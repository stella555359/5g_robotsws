import os
from datetime import datetime
from time import sleep

from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.lmp_logger import LmpLogger
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog \
    import start_btslog_on_local_machine, stop_and_collect_btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher as Sm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
from taf.sw.reporting_portal import reporting_portal
from taf.ul.alarms_watchdog import alarms_watchdog
import socket
import re

ssh_host = tl.gnbs[0].cu.oam_http_connection_details.addr

syslog_error_prints = '||'.join(
    ['*FATAL DSPHWAPI ERROR*', '*Invalid memory reference*', '*Please contact the owner*',
     '*fatality*', '*Abort signal received*', '*Bus error*'
     ])

ALLOWED_FAULT_ID = [61649, 61652, 61524, 61510, 4459, 6455, 4657, 4655, 4654, 4592, 4681]
"""Allowed Fault IDs Definition
    "61649" - LMP access via port xx
    "61652" - R&D Service Port enabled
    "61524" - SSH enabled
    "61510" - Automatic BTS Operator Certificate retrieval unsuccessful    /ipsec
    "4459"  - User Account has Default Password
    "6455"  - Service account root access is enabled
    "4657"  - unsupported SFP
    "4655"  - Service account root access is enabled (from 21B)
    "4654"  - Ethernet port security is disabled (from 21B)
    "4389"  - OTDOA PRS transmission disabled
    "4592"  - BTS Reset Cause
    "4681"  - Sanity Check Error
"""

EXPECTED_RATE = 0.9
PASSED_STATUS = 'PASSED'
FAILED_STATUS = 'FAILED'

au = AdminUtils(ssh_host)
_alarms_watchdog = alarms_watchdog()

lmp_logger_verify_loop = LmpLogger()

SYSLOG_FILE_PATTERN = r'SYSLOG_[0-9]*\.LOG|syslog_[0-9]*\.log'


@logged_keyword
def verify_in_loop(num_of_retests, test_func, btslog_logger='btslog'):
    results = []
    run_status = []

    blog('Start test in loop...')
    _alarms_watchdog.watch_alarms(allowed_alarms=ALLOWED_FAULT_ID)
    lmp_logger_verify_loop.initialise_lmp_logger()

    for idx in range(1, num_of_retests + 1):
        current_result = True
        blog('********************** TEST LOOP START **********************')
        blog('RUN {idx} of "{test}" has started. timestamp: {time}'.format(idx=idx, test=test_func,
                                                                           time=get_current_timestamp()))
        start_logging(btslog_logger=btslog_logger)
        sleep(2)
        try:
            tmp_results = BuiltIn().run_keyword(test_func)
            blog('Results up to this point: {tmp_results}'.format(tmp_results=tmp_results))
            run_status.append(tmp_results)
            blog('RUN {idx} of "{test}" - PASSED. timestamp: {time}'.format(
                idx=idx,
                test=test_func,
                time=get_current_timestamp()))
        except Exception:
            current_result = False
            blog('RUN {idx} of "{test}" - FAILED. timestamp: {time}'.format(
                idx=idx,
                test=test_func,
                time=get_current_timestamp()))

        btslog_dirs = stop_logging(btslog_logger=btslog_logger, idx=idx)
        hw_check_status, syslog_check_status = BuiltIn().run_keyword(after_iteration_check.__name__, btslog_dirs, idx)
        blog('hw_check_status: {}'.format(hw_check_status))
        blog('syslog_check_status: {}'.format(syslog_check_status))

        if not syslog_check_status or not hw_check_status:
            current_result = False
        report_to_reporting_portal(test_run=test_func + '_RUN_{}'.format(idx),
                                   result=PASSED_STATUS if current_result else FAILED_STATUS,
                                   build=get_sw_version())
        blog('********************** TEST LOOP END **********************')
        if not hw_check_status:
            blog('********************** TESTLINE RECOVERY START **********************')
            recovery_result = recover_site()
            detected_alarm = _alarms_watchdog.has_detected_alarms()
            blog('recovery_result: {}'.format(recovery_result))
            blog('detected_alarm: {}'.format(detected_alarm))

            if detected_alarm or not recovery_result:
                blog('Site could not be recovered. Verify test in loop shall stop!')
                au.collect_snapshot(
                    os.path.join(robot_globals.outputdir(), 'snapshot_after_test_RUN_{}.tar.gz'.format(idx)),
                    timeout=1800)
                teardown_verify_test_in_loop()
                blog('********************** TESTLINE RECOVERY END **********************')

                return report_to_reporting_portal(test_run=test_func + '_FINAL_RUN',
                                                  result=FAILED_STATUS,
                                                  build=get_sw_version())
        results.append(current_result)

    teardown_verify_test_in_loop()
    report_to_reporting_portal(test_run=test_func + '_FINAL_RUN',
                               result=evaluate_result(results),
                               build=get_sw_version())
    assert evaluate_result(results) == PASSED_STATUS
    return run_status


@logged_keyword
def start_logging(btslog_logger):
    start_logger_func = {'lmp_logger': lmp_logger_verify_loop.start_lmp_logger,
                         'btslog': start_btslog_on_local_machine}
    return start_logger_func[btslog_logger]()


@logged_keyword
def stop_logging(btslog_logger, idx):
    if btslog_logger == 'lmp_logger':
        return lmp_logger_verify_loop.stop_lmp_logger()
    elif btslog_logger == 'btslog':
        return stop_and_collect_btslog(
            target_dir=os.path.join(robot_globals.outputdir(), robot_globals.testname()) + '_RUN_{}'.format(idx))


@logged_keyword
def after_iteration_check(btslog_dirs, idx):
    syslog_check_status = verify_syslog(btslog_dirs, idx)
    hw_check_status = verify_all_hw_types()
    return hw_check_status, syslog_check_status


@logged_keyword
def teardown_verify_test_in_loop():
    _alarms_watchdog.stop_watching_alarms()


@logged_keyword
def recover_site():
    try:
        au.trigger_site_reset_and_wait_for_onair()
        return True
    except Exception:
        return False


@logged_keyword
def get_syslog_filepaths(btslog_dirs):
    return get_filepaths(
        btslog_dirs,
        pattern=SYSLOG_FILE_PATTERN,  # matches SYSLOG_idx.LOG or syslog_idx.log
        regex_engine='re',
    )


@logged_keyword
def verify_syslog(btslog_dirs, iteration):
    blog('Verifying syslog...')
    with LogHelper() as lh:
        btslog_filepaths = get_syslog_filepaths(btslog_dirs)
        syslog = lh.add_syslog(btslog_filepaths)
        msg = syslog.find_next(Sm(syslog_error_prints))
        if msg:
            blog('An error has been found in syslog.')
            au.collect_snapshot(
                filename=os.path.join(robot_globals.outputdir(), 'snapshot_{}.tar.gz'.format(iteration)))
            return False
        else:
            blog('Syslog has been verified successfully without any errors!')
            return True


@logged_keyword
def verify_all_hw_types():
    hw_types = ['SMOD', 'BBMOD', 'RMOD', 'NRCEL', 'ALD']
    hw_check_results = []
    with AdminApi(bts_host=ssh_host) as web_api:
        for hw_type in hw_types:
            blog('Start checking {}...'.format(hw_type))
            hw_check_results.append(verify_hw_type(hw_type, web_api))
            blog('Finished checking {}.'.format(hw_type))
    blog("Verified Hardware: ", all(res for res in hw_check_results))
    return all(res for res in hw_check_results)


@logged_keyword
def verify_hw_type(hw_type, web_api):
    expected_statuses = {'operationalState': ['Enabled', 'enabled'],
                         'availabilityStatus': ['Online', None, 'Degraded'],
                         'administrativeState': ['Unlocked', 'unlocked']}
    results = []

    hw_list = web_api.get_ids_for_all(class_name=hw_type)

    for hw in hw_list:
        blog('HW object: ' + str(hw))
        hw_name = re.findall(r'{}.*'.format(hw_type), hw)[0]
        try:
            hw_status = web_api.get_parameters(dist_name=hw)['stateInfo']
        except KeyError:
            hw_status = web_api.get_parameters(dist_name=hw)
        for status in expected_statuses:
            if hw_status[status] not in expected_statuses[status]:
                results.append(
                    (
                        '{0} {1} should be {2}. Current object ({1}) is {3}'.format(
                            hw_name,
                            status,
                            expected_statuses[status],
                            hw_status[status],
                        )
                    )
                )
    if results:
        blog('HW state verification returned errors.')
        blog('\n'.join(results))
        return False
    else:
        blog('HW state verification finished successfully without errors!')
        return True


@logged_keyword
def report_to_reporting_portal(test_run, result, build):
    ca = get_competence_area()
    testline_name = socket.gethostname().replace('-', '_')

    reporting_utils = reporting_portal()
    return reporting_utils.report_to_rp(name=test_run, result=result, ca=ca, testline=testline_name, build=build,
                                        qc_domain=None, qc_project=None, qc_id=None, uuf_test=True,
                                        label=tl.tl_cloud_topology, parameter_1=build)


@logged_keyword
def get_current_timestamp():
    now = datetime.now()
    return now.strftime('%Y-%m-%d, %H:%M:%S')


@logged_keyword
def get_competence_area():
    try:
        force_tags = BuiltIn().get_variable_value('${TEST_TAGS}')
        ca_tag = [tag for tag in force_tags if 'ca_' in tag.lower()]
        if ca_tag:
            return ca_tag[0][3:]
        else:
            return 'RAN_PZ_WRO_2'
    except RobotNotRunningError:
        return 'RAN_PZ_WRO_2'


@logged_keyword
def evaluate_result(results, expected_rate=EXPECTED_RATE):
    pass_rate = results.count(True) / len(results)
    return PASSED_STATUS if pass_rate >= expected_rate else FAILED_STATUS


@logged_keyword
def get_sw_version():
    with AdminApi() as web_api:
        return web_api.get_sw_version()
