import re
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from taf.rfrl.utilities.test_config import get_repository_path
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.ul.sc.perf.messenger.messenger import Messenger, Message
from common_variables import TLs_data, ADDITIONAL_ALARMS_FOR_TESTS


def compare_sw_version(active_sw_version, planned_sw_version):
    asw = SbtsSwVersion(active_sw_version)
    psw = SbtsSwVersion(planned_sw_version)
    if asw >= psw:
        return True
    return False


def find_nested_key(data, target_key):
    if isinstance(data, dict):
        for key, value in data.items():
            if key == target_key:
                return value
            elif isinstance(value, (dict, list)):
                result = find_nested_key(value, target_key)
                if result is not None:
                    return result

    elif isinstance(data, list):
        for item in data:
            if isinstance(item, (dict, list)):
                result = find_nested_key(item, target_key)
                if result is not None:
                    return result

    return None


def prepare_additional_alarms_for_test(test_type):
    tl_name = BuiltIn().get_variable_value('${tl.tl_cloud_topology}')
    return ADDITIONAL_ALARMS_FOR_TESTS[test_type] + get_specific_alarms_for_test(tl_name, test_type)


def get_specific_alarms_for_test(tl_name, test_type):
    try:
        return TLs_data[tl_name]['Alarms'][test_type]
    except KeyError:
        return []


def upload_swconfig_to_bts():
    sw_config_path = get_repository_path() + 'testsuite/QT/ASIR/resources/default_swconfig.txt'
    print(sw_config_path)
    gnb_du = GnbDuOperations()
    gnb_du.upload_swconfig(sw_config_path=sw_config_path)


def send_mail(test_case=None):
    if not test_case:
        test_case = get_builtin_value(param_name="TEST NAME")
    tl_name = get_builtin_value(param_name="TL_Name")
    sw_version = get_builtin_value(param_name="build")
    subject = "[ASIR QT] Problem with {} on build {}".format(tl_name, sw_version)
    msg_content = r"""
        <html>
        <body>
        <p>Hi,</p>
        <p>Check below test execution in jenkins:</p>
        <ul>
          <li>SOFTWARE VERSION: {}</li>
          <li>TEST LINE: {}</li>
          <li>TEST NAME: {}</li>""".format(sw_version, tl_name, test_case)
    message = Message(
        From='qt-jenkins@nokia.com',
        To='i_mn_ran_pz_krk_asir_qt@internal.nsn.com',
        CC=None,
        Subject=subject,
        Html=msg_content,
        Body=None,
        attachments=None,
        charset="utf-8")
    Messenger.send_message(message)


def get_branch_name():
    bts_operations = GnbDuOperations()
    build = bts_operations.get_bts_sw_version()
    return SbtsSwVersion(build).release


def adjust_qrxlevmin_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    dist_name = bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)
    if 'LNCEL' in dist_name:
        dist_name = '{}/SIB-0'.format(dist_name)
    return dist_name


def change_qrxlevmin_parameter(cell, value='max'):
    gnbscf = GnbCommissioning()
    cell_id = re.search("\\w+-(\\d+)", cell).group(1)
    if 'LNCEL' in cell:
        bts_patterns = EnbDistNamePatterns
        param_name = 'qrxlevmin'
        qrxlevmin_value = '-130' if value == 'max' else '-44'
    else:
        bts_patterns = GnbDistNamePatterns
        param_name = 'qRxLevMin'
        qrxlevmin_value = '-70' if value == 'max' else '-22'
    dist_name = adjust_qrxlevmin_dist_name(bts_patterns.cell_dist_name.format({}, {}, cell_id))
    gnbscf.perform_configuration_parameter_recommissioning(dist_name=dist_name, parameter=param_name,
                                                           operation='update', value=qrxlevmin_value)
