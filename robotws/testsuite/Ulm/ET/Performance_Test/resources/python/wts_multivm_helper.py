"""
Multi VM WTS Helper

To Check SIB
    source /home/ute/DEVELOPMENT/env_activate
    python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/wts_multivm_helper.py \
        --start_cell 1 \
        --end_cell 21 \
        --sibtype 1 \
        --check_sib \
        --log_level WARN

To Check UE Count
    source /home/ute/DEVELOPMENT/env_activate
    python /home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/wts_multivm_helper.py \
        --start_cell 1 \
        --end_cell 21 \
        --ue_count \
        --log_level WARN

"""

import argparse
import logging
import pathlib
import re

from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_multivm
from testsuite.Ulm.ET.Performance_Test.resources.python import taf_sw_wtssim_wrapper
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_wrapper
from taf.config.testline.testline import TestLine

logger = logging.getLogger(__name__)


def deregister_all_ues(tl: TestLine = None) -> None:
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    is_pass = True
    for test_pc_index in range(taf_transport_ssh_multivm.test_pc_count(tl)):
        egate_cmd = 'ue_deregister id=all ue_deregister_type=switch_off by=ue'
        try:
            taf_sw_wtssim_wrapper.execute_egate_command_and_wait_for_data(egate_cmd,
                                                                          test_pc_index=test_pc_index,
                                                                          timeout=300)
        except ConnectionRefusedError:
            logger.error('[VM %s] ue_deregister command failed', test_pc_index+1)
            is_pass = False
    return is_pass


def get_ue_count_for_all_egates(num_cells: int, tl: TestLine = None) -> list:
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    cells = []
    for _ in range(1, int(num_cells) + 1):
        cells.append(0)
    for test_pc_index in range(taf_transport_ssh_multivm.test_pc_count(tl)):
        try:
            ue_summary_output = taf_sw_wtssim_wrapper.execute_egate_command_and_wait_for_data(
                'ue_summary',
                test_pc_index=test_pc_index)
            vm_cells = wts_wrapper.get_ue_count_per_cell(num_cells=num_cells,
                                                         ue_summary_output=ue_summary_output)
            for cell_index, _ in enumerate(cells):
                cells[cell_index] = cells[cell_index] + vm_cells[cell_index]
        except ConnectionRefusedError:
            logger.error('[VM %s] ue_summary command failed', test_pc_index+1)
    return cells


def upload_wts_files_to_all_vm(directory: str, tl: TestLine = None) -> None:
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    for test_pc_index in range(taf_transport_ssh_multivm.test_pc_count(tl)):
        for file_path in pathlib.Path(directory).joinpath('common').iterdir():
            logger.debug("Uploading %s file: %s, is_file: %s",
                         f'vm{test_pc_index+1}', str(file_path), file_path.is_file())
            if file_path.is_file():
                taf_transport_ssh_multivm.upload_file(str(file_path),
                                                      f"/opt/wts/latest/{file_path.name}",
                                                      test_pc_index=test_pc_index)
        for file_path in pathlib.Path(directory).joinpath(f'vm{test_pc_index+1}').iterdir():
            logger.debug("Uploading %s file: %s, is_file: %s",
                         f'vm{test_pc_index+1}', str(file_path), file_path.is_file())
            if file_path.is_file():
                taf_transport_ssh_multivm.upload_file(str(file_path),
                                                      f"/opt/wts/latest/{file_path.name}",
                                                      test_pc_index=test_pc_index)


def execute_wts_manager_on_vm(json_loc: str, args: str = '', test_pc_index: int = 0, run_async=False) -> None:
    # GHC: Modified by AI: 2026-02-05 - Add background execution support for wts_manager command
    dev_folder = "/home/ute/DEVELOPMENT"
    wts_manager_py = f"{dev_folder}/robotws/testsuite/Ulm/ET/Performance_Test/resources/python/wts_manager.py"
    source_command = f"source {dev_folder}/env_activate"
    wts_command = f"python {wts_manager_py} {json_loc} {args}"
    if run_async:
        command = f"{source_command}; nohup {wts_command} &"
    else:
        command = f"{source_command}; {wts_command}"
    taf_transport_ssh_multivm.execute(command, index=test_pc_index)


def connect_to_all_vms(tl: TestLine) -> None:
    taf_transport_ssh_multivm.ssh_connect_all_vm(tl=tl)


def restart_wts_binaries_on_all_vms(tl: TestLine = None) -> None:
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    for test_pc_index in range(taf_transport_ssh_multivm.test_pc_count(tl)):
        command = r"""restart_wts_binaries(){
                        EDAEMON_PORT=22222
                        EGATE_PORT=10000
                        WTS_DIR=/opt/wts/latest
                        sudo pkill -f "./egate.* --port ${EGATE_PORT}" &&
                        sudo pkill -f "./edaemon.* --port ${EDAEMON_PORT}" &&
                        pushd ${WTS_DIR};
                            rm -f ${WTS_DIR}/*.log*; rm ${WTS_DIR}/SosReport*.tgz ;
                            sudo ./edaemon --port ${EDAEMON_PORT} && ./egate --port ${EGATE_PORT};
                        popd
                    }
                    restart_wts_binaries"""
        taf_transport_ssh_multivm.execute(command, index=test_pc_index)


def get_egate_console_log_for_all_vms(tl: TestLine = None) -> list:
    egate_console_logs = []
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    for test_pc_index in range(taf_transport_ssh_multivm.test_pc_count(tl)):
        try:
            taf_sw_wtssim_wrapper.execute_egate_command('sim_log_set flush',
                                                        test_pc_index=test_pc_index,
                                                        return_output=False)
        except ConnectionRefusedError:
            logger.warning('[VM %s] Unable to Flush egate_console.log', test_pc_index+1)
        egate_console_logs.append(
            taf_transport_ssh_multivm.execute(
                r'cat /opt/wts/latest/egate_console.log', index=test_pc_index)
        )
    return egate_console_logs


def get_sib_for_all_vms(tl: TestLine = None, sibtype=1) -> dict:
    '''
    returns {
        'type' : < sibtype >
        'enbs' : {
            < enb_id >: {
                < cell_id >: {
                    'vm': < vm_id >,
                    'uecs': < uec_list >
                }
            }
        }
    }
    '''
    sibs = {
        'type': sibtype,
        'enbs': {}
    }
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    egate_console_logs = get_egate_console_log_for_all_vms(tl=tl)
    for test_pc_index, egate_console in enumerate(egate_console_logs):
        try:
            regex_pattern = r'UEC-(\d+): eNB (\d+) cell (\d+): ' + \
                f'SystemInformationBlockType{sibtype}-NR updated'
            regex_result = re.findall(regex_pattern, egate_console)
        except TypeError as e:
            logger.warning('TypeError: %s', e)
            regex_result = []
        for item in regex_result:
            uec_id = int(item[0])
            enb_id = item[1]
            cell_id = int(item[2])
            if sibs['enbs'].get(enb_id, False) is False:
                sibs['enbs'][enb_id] = {}
            if sibs['enbs'][enb_id].get(cell_id, False) is False:
                sibs['enbs'][enb_id][cell_id] = {
                    'vm': test_pc_index+1,
                    'uecs': []
                }
            sibs['enbs'][enb_id][cell_id]['uecs'].append(uec_id)
    return sibs


def get_ap_cell_for_all_vms(tl: TestLine = None) -> dict:
    '''
    returns {
        < cell_id >: {
            'vm': < vm_id >,
            'uecs': < uec_list >
        }
    }
    '''
    cells = {}
    if tl is None:
        tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    egate_console_logs = get_egate_console_log_for_all_vms(tl=tl)
    for test_pc_index, egate_console in enumerate(egate_console_logs):
        try:
            regex_result = re.findall(r'UEC-(\d+): .irphone: .ell .etup completed for .CELL_ID:(\d+).',
                                      egate_console)
        except TypeError as e:
            logger.warning('TypeError: %s', e)
            regex_result = []
        for item in regex_result:
            uec_id = int(item[0])
            cell_id = int(item[1])
            if cells.get(cell_id, False) is False:
                cells[cell_id] = {
                    'vm': test_pc_index+1,
                    'uecs': []
                }
            cells[cell_id]['uecs'].append(uec_id)
    return cells


def format_sibs(sibs: dict) -> str:
    strval = ""
    strval = strval+f"SystemInformationBlockType{sibs['type']}-NR:\n"
    for enb, cells in sibs['enbs'].items():
        cells = dict(sorted(cells.items(), key=lambda item: item[0]))
        strval = strval+f"  - ENB {enb.rjust(2, '0')}\n"
        for cell, items in cells.items():
            uecs = [int(i) for i in items['uecs']]
            uecs.sort()
            strval = strval + \
                f"    - Cell {str(cell).rjust(2, '0')} (VM{str(items['vm']).rjust(2, '0')}): UEC:{uecs}\n"
    return strval


def format_ap_cells(cells: dict) -> str:
    strval = ""
    strval = strval+'Airphone Cell Setup:\n'
    cells = dict(sorted(cells.items(), key=lambda item: item[0]))
    for cell, items in cells.items():
        uecs = [int(i) for i in items['uecs']]
        uecs.sort()
        strval = strval + \
            f"    - Cell {str(cell).rjust(2, '0')} (VM{str(items['vm']).rjust(2, '0')}): UEC:{uecs}\n"
    return strval


def get_cells_without_sib(enb: dict, start_cell: int = 1, end_cell: int = 1, active_cells: list = None) -> list:
    missing_sib = []
    logger.debug('==== start get_cells_without_sib ====')
    logger.debug('enb: %s, start_cell: %s, end_cell: %s, active_cells: %s',
                 enb, start_cell, end_cell, active_cells)
    for cell in range(int(start_cell), int(end_cell)+1):
        if (active_cells is not None) and (cell not in active_cells) and (active_cells[0] != 'all'):
            logger.debug('skipping cell: %s', cell)
            continue
        enb_cell = enb.get(cell, None)
        logger.debug('enb_cell %s: %s', cell, enb_cell)
        if enb_cell is None:
            missing_sib.append(str(cell).rjust(2, '0'))
            continue
        if len(enb_cell['uecs']) == 0:
            missing_sib.append(str(cell).rjust(2, '0'))
            continue
    logger.debug('==== end get_cells_without_sib ====')
    return missing_sib


def get_offline_ap_cells(apcells: dict, start_cell: int = 1, end_cell: int = 1, active_cells: list = None) -> list:
    logger.debug('==== start get_offline_ap_cells ====')
    logger.debug('apcells: %s, start_cell: %s, end_cell: %s, active_cells: %s',
                 apcells, start_cell, end_cell, active_cells)
    offline_cells = []
    for cell in range(int(start_cell), int(end_cell)+1):
        if (active_cells is not None) and (cell not in active_cells) and (active_cells[0] != 'all'):
            logger.debug('skipping cell: %s', cell)
            continue
        ap_cell = apcells.get(cell, None)
        logger.debug('ap_cell %s: %s', cell, ap_cell)
        if ap_cell is None:
            offline_cells.append(str(cell).rjust(2, '0'))
            continue
        if len(ap_cell['uecs']) == 0:
            offline_cells.append(str(cell).rjust(2, '0'))
            continue
    logger.debug('==== end get_offline_ap_cells ====')
    return offline_cells


def is_sib_ready(enb: dict, start_cell: int = 1, end_cell: int = 1, active_cells: list = None) -> bool:
    cells_without_sib = get_cells_without_sib(
        enb, start_cell=start_cell, end_cell=end_cell, active_cells=active_cells)
    if len(enb) > 0 and len(cells_without_sib) == 0:
        return True
    logger.info('SIB Offline: %s', cells_without_sib)
    return False


def is_ap_cell_ready(ap_cells: dict, start_cell: int = 1, end_cell: int = 1, active_cells: list = None) -> bool:
    offline_cells = get_offline_ap_cells(
        ap_cells, start_cell=start_cell, end_cell=end_cell, active_cells=active_cells)
    if len(ap_cells) > 0 and len(offline_cells) == 0:
        return True
    logger.info('AP Cells Offline: %s', offline_cells)
    return False


def _main():
    parser = argparse.ArgumentParser(description='wts_manager.py')
    parser.add_argument('--start_cell', default=1)
    parser.add_argument('--end_cell', default=12)
    parser.add_argument('--sibtype', default=1)
    parser.add_argument('--active_cells', default=None)
    parser.add_argument('--check_sib', action='store_true')
    parser.add_argument('--ue_count', action='store_true')
    parser.add_argument('--log_level', default="WARN")
    args = parser.parse_args()

    logging.basicConfig(
        format="%(asctime)s|%(levelname)s:%(message)s",
        encoding='utf-8',
        level=getattr(logging, args.log_level)
    )
    tl = taf_transport_ssh_multivm.get_tl_obj_from_current_host()
    try:
        taf_transport_ssh_multivm.ssh_connect_all_vm(tl=tl)
        taf_sw_wtssim_wrapper.setup_all_egates_and_edaemons_connections(tl=tl)

        if args.check_sib:
            ap_cells = get_ap_cell_for_all_vms(tl=tl)
            sibs = get_sib_for_all_vms(sibtype=args.sibtype, tl=tl)
            try:
                sib_ready = is_sib_ready(
                    sibs['enbs']['2'],
                    start_cell=int(args.start_cell),
                    end_cell=int(args.end_cell),
                    active_cells=None if args.active_cells is None else args.active_cells.split(
                        ','),
                )
            except KeyError:
                sib_ready = False
            ap_cell_ready = is_ap_cell_ready(
                ap_cells,
                start_cell=int(args.start_cell),
                end_cell=int(args.end_cell),
                active_cells=None if args.active_cells is None else args.active_cells.split(
                    ','),
            )
            print(format_ap_cells(ap_cells))
            print(format_sibs(sibs))
            print(f" AP Ready: {ap_cell_ready}")
            print(f"SIB Ready: {sib_ready}")

        if args.ue_count:
            num_cells = int(args.end_cell)-int(args.start_cell)+1
            cells = get_ue_count_for_all_egates(num_cells)
            ue_count_table = wts_wrapper.get_ue_count_per_cell_table(num_cells=num_cells,
                                                                     active_cells=None,
                                                                     expected=None,
                                                                     cells=cells)
            print(ue_count_table)
    finally:
        taf_sw_wtssim_wrapper.teardown_all()


if __name__ == "__main__":
    _main()
