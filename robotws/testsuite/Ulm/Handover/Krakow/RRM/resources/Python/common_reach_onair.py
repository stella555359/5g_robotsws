import time
import traceback
import pprint
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


def _elapsed(last_time):
    return time.time() - last_time


def _log_message(message):
    print(message)
    logger.console(message)


class RebootFailed(BaseException):
    pass


class ReachOnAirFailed(BaseException):
    pass


def reboot_testlines_and_wait_for_configured(retry_count=3, timeout=60*60):
    ta5g_testline_management_instance = BuiltIn(
    ).get_library_instance('ta5g_testline_management')
    ta5g_iphy_instance = BuiltIn().get_library_instance('ta5g_iphy')
    exceptions = []
    start_time = time.time()
    elapsed = 0
    while retry_count > 0 and timeout - elapsed > 0:
        reboot_start = time.time()
        try:
            _log_message('START: Rebooting actions')
            _log_message('START: Rebooting site')
            action_start = time.time()
            ta5g_testline_management_instance.trigger_site_reset()
            action_stop = time.time()
            _log_message('STOP: Rebooting site successful after: {}'.format(
                int(action_stop - action_start)))
            elapsed = _elapsed(start_time)
            _log_message('START: Wait for ping')
            action_start = time.time()
            ta5g_testline_management_instance.wait_for_testline_icmp_echo_replies_and_ssh_services()
            action_stop = time.time()
            _log_message('STOP: Wait for ping successful after: {}'.format(
                int(action_stop - action_start)))
            elapsed = _elapsed(start_time)
            time.sleep(60)
            elapsed = _elapsed(start_time)
            _log_message('START: Wait for radios')
            action_start = time.time()
            ta5g_iphy_instance.check_radios_availability()
            action_stop = time.time()
            _log_message('STOP: Wait for radios successfull after: {}'.format(
                int(action_stop - action_start)))
            elapsed = _elapsed(start_time)
            reboot_stop = time.time()
            _log_message('STOP: Reboot successfull with additional actions after: {}'
                         .format(reboot_stop - reboot_start))
            return
        except Exception as e:
            reboot_stop = time.time()
            exceptions.append(e)
            _log_message('EXC: Reboot failed after: {}s due to exception: {}'
                         .format(int(reboot_stop - reboot_start), e))
            traceback.print_exc()
            retry_count -= 1
    raise RebootFailed('All reboot attempts ({}) failed due to:\n{}'
                       .format(len(exceptions), pprint.pformat(exceptions)))


def reach_onair_with_retries(lua_cfg, retry_count=3, timeout=100*60):
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    start_time = time.time()
    initial_timeout = timeout
    elapsed = 0
    reach_onair_timeout = 1200  # actually not used in ta5g_lib currently
    exceptions = []
    while retry_count > 0 and timeout - elapsed > 0:
        reach_start = time.time()
        try:
            _log_message(
                'START: Reach on Air, with max retry count: {}'.format(retry_count))
            ta5g_egate_instance.reach_onair(
                lua_cfg=lua_cfg, timeout=reach_onair_timeout)
            reach_stop = time.time()
            _log_message('STOP: Reach onAir successful after :{}'.format(
                int(reach_stop - reach_start)))
            return
        except Exception as e:
            reach_stop = time.time()
            elapsed = _elapsed(start_time)
            exceptions.append(e)
            _log_message('EXC: Reach onAir took: {}s, failed due to: {}'.format(
                int(reach_stop - reach_start), e))
            traceback.print_exc()
        try:
            ta5g_egate_instance.teardown_egate_and_collect_logs()
        except Exception as e_t:
            _log_message(
                'EXC: Teardown egate failed due to: {}, skipping it'.format(e_t))
            traceback.print_exc()
        reboot_testlines_and_wait_for_configured(retry_count=retry_count,
                                                 timeout=initial_timeout-elapsed)
        retry_count -= 1
        elapsed = _elapsed(start_time)
    raise ReachOnAirFailed('All reach on Air attempts ({}) failed due to:\n{}'
                           .format(len(exceptions), pprint.pformat(exceptions)))
