class RUValidationError(Exception):
    """
    Raised when numer of RUs from ru_matrix is not equal number of RUs from BTS
    """


class SWDowloadError(Exception):
    """
    Raised when sth wrong during software download
    """


class RuResetNotExecuted(Exception):
    """
    Raised when RU reset operation has been started but the RU reboot not occurred.
    """


class AlarmNotTriggered(Exception):
    pass


class WrongCellTriggered(Exception):
    pass


class CellInitializationNotFinished(Exception):
    pass
