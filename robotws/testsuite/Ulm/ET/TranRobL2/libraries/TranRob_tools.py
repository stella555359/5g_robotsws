# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB007449 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


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


def align_scf_for_CB007449_feature(inScfFilePath):
    rbi.log("============================== Begin align_scf_for_CB007449_feature()", logLevel)
    rbi.log("align_scf_for_CB007449_feature: inScfFilePath = %s" % inScfFilePath, logLevel)
    try:
        if os.path.isfile(inScfFilePath):
            with open(inScfFilePath, "r") as inScfFile:
                data = inScfFile.read()
                data = data.replace("/BWP_PROFILE-0/", "/BWP_PROFILE-4/")
                data = data.replace("/BWP_PROFILE-0<", "/BWP_PROFILE-4<")
                data = data.replace("/BWP_PROFILE-0\"", "/BWP_PROFILE-4\"")
                data = data.replace("/BWP_PROFILE-1/", "/BWP_PROFILE-4/")
                data = data.replace("/BWP_PROFILE-1<", "/BWP_PROFILE-4<")
                data = data.replace("/BWP_PROFILE-1\"", "/BWP_PROFILE-4\"")
                data = data.replace("/BWP_PROFILE-20/", "/BWP_PROFILE-44/")
                data = data.replace("/BWP_PROFILE-20<", "/BWP_PROFILE-44<")
                data = data.replace("/BWP_PROFILE-20\"", "/BWP_PROFILE-44\"")
                data = data.replace("/BWP_PROFILE-8/", "/BWP_PROFILE-4/")
                data = data.replace("/BWP_PROFILE-8<", "/BWP_PROFILE-4<")
                data = data.replace("/BWP_PROFILE-8\"", "/BWP_PROFILE-4\"")
                data = data.replace("/BWP_PROFILE-82/", "/BWP_PROFILE-44/")
                data = data.replace("/BWP_PROFILE-82<", "/BWP_PROFILE-44<")
                data = data.replace("/BWP_PROFILE-82\"", "/BWP_PROFILE-44\"")
            outScfFilePath = inScfFilePath + ".aligned.xml"
            with open(outScfFilePath, "w") as outScfFile:
                outScfFile.write(data)
    except Exception as e:
        logException("align_scf_for_CB007449_feature", e, silent=True)
    rbi.log("============================== End align_scf_for_CB007449_feature()", logLevel)
    return outScfFilePath


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


def get_expected_beams():
    beam_commands = create_beam_control_dict()
    expected_beams = []
    for ue_command in beam_commands.values():
        expected_beams.append(int(ue_command["ssbeam_bestbeam"]))
    return expected_beams


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), logLevel)
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")
