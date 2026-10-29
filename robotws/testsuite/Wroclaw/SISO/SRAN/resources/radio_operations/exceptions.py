"""
:modified:06.02.2025

:author: Mateusz Kawka
:maintainer: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""


class NotSupportedRadioUnit(Exception):
    def __init__(self, radio_unit):
        super(NotSupportedRadioUnit, self).__init__(
            f"Radio unit: {radio_unit} is not supported.\n\
            Please raise request for add new radio unit support")


class NotSupportedAntennaLineType(Exception):
    def __init__(self, radio_type):
        super(NotSupportedAntennaLineType, self).__init__(
            f"Antenna line type :{radio_type} not supported, supported values: 'physical', 'virtual', 'frmon'")


class NotSupportedAntennaLineDirection(Exception):
    def __init__(self, direction):
        super(NotSupportedAntennaLineDirection, self).__init__(
            f"Antenna line direction :{direction} not supported, supported values: 'RX', 'TX'")


class NotFoundCustomMapping(Exception):
    def __init__(self, direction, radio_type):
        super(NotFoundCustomMapping, self).__init__(
            f"CUSTOM_MAPPING dictionary doesn't contain {direction} for {radio_type}")


class NotFoundRadioModule(Exception):
    def __init__(self, radio_sn, module='system module(s)'):
        super(NotFoundRadioModule, self).__init__(
            f"Radio module with serial number {radio_sn} was not found on {module}")


class SendCommandFailure(Exception):
    def __init__(self):
        super(SendCommandFailure, self).__init__(
            "Unable to send command, check SSH connection establishment")


class OutputReadingError(Exception):
    def __init__(self):
        super(OutputReadingError, self).__init__(
            "Unable to read output from channel!")


class ExpectedOutputNotFound(Exception):
    def __init__(self, expected_output, timeout):
        super(ExpectedOutputNotFound, self).__init__(
            f"Expected output: {expected_output} not found in {timeout}s!")


class CannotConnectToRemoteHost(Exception):
    def __init__(self, remote_host):
        super(CannotConnectToRemoteHost, self).__init__(
            f"Cannot establish connection to remote host {remote_host}")


class CannotConnectToEnb(Exception):
    def __init__(self, hostname):
        super(CannotConnectToEnb, self).__init__(
            f"Cannot establish connection to ENB on {hostname}!")


class CannotConnectToRadioModule(Exception):
    def __init__(self):
        super(CannotConnectToRadioModule, self).__init__(
            "Cannot establish connection to RU, maybe FID 10 visible ?")


class CannotGetPowerFromRU(Exception):
    def __init__(self):
        super(CannotGetPowerFromRU, self).__init__(
            "Cannot get power table from RU!")


class NotSupportedTypeOfFrmonData(Exception):
    def __init__(self, type_of_data):
        super(NotSupportedTypeOfFrmonData, self).__init__(
            f"Not supported type of data: {type_of_data}, supported: `power` and `data`")


class NotSupportedRuFamily(Exception):
    def __init__(self, ru_family, fault_id):
        super(NotSupportedRuFamily, self).__init__(
            f"Not supported RU family: {ru_family} to generate fault {fault_id}")


class NotSupportedTypeOfRu(Exception):
    def __init__(self, ru_type, ru_name):
        super(NotSupportedTypeOfRu, self).__init__(
            f"Not supported RU type: {ru_type} - {ru_name}")


class FaultNotSupported(Exception):
    def __init__(self, fault_id):
        super(FaultNotSupported, self).__init__(
            f"Not supported fault: {fault_id}")


class CannotDefineSecondHostname(Exception):
    def __init__(self):
        super(CannotDefineSecondHostname, self).__init__(
            "Cannot define name of second hostname !")


class CannotReadDAPDPower(Exception):
    def __init__(self, ru_name):
        super(CannotReadDAPDPower, self).__init__(
            f"Cannot read TX power from DAPD for RU:{ru_name} !")


class NotSupportedRuForDAPD(Exception):
    def __init__(self, ru_name):
        super(NotSupportedRuForDAPD, self).__init__(
            f"RU:{ru_name} is not supported for DAPD TX power, only RU >= 5.1 !")


class WrongAntennaMappingDAPD(Exception):
    def __init__(self, ru_name):
        super(WrongAntennaMappingDAPD, self).__init__(
            f"Wrong antenna mapping for {ru_name}, at least one of antenna not found on SoC ")


class FaultAssertionError(Exception):
    def __init__(self, fault_id, severity, fault_state, fault_name):
        if severity is None:
            severity = ''
        else:
            severity = f", severity {severity}"
        if fault_name is None:
            fault_name = ''
        else:
            fault_name = f", faultName {fault_name}"
        super(FaultAssertionError, self).__init__(
            f"{fault_state} faultId {fault_id}{severity}{fault_name} not found in fault_history_log file")


class AlarmAssertionError(Exception):
    def __init__(self, alarm_id, severity, alarm_state, alarm_name):
        if severity is None:
            severity = ''
        else:
            severity = f", severity {severity}"

        super(AlarmAssertionError, self).__init__(
            f"{alarm_state} alarmId {alarm_id}, alarmName {alarm_name}{severity} not found in fault_history_log file")


class FaultSensorNotDefined(Exception):
    def __init__(self, sensor, ru_name):
        super(FaultSensorNotDefined, self).__init__(
            f"Sensor '{sensor}' not defined in TEMPERATURE_SENSORS for {ru_name}")


class ProcessIdNotFound(Exception):
    def __init__(self, process_name):
        super(ProcessIdNotFound, self).__init__(
            f"Process ID for process '{process_name}' not found !")


class TooManyMatchingProcesses(Exception):
    def __init__(self, process_name):
        super(TooManyMatchingProcesses, self).__init__(
            f"Too many processes with name '{process_name}' found\nProvide a more explicit process name!")


class SCPFileTransferFailure(Exception):
    def __init__(self, file_path, destination_dir):
        super(SCPFileTransferFailure, self).__init__(
            f"SCP file {file_path} transfer to destination: {destination_dir} failure!")


class KeyNotFoundInBinaryFile(Exception):
    def __init__(self, key, filename):
        super(KeyNotFoundInBinaryFile, self).__init__(
            f"Key: {key} was not found in binary file: {filename}")


class RadioModulePingTimeExceeded(Exception):
    def __init__(self, ru_name, ru_ip, expect_ping, timeout):
        super(RadioModulePingTimeExceeded, self).__init__(
            f"Radio module {ru_name} with IP {ru_ip} still has {expect_ping} ping status, timeout was: {timeout}s !")


class CalibrationDlPathFileNotFound(Exception):
    def __init__(self, ru_name):
        super(CalibrationDlPathFileNotFound, self).__init__(
            f"No any calibration_dlpathX.bin file was found on {ru_name} radio module !")


class NotSupportedFaultSeverity(Exception):
    def __init__(self, fault_id, severity):
        super(NotSupportedFaultSeverity, self).__init__(
            f"Unsupported severity: {severity} for faultId: {fault_id}")


class NotMatchPipeSensor(Exception):
    def __init__(self, sensor_type_var, sensor_type_tcs):
        super(NotMatchPipeSensor, self).__init__(
            f"TCS.bin file required sensor: {sensor_type_tcs} to trigger FID 1927 Minor,"
            f" but sensor: {sensor_type_var} is defined in radio_variables !")


class CannotReadSfpInfoFromRu(Exception):
    def __init__(self, sfp_id):
        super(CannotReadSfpInfoFromRu, self).__init__(
            f"Cannot read any SFP data for sfp_id {sfp_id}, make sure that SFP is inserted to provided port !")


class SfpOverrideFailed(Exception):
    def __init__(self):
        super(SfpOverrideFailed, self).__init__(
            "Cannot override sfp data, if recovering make sure that fault was generated first !")


class RfLogsNotFound(Exception):
    def __init__(self):
        super(RfLogsNotFound, self).__init__(
            "None of the runtime log files contain any information about temperatures for radio sensors !")


class RfLogsCoverageNotSupported(Exception):
    def __init__(self, coverage):
        super(RfLogsCoverageNotSupported, self).__init__(
            f"Given RF logs coverage -> {coverage} <- to collect is not supported,"
            " following modes are supported: Full, Minor")


class CloudRanArgumentMissing(Exception):
    def __init__(self, argument):
        super(CloudRanArgumentMissing, self).__init__(
            f"Missing argument: {argument} for CloudRAN connection!")


class NotSupportedSmodUnit(Exception):
    def __init__(self, smod_unit):
        super(NotSupportedSmodUnit, self).__init__(
            f"SMOD unit: {smod_unit} is not supported.\n\
             Please raise request for add new SMOD unit support")


class TempSensorNotFound(Exception):
    def __init__(self, sensor_name, possible_sensors):
        super(TempSensorNotFound, self).__init__(
            f"Sensor {sensor_name} is not valid for this RU, all possibilities: {possible_sensors}")


class TempOffsetSensorNotFound(Exception):
    def __init__(self, sensor_name):
        super(TempOffsetSensorNotFound, self).__init__(
            f"Sensor {sensor_name} is not found in tempest_inst.json file")
