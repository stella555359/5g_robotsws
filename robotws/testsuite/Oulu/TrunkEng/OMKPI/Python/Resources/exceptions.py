class StartupLimitException(Exception):
    pass


class CalculationException(Exception):
    pass


class ValueNotChangedException(Exception):
    pass


class ValueNotSameException(Exception):
    pass


class KpiNotFound(Exception):
    pass


class RadioSofwareNotUpdated(Exception):
    pass


class RadioSoftwareUpdateError(Exception):
    pass


class FileNotFound(Exception):
    pass


class KpiValuesNotMatching(Exception):
    pass


class NoKpi77aStartPoints(Exception):
    pass


class NoKpi77aEndPoints(Exception):
    pass


class CounterDoesNotExist(Exception):
    pass


class CounterNotInLimits(Exception):
    pass


class PMFileDoesntExist(Exception):
    pass


class PMFileExist(Exception):
    pass


class NoL1StartupCheckpoint(Exception):
    pass


class L1StartupCheckpointFailure(Exception):
    pass


class SwdlShutdownTimeFailure(Exception):
    pass


class NoCooledSFPInfo(Exception):
    pass
