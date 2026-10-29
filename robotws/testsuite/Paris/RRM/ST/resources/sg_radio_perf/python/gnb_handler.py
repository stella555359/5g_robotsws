import os
import requests
import subprocess
import sys
import time
from bcolors import bcolors
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin

rf_built_in = BuiltIn()
vts_artifactory_url_espoo1\
    = 'https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/'
vts_artifactory_url_hz1\
    = 'https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/'
lterel_url\
    = 'https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/'
rel_url\
    = 'https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/'


def _log(message, console=True):
    rf_built_in.log(message=message, console=console)


def download_sw_from_wtf(sw, dl_path):
    """
        Ex:SBTS00_ENB_9999_210705_000006
        Download load every load from
        https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/
        https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/
        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/SBTS00/
        TODO : https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
        TODO : https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
    """

    branch_used = sw.split("_", 1)[0]
    full_sw = '{}_{}_release_BTSSM_downloadable_A54.zip' . format(branch_used, sw.split("_", 1)[1])
    sw_SBTS = '{}_{}' . format(branch_used, sw.split("_", 1)[1])
    full_dl_path = '{}{}' . format(dl_path, full_sw)

    if os.path.exists(full_dl_path):
        full_sw_term = bcolors.BOLD + full_dl_path + bcolors.ENDC
        _log(bcolors.INFO_MSG + '{} : Already exists. Skip download.' . format(full_sw_term))
        return full_dl_path

    url = rel_url + branch_used + '/' + sw_SBTS + '/' + full_sw

    if not os.path.exists(dl_path):
        os.makedirs(dl_path)

    _log(bcolors.INFO_MSG + 'Checking... {}'.format(url))
    full_cmd = 'wget --spider {} 2>&1'.format(url)
    p = subprocess.Popen(full_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[0]
    if sw[0:6:1] != 'SBTS00':
        if b'404 Not Found' in p:
            _log(bcolors.INFO_MSG + '...Not Found')
            full_sw = '{}_release_BTSSM_downloadable_A54.zip' . format(sw)
            full_dl_path = '{}/{}' . format(dl_path, full_sw)
            url = '{}{}/{}' . format(lterel_url, sw.split("_", 1)[0], full_sw)
            if os.path.exists(full_dl_path):
                full_sw_term = bcolors.BOLD + full_dl_path + bcolors.ENDC
                _log(bcolors.INFO_MSG + '{} : Already exists. Skip download.' . format(full_sw_term))
                return full_dl_path
            _log(bcolors.INFO_MSG + 'Checking... {}'.format(url))
            full_cmd = 'wget --spider {} 2>&1'.format(url)
            p = subprocess.Popen(full_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True).communicate()[0]

    if b'404 Not Found' in p:
        _log(bcolors.INFO_MSG + '...Not Found')
        raise NameError(bcolors.ERROR_MSG + 'Unable to find {}. Aborting' . format(sw))

    _log(bcolors.INFO_MSG+'Downloading... {}'.format(url))
    os.system('wget {} -P {}'.format(url, dl_path))

    return full_dl_path


def download_yaft_from_svn():
    _log(bcolors.INFO_MSG+'Checkout yaft from SVN')

    # todo remove rm & download only if no yaft dir
    os.system('rm -rf yaft && svn co'
              ' --username=ca_ute_test'
              ' --password=utetest'
              ' https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk/ yaft')


def yaft(load_file, host='192.168.255.129', log_dir='/tmp/logs', python_version=''):
    download_yaft_from_svn()

    _log(bcolors.INFO_MSG+'Perform yaft on {}'.format(host))
    cmd = 'echo oZPS0POrRieRtu | python{} ./yaft/yaft.py -i {} -z {} -l {}'\
        ' -d /5gswload/CV33/tmp'\
        ' --ask_for_password'\
        ' --ignore_FSPs'. format(python_version, host, load_file, log_dir)
    # ' --fpga_update'\
    # ' --clean_to_default'\

    failed = False
    exit_code = os.WEXITSTATUS(os.system(cmd))
    if exit_code == 1:
        failed = True

    # os.system('rm -rf ./yaft/')

    '''
    TODO
    process = subprocess.Popen(shlex.split(cmd), shell=False, stdout=subprocess.PIPE)
    while True:
        output = process.stdout.readline()
        if process.poll() is not None:
            break
        if output:
            if '***   FAILED   ***' in output:
                failed=True
            print output.strip()
    rc = process.poll()
    '''
    if failed:
        return False
    return True


def update_sw(host, args, enb=False):
    """
        Update software with the specified load.

    """
    prefix = 'gnb'
    if enb:
        prefix = 'enb'

    dl_dir = args[prefix + '_target_directory']
    force = args[prefix + '_force_update']
    rm = args[prefix + '_delete_sw']
    target_sw = args[prefix + '_sw']

    oam_admin = admin()
    oam_connection = oam_admin.connect_to(bts_host=host, name="coam_alias")
    current_sw = oam_admin.get_sw_version(connection=oam_connection)

    # extract XX etc. From SBTSXXRY_etc.
    current_num_sw = current_sw.split("SBTS", 1)[1][:2]
    target_num_sw = target_sw.split("SBTS", 1)[1][:2]

    # ex: ENB_9999_210710_000003 in SBTS22R1_ENB_9999_210710_000003
    if current_sw.split("_", 1)[1] in target_sw and force is False:
        _log(bcolors.INFO_MSG+'Load {} already commissionned.'.format(current_sw))
        oam_admin.teardown(connection=oam_connection)
        return True

    load_file = download_sw_from_wtf(target_sw, dl_dir)

    if prefix + '_dl_only' in args.keys() and args[prefix + '_dl_only']:
        oam_admin.teardown(connection=oam_connection)
        return True

    _log(
        bcolors.INFO_MSG + 'Updating ' + bcolors.BOLD + host + bcolors.ENDC
        + ' from ' + bcolors.BOLD + current_sw + bcolors.ENDC
        + ' to ' + bcolors.BOLD + target_sw + bcolors.ENDC)

    if prefix + '_yaft' in args.keys() and args[prefix + '_yaft']:
        oam_admin.teardown(connection=oam_connection)
        if not yaft(load_file, host):
            raise NameError(bcolors.ERROR_MSG + 'Failed to yaft sw with load {}' . format(load_file))
    else:
        status =\
            oam_admin.update_software(
                sw_package=load_file, should_activate=True, timeout=3600, connection=oam_connection)
        if status != 'Software update has been completed':
            oam_admin.teardown(connection=oam_connection)
            raise NameError(
                            bcolors.ERROR_MSG + 'Failed to update sw with load {} status : {}'
                            . format(load_file, status))

    oam_admin.teardown(connection=oam_connection)
    _log(bcolors.SUCCESS_MSG + 'Software update has been completed')
    _log(bcolors.INFO_MSG + 'Wait 60s before checking bts status...')
    time.sleep(60)

    import traceback
    import logging

    oam_connection = None
    while oam_connection is None:
        try:
            _log(bcolors.INFO_MSG + 'Trying to connect to bts...')
            oam_connection = oam_admin.connect_to(bts_host=host, name="coam_alias", timeout=600)
        except Exception as e:
            logging.error(traceback.format_exc())
            pass

    bts_on_air = False
    bts_on_air_times = 0
    while not bts_on_air:
        status = oam_admin.get_bts_statuses(connection=oam_connection)
        if status["proceduralState"].lower() != "onair":
            _log(bcolors.INFO_MSG + 'Wait 300s again (bts not OnAir)...')
            time.sleep(300)
            bts_on_air_times += 1
            if bts_on_air_times > 10:
                break
        else:
            bts_on_air = True

    _log(bcolors.SUCCESS_MSG+'BTS OnAir.')
    cells_up = False
    cells_up_times = 0
    cells_up_max_times = 30
    cells_up_seconds = 60
    # instead of check ongoing
    while not cells_up:
        cells = oam_admin.get_cells_info(cell_type='nr', timeout=30, connection=oam_connection)
        cells_up = True
        for cell in cells:
            if cell['status']['operationalState'].lower() != 'enabled':
                _log(bcolors.INFO_MSG+'Wait 120s again (cells not operational yet)...')
                cells_up_times += 1
                cells_up = False
                time.sleep(cells_up_seconds)

        if cells_up_times > cells_up_max_times:
            break

    if cells_up_times > cells_up_max_times:
        oam_admin.teardown(connection=oam_connection)
        raise NameError(bcolors.ERROR_MSG + 'All cells are not operational after '
                        + () + '+ min after applying sw. Aborting')

    _log(bcolors.SUCCESS_MSG + 'All cells up.')
    oam_admin.teardown(connection=oam_connection)

    _log(bcolors.SUCCESS_MSG+bcolors.BOLD + 'Applied {} on {}' . format(target_sw, host) + bcolors.ENDC)
    return False


if __name__ == '__main__':
    import argparse

    arg = argparse.ArgumentParser(description='Upgrade gNBs', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    arg.add_argument('-g', '--gnbs', nargs='+', required=True, help='List of gNBs IPs to upgdate')
    arg.add_argument('-s', '--gnb-sw', required=True,
                     help='Software to download from WFT. eg:SBTS22R2_ENB_9999_211130_000009')
    arg.add_argument('-t', '--gnb-target-directory', default='/tmp',
                     help='Target directory for downloaded file\
                        if the file is already found in the target directory, download is skipped')
    arg.add_argument('-f', '--gnb-force-update', action='store_true', default=False, help='Force update of the gNb')
    arg.add_argument('-d', '--gnb-delete-sw', action='store_true', default=False,
                     help='Delete the downloaded software from target directory, after software update.')
    arg.add_argument('--gnb-dl-only', action='store_true', help='Download only, no update is done')
    arg.add_argument('--gnb-yaft', action='store_true', help='Download only, no update is done')

    args = vars(arg.parse_args())
    for gnb in args['gnbs']:
        update_sw(host=gnb, args=args)
