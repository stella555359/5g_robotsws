import sys
import time

from kpi_generate_report import kpi_generate_and_crawling
from kpi_column_padding import kpi_column_padding
from kpi_checker import run_kpi_check

if __name__ == '__main__':
    """
    Command line arguments:
    1. template_name: The KPI report template.
    2. report_name: The name of the KPI report.
    3. test_line: The name of the testline.
    4. package_version: The version of the package.
    5. start_time: The start time of the KPI report.
    6. end_time: The end time of the KPI report.
    7. report_excel_file_path: The file path of the generated KPI report.
    8. origin_kpi_excel: The file path of the original KPI Excel file.
    9. suite_timestamp: The suite timestamp of the KPI report.
    10. sheet_name: The name of the sheet in the KPI report.
    11. receiver_email: The email address of the receiver.
    12. sw_build_name_row: The row number of the software build name.
    13. start_row_index: The starting row index for KPI data.
    14. start_row_sparkline_index: The starting row index for sparklines.
    15. sparkline_col: The column for sparklines.
    16. kpi_value_col: The column for KPI values.
    17. kpi_name_col: The column for KPI names.
    18. kpi_rule_col: The column for KPI rules.
    19. case_kpi_excel: The excel file of the generated KPI report.
    20. kpi_value_end_col: The end column for KPI values.
    """
    template_name = sys.argv[1]
    report_name = sys.argv[2]
    test_line = sys.argv[3]
    package_version = sys.argv[4]
    start_time = sys.argv[5]
    end_time = sys.argv[6]
    report_excel_file_path = sys.argv[7]
    origin_kpi_excel = sys.argv[8]
    suite_timestamp = sys.argv[9]
    sheet_name = sys.argv[10] if sys.argv[10] != 'default' else "SA final"
    receiver_email = sys.argv[11]
    sw_build_name_row = int(sys.argv[12]) if sys.argv[12] != 'default' else 4
    start_row_index = int(sys.argv[13]) if sys.argv[13] != 'default' else 5
    start_row_sparkline_index = int(sys.argv[14]) if sys.argv[14] != 'default' else 5
    sparkline_col = sys.argv[15] if sys.argv[15] != 'default' else "H"
    kpi_value_col = sys.argv[16] if sys.argv[16] != 'default' else "L"
    kpi_name_col = sys.argv[17] if sys.argv[17] != 'default' else "D"
    kpi_rule_col = sys.argv[18] if sys.argv[18] != 'default' else "G"
    case_kpi_excel = sys.argv[19]
    kpi_value_end_col = sys.argv[20] if sys.argv[20] != 'default' else "BZ"

    print(f"template_name: {template_name}")
    print(f"report_name: {report_name}")
    print(f"test_line: {test_line}")
    print(f"package_version: {package_version}")
    print(f"start_time: {start_time}")
    print(f"end_time: {end_time}")
    print(f"report_excel_file_path: {report_excel_file_path}")
    print(f"origin_kpi_excel: {origin_kpi_excel}")
    print(f"suite_timestamp: {suite_timestamp}")
    print(f"sheet_name: {sheet_name}")
    print(f"receiver_email: {receiver_email}")
    print(f"sw_build_name_row: {sw_build_name_row}")
    print(f"start_row_index: {start_row_index}")
    print(f"start_row_sparkline_index: {start_row_sparkline_index}")
    print(f"sparkline_col: {sparkline_col}")
    print(f"kpi_value_col: {kpi_value_col}")
    print(f"kpi_name_col: {kpi_name_col}")
    print(f"kpi_rule_col: {kpi_rule_col}")
    print(f"case_kpi_excel: {case_kpi_excel}")
    print(f"kpi_value_end_col: {kpi_value_end_col}")

    """
    1. Generate KPI report based on the template and test result data.
    2. Pad KPI value column in the generated report for better visualization.
    3. Run KPI check and send email if any KPI check fails.
    """

    time.sleep(16 * 60)
    kpi_generate_and_crawling(template_name=template_name,
                              report_name=report_name,
                              test_line=test_line,
                              package_version=package_version,
                              start_time=start_time,
                              end_time=end_time,
                              report_excel_file_path=report_excel_file_path
                              )
    kpi_column_padding(case_kpi_excel=case_kpi_excel,
                       origin_kpi_excel=origin_kpi_excel,
                       sw_build=package_version,
                       suite_timestamp=suite_timestamp,
                       sheet_name=sheet_name,
                       sw_build_name_row=sw_build_name_row,
                       start_row_index=start_row_index,
                       insert_col=kpi_value_col,
                       start_row_sparkline_index=start_row_sparkline_index,
                       sparkline_col=sparkline_col,
                       end_col=kpi_value_end_col
                       )
    run_kpi_check(file=origin_kpi_excel,
                  receiver_email=receiver_email,
                  sheet_name=sheet_name,
                  start_row=start_row_index,
                  kpi_col=kpi_name_col,
                  rule_col=kpi_rule_col,
                  value_col=kpi_value_col
                  )
