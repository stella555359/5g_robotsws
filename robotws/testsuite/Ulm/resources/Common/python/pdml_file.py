from robot.libraries.BuiltIn import BuiltIn
from taf.analyzer.pdml import PdmlReader, pdml
import os


def strip_headers(source_file, target_file):
    """
    Strips tshark header from given pdml file.
    """
    try:
        line_counter = 0
        with open(source_file, 'rb') as in_file, open(target_file, 'wb') as out_file:
            while True:
                if "xml version" in str(in_file.readline()):
                    break
                if line_counter > 100:
                    BuiltIn().log("ERR: Error with PDML format")
                    return None
                line_counter += 1
            out_file.writelines(in_file.readlines())
        os.chmod(target_file, 0o666)
    except IOError as e:
        BuiltIn().log("File %s not found" % source_file, "ERROR")
        BuiltIn().log(str(e), "ERROR")
        return None
    return


# NSA measurements

def find_a2_measurement_id(pdml_file_path):
    """
    Read pdml file and find A2 measurement id inside RRC Reconfiguration message.
    A2 measurement id is needed for handover scenarios.
    """
    a2_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a2_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element"):
                event_ids = root.xpath(
                    "x2ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA2" in event_id.showname:
                        a2_report_config_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_report_config_id = %s" % a2_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "x2ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a2_report_config_id:
                        a2_measurement_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_measurement_id = %s" % a2_measurement_id)
                        break
    if a2_measurement_id is None:
        raise AssertionError("A2 measurement id could not be found!!!")
    return a2_measurement_id


def find_a3_measurement_id(pdml_file_path):
    """
    Read pdml file and find A3 measurement id inside RRC Reconfiguration message.
    A3 measurement id is needed for handover scenarios.
    """
    a3_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a3_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element"):
                event_ids = root.xpath(
                    "x2ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA3" in event_id.showname:
                        a3_report_config_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_report_config_id = %s" % a3_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "x2ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a3_report_config_id:
                        a3_measurement_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_measurement_id = %s" % a3_measurement_id)
                        break
            elif root.xpath("x2ap//..//x2ap.SgNBModificationRequestAcknowledge_element"):
                event_ids = root.xpath(
                    "x2ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA3" in event_id.showname:
                        a3_report_config_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_report_config_id = %s" % a3_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "x2ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a3_report_config_id:
                        a3_measurement_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_measurement_id = %s" % a3_measurement_id)
                        break
    if a3_measurement_id is None:
        raise AssertionError("A3 measurement id could not be found!!!")
    return a3_measurement_id


def find_a1_measurement_id(pdml_file_path):
    """
    Read pdml file and find A1 measurement id inside RRC Reconfiguration message.
    A1 measurement id is needed for handover scenarios.
    """
    a1_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a1_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("x2ap//..//x2ap.SgNBModificationRequestAcknowledge_element"):
                event_ids = root.xpath(
                    "x2ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA1" in event_id.showname:
                        a1_report_config_id = idx + 1
                        BuiltIn().log("find_a1_measurement_id(): a1_report_config_id = %s" % a1_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "x2ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a1_report_config_id:
                        a1_measurement_id = idx + 1
                        BuiltIn().log("find_a1_measurement_id(): a1_measurement_id = %s" % a1_measurement_id)
                        break
    if a1_measurement_id is None:
        raise AssertionError("A1 measurement id could not be found!!!")
    return a1_measurement_id


def find_a5_measurement_id(pdml_file_path):
    """
    Read pdml file and find A5 measurement id inside RRC Reconfiguration message.
    A5 measurement id is needed for handover scenarios.
    """
    a5_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a5_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("x2ap//..//x2ap.SgNBAdditionRequestAcknowledge_element"):
                event_ids = root.xpath(
                    "x2ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA5" in event_id.showname:
                        a5_report_config_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_report_config_id = %s" % a5_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "x2ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a5_report_config_id:
                        a5_measurement_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a5_measurement_id = %s" % a5_measurement_id)
                        break
            elif root.xpath("x2ap//..//x2ap.SgNBModificationRequestAcknowledge_element"):
                event_ids = root.xpath(
                    "x2ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA5" in event_id.showname:
                        a5_report_config_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_report_config_id = %s" % a5_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "x2ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a5_report_config_id:
                        a5_measurement_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_measurement_id = %s" % a5_measurement_id)
                        break
    if a5_measurement_id is None:
        raise AssertionError("A5 measurement id could not be found!!!")
    return a5_measurement_id
# end of NSA measurements


# SA measurements

def find_a5_measurement_id_SA(pdml_file_path):
    """
    Read pdml file and find A5 measurement id inside RRC Reconfiguration message.
    A5 measurement id is needed for handover scenarios.
    """
    a5_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a5_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("f1ap//..//f1ap.UEContextSetupRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA5" in event_id.showname:
                        a5_report_config_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_report_config_id = %s" % a5_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a5_report_config_id:
                        a5_measurement_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a5_measurement_id = %s" % a5_measurement_id)
                        break
            elif root.xpath("f1ap//..//f1ap.UEContextModificationRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA5" in event_id.showname:
                        a5_report_config_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_report_config_id = %s" % a5_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a5_report_config_id:
                        a5_measurement_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_measurement_id = %s" % a5_measurement_id)
                        break
            elif root.xpath("f1ap//..//f1ap.DLRRCMessageTransfer_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA5" in event_id.showname:
                        a5_report_config_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_report_config_id = %s" % a5_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a5_report_config_id:
                        a5_measurement_id = idx + 1
                        BuiltIn().log("find_a5_measurement_id(): a5_measurement_id = %s" % a5_measurement_id)
                        break
    if a5_measurement_id is None:
        raise AssertionError("A5 measurement id could not be found!!!")
    return a5_measurement_id


def find_a2_measurement_id_SA(pdml_file_path):
    """
    Read pdml file and find A2 measurement id inside RRC Reconfiguration message.
    A2 measurement id is needed for handover scenarios. SA scenario
    """
    a2_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a2_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("f1ap//..//f1ap.UEContextSetupRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA2" in event_id.showname:
                        a2_report_config_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_report_config_id = %s" % a2_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a2_report_config_id:
                        a2_measurement_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_measurement_id = %s" % a2_measurement_id)
                        break
            if root.xpath("f1ap//..//f1ap.UEContextModificationRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA2" in event_id.showname:
                        a2_report_config_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_report_config_id = %s" % a2_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a2_report_config_id:
                        a2_measurement_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_measurement_id = %s" % a2_measurement_id)
                        break
            elif root.xpath("f1ap//..//f1ap.DLRRCMessageTransfer_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA2" in event_id.showname:
                        a3_report_config_id = idx + 1
                        BuiltIn().log("find_a2_measurement_id(): a2_report_config_id = %s" % a2_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a2_report_config_id:
                        a2_measurement_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a2_measurement_id = %s" % a2_measurement_id)
                        break
    if a2_measurement_id is None:
        raise AssertionError("A2 measurement id could not be found!!!")
    return a2_measurement_id


def find_a1_measurement_id_SA(pdml_file_path):
    """
    Read pdml file and find A1 measurement id inside RRC Reconfiguration message.
    A1 measurement id is needed for handover scenarios. SA scenario
    """
    a1_measurement_id = None
    a1_report_config_id = None
    if not os.path.isfile(pdml_file_path):
        BuiltIn().fail("find_a1_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("f1ap//..//f1ap.UEContextModificationRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA1" in event_id.showname:
                        a1_report_config_id = idx + 1
                        BuiltIn().log("find_a1_measurement_id(): a1_report_config_id = %s" % a1_report_config_id)
                        break
                    else:
                        a1_report_config_id = None
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a1_report_config_id:
                        a1_measurement_id = idx + 1
                        BuiltIn().log("find_a1_measurement_id(): a1_measurement_id = %s" % a1_measurement_id)
                        break
            elif root.xpath("f1ap//..//f1ap.DLRRCMessageTransfer_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA1" in event_id.showname:
                        a1_report_config_id = idx + 1
                        BuiltIn().log("find_a1_measurement_id(): a1_report_config_id = %s" % a1_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a1_report_config_id:
                        a1_measurement_id = idx + 1
                        BuiltIn().log("find_a1_measurement_id(): a1_measurement_id = %s" % a1_measurement_id)
                        break
                    else:
                        a1_report_config_id = None
    if a1_measurement_id is None:
        raise AssertionError("A1 measurement id could not be found!!!")
    return a1_measurement_id


def find_a3_measurement_id_SA(pdml_file_path):
    """
    Read pdml file and find A3 measurement id inside RRC Reconfiguration message.
    A3 measurement id is needed for handover scenarios. SA scenario
    """
    a3_measurement_id = None
    if not os.path.isfile(pdml_file_path):
        raise AssertionError(
            "find_a3_measurement_id(): %s does not exist!!!" % pdml_file_path)
    with open(pdml_file_path, 'rb') as file_obj:
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if root.xpath("f1ap//..//f1ap.UEContextSetupRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA3" in event_id.showname:
                        a3_report_config_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_report_config_id = %s" % a3_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a3_report_config_id:
                        a3_measurement_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_measurement_id = %s" % a3_measurement_id)
                        break
            elif root.xpath("f1ap//..//f1ap.UEContextModificationRequest_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA3" in event_id.showname:
                        a3_report_config_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_report_config_id = %s" % a3_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a3_report_config_id:
                        a3_measurement_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_measurement_id = %s" % a3_measurement_id)
                        break
            elif root.xpath("f1ap//..//f1ap.DLRRCMessageTransfer_element"):
                event_ids = root.xpath(
                    "f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA3" in event_id.showname:
                        a3_report_config_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_report_config_id = %s" % a3_report_config_id)
                        break
                report_config_ids = root.xpath(
                    "f1ap//..//nr-rrc.measIdToAddModList//..//nr-rrc.reportConfigId")
                for idx, report_config_id in enumerate(report_config_ids):
                    if int(report_config_id.show) == a3_report_config_id:
                        a3_measurement_id = idx + 1
                        BuiltIn().log("find_a3_measurement_id(): a3_measurement_id = %s" % a3_measurement_id)
                        break
    if a3_measurement_id is None:
        raise AssertionError("A3 measurement id could not be found!!!")
    return a3_measurement_id
# end of SA measurements
