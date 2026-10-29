class AlarmIsNotActive(Exception):
    pass


class AlarmIsActive(Exception):
    pass


class ValidationError(Exception):
    def __init__(self, message=None, errors=None):
        super(ValidationError, self).__init__(message)
        self.errors = errors


class DSSIsNotDeactivated(Exception):
    pass


class SynchronizationError(Exception):
    pass


class ValidationErrorNotActive(Exception):
    pass


class UnexpectedDssStatus(Exception):
    pass


class CellNotOnAir(Exception):
    pass


class ConfigurationError(Exception):
    pass


class AbsentMandatoryAlarms(Exception):
    pass


class UnallowedAlarms(Exception):
    pass


class WrongRadioModuleStatus(Exception):
    pass


class IncorrectSfpData(Exception):
    pass


class NoConnectedSfp(Exception):
    pass


class ExpectedSfpNotFound(Exception):
    pass


class WrongNrarfcnFrequency(Exception):
    pass


class WrongBasicBeamSet(Exception):
    pass


class CertificateVerificationError(Exception):
    pass


class NrcellgrpNotFound(Exception):
    pass


class AaShellConnectionEstablished(Exception):
    pass


class ParameterChangingError(Exception):
    pass


class FileNotFound(Exception):
    pass


class InvalidFileNameError(Exception):
    pass


class UnexpectedWebemBehavior(Exception):
    pass


class WrongApiException(Exception):
    pass


class InvalidIntervalsOrValuesCounter(Exception):
    pass


class StartUpTargetNotMet(Exception):
    pass


class AverageStartupTargetNotMet(StartUpTargetNotMet):
    pass


class WrongNumberOfRadios(Exception):
    pass


class F1LinkNotTerminated(Exception):
    pass


class SshConnectionFailed(Exception):
    pass


class WrongParameterSettings(Exception):
    pass


class ComponentIsNotOnline(Exception):
    pass


class UptimeTooLong(Exception):
    pass


class UnexpectedBtsResetOccurred(Exception):
    pass


class WrongPduStatus(Exception):
    pass


class SiteNotOnAir(Exception):
    pass


class InvalidParameterValue(Exception):
    pass


class SshKeyNotExists(Exception):
    pass


class ListsAreNotEqual(Exception):
    pass


class BadTputFormat(Exception):
    pass


class InvalidStatuses(Exception):
    pass


class UeProcedureFailure(Exception):
    pass


class F1LinkUnavailable(Exception):
    pass


class CertificateMissmatch(Exception):
    pass


class SystemCheckFailure(Exception):
    pass


class MessageMissing(Exception):
    pass


class NotAllCellsDisabled(Exception):
    pass


class NotAllCellsEnabled(Exception):
    pass


class CuNotAvailable(Exception):
    pass


class LockCellFailure(Exception):
    pass


class UnlockCellFailure(Exception):
    pass


class LockUnlockTargetNotMet(Exception):
    pass


class SnapshotNotCollectedInTime(Exception):
    pass


class AmswissknifeOperationNotAvailable(Exception):
    pass


class SwDownloadDurationNotMet(Exception):
    pass


class AverageSwDownloadDurationNotMet(SwDownloadDurationNotMet):
    pass


class SwActivationDurationNotMet(Exception):
    pass


class AverageSwActivationDurationNotMet(SwActivationDurationNotMet):
    pass


class SwUpgradeDurationNotMet(Exception):
    pass


class AverageSwUpgradeDurationNotMet(SwUpgradeDurationNotMet):
    pass


class UpgradeTargetNotMet(Exception):
    pass


class AverageUpgradeTargetNotMet(Exception):
    pass


class SnapshotCollectionNotStarted(Exception):
    pass


class SnapshotCollectionStarted(Exception):
    pass
