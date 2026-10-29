"""
Multi VM WTS Wrapper

source /home/ute/DEVELOPMENT/env_activate
python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/taf_sw_wtssim_wrapper.py \
    --log_level WARN --test



"""

import argparse
import logging

import robot.libraries.BuiltIn

import taf.sw.wtssim
import taf.internal.aliasing
from taf.config.testline.testline import TestLine

from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_multivm


_SW_WTSSIM_OBJ = None
COMMON_ALIAS_OK = False
CONST_COMMON_EDAEMON_PORT = 22222
CONST_COMMON_EGATE_PORT = 10000
CONST_COMMON_SSH_PORT = 22
CONST_COMMON_SSH_PROMPT = '$'
CONST_COMMON_EGATE_PATH = '/opt/iphy/latest'
CONST_COMMON_TELNET_PROMPT = 'EGATE>'
CONST_EGATE_ALIASES = ['telnet-egate-vm1',
                       'telnet-egate-vm2',
                       'telnet-egate-vm3']


logger = logging.getLogger(__name__)


def execute_egate_command(cmd: str, *args, **kwargs) -> str:
    return _execute_egate_command_interface('execute_egate_command', cmd, *args, **kwargs)


def execute_egate_command_and_wait_for_data(cmd: str, *args, **kwargs) -> str:
    return _execute_egate_command_interface('execute_egate_command_and_wait_for_data', cmd, *args, **kwargs)


def _execute_egate_command_interface(sw_wtssim_function: str,
                                     cmd: str,
                                     *args,
                                     test_pc_index: int = 0,
                                     pass_regexp: str = CONST_COMMON_TELNET_PROMPT,
                                     add_newline=True,
                                     **kwargs) -> str:
    logger.debug('EGATE VM %s: %s', test_pc_index+1, cmd)
    retval = 'empty'
    sw_wtssim_func = getattr(get_taf_sw_wtssim_obj(), sw_wtssim_function)
    retries = int(kwargs.pop('retries', 0))
    max_retries = int(kwargs.pop('max_retries', 1))
    try:
        retval = sw_wtssim_func(cmd + ' \n' if add_newline else cmd,
                                *args,
                                alias=CONST_EGATE_ALIASES[test_pc_index],
                                pass_regexp=pass_regexp,
                                ** kwargs)
    except TimeoutError:  # probably catching asyncio.exceptions.TimeoutError too
        logger.error('[TimeoutError] [%s] %s',
                     CONST_EGATE_ALIASES[test_pc_index], cmd)
        retval = f'[TimeoutError] [{CONST_EGATE_ALIASES[test_pc_index]}] {cmd}'
    except AttributeError:
        logger.error('[AttributeError] [%s] %s',
                     CONST_EGATE_ALIASES[test_pc_index], cmd)
        retval = f'[AttributeError] [{CONST_EGATE_ALIASES[test_pc_index]}] {cmd}'
    except taf.internal.aliasing.AliasLookupError as e:
        retval = f"[AliasLookupError] [{CONST_EGATE_ALIASES[kwargs.get('test_pc_index', 0)]}] {cmd}"
        if retries < max_retries:
            kwargs['retries'] = retries + 1
            logger.warning('[AliasLookupError] [%s] %s, %s. Retrying... (%d/%d)',
                           CONST_EGATE_ALIASES[kwargs.get('test_pc_index', 0)], cmd, e, kwargs['retries'], max_retries)
            setup_all_egates_and_edaemons_connections()
            return _execute_egate_command_interface(sw_wtssim_function, cmd, *args, **kwargs)
    if retval is None:
        logger.warning('[ReturnedNoneType] [%s] %s',
                       CONST_EGATE_ALIASES[test_pc_index], cmd)
    return retval


def setup_all_egates_and_edaemons_connections(tl: TestLine = None) -> None:
    if tl is None:
        tl = get_tl_obj_from_current_host()
    for test_pc_index in range(taf_transport_ssh_multivm.test_pc_count(tl)):
        try:
            _setup_egate(tl, test_pc_index)
            _setup_edaemon(tl, test_pc_index)
        except OSError as e:
            logger.error('EGATE: %s', e)


def _setup_egate(tl: TestLine,
                 index: int,
                 egate_port: int = CONST_COMMON_EGATE_PORT,
                 tool_dir: str = CONST_COMMON_EGATE_PATH,
                 ssh_port: int = CONST_COMMON_SSH_PORT) -> None:
    connection_details = taf_transport_ssh_multivm.get_credentials_from_testline(tl, index)
    get_taf_sw_wtssim_obj().setup_egate(egate_port=egate_port,
                                        tool_dir=tool_dir,
                                        host_ip=connection_details.addr,
                                        ssh_user=connection_details.username,
                                        ssh_pass=connection_details.password,
                                        ssh_port=ssh_port,
                                        ssh_prompt=CONST_COMMON_SSH_PROMPT,
                                        alias=CONST_EGATE_ALIASES[index]
                                        )


def _setup_edaemon(tl: TestLine,
                   test_pc_index: int,
                   edaemon_port: int = CONST_COMMON_EDAEMON_PORT,
                   tool_dir: str = CONST_COMMON_EGATE_PATH,
                   ssh_port: int = CONST_COMMON_SSH_PORT) -> None:
    connection_details = taf_transport_ssh_multivm.get_credentials_from_testline(tl, test_pc_index)
    get_taf_sw_wtssim_obj().setup_edaemon(edaemon_port=edaemon_port,
                                          tool_dir=tool_dir,
                                          ssh_user=connection_details.username,
                                          ssh_pass=connection_details.password,
                                          ssh_port=ssh_port,
                                          ssh_prompt=CONST_COMMON_SSH_PROMPT,
                                          alias=CONST_EGATE_ALIASES[test_pc_index]
                                          )
    get_taf_sw_wtssim_obj().link_edaemons_to_egate(CONST_EGATE_ALIASES[test_pc_index],
                                                   alias=CONST_EGATE_ALIASES[test_pc_index])


def teardown_all() -> None:
    get_taf_sw_wtssim_obj().teardown_all_aliases_for_wts(collect_logs=False)


def get_taf_sw_wtssim_obj() -> taf.sw.wtssim.wtssim:
    global _SW_WTSSIM_OBJ  # pylint: disable=locally-disabled, W0603
    if _SW_WTSSIM_OBJ is None:
        try:
            _SW_WTSSIM_OBJ = robot.libraries.BuiltIn.BuiltIn().get_library_instance('taf.sw.wtssim')
        except robot.libraries.BuiltIn.RobotNotRunningError:
            logger.info('initializing taf.sw.wtssim.wtssim()')
            _SW_WTSSIM_OBJ = taf.sw.wtssim.wtssim()
    return _SW_WTSSIM_OBJ


def _main() -> None:
    parser = argparse.ArgumentParser(description='taf_sw_wtssim_wrapper.py')
    parser.add_argument('--log_level', default="WARN")
    parser.add_argument('--cmd', default=None)
    parser.add_argument('--test_pc_index', default="0")
    parser.add_argument('--test', action='store_true')
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=getattr(logging, args.log_level)
    )

    setup_all_egates_and_edaemons_connections(tl=taf_transport_ssh_multivm.get_tl_obj_from_current_host())

    if args.test:
        print(execute_egate_command('sim_log_set', test_pc_index=0))
        print(execute_egate_command('sim_log_set', test_pc_index=1))
        print(execute_egate_command('sim_log_set', test_pc_index=2))
    else:
        if args.cmd:
            print(execute_egate_command_and_wait_for_data(
                args.cmd, int(args.test_pc_index)))


if __name__ == "__main__":
    _main()
