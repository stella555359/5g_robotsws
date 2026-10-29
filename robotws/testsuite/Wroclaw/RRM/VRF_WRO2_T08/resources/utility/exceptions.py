class LogParsingError(Exception):
    pass


class TestConfigError(Exception):
    pass


class TimeoutExceeded(Exception):
    pass


class AllRetriesFailed(Exception):
    pass


class ConfigurationNotLoaded(Exception):
    pass


class SCFObjectNotFound(Exception):
    pass


class UeDropped(Exception):
    def __init__(self, attenuation=float('nan'), rsrp=float('nan')):
        self.attenuation = attenuation
        self.rsrp = rsrp

    def __str__(self):
        return "Ue probably dropped at attenuation {}db and rsrp {}".format(self.attenuation, self.rsrp)

    def __repr__(self):
        return self.__str__()


class AttachVerificationFail(Exception):
    pass
