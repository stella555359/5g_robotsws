import os
import time
from contextlib import contextmanager
import json
from pathlib import Path
from datetime import datetime
from pprint import pformat
from typing import Iterator, Optional, Union

from robot.libraries.BuiltIn import BuiltIn, logger
from taf.rfrl.bts.devices.asir import asir_operations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.sw_update import GenericSwUpdate
from taf.sbts.oam.coam.admin import admin
from taf.sbts.oam.coam.admin.facade import AdminConnection
from taf.transport.ssh import ssh
from taf.transport.ssh.connection import Connection
from taf.transport.ssh.session import SSHSession
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations, GnbCellOperations
from taf.config.testline.connection_details import HttpConnectionDetails
from taf.rfrl.utilities.test_config import DefaultFileLocation
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations


class FaultNotFoundException(Exception):
    pass


@contextmanager
def use_admin_connection(bts_host: str = " ", bts_id=0) -> Iterator[AdminConnection]:
    """Context manager for automatically connecting and disconnecting via AdminConnection.

    :return AdminConnection:
    :yield Iterator[AdminConnection]:
    """
    if bts_host == " ":
        bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[int(bts_id)]
        bts_host = bts_instance.oam_ip.v4.split("/")[0]
    api = admin()
    try:
        connection = api.connect_to(bts_host=bts_host, timeout=300)
        yield connection
    finally:
        connection.disconnect()


@contextmanager
def use_ssh_connection(
        hostname: str,
        username: str,
        password: str,
        proxy: Optional[Connection] = None,
        throw_exception: bool = False) -> Iterator[SSHSession]:
    """Context manager for automatically connecting and disconnecting via SSHSession.

    :param str hostname:
    :param str username:
    :param str password:
    :param throw_exception:
    :param Optional[Connection] proxy: # NOTE: TO BE DONE:, defaults to None
    :yield Iterator[SSHSession]:
    """
    ssh_connection = ssh()
    err = None
    if proxy is not None:
        ssh_connection.connect_to(hostname=hostname, username=username, password=password, proxy=proxy)
    else:
        ssh_connection.connect_to(hostname=hostname, username=username, password=password)
    try:
        yield ssh_connection
    except Exception as err:
        logger.console(err)
    finally:
        ssh_connection.disconnect()
        if throw_exception:
            raise err


def get_sw_release_name() -> str:
    """Simple wrapper for fetching active release via m-plane.

    :return str: active release, e.g. 'SBTS24R1'
    """
    with use_admin_connection() as connection:
        active_sw_release_name = connection.get_sw_release_name()
        return active_sw_release_name


def get_sw_version(parse_as_trunk: bool = True) -> str:
    """Simple wrapper for fetching active sw version via m-plane.

    :param bool parse_as_trunk: changes prefix to SBTS00 if set to True, defaults to True
    :return str: active software version, e.g. 'SBTS00_ENB_9999_240418_000007' if parse_as_trunk, otherwise
                                               'SBTS24R3_ENB_9999_240418_000007'
    """
    with use_admin_connection() as connection:
        sw_version = connection.get_sw_version()
        if parse_as_trunk and '9999' in sw_version:
            splitted_sw_version = sw_version.split('_')
            splitted_sw_version[0] = 'SBTS00'
            sw_version = '_'.join(splitted_sw_version)
        return sw_version


def get_snapshot(target_file_name):
    with use_admin_connection() as connection:
        connection.get_snapshot(target_file_name)


def get_mrbts_id(bts="gnb", bts_id=0) -> int:
    """Returns global_bts_id fetched from __init__.py file.

    :return int:
    """
    if bts.lower() == "enb":
        bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).enbs[0]
    else:
        bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[int(bts_id)]
    return bts_instance.global_bts_id


def _get_cells_info(rat_type: str) -> dict:
    """Get cells info as dictionary with PCI as keys and cell ID as value.

    :param str rat_type: 'lte' or 'nr' are allowed
    :return dict: cells info provided as {PCI : CELL_ID}
    """
    cells_info = {}

    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        cells_by_rat = bts_info["cells"][rat_type.lower()]
        cells_info = {
            cell["physicalCellId"]: cell["globalCellId"] for cell in cells_by_rat
        }

    logger.info(f"Cells info with PCI to CELL_ID mapping: {pformat(cells_info)}.")
    return cells_info


def get_cell_id_by_pci(pci: Union[int, str], rat: str = 'nr') -> int:
    """Fetches CELL_ID basing on PCI.

    :param Union[int, str] pci:
    :param str rat: 'nr' or 'lte', defaults to 'nr'
    :return int: cell_id from desired PCI
    """
    pci = int(pci)
    cells_info = _get_cells_info(rat)
    cell_id = cells_info.get(pci)
    if not cell_id:
        logger.warn(f"Cell with pci={pci} does not exist")  # TODO: should we raise an Exception
        #                                                     TODO:if there is no cell with desired PCI?
    return cell_id


def get_cell_pci_by_id(id: Union[int, str], rat: str = 'nr') -> int:
    """Fetches PCI basing on CELL_ID.

    :param Union[int, str] id:
    :param str rat: 'nr' or 'lte', defaults to 'nr'
    :return int: cell_pci from desired id
    """
    id = int(id)
    pci_found = None
    cells_info = _get_cells_info(rat)
    for pci, cell_id in cells_info.items():
        if cell_id == id:
            pci_found = pci
            break
    if not pci_found:
        logger.warn(f"Cell with id={id} does not exist")
    return pci_found


def perform_delta_recommissioning(delta: dict, max_attempts: int = 3):
    with use_admin_connection() as connection:
        delta_file = json.dumps(delta)
        attempt = 1
        err = None
        while attempt <= max_attempts:
            try:
                connection.perform_delta_recommissioning(delta_file=delta_file)
                break
            except AdminApiProcedureFailureException as err:
                if 'CPlane is busy' in repr(err):
                    logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                    logger.debug(repr(err))
                    time.sleep(20)
                    attempt += 1
                    continue
                raise err
        else:
            raise err


def toggle_cells_barred_state(
    rat: str = "nr",
    expected_cell_pci: Optional[int] = None,
    expected_cell_id: Optional[int] = None,
    to_be_barred: bool = True,
    brief: bool = False
):
    """Toggles `cellBarred` parameter to `barred`/`notBarred` state for desired LNCEL/NRCELL.
    If no `expected_cell_pci` is given then all CELLs would have commissioned parameter
    or 'expected_cell_id' (id of LNCEL/NRCELL object) can be set.

    Used for making desired LNCELL able to be attachable by UEs (when cell has `cellBarred` set to `notBarred`).

    :param str rat: desired rat - 'nr' or 'lte'
    :param Optional[int] excepted_cell_pci: defaults to None (if None all CELLs are affected)
    :param Optional[int] excepted_cell_id: defaults to None (if None all NRCELLs are affected)
    :param bool to_be_barred: if True then `barred` is set, otherwise `notBarred`, defaults to True
    :param bool brief: optional info to console about barred cells
    """
    if expected_cell_pci is None:
        expected_cell_id = expected_cell_id
    else:
        expected_cell_id = get_cell_id_by_pci(pci=expected_cell_pci, rat=rat)

    planned_value = {
        True: "barred",
        False: "notBarred"
    }

    delta_cells_barred_state_update = []

    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()

        all_cells = [
            cell["id"].get("configuration")
            for cell in
            bts_info["cells"][rat]
        ]

        sib_0 = "/SIB-0" if rat == "lte" else ""
        if expected_cell_pci or expected_cell_id:
            # change `cellBarred` parameter to `to_be_barred` value for desired LTE CELL,
            # and opposite value for rest of CELL(s).
            for cell_configuration_nidd in all_cells:
                _, cell_id = cell_configuration_nidd.split("/")[-1].split("-")
                cell_barred_delta_parameter_update = {
                    "distName": f"{cell_configuration_nidd}{sib_0}",
                    "operation": "update",
                    "parameters": [
                        {
                            "parameterName": "cellBarred",
                            "value": planned_value[to_be_barred] if str(expected_cell_id) == str(cell_id)
                                else planned_value[not to_be_barred],
                            "operation": "update",
                        }
                    ],
                }
                delta_cells_barred_state_update.append(cell_barred_delta_parameter_update)
        else:  # change `cellBarred` parameter to `to_be_barred` value for all cells
            for cell_configuration_nidd in all_cells:
                cell_barred_delta_parameter_update = {
                    "distName": f"{cell_configuration_nidd}{sib_0}",
                    "operation": "update",
                    "parameters": [
                        {
                            "parameterName": "cellBarred",
                            "value": planned_value[to_be_barred],
                            "operation": "update",
                        }
                    ],
                }
                delta_cells_barred_state_update.append(cell_barred_delta_parameter_update)

    logger.info(f"LNCELL `cellBarred` delta configuration: \n {pformat(delta_cells_barred_state_update)}.")
    if brief:
        for cell in delta_cells_barred_state_update:
            logger.console(f'{cell["distName"] : >42}'
                           + f'  {cell["parameters"][0]["parameterName"]} = {cell["parameters"][0]["value"]}')
    perform_delta_recommissioning(delta_cells_barred_state_update)


def toggle_nr_cells_barred_state(
    expected_cell_pci: Optional[int] = None, to_be_barred: bool = True
):
    """Toggles `cellBarred` parameter to `barred`/`notBarred` state for desired NRCELL.
    If no `expected_cell_pci` is given then all NRCELLs would have commissioned parameter.

    Used for making desired NRCELL able to be attachable by UEs (when cell has `cellBarred` set to `notBarred`).

    :param Optional[int] expected_cell_pci: defaults to None (if None all NRCELLs are affected)
    :param bool to_be_barred: if True then `barred` is set, otherwise `notBarred`, defaults to True
    """
    toggle_cells_barred_state(rat="nr", expected_cell_pci=expected_cell_pci, to_be_barred=to_be_barred)


def toggle_lte_cells_barred_state(
    expected_cell_pci: Optional[int] = None, to_be_barred: bool = True
):
    """Toggles `cellBarred` parameter to `barred`/`notBarred` state for desired LNCELL.
    If no `expected_cell_pci` is given then all NRCELLs would have commissioned parameter.

    Used for making desired LNCELL able to be attachable by UEs (when cell has `cellBarred` set to `notBarred`).

    :param Optional[int] excepted_cell_pci: defaults to None (if None all NRCELLs are affected)
    :param bool to_be_barred: if True then `barred` is set, otherwise `notBarred`, defaults to True
    """
    toggle_cells_barred_state(rat="lte", expected_cell_pci=expected_cell_pci, to_be_barred=to_be_barred)


def get_http_connection_credentials_from_init() -> dict:
    """Get OAM (Web Element Manager) HTTP connection details.

    :return str: dict with all necessary data to connect to WebEM
    """
    bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[0]
    connection_details: HttpConnectionDetails = bts_instance.cu.oam_http_connection_details
    return {
        'addr': connection_details.addr,
        'port': connection_details.port,
        'username': connection_details.username,
        'password': connection_details.password
    }


def download_sw_build(sw_build: str, target_dir: str) -> str:
    """Downloads desired SW build to target directory.

    :param str sw_build: full name for SW Build
    :param str target_dir: full unix path
    :return str: path of downloaded SW build file (with .zip extension)
    """
    generic_sw_update = GenericSwUpdate(bts_type="GNB", comm=GnbCommissioning())
    path_to_sw = generic_sw_update.download_sw_package(
        sw_version=sw_build, target_dir=target_dir
    )
    return path_to_sw


def wait_sw_update_possible(readiness_timeout: int = 600):
    """Waits for SW Update to be possible.
    Wrapper of taf.rfrl.bts.devices.du.sw_update.GenericSwUpdate.wait_sw_update_possible method.

    :param int readiness_timeout: defaults to 600
    """
    generic_sw_update = GenericSwUpdate(bts_type="GNB", comm=GnbCommissioning())
    generic_sw_update.wait_sw_update_possible(readiness_timeout=readiness_timeout)


def update_sw(sw_package_dir: str, timeout: int = 1800):
    """Updates SW.
    Wrapper of taf.rfrl.bts.devices.du.sw_update.GenericSwUpdate.update_software method.

    :param str sw_package_dir: full path for desired SW build (with .zip extension).
    """
    generic_sw_update = GenericSwUpdate(bts_type="GNB", comm=GnbCommissioning())
    generic_sw_update.update_software(sw_package_dir=sw_package_dir, timeout=timeout)


def rollback_sw():
    """Rollbacks SW NOTE: not tested yet"""
    with use_admin_connection() as connection:
        connection.rollback_software(detailed_output=True)


def get_active_asir_scf(path=BuiltIn().get_variable_value("${OUTPUT DIR}"), file_name="ASIR_SCF.xml") -> str:
    """
    Saves active ASIR SCF to file within given path.

    :param str path: path of directory where ASIR SCF should be downloaded
    :param str file_name: file name of downloaded ASIR SCF
    :return str: path to the current SCF file content
    """
    asir_api = asir_operations.GnbAsirHubOperations()
    return asir_api.get_current_scf_file(local_dir_path=path, file_name=file_name)


def get_active_scf(path=BuiltIn().get_variable_value("${OUTPUT DIR}"), file_name="SCF.xml") -> str:
    """
    Saves active WebEM SCF to file within given path.

    :param str path: path of directory where WebEM SCF should be downloaded
    :param str file_name: file name of downloaded WebEM SCF

    :return str: path to the file with current SCF content
    """
    with use_admin_connection() as connection:
        saved_scf_path = connection.get_current_scf_file(
            local_dir_path=path,
            file_name=file_name,
            export_type="configuration"
        )
        logger.debug(f"(traditional) WebEM SCF has been saved in file: '{saved_scf_path}'")
    return saved_scf_path


def perform_asir_commissioning(scf_path: str):
    """
    Performs ASIR commissioning with provided ASIR SCF.

    :param str scf_path: path to SCF file
    """
    asir_api = asir_operations.GnbAsirHubOperations()
    asir_api.perform_asir_commissioning(scf_path=scf_path)


def perform_commissioning(scf_path: str) -> str:
    """
    Performs commissioning with provided SCF.
    :param str scf_path: path to SCF file
    :raises FileNotFoundError:
    :return str: status of commissioning
    """
    if not os.path.isfile(scf_path):
        raise FileNotFoundError(f'SCF file with path {scf_path} do not exists!')

    with use_admin_connection() as connection:
        commissioning_status = connection.perform_commissioning(
            bts_id=0,
            scf_file=scf_path,
            skip_parameter_relation_errors=True
        )
        return commissioning_status


def prepare_delta_for_asir_commissioning(
    asir_dist_name: str,
    parameter: str,
    value: str,
    index: Optional[int] = None,
    operation: str = "update",
):
    """Prepares `delta` for ASIR recommissioning

    :param str asir_dist_name: _description_
    :param str parameter: _description_
    :param str value: _description_
    :param str operation: _description_, defaults to 'update'
    :return _type_: _description_
    """
    delta = [
        {
            "distName": asir_dist_name,
            "parameters": [
                {
                    "operation": operation,
                    "parameterName": parameter,
                    "value": value,
                }
            ],
        }
    ]
    if index is not None:
        delta[0].get("parameters")[0]["index"] = index
    return delta


def update_parameter_of_asir_configuration(
    asir_dist_name: str, parameter: str, value: str, index=None
):
    """
    Updates current ASIR SCF with desired parameter and value on provided object identified by distname.

    :param asir_dist_name: ASIR dist name of object to be changed (should start with ASI-1 as root object)
    :param str parameter: parameter to be changed
    :param str value: value of parameter to be commissioned
    """
    asir_api = asir_operations.GnbAsirHubOperations()

    if index is None:
        delta = prepare_delta_for_asir_commissioning(asir_dist_name=asir_dist_name, parameter=parameter, value=value)
    else:
        delta = prepare_delta_for_asir_commissioning(asir_dist_name=asir_dist_name, parameter=parameter, value=value,
                                                     index=index)

    asir_api.perform_asir_recommissioning(delta=delta)


def perform_parameter_recommissioning(
    dist_name: str,
    parameter: str,
    operation: str,
    value: Union[str, list],
    skip_parameter_relation_errors: bool = False,
    should_activate: bool = True,
    timeout: int = 300
):
    """Wrapper for AdminConnection `perform_parameter_recommissioning`

    Args:
        dist_name (str): Object dist name ie. "MRBTS-1/LNBTS-1/LNMME-0"
        parameter (str): Parameter name ie. "ipAddrPrim"
        operation (str): Parameter operation (update or delete)
        value (Union[str, int]): Parameter value ie. "10.0.1.99" or [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}]
        skip_parameter_relation_errors (bool, optional): Skip parameter relation errors. Defaults to False.
        should_activate (bool, optional): Should automatically activate plan. Defaults to True.
        timeout (int, optional): Time to wait for positive procedure result. Defaults to 300.

        :raises taf.sbts.oam.coam.admin.legacy.exceptions.AdminApiProcedureFailureException: Will be raised if
            recommissioning fails
    """
    with use_admin_connection() as connection:
        result = connection.perform_parameter_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            value=value,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate,
            timeout=timeout
        )
        logger.debug(f"Result of perform_parameter_recommissioning {result}")


def get_commissioning_path_for_test_case(test_case_name: str, scf_type: str = 'scf') -> str:
    """Get path for desired test case.

    :param str feature_name: name of main FR/CNI directory in RAN_PZ_KRK7, ex. CB009792
    :param str test_case_name: name of directory inside SCF_for_desired_TCs/SBTS<xxRx>/, ex. A_02
    :param str scf_type: 'scf'/'asir'/'delta'/'target'
    :raises FileNotFoundError: if there are no configuration file for desired test of desired scf_type of active release
    :return str: SCF file path
    """

    scf_type_filename = {
        'scf': 'SCF.xml',
        'asir': 'ASiR_SCF.xml',
        'delta': 'DELTA.json',
        'target': 'SCF_target.xml',
        'asir_target': 'ASiR_SCF_target.xml'
    }

    desired_scf = scf_type_filename.get(scf_type)

    if not desired_scf:
        raise FileNotFoundError(f'Given SCF type {scf_type} is not supported!')

    current_suite_file = Path(BuiltIn().get_variable_value("${SUITE SOURCE}"))
    current_suite_dir = current_suite_file.parent.absolute()
    active_release = get_sw_release_name()
    scf_file_path = f"{current_suite_dir}/resources/SCF_for_desired_TCs/{active_release}/{test_case_name}/{desired_scf}"

    if not os.path.isfile(scf_file_path):
        raise FileNotFoundError(f'There are no file '
                                f'for TC {test_case_name} for {active_release} of given {scf_type} type!')
    return scf_file_path


def get_pci_for_nrcell_identity(nrcell_identity: str) -> str:
    """Gets NRCELL PCI basing on NRCELL's nrCellIdentity parameter.

    :param str nrcell_identity:
    :raises ValueError: if there are no NRCELL with provided nrcell_identity
    :return str: PCI of desired NRCELL
    """
    with use_admin_connection() as connection:

        nr_subcells_info = connection.get_subcells_info()
        nr_cells_info = connection.get_cells_info(cell_type='nr')

        for nrcellgrp in nr_subcells_info.values():
            for nrcell_id, nrcell in zip(nrcellgrp, nrcellgrp.values()):
                nrcellidentity = nrcell.get('NRCELL_L').get('parameters').get('nrCellIdentity') or \
                                 nrcell.get('NRCELL_R').get('parameters').get('nrCellIdentity')

                if str(nrcell_identity) == str(nrcellidentity):
                    nr_cells_info = connection.get_cells_info(cell_type='nr')
                    desired_cell = [
                        nrcell.get('physicalCellId')
                        for nrcell in nr_cells_info
                        if nrcell.get('id').get('configuration').split('/')[-1] == nrcell_id
                    ]
                    return str(desired_cell[0])
            else:
                raise ValueError('There are no NRCELL with provided identity!')


def has_ue_been_attached_to_propper_nrcell(ue_info: dict, pci: str) -> bool:
    """Checks if UE has been attached to desired cell.
    This method is workaround due to problems with KW `Get UE Info` on some UEs (primarily Quectel).

    :param dict ue_info: dict fetched from KW `Get Ue Info` of taf.ue/ute_ue
    :param str pci: PCI to be checked
    :return bool:
    """
    ue_attached_nrcell_identity = ue_info.get('cell_id')
    ue_attached_nrcell_pci = get_pci_for_nrcell_identity(ue_attached_nrcell_identity)
    return str(pci) == ue_attached_nrcell_pci


def block_cells(cell_list: list[int], ignore_error=False):
    """Blocks all cells from the desired list of cell's IDs.
    All cells from the list have to be in a unblocked state before calling the function.
    :param bool ignore_error: To allow block already blocked cells set ignore_error=True
    :param list[int] cell_list: list of cell's IDs desired to be blocked, use MOC ID
    Usage:
    Block cells    [2,3,6]    ignore_error=True           (MRBTS-xx/NRBTS-xx/NRCELL-2 , NRCELL-3 , LNCEL-6)
    Block cells    [11]                                   (MRBTS-xx/LNBTS-xx/LNCEL-11
    """
    for cell in cell_list:
        try:
            GenericCellOperations().block_cell(cell_id=cell)
        except AdminApiProcedureFailureException as err:
            if ignore_error:
                logger.warn(f"Block cell {cell} failed. Probably blocked already")
            else:
                raise err


def unblock_cells(cell_list: list[int], ignore_error=False):
    """Unblocks all cells from the desired list of cell's IDs.
    All cells from the list have to be in a blocked state before calling the function.
    :param bool ignore_error: To allow unblock already unblocked cells set ignore_error=True
    :param list[int] cell_list: list of cell's IDs desired to be unblocked, use MOC ID
    Usage:
    Unblock cells    [2,3,6]    ignore_error=True           (MRBTS-xx/NRBTS-xx/NRCELL-2 , NRCELL-3 , LNCEL-6)
    Unblock cells    [11]                                   (MRBTS-xx/LNBTS-xx/LNCEL-11
    """
    for cell in cell_list:
        try:
            GenericCellOperations().unblock_cell(cell_id=cell)
        except AdminApiProcedureFailureException as err:
            if ignore_error:
                logger.warn(f"Unblock cell {cell} failed. Probably unblocked already")
            else:
                raise err


def lock_gnb_cell(gnb_id=0, cell_id=1, du_id=0, administrative_state=False, max_attempts=4):
    """Custom version of 'Lock gNB Cell' from 'gnb_cell.robot', immune' to 'Cplane is busy' error

    :param administrative_state: Flag to determine whether perform locking via administrative state. Default: False
    :param gnb_id: GNB id - related to Test Line configuration.
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param cell_id: cell id.
    :param max_attempts: Number of attempts after 'CPlane is busy' fails the lock_cell function
    """
    attempt = 1
    err = None
    while attempt <= int(max_attempts):
        try:
            GnbCellOperations().lock_cell(bts_id=gnb_id, cell_id=cell_id, du_id=du_id,
                                          administrative_state=administrative_state)
            break
        except AdminApiProcedureFailureException as err:
            if 'CPlane is busy' in repr(err):
                logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                logger.debug(repr(err))
                time.sleep(20)
                attempt += 1
                continue
            raise err
    else:
        raise err


def unlock_gnb_cell(gnb_id=0, cell_id=1, du_id=0, administrative_state=False, max_attempts=4):
    """Custom version of 'Unlock gNB Cell' from 'gnb_cell.robot', immune' to 'Cplane is busy' error

    :param administrative_state: Flag to determine whether perform unlocking via administrative state. Default: False
    :param gnb_id: GNB id - related to Test Line configuration.
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param cell_id: cell id.
    :param max_attempts: Number of attempts after 'CPlane is busy' fails the unlock_cell function
    """
    attempt = 1
    err = None
    while attempt <= int(max_attempts):
        try:
            GnbCellOperations().unlock_cell(bts_id=gnb_id, cell_id=cell_id, du_id=du_id,
                                            administrative_state=administrative_state)
            break
        except AdminApiProcedureFailureException as err:
            if 'CPlane is busy' in repr(err):
                logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                logger.debug(repr(err))
                time.sleep(20)
                attempt += 1
                continue
            raise err
    else:
        raise err


def get_default_scf_path(file_name: str):
    """Get full path to the SCF stored in commissionings/Krakow/<tl_name>/<release>/

    :return str: full path to the SCF file name.
    """
    commission_dir = DefaultFileLocation().get_commissioning_dir()
    scf_path = os.path.join(commission_dir, file_name)
    return scf_path


def get_current_time() -> str:
    """Get current time.

    :return str: current time e.g. 2024-04-18 16:40:55
    """
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    logger.info('Start time {}'.format(current_time))
    return current_time


def modify_format_of_asir_time(asir_time: str) -> str:
    """Modify format of asir time.

    :param str asir_time: date
    :return str: modify date
    """

    return asir_time.replace('T', ' ', 1).replace('UTC', '')


def verify_alarm_appear_in_alarm_history_on_asir(allowed_fault_ids: list, start_time: str):
    """Verify if specified alarm appeared on ASIR after time.

    :param list allowed_fault_ids: list of FIDs
    :param str start_time: current date
    :return str: current time ex. 2024-04-18 16:40:55
    """
    all_alarm = GnbAsirHubOperations().get_historical_asir_webem_alarms()
    alarm_list_after_time = [alarm for alarm in all_alarm
                             if modify_format_of_asir_time(alarm['time_started']) > start_time]
    logger.debug(f'All alarm {alarm_list_after_time}')
    if alarm_list_after_time:
        fault_id_list = list(dict.fromkeys([alarm['fault_id'] for alarm in alarm_list_after_time]))
        logger.debug(f'Alarm in alarm history on asir {fault_id_list}')
        logger.debug(f'Allowed Alarm {allowed_fault_ids}')
        not_expected_alarm = [fault for fault in sorted(fault_id_list) if str(fault) not in sorted(allowed_fault_ids)]
        if not_expected_alarm:
            raise FaultNotFoundException(
                'Fault {} not appear in history list {} after time{}'.format(not_expected_alarm,
                                                                             alarm_list_after_time,
                                                                             start_time))


def verify_hubmod_lock_status():
    """Verify status of lock ASIR HUB

    """
    expected_statuses = {'operationalState': 'enabled', 'localState': 'blocked'}
    GnbAsirHubOperations().verify_hubmod_status(expected_statuses=expected_statuses)


def block_rat(rat: str, timeout: int = 600):
    """Blocks RAT.

    :param str rat: RAT to block. ["NR"|"LTE"|"WCDMA"|"GSM"]
    :param int timeout: Time to wait for positive procedure result., defaults to 600
    """
    with use_admin_connection() as connection:
        connection.block_rat(rat, timeout)


def unblock_rat(rat: str, timeout: int = 600):
    """Unblocks RAT.

    :param str rat: RAT to block. ["NR"|"LTE"|"WCDMA"|"GSM"]
    :param int timeout: Time to wait for positive procedure result., defaults to 600
    """
    with use_admin_connection() as connection:
        connection.unblock_rat(rat, timeout)


def reset_rat(rat_type: str, timeout=600, graceful_cell_shutdown=None, reset_type=None):
    """Preform RAT reset procedure.

    :param str rat_type: should be one of ["NR", "LTE", "WCDMA", "GSM"]
    :param int timeout: defaults to 600
    :param bool graceful_cell_shutdown: _description_, defaults to None
    :param bool reset_type: should be one of ["Soft"|"Hard"], defaults to "Soft"
    """
    with use_admin_connection() as connection:
        connection.rat_reset(
            rat_type=rat_type.upper(),
            timeout=timeout,
            graceful_cell_shutdown=graceful_cell_shutdown,
            reset_type=reset_type
        )
