class PMFileExist(Exception):
    pass


class PMFileDoesntExist(Exception):
    pass


class StateException(Exception):
    pass


class PMFileCheckFailed(Exception):
    pass


class CounterDoesNotExist(Exception):
    pass


class CounterNotInLimits(Exception):
    pass


class SFPException(Exception):
    pass


class Ne3sInterfaceException(Exception):
    pass


class GcsTimeException(Exception):
    pass


class SnapshotException(Exception):
    pass
