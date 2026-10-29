import json
import os
import time
from robot.api import logger
from ta_attenuator import ta_attenuator
from taf.collectors.tcpdump import tcpdump
from taf.collectors.core import core
from taf.analyzer.pdml import PdmlReader, pdml
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_utilities import (
    robot_kw,
    robot_logger,
    robot_var,
)
from time import sleep
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from ute_common_abstract_core.exceptions import AliasAlreadyAssignedError
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_variables import CELL_TYPES
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_utilities import (
    robot_logger,
    robot_kw,
    wait_until_kw_succeeds,
)


_attenuator = ta_attenuator()
ue = BuiltIn().get_library_instance("ute_ue")
core = core()
local = " local connection"
admin = admin()


class AttachVerificationFail(Exception):
    pass


@robot_kw
def get_admin_connection(remote=False):
    """
    Parameters
    ----------
    remote : `bool`
        Flag indicating whether a remote site is being used

     Returns
    -------
        Existing connection to admin or calls setup_new_admin_connection function

    """
    if remote:
        admin_connection = robot_var("REMOTE_ADMIN")
    else:
        admin_connection = robot_var("LOCAL_ADMIN")
    try:
        admin.get_sw_version(connection=admin_connection, timeout=60)
    except Exception as e:
        try:
            robot_logger(
                "Getting sw failed due to {} trying to resetup connection".format(e),
                "info",
                log_to_console=False,
            )
            admin.teardown_admin("remote_admin" if remote else "local_admin")
            admin_connection = wait_until_kw_succeeds(
                900, 10, setup_new_admin_connection, remote
            )
        except Exception as e:
            robot_logger(e, "debug", log_to_console=False)
            admin_connection = wait_until_kw_succeeds(
                900, 10, setup_new_admin_connection, remote
            )
    return admin_connection


@robot_kw
def setup_new_admin_connection(remote=False):
    """
    Parameters
    ----------
    remote : `bool`
        Flag indicating whether a remote site is being used

     Returns
    -------
        Created connection to admin

    """
    if remote:
        remote_vm = robot_var("REMOTE_VM_IP")
        admin_connection = admin.setup_admin(
            update_interval=500, remote_host=remote_vm, alias="remote_admin"
        )
        BuiltIn().set_test_variable("${REMOTE_ADMIN}", admin_connection)
    else:
        admin_connection = admin.setup_admin(update_interval=500, alias="local_admin")
        BuiltIn().set_test_variable("${LOCAL_ADMIN}", admin_connection)
    return admin_connection


@robot_kw
def attach_test(dependent_cells=None, remote=False):
    """
    Function used to attach UE and its verification

    Parameters
    ----------
    dependent_cells: dict
        Include dict with cell id and cell info

    remote : `bool`
        Flag indicating whether a remote site is being used

    """
    cell_mapping_per_att_port = robot_var("LOCAL_CELL_PER_ATT_PORT_MAPPING")
    if remote:
        cell_mapping_per_att_port = robot_var("REMOTE_CELL_PER_ATT_PORT_MAPPING")
    attach_test_results = {}
    cells_dict = get_cells_info_for_attach_verification(
        cell_mapping_per_att_port, remote
    )
    if dependent_cells is not None:
        cells_dict = remove_not_dependent_cells(
            cells_dict, get_cells_global_id(dependent_cells)
        )
        logger.console("DEPENDENTS CELL IS NOT NONE")
    if not cells_dict:
        robot_logger(
            "None of dependent cells have been mapped to attenuator port", "warn"
        )
        return None
    try:
        get_ue("UE_1", ["REAL_ANDROID_UE"])
        initialize_attenuator()
        for cell_id, cell_info in cells_dict.items():
            cell_result = {}
            mapped_port = get_cell_mapped_port(cell_id, cell_mapping_per_att_port)
            try:
                robot_logger("ATT 0db", "info")
                _attenuator.set_attenuation(mapped_port, "0dB")
                sleep(60)
                attach_and_verify(cell_id, cell_info)
                cell_result["Attach Result"] = "Passed"
                robot_logger(
                    "Verifying data transfer for Cell :{}".format(cell_id), "info"
                )
                verify_dl_data_transfer()
                cell_result["L3 Call Result"] = "Passed"
            except Exception as verification_exception:
                cell_result["Attach Result"] = "Failed"
                if cell_result.get("Attach Result") == "Passed":
                    cell_result["L3 Call Result"] = "Failed"
                    robot_logger(
                        "L3 Call verification failed for CellId: {}".format(cell_id),
                        "error",
                    )
                robot_logger(
                    "Reason of verification fail: /n{}".format(verification_exception),
                    "info",
                    log_to_console=False,
                )
            finally:
                attach_test_results[cell_id] = cell_result
                _attenuator.set_attenuation_for_all_cells("90dB")
                detach_ue()
    except Exception as e:
        print(e)
    finally:
        release_attenuator()
        ue.stop_using_ue("UE_1")
    if any(
        "Failed" == result
        for cell_results in attach_test_results.values()
        for result in cell_results.values()
    ):
        robot_logger(
            "Attach verification failed! Result : \n{}".format(
                json.dumps(attach_test_results, indent=4)
            ),
            "error",
        )
        raise AttachVerificationFail()


def get_cells_info_for_attach_verification(cell_mapping_per_att_port, remote=False):
    """
    Function mapping cells

    Parameters
    ----------
    remote : `bool`
        Flag indicating whether a remote site is being used

     Returns
    -------
        Dict with mapped cells

    """
    admin_connection = get_admin_connection(remote)
    cells_per_rat_list = admin.get_cell_list(connection=admin_connection)["cells"]
    cells_parameters_list = [
        cell
        for cell_type in CELL_TYPES.values()
        for cell in admin.get_parameters_for_all(cell_type, connection=admin_connection)
    ]
    cells = {
        cell["globalCellId"]: {
            "physicalCellId": str(cell["physicalCellId"]),
            "cell_rat": rat,
            **get_rat_identity(cell, cells_parameters_list),
            "internalId": cell["id"]["internal"],
        }
        for rat in cells_per_rat_list.keys()
        for cell in cells_per_rat_list[rat]
    }
    mapped_cells = {cell: cell_info for cell, cell_info in cells.items()}
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


@robot_kw
def remove_not_dependent_cells(cells_dict, dependent_cells_list):
    dependent_cells_list = [str(cell) for cell in dependent_cells_list]
    return {
        cell: cell_info
        for cell, cell_info in cells_dict.items()
        if str(cell) in dependent_cells_list
    }


@robot_kw
def get_ue(ue_alias, capabilities_list):
    """
    Function that reserve UE for L3 test

    Parameters
    ----------
    ue_alias : str
        UE alias

    capabilities_list : str
        List with capabilities meeting the requirements

    """
    try:
        ue.require_ue(ue_alias, capabilities_list)
    except AliasAlreadyAssignedError:
        robot_logger(
            "UE Already required, reusing same UE as in previous test.", "info"
        )


@robot_kw
def attach_ue(timeout="160"):
    ue.attach_ue("UE_1", timeout)


def ue_reboot(alias="UE_1", timeout=200):
    get_ue(alias, ["REAL_ANDROID_UE"])
    ue.reboot_ue(alias, timeout)
    ue.stop_using_ue(alias)


@robot_kw
def detach_ue():
    try:
        ue.detach_ue("UE_1")
    except Exception as e:
        print(e)


def get_cells_global_id(dict_of_cell_distnames_per_type):
    admin_connection = get_admin_connection()
    global_cell_id_list = [
        admin.get_cell_specific_info(cell, connection=admin_connection)["globalCellId"]
        for cell_type in dict_of_cell_distnames_per_type.keys()
        for cell in dict_of_cell_distnames_per_type[cell_type]
        if cell_type == "NRCEL" or cell_type == "LNCEL"
    ]
    return global_cell_id_list


@robot_kw
def release_attenuator():
    _attenuator.set_attenuation_for_all_cells("90dB")
    _attenuator.release_attenuator_cell(
        list(_attenuator.cells_pool.cells_registry.keys())
    )


@robot_kw
def initialize_attenuator():
    yaml_file = robot_var("ABSTRACT_LIB_CONFIG")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells("90dB")
    sleep(2)


@robot_kw
def get_cell_mapped_port(cell_id, ports_mapping):
    cell_id = str(cell_id)
    for cells, ports in ports_mapping.items():
        if cell_id in cells:
            return int(cell_id)


@robot_kw
def verify_dl_data_transfer():
    ue.start_data_transfer(
        dt_name="DL",
        ue_alias="UE_1",
        direction="dl",
        duration="60s",
        throughput="300Mbits/sec",
        packet_size="1400",
    )
    sleep(10)
    robot_logger("Check if data transfer is alive", "info")
    ue.check_data_transfer_is_alive(dt_name="DL")
    robot_logger("Waiting 3 minutes for data transfer to finish", "info")
    time.sleep(180)
    robot_logger("Checking if data Transfer is alive after 3 minutes", "info")
    ue.check_data_transfer_is_alive(dt_name="DL")
    ue.stop_data_transfer("DL")
    robot_logger("Getting data transfer statistics", "info")
    ue.get_data_transfer_statistics(dt_name="DL")


@robot_kw
def attach_and_verify(cell_id, cell_info):
    robot_logger("Verifing attach for Cell : {}".format(cell_id), "info")
    detach_ue()
    create_tcpdump_collector("CELL_{}_attach.pcap".format(cell_id))
    robot_logger("Start tcp dump", "info")
    start_tcp_dump()
    robot_logger("Sleep 10s", "info")
    sleep(10)
    robot_logger("attach_ue", "info")
    attach_ue()
    target_dir = os.path.join(
        robot_var("OUTPUT_DIR").replace(" ", "_"),
        robot_var("SUITE_NAME").replace(" ", "_"),
        robot_var("TEST_NAME").replace(" ", "_"),
    )
    sleep(10)
    stop_and_collect_tcp_dump(target_dir)
    pdml_file = convert_pcap_to_pdml(
        "{}/tcpdump/CELL_{}_attach.pcap".format(target_dir, cell_id)
    )
    check_attach_msg_sequence_present(pdml_file, cell_info)
    verify_proper_cell_id_attach(cell_info, pdml_file)


@robot_kw
def start_tcp_dump():
    core.start_collectors("tcpdump")


@robot_kw
def stop_and_collect_tcp_dump(file_dir):
    core.stop_collectors("tcpdump")
    core.collect_collectors("tcpdump", target_dir=file_dir)
    core.teardown_collectors("tcpdump")


@robot_kw
def create_tcpdump_collector(filename):
    executor = {
        "host": "192.168.255.129",
        "user": "toor4nsn",
        "password": "oZPS0POrRieRtu",
    }
    tcpdump().create_tcpdump_collector(
        name="tcpdump",
        target_file_name=filename,
        options="sctp -i any",
        executor=executor,
    )
    core.setup_collectors("tcpdump")


@robot_kw
def convert_pcap_to_pdml(pcap_file):
    os.system(
        "tshark -T pdml -r {} > {}.xml".format(pcap_file, pcap_file.split(".pcap")[0])
    )
    pdml_file = "{}.xml".format(pcap_file.split(".pcap")[0])
    return pdml_file


@robot_kw
def check_attach_msg_sequence_present(pdml_file, cell_info):
    if cell_info["cell_rat"] == "nr":
        try:
            pdml.check_msc(
                file_name=pdml_file,
                field_name_list=["x2ap"],
                message_sequence="SgNBAdditionRequest.*"
                "SgNBAdditionRequestAcknowledge.*"
                "SgNBReconfigurationComplete.*"
                "SNStatusTransfer.*",
            )
        except AssertionError:
            pdml.check_msc(
                file_name=pdml_file,
                field_name_list=["ngap"],
                message_sequence="InitialUEMessage.*"
                "InitialContextSetupRequest.*"
                "InitialContextSetupResponse.*",
            )
    elif cell_info["cell_rat"] == "lte":
        pdml.check_msc(
            file_name=pdml_file,
            field_name_list=["nas_eps"],
            message_sequence=".*Attach request.*"
            ".*Attach accept.*"
            ".*Attach complete.*",
        )


@robot_kw
def verify_proper_cell_id_attach(cell_info, pdml_file):
    if "lte" in cell_info["cell_rat"]:
        verify_proper_eutran_cell_id_attach(cell_info["eutraCelId"], pdml_file)
    elif "nr" in cell_info["cell_rat"]:
        verify_proper_pci_attach(cell_info["physicalCellId"], pdml_file)


@robot_kw
def verify_proper_eutran_cell_id_attach(cell_id, pdml_file):
    pdml_entries = PdmlReader.from_file(pdml_file)
    for entry in pdml_entries:
        if "UplinkNASTransport" in entry.packet:
            eutran_id = entry.packet["s1ap.CellIdentity"].show
            assert int(eutran_id, 16) == int(cell_id)


@robot_kw
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
