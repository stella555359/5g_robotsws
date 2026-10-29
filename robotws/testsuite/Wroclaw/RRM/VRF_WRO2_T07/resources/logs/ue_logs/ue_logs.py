from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.ue_logs.QxdmLogsCollector import QxdmLogsCollector
from taf.sw.qualcomm.license.interface import license
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.transport.ssh import ssh
import os

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword

ue_pc_dir = 'c:/Users/wro5grrm/auto'
ue_pc_logs_dir = os.path.join(ue_pc_dir, 'logs')


@logged_keyword
def start_ue_logging(filename=None, duration=20, username=None, password=None, ue_id=0):
    filename = robot_globals.testname() + '_ue_log' if filename is None else filename
    username = tl.qxdm_username if username is None else username
    password = tl.qxdm_password if password is None else password

    uepc_alias = connections.connect_to_uepc(ue_id=int(ue_id))
    _ssh = ssh()
    _ssh.upload_file(remote_path='/cygdrive/c/Users/wro5grrm/auto/QxdmCommand.py',
                     local_path=os.path.join(
                         robot_globals.execdir(),
                         'testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/ue_logs/QxdmCommand.py'),
                     connection=uepc_alias)
    get_5g_qxdm_and_qcat_license(username=username, password=password, ue_id=int(ue_id))
    start_qxdm(filename=filename + '.hdf', duration=duration, ue_id=int(ue_id))


@logged_keyword
def stop_ue_logging(filename=None, ue_id=0):
    filename = robot_globals.testname() + '_ue_log' if filename is None else filename
    uepc_alias = connections.connect_to_uepc(ue_id=int(ue_id))
    stop_qxdm(filename=filename + '.hdf', ue_id=int(ue_id))
    release_5g_qxdm_and_qcat_license(int(ue_id))
    _ssh = ssh()
    ue_logs_output_path = os.path.join(robot_globals.outputdir(), filename + '.txt')
    _ssh.download_file(remote_path=os.path.join(ue_pc_logs_dir, filename + '.txt'),
                       local_path=ue_logs_output_path,
                       connection=uepc_alias)
    return ue_logs_output_path


def release_5g_qxdm_and_qcat_license(ue_id, lk_path=None):
    lk_path = tl.ues[int(ue_id)].licensekeeper if not lk_path else lk_path
    launcher = {'host': tl.ues[int(ue_id)].ssh_connection_details.addr,
                'path': lk_path,
                'user': tl.ues[int(ue_id)].ssh_connection_details.username,
                'password': tl.ues[int(ue_id)].ssh_connection_details.password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.release_licence_qxdm_5g()
    lk.release_licence_qcat_5g()
    lk.logout()
    lk.teardown()


def get_5g_qxdm_and_qcat_license(username, password, ue_id, lk_path=None):
    lk_path = tl.ues[int(ue_id)].licensekeeper if not lk_path else lk_path
    launcher = {'host': tl.ues[int(ue_id)].ssh_connection_details.addr,
                'path': lk_path,
                'user': tl.ues[int(ue_id)].ssh_connection_details.username,
                'password': tl.ues[int(ue_id)].ssh_connection_details.password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.login(username=username, password=password)
    lk.get_licence_qxdm_5g()
    lk.get_licence_qcat_5g()


def start_qxdm(filename, duration, ue_id):
    dmc_file = tl.ues[int(ue_id)].dmc_path
    diag_com = tl.ues[int(ue_id)].diag_com
    logs_path = os.path.join(ue_pc_logs_dir, filename)

    qxdm_collector = QxdmLogsCollector(script_name='QxdmCommand.py', ue_pc_dir_path=ue_pc_dir)
    qxdm_collector.collect_and_save_qxdm_hdf_log(log_file=logs_path, ue_id=int(ue_id), duration=duration,
                                                 dmc_file=dmc_file, com_port=diag_com, mode='start')


def stop_qxdm(filename, ue_id):
    dmc_file = tl.ues[int(ue_id)].dmc_path
    diag_com = tl.ues[int(ue_id)].diag_com
    qcat_path = tl.ues[int(ue_id)].qcat_path
    logs_path = os.path.join(ue_pc_logs_dir, filename)

    qxdm_collector = QxdmLogsCollector(script_name='QxdmCommand.py', ue_pc_dir_path=ue_pc_dir)
    qxdm_collector.collect_and_save_qxdm_hdf_log(log_file=logs_path, ue_id=int(ue_id), duration=0,
                                                 dmc_file=dmc_file, com_port=diag_com, mode='stop')
    qxdm_collector.convert_hdf_log_to_txt(hdf_log=logs_path, ue_id=ue_id, qcat_path=qcat_path, timeout=60)
