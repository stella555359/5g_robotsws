import io
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
import os

_ssh = ssh()


@logged_keyword
def prepare_swconfig(custom_swconfig_flags=None, with_site_reset=True):
    """
    Modify swconfig located on SMOD according to the given flags and their values. Modification and site reset will not
    be performed if the modification is deemed redundant.
    :param custom_swconfig_flags: A dict of relevant SW flags. The values are tuples (flag_value, comment),
    containing the value of the flag and a comment describing the given flag, e.g. {'0x01': ('1', 'description')}
    :param with_site_reset: Decide whether you want to trigger site reset after swconfig modification.
    """
    swconfig_path = download_swconfig_file_from_smod()
    flags = {'0x1003F': ('1', 'DEFAULT'), '0x10040': ('1', 'DEFAULT'),
             '0x10041': ('2', 'DEFAULT'), '0x420000': ('1', 'DEFAULT')}
    if custom_swconfig_flags:
        flags.update(custom_swconfig_flags)

    if is_swconfig_modification_needed(swconfig_path, flags):
        modify_parameter_in_swconfig_file(swconfig_path, flags)
        upload_swconfig_to_smod()
        blog('SWCONFIG HAS BEEN MODIFIED!')

        if with_site_reset:
            web_api = AdminUtils()
            web_api.trigger_site_reset_and_wait_for_onair()


@logged_keyword
def is_swconfig_modification_needed(swconfig_path, flags_to_check):
    existing_flags = get_flags_from_swconfig(swconfig_path)
    existing_params_and_values = split_flags_into_params_and_values(existing_flags)

    for param, desc in iter(flags_to_check.items()):
        if (param, desc[0]) not in iter(existing_params_and_values.items()):
            return True
    return False


@logged_keyword
def get_flags_from_swconfig(swconfig_path):
    try:
        with io.open(swconfig_path, 'r+', errors='ignore') as f:
            file_lines = filter(None, (line.rstrip() for line in f))
            existing_flags = remove_commented_lines(file_lines)
            return existing_flags
    except EnvironmentError:
        raise blog('No swconfig found or you don\'t have access to the file.')


def remove_commented_lines(file_lines):
    relevant_lines = []
    for line in file_lines:
        if line[0] != '#':
            relevant_lines.append(line)
    return relevant_lines


def split_flags_into_params_and_values(flags_to_check):
    params_and_values = {}
    for flag in flags_to_check:
        params_and_values[flag.split('=')[0]] = flag.split('=')[1]
    return params_and_values


@logged_keyword
def modify_parameter_in_swconfig_file(swconfig_path, flags):
    try:
        with io.open(swconfig_path, 'r+', errors='ignore') as f:
            contents = f.readlines()

        idx_to_remove = []
        for idx, line in enumerate(contents):
            param = line.split('=')[0]
            if line[0] != '#' and param in flags.keys():
                idx_to_remove.append(idx)
                if contents[idx - 1][0] == '#':
                    idx_to_remove.append(idx - 1)

        contents = [line for idx, line in enumerate(contents) if idx not in idx_to_remove]

        for param, desc in iter(flags.items()):
            contents.append('# {}'.format(desc[1] + '\n'))
            contents.append('{}={}'.format(param, desc[0] + '\n\n'))

        with open(swconfig_path, 'w') as f:
            f.writelines(contents)

    except EnvironmentError:
        raise blog('No swconfig found or you don\'t have access to the file.')


def download_swconfig_file_from_smod(src='/ffs/run/swconfig.txt', dst=None):
    dst = os.path.join(robot_globals.outputdir(), 'swconfig.txt') if dst is None else dst
    smod_master_alias = connections.connect_to_smod()
    try:
        _ssh.download_file(remote_path=src, local_path=dst, connection=smod_master_alias)
        blog('Swconfig downloaded from SMOD successfully!')
    except FileNotFoundError:
        os.system('touch {}'.format(dst))
        blog('Swconfig does not exists on SMOD, new file created!')
    return dst


def upload_swconfig_to_smod(src=None, dst='/ffs/run/swconfig.txt'):
    src = os.path.join(robot_globals.outputdir(), 'swconfig.txt') if src is None else src
    smod_master_alias = connections.connect_to_smod()
    _ssh.upload_file(remote_path=dst, local_path=src, connection=smod_master_alias)
    blog('Swconfig uploaded to SMOD successfully!')

    return dst
