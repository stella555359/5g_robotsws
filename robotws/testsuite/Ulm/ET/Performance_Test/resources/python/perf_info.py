
import re
import traceback
import prettytable

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Ulm.ET.Performance_Test.resources.db import db_interface_insert
from testsuite.Ulm.ET.Performance_Test.resources.python import taf_sw_wtssim_wrapper

rbi = BuiltIn()

CONST_PRECISION = 2
WTS_ALIAS = 'perf_egate'

cell_stats_nr_mb_conversion_factor = {
    'gbps': 1000, 'mbps': 1, 'kbps': 0.001, 'bps': 0.000001
}


def connect_egate(alias=WTS_ALIAS):
    try:
        tl = rbi.get_variable_value("${tl}")
        taf_sw_wtssim_wrapper.get_taf_sw_wtssim_obj().setup_egate(
            egate_port=tl.core.egate_port, tool_dir=tl.core.dir_path, alias=alias)
    except AttributeError:
        taf_sw_wtssim_wrapper.get_taf_sw_wtssim_obj().setup_egate(
            egate_port="10000", tool_dir="/opt/iphy/latest", alias=alias)


def disconnect_egate(alias=WTS_ALIAS):
    taf_sw_wtssim_wrapper.get_taf_sw_wtssim_obj().teardown_egate(alias=alias)


def save_cell_stats(itype='throughput', enb=2, insert_db='true', current=False,
                    testcase_id=None, start_cell=1, end_cell=1, uec='1,2,3,4,5'):
    uec = uec.split(',')
    total_ul = 0
    total_dl = 0
    if str(current).lower() == 'true':
        const_ul_data_rate_index = 0
        const_dl_data_rate_index = 2
    else:
        const_ul_data_rate_index = 1
        const_dl_data_rate_index = 3
    try:
        connect_egate()
        per_cell_headers = ['Cell', 'UEC', 'UL', 'DL']
        total_tputtable = prettytable.PrettyTable(['Cell', 'UL', 'DL'])
        rbi.log_to_console("Cell Stats NR (egate max tput reached) in mbps:")
        for cell_id in range(int(start_cell), int(end_cell) + 1):
            tputtable = prettytable.PrettyTable(per_cell_headers)
            cell_total_ul = 0
            cell_total_dl = 0
            for iuec in uec:
                try:
                    output = taf_sw_wtssim_wrapper.get_taf_sw_wtssim_obj().execute_egate_command_and_wait_for_data(
                        cmd=f"cell_stats_nr enb={enb} id={cell_id} type={itype} uec={iuec}",
                        pass_regexp="([U,D]L Max Data Rate|disabled)",
                        return_output=True, alias=WTS_ALIAS)
                    result = grep_cell_stats_nr_result(output)
                    tputtable.add_row([cell_id, iuec, round(result[const_ul_data_rate_index], 2),
                                       round(result[const_dl_data_rate_index], 2)])
                    cell_total_ul = cell_total_ul + result[const_ul_data_rate_index]
                    cell_total_dl = cell_total_dl + result[const_dl_data_rate_index]
                except Exception as e:
                    tputtable.add_row([cell_id, iuec, 'n/a', 'n/a'])
                    rbi.log(f"save_cell_stats loop: e={e}\n{traceback.format_exc()}", level='DEBUG')
                    break
            total_ul = total_ul+cell_total_ul
            total_dl = total_ul+cell_total_dl
            total_tputtable.add_row([cell_id, round(cell_total_ul, 2), round(cell_total_dl, 2)])
            rbi.log_to_console(str(tputtable))
        total_tputtable.add_row(['Total', round(total_ul, 2), round(total_dl, 2)])
        total_tputtable.align = "r"
        tputtable.align = "r"
        rbi.log_to_console(str(total_tputtable))
    except Exception as e:
        rbi.log(f"save_cell_stats: e={e}\n{traceback.format_exc()}", level="WARN")
    finally:
        disconnect_egate()
    if str(insert_db).lower() == 'true':
        if testcase_id is None:
            rbi.log_to_console("save_cell_stats failed to insert db: no testcase id provided!")
        else:
            db_interface_insert.connect_to_database(rbi.get_variable_value("${TP.DB_SQLITE3_DATABASE}"))
            db_interface_insert.insert_testcase_results_with_args(
                testcase_id, 'cell_stats_nr_ul_mbps', round(total_ul, CONST_PRECISION))
            db_interface_insert.insert_testcase_results_with_args(
                testcase_id, 'cell_stats_nr_dl_mbps', round(total_dl, CONST_PRECISION))


def grep_cell_stats_nr_result(cell_stats_nr):
    """=========================================================================================
        Cell Id  UL Max Data Rate  UL Current Data Rate  DL Max Data Rate  DL Current Data Rate
        -----------------------------------------------------------------------------------------
        4        0 bps             0 bps                 65.208 kbps       62.696 kbps
        =========================================================================================
    """
    rbi.log("========== start: grep_cell_stats_nr_result ==========")
    re_stats = re.findall(r'[0-9.]+ k*bps', cell_stats_nr)
    const_re_stats_len = 4
    converted_tputs = [0, 0, 0, 0]
    if len(re_stats) == const_re_stats_len:    # matches the expectation
        for i, tput in enumerate(re_stats):
            value, datarate = tput.split()
            converted_tputs[i] = round(
                cell_stats_nr_mb_conversion_factor[datarate] * float(value), CONST_PRECISION)
    else:
        rbi.log(f"    re_stats invalid format: {re_stats}")
    return converted_tputs
