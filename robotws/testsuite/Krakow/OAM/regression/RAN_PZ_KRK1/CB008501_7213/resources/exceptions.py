class ConnectionNotCreated(Exception):
    pass


class ConnectionNotStarted(Exception):
    pass


class RequiredCipherNotUsed(Exception):
    pass


class RequiredCipherNotSeen(Exception):
    pass


class ForbiddenCipherSeen(Exception):
    pass
