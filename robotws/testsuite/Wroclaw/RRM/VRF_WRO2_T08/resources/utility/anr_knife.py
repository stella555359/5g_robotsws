import os

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.testline_preparation.testline_preparation import \
    verify_x2_link_is_available
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.AdminWrapper import AdminWrapper
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

cm = ConnectionManager()
admin = AdminWrapper()
temp_dir = '/tmp/temp'
ini_file_path = 'opt/nokia/SS_CPLANE/etc/cp_cl.enb_conf.ini'
param_name = 'rdNeighRemovalEvaluationTime'


def anr_knife(value='5'):
    _mount_burak_network_drive()
    with Admin5G() as admin_api:
        sw_release = admin_api.get_sw_release_name()
        if sw_release not in ['SBTS24R1', 'SBTS24R2', 'SBTS24R3', 'SBTS25R1', 'SBTS25R2']:
            with cm.nr_smod_connection() as smod:
                cp_cl_archive = _find_cp_cl_archive(smod)
                logger.info(f"Found archive {cp_cl_archive}", also_to_console=True)
                ini_file = _get_raw_cp_cl_ini_file(smod, cp_cl_archive)
                logger.info(f"ini file extracted to: {ini_file}", also_to_console=True)
                current_value = _get_current_param_value(smod, ini_file)
                if current_value != value:
                    logger.info(f"Updating knife parameter {param_name} from {current_value} to {value}",
                                also_to_console=True)
                    _prepare_ini_file(smod, ini_file, current_value, value)
                    _upload_knife(smod)
                    _execute_knife(smod, cp_cl_archive, ini_file)
                    wait_for_bts_ready()


def _mount_burak_network_drive():
    cmd = "sudo mkdir /mnt/burak1 && sudo chmod 777 /mnt/burak1 && sudo mount -t cifs " \
          "//10.42.248.45/Global_veryfication/ /mnt/burak1/ -o " \
          "username=plwr4gsfe,password=ltesfe4@,domain=noklab,file_mode=0777,dir_mode=0777,uid=ute,gid=ute"
    os.system(cmd)


def _find_cp_cl_archive(smod):
    files = smod.execute_command(cmd='find /rom/swpool/CPLANE-5G/ -name cp-cl*.txz').splitlines()
    assert len(files) == 1, f"There should be only one cp-cl file! Found files: {files}"
    return files[0]


def _get_raw_cp_cl_ini_file(smod, cp_cl_archive):
    smod.send_command(f'mkdir -p {temp_dir}')
    return _extract_ini_file_from_cp_cl_archive(smod, cp_cl_archive)


def _extract_ini_file_from_cp_cl_archive(smod, file):
    output = smod.execute_command(f'tar -xvf {file} -C {temp_dir} {ini_file_path}')
    if "not found in archive" in output.lower():
        output = smod.execute_command(f'tar -xvf {file} -C {temp_dir} ./{ini_file_path}')
        if "not found in archive" in output.lower():
            raise FileNotFoundError(ini_file_path)
    return os.path.join(temp_dir, ini_file_path)


def _get_current_param_value(smod, ini_file):
    params = smod.execute_command(f'grep {param_name}= {ini_file}').splitlines()
    assert len(params) == 1, f"There should be only one {param_name} in .ini file, found {len(params)}"
    if 'No such file or directory' in params[0]:
        raise FileNotFoundError(f'{ini_file} does not exist')
    print(params)
    return params[0].split('=')[1]


def _prepare_ini_file(smod, ini_file, current_value, target_value):
    smod.execute_command(f"sed -i 's/{param_name}={current_value}/{param_name}={target_value}/' {ini_file}")


def _upload_knife(smod):
    smod.upload_file(local_path='/mnt/burak1/[2]GloVer/[2]GloVer/Users/kaczmars/ANR/knife',
                     remote_path='/usr/bin/knife')
    smod.send_command('chmod 777 /usr/bin/knife')


def _execute_knife(smod, cp_cl_archive, updated_ini):
    cp_cl_archive_name = os.path.basename(cp_cl_archive)
    logger.info(f"Executing knife update command...", also_to_console=True)
    smod.execute_command(f'knife update {cp_cl_archive_name} {updated_ini}', timeout=180)
    logger.info(f"Rebooting SMOD...", also_to_console=True)
    smod.send_command('reboot')


@wait_until_function_succeeds(600, 10)
def wait_for_bts_ready():
    with admin.nr_context():
        logger.info(f"Wait for all cells online...", also_to_console=True)
        verify_x2_link_is_available('admin_nr')
