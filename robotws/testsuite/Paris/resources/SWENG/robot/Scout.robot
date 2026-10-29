*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage Scout KPIs and KPIs reports
...
...             == Description ==
...             *Concepts:*
...
...                *Scout:*
...                    Scout is a network performance monitoring and analysis tool used by Nokia.
...
...                *KPI:* Key Performance Indicator
...                    - Key Performance Indicators (KPIs) in the context of 5G networks are critical for evaluating the performance,
...                        efficiency, and effectiveness of the network.
...                    - Here are some example of KPIs specific to 5G:
...                    | Latency
...                    | Throughput
...                    | Reliability
...                    | Capacity
...                    | Coverage
...                    | Mobility
...                    | Energy Efficiency
...                    | Device Density
...                    | Quality of Service (QoS)
...                    | Spectrum Efficiency
...
...                These KPIs help network operators and service providers assess the performance of their 5G networks,
...                ensure they meet the required standards, and identify areas for improvement.
...
...             *TOKEN usage for Scout*
...                 - The TOKEN is used to authenticate the user to Scout API.
...                 - The TOKEN must be stored in the environment variable %{SCOUT_API_TOKEN}.
...                 - Running your test suite with the environment variable %{SCOUT_API_TOKEN} set will allow the library to access Scout API.
...                 - The TOKEN can be set in the robot command line with the command  export SCOUT_API_TOKEN=your_token_value.
...
...                 *IMPORTANT*
...                 - The TOKEN MUST also be set in the robot scripts.
...                 - To use it in your test, retrieve it using the keyword Get Api Token.
...                 - Then set it as a suite variable or global variable named ${PERSONAL_SCOUT_TOKEN}.
...
...             *Mecanism:*
...                - The library provides keywords to retrieve KPI and KPIs report from Scout.
...                - The keywords can be used to get the last values of a specific KPI or a report containing multiple KPIs.
...                - The retrieved data is then converted into a CSV file for further analysis or reporting.
...                - The library also provides keywords to convert the retrieved data into CSV files for easy sharing and analysis.
...                - The CSV files can be saved to a specified path with a given name.
...                - The library uses the Scout TAF library via a SWENG python library to retrieve the data and convert it into a CSV format.
...                - The library provides a Keyword to evaluate constraints from a CSV file.
...                - The library provides a Keyword to update the Scout journal with the results of the evaluation.
...                - The library provides a Keyword to compare two Scout reports and generate a comparison report.
...                - The library provides a Keyword to analyze the KPI history by comparing it with the constraints defined in the given files.
...                - The library provides Keywords to enable and disable full KPI/PM collection in Scout with exception handling.
...
...                18 keywords are provided:
...                | Get Kpi History                         | Used to retrieve the last values of a specific KPI from Scout.
...                | Get Pm History                          | Used to retrieve the last values of a specific PM counter from Scout.
...                | Convert Kpi History To Csv File         | Used to convert the retrieved KPI data into a CSV file.
...                | Convert Pm History To Csv File          | Used to convert the retrieved PM counter data into a CSV file.
...                | Get Kpis Report                         | Used to retrieve a report containing multiple KPIs from Scout.
...                | Convert Kpis Report To Csv File         | Used to convert the retrieved KPIs report into a CSV file.
...                | Evaluate Constraints                    | Used to evaluate constraints from a CSV file.
...                | Evaluate Constraints Multiple Files     | Used to evaluate constraints from multiple CSV files.
...                | Get Api Token                           | Used to retrieve the API token for authenticating with the Scout API.
...                | Update Scout Journal                    | Used to update the Scout journal with the results of the evaluation.
...                | Compare Two Scout Reports               | Used to compare two Scout reports and generate a comparison report.
...                | Analyze Scout Kpi History               | Used to compare the KPI history with the constraints from the given files.
...                | Enable Full Kpi Pm Collection           | Used to enable full KPI/PM collection in Scout with exception handling.
...                | Disable Full Kpi Pm Collection          | Used to disable full KPI/PM collection in Scout with exception handling.
...                | Convert Scout Raw Report To Constraints | Used to convert a raw Scout report to a constraint file with min/max bounds.
...                | Fetch Scout Comparator Report To Excel  | Used to fetch a Scout comparator report via API and save as Excel file.
...                | Create Scout Comparator Analyzer        | Used to create a Scout comparator analyzer for constraint file generation.
...                | Create Excel Comparator                 | Used to create an Excel comparator for comparing reference and fetched files.
...
...                CSV columns:
...                | current_date
...                | step_name_suffix
...                | start_date
...                | stop_date
...                | testline_name
...                | software_load
...                | evaluation_status
...                | template_id
...
...             *Examples:*
...                | ${result} \ \ \ \ \ Get Kpi History \ \ \ \ \ ${kpi_name} \ \ \ \ \ {start_date}
...                | Convert Kpi History To Csv File \ \ \ \ ${kpi_name} \ \ \ \ ${kpi_history_res} \ \ \ \ /tmp/ \ \ \ \ ${kpi_history_name}.csv
...                | ${kpi_rep_dict} \ \ \ \ \ Get Kpis Report \ \ \ \ ${kpis_report_name_in_scout} \ \ \ \ \ ${template_id} \ \ \ \ \ ${start_date}
...                | Convert Kpis Report To Csv File \ \ \ \ ${kpi_rep_dict} \ \ \ \ /tmp/ \ \ \ \ ${kpis_report_name}.csv
...                | ${kpi_evaluate_result} \ \ \ \ \ Evaluate Constraints \ \ \ \ \ ${constraint_file} \ \ \ \ ${kpis_report_csv_file_name}
...                | ${status} \ \ \ \ \ Update Scout Journal \ \ \ \ \ ${line} \ \ \ \ ${scout_jnl_local_path} \ \ \ \ ${scout_jnl_remote_path}
...                | ${comparison_result} \ \ \  \ Compare Two Scout Reports \ \ \ \ ${template_id} \ \ \ \ ${file_path} \ \ \ \ ${remote_path}
...                | ${analysis_result} \ \ \  \ Analyze Scout Kpi History \ \ \ \ ${kpi_name} \ \ \ \ ${kpi_history_path}
...                | \ \ \ \ ${constraint_files_dir} \ \ \ \ ${constraint_files_pref}
...                | ${PERSONAL_SCOUT_TOKEN} \ \ \ \ Get Api Token
...                | ${eval_result} \ \ \ \ Evaluate Constraints Multiple Files \ \ \ \ ${constraint_file_dir} \ \ \ \ ${constraint_files_prefix}
...                | \ \ \ \ ${kpis_report_csv_file_name}
...                | ${enable_result} \ \ \ \ Enable Full Kpi Pm Collection
...                | ${disable_result} \ \ \ \ Disable Full Kpi Pm Collection
...                | ${constraint_file} \ \ \ \ Convert Scout Raw Report To Constraints \ \ \ \ ${raw_report_path} \ \ \ \ ${output_path}
...                | ${success} \ \ \ \ Fetch Scout Comparator Report To Excel \ \ \ \ ${report_id} \ \ \ \ ${output_excel_path}
...                | ${analyzer} \ \ \ \ Create Scout Comparator Analyzer \ \ \ \ ${excel_file} \ \ \ \ Chart Data
...                | ${comparator} \ \ \ \ Create Excel Comparator \ \ \ \ ${reference_file} \ \ \ \ ${fetched_file}
...


# Libraries
Library    ../python/Scout.py                            WITH NAME    sco_uti

# Resources
Resource    ./Tools.robot


*** Keywords ***


Get Api Token
    [Documentation]
    ...       Retrieve the API token used for authenticating with the Scout API.
    ...
    ...                *Definitions:*
    ...                - API token: A string value required to access the Scout API. It must be set in the environment variable %{SCOUT_API_TOKEN}.
    ...                - Dummy token: If the environment variable is not set, a dummy token is returned. This will not work with Scout API calls.
    ...                - The SCOUT_API_TOKEN variable must be set using the command export SCOUT_API_TOKEN=your_token_value before running your test
    ...                - To use it in your robot test, set it as a test suite variable or global variable.
    ...
    ...                *Arguments:*
    ...                - None.
    ...
    ...                *Returned value:*
    ...                - The API token to be used for Scout API calls. Store it in a local variable and set it as a suite or global variable for use
    ...                  in your tests.
    ...                - To set the token, use the command: export SCOUT_API_TOKEN=your_token_value before running your test suite.

    ${token}=    Get Environment Variable    SCOUT_API_TOKEN    ${EMPTY}
    IF    '${token}' == '${EMPTY}'
        Dated Log    WARNING: SCOUT_API_TOKEN environment variable is not set. Token will be retrieved from test variables.
        ${token}=    Set Variable    ${SCOUT_API_TOKEN}
    END
    [Return]    ${token}


Get Kpi History
    [Documentation]
    ...       Retrieve the last KPI history values from Scout and return them as a dictionary.
    ...
    ...                *Definitions:*
    ...                - KPI (Key Performance Indicator): A measurable value that demonstrates how effectively a network is achieving key objectives
    ...                - KPI history: Historical values of a specific KPI as collected by Scout.
    ...
    ...                *Arguments:*
    ...                - ${kpi_code}: Name of the KPI to retrieve history for.
    ...                - ${start_date}: Start date/time for the KPI history. Can be a time (e.g., "10:15:03") or a date-time
    ...                    (e.g., "2025-03-21 10:15:03").
    ...                  The interval between start_date and the current date should not be less than pm_period.
    ...                - ${stop_date}: (Optional) Stop date/time for the KPI history. Can be a time or date-time.
    ...
    ...                *Returned value:*
    ...                - Dictionary containing the KPI history values.

    [Arguments]                     ${kpi_code}    ${start_date}    ${stop_date}=None
    ${kpi_history}                  sco_uti.get_kpi_values
    ...                             kpi=${kpi_code}                 apikey=${PERSONAL_SCOUT_TOKEN}              start_date=${start_date}
    ...                             end_date=${stop_date}
    [Return]                        ${kpi_history}


Convert Kpi History To Csv File
    [Documentation]
    ...       Convert Kpi History To Csv File
    ...                *Definitions:*
    ...                - KPI history: A dictionary containing the historical values of a specific KPI retrieved from Scout.
    ...                - CSV file: A comma-separated values file used to store the KPI history for further analysis or reporting.
    ...
    ...                *Arguments:*
    ...                - ${kpi_name}: Name of the KPI used to save the generated report.
    ...                - ${imput_dictionary}: Dictionary containing the KPI history data.
    ...                - ${res_file_path}: Path where the CSV file will be saved.
    ...                - ${res_file_name}: Name of the CSV file to be created.
    ...
    ...                *Returned value:*
    ...                - The name of the CSV file containing the KPI history.

    [Arguments]                   ${kpi_name}   ${imput_dictionary}   ${res_file_path}   ${res_file_name}
    ${kpis_report_csv_file_name}    sco_uti.convert_kpi_history_to_csv   ${kpi_name}   ${imput_dictionary}   ${res_file_path}   ${res_file_name}
    [Return]                        ${kpis_report_csv_file_name}


Get Pm History
    [Documentation]
    ...       Retrieve PM counter history from Scout and return it as a dictionary.
    ...       Parallel keyword to 'Get Kpi History' for M55xxxCxxxxx counters.
    ...       Uses taf.sw.scout get_pm() under the hood.
    ...
    ...                *Definitions:*
    ...                - PM counter: A Performance Monitoring counter identified by an M55xxx code.
    ...                - PM history: Historical values of a specific PM counter as collected by Scout.
    ...
    ...                *Arguments:*
    ...                - ${pm_id}: PM counter identifier, e.g. M55113C00001.
    ...                - ${start_date}: Start date/time for the history.
    ...                  Can be a time (e.g. "10:15:03") or a date-time (e.g. "2025-03-21 10:15:03").
    ...                - ${stop_date}: (Optional) Stop date/time.
    ...                - ${interval}: (Optional) PM interval in minutes (e.g. 15).
    ...
    ...                *Returned value:*
    ...                - Dictionary containing the PM counter history values.

    [Arguments]                     ${pm_id}    ${start_date}    ${stop_date}=${None}    ${interval}=${None}
    ${pm_history}                   sco_uti.get_pm_values
    ...                             pm_id=${pm_id}                  apikey=${PERSONAL_SCOUT_TOKEN}              start_date=${start_date}
    ...                             end_date=${stop_date}           interval=${interval}
    [Return]                        ${pm_history}


Convert Pm History To Csv File
    [Documentation]
    ...       Convert PM counter history to a CSV file.
    ...       Parallel keyword to 'Convert Kpi History To Csv File' for M55xxxCxxxxx counters.
    ...
    ...                *Definitions:*
    ...                - PM history: A dictionary containing the historical values of a PM counter from Scout.
    ...                - CSV file: A comma-separated values file used to store the PM history.
    ...
    ...                *Arguments:*
    ...                - ${pm_id}: PM counter identifier used to prefix the output filename.
    ...                - ${imput_dictionary}: Dictionary containing the PM counter history data.
    ...                - ${res_file_path}: Path where the CSV file will be saved.
    ...                - ${res_file_name}: Name of the CSV file to be created.
    ...
    ...                *Returned value:*
    ...                - The full path of the CSV file containing the PM counter history.

    [Arguments]                   ${pm_id}   ${imput_dictionary}   ${res_file_path}   ${res_file_name}
    ${pm_report_csv_file_name}    sco_uti.convert_pm_history_to_csv   ${pm_id}   ${imput_dictionary}   ${res_file_path}   ${res_file_name}
    [Return]                      ${pm_report_csv_file_name}


Get Kpis Report
    [Documentation]
    ...       Retrieve Scout KPIs report values and return them as a dictionary.
    ...
    ...                *Definitions:*
    ...                - KPIs (Key Performance Indicators): Metrics used to evaluate network performance.
    ...                - Scout report: A collection of KPIs generated by the Scout tool.
    ...                - template_id: The numeric identifier of the KPI template in Scout.
    ...
    ...                For example, for template "5G TOP KPI 25R3", the Scout URL is
    ...                "https://scout.nsn-rdnet.net/kpis-templates/2238/", so template_id is "2238".
    ...
    ...                *Arguments:*
    ...                - ${report_name}: Name to save the generated report.
    ...                - ${template_id}: ID from the last part of the Scout template URL.
    ...                - ${start_date}: Start date/time (e.g. "10:15:03" or "2025-03-21 10:15:03").
    ...                  The interval between start_date and current date should not be less than pm_period.
    ...                - ${stop_date}: Stop date/time (mandatory for Scout).
    ...
    ...                *Returns:*
    ...                - Dictionary containing the KPIs report.

    [Arguments]                     ${report_name}   ${template_id}    ${start_date}    ${stop_date}
    ${kpis_report}                  sco_uti.get_kpis_report
    ...                             report_name=${report_name}     template_id=${template_id}   apikey=${PERSONAL_SCOUT_TOKEN}
    ...                             start_date=${start_date}   end_date=${stop_date}
    [Return]                        ${kpis_report}


Convert Kpis Report To Csv File
    [Documentation]
    ...       Convert Kpis Report To Csv File
    ...                *Definitions:*
    ...                - imput_dictionary: Dictionary containing the KPIs report data.
    ...                - res_file_path: Path where the CSV file will be saved.
    ...                - res_file_name: Name of the CSV file to be created.
    ...
    ...                *Arguments:*
    ...                - ${imput_dictionary}: Dictionary containing the KPIs report.
    ...                - ${res_file_path}: Path where the CSV file will be saved.
    ...                - ${res_file_name}: Name of the CSV file.
    ...
    ...                *Returned value:*
    ...                - The name of the CSV file containing the KPIs report.

    [Arguments]                     ${imput_dictionary}   ${res_file_path}   ${res_file_name}
    ${kpis_report_csv_file_name}    sco_uti.convert_kpis_report_to_csv     ${imput_dictionary}   ${res_file_path}   ${res_file_name}
    [Return]                        ${kpis_report_csv_file_name}


Evaluate Constraints
    [Documentation]
    ...       Evaluate constraints from CSV file.
    ...
    ...                *Definitions:*
    ...                - Constraint file: A file containing the constraints to be evaluated against the KPIs report.
    ...                - KPIs report CSV file: A CSV file containing the KPIs report data.
    ...
    ...                *Arguments:*
    ...                - ${constraint_file}: Name or path of the file containing the constraints.
    ...                - ${kpis_report_csv_file_name}: Name or path of the CSV file containing the KPIs report.
    ...
    ...                *Returned value:*
    ...                - The result of the evaluation (e.g., PASS/FAIL or a detailed evaluation result).

    [Arguments]                    ${constraint_file}   ${kpis_report_csv_file_name}
    ${kpi_evaluate_result}         sco_uti.evaluateConstraints   ${constraint_file}   ${kpis_report_csv_file_name}
    [Return]                       ${kpi_evaluate_result}


Evaluate Constraints Multiple Files
    [Documentation]
    ...       Evaluate constraints from multiple CSV files.
    ...
    ...                *Definitions:*
    ...                - Constraint file: A file containing the constraints to be evaluated against the KPIs report.
    ...                - KPIs report CSV file: A CSV file containing the KPIs report data.
    ...
    ...                *Arguments:*
    ...                - ${constraint_file_dir}: Directory containing the constraint files to be evaluated.
    ...                - ${constraint_files_prefix}: Prefix used to filter constraint files in the directory.
    ...                - ${kpis_report_csv_file_name}: Name or path of the CSV file containing the KPIs report.
    ...
    ...                *Returned value:*
    ...                - The result of the evaluation (e.g., PASS/FAIL or a detailed evaluation result).

    [Arguments]                ${constraint_file_dir}    ${constraint_files_prefix}   ${kpis_report_csv_file_name}
    ${kpi_evaluate_result}     sco_uti.evaluateConstraintsMulti   ${constraint_file_dir}   ${constraint_files_prefix}   ${kpis_report_csv_file_name}
    [Return]                   ${kpi_evaluate_result}


Update Scout Journal
    [Documentation]
    ...       Update Scout Journal with evaluation results.
    ...                *Definitions:*
    ...                - Scout Journal: A log file that records the results and details of KPI evaluations performed using Scout.
    ...                - Journal line: A single entry containing information about a specific evaluation or result to be added to the journal.
    ...
    ...                *Arguments:*
    ...                - ${line}: Information to be added to the journal (e.g., evaluation result, timestamp, KPI details).
    ...                - ${scout_jnl_local_path}: Local path on the VM where the Scout journal will be stored and updated.
    ...                - ${scout_jnl_remote_path}: Remote path where the Scout journal is backed up.
    ...
    ...                *Returned value:*
    ...                - ${status}: Status of the update operation (e.g., PASS or FAIL).
    [Arguments]                    ${line}     ${scout_jnl_local_path}   ${scout_jnl_remote_path}
    ${scout_journal}               sco_uti.newJournal
    ${status}                      Call Method    ${scout_journal}    add_line_to_journal
    ...                            ${line}    ${scout_jnl_local_path}    ${scout_jnl_remote_path}
    [Return]                       ${status}


Compare Two Scout Reports
    [Documentation]
    ...       Compare two Scout reports and generate a comparison report.
    ...                *Definitions:*
    ...                - Scout Report: A CSV file generated by Scout containing KPI data for a specific template and period.
    ...                - Comparison: The process of analyzing two Scout reports to identify differences or changes between two periods.
    ...
    ...                *Arguments:*
    ...                - ${template_id}: Numeric identifier of the KPI template in Scout (e.g., "2238" from the Scout template URL).
    ...                - ${file_path}: Path to the local Scout journal file to be compared.
    ...                - ${remote_path}: (Optional) Path on the remote server where the journal file can be downloaded from.
    ...                - ${first_period_description}: (Optional) Description of the first period for comparison.
    ...                - ${second_period_description}: (Optional) Description of the second period for comparison.
    ...                - If not provided, default descriptions "First Period" and "Second Period" will be used.
    ...                - ${api_token}: API token for authenticating with the Scout API. The token will be retrieved using the Get Api Token keyword.
    ...
    ...                *Returned value:*
    ...                - The result of the comparison, typically as a report or summary of differences between the two Scout reports.
    [Arguments]    ${template_id}    ${file_path}    ${remote_path}=None
    ...            ${first_period_description}=None    ${second_period_description}=None
    ${scout_journal}               sco_uti.newJournal
    ${api_token}                  Get Api Token
    ${comparison_result}           Call Method     ${scout_journal}    generate_comparator_report
    ...                            ${template_id}    ${file_path}    ${remote_path}    ${first_period_description}
    ...                            ${second_period_description}    apikey=${api_token}
    Log    Arguments: ${template_id}, ${file_path}, ${remote_path}, ${first_period_description}, ${second_period_description}, ${api_token}
    Log    generate_comparator_report result: ${comparison_result}
    [Return]    ${comparison_result}


Analyze Scout Kpi History
    [Documentation]
    ...       Analyze the KPI history by comparing it with the constraints defined in the constraint files.
    ...
    ...                *Arguments:*
    ...                - ${kpi_name}: The name of the KPI to analyze.
    ...                - ${path_history}: The path to the CSV file containing the KPI history.
    ...                - ${constraint_files_dir}: The directory containing the constraint files.
    ...                - ${constraint_files_pref}: The prefix of the constraint files to consider.
    ...
    ...                *Returned value:*
    ...                - The result of the KPI history analysis.
    [Arguments]    ${kpi_name}    ${path_history}    ${constraint_files_dir}    ${constraint_files_pref}
    ${result}    sco_uti.scout_kpi_history_analyzer    ${kpi_name}    ${path_history}    ${constraint_files_dir}    ${constraint_files_pref}
    Log    Arguments: ${kpi_name}, ${path_history}, ${constraint_files_dir}, ${constraint_files_pref}
    Log    scout_kpi_history_analyzer result: ${result}
    [Return]    ${result}

Enable Full Kpi Pm Collection
    [Documentation]
    ...    Enable full KPI/PM collection in Scout with exception handling.
    ...    Returns True if successful, False otherwise.
    ${api_token}                  Get Api Token
    ${result}=    sco_uti.enable_full_kpi_pm_collection    ${api_token}
    [Return]      ${result}

Disable Full Kpi Pm Collection
    [Documentation]
    ...    Disable full KPI/PM collection in Scout with exception handling.
    ...    Returns True if successful, False otherwise.
    ${api_token}                  Get Api Token
    ${result}=    sco_uti.disable_full_kpi_pm_collection    ${api_token}
    [Return]      ${result}


Convert Scout Raw Report To Constraints
    [Documentation]
    ...       Convert a raw Scout report CSV to a constraint file with calculated min/max bounds.
    ...
    ...                *Definitions:*
    ...                - Raw Scout report: A CSV file exported from Scout containing historical KPI values with columns:
    ...                  DistName, EntryName, GroupName, TimeStamp, Value.
    ...                - Constraint file: A formatted CSV file with min/max bounds for each counter/KPI, grouped by family
    ...                  (e.g., Accessibility, Integrity, Mobility). Used for automated KPI validation.
    ...                - Family-based deviations: Percentage adjustments applied to raw min/max values based on KPI family:
    ...                  * Accessibility: ±0.5% (very strict)
    ...                  * Integrity: ±5.0% (medium tolerance)
    ...                  * Mobility: ±1.0% (strict)
    ...                  * Retainability: ±1.0% (strict)
    ...                  * Usage - Utilization: ±5.0% (higher tolerance)
    ...                  * Usage - Capacity: ±5.0% (higher tolerance)
    ...                  * Usage - Energy Efficiency: ±1.0% (strict)
    ...                  * Default: ±5.0% (for unlisted families)
    ...
    ...                *Arguments:*
    ...                - ${raw_report_path}: Path to the raw Scout report CSV file (input).
    ...                  Expected format: CSV with columns ,DistName,EntryName,GroupName,TimeStamp,Value.
    ...                  Example: /home/user/Public/my_lab/raw_scout_report.csv
    ...                - ${output_path}: (Optional) Path where the constraint file will be saved.
    ...                  If not provided, defaults to "constraint_<input_filename>.csv" in the same directory as the input.
    ...                  Example: /tmp/constraints.csv
    ...
    ...                *Process:*
    ...                1. Parse raw Scout report and extract OAM IDs (NRCELL, NRBTS) and counter codes
    ...                2. Group data by counter and family, calculate raw min/max values
    ...                3. Apply family-specific deviation percentages to create min/max bounds
    ...                4. Write formatted constraint file with family sections in specific order:
    ...                   Usage - Energy Efficiency, Accessibility, Retainability, Mobility,
    ...                   Integrity, Usage - Utilization, Usage - Capacity
    ...
    ...                *Output format:*
    ...                Header: #oam_id        ; Counter_or_KPI;       Min;       Max; Variant;   Comment from MIND/JUMP
    ...                Family sections with "# ===== <Family Name> =====" headers
    ...                Data lines: <oam_id>; <counter>; <min>; <max>; <variant>; <comment>
    ...
    ...                *Returned value:*
    ...                - The path to the generated constraint file.
    ...                - Returns None if parsing or writing fails.
    ...
    ...                *Example:*
    ...                | ${constraint_file}= | Convert Scout Raw Report To Constraints | /tmp/raw_scout_report.csv | /tmp/constraints.csv |

    [Arguments]    ${raw_report_path}    ${output_path}=None
    ${parser}=    _Create Scout Report Parser    ${raw_report_path}    ${output_path}
    ${result_path}=    _Convert Scout Report    ${parser}
    [Return]    ${result_path}


_Create Scout Report Parser
    [Documentation]    Internal keyword: Create ScoutReportParser instance
    [Arguments]    ${input_file}    ${output_file}=None
    ${parser}=    sco_uti.new_scout_report_parser    ${input_file}    ${output_file}
    [Return]    ${parser}


_Convert Scout Report
    [Documentation]    Internal keyword: Execute conversion using parser instance
    [Arguments]    ${parser}
    ${result}=    Call Method    ${parser}    convert
    [Return]    ${result}


Fetch Scout Comparator Report To Excel
    [Documentation]
    ...       Fetch a Scout comparator report via API and save it as an Excel file.
    ...
    ...                *Definitions:*
    ...                - Comparator report: A Scout report that compares KPI data between two time periods (reference vs current).
    ...                - Report ID: Unique identifier for the comparator report in Scout (found in the Scout URL).
    ...                - Excel file: Output file containing the formatted comparator data with KPI values, statistics, and comparison results.
    ...
    ...                *Arguments:*
    ...                - ${report_id}: The Scout comparator report ID (e.g., "1165894").
    ...                  This ID can be found in the Scout URL: https://scout.nsn-rdnet.net/comparator-reports/1165894/
    ...                - ${output_path}: Path where the Excel file will be saved (e.g., "/tmp/comparator_report.xlsx").
    ...                - ${testline_name}: (Optional) Scout testline name (not currently used, reserved for future use). Default: None
    ...                - ${expected_kpis}: (Optional) List of KPI codes to filter (e.g., ['NR_5055c', 'NR_5057e']).
    ...                  If None, all KPIs from the report are included. Default: None
    ...                - ${expected_dist_names}: (Optional) List of distribution/entity names to filter (e.g., ['bts', 'NRCELL-1']).
    ...                  If None, all entities from the report are included. Default: None
    ...
    ...                *Returned value:*
    ...                - True if the report was successfully fetched and saved, False otherwise.
    ...
    ...                *Note:*
    ...                - This keyword automatically uses the Scout API token retrieved via Get Api Token.
    ...                - The generated Excel will contain columns matching the Scout web UI format:
    ...                  Code, Name, Dist Name, Range, Values, Unit, Count, Min, Max, Average, Avg Diff, Median, etc.
    ...                - Filters (expected_kpis and expected_dist_names) are optional and can be used independently.
    ...                - Backward compatible: existing calls without filter parameters will work unchanged.
    ...
    ...                *Examples:*
    ...                | ${PERSONAL_SCOUT_TOKEN}= | Get Api Token |
    ...                | ${success}= | Fetch Scout Comparator Report To Excel | 1165894 | /tmp/scout_report.xlsx |
    ...                |
    ...                | # With KPI filter |
    ...                | ${success}= | Fetch Scout Comparator Report To Excel | 1165894 | /tmp/report.xlsx | None | ['NR_5055c'] |
    ...                |
    ...                | # With entity filter |
    ...                | ${success}= | Fetch Scout Comparator Report To Excel | 1165894 | /tmp/report.xlsx | None | None | ['bts', 'NRCELL-1'] |
    ...                |
    ...                | # With both filters |
    ...                | ${success}= | Fetch Scout Comparator Report To Excel | 1165894 | /tmp/report.xlsx | None | ['NR_5055c'] | ['bts'] |

    [Arguments]    ${report_id}    ${output_path}    ${testline_name}=None    ${expected_kpis}=None    ${expected_dist_names}=None
    ${api_token}=    Get Api Token
    ${result}=    sco_uti.fetch_comparator_report_and_save_excel
    ...    ${report_id}    ${output_path}    ${expected_kpis}    ${expected_dist_names}    ${testline_name}    ${api_token}
    [Return]    ${result}


Create Scout Comparator Analyzer
    [Documentation]
    ...       Create a Scout Comparator Analyzer instance for analyzing Excel comparator reports and generating constraint files.
    ...
    ...                *Definitions:*
    ...                - Scout Comparator Analyzer: A tool that analyzes Scout comparator Excel reports (Chart Data or Comparator Details tabs)
    ...                  and generates constraint CSV files with min/max bounds for automated KPI validation.
    ...                - Excel file: Input Scout comparator report in Excel format.
    ...                - Sheet name: Name of the Excel sheet to analyze (default: 'Chart Data').
    ...                - Legacy mode: If True, comments out NRBTS entries and None/None constraints in the output.
    ...
    ...                *Arguments:*
    ...                - ${excel_file}: Path to the Scout comparator Excel file.
    ...                - ${sheet_name}: (Optional) Name of the sheet to analyze. Default is 'Chart Data'.
    ...                  If not provided, will auto-detect between 'Chart Data' and 'Comparator Details' formats.
    ...                - ${legacy_mode}: (Optional) Boolean flag. If True, applies legacy formatting rules. Default is False.
    ...
    ...                *Returned value:*
    ...                - A ScoutComparatorAnalyzer instance that can be used with Call Method to:
    ...                  * load_data() - Load Excel data from the specified sheet
    ...                  * analyze_chart_data() - Analyze data and build internal data dictionary
    ...                  * generate_constraint_file(output_file) - Generate constraint CSV file from analyzed data
    ...
    ...                *Process:*
    ...                1. Create analyzer instance with this keyword
    ...                2. Call Method ${analyzer} load_data - Load the Excel file
    ...                3. Call Method ${analyzer} analyze_chart_data - Analyze the data
    ...                4. Call Method ${analyzer} generate_constraint_file ${output_path} - Generate constraint file
    ...
    ...                *Example:*
    ...                | ${analyzer}= | Create Scout Comparator Analyzer | /tmp/scout_report.xlsx | Chart Data | False |
    ...                | ${load_ok}= | Call Method | ${analyzer} | load_data |
    ...                | ${analyze_ok}= | Call Method | ${analyzer} | analyze_chart_data |
    ...                | ${constraint_file}= | Call Method | ${analyzer} | generate_constraint_file | /tmp/constraints.csv |

    [Arguments]    ${excel_file}    ${sheet_name}=Chart Data    ${legacy_mode}=False
    ${analyzer}=    sco_uti.new_scout_comparator_analyzer    ${excel_file}    ${sheet_name}    ${legacy_mode}
    [Return]    ${analyzer}


Create Excel Comparator
    [Documentation]
    ...       Create an Excel Comparator instance for comparing reference and fetched Excel files.
    ...
    ...                *Definitions:*
    ...                - Excel Comparator: A tool that validates Excel files by comparing column structures and data formats
    ...                  between a reference file (expected format) and a fetched file (actual format).
    ...                - Reference file: Template Excel file with the expected column structure and format.
    ...                - Fetched file: Actual Excel file to be validated against the reference.
    ...
    ...                *Arguments:*
    ...                - ${reference_file}: (Optional) Path to the reference Excel file with expected format.
    ...                - ${fetched_file}: (Optional) Path to the fetched Excel file to validate.
    ...
    ...                *Returned value:*
    ...                - An ExcelComparator instance that can be used with Call Method to:
    ...                  * load_files() - Load both reference and fetched Excel files
    ...                  * compare_columns() - Compare column names between reference and fetched files
    ...                  * validate_data_formats() - Validate data formats for key columns
    ...                  * generate_comparison_report(verbose=True) - Generate comprehensive comparison report
    ...                  * get_first_n_rows(n, columns_limit) - Get first N rows of fetched data
    ...
    ...                *Process:*
    ...                1. Create comparator instance with this keyword (files can be set later)
    ...                2. Call Method ${comparator} load_files - Load both Excel files
    ...                3. Call Method ${comparator} generate_comparison_report ${verbose} - Generate full comparison
    ...
    ...                *Example:*
    ...                | ${comparator}= | Create Excel Comparator | /tmp/reference.xlsx | /tmp/fetched.xlsx |
    ...                | ${load_ok}= | Call Method | ${comparator} | load_files |
    ...                | ${report}= | Call Method | ${comparator} | generate_comparison_report | ${True} |
    ...                | Log | Comparison success: ${report['success']} |

    [Arguments]    ${reference_file}=None    ${fetched_file}=None
    ${comparator}=    sco_uti.new_excel_comparator    ${reference_file}    ${fetched_file}
    [Return]    ${comparator}
