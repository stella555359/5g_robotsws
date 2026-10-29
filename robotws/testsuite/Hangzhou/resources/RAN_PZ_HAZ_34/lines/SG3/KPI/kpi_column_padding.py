import shutil
import time
from openpyxl import load_workbook
import pandas as pd
from openpyxl.utils import column_index_from_string
from openpyxl.styles import Font
import warnings
import os
from datetime import datetime

warnings.filterwarnings(
    "ignore",
    category=UserWarning,
    message="Sparkline Group extension is not supported"
)


def kpi_column_padding(case_kpi_excel,
                       origin_kpi_excel,
                       sw_build,
                       suite_timestamp,
                       sheet_name,
                       sw_build_name_row=4,
                       start_row_index=5,
                       insert_col="L",
                       start_row_sparkline_index=5,
                       sparkline_col="H",
                       end_col="BZ"):
    '''
    copy case kpi excel Aggregated column into origin kpi excel.
    :param case_kpi_excel: excel downloaded from scout case by case.
    :param origin_kpi_excel: origin kpi excel maintained by owner.
    :param sw_build: sw build of case executed.
    :param suite_timestamp: suite_test time stamps, used for all case in same suite.
    :param sheet_name: sheet name in kpi excel file.
    :param sw_build_name_row: sw build name row, default is row4.
    :param start_row_index: insert row for each case, default 5 for case1.
    :param insert_col: parameter from case kpi excel and insert into origin kpi excel column index,default L (12)
    :param start_row_sparkline_index: starting column for generate sparkline.
    :param sparkline_col: sparkline column, default is "H".
    '''

    print("=================copy_kpi_column_to_excel=================")
    # ========= 1. read case_kpi_excel column, only 500 kpi currently =========
    df = pd.read_excel(case_kpi_excel, sheet_name="Base Report")

    # column name is "Aggregated"
    data_list = df["Aggregated"].tolist()
    # print(data_list)

    # ========= 2. open origin_kpi_excel and keep charts/formulas =========
    wb = load_workbook(origin_kpi_excel)
    ws = wb[sheet_name]

    # ========= 3. insert new column, default is "M",index=13=========
    insert_col_index = column_index_from_string(insert_col)
    sw_build_with_timestamp = sw_build + "_%s" % suite_timestamp
    if sw_build_with_timestamp != ws.cell(row=sw_build_name_row, column=insert_col_index).value:
        ws.insert_cols(insert_col_index)

        # set new column name
        ws.cell(row=sw_build_name_row, column=insert_col_index, value=sw_build_with_timestamp)

    # ========= 4. write value from third row for case1, assign row index for different case =========
    for i, value in enumerate(data_list, start=start_row_index):
        ws.cell(row=i, column=insert_col_index, value=value)

    # ========= 5. save with charts and formulas =========
    kpi_excel_backup_dir_path = os.path.dirname(origin_kpi_excel) + "/kpi_template_backup"
    kpi_excel_file_name = os.path.basename(origin_kpi_excel)
    t = datetime.now().strftime("%Y%m%d%H%M%S")
    if not os.path.exists(kpi_excel_backup_dir_path):
        os.mkdir(kpi_excel_backup_dir_path)
    kpi_excel_file_backup = kpi_excel_backup_dir_path + "/%s_" % t + kpi_excel_file_name
    shutil.copy2(origin_kpi_excel, kpi_excel_file_backup)
    wb.save(origin_kpi_excel)
    # return origin_kpi_excel
    time.sleep(2)
    generate_sparkline(origin_kpi_excel, sheet_name, start_row_sparkline_index, insert_col, sparkline_col, end_col)


# generate sparkline
# levels = "¨x¨y¨z¨{¨|¨}¨~¨"
levels = "\u2581\u2582\u2583\u2584\u2585\u2586\u2587\u2588"
# print(levels)


def sparkline_text(values, levels):
    nums = [v for v in values if v is not None]
    if not nums:
        return ""

    lo, hi = min(nums), max(nums)

    span = hi - lo
    n = len(levels)
    out = []
    for v in values:
        if v is None:
            out.append(" ")
        elif lo == hi:
            out.append(levels[len(levels) // 2])
        else:
            # idx = int((v - lo) / (hi - lo) * (len(levels) - 1))
            # out.append(levels[idx])
            idx = round((v - lo) / span * (n - 1))
            out.append(levels[idx])
    return " ".join(out)


def generate_sparkline(origin_kpi_excel, sheet_name, start_row_sparkline_index=5,
                       insert_col="L", sparkline_col="H", end_col="BZ"):
    '''
    :param origin_kpi_excel: origin kpi excel maintained by owner.
    :param sheet_name: sheet name in kpi excel file.
    :param start_row_sparkline_index: starting column for generate sparkline.
    :param insert_col: parameter from case kpi excel and insert into origin kpi excel column index,default "L" (12).
    :param sparkline_col: sparkline column, default is "H".
    :param end_col: end column for sparkline, default is "BZ".
    :return: generate new origin kpi excel.
    '''
    print("=================generate_sparkline=================")
    wb = load_workbook(origin_kpi_excel)
    ws = wb[sheet_name]
    START_COL = column_index_from_string(insert_col)
    END_COL = column_index_from_string(end_col)
    TARGET_COL = column_index_from_string(sparkline_col)
    trend_font = Font(
        name="Microsoft JhengHei",
        color="2E75B6",  # blue
        size=9
    )
    START_ROW = start_row_sparkline_index
    for row in range(START_ROW, ws.max_row + 1):
        values = []
        for col in range(START_COL, END_COL + 1):
            v = ws.cell(row=row, column=col).value
            if v is None or v == "":
                values.append(None)
            else:
                try:
                    values.append(float(v))
                except ValueError:
                    values.append(None)
        trend = sparkline_text(values, levels)
        cell = ws.cell(row=row, column=TARGET_COL)
        cell.value = trend
        cell.font = trend_font
    wb.save(origin_kpi_excel)
    return origin_kpi_excel


if __name__ == '__main__':
    kpi_column_padding(
        case_kpi_excel="/home/ute/Downloads/debug_xk/case1_F_HO_SBTS26R1_ENB_0000_000434_000054_2026_02_11_22_40.xlsx",
        origin_kpi_excel="/home/ute/Downloads/debug_xk/NR_L1L2L3_Area_SpecSiteCell_25R2_v1_Daily.xlsx",
        sw_build="sbts_sw_build",
        suite_timestamp="20260311161234",
        sheet_name="SA final",
        sw_build_name_row=4,
        start_row_index=5,
        insert_col="L",
        start_row_sparkline_index=5,
        sparkline_col="H",
        end_col="BZ"
        )
