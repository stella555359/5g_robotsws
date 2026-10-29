class EnvironmentIssue(Exception):
    pass


class ScriptIssue(Exception):
    pass


class SSHConnectionFailure(Exception):
    pass


class BTSConnectionFailure(Exception):
    pass


class PassRateException(Exception):
    pass


class UnexpectedBTSStatus(Exception):
    pass


class WrongCellStates(Exception):
    pass


class UnallowedAlarmFound(Exception):
    pass


class ExpectedAlarmNotFound(Exception):
    pass


class PIDNotFound(Exception):
    pass


class BTSConfigurationNotFound(Exception):
    pass


class ConfigurationIssue(Exception):
    pass


class TestSettingsError(Exception):
    pass


class UnitNotFound(Exception):
    pass


class ExpectedSyslogPrintNotFound(Exception):
    pass


class UnexpectedSyslogPrintFound(Exception):
    pass


class PingToIpNotLost(Exception):
    pass


class NoReplyToPing(Exception):
    pass


class CellDownWithoutActiveAlarm(Exception):
    pass


class CellsDown(Exception):
    pass


class PathToIms2NotGiven(Exception):
    pass


class StateNotInIms2History(Exception):
    pass


class NoDictionaryForIms2HistoryCheck(Exception):
    pass


class WrongStateInIms2History(Exception):
    pass


class ComponentNotFoundFromIms2History(Exception):
    pass


class ElementNotFoundFromIms2History(Exception):
    pass


class StateNotFoundFromIms2History(Exception):
    pass


class BuildNotFoundFromArtifactory(Exception):
    pass


class TimeOutWhenDownloadingFromArtifactory(Exception):
    pass


class ExpectedSwBuildIsNotActive(Exception):
    pass


class SoftwareUpdateFailure(Exception):
    pass


class SoftwareRollbackFailure(Exception):
    pass


class NoFronthaulSwitch(Exception):
    pass


class ClassNotFoundFromCommissioning(Exception):
    pass


class ExpectedLogsNotFound(Exception):
    pass


class UnexpectedRestartCounterValue(Exception):
    pass


class SizeOfSwBuildIsUnexpected(Exception):
    pass


class TCPFailure(Exception):
    pass


class WrongRadioStates(Exception):
    pass


class WrongBbmodStates(Exception):
    pass


class WrongSmodStates(Exception):
    pass


class SwNodeNotFound(Exception):
    pass


class DataTransferFailed(Exception):
    pass


class InvalidUserInput(Exception):
    pass


class PromotedBuildNotFoundFromWft(Exception):
    pass


class UnableToParseTimestampFromSyslog(Exception):
    pass


class FileNotFoundFromTestLogs(Exception):
    pass


class UnitResetFailed(Exception):
    pass


class UnableToGetTimesFromSyslog(Exception):
    pass


class BtsAndPcTimeDiffereceTooBig(Exception):
    pass


class ClassNotFoundFromScfFile(Exception):
    pass


class ElementNotFoundFromScfFile(Exception):
    pass


class CommissioningFailure(Exception):
    pass


class SyslogFilesNotFound(Exception):
    pass


class HaltTheTest(Exception):
    pass


class ErrorFromAdmin(Exception):
    pass


class ErrorFromRescueConsole(Exception):
    pass


class FhsSoftwareUpdateFailure(Exception):
    pass


class IncorrectDocxoValues(Exception):
    pass


class WrongRadioUptimes(Exception):
    pass


class SwActivationNotSuccessful(Exception):
    pass


class ComparisonFailure(Exception):
    pass


class UTFLabFailure(Exception):
    pass


class SoftwarePrecheckFailure(Exception):
    pass
