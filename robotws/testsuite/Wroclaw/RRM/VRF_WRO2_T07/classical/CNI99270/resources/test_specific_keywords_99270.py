from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.checkpoints import verify_on_air
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as Sm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name, get_bts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import \
    load_scf, wait_for_online_state, _validate_path
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.test.test_file_helper import os
from socket import gethostname
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
import time


@logged_keyword
def check_2CC_03(btslog_dir):
    regular_expression_for_2cc = r'^[\s\S]*\[PCellId: 902758401][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells: ' \
                                 r'\[(902758403)' \
                                 r'\][\s\S]*$'
    regex_pcell_1 = r'^[\s\S]*902758401[\s\S]*INITIALACCESS[\s\S]*$'
    regex_scell_2 = r'^[\s\S]*902758403[\s\S]*SCELLADDITION[\s\S]*$'

    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))

        blog('checking regular_expression: ' + str(regular_expression_for_2cc))
        msg_1 = syslog.find_next(Sm(regular_expression_for_2cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 2CC in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_pcell_1))
        msg_2 = syslog.find_next_anew(Sm(regex_pcell_1, regex_engine='re'))
        assert msg_2 is not None, 'No sign of Pcell 902758401 INITIALACCESS in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_2))
        blog('Syslog from {} analysed successfully (Pcell 902758401 INITIALACCESS).'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_scell_2))
        msg_3 = syslog.find_next_anew(Sm(regex_scell_2, regex_engine='re'))
        assert msg_3 is not None, 'No sign of Scell 902758403 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_3))
        blog('Syslog from {} analysed successfully (Scell 902758403 SCELLADDITION).'.format(str(btslog_dir)))


@logged_keyword
def check_2CC_05(btslog_dir):
    regular_expression_for_2cc = r'^[\s\S]*\[PCell 902758401][\s\S]*' \
                                 r'Finished with status Status:ok and selected SCells ' \
                                 r'\[(902758402)' \
                                 r'\][\s\S]*$'
    regex_pcell_1 = r'^[\s\S]*UserSetup[\s\S]*902758401[\s\S]*INITIALACCESSSGNBADDITION[\s\S]*$'
    regex_scell_2 = r'^[\s\S]*UE setup[\s\S]*902758402[\s\S]*SCELLADDITION[\s\S]*$'

    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))

        blog('checking regular_expression: ' + str(regular_expression_for_2cc))
        msg_1 = syslog.find_next(Sm(regular_expression_for_2cc, regex_engine='re'))
        assert msg_1 is not None, 'No sign of 2CC in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_pcell_1))
        msg_2 = syslog.find_next_anew(Sm(regex_pcell_1, regex_engine='re'))
        assert msg_2 is not None, 'No sign of Pcell 902758401 INITIALACCESS in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_2))
        blog('Syslog from {} analysed successfully (Pcell 902758401 INITIALACCESS).'.format(str(btslog_dir)))

        blog('checking regular_expression: ' + str(regex_scell_2))
        msg_3 = syslog.find_next_anew(Sm(regex_scell_2, regex_engine='re'))
        assert msg_3 is not None, 'No sign of Scell 902758402 SCELLADDITION in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_3))
        blog('Syslog from {} analysed successfully (Scell 902758402 SCELLADDITION).'.format(str(btslog_dir)))


@logged_keyword
def check_actSuperCell_for_1_st_supercell():
    with ScfManager() as Scf:
        feature_act_value_1 = Scf.get_all_values_from_scf(dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.
                                                          format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
                                                          p_name='actSuperCell')
        return str(feature_act_value_1[0])


@logged_keyword
def check_actSuperCell_for_2_nd_supercell():
    with ScfManager() as Scf:
        feature_act_value_2 = Scf.get_all_values_from_scf(dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-2'.
                                                          format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
                                                          p_name='actSuperCell')
        return str(feature_act_value_1[0])


@logged_keyword
def upload_scf(testcase, config_dir=None, skip_relation_errors=False):
    if config_dir is None:
        config_dir = _validate_path("{}/testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CNI99270/custom_config".
                                    format(robot_globals.execdir()))
    load_scf(scf_path=resolve_custom_scf_path(testcase, config_dir), skip_relation_errors=skip_relation_errors)
    wait_for_online_state()


@logged_keyword
def resolve_custom_scf_path(testcase, config_dir):
    branch = get_sw_release_name()
    rat = ''
    try:
        rat = str(get_bts_id())[0]
    except Exception as e:
        blog("Error {} occured during getting bts id".format(e), level='ERROR')
        pass
    rat = rat if rat in ['4', '5'] else '5'
    file_name = '{}_{}_{}G_{}.xml'.format(gethostname().replace('-', '_'), branch, rat, testcase)
    filepath = "{config}/{branch}/{file}".format(config=config_dir, branch=branch, file=file_name)
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    blog(filepath)
    return filepath
