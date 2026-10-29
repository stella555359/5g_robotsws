import os
import json
import subprocess
import logging
from taf.config.scf import scf
from time import sleep, time
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from taf.ue import ue
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.resources.log.matchers import SyslogMessageMatcher as SM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import wait_for_bbmod, wait_for_ru, \
    wait_for_onair, tl_type, wait_for_x2_link_availability

try:
    import urllib.request as urllib
except ImportError:
    import urllib as urllib

test_preconditions_scf_1 = {
    'shutdownWindow': '60',
    'shutdownStepAmount': '10',
    'actGrflShdn': 'true'
}

test_preconditions_scf_2 = {
    'shutdownWindow': '60',
    'shutdownStepAmount': '10',
    'actGrflShdn': 'false'
}

custom_swconfig_flags = {'0x590072': ('1', '5GC000501_A_23 logging flag')}

_ssh = ssh()
_utils = AdminUtils()


# TODO: THE BELOW FUNCTIONS ARE USED IN A24 TC AFTER EDA FIX
@logged_keyword
def stop_data_transfer_if_active(dt='DT_DL'):
    try:
        ue().stop_data_transfer(dt)
    except Exception as e:
        logging.info(f"There is no active Data Transfer on UE. - {e}")


@logged_keyword
def get_nr_bts_id():
    with AdminApi() as web_api:
        return web_api.get_bts_info()['nrBtsId']


@logged_keyword
def get_cells_list():
    with AdminApi() as web_api:
        return [cell['globalCellId'] for cell in web_api.get_cells_info()]


@logged_keyword
def unlock_all_cells():
    cells_list = get_cells_list()
    for cell_index in cells_list:
        cell_unlock_after_shutdown(cell_index)


@logged_keyword
def cell_unlock_after_shutdown(cell_nr):
    with AdminApi() as admin:
        admin.perform_parameter_recommissioning(dist_name=bts_prefix + '/NRCELL-' + str(cell_nr),
                                                parameter='administrativeState',
                                                operation='update',
                                                skip_parameter_relation_errors=True,
                                                value='Unlocked')


@logged_keyword
def perform_shutting_down(cell_nr):
    print(bts_prefix)
    with AdminApi() as admin:
        admin.perform_parameter_recommissioning(dist_name=bts_prefix + '/NRCELL-' + cell_nr,
                                                parameter='administrativeState',
                                                operation='update',
                                                skip_parameter_relation_errors=True,
                                                value='Shutting Down')


@logged_keyword
def set_sgNB_release_params(cell_nr, rsrp_threshold, shutdown_window=60, shutdown_step_amount=10):
    return {
        'srb3SupportEnabled': 'false',
        'a2MeasReleaseEnabled': 'rsrp',
        'shutdownWindow': str(shutdown_window),
        'shutdownStepAmount': str(shutdown_step_amount),
        'actGrflShdn': 'true',
        bts_prefix + '/NRCELL-' + cell_nr + '/a2HysteresisReleaseSsbRsrp': '2',
        bts_prefix + '/NRCELL-' + cell_nr + '/a2ThresholdReleaseSsbRsrp': rsrp_threshold,
        bts_prefix + '/NRCELL-' + cell_nr + '/a2TimeToTriggerReleaseSsbRsrp': 'ms512',
    }


@logged_keyword
def graceful_commissioning_with_ho(mrbts_id, nrbts_id, cell_ids, rsrp_threshold, shutdown_window, shutdown_step_amount):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
    for cell_id in cell_ids:
        cell_object = f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'
        # MRBTS/NRBTS
        ds.add_param_to_delta(nrbts_object, 'srb3SupportEnabled', 'false')
        ds.add_param_to_delta(nrbts_object, 'actGrflShdn', 'true')
        ds.add_param_to_delta(nrbts_object, 'shutdownWindow', str(shutdown_window))
        ds.add_param_to_delta(nrbts_object, 'shutdownStepAmount', str(shutdown_step_amount))
        # MRBTS/NRBTS/NRCELL
        ds.add_param_to_delta(cell_object, 'a2MeasReleaseEnabled', 'rsrp')
        ds.add_complex_item_to_delta(cell_object, 'a2MeasReleaseSsbRsrp',
                                     a2HysteresisReleaseSsbRsrp='2',
                                     a2ThresholdReleaseSsbRsrp=rsrp_threshold,
                                     a2TimeToTriggerReleaseSsbRsrp='ms512')

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)


@logged_keyword
def graceful_delta_commissioning(mrbts_id, nrbts_id, shutdown_window, shutdown_step_amount):
    ds = DeltaStore()
    ds.initialise_delta_store()

    nrbts_object = f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}'
    ds.add_param_to_delta(nrbts_object, 'actGrflShdn', 'true')
    ds.add_param_to_delta(nrbts_object, 'shutdownWindow', str(shutdown_window))
    ds.add_param_to_delta(nrbts_object, 'shutdownStepAmount', str(shutdown_step_amount))

    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)


@logged_keyword
def connect_to_rmod(rmod_ip, rmod_pass=None, rmod_username='root'):
    smod = connections.connect_to_smod()
    _ssh.send_command('rm -rf /tmp/sshd_debug.log', connection=smod)
    _ssh.send_command('lxc-attach -n 0x1018 -- /usr/sbin/sshd -p 22 -f /dev/null'
                      ' -o "PermitRootLogin yes" > /tmp/sshd_debug.log', connection=smod)
    container = _ssh.connect_to(hostname='192.168.255.254',
                                username='toor4nsn',
                                password=tl.gnbs[0].cu.oam_ssh_connection_details.password,
                                proxy=smod,
                                alias='container')
    rmod = _ssh.connect_to(hostname=rmod_ip,
                           username=rmod_username,
                           password=rmod_pass,
                           proxy=container,
                           alias='rmod')
    return rmod


@logged_keyword
def get_avg_cell_tx_power_on_rmod(rmod_connection, buffer_interval, step_duration, measure_loops=5, antls=4):
    start_time = time()
    sleep(buffer_interval)
    all_tx_powers = []
    measurements_qty = measure_loops * antls
    for measure in range(measure_loops):
        tx_power_measured_from_4_antl = _ssh.execute(
            command=f'dapd -pwr 0 && dapd -pwr 1 && dapd -pwr 2 && dapd -pwr 3', connection=rmod_connection)
        all_tx_powers.extend(tx_power_measured_from_4_antl.split())
    all_tx_powers = [float(string[string.find('=')+1:string.find(',')]) for string in all_tx_powers if 'TX' in string]
    try:
        assert len(all_tx_powers) == measurements_qty
    except AssertionError as e:
        e.args = (f'{measurements_qty} measurements expected, but {len(all_tx_powers)} measured. Check if four '
                  f'antenna lines are active.',)
        raise e
    avg_tx_power = sum(all_tx_powers)/measurements_qty
    sleep(buffer_interval)
    end_time = time()
    duration = end_time - start_time
    try:
        assert step_duration - 2 < duration < step_duration + 2
    except AssertionError as e:
        e.args = (f'Logs collected in {duration} seconds time slot, but it should last for less than '
                  f'{step_duration + 2} and more than {step_duration - 2}.',)
        raise e
    return round(avg_tx_power, 3)


@logged_keyword
def get_avg_cell_tx_power_on_rmod_while_graceful_shutdown(rmod_connection, buffer_interval, step_duration,
                                                          shutdown_step_amount):
    avg_tx_power_for_each_step = [
        get_avg_cell_tx_power_on_rmod(rmod_connection, buffer_interval, step_duration)
        for _ in range(shutdown_step_amount)]
    return avg_tx_power_for_each_step


@logged_keyword
def start_measuring_tx_power_in_webem(antls_dist_names, conn):
    _admin = admin()
    _admin.start_antl_online_monitoring(antls_dist_names, connection=conn)


@logged_keyword
def stop_measuring_tx_power_in_webem(cell_id, steps, conn):
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    output_file_name = f'{output_dir}/antls_monitoring.json'
    mrbts_id = str(BuiltIn().get_variable_value("${MRBTS_ID}"))
    json_key = BuiltIn().get_variable_value("${JSON_KEY_TL_MAP}")
    _admin = admin()
    _admin.stop_antl_online_monitoring(output_file_name, connection=conn)
    _admin.teardown(connection=conn)
    with open(output_file_name, 'r') as json_file:
        antl_data = json.load(json_file)
    all_antls_power = {}
    for antennaLines in antl_data['RSSI'][0]['antennaLines']:
        antl_dbm_values = list(antennaLines['measureDatas'][f'NRCELL-{cell_id}{json_key[mrbts_id]}'].values())
        antl_dbm_values = list(filter(lambda x: x != '-', antl_dbm_values))
        all_antls_power[antennaLines['name']] = [dbm for i, dbm in enumerate(antl_dbm_values)
                                                 if dbm not in set(antl_dbm_values[:i])]
    blog(all_antls_power)
    for dbm_list in all_antls_power.values():
        if len(dbm_list) == steps + 1 and all(x < y for x, y in zip(dbm_list, dbm_list[1:])):
            before_shutdown = dbm_list.pop(0)
            return before_shutdown, dbm_list

    # The below for loop is WA for unstable behavior of WebEm measurement method
    for dbm_list in all_antls_power.values():
        if len(dbm_list) == steps + 2:
            if abs(dbm_list[0] - dbm_list[1]) == 1:
                dbm_list.pop(0)
                if all(x < y for x, y in zip(dbm_list, dbm_list[1:])):
                    before_shutdown = dbm_list.pop(0)
                    return before_shutdown, dbm_list
            elif abs(dbm_list[0] - dbm_list[1]) == 3:
                dbm_list.pop()
                if all(x < y for x, y in zip(dbm_list, dbm_list[1:])):
                    before_shutdown = dbm_list.pop(0)
                    return before_shutdown, dbm_list
        elif len(dbm_list) == steps + 3:
            if abs(dbm_list[0] - dbm_list[1]) == 1 and abs(dbm_list[-1] - dbm_list[-2]) == 1:
                dbm_list.pop(0)
                dbm_list.pop()
                if all(x < y for x, y in zip(dbm_list, dbm_list[1:])):
                    before_shutdown = dbm_list.pop(0)
                    return before_shutdown, dbm_list

    raise Exception("Amount of measurements doesn't match amount of graceful shutdown steps. "
                    "Check value of 'all_antls_power' variable.")


@logged_keyword
def verify_power_reduction(before_shutdown, while_shutdown, deviation):
    # TODO: The below code is commented out because of unstable behavior on TL109
    # try:
    #     assert 3 - deviation <= abs(before_shutdown - while_shutdown[0]) <= 3 + deviation
    # except AssertionError as e:
    #     e.args = (f'Power reduction is not in range {3 - deviation}-{3 + deviation} dB per step',)
    #     raise e
    for i in range(1, len(while_shutdown)):
        reduction = abs(while_shutdown[i-1] - while_shutdown[i])
        try:
            assert 3 - deviation <= reduction <= 3 + deviation
        except AssertionError as e:
            e.args = (f'Power reduction is not in range {3 - deviation}-{3 + deviation} dB per step',)
            raise e


# TODO: THE BELOW FUNCTIONS ARE NOT USED IN A24 TC
def upload_runtime_ini_to_gnb():
    smod = connections.connect_to_smod()
    _ssh.execute(command='echo -e "[control]\nLoggingSeverity=trace" > '
                         '/ffs/run/cp_runtime.ini; chmod a+r /ffs/run/cp_runtime.ini',
                 connection=smod)


def check_event_a2_in_pcap_log(in_pcap, lua=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=in_pcap, lua=lua, shark_filter='',
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
        a2_event_msg = finder.find_next(
            PM('SgNBAdditionRequestAcknowledge', name_line_pattern='empty').containing('eventA2')
        )
        assert a2_event_msg, "Event A2 not found in pcap"


def check_a2_meas_in_bts_log(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        a2meas = finder.find_next(SM(r'(mentType: A2SgnbRelease)|'
                                     r'(measurementType A2SgnbRelease)|'
                                     r'(SgnbRelease)',
                                     regex_engine='re'))
        assert a2meas, 'A2SgnbRelease measurement not found in syslog'


def check_shutdown_msg_in_bts_log(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)
        shutdown_req = finder.find_next(SM('*ShutdownReq*'))
        assert shutdown_req, "not find ShutdownReq message in syslog"
        shutdown_resp = finder.find_next(SM('*ShutdownResp*'))
        assert shutdown_resp, "not find ShutdownResp message in syslog"


def check_ho_related_msg_in_bts_log(bts_log_file):
    with LogHelper() as lh:
        finder = lh.add_syslog(bts_log_file)

        msg1 = finder.find_next_anew(
            SM('*Processing IntraGnbHandover*')
        )
        msg2 = finder.find_next_anew(
            SM(r'(ueSuspendCause:HANDOVER)|(ueSuspendCause:HO_INTRA_DU)', regex_engine='re')
        )
        msg3 = finder.find_next_anew(
            SM('*\"ueAddCause\":\"INTRADUHANDOVER\"*')
        )
        msg4 = finder.find_next_anew(
            SM('*[IntraGnbIntraDuHandoverProcedure] RrcReconfigurationComplete*')
        )

        assert msg1, 'Processing IntraGnbHandover not found'
        assert msg2, 'Handover in ueSuspend cause not found'
        assert msg3, 'INTRADUHANDOVER not found in ueAddCause'
        assert msg4, 'IntraGnbIntraDuHO not found'


def set_HO_params(src_cell, dst_cell):
    return {
        'actIntraFreqHoSA': 'true',
        'shutdownWindow': '72',
        'shutdownStepAmount': '12',
        'actGrflShdn': 'true',
        bts_prefix + '/NRCELL-' + src_cell + '/a3MeasEnabled': 'rsrp',
        bts_prefix + '/NRCELL-' + src_cell + '/a3HysteresisSsbRsrp': '1',
        bts_prefix + '/NRCELL-' + src_cell + '/a3OffsetSsbRsrp': '3',
        bts_prefix + '/NRCELL-' + src_cell + '/a3TimeToTriggerSsbRsrp': 'ms320',
        bts_prefix + '/NRCELL-' + dst_cell + '/NRREL-' + dst_cell + '/cellIndividualSsbRsrpOffset': '0dB',
        bts_prefix + '/NRCELL-' + dst_cell + '/NRREL-' + dst_cell + '/cellIndividualSsbRsrqOffset': '0dB',
        bts_prefix + '/NRCELL-' + dst_cell + '/NRREL-' + dst_cell + '/removeNotAllowed': 'false',
    }


def set_parameters_above_range():
    with AdminApi() as admin:
        admin.perform_parameter_recommissioning(dist_name=bts_prefix,
                                                parameter='shutdownWindow',
                                                operation='update',
                                                skip_parameter_relation_errors=False,
                                                value=200,
                                                timeout=900)

        admin.perform_parameter_recommissioning(dist_name=bts_prefix,
                                                parameter='shutdownStepAmount',
                                                operation='update',
                                                skip_parameter_relation_errors=False,
                                                value=20,
                                                timeout=900)


def set_parameters_below_range():
    with AdminApi() as admin:
        admin.perform_parameter_recommissioning(dist_name=bts_prefix,
                                                parameter='shutdownWindow',
                                                operation='update',
                                                skip_parameter_relation_errors=False,
                                                value=5,
                                                timeout=900)

        admin.perform_parameter_recommissioning(dist_name=bts_prefix,
                                                parameter='shutdownStepAmount',
                                                operation='update',
                                                skip_parameter_relation_errors=False,
                                                value=0,
                                                timeout=900)


def check_feature_value():
    config_scf = scf()
    with AdminApi() as admin:
        admin.get_current_scf_file(local_dir_path='/tmp/', file_name='scf_file')
    # api = admin()
    # connection = api.connect_to()
    config_scf.load_scf('/tmp/scf_file')
    act_grfl_shdn_value = config_scf.get_all_values_from_scf(dist_name=bts_prefix, p_name='actGrflShdn')
    return str(act_grfl_shdn_value[0])


def set_actGrflShdn_to_false():
    with AdminApi() as admin:
        admin.perform_parameter_recommissioning(dist_name=bts_prefix,
                                                parameter='actGrflShdn',
                                                operation='update',
                                                skip_parameter_relation_errors=False,
                                                value='false',
                                                timeout=900)


def check_if_cell_is_locked_immediately(nrcell_id):
    with AdminApi() as admin:
        while True:
            sleep(5)
            result = admin.get_cells_info()
            for elem in range(len(result)):
                if int(result[elem]['id']['configuration'][-1:]) == int(nrcell_id):
                    return result[elem]['status']['administrativeState']


@logged_keyword
def update_sw_to_testpackage_t1():
    blog('Starting update procedure to testpackage t1...')
    with AdminApi() as web_api:
        sw_version = web_api.get_sw_version()
        sw_version = sw_version if '_ENB_9999_' not in sw_version \
            else '_'.join(['SBTS00' if 'SBTS' in x else x for x in sw_version.split('_')])
        sw_path = download_sw_package(sw_version=sw_version)
        web_api.update_software(sw_package=sw_path, timeout=2700)
    os.remove(sw_path)
    wait_for_bbmod()
    wait_for_ru()
    wait_for_onair()
    if tl_type() in ['both', 'NSA']:
        wait_for_x2_link_availability()


@logged_keyword
def download_sw_package(sw_version):
    url = get_download_link(str(sw_version))
    _file = '/tmp/' + url.split('/')[-1]
    blog('Downloading {url} to {path}'.format(url=url, path=_file))
    proc = subprocess.Popen(["wget", "-O", _file, url])
    proc.communicate()
    return _file


@logged_keyword
def get_download_link(sw_version):
    link = _get_download_link_sbts(sw_version)
    assert urllib.urlopen(link).code == 200, 'Link not valid {}'.format(link)
    return link


@logged_keyword
def _get_download_link_sbts(sw_version):
    repo = "http://files.ute.nsn-rdnet.net/builds/enb/base/"
    link = "{repo}{sw}/{sw}_release_BTSSM_downloadable_testpackage_T1.zip"
    return link.format(repo=repo, sw=sw_version)


def get_attached_cell_from_pcap(pcap_path):
    nr_cell_id = get_primary_and_secondary_physcellids_from_attach_pcap(pcap_path)
    blog('Cell attached: {cell_id}'.format(cell_id=nr_cell_id))
    global_cell_id = find_global_cell_id_given_cell_nr_id(nr_cell_id)
    return str(global_cell_id)


def get_primary_and_secondary_physcellids_from_attach_pcap(pcap_path=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_path)
        sgnb_add_req_ack = finder.find_all(PM('UEContextSetupRequest',
                                              name_line_pattern='empty'))[-1]
        phys_id_paths = sgnb_add_req_ack.find('*nRCellIdentity*')[0]['val']
    return int(phys_id_paths[:9], 16)


def find_global_cell_id_given_cell_nr_id(cell_nr_id):
    cells_info = _utils.get_subcells_info()
    blog(cells_info)
    cells_num = len(get_cells_list())
    cells = []
    for i in range(cells_num):
        cells.append(cells_info[u'NRCELLGRP-' + str(i)]['NRCELL-' + str(i + 1)]['NRCELL_L']['parameters'])
    for cell in cells:
        if cell['nrCellIdentity'] == cell_nr_id:
            return cell['lcrId']
    else:
        return -1
