import testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification as ttiv
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti.tti_streaming as ttis
import re
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections import connect_to_uepc
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.resources.log.log import blog
from taf.rfrl.ue.parsers.qxdm_parser import QxdmLogParser
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.core import CollectorKeywords
from taf.transport.ssh import ssh
from datetime import datetime
from calendar import day_abbr


def nullify_attenuation():
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    attenuator.release_attenuator()


def start_tti_traces_in_streaming_mode_for_specified_cells(nr_cell_dns, tcpdump_filename='tti_tcpdump'):
    blog('TTI Traces are forwarded to IP: ' + str(ttis.dest_ip))
    tcpdump_collector = ttis.start_tcpdump_on_tti_interface(tcpdump_filename=tcpdump_filename)
    start_generation_of_tti_trace_using_taf_sbts_with_specified_cells(tcpdump_collector, nr_cell_dns)


def start_generation_of_tti_trace_using_taf_sbts_with_specified_cells(tcpdump_collector, nr_cell_dns,
                                                                      tti_collector_name='TTI'):
    executor = {'host': tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr,
                'user': tl.gnbs[0].cu.oam_http_connection_details.username,
                'password': tl.gnbs[0].cu.oam_http_connection_details.password,
                'port': 443,
                'release': ttis.assign_release_version()}
    l2_stream_config_1 = {'trace_type': 'Component',
                          'nr_cell_dns': nr_cell_dns}
    l2_stream_configuration = [l2_stream_config_1]
    tti_collector = l2stream3()
    tti_collector.create_sbts_l2stream_collector(name=tti_collector_name, webservice=executor,
                                                 source_ip_addr=ttis.src_ip,
                                                 destination_ip_addr=ttis.dest_ip,
                                                 collector=tcpdump_collector,
                                                 l2_stream_configuration=l2_stream_configuration)
    core = CollectorKeywords()
    core.setup_collectors(names=tti_collector_name)
    core.start_collectors(names=tti_collector_name)
    core.set_suite_alias(tti_collector_name)
    blog('TTI streaming started!')


def get_max_rrm_value(tti_path):
    list_of_msg = ttiv.process_needed_messages(tti_path, ['ulFdSchedData'])
    return max((int(msg['rrmMaxNumPrbUl']) for msg in list_of_msg if int(msg['rrmMaxNumPrbUl']) < 60000))


def get_cell_info(cell_dist):
    with AdminApi() as admin_api:
        return admin_api.get_cell_specific_info(cell_dist)


def is_cell_in_reduced_energy_saving_state(cell_id):
    cell_info = get_cell_info(cell_id)
    return (cell_info['energySavingState'] == 'reducedEnergySaving') or \
           (cell_info['energySavingState'] == 'switchingOffRTX')


def assert_cell_in_reduced_energy_saving_state(cell_id):
    assert is_cell_in_reduced_energy_saving_state(cell_id), \
           "Cell with id {cell} isn't in reduced energy saving state".format(cell=cell_id)


def assert_cell_not_in_reduced_energy_saving_state(cell_id):
    assert not is_cell_in_reduced_energy_saving_state(cell_id), \
           "Cell with id {cell} is in reduced energy saving state".format(cell=cell_id)


def get_day_of_week():
    dt = datetime.now()
    return day_abbr[dt.weekday()]


def check_pdsch_tb_size(filepath, tb_size):
    msg_id = '0xB883'
    msg_field = "Carriers->PUSCH Data->TB Size (bytes)"
    parser = QxdmLogParser(file_path=filepath, message_ids=[msg_id])
    parser.parse()
    parser_results = parser.ret[msg_id]
    for msg in parser_results:
        idx = msg['Records']['headers'].index(msg_field)
        value = msg['Records']['values'][0][idx]
        if value == '':
            continue

        if int(value) >= int(tb_size):
            blog(f"Correct TB_size value found: {value}")
            return

    raise RuntimeError(f"QXDM analysis failed. TB_size that exceeds configured value: {tb_size} not found in logs")


def download_qxdm_log(output_dir, log_filepath):
    _ssh = ssh()
    _ssh.download_file(local_path=output_dir, remote_path=log_filepath, connection=connect_to_uepc())


def decode_emil_logs_on_uepc(local_path, file_list, remote_path, emil_path):
    decoded_filepaths = []
    _ssh = ssh()
    uepc_con = connect_to_uepc()
    _ssh.execute(command=f'mkdir {remote_path}', connection=uepc_con)

    for no, file in enumerate(file_list):
        file = file[:-4]
        uepc_filepath = f'{remote_path}/file_{no}.5gm'
        _ssh.upload_file(local_path=f'{local_path}/{file}.5gm', remote_path=uepc_filepath, connection=uepc_con)

        command = \
            f'cd {emil_path} && Emil.exe {uepc_filepath} -tocsv -autoclose -destination {remote_path}/file_{no}.csv'
        blog(f"Executing: {command}")
        _ssh.execute(command=command, connection=uepc_con)
        try:
            _ssh.download_file(remote_path=f'{remote_path}/file_{no}.csv', local_path=f'{local_path}/file_{no}.csv',
                               connection=uepc_con)
            decoded_filepaths.append(f'{local_path}/file_{no}.csv')
        except FileNotFoundError:
            blog(f"Could not download {local_path}/file_{no}.csv. The decoding process could have failed.")
            continue
    return decoded_filepaths


def check_emil_log_for_carrier_aggregation(file_list, pcell_pcid, scell_pcid):
    target_msg = "UEContextModificationResponse"
    pcell = "spCellConfig"
    scell = "sCellToAddModList"
    in_message = False
    pcell_found = False
    scell_found = False

    blog("Starting CSV file parsing")

    for csv_file in file_list:
        with open(csv_file, 'r') as file:
            lines = file.readlines()
            for i, line in enumerate(lines):
                if pcell_found and scell_found:
                    blog("Both pCell and sCell found in a message")
                    return

                if re.search(r"^0,\d{4}-\d{2}-\d{2}", line) is not None:
                    in_message = False
                    pcell_found = False
                    scell_found = False
                    if target_msg in line:
                        in_message = True

                if in_message:
                    if pcell in lines[i]:
                        if str(pcell_pcid) in lines[i+3]:
                            pcell_found = True

                    if scell in lines[i]:
                        if str(scell_pcid) in lines[i+4]:
                            scell_found = True

    raise RuntimeError("No message with both pCell and sCell found")
