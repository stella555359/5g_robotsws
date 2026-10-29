from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import \
    stop_and_collect_btslog, start_btslog_on_local_machine
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_lte import TcpdumpLte
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti.tti_streaming as tti
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from time import sleep
from datetime import datetime
import os

l1l2 = L1L2()
tcpdump_nr = TcpdumpSmod()
tcpdump_lte = TcpdumpLte()


@logged_keyword
def logs_collector(output_dir=None, log_name='logs_collector', duration=10, collect_l1l2=False, smod_lte=False,
                   smod_master=False, smod_slave=False, collect_tti=False, collect_btslog=False,
                   collect_snapshot=False):
    output_dir = robot_globals.outputdir() if output_dir is None else output_dir
    run_folder_abspath = check_and_assign_folder(output_dir=output_dir)

    create_folder(run_folder_abspath)

    blog('L1L2: {}. SMOD_master_5G: {}. SMOD_slave_5G: {}. TTI: {}. btslog: {}. snapshot: {}'.format(
        collect_l1l2, smod_master, smod_slave, collect_tti, collect_btslog, collect_snapshot))

    if collect_l1l2:
        l1l2.start_gnbmirroring(filename=os.path.join(run_folder_abspath, log_name))

    if collect_btslog:
        start_btslog_on_local_machine()

    if smod_lte:
        tcpdump_lte.start_tcpdump_on_lte(filename=os.path.join(log_name))

    if smod_master or smod_slave:
        tcpdump_nr.start_tcpdump_on_smod(filename=os.path.join(log_name),
                                         smod_master=smod_master, smod_slave=smod_slave)

    if collect_tti:
        tti.start_tti_traces_in_streaming_mode(collector_type='sbts')

    sleep(duration)

    tti_logs, l1l2_logs, sctp_logs, btslog_dir, snapshot_dir = None, None, None, None, None

    if collect_tti:
        folder_name = os.path.basename(run_folder_abspath)
        tti_logs = tti.stop_tti_traces_in_streaming_mode(tti_output_dir=output_dir,
                                                         decoded_output_file=os.path.join(folder_name, log_name))

        tti_pcap_path = os.path.join(output_dir, 'TTI/tti_tcpdump/tti_tcpdump.pcap')
        os.rename(tti_pcap_path, os.path.join(run_folder_abspath, 'tti_tcpdump.pcap'))

    if collect_l1l2:
        sleep(1)
        l1l2_logs = l1l2.stop_gnbmirroring_and_download_logs()

    if smod_lte:
        lte_logs = tcpdump_lte.stop_tcpdump_and_download_logs_from_lte()
        dst = os.path.join(run_folder_abspath, os.path.basename(lte_logs))
        os.rename(lte_logs, dst)

    if smod_master or smod_slave:
        sctp_logs = tcpdump_nr.stop_tcpdump_and_download_logs_from_smod()
        dst = os.path.join(run_folder_abspath, os.path.basename(sctp_logs))
        os.rename(sctp_logs, dst)

    if collect_btslog:
        btslog_dir = stop_and_collect_btslog(target_dir=os.path.join(run_folder_abspath))

    if collect_snapshot:
        snapshot_dir = os.path.join(run_folder_abspath, 'snapshot.tar.gz')
        au = AdminUtils()
        au.collect_snapshot(snapshot_dir)

    blog('L1L2_path: {}. tcpdump_5G_path: {}. TTI_path: {}. btslog_path: {}. snapshot_path: {}'.format(
        tti_logs, l1l2_logs, sctp_logs, btslog_dir, snapshot_dir))


def create_folder(folder):
    if not os.path.exists(folder):
        os.makedirs(folder)


def check_and_assign_folder(output_dir, name_pattern='run'):
    now = datetime.now()
    timestamp = now.strftime('%Hh_%Mm_%Ss')
    folder_without_timestamp = '{}_0'.format(name_pattern)
    folder = '{}__{}'.format(folder_without_timestamp, timestamp)
    path = os.path.join(output_dir, folder)

    while folder_with_idx_exists(output_dir, folder_without_timestamp):
        name_without_idx, run_idx = folder.split('_')[:2]
        new_idx = int(run_idx) + 1
        folder_without_timestamp = '{}_{}'.format(name_without_idx, new_idx)
        folder = '{}__{}'.format(folder_without_timestamp, timestamp)
        path = os.path.join(output_dir, folder)

    blog('logs output path: {}'.format(path))
    return path


def folder_with_idx_exists(output_dir, folder):
    existing_folders = os.listdir(output_dir)
    return any(folder in f for f in existing_folders)
