import re
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from taf.sbts.oam.coam.admin import admin

admin_connection = admin()
tl = BuiltIn().get_variable_value('${tl}')
lmp_address = tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr

components = ["CP-NRT", "CP-RT", "CP-CL", "CP-NB", "CP-IF", "CP-UE", "UP-UE"]
NrCellMappingInfo_file_name = "*NrCellMappingInfo.txt"
snapshot_file_list_file_name = "snapshot_file_list.txt"
snapshot_dir = BuiltIn().get_variable_value("${OUTPUTDIR}") + "/snapshot"
NrCellMappingInfo_file_number = 0


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions(check_steps_end=True)
def verify_component_and_cell_info(bts_id=0, du_id=0):
    """
    Verify component and cell info in NrCellMappingInfo.txt file.
    Example of NrCellMappingInfo.txt file:

        Component   NodeId
    ------------------
    CP-NRT      0x2525
    CP-RT       0x2524
    CP-CL       0x2521
    CP-NB       0x2522
    CP-IF       0x2523
    CP-UE       0x2731
    UP-UE       0x2730

    NRCELL  lcrId  nrCellIdentity  PCI  L2-PS   L2-LO   Subcells  Id  Type  L1
    --------------------------------------------------------------------------------
    1       1      379109377       1    0x2740  0x2740  DL        0   D2    0x225D
                                                        UL        0   D2    0x225D
    :param bts_id: ID of BTS
    :param du_id: ID of DU
    :return: int, number of cells in nrcellmappinginfo
    """
    vm = DeviceFactory.get_device(connection_names.ssh_bts_du.format("GNB", bts_id, du_id), initial_state="UNIX_LOCAL")
    cat_cmd = vm.get_cmd(cmd_name="cat",
                         cmd_params={"path": "{}/{}{}".format(snapshot_dir, NrCellMappingInfo_file_name,
                                                              NrCellMappingInfo_file_number)})
    nrcellmappinginfo_list = cat_cmd()["LINES"]
    MolerTest.info("NrCellMappingInfo:", dump=nrcellmappinginfo_list)
    _verify_components(nrcellmappinginfo_list)
    number_of_cells = _verify_cells_info(nrcellmappinginfo_list)
    MolerTest.steps_end()
    return number_of_cells


def _verify_components(nrcellmappinginfo_list):
    missing_components_list = list(components)
    for component in components:
        # CP-NRT      0x2525
        _re_component = r"^{}\s+\dx\d+$".format(component)
        for line in nrcellmappinginfo_list:
            if component in line and re.match(_re_component, line):
                missing_components_list.remove(component)
                break
    if missing_components_list:
        MolerTest.error("Missing or incorrect components in {}{}".format(NrCellMappingInfo_file_name,
                                                                         NrCellMappingInfo_file_number),
                        dump=missing_components_list)


def _verify_cells_info(nrcellmappinginfo_list):
    cell_info_list = _find_cell_info_list(nrcellmappinginfo_list)
    if not cell_info_list:
        MolerTest.error("Missing cells info in {}{}"
                        .format(NrCellMappingInfo_file_name, NrCellMappingInfo_file_number))
        MolerTest.steps_end()
        return
    number_of_cells = _verify_no_missing_cell_info(cell_info_list)
    MolerTest.steps_end()
    return number_of_cells


def _find_cell_info_list(nrcellmappinginfo_list):
    cell_info_list = list()
    header = "NRCELL  lcrId  nrCellIdentity  PCI  L2-PS   L2-LO   Subcells  Id  Type  L1"
    for idx, line in enumerate(nrcellmappinginfo_list):
        if header in line:
            cell_info_list = nrcellmappinginfo_list[idx + 2:]
            break
    return cell_info_list


# 1       1      379109377       1    0x2740  0x2740  DL        0   D2    0x225D
_re_cell_info_1 = r"^\d+\s+\d+\s+\d+\s+\d+\s+\dx\d+\s+\dx\d+\s+DL\s+\d+\s+\w\d\s+\dx\d+\w"
#                                                    UL        0   D2    0x225D
_re_cell_info_2 = r"^\s+UL\s+\d+\s+\w\d\s+\dx\d+\w"


def _verify_no_missing_cell_info(cell_info_list):
    missing_cell_info_list = list()
    number_of_cells = 0
    for idx, line in enumerate(cell_info_list[::2]):
        MolerTest.info(cell_info_list[2 * idx])
        if not re.match(_re_cell_info_1, cell_info_list[2 * idx]) \
                or not re.match(_re_cell_info_2, cell_info_list[2 * idx + 1]):
            missing_cell_info_list.append([cell_info_list[2 * idx], cell_info_list[2 * idx + 1]])
        else:
            number_of_cells += 1
    if missing_cell_info_list:
        MolerTest.error("Incorrect cells info in {}{}"
                        .format(NrCellMappingInfo_file_name, NrCellMappingInfo_file_number),
                        dump=missing_cell_info_list)
    return number_of_cells


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def get_nrcellmappinginfo(bts_id=0, du_id=0):
    """
    Get nrcellmappinginfo file.

    :param bts_id: ID of BTS
    :param du_id: ID of DU
    :return: None
    """
    vm = DeviceFactory.get_device(connection_names.ssh_bts_du.format("GNB", bts_id, du_id), initial_state="UNIX_LOCAL")
    cmd_params = {"zip_file": "{}/*.zip".format(snapshot_dir), "extract_dir": "{}/extracted".format(snapshot_dir)}
    unzip_cmd = vm.get_cmd(cmd_name="unzip", cmd_params=cmd_params)
    unzip_cmd()
    zip_file = find_nrcellmappinginfo_in_snapshot_file_list()
    unzip_file_with_nrcellmappinginfo(zip_file)


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def find_nrcellmappinginfo_in_snapshot_file_list(bts_id=0, du_id=0):
    """
    Find nrcellmappinginfo in snapshot file list.

    :param bts_id: ID of BTS
    :param du_id: ID of DU
    :return: file name with NrCellMappingInfo.txt
    """
    vm = DeviceFactory.get_device(connection_names.ssh_bts_du.format("GNB", bts_id, du_id), initial_state="UNIX_LOCAL")
    cat_cmd = vm.get_cmd(cmd_name="cat", cmd_params={"path": "{}/extracted/{}"
                         .format(snapshot_dir, snapshot_file_list_file_name)})
    snapshot_file_list = cat_cmd()["LINES"]
    for idx, snapshot_file in enumerate(snapshot_file_list):
        if "NrCellMappingInfo.txt" in snapshot_file:
            for num in reversed(range(idx)):
                if re.match("^BTS.*", snapshot_file_list[num]):
                    return snapshot_file_list[num][:-1]


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def unzip_file_with_nrcellmappinginfo(zip_file, bts_id=0, du_id=0):
    """
    Unzip file with nrcell mapping info.

    :param zip_file: zip file with nrcellmappinginfo.txt
    :param bts_id: ID of BTS
    :param du_id: ID of DU
    :return: None
    """
    global NrCellMappingInfo_file_number
    NrCellMappingInfo_file_number += 1
    vm = DeviceFactory.get_device(connection_names.ssh_bts_du.format("GNB", bts_id, du_id), initial_state="UNIX_LOCAL")
    cmd_params = {"zip_file": "{}/extracted/{} {}".format(snapshot_dir, zip_file, NrCellMappingInfo_file_name),
                  "extract_dir": snapshot_dir}
    unzip_cmd = vm.get_cmd(cmd_name="unzip", cmd_params=cmd_params)
    unzip_cmd()
    mv_cmd = vm.get_cmd(cmd_name="mv", cmd_params={"src": "{}/{}".format(snapshot_dir, NrCellMappingInfo_file_name),
                                                   "dst": "{}/{}{}".format(snapshot_dir, NrCellMappingInfo_file_name,
                                                                           NrCellMappingInfo_file_number)})
    mv_cmd()
    rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": "{}/extracted".format(snapshot_dir), "options": "-rf"})
    rm_cmd()


@load_moler_configuration_from_tl()
@MolerTest.raise_background_exceptions()
def remove_old_snapshot(bts_id=0, du_id=0):
    """
    Remove old snapshot if exists.

    :param bts_id: ID of BTS
    :param du_id: ID of DU
    :return: None
    """
    vm = DeviceFactory.get_device(connection_names.ssh_bts_du.format("GNB", bts_id, du_id), initial_state="UNIX_LOCAL")
    rm_cmd = vm.get_cmd(cmd_name="rm", cmd_params={"file": "{}/*.zip".format(snapshot_dir), "options": "-rf"})
    rm_cmd()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def verify_subcells_info():
    """
    Find and verify info about SubCells ID and direction.

    :return: None
    """
    admin_connection.connect_to(bts_host=lmp_address)
    cells_info = admin_connection.get_cells_info()
    admin_connection.teardown()
    MolerTest.info("Cells info:", dump=cells_info)
    _check_cells_info(cells_info)
    MolerTest.steps_end()


def _check_cells_info(cells_info):
    for cell in cells_info:
        cell_dist_name = cell['id']['configuration']
        if not _verify_subcelllist_exists(cell, cell_dist_name):
            continue
        if not _verify_subcelllist_not_empty(cell, cell_dist_name):
            continue
        _check_number_of_subcells(cell, cell_dist_name)
        _check_subcelllist_content(cell, cell_dist_name)


def _verify_subcelllist_exists(cell, cell_dist_name):
    if 'subCellList' not in cell:
        MolerTest.error("Missing subCellList in Cells info for Cell: {}".format(cell_dist_name))
        return False
    return True


def _verify_subcelllist_not_empty(cell, cell_dist_name):
    if not cell['subCellList']:
        MolerTest.error("Missing SubCells in subCellList for Cell: {}".format(cell_dist_name))
        return False
    return True


def _check_number_of_subcells(cell, cell_dist_name):
    expected_subcells = 2
    subcells_num = len(cell['subCellList'])
    if subcells_num != expected_subcells:
        MolerTest.error("Incorrect number of subCells for Cell: {}. Correct number: {}, current number: {}"
                        .format(cell_dist_name, expected_subcells, subcells_num))


# Subcell-0 (UL)
_re_subcell_info = r'^Subcell-\d+\s\((DL|UL)\)$'


def _check_subcelllist_content(cell, cell_dist_name):
    subcell_info_example = "Subcell-0 (DL)"
    for subcell in cell['subCellList']:
        if not re.match(_re_subcell_info, subcell):
            MolerTest.error("Incorrect subCellList content for Cell: {}. example of correct subcell info: {}"
                            .format(cell_dist_name, subcell_info_example), dump=subcell)
