import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/vfd_status.dart';
import 'session_access.dart';

class Esp32Service extends ChangeNotifier {
  final String baseUrl;
  final bool demoMode;
  final http.Client _client;
  final DemoSessionAuthority _demoAuthority;
  final Object _demoIdentity = Object();

  static final _sharedDemo = DemoSessionAuthority();

  final _timeout = const Duration(seconds: 2);
  final _random = Random();

  SessionAccess _access = SessionAccess.disconnected;

  VfdStatus? _latest;
  String? _token, _message;

  bool _working = false, _disposed = false;
  int _epoch = 0;

  Future<VfdStatus>? _poll;
  Timer? _freshness;

  VfdStatus _demoStatus = _initialDemo();

  Esp32Service({
    this.baseUrl = 'http://192.168.4.1',
    this.demoMode = true,
    http.Client? client,
    DemoSessionAuthority? demoAuthority,
  }) : _client = client ?? http.Client(),
       _demoAuthority = demoAuthority ?? _sharedDemo;

  // SESSION PROPERTIES

  SessionAccess get access => _access;
  bool get working => _working;
  String? get message => _message;
  bool get demoRemote => _demoAuthority.remote;

  bool get _demoOwns =>
      _demoAuthority.stateFor(_demoIdentity) ==
      SessionAccess.authorized;

  VfdStatus? get latestStatus =>
      _access == SessionAccess.authorized &&
          !_working &&
          !_disposed &&
          (!demoMode || _demoOwns)
      ? _latest : null;

  bool get hasMeasurements =>
      latestStatus?.connected == true;

  bool get canUseDemoControls =>
      demoMode && hasMeasurements;

  static VfdStatus _initialDemo() =>
      VfdStatus.initial().copyWith(
        connected: true,
        dcLinkVoltage: 48.0,
      );

  VfdStatus _unavailable() =>
      VfdStatus.initial().copyWith(connected: false);

  bool _current(int epoch) =>
      !_disposed && epoch == _epoch;

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  // CLEAR SESSION AND MEASUREMENTS

  void _clear(SessionAccess state, [String? message]) {
    _freshness?.cancel();
    _latest = null;
    _token = null;
    _access = state;
    _message = message;

    if (demoMode) _demoStatus = _initialDemo();

    _publish();
  }

  void invalidateAccess() {
    if (_disposed) return;

    _epoch++;
    _working = false;

    if (demoMode) _demoAuthority.release(_demoIdentity);

    _clear(SessionAccess.disconnected);
  }

  void _accept(VfdStatus status) {
    if (!status.connected) {
      throw StateError('Disconnected status');
    }

    _latest = status;
    _message = null;
    _freshness?.cancel();

    _freshness = Timer(const Duration(seconds: 4), () {
      _epoch++;

      if (demoMode) _demoAuthority.release(_demoIdentity);

      _clear(
        SessionAccess.disconnected,
        'Measurement refresh expired.',
      );
    });

    _publish();
  }

  // HTTP COMMUNICATION

  Future<http.Response> _request(
    String path, {
    bool post = false,
    String? token,
  }) {
    final uri = Uri.parse('$baseUrl$path');

    final headers = {
      'Accept': 'application/json',
      'Cache-Control': 'no-store',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    return (post
        ? _client.post(uri, headers: headers)
        : _client.get(uri, headers: headers)).timeout(_timeout);
  }

  Map<String, dynamic> _json(http.Response response) =>
      jsonDecode(response.body) as Map<String, dynamic>;

  SessionAccess _state(Map<String, dynamic> body) =>
      switch (body['state']) {
        'local' => SessionAccess.local,
        'available' => SessionAccess.available,
        'busy' => SessionAccess.busy,
        'authorized' => SessionAccess.authorized,
        _ => throw const FormatException('Unknown session state'),
      };

  SessionAccess _denied(int code) => switch (code) {
    409 => SessionAccess.busy,
    423 => SessionAccess.local,
    _ => SessionAccess.disconnected,
  };

  // SIMULATED LOCAL/REMOTE SELECTION

  void setDemoRemote(bool remote) {
    if (!demoMode || _disposed || _working) return;

    _epoch++;
    _demoAuthority.setRemote(remote);

    final state = _demoAuthority.stateFor(_demoIdentity);

    if (state != SessionAccess.authorized) {
      _clear(state);
    } else {
      _publish();
    }
  }

  // SHARED SESSION ACTION HANDLER

  Future<void> _sessionAction(
    Future<void> Function(int) action,
    String errorMessage,
  ) async {
    final epoch = ++_epoch;

    _working = true;
    _latest = null;
    _freshness?.cancel();
    _publish();

    try {
      if (_current(epoch)) await action(epoch);
    } catch (_) {
      if (_current(epoch)) {
        _clear(SessionAccess.disconnected, errorMessage);
      }
    } finally {
      if (_current(epoch)) {
        _working = false;
        _publish();
      }
    }
  }

  // REQUEST ACCESS

  Future<void> requestAccess() async {
if (_disposed ||
    _working ||
    _access != SessionAccess.available) {
  return;
}
    await _sessionAction((epoch) async {
      if (demoMode) {
        _access = _demoAuthority.acquire(_demoIdentity);
      } else {
        final response = await _request(
          '/api/session/acquire',
          post: true,
        );

        if (!_current(epoch)) return;

        if (response.statusCode == 409 ||
            response.statusCode == 423) {
          _clear(_denied(response.statusCode));
          return;
        }

        if (response.statusCode != 200) {
          throw StateError('Access denied');
        }

        final body = _json(response);
        final token = body['token'];

        if (_state(body) != SessionAccess.authorized ||
            token is! String ||
            token.isEmpty) {
          throw const FormatException('Invalid session token');
        }

        _token = token;
        _access = SessionAccess.authorized;
      }

      _message = null;
    }, 'Could not establish session.');
  }

  // RELEASE ACCESS

  Future<void> releaseAccess() async {
if (_disposed ||
    _working ||
    _access != SessionAccess.authorized) {
  return;
}
    final token = _token;

    await _sessionAction((epoch) async {
      _clear(SessionAccess.disconnected);

      if (demoMode) {
        _demoAuthority.release(_demoIdentity);
        _access = _demoAuthority.stateFor(_demoIdentity);
      } else if (token != null && _current(epoch)) {
        final response = await _request(
          '/api/session/release',
          post: true,
          token: token,
        );

        if (!_current(epoch)) return;

        if (response.statusCode != 200 &&
            response.statusCode != 204) {
          throw StateError('Release not confirmed');
        }
      }
    }, 'Release unconfirmed; server lease must expire.');
  }

  // STATUS POLLING

  Future<VfdStatus> getStatus() {
    if (_disposed || _working) {
      return Future.value(_unavailable());
    }

    return _poll ??=
        _readStatus(_epoch).whenComplete(() => _poll = null);
  }

  Future<VfdStatus> _readStatus(int epoch) async {
    try {
      if (demoMode) {
        final state = _demoAuthority.stateFor(_demoIdentity);

        if (state != SessionAccess.authorized ||
            !_demoAuthority.renew(_demoIdentity)) {
          _clear(state);
          return _unavailable();
        }

        _access = state;
        _accept(_simulate());

        return _latest ?? _unavailable();
      }

      final token = _token;

      final authorized =
          token != null &&
          _access == SessionAccess.authorized;

      final response = await _request(
        authorized ? '/api/status' : '/api/session',
        token: authorized ? token : null,
      );

      if (!_current(epoch)) return _unavailable();

      if (authorized &&
          [401, 403, 409, 423].contains(response.statusCode)) {
        _clear(
          _denied(response.statusCode),
          'Session no longer authorized.',
        );

        return _unavailable();
      }

      if (response.statusCode != 200) {
        throw StateError('Request failed');
      }

      final body = _json(response);

      if (!authorized) {
        final state = _state(body);

        if (state == SessionAccess.authorized) {
          throw StateError('Unexpected authorization');
        }

        _clear(state);
        return _unavailable();
      }

      _accept(_validatedStatus(body));

      return _latest ?? _unavailable();

    } catch (_) {
      if (_current(epoch)) {
        if (demoMode) {
          _demoAuthority.release(_demoIdentity);
        }

        _clear(
          SessionAccess.disconnected,
          'Session or connection lost.',
        );
      }

      return _unavailable();
    }
  }

  // VALIDATE RECEIVED MEASUREMENTS

  VfdStatus _validatedStatus(Map<String, dynamic> body) {
    if (body['session_authorized'] != true ||
        body['running'] is! bool ||
        body['fault_active'] is! bool ||
        body['fault_code'] is! int ||
        body['fault_description'] is! String ||
        !['forward', 'reverse'].contains(body['direction']) ||
        !['speed', 'manual'].contains(body['mode'])) {
      throw const FormatException('Invalid authorized snapshot');
    }

    for (final key in [
      'commanded_rpm',
      'actual_rpm',
      'motor_current',
      'dc_link_voltage',
      'estimated_torque',
    ]) {
      final value = body[key];

      if (value is! num || !value.isFinite) {
        throw FormatException('Invalid $key');
      }
    }

    return VfdStatus.fromJson(body);
  }

  // SHARED SIMULATION CONTROL HANDLER

  Future<void> _updateDemo(
    VfdStatus Function(VfdStatus) update,
  ) async {
    if (!demoMode) {
      throw UnsupportedError('Live motor control is disabled.');
    }

    if (!canUseDemoControls) {
      throw StateError('Demo session not authorized');
    }

    _demoStatus = update(_demoStatus);
  }

  // SIMULATED MOTOR CONTROLS

  Future<void> requestStart() => _updateDemo((s) {
    if (s.faultActive) {
      throw StateError('Cannot start while a fault is active.');
    }

    return s.copyWith(running: true);
  });

  Future<void> requestStop() =>
      _updateDemo((s) => s.copyWith(
        running: false,
        actualRpm: 0,
      ));

  Future<void> setSpeed(double rpm) =>
      _updateDemo((s) => s.copyWith(commandedRpm: rpm));

  Future<void> setDirection(String direction) async {
    if (!['forward', 'reverse'].contains(direction)) {
      throw ArgumentError('Direction must be forward or reverse.');
    }

    await _updateDemo((s) => s.copyWith(direction: direction));
  }

  Future<void> setOperatingMode(String mode) =>
      _updateDemo((s) => s.copyWith(operatingMode: mode));

  Future<void> resetFault() =>
      _updateDemo((s) => s.copyWith(
        faultActive: false,
        faultCode: 0,
        faultDescription: 'No fault',
      ));

  // SIMULATED MEASUREMENTS

  VfdStatus _simulate() {
    final s = _demoStatus;

    double rpm = s.running
        ? max(
            0.0,
            s.actualRpm +
                (s.commandedRpm - s.actualRpm) * 0.25 +
                _random.nextDouble() * 4 - 2,
          )
        : (s.actualRpm * 0.5 < 1 ? 0.0 : s.actualRpm * 0.5);

    _demoStatus = s.copyWith(
      connected: true,
      actualRpm: rpm,
      motorCurrent: s.running
          ? 1.5 + _random.nextDouble() * 0.5 : 0.0,
      estimatedTorque: s.running
          ? 1.0 + _random.nextDouble() * 0.3 : 0.0,
      dcLinkVoltage: 47.5 + _random.nextDouble(),
    );

    return _demoStatus;
  }

  // CLEANUP

  @override
  void dispose() {
    _disposed = true;
    _epoch++;
    _freshness?.cancel();

    if (demoMode) {
      _demoAuthority.release(_demoIdentity);
    }

    _token = null;
    _latest = null;
    _client.close();

    super.dispose();
  }
}