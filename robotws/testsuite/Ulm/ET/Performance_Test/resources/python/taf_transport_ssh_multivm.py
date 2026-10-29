'''
MultiVM SSH Connection
'''

import re
import sys
import logging
import importlib
import subprocess
import pathlib


import taf.internal.aliasing as taf_internal_aliasing
from taf.config.testline.testline import TestLine
from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper

logger = logging.getLogger(__name__)

CONST_CORE_ALIASES = [
    taf_transport_ssh_wrapper.CONST_CORE_ALIAS, 'ssh-core-vm2', 'ssh-core-vm3']


def execute(cmd: str, *args, index: int = 0, **kwargs):
    try:
        return taf_transport_ssh_wrapper.execute(cmd, *args, CONST_CORE_ALIASES[index], **kwargs)
    except taf_internal_aliasing.AliasLookupError:
        logger.error('AliasLookupError: index(%s) %s, cmd: %s',
                     index, CONST_CORE_ALIASES[index], cmd)
        return f'AliasLookupError: {CONST_CORE_ALIASES[index]}'


def upload_file(*args, test_pc_index: int = 0, **kwargs):
    taf_transport_ssh_wrapper.upload_file(
        *args, connection=CONST_CORE_ALIASES[test_pc_index], **kwargs)


def ssh_connect_all_vm(tl: TestLine = None, indexes: list = None, **kwargs):
    """
    tl      :     TestLine obj
    indexes :     test_pc indexex
    """
    if tl is None:
        tl = get_tl_obj_from_current_host()
    for index in range(test_pc_count(tl)):
        logger.debug("connect vm %s", index + 1)
        try:
            ssh_connect_on_onevm_in_multivm(tl, index, **kwargs)
        except Exc.MultiVMException:
            logger.warning(
                'MultiVMException: Unable to connect (vm %s)', index + 1)


def ssh_connect_on_onevm_in_multivm(tl: TestLine, index: int, **kwargs):
    """
    tl    :     TestLine obj
    index :     test_pc index
    """
    connection_details = get_credentials_from_testline(tl, index)
    logger.info("Connect VM (%s) %s as %s", index + 1,
                connection_details.addr, CONST_CORE_ALIASES[index])
    taf_transport_ssh_wrapper.ssh_connect(hostname=connection_details.addr,
                                          username=connection_details.username,
                                          password=connection_details.password,
                                          alias=CONST_CORE_ALIASES[index],
                                          **kwargs)


def get_credentials_from_testline(tl: TestLine, index: int):
    """
    tl    :     TestLine obj
    index :     test_pc index
    ex. returns {addr, username, password}
    """
    if hasattr(tl, 'test_pcs'):
        try:
            return tl.test_pcs[index].default_ssh_connection_details
        except IndexError as e:
            logger.error("wrong test_pc index (%s), must be 0 to %s",
                         index, len(tl.test_pcs)-1)
            raise Exc.MultiVMException from e
    else:
        logger.warning('tl obj is only for 1 vm')
        return tl.test_pc.default_ssh_connection_details


def get_tl_obj_from_current_host(testline_config_dir: str = '/home/ute/DEVELOPMENT/testline_configuration'):
    rawhost = subprocess.run("hostname", encoding='utf-8',
                             shell=True, check=False, stdout=subprocess.PIPE).stdout
    rawhost = re.sub(r'_\d+$', '', rawhost.replace('-', '_').strip().replace('\n', ''))
    path_to_config = pathlib.Path(testline_config_dir)
    logger.debug("appending path: %s", path_to_config)
    sys.path.insert(1, str(path_to_config))
    logger.debug(sys.path)
    return importlib.import_module(rawhost, package='__init__').tl


def is_multi_vm(tl=None) -> bool:
    if tl is None:
        tl = get_tl_obj_from_current_host()
    return test_pc_count(tl) > 1


def test_pc_count(tl=None) -> int:
    """
    This function returns the number of test pcs defined in the testline configuration.
    If the testline configuration cannot be found, 1 is returned.
    """
    try:
        if tl is None:
            tl = get_tl_obj_from_current_host()
        return len(tl.test_pcs)
    except ModuleNotFoundError as e:
        logger.error('Unable to determine test pc count for host: %s', e)
        return 1


class Exc:

    class MultiVMException(Exception):
        pass


def _main():
    print('test taf_transport_ssh_multivm.py')
    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=logging.DEBUG
    )
    ssh_connect_all_vm(get_tl_obj_from_current_host())
    print(execute('hostname', index=0))
    print(execute('hostname', index=1))
    print(execute('hostname', index=2))
    print('end test taf_transport_ssh_multivm.py')


if __name__ == "__main__":
    _main()
