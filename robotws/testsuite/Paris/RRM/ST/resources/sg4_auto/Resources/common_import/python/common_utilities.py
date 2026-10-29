# =====================================================================================================================
# This is a Python File, which helps to get common keywords
# ---------------------------------------------------------------------------------------------------------------------
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
import datetime
import os


def get_log_path():
    log_path = BuiltIn().get_variable_value('${LOG_PATH}', None)
    if log_path is None:
        log_path = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR}'),
                                'Logs/{}'.format(datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")))
        BuiltIn().set_suite_variable('${LOG_PATH}', log_path)
    if not os.path.exists(log_path):
        os.makedirs(log_path)
    return log_path


def Reverse(str):
    stringlength = len(str)
    slicedString = str[stringlength::-1]
    return (slicedString)


def DecodePLMN(plmn):
    plmn = plmn.replace(':', '')
    print("Decoded PLMN: " + str(plmn))
    mcc = int(Reverse(plmn[0:2]) + Reverse(plmn[2:4]).replace('f', ''))
    print("Decoded MCC: " + str(mcc))
    mnc = int(Reverse(plmn[4:6]))
    print("Decoded MNC: " + str(mnc))
    return mcc, mnc


def EncodePLMN(mcc, mnc):
    plmn = list('XXXXXX')
    plmn[0] = Reverse(mcc)[1]
    plmn[1] = Reverse(mcc)[2]
    plmn[2] = "f"
    plmn[3] = Reverse(mcc)[0]
    plmn[4] = Reverse(mnc)[0]
    plmn[5] = Reverse(mnc)[1]
    plmn_list = plmn
    plmn = ''
    for bits in plmn_list:
        plmn = plmn + bits
    print("Encoded PLMN: " + str(plmn))
    return plmn
