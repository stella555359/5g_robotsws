import inspect
import json
import os
import time

from robot.libraries.BuiltIn import BuiltIn
from ta_attenuator import ta_attenuator
from taf.analyzer.pdml import PdmlReader, pdml
from taf.collectors.core import core
from taf.collectors.tcpdump import tcpdump
from taf.sbts.oam.coam.admin import admin
from ute_common_abstract_core.exceptions import AliasAlreadyAssignedError

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import AttachVerificationFail
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_variable, \
    set_robot_test_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration

_attenuator = ta_attenuator()
_tl_conf = TestlineConfiguration()
_cm = ConnectionManager()

ue = BuiltIn().get_library_instance("taf.ue")
core = core()
ues_list = get_robot_variable("NSA_UES", []) + get_robot_variable("SA_UES", [])
admin = admin()

CELL_TYPES = {"NR": "NRCEL",
              "LTE": "LNCEL",
              "WCDMA": "WNCEL",
              "GSM": "GNCEL"}


class PDUNotEstablishedError(Exception):
    pass


@logged_keyword
def initialize_attenuator():
    yaml_file = get_robot_variable("ABSTRACT_LIB_CONFIG")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')
    time.sleep(2)


@logged_keyword
def release_attenuator():
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


@logged_keyword
def create_tcpdump_collector(filename, attach_type):
    executor = {"host": "192.168.255.129",
                "user": "toor4nsn",
                "password": "oZPS0POrRieRtu"}
    if attach_type == "NSA" and get_robot_variable("REMOTE_VM_IP") is not None:
        remote_node_connection = {"host": "{}".format(get_robot_variable("REMOTE_VM_IP")), "user": "ute",
                                  "password": "oZPS0POrRieRtu"}
        executor["proxy"] = remote_node_connection
    tcpdump().create_tcpdump_collector(name="tcpdump_{}".format(attach_type), target_file_name=filename,
                                       options="sctp -i any",
                                       executor=executor)

    core.setup_collectors("tcpdump_{}".format(attach_type))


@logged_keyword
def start_tcp_dump(attach_type):
    core.start_collectors("tcpdump_{}".format(attach_type))


@logged_keyword
def stop_and_collect_tcp_dump(file_dir, attach_type):
    core.stop_collectors("tcpdump_{}".format(attach_type))
    core.collect_collectors("tcpdump_{}".format(attach_type), target_dir=file_dir)
    core.teardown_collectors("tcpdump_{}".format(attach_type))


@logged_keyword
def check_attach_msg_sequence_present(pdml_file, cell_info, attach_type=None):
    if attach_type == "NSA":
        pdml.check_msc(file_name=pdml_file, field_name_list=['x2ap'],
                       message_sequence='SgNBAdditionRequest.*'
                                        'SgNBAdditionRequestAcknowledge.*'
                                        'SgNBReconfigurationComplete.*'
                                        'SNStatusTransfer.*')
    elif attach_type == "SA":
        pdml.check_msc(file_name=pdml_file, field_name_list=["ngap"],
                       message_sequence='InitialUEMessage.*'
                                        'InitialContextSetupRequest.*'
                                        'InitialContextSetupResponse.*'
                                        'PDUSessionResourceSetupResponse.*')
    else:
        if cell_info["cell_rat"] == "nr":
            try:
                pdml.check_msc(file_name=pdml_file, field_name_list=['x2ap'],
                               message_sequence='SgNBAdditionRequest.*'
                                                'SgNBAdditionRequestAcknowledge.*'
                                                'SgNBReconfigurationComplete.*'
                                                'SNStatusTransfer.*')

            except AssertionError:
                pdml.check_msc(file_name=pdml_file, field_name_list=["ngap"],
                               message_sequence='InitialUEMessage.*'
                                                'InitialContextSetupRequest.*'
                                                'InitialContextSetupResponse.*'
                                                'PDUSessionResourceSetupResponse.*')

        elif cell_info["cell_rat"] == "lte":
            pdml.check_msc(file_name=pdml_file, field_name_list=["nas-eps"],
                           message_sequence='.*Attach request.*'
                                            '.*Attach accept.*'
                                            '.*Attach complete.*')


@logged_keyword
def check_pdu_session_established(pdml_file, cell_info, attach_type="NSA"):
    if cell_info["cell_rat"] == "nr":
        if attach_type == "NSA":
            pdml.check_msc(file_name=pdml_file, field_name_list=["nas-eps"],
                           message_sequence='.*Attach complete.*')
        elif attach_type == "SA":
            pdml.check_msc(file_name=pdml_file, field_name_list=["ngap"],
                           message_sequence='PDUSessionResourceSetupResponse.*')


@logged_keyword
def convert_pcap_to_pdml(pcap_file):
    os.system("tshark -T pdml -r {} > {}.xml".format(pcap_file, pcap_file.split(".pcap")[0]))
    pdml_file = "{}.xml".format(pcap_file.split(".pcap")[0])
    return pdml_file


@logged_keyword
def verify_proper_eutran_cell_id_attach(cell_id, pdml_file):
    pdml_entries = PdmlReader.from_file(pdml_file)
    for entry in pdml_entries:
        if "UplinkNASTransport" in entry.packet:
            eutran_id = entry.packet["s1ap.CellIdentity"].show
            assert int(eutran_id, 16) == int(cell_id)


@logged_keyword
def verify_proper_pci_attach(pci, pdml_file):
    pdml_entries = PdmlReader.from_file(pdml_file)
    for entry in pdml_entries:
        if "SgNBAdditionRequest" in entry.packet:
            attach_pci = entry.packet["nr-rrc.physCellId"].show
            assert attach_pci == pci
        elif "UEContextModificationResponse" in entry.packet:
            if "nr-rrc.physCellId" in entry.packet:
                attach_pci = entry.packet["nr-rrc.physCellId"].show
                assert attach_pci == pci


@logged_keyword
def verify_proper_cell_id_attach(cell_info, pdml_file):
    if "lte" in cell_info["cell_rat"]:
        verify_proper_eutran_cell_id_attach(cell_info["eutraCelId"], pdml_file)
    elif "nr" in cell_info["cell_rat"]:
        verify_proper_pci_attach(cell_info["physicalCellId"], pdml_file)


@logged_keyword
def detach_ue(ue_alias):
    try:
        ue.detach_ue(ue_alias)
    except Exception as e:
        print(e)


@logged_keyword
def attach_ue(ue_alias):
    ue.attach_ue(ue_alias)


@logged_keyword
def try_to_attach_ue(cell_id, cell_info, cell_mapping_per_att_port):
    try:
        attach_and_verify(cell_id, cell_info, cell_mapping_per_att_port)
    except Exception as e:
        detach_ue()
        raise


@logged_keyword
def try_to_attach_multiple_ues(cell_id, cell_info, cell_mapping_per_att_port):
    try:
        verify_attach_for_multiple_ues(cell_id, cell_info, cell_mapping_per_att_port)
    except Exception as e:
        detach_ues()
        raise


@logged_keyword
def attach_and_verify(cell_id, cell_info, cell_mapping_per_att_port):
    robot_logger("Verifing attach for Cell : {}".format(cell_id), "info")
    detach_ue()
    create_tcpdump_collector("CELL_{}_attach.pcap".format(cell_id))
    start_tcp_dump()
    time.sleep(10)
    _attenuator.set_attenuation(get_cell_mapped_port(cell_id, cell_mapping_per_att_port), "0dB")
    time.sleep(5)
    attach_ue()
    target_dir = os.path.join(
        get_robot_variable("LOG_PATH").replace(" ", "_"),
        get_robot_variable("TEST_NAME").replace(" ", "_"),
        "Loop_{}".format(get_robot_variable("i")))
    time.sleep(30)
    stop_and_collect_tcp_dump(target_dir)
    pdml_file = convert_pcap_to_pdml("{}/tcpdump/CELL_{}_attach.pcap".format(target_dir, cell_id))
    check_attach_msg_sequence_present(pdml_file, cell_info)
    check_pdu_session_established(pdml_file, cell_info)
    verify_proper_cell_id_attach(cell_info, pdml_file)


@logged_keyword
def verify_dl_data_transfer():
    ue.start_data_transfer(dt_name="ASUS_DT", ue_alias="ASUS", direction='dl',
                           duration='660s', throughput="300Mbits/sec", packet_size='1400')
    ue.start_data_transfer(dt_name="SAMSUNG_S23_DT", ue_alias='SAMSUNG_S23', direction='dl',
                           duration='660s', throughput="300Mbits/sec", packet_size='1400')
    time.sleep(10)
    ue.check_data_transfer_is_alive(dt_name="ASUS_DT")
    ue.check_data_transfer_is_alive(dt_name="SAMSUNG_S23_DT")
    robot_logger("Waiting 3 minutes for data transfer to finish", "info")
    time.sleep(180)
    time.sleep(20)
    robot_logger("Checking if data Transfer is alive after 3 minutes", "info")
    ue.check_data_transfer_is_alive(dt_name="ASUS_DT")
    ue.check_data_transfer_is_alive(dt_name="SAMSUNG_S23_DT")
    robot_logger("Getting data transfer statistics", "info")
    print(ue.get_data_transfer_statistics(dt_name="ASUS_DT"))
    print(ue.get_data_transfer_statistics(dt_name="SAMSUNG_S23_DT"))
    ue.stop_data_transfer(dt_name="ASUS_DT")
    ue.stop_data_transfer(dt_name="SAMSUNG_S23_DT")


@logged_keyword
def attach_test(dependent_cells=None, remote=False):
    cell_mapping_per_att_port = get_robot_variable("LOCAL_CELL_PER_ATT_PORT_MAPPING")
    if remote:
        cell_mapping_per_att_port = get_robot_variable("REMOTE_CELL_PER_ATT_PORT_MAPPING")
    attach_test_results = {}
    cells_dict = get_cells_info_for_attach_verification(cell_mapping_per_att_port, remote)
    if dependent_cells is not None:
        cells_dict = remove_not_dependent_cells(cells_dict, get_cells_global_id(dependent_cells))
    if not cells_dict:
        robot_logger("None of dependent cells have been mapped to attenuator port", "warn")
        return None
    try:
        get_ue("ASUS", ["ASUS"])
        get_ue("SAMSUNG_S23", ["SAMSUNG_S23"])
        initialize_attenuator()
        for cell_id, cell_info in cells_dict.items():
            cell_result = {}
            try:
                robot_logger("ATT 0db", "info")
                wait_until_kw_succeeds("3 times", "2", try_to_attach_multiple_ues, cell_id, cell_info,
                                       cell_mapping_per_att_port)
                cell_result["Attach Result"] = "Passed"
                robot_logger("Verifying data transfer for Cell :{}".format(cell_id), "info")
                verify_dl_data_transfer()
                cell_result["Traffic Flow Result"] = "Passed"
            except Exception as verification_exception:
                if cell_result.get("Attach Result") == "Passed":
                    cell_result["Traffic Flow Result"] = "Failed"
                    robot_logger("Traffic Flow verification failed for CellId: {}".format(cell_id), "error")
                else:
                    cell_result["Attach Result"] = "Failed"
                robot_logger("Reason of verification fail: /n{}".format(verification_exception), "info",
                             log_to_console=False)
            finally:
                attach_test_results[cell_id] = cell_result
                _attenuator.set_attenuation_for_all_cells("90dB")
                detach_ue()
    except Exception as e:
        print(e)
    finally:
        release_attenuator()
        ue.stop_using_ue("ASUS")
        ue.stop_using_ue("SAMSUNG_S23")
    if any("Failed" == result for cell_results in attach_test_results.values() for result in cell_results.values()):
        robot_logger("Attach verification failed! Result : \n{}".format(json.dumps(attach_test_results, indent=4)),
                     "error")
        raise AttachVerificationFail()


@logged_keyword
def get_cell_mapped_port(cell_id, ports_mapping):
    for ports, cells in ports_mapping.items():
        if cell_id in cells:
            return ports


@logged_keyword
def get_ue(ue_alias, capabilities_list):
    try:
        ue.require_ue(ue_alias, capabilities_list)
    except AliasAlreadyAssignedError:
        robot_logger("UE Already required, reusing same UE as in previous test.", "info")


def get_cells_global_id(dict_of_cell_distnames_per_type):
    admin_connection = get_admin_connection()
    global_cell_id_list = [admin.get_cell_specific_info(cell, connection=admin_connection)["globalCellId"]
                           for cell_type in dict_of_cell_distnames_per_type.keys()
                           for cell in dict_of_cell_distnames_per_type[cell_type]
                           if cell_type == "NRCEL" or cell_type == "LNCEL"]
    return global_cell_id_list


def get_eutran_cell_id_per_pci(lncels_info_dict, pci):
    for cell in lncels_info_dict:
        if cell['physicalCellId'] == str(pci):
            return cell['eutranCellId']


def get_cells_info_for_attach_verification(cell_mapping_per_att_port, remote=False):
    admin_connection = get_admin_connection(remote)
    cells_per_rat_list = admin.get_cell_list(connection=admin_connection)["cells"]
    cells_parameters_list = [cell for cell_type in CELL_TYPES.values() for cell in
                             admin.get_parameters_for_all(cell_type, connection=admin_connection)]
    cells = {cell["globalCellId"]: {"physicalCellId": str(cell["physicalCellId"]),
                                    "cell_rat": rat,
                                    **get_rat_identity(cell, cells_parameters_list),
                                    "internalId": cell["id"]["internal"]}
             for rat in cells_per_rat_list.keys() for cell in cells_per_rat_list[rat]}
    mapped_cells = {cell: cell_info for cell, cell_info in cells.items()
                    if any(int(cell) in cell_list for cell_list in cell_mapping_per_att_port.values())}
    return mapped_cells


def get_rat_identity(cell_info, cells_parameters_list):
    for cell_params in cells_parameters_list:
        if cell_params["id"] == cell_info["id"]["internal"]:
            cell_parameters = cell_params
    if cell_parameters.get("nrCellIdentity") is not None:
        return {"nrCellIdentity": str(cell_parameters.get("nrCellIdentity"))}
    elif cell_parameters.get("eutraCelId") is not None:
        return {"eutraCelId": str(cell_parameters.get("eutraCelId"))}
    raise Exception


@logged_keyword
def remove_not_dependent_cells(cells_dict, dependent_cells_list):
    dependent_cells_list = [str(cell) for cell in dependent_cells_list]
    return {cell: cell_info for cell, cell_info in cells_dict.items() if str(cell) in dependent_cells_list}


@logged_keyword
def get_ues():
    for single_ue in ues_list:
        ue.require_ue(ue_alias=single_ue, capabilities=single_ue)


@logged_keyword
def attach_ues(ues=ues_list):
    for single_ue in ues:
        robot_logger("Performing attach command on {}".format(single_ue), "info", log_to_console=False)
        ue.attach_ue(single_ue)


@logged_keyword
def release_ues():
    robot_logger("Performing release command", "info", log_to_console=True)

    for single_ue in ues_list:
        robot_logger("Performing release command on {}".format(single_ue), "info", log_to_console=False)
        try:
            ue.stop_using_ue(single_ue)
        except Exception:
            pass


@logged_keyword
def detach_ues():
    robot_logger("Performing detach command", "info", log_to_console=True)

    for single_ue in ues_list:
        robot_logger("Performing detach command on {}".format(single_ue), "info", log_to_console=False)
        try:
            ue.detach_ue(single_ue)
        except Exception:
            pass


@logged_keyword
def verify_attach_for_multiple_ues(cell_id, cell_info, cell_mapping_per_att_port):
    robot_logger("Verifing attach for Cell : {}".format(cell_id), "info")
    detach_ues()
    create_tcpdump_collectors(cell_id)
    start_tcpdump_collectors()
    time.sleep(10)
    lte_cell = get_robot_variable('LTE_CELL_FOR_NSA')
    _attenuator.set_attenuation(get_cell_mapped_port(cell_id, cell_mapping_per_att_port), "0dB")
    time.sleep(10)
    attach_ues(get_robot_variable('SA_UES'))
    if lte_cell:
        _attenuator.set_attenuation(lte_cell, "0dB")
        time.sleep(15)
    attach_ues(get_robot_variable('NSA_UES'))
    target_dir = os.path.join(
        get_robot_variable("LOG_PATH").replace(" ", "_"),
        get_robot_variable("TEST_NAME").replace(" ", "_"),
        "Loop_{}".format(get_robot_variable("i", "Test")))
    time.sleep(30)
    collect_tcpudmps(target_dir)
    time.sleep(5)
    nsa_pdml_file = convert_pcap_to_pdml(f"{target_dir}/tcpdump_NSA/CELL_{cell_id}_NSA_attach.pcap")
    sa_pdml_file = convert_pcap_to_pdml(f"{target_dir}/tcpdump_SA/CELL_{cell_id}_SA_attach.pcap")
    attach_results = {"NSA": verify_attach(nsa_pdml_file, cell_info, cell_id, "NSA"),
                      "SA": verify_attach(sa_pdml_file, cell_info, cell_id, "SA")}
    robot_logger(f"Attach results for {cell_id} :{attach_results}", "info")
    if "failed" in attach_results.values():
        raise AttachVerificationFail


@logged_keyword
def create_tcpdump_collectors(cell_id):
    create_tcpdump_collector("CELL_{}_NSA_attach.pcap".format(cell_id), attach_type="NSA")
    create_tcpdump_collector("CELL_{}_SA_attach.pcap".format(cell_id), attach_type="SA")


@logged_keyword
def start_tcpdump_collectors():
    start_tcp_dump("NSA")
    start_tcp_dump("SA")


def collect_tcpudmps(target_directory):
    stop_and_collect_tcp_dump(target_directory, "NSA")
    stop_and_collect_tcp_dump(target_directory, "SA")


@logged_keyword
def verify_attach(pdml_file, cell_info, cell_id, attach_type):
    try:
        check_attach_msg_sequence_present(pdml_file, cell_info, attach_type)
        check_pdu_session_established(pdml_file, cell_info, attach_type)
        verify_proper_cell_id_attach(cell_info, pdml_file)
        return "passed"
    except Exception as attach_exception:
        robot_logger("Attach failed: \ncell: {}\nattach type: {} \n Reason: {}".format(cell_id, attach_type,
                                                                                       attach_exception), "error")
        return "failed"


@logged_keyword
def verify_tput_for_multiple_ues():
    robot_logger("Starting Tput Verification")
    tput_duration = int(get_robot_variable("TPUT_DURATION"))
    start_data_transfer_for_all_ues()
    time.sleep(10)
    check_dt_is_alive_all_ues()
    robot_logger("Waiting {} minutes for data transfer to finish".format(tput_duration / 60), "info")
    time.sleep(tput_duration)
    check_dt_is_alive_all_ues()
    get_data_statistics_for_all_ues()
    stop_data_transfer_for_all_ues()


@logged_keyword
def start_data_transfer_for_all_ues():
    tput_duration = int(get_robot_variable("TPUT_DURATION")) + 30
    for single_ue in ues_list:
        robot_logger("Starting dt for {}".format(single_ue), log_to_console=True)
        ue.start_data_transfer(dt_name="DT_{}".format(single_ue), ue_alias=single_ue, direction='dl',
                               duration='{}s'.format(tput_duration), throughput="300Mbits/sec", packet_size='1400')


@logged_keyword
def check_dt_is_alive_all_ues():
    for single_ue in ues_list:
        robot_logger("Checking if dt is alive for {}".format(single_ue), log_to_console=False)
        ue.check_data_transfer_is_alive(dt_name="DT_{}".format(single_ue))


@logged_keyword
def get_data_statistics_for_all_ues():
    for single_ue in ues_list:
        robot_logger("Getting dt statictics for {}".format(single_ue), log_to_console=False)
        print(ue.get_data_transfer_statistics(dt_name="DT_{}".format(single_ue)))


@logged_keyword
def stop_data_transfer_for_all_ues():
    for single_ue in ues_list:
        robot_logger("Stopping dt for {}".format(single_ue), "info", log_to_console=False)
        ue.stop_data_transfer(dt_name="DT_{}".format(single_ue))


@logged_keyword
def get_cells_mapping(remote=False):
    cell_mapping_per_att_port = get_robot_variable("LOCAL_CELL_PER_ATT_PORT_MAPPING")
    if remote:
        cell_mapping_per_att_port = get_robot_variable("REMOTE_CELL_PER_ATT_PORT_MAPPING")
    return cell_mapping_per_att_port


@logged_keyword
def get_cells_for_attach(remote=False):
    cell_mapping_per_att_port = get_robot_variable("LOCAL_CELL_PER_ATT_PORT_MAPPING")
    if remote:
        cell_mapping_per_att_port = get_robot_variable("REMOTE_CELL_PER_ATT_PORT_MAPPING")
    cells_dict = get_cells_info_for_attach_verification(cell_mapping_per_att_port, remote)
    return cells_dict


def attach_test_multiple_ues(dependent_cells=None, remote=False):
    robot_logger(f"Dependent Cells List: {dependent_cells}")
    cells_dict = get_cells_for_attach(remote)
    if not cells_dict:
        robot_logger("None of dependent cells have been mapped to attenuator port", "warn")
        return
    attach_test_results = {}
    try:
        get_ues()
        initialize_attenuator()
        if not hasattr(attach_test_multiple_ues, 'ues_rebooted') and get_robot_variable('ADB_REBOOT', None):
            reboot_ues()
            attach_test_multiple_ues.ues_rebooted = True
        robot_logger("Starting attach procedure...", "info")
        for cell_id, cell_info in cells_dict.items():
            robot_logger(str(cell_id), "info")
            cell_result = {}
            try:
                wait_until_kw_succeeds("3 times", "2", try_to_attach_multiple_ues, cell_id, cell_info,
                                       get_cells_mapping(remote))
                cell_result["Attach Result"] = "Passed"
                robot_logger("Verifying data transfer for Cell :{}".format(cell_id), "info")
                verify_tput_for_multiple_ues()
                cell_result["Traffic Flow Result"] = "Passed"
            except Exception as verification_exception:
                if cell_result.get("Attach Result") == "Passed":
                    cell_result["Traffic Flow Result"] = "Failed"
                    robot_logger("Traffic Flow verification failed for CellId: {}".format(cell_id), "error")
                else:
                    cell_result["Attach Result"] = "Failed"
                robot_logger("Reason of verification fail: /n{}".format(verification_exception), "info",
                             log_to_console=False)
            finally:
                attach_test_results[cell_id] = cell_result
                _attenuator.set_attenuation_for_all_cells("90dB")
                detach_ues()
                robot_logger("Cell {} Results : {}".format(cell_id, json.dumps(cell_result, indent=4)), "info")
    except Exception as e:
        print(e)
    finally:
        release_attenuator()
        release_ues()
    robot_logger("Attach Test Results :\n{}".format(json.dumps(attach_test_results, indent=4)), "info")
    if any("Failed" == result for cell_results in attach_test_results.values() for result in cell_results.values()):
        robot_logger("Attach verification failed! Result : \n{}".format(json.dumps(attach_test_results, indent=4)),
                     "error")
        raise AttachVerificationFail()


def reboot_ues(timeout=60):
    @wait_until_function_succeeds(timeout=timeout, interval=10, console=False)
    def __get_adb_devices(host_connection, serial_numbers):
        output = host_connection.execute_command('adb devices')
        assert all([sn in output for sn in serial_numbers])

    with _cm.uepc_connection(autoconnect=False) as connection:
        serial_numbers = []
        for ue_name in ues_list:
            sn = _tl_conf.yaml['UE_POOLS']['AndroidUePool']['inline_config'][ue_name]['CONSTRUCTOR_PARAMETERS'][
                'serial_number']
            robot_logger('Rebooting UE {}'.format(ue_name), 'info')
            connection.send_command('adb -s {} reboot'.format(sn))
            serial_numbers.append(sn)
        time.sleep(60)
        __get_adb_devices(host_connection=connection, serial_numbers=serial_numbers)
        robot_logger('UES rebooted successfully', 'info')


def check_nsa_samsung():
    get_ue("SAMSUNG_S23", ["SAMSUNG_S23"])
    try:
        attach_ue("SAMSUNG_S23")
        time.sleep(10)
        robot_logger("Start")
        ue.start_data_transfer(dt_name="SAMSUNG_S23DT", ue_alias='SAMSUNG_S23', direction='dl',
                               duration='660s', throughput="600Mbits/sec", packet_size='1400')
        time.sleep(10)
        ue.check_data_transfer_is_alive(dt_name="SAMSUNG_S23DT")
        robot_logger("Waiting 3 minutes for data transfer to finish", "info")
        time.sleep(20)
        robot_logger("Checking if data Transfer is alive after 3 minutes", "info")
        ue.check_data_transfer_is_alive(dt_name="SAMSUNG_S23DT")
    finally:
        detach_ue("SAMSUNG_S23")
        ue.stop_data_transfer("SAMSUNG_S23DT")


def robot_logger(msg, log_level="INFO", log_to_console=True):
    now = time.strftime("%H:%M:%S")
    if log_level.upper() == "INFO":
        BuiltIn().log(f"[ {log_level.upper()} ] {now} - {msg}", level=log_level.upper(),
                      console=log_to_console)
    elif log_level.upper() == "WARN" or log_level.upper() == "ERROR":
        BuiltIn().log(f"{now} - {msg}", level=log_level.upper(), console=False)


@logged_keyword
def get_admin_connection(remote=False):
    if remote:
        admin_connection = get_robot_variable("REMOTE_ADMIN")
    else:
        admin_connection = get_robot_variable("LOCAL_ADMIN")
    try:
        admin.get_sw_version(connection=admin_connection, timeout=60)
    except Exception as e:
        try:
            robot_logger("Getting sw failed due to {} trying to resetup connection".format(e), "info",
                         log_to_console=False)
            admin.teardown_admin("remote_admin" if remote else "local_admin")
            admin_connection = wait_until_kw_succeeds(900, 10, setup_new_admin_connection, remote)
        except Exception as e:
            robot_logger(e, "debug", log_to_console=False)
            admin_connection = wait_until_kw_succeeds(900, 10, setup_new_admin_connection, remote)
    return admin_connection


def run_kw(keyword_name, *args, **kwargs):
    arguments = [arg for arg in args]
    key_args = [
        "{}=${{{}}}".format(kwarg, _project_robot_var_type(keyword_name, kwarg, value)) if not isinstance(
            value, str) else f"{kwarg}={value}" for kwarg, value in kwargs.items()]
    arguments.extend(key_args)
    return BuiltIn().run_keyword(keyword_name, *arguments)


@logged_keyword
def setup_new_admin_connection(remote=False):
    if remote:
        remote_vm = get_robot_variable("REMOTE_VM_IP")
        admin_connection = admin.setup_admin(update_interval=500, remote_host=remote_vm, alias="remote_admin")
        BuiltIn().set_test_variable("${REMOTE_ADMIN}", admin_connection)
    else:
        admin_connection = admin.setup_admin(update_interval=500, alias="local_admin")
        BuiltIn().set_test_variable("${LOCAL_ADMIN}", admin_connection)
    return admin_connection


def _project_robot_var_type(function_name, arg_name, value):
    temp_arg_name = f"{function_name}_{arg_name}"
    set_robot_test_variable(temp_arg_name, value)
    return temp_arg_name


def wait_until_kw_succeeds(retry, retry_interval, function, *args, **kwargs):
    arguments = [arg for arg in args]
    key_args = [
        "{}=${{{}}}".format(kwarg, _project_robot_var_type(function.__name__, kwarg, value)) if not isinstance(
            value, str) else "{}={}".format(kwarg, value) for kwarg, value in kwargs.items()]
    arguments.extend(key_args)
    func = ".".join([get_module_name(function), function.__name__])
    return BuiltIn().wait_until_keyword_succeeds(retry, retry_interval, func, *arguments)


def get_module_name(function):
    module_file = _get_file_name(function)
    imported_libs = BuiltIn().get_library_instance(all=True)
    for lib, lib_path in imported_libs.items():
        if module_file.lower() in str(lib_path).lower():
            return lib
    BuiltIn().import_library(inspect.getabsfile(function), "WITH NAME", module_file)
    return module_file


def _get_file_name(function):
    if function.__closure__ is not None:
        function = function.__closure__[0].cell_contents
    if inspect.isfunction(function) or inspect.ismethod(function):
        return inspect.getfile(function).split("/")[-1].strip(".py")
