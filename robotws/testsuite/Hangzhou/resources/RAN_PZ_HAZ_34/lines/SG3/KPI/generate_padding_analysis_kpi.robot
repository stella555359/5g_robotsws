*** Settings ***
Documentation    ming.shi@nokia.com

Library    OperatingSystem
Library    Process


*** Keywords ***
Run_Script_To_Generate_Padding_Analysis_KPI
    [Documentation]    ming.shi@nokia.com
    ...    This keyword runs the KPI report generation script with the provided arguments.
    ...    It constructs the command to execute the Python script and logs the output.
    ...    ${template_name} - The template name.
    ...    ${report_name} - The name of the report to be generated. report_name
    ...    ${ute_tl_id} - The TL ID of ute vm for the report. '375'
    ...    ${package_version} - The version of the package being analyzed. SBTS26R3_ENB_9999_260313_000009
    ...    ${start_time} - The start time for the analysis. '2024-06-17 00:00:00'
    ...    ${end_time} - The end time for the analysis. '2024-06-17 23:59:59'
    ...    ${report_excel_file_path} - The file path where the generated report will be saved.
    ...    /opt/workspace/SCF/report/
    ...    ${origin_kpi_excel} - The file path to the original KPI Excel file.
    ...    /opt/workspace/SCF/origin_kpi/Origin_KPI_375_SBTS26R3_ENB_9999_260313_000009.xlsx
    ...    ${suite_timestamp} - The timestamp for the test suite execution. 2024-06-17 00:00:00
    ...    ${sheet_name} - The name of the sheet in the Excel file where the KPI data will be written.
    ...    default or other sheet name, default means SA final
    ...    ${receiver_email} - The email address to receive the report. receiver_email
    ...    ${sw_build_name_row} - The row index for the software build name in the Excel sheet. default or other value, default means row 4
    ...    ${start_row_index} - The starting row index for writing KPI data in the Excel sheet. default or other value, default means row 5
    ...    ${start_row_sparkline_index} - The starting row index for writing sparkline data in the Excel sheet.
    ...    default or other value, default means row 5
    ...    ${sparkline_col} - The column index for writing sparkline data in the Excel sheet. default or other value, default means column H
    ...    ${kpi_value_col} - The column index for writing KPI values in the Excel sheet. default or other value, default means column L
    ...    ${kpi_name_col} - The column index for writing KPI names in the Excel sheet. default or other value, default means column D
    ...    ${kpi_rule_col} - The column index for writing KPI rules in the Excel sheet. default or other value, default means column G
    ...    ${case_kpi_excel} - The path puls file name where the generated report will be saved.
    ...    ${test_line} - The name of the testline.
    ...    /opt/workspace/SCF/report/Report_375_SBTS26R3_ENB_9999_260313_000009_2024-06-17.xlsx
    ...    ${kpi_value_end_col} - The end column index for writing KPI values in the Excel sheet. default or other value, default means column BZ
    [Arguments]
    ...    ${template_name}
    ...    ${report_name}
    ...    ${ute_tl_id}
    ...    ${package_version}
    ...    ${start_time}
    ...    ${end_time}
    ...    ${report_excel_file_path}
    ...    ${origin_kpi_excel}
    ...    ${suite_timestamp}
    ...    ${sheet_name}
    ...    ${receiver_email}
    ...    ${sw_build_name_row}
    ...    ${start_row_index}
    ...    ${start_row_sparkline_index}
    ...    ${sparkline_col}
    ...    ${kpi_value_col}
    ...    ${kpi_name_col}
    ...    ${kpi_rule_col}
    ...    ${case_kpi_excel}
    ...    ${test_line}
    ...    ${kpi_value_end_col}=BZ
    ${command}=    Catenate
    ...    source CIENV/7_5_UTE5G402T${ute_tl_id}/bin/activate;python ${CURDIR}/kpi_run.py
    ...    ${template_name}
    ...    '${report_name}'
    ...    ${test_line}
    ...    ${package_version}
    ...    '${start_time}'
    ...    '${end_time}'
    ...    '${report_excel_file_path}'
    ...    '${origin_kpi_excel}'
    ...    '${suite_timestamp}'
    ...    '${sheet_name}'
    ...    ${receiver_email}
    ...    ${sw_build_name_row}
    ...    ${start_row_index}
    ...    ${start_row_sparkline_index}
    ...    ${sparkline_col}
    ...    ${kpi_value_col}
    ...    ${kpi_name_col}
    ...    ${kpi_rule_col}
    ...    '${case_kpi_excel}'
    ...    ${kpi_value_end_col}
    ...    >
    ...    '${report_excel_file_path}''${report_name}'.log
    ...    2>&1
    ...    &
    ${result}=    Run Process    command=${command}    shell=${True}
    Log To Console    kpi_run.py is executed, retrun code is ${result.rc}
