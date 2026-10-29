class SwitchSettingFailure(Exception):
    pass


class SwitchGettingFailure(Exception):
    pass


class UnallowedState(Exception):
    pass


class DeviceNotInDictionaryError(Exception):
    pass


class AldEmulatorConnectionException(Exception):
    pass


class AldEmulatorOutputException(Exception):
    pass


class RfLockUnsuccessfulException(Exception):
    pass


class RfUnlockUnsuccessfulException(Exception):
    pass


class RfResetUnsuccessfulException(Exception):
    pass


class RMODStatusNotOkException(Exception):
    pass


class KeyErrorInEnvironmentsDict(Exception):
    pass


class WrongFEGValueException(Exception):
    pass


class IncorrectRadioException(Exception):
    pass


class ClewareDeviceNotFoundException(Exception):
    pass


class AntennaLineNotFound(Exception):
    pass
