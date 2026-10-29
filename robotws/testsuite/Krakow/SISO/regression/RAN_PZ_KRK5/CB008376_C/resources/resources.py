import os
import json
import time
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.procedures.resources.python.snapshot.exceptions import NotAllMandatoryFilesPresent
from taf.rfrl.common_resources.python.report_to_rep import TputKPI
from taf.rfrl.utilities.test_config import get_log_path
import taf.rfrl.utilities.logger.custom_logger as logger


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def convert_status_to_json(status):
    status = "".join(str(status).split())
    status = str(status).replace('Severalfailuresoccurred:', '')
    status = status.replace("1)NotAllMandatoryFilesPresent:", '')
    status = status.replace('2)NotAllMandatoryFilesPresent:', ', ')
    status = "".join(('[', status, ']'))
    status = status.replace('\'', '\"')
    status = status.replace('\"[', '[')
    status = status.replace(']\"', ']')
    return json.loads(status)


def check_snapshot_status(status):
    accept = {'EB2244R1896': ['frozenFrame_Coco_clks1.log', 'frozenFrame_Coco_eth2.log',
                              'frozenFrame_Coco_port3.log']}
    reported_missings = convert_status_to_json(status)
    really_missing = dict()
    for reported_missing in reported_missings:
        for rrh in reported_missing:
            really_missing_files = list()
            if rrh['ru_serial_number'] in accept:
                for file_name in rrh['missing_files']:
                    if file_name not in accept[rrh['ru_serial_number']]:
                        really_missing_files.append(file_name)
            if really_missing_files:
                really_missing['ru_name'] = rrh['ru_name']
                really_missing['ru_serial_number'] = rrh['ru_serial_number']
                really_missing['missing_files'] = really_missing_files
    if really_missing:
        logger.log_warn_to_console('Really missing {}'.format(really_missing))
        raise NotAllMandatoryFilesPresent(str(really_missing))


def action_with_cells_using_delta(action='Lock'):
    gnb_cell = GnbCellOperations()
    all_cells_ids = gnb_cell.get_all_cells_id()
    logger.log_info_to_console('All cells would be: {}ed'.format(action.lower()))
    for cell_id in all_cells_ids:
        if action == 'Lock':
            gnb_cell.lock_cell(cell_id=cell_id)
            time.sleep(10)
            gnb_cell.verify_cell_statuses(cell_id=cell_id, operational_state='disabled',
                                          procedural_status='initialization required',
                                          availability_status='offline', administrative_state='locked')
        else:
            gnb_cell.unlock_cell(cell_id=cell_id)
            time.sleep(10)
            gnb_cell.verify_cell_statuses(cell_id=cell_id, operational_state="enabled", procedural_status="configured",
                                          availability_status="online", administrative_state="unlocked")


def generate_tput_graph(tput_dl, tput_ul, dt_name, file_name):
    tput_kpi = TputKPI()
    tput_dl = tput_dl.replace(" ", "")
    tput_ul = tput_ul.replace(" ", "")
    tput_kpi._prepare_tput_kpi_data(protocol='TCP', tput_dl=tput_dl, tput_ul=tput_ul, data_transfer_name=dt_name)
    tput_kpi.generate_excel_report(excel_file_path=os.path.join(get_log_path(), "{}.xlsx".format(file_name)))
