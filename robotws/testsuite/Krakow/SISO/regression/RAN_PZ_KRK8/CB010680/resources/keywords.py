import logging
import re
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.util.moler_test import MolerTest
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations

path_to_unzip = "/home/ute/snapshot/UNZIPSNAPSHOT"
file_path = "/home/ute/snapshot/SNAPSHOT.zip"


class MissingFileException(Exception):
    pass


class MissingCellException(Exception):
    pass


@load_moler_configuration_from_tl()
def unzip_snapshot(file_path):
    vm = DeviceFactory.get_device(name="TEST_PC")
    # path_to_snapshot = file_path

    unzip_snapshot_cmd = vm.get_cmd(
        cmd_name="unzip",
        cmd_params={"zip_file": file_path,
                    "extract_dir": path_to_unzip, },
    )
    unzip_snapshot_cmd()

    cd_to_folder_cmd = vm.get_cmd(
        cmd_name="cd", cmd_params={"path": path_to_unzip})
    cd_to_folder_cmd()

    find_zip_cmd = vm.get_cmd(
        cmd_name="find",
        cmd_params={
            "options": ". -name '*.zip' -exec sh -c 'unzip -o -d \"${1%.*}\" \"$1\"' _ {} \\;"
        },
    )
    find_zip_cmd()


@load_moler_configuration_from_tl()
def check_nrposition_cells():
    vm = DeviceFactory.get_device(name="TEST_PC")
    file_dir = []
    find_path = vm.get_cmd(
        cmd_name="find",
        cmd_params={
            "options": '/home/ute/snapshot/ -name BTS*_*_NrCellMappingInfo.txt -print'
        },
    )

    output_find_path = find_path()

    if not output_find_path['RESULT']:
        raise MissingFileException("NrCellMappingInfo.txt was not found in snapshot")

    file_dir.append(output_find_path)
    MolerTest.info("DIRECTORY: {}".format(output_find_path['RESULT'][0]))
    nrcellmappinginfo_file = output_find_path['RESULT'][0]

    cat_nrcellmappinginfo = vm.get_cmd(
        cmd_name="cat",
        cmd_params={
            "path": nrcellmappinginfo_file
        },
    )

    output_nrcellmapinginfo = cat_nrcellmappinginfo()
    MolerTest.info("NrCellMappinginfo: {}".format(output_nrcellmapinginfo))

    expected_ids = []

    gnbcell = GnbCellOperations()

    expected_ids.append(gnbcell.get_cells_ids_with_related_parameter_value("nrPosCellType", "0DL4UL"))
    for expected_id in expected_ids:
        MolerTest.info(f"expected_id: {expected_id}")

    start_nrposcell_info = False
    cell_matched = True
    expected_start_nrposcell = ('NRPOSCELL   lcrId  nrPosCellIdentity  Associated NRCELL '
                                'L2-PS   L2-LO   Subcells  Id  Type  L1')
    for line in output_nrcellmapinginfo['LINES']:
        logging.info(f"{line}")
        if expected_start_nrposcell in line:
            start_nrposcell_info = True

        if start_nrposcell_info:
            if '---' in line:
                continue
        parsed_line = re.search(r".*(?P<NRPOSCELL>\d)\s+(?P<lcrId>\d)\s+(?:\d{9})(?P<lcrIdInNrPosCell>\d)\s+"
                                r"(?P<Associated_NRCELL>\d+)\s+(?P<L2_PS>0x\d+)\s+(?P<L2_LO>0x\d+)\s+"
                                r"(?P<Subcells>UL|DL)\s+(?P<Id>\d)\s+(?P<Type>C4S)\s+(?P<L1>0x\w+)", line)
        if parsed_line:

            if int(parsed_line.group("NRPOSCELL")) not in expected_ids[0]:
                logging.error(f"NRPOSCELL value: {type(parsed_line.group('NRPOSCELL'))} "
                              f"not found in expected_ids list: {type(expected_ids[0])} i {type(expected_ids[0][0])}")
                cell_matched = False
            if int(parsed_line.group("lcrId")) not in expected_ids[0]:
                logging.error(
                    f"lcrId value: {parsed_line.group('lcrId')} not found in expected_ids list: {expected_ids[0]}")
                cell_matched = False
            if int(parsed_line.group("Id")) not in expected_ids[0]:
                logging.error(
                    f"Id value: {parsed_line.group('Id')} not found in expected_ids list: {expected_ids[0]}")
                cell_matched = False
            if parsed_line.group("Subcells") != "UL":
                logging.error(
                    f"Subcells value: {parsed_line.group('Subcells')} not is not as expected 'UL'")
                cell_matched = False
            if parsed_line.group("Type") != "C4S":
                logging.error(
                    f"Type value: {parsed_line.group('Subcells')} not is not as expected 'C4S'")
                cell_matched = False

    if not cell_matched:
        raise MissingCellException("There are wrong NRPOSITION Cell values.")
