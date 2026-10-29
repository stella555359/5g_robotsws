# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used for CB007491 Feature
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import math
import io
import csv
import logging

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.XML import XML
from robot.utils import asserts

import xml.etree.ElementTree as ET

from taf.config.scf import scf
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


def create_beam_control_dict():
    beam_control_dict = {0: {'ueBeamIndexInitial': '0,1,2,3,4,5', 'ssbeam_bestbeam': '0', 'ssbeam_rsrp_best': '-44',
                             'ssbeam_rsrp_avg': '-50'},
                         1: {'ueBeamIndexInitial': '1,0,2,3,4,5', 'ssbeam_bestbeam': '1', 'ssbeam_rsrp_best': '-45',
                             'ssbeam_rsrp_avg': '-120'},
                         2: {'ueBeamIndexInitial': '2,0,1,3,4,5', 'ssbeam_bestbeam': '2', 'ssbeam_rsrp_best': '-50',
                             'ssbeam_rsrp_avg': '-125'},
                         3: {'ueBeamIndexInitial': '3,0,1,2,4,5', 'ssbeam_bestbeam': '3', 'ssbeam_rsrp_best': '-55',
                             'ssbeam_rsrp_avg': '-120'},
                         4: {'ueBeamIndexInitial': '4,0,1,2,3,5', 'ssbeam_bestbeam': '4', 'ssbeam_rsrp_best': '-60',
                             'ssbeam_rsrp_avg': '-139'},
                         5: {'ueBeamIndexInitial': '5,0,1,2,3,4', 'ssbeam_bestbeam': '5', 'ssbeam_rsrp_best': '-65',
                             'ssbeam_rsrp_avg': '-70'}}
    return beam_control_dict


def create_beam_control_for_beamset_2_dict():
    beam_control_dict = {0: {'ueBeamIndexInitial': '0,1', 'ssbeam_bestbeam': '0', 'ssbeam_rsrp_best': '-44',
                             'ssbeam_rsrp_avg': '-50'},
                         1: {'ueBeamIndexInitial': '1,0', 'ssbeam_bestbeam': '1', 'ssbeam_rsrp_best': '-45',
                             'ssbeam_rsrp_avg': '-120'},
                         2: {'ueBeamIndexInitial': '0,1', 'ssbeam_bestbeam': '0', 'ssbeam_rsrp_best': '-50',
                             'ssbeam_rsrp_avg': '-125'},
                         3: {'ueBeamIndexInitial': '1,0', 'ssbeam_bestbeam': '1', 'ssbeam_rsrp_best': '-55',
                             'ssbeam_rsrp_avg': '-120'},
                         4: {'ueBeamIndexInitial': '0,1', 'ssbeam_bestbeam': '0', 'ssbeam_rsrp_best': '-60',
                             'ssbeam_rsrp_avg': '-139'},
                         5: {'ueBeamIndexInitial': '1,0', 'ssbeam_bestbeam': '1', 'ssbeam_rsrp_best': '-65',
                             'ssbeam_rsrp_avg': '-70'}}
    return beam_control_dict


def get_expected_beams():
    beam_commands = create_beam_control_dict()
    expected_beams = []
    for ue_command in beam_commands.values():
        expected_beams.append(int(ue_command["ssbeam_bestbeam"]))
    return expected_beams


def verify_that_nr_rrc_dmrs_uplinkforpusch_does_not_contain_dmrs_additionalposition(pdml_file, mapping_type,
                                                                                    validate=None):
    """
    Verifies that dmrs additional position is not present in RRC, meaning that pos2 is used

    :param validate: None or True
    :param pdml_file: PDML file converted
    :param mapping_type:   PUSCH or PDSCH Mapping type [ "B" or "A" ]
    """
    xpath = ".//field[@name='f1ap.DUtoCURRCInformation_element']" \
            "//field[@name='nr-rrc.dmrs_UplinkForPUSCH_MappingType{}']" \
            "//field[@name='nr-rrc.dmrs_AdditionalPosition']".format(mapping_type.upper())
    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        XML().element_should_not_exist(source=pdml_file, xpath=xpath)


def verify_dmrs_additional_position_absence(pdml_file, mapping_type):
    """
    Verifies that the dmrs_AdditionalPosition attribute is not present in the RRC message,
    indicating that pos2 is used for DMRS.

    Args:
        pdml_file (str): Path to the PDML file.
        mapping_type (str): PUSCH or PDSCH Mapping type ("B" or "A").

    Returns:
        bool: True if the attribute is not present, False otherwise.
    """

    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()

        xpath = ".//field[@name='f1ap.DUtoCURRCInformation_element']" \
                "//field[@name='nr-rrc.dmrs_UplinkForPUSCH_MappingType{}']" \
                "//field[@name='nr-rrc.dmrs_AdditionalPosition']".format(mapping_type.upper())

        element = root.find(xpath)

        if element is None:
            rbi.log("[ INFO ] dmrs_AdditionalPosition Attribute is not present, indicating pos2 is used",
                    console="Yes")
            return True  # Attribute is not present, indicating pos2 is used
        else:
            print(f"Error: dmrs_AdditionalPosition attribute found at XPath: {xpath}")
            text = "[ INFO ]: %s : dmrs_AdditionalPosition attribute found at XPath: {%s}"
            rbi.log(text % ("verify_dmrs_additional_position_absence", xpath), console="Yes")
            return False

    except FileNotFoundError:
        print(f"Error: PDML file not found: {pdml_file}")
        return False
    except ET.ParseError:
        print(f"Error: Invalid PDML file: {pdml_file}")
        return False


def verify_that_nr_rrc_dmrs_downlinkforpdsch_does_not_contain_dmrs_additionalposition(pdml_file):
    """
    Verifies that dmrs additional position is not present in RRC, meaning that pos2 is used

    :param pdml_file: PDML file converted
    """
    path = ".//field[@name='f1ap.DUtoCURRCInformation_element']" \
           "//field[@name='nr-rrc.spCellConfig']" \
           "//field[@name='nr-rrc.pdsch_Config']" \
           "//field[@name='nr-rrc.dmrs_DownlinkForPDSCH_MappingTypeA']" \
           "//field[@name='nr-rrc.dmrs_AdditionalPosition']"
    XML().element_should_not_exist(source=pdml_file, xpath=path)


def verify_the_value_of_dmrs_additionalposition(pdml_file, mapping_type, value, direction):
    """
    Verifies the value of dmrs additional position in case it's pos0 or pos1

    :param pdml_file: PDML file
    :param mapping_type:  PUSCH or PDSCH Mapping type [ "B" or "A" ]
    :param value: value of the additional dmrs symbol ["0" or "1"]
    :param direction: Physical channel direction ["UplinkForPUSCH" / "DownlinkForPDSCH"]
    """
    xpath = ".//field[@name='f1ap.UEContextSetupResponse_element']" \
            "//field[@name='f1ap.DUtoCURRCInformation_element']//field[@name='nr-rrc.dmrs_{0}_MappingType{1}']//" \
            "field[@name='nr-rrc.dmrs_AdditionalPosition']".format(direction, mapping_type.upper())
    XML().element_attribute_should_be(source=pdml_file, name="show", expected=value, xpath=xpath)


def verify_the_value_of_dmrs_additionalposition_v2(pdml_file, mapping_type, expected_value, direction):
    """
    Verifies the value of the dmrs_AdditionalPosition attribute in a PDML file.

    Args:
        pdml_file (str): Path to the PDML file.
        mapping_type (str): PUSCH or PDSCH Mapping type ("B" or "A").
        expected_value (str): Expected value of the dmrs_AdditionalPosition attribute ("0" or "1").
        direction (str): Physical channel direction ("UplinkForPUSCH" or "DownlinkForPDSCH").

    Returns:
        bool: True if the value matches the expected value, False otherwise.
    """

    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()

        xpath = ".//field[@name='f1ap.UEContextSetupResponse_element']" \
                "//field[@name='f1ap.DUtoCURRCInformation_element']//field[@name='nr-rrc.dmrs_{}_MappingType{}']//" \
                "field[@name='nr-rrc.dmrs_AdditionalPosition']".format(direction, mapping_type.upper())

        element = root.find(xpath)

        if element is not None:
            actual_value = element.get("show")
            return actual_value == expected_value
        else:
            print(f"Error: Element not found at XPath: {xpath}")
            return False

    except FileNotFoundError:
        print(f"Error: PDML file not found: {pdml_file}")
        return False
    except ET.ParseError:
        print(f"Error: Invalid PDML file: {pdml_file}")
        return False


def verify_the_value_of_high_speed_cell_activation_at_l2_ps(pdml_file, value, validate=None):
    """

    :param pdml_file:
    :param value: True or False
    :param validate: None or True
    :return:
    """
    xpath = ".//field[@name='itf_l2_ps_cell_CellSetupReq_t.actHighSpeedCell']"
    xpath_alternative = ".//field[@name='itf_l2_ps_cell_CellSetupReq.actHighSpeedCell']"
    attributes = XML().get_elements(source=pdml_file, xpath=xpath_alternative) if \
        len(XML().get_elements(source=pdml_file, xpath=xpath)) == 0 else \
        XML().get_elements(source=pdml_file, xpath=xpath)
    for attr in attributes:
        if not validate:
            rbi.log("No validation requested... keyword pass!")
        else:
            asserts.assert_equal(attr.get("show"), value, "Values do not match {} != {}".format(attr.get("show"),
                                                                                                value),
                                 values=False)
        text = "[ INFO ] %s(): value = <%s>"
        rbi.log(text % ("verify_the_value_of_high_speed_cell_activation_at_l2_ps", attr.get("show")), console="Yes")


def verify_the_value_of_dmrs_additional_position_in_l2ps(pdml_file, value, channel, validate=None):
    xpath = ".//field[@name='itf_l2_ps_{0}_{1}Config.dmrsAdditionalPosition']".format(channel.lower(), channel)
    attributes = XML().get_elements(source=pdml_file, xpath=xpath)
    for attr in attributes:
        if not validate:
            rbi.log("No validation requested... keyword pass!")
        else:
            asserts.assert_equal(attr.get("show"), value, "Values do not match {} != {}".format(value,
                                                                                                attr.get("show")),
                                 values=False)
        text = "[ INFO ] %s(): value = <%s>"
        rbi.log(text % ("verify_the_value_of_dmrs_additional_position_in_l2ps", attr.get("show")), console="Yes")


def verify_the_value_of_pucch_additional_dmrs(pdml_file):
    xpath = ".//field[@name='f1ap.UEContextSetupResponse_element']" \
            ".//field[@name='nr-rrc.pucch_Config']" \
            ".//field[@name='nr-rrc.format3']" \
            ".//field[@name='nr-rrc.additionalDMRS']"

    XML().element_attribute_should_be(source=pdml_file, xpath=xpath,
                                      expected="additionalDMRS: true (0)", name="showname")


def verify_prach_zeroCorrelationZoneConfig(pdml_file, value=0, validate=None):
    """
    Verifies that the zeroCorrelationZoneConfig attribute is present in the RRC message,

    Args:
        pdml_file (str): Path to the PDML file.

    Returns:
        bool: True if the attribute is present, False otherwise.
    """

    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()
        # xpath = ".//field[@name='nr-rrc.zeroCorrelationZoneConfig']"
        xpath = ".//field[@name='nr-rrc.uplinkConfig_element']" \
                "//field[@name='nr-rrc.zeroCorrelationZoneConfig']"
        elements = root.find(xpath)
        if elements is not None:
            attributes = XML().get_elements(source=pdml_file, xpath=xpath)
            for attr in attributes:
                if not validate:
                    rbi.log("No validation requested... keyword pass!")
                else:
                    text = "Values do not match {} != {}"
                    asserts.assert_equal(attr.get("show"), value, text.format(attr.get("show"), value),
                                         values=False)
                text = "[ INFO ] %s(): value = <%s>"
                rbi.log(text % ("verify_prach_zeroCorrelationZoneConfig", attr.get("show")), console="Yes")
        else:
            print(f"Error: Element not found at XPath: {xpath}")
            text = "[ Error ] %s: Element not found at XPath: {%s}"
            rbi.log(text % ("verify_prach_zeroCorrelationZoneConfig", xpath), console="Yes")
            return False

    except FileNotFoundError:
        print(f"Error: PDML file not found: {pdml_file}")
        return False
    except ET.ParseError:
        print(f"Error: Invalid PDML file: {pdml_file}")
        return False
    return True


def verify_prach_RootSequenceIndex(pdml_file, value=0, validate=None):
    """
    Verifies that the prach_RootSequenceIndex attribute is present in the RRC message,

    Args:
        pdml_file (str): Path to the PDML file.

    Returns:
        bool: True if the attribute is present, False otherwise.
        :param validate:
        :param value:
    """

    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()
        # xpath = ".//field[@name='nr-rrc.prach_RootSequenceIndex']"
        xpath = ".//field[@name='nr-rrc.uplinkConfig_element']" \
                "//field[@name='nr-rrc.prach_RootSequenceIndex']"
        elements = root.find(xpath)
        if elements is not None:
            attributes = XML().get_elements(source=pdml_file, xpath=xpath)
            for attr in attributes:
                if not validate:
                    rbi.log("No validation requested... keyword pass!")
                else:
                    text = "Values do not match {} != {}"
                    asserts.assert_equal(attr.get("show"), value, text.format(attr.get("show"), value),
                                         values=False)
                text = "[ INFO ] %s(): value = <%s>"
                rbi.log(text % ("verify_prach_RootSequenceIndex", attr.get("show")), console="Yes")
        else:
            print(f"Error: Element not found at XPath: {xpath}")
            text = "[ Error ] %s: Element not found at XPath: {%s}"
            rbi.log(text % ("verify_prach_RootSequenceIndex", xpath), console="Yes")
            return False

    except FileNotFoundError:
        print(f"Error: PDML file not found: {pdml_file}")
        return False
    except ET.ParseError:
        print(f"Error: Invalid PDML file: {pdml_file}")
        return False
    return True


def calculate_coreset4_size(bwPrb=52, nbrOfBlankedPRBsLowEdgeDL=0, nbrOfBlankedPRBsHighEdgeDL=0):
    # Perform the calculations as per the Excel formula
    ceiling_value = math.ceil(nbrOfBlankedPRBsLowEdgeDL / 6)
    multiplied_value = ceiling_value * 6
    result = bwPrb - multiplied_value - nbrOfBlankedPRBsHighEdgeDL
    size = math.floor(result / 6) * 6

    return size


def calculate_coreset4_cRbStart(nbrOfBlankedPRBsLowEdgeDL=0):
    # Perform the calculations as per the Excel formula
    ceiling_value = math.ceil(nbrOfBlankedPRBsLowEdgeDL / 6)
    cRbStart = ceiling_value * 6

    return cRbStart


def return_only_rbgsize_pdsch(chBW=273, ConfigType=1):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    return rbgsize


def cal_num_of_pdsch_old(chBW, ConfigType=1, nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0, w_debug=False):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    rat0bitmap_full = rat0bitmap
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsHighEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsHighEdgeDL))
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsLowEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsLowEdgeDL))
    msg = 'cal_num_of_pdsch: rat0bitmap'
    if w_debug:
        datedConsole(getHeaderLine(msg, rat0bitmap_full))
    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        x = 0
        y = 0
        if w_debug:
            datedConsole(getHeaderLine('Instrum1 '+msg, rat0bitmap[-1]))
        res = nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1]
        if w_debug:
            datedConsole(getHeaderLine('Instrum1.1 ' + msg, (res, nbrOfBlankedPRBsHighEdgeDL, rat0bitmap[-1])))
        # if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] <= 0:
        if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] == 0:
            rat0bitmap = rat0bitmap[:-1]
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        elif nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] < 0:
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        else:
            y = math.ceil((nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1])/rbgsize)
            if w_debug:
                datedConsole(getHeaderLine('Instrum3.0 ' + msg, y))
            rat0bitmap = rat0bitmap[:-1-y]
            if w_debug:
                datedConsole(getHeaderLine('Instrum3 ' + msg, rat0bitmap))
        x = math.ceil(nbrOfBlankedPRBsLowEdgeDL/rbgsize)
        rat0bitmap = rat0bitmap[x:]
        if rat0bitmap[-1] == rbgsize:
            usablepdsch = len(rat0bitmap) * rbgsize
        else:
            usablepdsch = len(rat0bitmap[:-1]) * rbgsize + rat0bitmap[-1]
    else:
        usablepdsch = chBW
    msg = '=====> Full rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap_full))
    msg = '=====> Full NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap_full)))
    msg = '=====> Usable rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap))
    msg = '=====> Usable NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap)))
    msg = '=====> Usable PRB PDSCH'
    datedConsole(getHeaderLine(msg, usablepdsch))
    return chBW, rat0bitmap_full, usablepdsch, rat0bitmap


def cal_num_of_pdsch_v1_OK(chBW, ConfigType=1, nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0,
                           w_debug=False):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    rat0bitmap_full = rat0bitmap
    rat0bitmap_full_init = rat0bitmap_full
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsHighEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsHighEdgeDL))
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsLowEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsLowEdgeDL))
    msg = 'cal_num_of_pdsch: rat0bitmap'
    if w_debug:
        datedConsole(getHeaderLine(msg, rat0bitmap_full))
    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        x = 0
        y = 0
        if w_debug:
            msg = 'cal_num_of_pdsch: rat0bitmap lst rbg'
            datedConsole(getHeaderLine('Instrum1 '+msg, rat0bitmap[-1]))
        if nbrOfBlankedPRBsLowEdgeDL > 0:
            res = nbrOfBlankedPRBsLowEdgeDL - rat0bitmap[-1]
            if w_debug:
                msg = 'cal_num_of_pdsch: (prb res, nbrOfBlankedPRBsLowEdgeDL, lst rbg)'
                datedConsole(getHeaderLine('Instrum1.1 ' + msg, (res, nbrOfBlankedPRBsLowEdgeDL, rat0bitmap[-1])))
            # if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] <= 0:
            if nbrOfBlankedPRBsLowEdgeDL - rat0bitmap[-1] == 0:
                rat0bitmap = rat0bitmap[:-1]
                if w_debug:
                    msg = 'cal_num_of_pdsch: rat0bitmap'
                    datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
            elif nbrOfBlankedPRBsLowEdgeDL - rat0bitmap[-1] < 0:
                rat0bitmap = rat0bitmap[:-1]
                if w_debug:
                    datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
            else:
                y = math.ceil((nbrOfBlankedPRBsLowEdgeDL - rat0bitmap[-1])/rbgsize)
                if w_debug:
                    datedConsole(getHeaderLine('Instrum3.0 ' + msg, y))
                rat0bitmap = rat0bitmap[:-1-y]
                if w_debug:
                    datedConsole(getHeaderLine('Instrum3 ' + msg, rat0bitmap))
        x = math.ceil(nbrOfBlankedPRBsHighEdgeDL/rbgsize)
        rat0bitmap = rat0bitmap[x:]
        if rat0bitmap[-1] == rbgsize:
            usablepdsch = len(rat0bitmap) * rbgsize
        else:
            usablepdsch = len(rat0bitmap[:-1]) * rbgsize + rat0bitmap[-1]
    else:
        usablepdsch = chBW
    msg = '=====> Full rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap_full))
    msg = '=====> Full NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap_full)))
    fullpdsch = len(rat0bitmap_full_init[:-1]) * rbgsize + rat0bitmap_full_init[-1]
    msg = '=====> Full PRB PDSCH'
    datedConsole(getHeaderLine(msg, fullpdsch))
    msg = '=====> Usable rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap))
    msg = '=====> Usable NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap)))
    msg = '=====> Usable PRB PDSCH'
    datedConsole(getHeaderLine(msg, usablepdsch))
    return chBW, rat0bitmap_full, usablepdsch, rat0bitmap


def get_rbg_size(chBW, config):
    return next((key for key in config if config[key][0] <= chBW <= config[key][1]), 0)


def calculate_rat0bitmap(chBW, rbgsize):
    rat0bitmap = [rbgsize for _ in range(chBW // rbgsize)]
    remainder = chBW % rbgsize
    if remainder != 0:
        rat0bitmap.append(remainder)
    return rat0bitmap


def debug_message(w_debug, msg, data):
    if w_debug:
        datedConsole(getHeaderLine(msg, data))


def cal_num_of_pdsch(chBW, ConfigType=1, nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0, w_debug=False):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}

    config = config_1 if ConfigType == 1 else config_2
    rbgsize = get_rbg_size(chBW, config)
    rat0bitmap = calculate_rat0bitmap(chBW, rbgsize)
    rat0bitmap_full = rat0bitmap.copy()

    debug_message(True, 'cal_num_of_pdsch: nbrOfBlankedPRBsLowEdgeDL', nbrOfBlankedPRBsLowEdgeDL)
    debug_message(True, 'cal_num_of_pdsch: nbrOfBlankedPRBsHighEdgeDL', nbrOfBlankedPRBsHighEdgeDL)
    debug_message(w_debug, 'cal_num_of_pdsch: full rat0bitmap', rat0bitmap_full)

    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        if nbrOfBlankedPRBsHighEdgeDL > 0:
            res = nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1]
            debug_message(w_debug, 'cal_num_of_pdsch: (prb res, nbrOfBlankedPRBsHighEdgeDL, lst rbg)',
                          (res, nbrOfBlankedPRBsHighEdgeDL, rat0bitmap[-1]))
            if res <= 0:
                rat0bitmap.pop()
            else:
                y = math.ceil(res / rbgsize)
                rat0bitmap = rat0bitmap[:-1 - y]

        x = math.ceil(nbrOfBlankedPRBsLowEdgeDL / rbgsize)
        rat0bitmap = rat0bitmap[x:]

    usablepdsch = len(rat0bitmap[:-1]) * rbgsize + rat0bitmap[-1] if rat0bitmap[-1] != rbgsize else len(
        rat0bitmap) * rbgsize

    debug_message(True, '=====> Full rat0bitmap', rat0bitmap_full)
    debug_message(True, '=====> Full NbrRBG', len(rat0bitmap_full))
    fullpdsch = len(rat0bitmap_full[:-1]) * rbgsize + rat0bitmap_full[-1]
    debug_message(True, '=====> Full PRB PDSCH', fullpdsch)
    debug_message(True, '=====> Usable rat0bitmap', rat0bitmap)
    debug_message(True, '=====> Usable NbrRBG', len(rat0bitmap))
    debug_message(True, '=====> Usable PRB PDSCH', usablepdsch)

    return chBW, rat0bitmap_full, usablepdsch, rat0bitmap


def return_only_rbgsize_pdsch_FDD(chBW=52, ConfigType='FR1'):
    FR1 = {2: [25, 52], 4: [79, 106], 8: [133, 216], 16: [217, 270]}
    FR2 = {4: [24, 50], 8: [51, 65], 16: [79, 133]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 'FR1':
        for key in FR1:
            if FR1[key][0] <= chBW <= FR1[key][1]:
                rbgsize = key
    elif ConfigType == 'FR2':
        for key in FR2:
            if FR2[key][0] <= chBW <= FR2[key][1]:
                rbgsize = key
    return rbgsize


def cal_num_of_pdsch_FDD(chBW, ConfigType='FR1', nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0,
                         w_debug=False):
    """
    Bandwidth (MHz)	  Subcarrier Spacing (kHz)  	PRBs	RBG Size (PRBs)
        5	              15	                    25      	2
        10	              15                       	52        	2
        15	              15                      	79          4
        20	              15	                    106         4
        25	              15                      	133     	8
        30	              15                    	160     	8
        40	              15                       	216     	8
        50	              15                    	270	        16
        10	              30                    	24         	4
        20	              30                    	51	        8
        25            	  30                    	65	        8
        30	              30                    	79         	16
        40	              30                    	106     	16
        50	              30                    	133     	16
    :param chBW:
    :param ConfigType:
    :param nbrOfBlankedPRBsHighEdgeDL:
    :param nbrOfBlankedPRBsLowEdgeDL:
    :param w_debug:
    :return:
    """
    FR1 = {2: [25, 52], 4: [79, 106], 8: [133, 216], 16: [217, 270]}
    FR2 = {4: [24, 50], 8: [51, 65], 16: [79, 133]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 'FR1':
        for key in FR1:
            if FR1[key][0] <= chBW <= FR1[key][1]:
                rbgsize = key
    elif ConfigType == 'FR2':
        for key in FR2:
            if FR2[key][0] <= chBW <= FR2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    rat0bitmap_full = rat0bitmap
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsHighEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsHighEdgeDL))
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsLowEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsLowEdgeDL))
    msg = 'cal_num_of_pdsch: rat0bitmap'
    if w_debug:
        datedConsole(getHeaderLine(msg, rat0bitmap_full))
    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        x = 0
        y = 0
        if w_debug:
            datedConsole(getHeaderLine('Instrum1 '+msg, rat0bitmap[-1]))
        res = nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1]
        if w_debug:
            datedConsole(getHeaderLine('Instrum1.1 ' + msg, (res, nbrOfBlankedPRBsHighEdgeDL, rat0bitmap[-1])))
        # if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] <= 0:
        if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] == 0:
            rat0bitmap = rat0bitmap[:-1]
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        elif nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] < 0:
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        else:
            y = math.ceil((nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1])/rbgsize)
            if w_debug:
                datedConsole(getHeaderLine('Instrum3.0 ' + msg, y))
            rat0bitmap = rat0bitmap[:-1-y]
            if w_debug:
                datedConsole(getHeaderLine('Instrum3 ' + msg, rat0bitmap))
        x = math.ceil(nbrOfBlankedPRBsLowEdgeDL/rbgsize)
        rat0bitmap = rat0bitmap[x:]
        if rat0bitmap[-1] == rbgsize:
            usablepdsch = len(rat0bitmap) * rbgsize
        else:
            usablepdsch = len(rat0bitmap[:-1]) * rbgsize + rat0bitmap[-1]
    else:
        usablepdsch = chBW
    msg = '=====> Full rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap_full))
    msg = '=====> Full NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap_full)))
    msg = '=====> Usable rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap))
    msg = '=====> Usable NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap)))
    msg = '=====> Usable PRB PDSCH'
    datedConsole(getHeaderLine(msg, usablepdsch))
    return chBW, rat0bitmap_full, usablepdsch, rat0bitmap


def get_specified_column_from_csv_file_for_rnti(filename, linename, pattern='rnti'):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        row_dict = dict()
        for row in reader:
            if row[pattern] != '0' and row[pattern] != '65535' and row[linename] != '':
                row_dict.setdefault(row[pattern], []).append(row[linename])
        print(row_dict)
    return row_dict


def get_specified_column_from_csv_file(filename, linename):
    """This creates a keyword named "Read a column from CSV File"

    This keyword takes 2 arguments, which are a path to a .csv file and list name. It
    returns a list of column and remove empty string.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile, delimiter=';')
        row_dict = dict()
        for row in reader:
            if row[linename] != '':
                row_dict.setdefault(linename, []).append(row[linename])
        print(row_dict)
    return row_dict


def get_cell_from_csv_file(filename, pattern='cell'):
    """This creates a keyword named "get_cell_from_csv_file"

    This keyword takes 1 argument, which are a path to a .csv file. It
    returns a list of rnti.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile,  delimiter=';')
        # logging.info("get_cell_from_csv_file: reader = %s" % (reader))
        # for row in reader:
        #     logging.info("get_cell_from_csv_file: row = %s" % row)
        column = [row[pattern] for row in reader]
        column_rnti = set(column)
        # logging.info("get_cell_from_csv_file: column_rnti = %s" % column_rnti)
    return list(column_rnti)


def get_rnti_from_csv_file(filename, pattern='rnti', exclude_first_samples=True):
    """This creates a keyword named "get_rnti_from_csv_file"

    This keyword takes 1 argument, which are a path to a .csv file. It
    returns a list of rnti.
    """
    with io.open(filename, 'rt', encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile,  delimiter=';')
        # logging.info("get_rnti_from_csv_file: reader = %s" % (reader))
        # for row in reader:
        #     logging.info("get_rnti_from_csv_file: row = %s" % row)
        column = [row[pattern] for row in reader]
        column_rnti = set(column)
        if '0' in column_rnti:
            column_rnti.remove('0')
        if '65535' in column_rnti:
            column_rnti.remove('65535')
    for i in column_rnti.copy():
        count_result = column.count(i)
        if count_result < 20 and exclude_first_samples:
            column_rnti.remove(i)
    return list(column_rnti)


def get_feature_parameters_from_scf(scf_path, feature_params, distname, listname=None, index=0):
    feature_params_dict = {}
    scfObj = scf()
    scfObj.load_scf(file_path=scf_path)
    for param in feature_params:
        if listname:
            param_value = scfObj.get_value_from_scf(dist_name=distname, list_name=listname, index=index, p_name=param)
        else:
            param_value = scfObj.get_value_from_scf(dist_name=distname, p_name=param)
        param_value = param_value if param_value not in ['True', 'False'] else param_value.lower()
        param_value = 'infinity' if param_value == 'inf' else param_value
        feature_params_dict[param] = param_value
    return feature_params_dict


def writeConfiguration(file, config):
    input_file_fd = open(file, 'a')
    input_file_fd.write("\n\t**************************\n\tScf values for Validation\n\t**************************\n")
    for data in config:
        input_file_fd.write("\t " + str(data['field']) + "=\t" + str(data['content']) + "\n")
    input_file_fd.close()


def test_calculate_cRbStart():
    # Example values for nbrOfBlankedPRBsLowEdgeUL and nbrOfBlankedPRBsHighEdgeUL
    nbrOfBlankedPRBsLowEdgeUL = 10  # NbrBL UL BLE
    nbrOfBlankedPRBsHighEdgeUL = 5  # NbrBL UL BHE

    # Calculate the size using the provided values
    size = calculate_coreset4_size(nbrOfBlankedPRBsLowEdgeUL, nbrOfBlankedPRBsHighEdgeUL)
    print(f"The calculated size is: {size}")

    # Example value for nbrOfBlankedPRBsLowEdgeUL
    nbrOfBlankedPRBsLowEdgeUL = 10  # NbrBL UL BLE

    # Calculate the cRbStart using the provided value
    cRbStart = calculate_coreset4_cRbStart(nbrOfBlankedPRBsLowEdgeUL)
    print(f"The calculated cRbStart is: {cRbStart}")


def test_prach():
    file_pdml = '/home/ute/csamson/TRACES/l2_l3_syscom_tcpdump.pdml'
    verify_prach_RootSequenceIndex(file_pdml)
    verify_prach_zeroCorrelationZoneConfig(file_pdml)


def test_calc_num_pdsch():
    # Example values for nbrOfBlankedPRBsLowEdgeDL and nbrOfBlankedPRBsHighEdgeDL
    nbrOfBlankedPRBsLowEdgeDL = 13  # NbrBL DL BLE
    nbrOfBlankedPRBsHighEdgeDL = 7  # NbrBL DL BHE

    chBW, rat0bitmap_full, usablepdsch, rat0bitmap = \
        cal_num_of_pdsch(chBW=52,
                         ConfigType=1,
                         nbrOfBlankedPRBsHighEdgeDL=nbrOfBlankedPRBsHighEdgeDL,
                         nbrOfBlankedPRBsLowEdgeDL=nbrOfBlankedPRBsLowEdgeDL,
                         w_debug=True)
    print(f"The chBW is: {chBW}")
    print(f"The rat0bitmap_full is: {rat0bitmap_full}")
    print(f"The calculated usablepdsch is: {usablepdsch}")
    print(f"The rat0bitmap is: {rat0bitmap}")


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    test_calc_num_pdsch()
