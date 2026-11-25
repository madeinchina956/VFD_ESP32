enum SessionAccess {
  disconnected,
  local,
  available,
  busy,
  authorized,
}

extension SessionAccessText on SessionAccess {
  String get label => switch (this) {
    SessionAccess.disconnected => 'Disconnected / access unknown',
    SessionAccess.local => 'Local interface active',
    SessionAccess.available => 'Remote available',
    SessionAccess.busy => 'Another device owns the session',
    SessionAccess.authorized => 'Remote session authorized',
  };
}

// In-process simulation only.
// Separate phones require a shared server.
class DemoSessionAuthority {
  bool _remote = false;
  Object? _owner;

  final Stopwatch _clock = Stopwatch()..start();

  int _expiresAt = 0;
  final Duration lease;

  DemoSessionAuthority({
    this.lease = const Duration(seconds: 5),
  });

  bool get remote => _remote;

  void setRemote(bool value) {
    if (_remote != value) {
      _remote = value;
      _owner = null;
    }
  }

  void _expire() {
    if (_clock.elapsedMilliseconds >= _expiresAt) {
      _owner = null;
    }
  }

  SessionAccess stateFor(Object client) {
    _expire();

    if (!_remote) {
      return SessionAccess.local;
    }

    if (_owner == null) {
      return SessionAccess.available;
    }

    return identical(_owner, client)
        ? SessionAccess.authorized
        : SessionAccess.busy;
  }

  SessionAccess acquire(Object client) {
    final state = stateFor(client);

    if (state == SessionAccess.available ||
        state == SessionAccess.authorized) {
      _owner = client;

      _expiresAt =
          _clock.elapsedMilliseconds +
          lease.inMilliseconds;
    }

    return stateFor(client);
  }

  bool renew(Object client) {
    if (stateFor(client) != SessionAccess.authorized) {
      return false;
    }

    _expiresAt =
        _clock.elapsedMilliseconds +
        lease.inMilliseconds;

    return true;
  }

  void release(Object client) {
    if (identical(_owner, client)) {
      _owner = null;
    }
  }
}