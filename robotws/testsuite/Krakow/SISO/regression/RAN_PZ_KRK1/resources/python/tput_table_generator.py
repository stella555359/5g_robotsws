"""
:copyright: Nokia Solutions and Networks
:author: Agnieszka Bylica
:contact: agnieszka.bylica@nokia.com
"""

import logging
from taf.rfrl.ue.helpers.tput_statistics import TputStatistics
from taf.rfrl.utilities.reports.excel_report import ExcelReport
from taf.rfrl.utilities.robot.general import get_builtin_value


def get_tput_statistics(**kwargs):
    """
    Get real values of min, max and average tput.
    :kwargs: parameters required to get tput statistics:
             tput_dl, tput_ul, protocol, deviation, dt_name
    :return: list of dicts in format:
        [
            {'name': 'min_dl_tcp_tput', 'value': 175000.0, 'target': '', 'unit': 'Kbits/sec'},
            {'name': 'avg_dl_tcp_tput', 'value': 195752.75, 'target': 172000.0, 'unit': 'Kbits/sec'},
            {'name': 'avg_naa_dl_tcp_tput', 'value': 182859.08, 'target': 172000.0, 'unit': 'Kbits/sec'},
            {'name': 'max_dl_tcp_tput', 'value': 203000.0, 'target': '', 'unit': 'Kbits/sec'},
            {'name': 'min_ul_tcp_tput', 'value': 3170.0, 'target': '', 'unit': 'Kbits/sec'},
            {'name': 'avg_ul_tcp_tput', 'value': 101430.22, 'target': 81600.0, 'unit': 'Kbits/sec'},
            {'name': 'avg_naa_ul_tcp_tput', 'value': 98678.28, 'target': 81600.0, 'unit': 'Kbits/sec'},
            {'name': 'max_ul_tcp_tput', 'value': 106000.0, 'target': '', 'unit': 'Kbits/sec'}
        ]
    """
    tput_stats_obj = TputStatistics()
    tput_stats = tput_stats_obj.get_tput_statistics(protocol=kwargs['protocol'], tput_dl=kwargs['tput_dl'],
                                                    tput_ul=kwargs['tput_ul'],
                                                    deviation=kwargs['deviation'],
                                                    is_traffic_multi_radio_bearer=False,
                                                    data_transfer_name=kwargs['dt_name'])
    logging.debug(f'RAW tput statistics: {tput_stats}')
    tput_stats_obj.convert_to_kilobits(tput_stats)
    logging.debug(f'Tput statistics in Kbits/sec: {tput_stats}')
    return tput_stats


def fill_in_tput_table(cell_id, sheetname='Tput stats', dt_name='DT_', **kwargs):
    """
    Create xlsx file with tput statistics for every cell.
    :param cell_id: ID of the cell on which the tput is running
    :param sheetname: a name of the sheet where tput data is stored, if not given all data is stored in a default sheet
    :param dt_name: a name of the running tput without DL/UL, default DT_
    :kwargs: parameters required to get tput statistics:
             tput_dl, tput_ul, protocol, deviation
    :return: path to the file
    """
    tput_statistics = get_tput_statistics(dt_name=dt_name, **kwargs)
    headers = ['CELL ID', 'TARGET']
    values = [f'CELL-{cell_id}', None]
    for item in tput_statistics:
        headers.append(item['name'].replace('_', ' ').upper())
        values.append(f"{item['value']} {item['unit']}")
        if values[1] is None:
            values[1] = f"{item['target']} {item['unit']}" if item['target'] else None

    excel_path = get_builtin_value('LOG_PATH') + '/tput.xlsx'
    excel_workbook = ExcelReport(excel_path)
    if not excel_workbook.file_exists:
        excel_workbook.create_new_excel_file(headers=headers, data=[values], sheetname=sheetname)
    elif sheetname not in excel_workbook.worksheets:
        excel_workbook.add_worksheet(name=sheetname)
        excel_workbook.add_data_to_worksheet(data=[values], headers=headers, name=sheetname)
    else:
        excel_workbook.add_data_to_worksheet(data=[values], name=sheetname)
    return excel_workbook.file_path
