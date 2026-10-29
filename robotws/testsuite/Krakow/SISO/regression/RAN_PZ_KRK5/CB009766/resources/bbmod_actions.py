import re
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def action_with_bbmod(action, bbmod_id=None):
    gnb_du = GnbDuOperations()
    bbmod_ids = get_bbmods_list(bbmod_id)
    print(f"mizajac {bbmod_ids}")
    if action == 'Lock':
        for bbmod in bbmod_ids:
            runtime_bbmod_id = get_bbmod_runtime_id(bbmod_id=bbmod)
            gnb_du.lock_bbmod(bbmod_id=int(runtime_bbmod_id), timeout=60)
            logger.log_info_to_console(f'BBMOD id: {bbmod} was locked.')
    elif action == 'Unlock':
        for bbmod in bbmod_ids:
            runtime_bbmod_id = get_bbmod_runtime_id(bbmod_id=bbmod)
            gnb_du.unlock_bbmod(bbmod_id=int(runtime_bbmod_id), timeout=60)
            logger.log_info_to_console(f'BBMOD id: {bbmod} was unlocked.')
    else:
        logger.log_warn_to_console(f"Action: {action} not supported by this KW. Please contact with KW autor.")


def get_bbmods_list(str_bbmods_list=None):
    return get_all_bbmod_ids() if str_bbmods_list is None else str_bbmods_list.split()


def get_all_bbmod_ids():
    gnb_du = GnbDuOperations()
    bts_info = gnb_du.get_bts_info()
    bbmod_ids = []
    print(f"mizajac {bts_info['basebandModules']}")
    for bbmod_info in bts_info['basebandModules']:
        try:
            dist_name = bbmod_info['id']['configuration']
            match = re.search(r'BBMOD-(\d+)$', dist_name)
            if match:
                bbmod_id = match.group(1)
                bbmod_ids.append(int(bbmod_id))
        except KeyError:
            logger.log_warn_to_console(f"lape Keyerror z dist_name bbmod_info id configuration")
    bbmod_ids.sort()
    print(f"mizajac {bbmod_ids}")
    return bbmod_ids


def get_bbmod_runtime_id(bbmod_id):
    gnb_du = GnbDuOperations()
    bts_info = gnb_du.get_bts_info()
    for bbmod_info in bts_info['basebandModules']:
        try:
            dist_name = bbmod_info['id']['configuration']
            match = re.search(r'BBMOD-{}$'.format(bbmod_id), dist_name)

            if match:
                runtime_dist_name = bbmod_info['id']['internal']
                runtime_id = re.search(r'BBMOD_R-(\d+)$', runtime_dist_name).group(1)
                return runtime_id
        except KeyError:
            logger.log_warn_to_console(f"lape Keyerror z dist_name bbmod_info id configuration")
