import os
import time
import re
import requests
import pandas as pd
from Hosts import Host
from taf.sw.scout import scout as taf_scout
from taf.transport.ssh import connect
from taf.sw.scout.api import ScoutApiException, PostRequestException
from taf.sw.reporting_portal.interface import reporting_portal
from robot.api import logger
import PandasCsv as pcsv
from OsTool import get_testline_name
from KPIs import TLConfig, Log, ConstraintFile, Kpi, Var

# Machine UTE locally allocated to NPS used to access Titan server via a /mnt/titan mount point
# This is used to store the journal files, the counters, the kpis, the Jenkins logs, etc
# Remote connection details
REMOTE_TITAN_MOUNT_HOST = "10.14.38.159"
REMOTE_USER = "ute"
REMOTE_CRED = "ute"
COLUMN_NAMES = ["current_date", "step_name_suffix", "start_date", "stop_date",
                "testline_name", "software_load", "evaluation_status", "template_id"]
CONSTR_TEMP_FILE = '/tmp/summary.csv'
CONSTR_TEMP_FILE_CLEAN = '/tmp/summary_clean.csv'
RP_PORTAL = reporting_portal()


def enable_full_kpi_pm_collection(apikey, alias='default'):
    """
    Enable Full KPI/PM Collection with exception handling.
    :param alias: Name of execution context. Default is 'default'.
    :return: True if enabled, False otherwise.
    """
    try:
        tafscout = taf_scout()
        tl_name = get_testline_name()
        tafscout.setup_scout(scout_testline_name=tl_name, api_key=apikey, timeout=300)
        scout_api = tafscout.store.get_alias_value(alias)
        scout_api.switch_full_kpi_pm_collection(enable=True)
        return True
    except (ScoutApiException, PostRequestException, Exception) as e:
        logger.error(f"Failed to enable full KPI/PM collection: {e}")
        return False
    finally:
        tafscout.teardown_scout_api()


def disable_full_kpi_pm_collection(apikey, alias='default'):
    """
    Disable Full KPI/PM Collection with exception handling.
    :param alias: Name of execution context. Default is 'default'.
    :return: True if disabled, False otherwise.
    """
    try:
        tafscout = taf_scout()
        tl_name = get_testline_name()
        tafscout.setup_scout(scout_testline_name=tl_name, api_key=apikey, timeout=300)
        scout_api = tafscout.store.get_alias_value(alias)
        scout_api.switch_full_kpi_pm_collection(enable=False)
        return True
    except (ScoutApiException, PostRequestException, Exception) as e:
        logger.error(f"Failed to disable full KPI/PM collection: {e}")
        return False
    finally:
        tafscout.teardown_scout_api()


def convert_kpi_history_to_csv(kpi_name, history, path, file_name):
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    history = history[1] if isinstance(history, tuple) and len(history) > 1 else history
    df = pd.DataFrame(history)
    new_filename = f"{kpi_name}_{file_name}"
    full_file_name = os.path.join(path, new_filename)
    with open(full_file_name, mode='w', newline='') as file:
        file.write(f"kpi_name: {kpi_name}\n\n")
        df.to_csv(file, index=False)
        logger.info(f"Scout history saved to {full_file_name}")
    return full_file_name


def convert_pm_history_to_csv(pm_id, history, path, file_name):
    """
    Parallel to convert_kpi_history_to_csv() — for PM counters (M55xxxCxxxxx).
    Converts the Scout PM counter history to a CSV file.
    :param pm_id:      PM counter identifier (e.g. 'M55113C00001')
    :param history:    Scout PM report as returned by get_pm_values()
    :param path:       Directory where the CSV will be written
    :param file_name:  Output CSV filename
    :return:           Full path of the written CSV file
    """
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    history = history[1] if isinstance(history, tuple) and len(history) > 1 else history
    df = pd.DataFrame(history)
    # Rename 'dist' → 'level' and extract the last segment after the final '/'
    if 'dist' in df.columns:
        df.rename(columns={'dist': 'level'}, inplace=True)
    if 'level' in df.columns:
        df['level'] = df['level'].astype(str).apply(lambda x: x.rsplit('/', 1)[-1])
        # Reorder columns: create_time, level, value (+ any remaining columns)
        cols = list(df.columns)
        ordered = []
        for c in ['create_time', 'level', 'value']:
            if c in cols:
                ordered.append(c)
        ordered += [c for c in cols if c not in ordered]
        df = df[ordered]
    new_filename = f"{pm_id}_{file_name}"
    full_file_name = os.path.join(path, new_filename)
    with open(full_file_name, mode='w', newline='') as file:
        file.write(f"pm_id: {pm_id}\n\n")
        df.to_csv(file, index=False)
        logger.info(f"Scout PM history saved to {full_file_name}")
    return full_file_name


def convert_kpis_report_to_df(data):
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    actual_data = data[1] if isinstance(data, tuple) and len(data) > 1 else data
    df = pd.json_normalize(
        actual_data,
        record_path=['report'],
        meta=['type', 'id', 'name', 'start_time', 'end_time', 'create_time'],
        meta_prefix='meta_'
    )
    return df, actual_data[0]


def convert_kpis_report_to_csv(data, path, file_name):
    full_file_name = os.path.join(path, file_name)
    df, actual_data = convert_kpis_report_to_df(data)
    with open(full_file_name, mode='w', newline='') as file:
        file.write(f"type: {actual_data['type']}\n")
        file.write(f"id: {actual_data['id']}\n")
        file.write(f"name: {actual_data['name']}\n")
        file.write(f"start_time: {actual_data['start_time']}\n")
        file.write(f"end_time: {actual_data['end_time']}\n")
        file.write(f"create_time: {actual_data['create_time']}\n\n")
        df.to_csv(file, index=False)
        logger.info(f"Scout report saved to {full_file_name}")
    return full_file_name


def get_kpi_values(kpi, apikey, start_date, end_date=None, timeout=900, retry_interval=30):
    tafscout = taf_scout()
    try:
        tl_name = get_testline_name()
        tafscout.setup_scout(scout_testline_name=tl_name, api_key=apikey, timeout=300)
        start_time_check = time.time()
        scout_report = None
        while scout_report is None and (time.time() - start_time_check) < timeout:
            scout_report = tafscout.get_kpi(kpi_code=kpi, start_time=start_date, end_time=end_date)
            if scout_report is None:
                time.sleep(retry_interval)
        if scout_report is None:
            logger.info(f"Timeout - KPI: {kpi} not catch from Scout", also_console=True)
            return None, None
        logger.info(f"\n scout report:\n {scout_report}", also_console=False)
        return scout_report
    finally:
        tafscout.teardown_scout_api()


def get_pm_values(pm_id, apikey, start_date, end_date=None, interval=None, timeout=900, retry_interval=30):
    """
    Parallel to get_kpi_values() — for PM counters (M55xxxCxxxxx).
    :param pm_id:          PM counter identifier (e.g. 'M55113C00001')
    :param apikey:         Scout API token
    :param start_date:     Start time, e.g. '2025-03-21 10:00:00'
    :param end_date:       End time (optional)
    :param interval:       PM interval in minutes, e.g. 15 (optional, passed to taf get_pm)
    :param timeout:        Max seconds to wait for Scout response
    :param retry_interval: Seconds between retries
    :return:               Scout PM report, or (None, None) on timeout
    """
    tafscout = taf_scout()
    try:
        tl_name = get_testline_name()
        tafscout.setup_scout(scout_testline_name=tl_name, api_key=apikey, timeout=300)
        start_time_check = time.time()
        scout_report = None
        while scout_report is None and (time.time() - start_time_check) < timeout:
            scout_report = tafscout.get_pm(pm_id=pm_id,
                                           start_time=start_date,
                                           end_time=end_date,
                                           interval=interval)
            if scout_report is None:
                time.sleep(retry_interval)
        if scout_report is None:
            logger.info(f"Timeout - PM counter: {pm_id} not caught from Scout", also_console=True)
            return None, None
        logger.info(f"\n scout pm report:\n {scout_report}", also_console=False)
        return scout_report
    finally:
        tafscout.teardown_scout_api()


def get_kpis_report(report_name, template_id, apikey, start_date, end_date, timeout=300,
                    retry_interval=30):
    """
    Argument:
        report_name :    this is the name of the file choosen to save the generated report
        template_id :    is number present in last part of URL address of the scout template web page
                         Example for template "5G TOP KPI 25R3"
                         the URL in the template web page is "https://scout.nsn-rdnet.net/kpis-templates/2238/"
                         So that argument "template_id" value, here will be : "2238"
        start_date :     Can be only a time or also "date time"
                         Example : 10:15:03 or 2025-03-21 10:15:03 are both acceptable.
                         Note that start date and current date interval should not be less than pm_period.
        end_date :       Can be only a time or also "date time", mandatory argument.
        timeout :        is the time in seconds to wait for the report to be generated
        retry_interval : is the time in seconds to wait between each retry to get the report
        apikey :         is the API key to access the scout API
        :return: KPI report as a dictionary
    """
    tafscout = taf_scout()
    try:
        tl_name = get_testline_name()
        tafscout.setup_scout(scout_testline_name=tl_name, api_key=apikey, timeout=timeout)
        start_time_check = time.time()
        scout_report = None
        while scout_report is None and (time.time() - start_time_check) < timeout:
            scout_report = tafscout.generate_kpi_report(
                report_name=report_name, template_id=template_id, start_time=start_date, end_time=end_date)
            if scout_report is None:
                time.sleep(retry_interval)
        if scout_report is None:
            logger.info("Timeout - KPI not catched from Scout", also_console=True)
            return None, None
        logger.info(f"\n scout report:\n {scout_report}", also_console=False)
        return scout_report
    finally:
        tafscout.teardown_scout_api()


def get_kpis_report_from_file(reportFile, string_to_remove=""):
    """
    Read a CSV file and return a pandas DataFrame containing the data.
    Parameters:
    - reportFile (str): The path to the CSV file.
    - string_to_remove (str): (Optional) A string to remove from all column names.
    Returns:
    - df_report (pandas.DataFrame): The DataFrame containing the data from the CSV file.
    """
    pd = pcsv.import_with_auto_install(['pandas'])[0]
    with open(reportFile, 'r') as file:
        # Find the line number where the column names start
        for i, line in enumerate(file):
            if line.strip().startswith("code,group_name"):  # Adjust this to match your column names
                header_rows = i
                break
    # Read the CSV starting from the detected header row
    df_report = pd.read_csv(reportFile, skiprows=header_rows)
    # Remove a given string from all column names
    if string_to_remove:
        # Remove the specified string from all column names
        df_report.columns = df_report.columns.str.replace(string_to_remove, '', regex=False)
    return df_report


def normalize_kpi_name(kpi_name):
    """
    Normalize KPI aliases to the constraint-file naming format.

    Examples:
    - NR_1234a -> NR_1234
    - SCOUT_NR123a -> NR_123
    - SCOUT_NR1234_Else -> NR_1234
    - SCOUT_NR1234a_Else -> NR_1234
    """
    normalized_name = str(kpi_name).strip()
    nr_match = re.search(r'(?:SCOUT_)?NR_?(\d+)', normalized_name, re.IGNORECASE)
    if nr_match:
        return f"NR_{nr_match.group(1)}"
    return re.sub(r'[a-z]$', '', normalized_name)


def scout_kpi_history_analyzer(kpi_name, path_history, constraint_files_dir, constraint_files_pref):
    """
    Analyze the KPI history by comparing it with the constraints defined in the constraint files.
    Parameters:
    - kpi_name (str): The name of the KPI to analyze.
    - path_history (str): The path to the CSV file containing the KPI history.
    - constraint_files_dir (str): The directory containing the constraint files.
    - constraint_files_pref (str): The prefix of the constraint files to consider.
    :return: A string indicating the validity of the KPI.
        string used to improve Robot compatibility
    """
    short_kpi_name = normalize_kpi_name(kpi_name)
    logger.info(f"KPI name normalization: {kpi_name} -> {short_kpi_name}")
    # Read the constraint files and concatenate them into a single DataFrame
    constraints_kpi = fill_constraints_dataframes(short_kpi_name, constraint_files_dir, constraint_files_pref)
    if constraints_kpi.empty:
        print(f"ERROR: No valid constraints found for {kpi_name} (normalized: {short_kpi_name})")
        is_valid = False
        return str(is_valid)
    means_df = fill_means_dataframe(path_history)
    results = conformity_checks(constraints_kpi, means_df, short_kpi_name)
    # check results validity
    is_valid = is_result_valid(results)
    return str(is_valid)


def fill_constraints_dataframes(kpi_name, constraint_files_dir, constraint_files_pref):
    """
    Read the constraint files and concatenate them into a single DataFrame.
    """
    column_names = ["level", "kpi_name", "min", "max", "scope", "description"]
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    constraints = join_constraints_dfs(constraint_files_dir, constraint_files_pref, column_names)
    short_kpi_name = normalize_kpi_name(kpi_name)
    logger.trace(f"short_kpi_name: {short_kpi_name}")
    logger.debug(f"Available kpi_name values: {constraints['kpi_name'].unique().tolist()}")
    print(f"Available kpi_name values: {constraints['kpi_name'].unique().tolist()}")
    # Check short_kpi_name is present in constraints['kpi_name'] colomn
    if short_kpi_name not in constraints["kpi_name"].values:
        logger.warn(f"{short_kpi_name} not found in constraints['kpi_name']")
        print(f"{short_kpi_name} not found in constraints['kpi_name']")
        constraints_kpi = pd.DataFrame()  # Empty DataFrame if no match found
    else:
        constraints_kpi = constraints[constraints["kpi_name"].str.strip() == short_kpi_name].copy()
        return constraints_kpi
    return constraints_kpi


def fill_means_dataframe(path_history):
    """
    Calculate mean values for each level from a KPI history CSV file.

    This function processes Scout KPI history data where some objects may have numeric measurements
    while others may have no values (empty cells). It distinguishes between levels that have at
    least some numeric data versus levels where all values are empty.

    Args:
        path_history (str): Absolute path to the KPI history CSV file.
                           Expected format:
                           - Line 1: kpi_name: <name>
                           - Line 2: empty
                           - Line 3+: create_time,level,value
                           Example:
                               kpi_name: NR_5151d

                               create_time,level,value
                               2025-12-04T13:45,NRCELL-6,
                               2025-12-04T13:45,bts,100
                               2025-12-04T13:45,NRCELL-1,100

    Returns:
        pandas.Series: A Series indexed by level with the following values:
                      - float: Mean of all numeric (non-empty) values for that level
                      - None: If all values are empty for that level (no numeric data)
                      - Empty Series: If 'value' column is not found in the file

    Behavior:
        - Groups data by 'level' column
        - For each level, filters out NaN/empty values
        - If numeric values exist: calculates and returns their mean
        - If all values are empty: returns None for that level
        - Logs detailed information about each level (count of values, mean, or empty status)

    Example:
        Input CSV content:
            create_time,level,value
            2025-12-04T13:45,NRCELL-6,
            2025-12-04T13:45,NRCELL-6,
            2025-12-04T13:45,bts,100
            2025-12-04T13:45,bts,102
            2025-12-04T13:45,NRCELL-1,98

        Output Series:
            NRCELL-6    None
            bts         101.0
            NRCELL-1    98.0

    Notes:
        - Skips first line (skiprows=1) to skip the kpi_name header
        - Uses pd.to_numeric with errors='coerce' to convert values (empty strings become NaN)
        - Preserves information about empty values (doesn't drop them before grouping)
        - Critical for proper validation of constraints that allow empty values
    """
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    history_df = pd.read_csv(path_history, skiprows=1)
    history_df.columns = history_df.columns.str.strip()

    print(f"Available columns: {history_df.columns.tolist()}")
    if "value" not in history_df.columns:
        logger.error(f"ERROR : column 'value' not found. Available columns : {history_df.columns.tolist()}")
        return pd.Series()

    # Convert to numeric, keeping NaN for empty values
    history_df["value"] = pd.to_numeric(history_df["value"], errors='coerce')

    # Group by level and calculate mean, counting empty values
    means_dict = {}
    for level, group in history_df.groupby("level"):
        non_empty_values = group["value"].dropna()
        if len(non_empty_values) > 0:
            # If there are numeric values, calculate mean
            means_dict[level] = non_empty_values.mean()
            logger.info(f"Level {level}: {len(non_empty_values)} numeric values, mean = {means_dict[level]:.2f}")
        else:
            # All values are empty for this level
            means_dict[level] = None
            logger.info(f"Level {level}: All values are empty (None)")

    logger.info(f"Total levels processed: {len(means_dict)}")
    return pd.Series(means_dict)


def conformity_checks(constraints_kpi, means_df, kpi_name):
    """
    Validate KPI mean values against defined constraints with support for empty values.

    This function implements a 4-case validation logic that handles both numeric and empty values:

    +-----------------------+-------------------+----------------------------------+
    | Constraint Type       | Value Type        | Result                           |
    +-----------------------+-------------------+----------------------------------+
    | None, None            | Empty (None/NaN)  | PASS (empty is acceptable)       |
    | None, None            | Numeric           | FAIL (value should be empty)     |
    | Numeric (min, max)    | Empty (None/NaN)  | FAIL (value is required)         |
    | Numeric (min, max)    | Numeric           | PASS/FAIL (range check)          |
    +-----------------------+-------------------+----------------------------------+

    Args:
        constraints_kpi (pandas.DataFrame): DataFrame containing constraint definitions.
                                           Required columns:
                                           - level: Object identifier (e.g., "NRCELL[@id='6']")
                                           - kpi_name: KPI code (e.g., "NR_5151")
                                           - min: Minimum acceptable value or "None"
                                           - max: Maximum acceptable value or "None"
                                           - scope: Constraint scope (e.g., "ALL")
                                           - description: Human-readable description

        means_df (pandas.Series): Series of mean values indexed by level.
                                 Values can be:
                                 - float: Mean of numeric measurements
                                 - None/NaN: All measurements were empty

        kpi_name (str): Name of the KPI being validated (may include version suffix like 'a', 'b')
                       Suffix will be removed for constraint matching.

    Returns:
        list of tuples: List of (level, mean_value, conformity) tuples where:
                       - level (str): Object identifier (e.g., "NRCELL-6", "bts")
                       - mean_value (float or None): The calculated mean or None
                       - conformity (bool or None): True if constraint met, False if violated,
                                                    None if no constraint found for this level

    Behavior:
        1. Removes version suffix from kpi_name (e.g., "NR_5151a" → "NR_5151")
        2. Normalizes constraint levels for matching (e.g., "NRCELL[@id='6']" → "NRCELL-6")
        3. For each level in means_df:
           - Searches for matching constraint (by level and kpi_name)
           - Applies 4-case validation logic
           - Logs detailed PASS/FAIL result with reasoning
           - Appends result to output list
        4. Special case: "bts" level matches "NRBTS-" constraints

    Examples:
        Input:
            constraints_kpi:
                level                  kpi_name  min   max   scope  description
                NRCELL[@id='6']       NR_5151   None  None  ALL    Empty OK
                NRCELL[@id='1']       NR_5151   90    110   ALL    Numeric range
                NRBTS[@id='1']        NR_5151   95    105   ALL    BTS range

            means_df:
                NRCELL-6    None
                NRCELL-1    100.0
                bts         102.0

        Output:
            [('NRCELL-6', None, True),      # Empty value OK with None/None constraint
             ('NRCELL-1', 100.0, True),     # 100 is within [90, 110]
             ('bts', 102.0, True)]          # 102 is within [95, 105]

    Notes:
        - Constraint min/max comparison is case-insensitive ("None", "none", "NONE" all work)
        - Prints detailed validation logs for debugging (level, value, constraint, result)
        - Returns None for conformity if no matching constraint found
        - Uses pd.isna() to properly detect both None and NaN values
        - Critical for validating Scout KPI data where empty values may be expected

    See Also:
        fill_means_dataframe(): Produces the means_df input for this function
        is_result_valid(): Validates the overall conformity results
    """
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    results = []
    kpi_name = normalize_kpi_name(kpi_name)
    constraints_kpi = constraints_kpi.copy()
    constraints_kpi["level_norm"] = constraints_kpi["level"].apply(normalize_constraint_level)

    for level, mean_value in means_df.items():
        constraint_found = False
        for _, row in constraints_kpi.iterrows():
            # Only match constraints for the current kpi_name
            if str(row["kpi_name"]).strip() != kpi_name.strip():
                continue

            constraint_level = str(row["level_norm"])
            if constraint_level == level or (constraint_level.startswith("NRBTS-") and level.startswith("bts")):
                constraint_found = True
                print(f"\nChecking conformity for level: {level}")
                print(f"  Mean value: {mean_value}")
                print(f"  Constraint: min={row['min']}, max={row['max']}")

                # Check if constraint min/max are empty (None or NaN)
                # This handles both string "None" and pandas NaN
                is_min_empty = pd.isna(row["min"]) or str(row["min"]).strip().lower() in ['none', 'nan']
                is_max_empty = pd.isna(row["max"]) or str(row["max"]).strip().lower() in ['none', 'nan']

                if is_min_empty and is_max_empty:
                    # Constraint is "None, None" - empty values are acceptable
                    if mean_value is None or pd.isna(mean_value):
                        conformity = True
                        print(f"  Result: PASS (empty value is acceptable with None/None constraint)")
                    else:
                        # Value is numeric but constraint expects None
                        conformity = False
                        print(f"  Result: FAIL (numeric value {mean_value} found but None/None expected)")
                else:
                    # Constraint has numeric min/max
                    if mean_value is None or pd.isna(mean_value):
                        # Value is empty but constraint expects numeric
                        conformity = False
                        print(f"  Result: FAIL (empty value but numeric constraint expected)")
                    else:
                        # Both value and constraint are numeric
                        try:
                            min_val = float(row["min"])
                            max_val = float(row["max"])
                            conformity = min_val <= mean_value <= max_val
                            print(f"  Result: {'PASS' if conformity else 'FAIL'} "
                                  f"(value {mean_value:.2f} vs range [{min_val}, {max_val}])")
                        except (ValueError, TypeError) as e:
                            print(f"  Result: ERROR (cannot parse min/max: {e})")
                            conformity = False

                results.append((level, mean_value, conformity))
                break

        if not constraint_found:
            print(f"\nNo constraint found for level: {level}, mean_value: {mean_value}")
            results.append((level, mean_value, None))

    return results


def is_result_valid(conformity_res):
    is_valid = True
    for _, _, third_field in conformity_res:
        print(f"type(third_field): {type(third_field)}, value: {third_field}")
        # Normalize the value to boolean
        normalized = None
        if isinstance(third_field, bool):
            normalized = third_field
        elif isinstance(third_field, (int, float)):
            # 0 is False, 1 or any positive number is True, negative is False
            normalized = bool(third_field) and third_field > 0
        elif isinstance(third_field, str):
            # Accept 'true', 'True', 'false', 'False', '0', '1', etc.
            val = third_field.strip().lower()
            if val in ['true', 'yes', '1']:
                normalized = True
            elif val in ['false', 'no', '0']:
                normalized = False
            else:
                try:
                    # Try to interpret as a number
                    num = float(val)
                    normalized = bool(num) and num > 0
                except Exception:
                    normalized = None
        if normalized is False or normalized is None:
            is_valid = False
            break
    return str(is_valid)


def normalize_constraint_level(level_str):
    # Match ANYTHING[@id='number'] and return ANYTHING-number
    match = re.match(r"([A-Za-z0-9_]+)\[@id='(\d+)'\]", level_str)
    if match:
        return f"{match.group(1)}-{match.group(2)}"
    # If it's just 'bts', return a pattern to match NRBTS-x
    if level_str.lower() == "bts":
        return "NRBTS-"
    return level_str


def evaluateConstraints(constraintsFile, reportFile, logit=True, failOnError=False):
    """
    Evaluate constraints based on the given constraints file and report file.
    Args:
        constraintsFile (str): Path to the constraints file.
        reportFile (str): Path to the report file.
        logit (bool, optional): Flag indicating whether to log details. Defaults to True.
                Set to False for tests.
        failOnError (bool, optional): Flag indicating whether to fail on error.
                Defaults to False.
    Returns:
        bool: True if all constraints pass, False otherwise.
    """
    # Init log file to store details
    if logit:
        Log(constraintsFile)
    # Reading Counter and KPI definitions,
    branchName = TLConfig.topo.getBranchName()
    # Reading Report file
    df_report = get_kpis_report_from_file(reportFile)
    # Reading Constraints file
    constraintFile = ConstraintFile(constraintsFile, reportDf=df_report)
    isEvalOk = constraints_check(df_report, constraintFile, failOnError, logit)
    return isEvalOk


def evaluateConstraintsMulti(constraint_files_dir, constraint_files_pref, reportFile,
                             logit=False, failOnError=False):
    """
    Evaluate constraints based on the given constraints directory and report file.
    Args:
        constraint_files_dir (str): Path to the directory containing the constraints files.
        constraint_files_pref (str): Prefix used to filter constraint files in the directory.
        reportFile (str): Path to the report file.
        logit (bool, optional): Flag indicating whether to log details. Defaults to True.
                Set to False for tests.
        failOnError (bool, optional): Flag indicating whether to fail on error.
                Defaults to False.
    Returns:
        bool: True if all constraints passed, False otherwise.
    """
    column_names = ["level", "kpi_name", "min", "max", "scope", "description"]
    df_report = get_kpis_report_from_file(reportFile)
    df_raw = join_constraints_dfs(constraint_files_dir, constraint_files_pref, column_names)
    # For each kpi_name, process NRCELL/NRBTS logic in-place
    error_list = {}
    only_nrcells_list = {}
    hybrids_list = {}
    for counter in df_raw['kpi_name'].unique():
        subdf = df_raw[df_raw['kpi_name'] == counter]
        has_nrbts = subdf['level'].str.startswith('NRBTS').any()
        has_nrcell = subdf['level'].str.startswith('NRCELL').any()
        drop_nr = 0
        # If NRBTS exists, drop all NRCELL for this kpi_name
        if has_nrbts:
            idx_to_drop = subdf[subdf['level'].str.startswith('NRCELL')].index
            drop_nr = len(idx_to_drop)
            hybrids_list[counter] = drop_nr
            df_raw.drop(idx_to_drop, inplace=True)
        # If only NRCELL exists, check Min/Max uniqueness
        elif has_nrcell and not has_nrbts:
            min_max_pairs = subdf[['min', 'max']].drop_duplicates()
            if len(min_max_pairs) == 1:
                # Keep only one row, drop the rest, and log error
                idx_to_keep = subdf.index[0]
                idx_to_drop = subdf.index[1:]
                df_raw.drop(idx_to_drop, inplace=True)
                only_nrcells_list[counter] = len(idx_to_drop) + 1
            else:
                idx_to_drop = subdf.index
                error_list[counter] = len(idx_to_drop)
    df_raw.to_csv(CONSTR_TEMP_FILE_CLEAN, index=False, sep=';', header=False)
    print("Cleaned constraint file rows:", len(df_raw))
    print("Cleaned constraint file columns:", df_raw.columns.tolist())
    print(df_raw.head(10))
    print(f"\nError list (NRCELL-only, Min/Max NOT identical): {error_list}")
    print(f"\nOnly NRCELL list (Min/Max unique): {only_nrcells_list}")
    print(f"\nHybrids list (Both NRBTS and NRCELL, NRCELL dropped): {hybrids_list}")
    # Reading Constraints file
    constraintFile = ConstraintFile(f"{CONSTR_TEMP_FILE_CLEAN}", reportDf=df_report)
    print(f"\nConstraintFile object created: {constraintFile}")
    print(f"Number of constraints loaded: {len(getattr(constraintFile, 'constraints', []))}")
    if hasattr(constraintFile, 'constraints'):
        for idx, c in enumerate(constraintFile.constraints[:10]):  # Show first 10 for brevity
            print(f"Constraint[{idx}]: rootParam={getattr(c, 'rootParam', None)}, "
                  f"type={getattr(c, 'type', None)}, min={getattr(c, 'min', None)}, "
                  f"max={getattr(c, 'max', None)}, variant={getattr(c, 'variant', None)}")
    isEvalOk = constraints_check(df_report, constraintFile, failOnError, logit)
    return isEvalOk


def constraints_check(df_report, constraintFile, failOnError, logit):
    DFParser(df_report, constraintFile)
    # Display failed constraints
    logger.info("Constraint file content")
    constraintFile.displayAll(deactivate_constr_print=True)
    constraintFile.stats(failOnError)
    if logit:
        Log.close()
    return constraintFile.isOK()


def join_constraints_dfs(constraint_files_dir, constraint_files_pref, column_names):
    pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])
    dataframes = []
    for filename in os.listdir(constraint_files_dir):
        if filename.startswith(constraint_files_pref):
            filepath = os.path.join(constraint_files_dir, filename)
            print(f"\nProcessing constraint file: {filepath}")
            df = pd.read_csv(filepath, sep=';', comment='#', skipinitialspace=True, header=None, names=column_names)
            dataframes.append(df)
    if not dataframes:
        logger.error("ERROR: No valid constraint files found.")
        print("No valid constraint files found.")
        return pd.DataFrame()  # Return empty DataFrame if no valid files found
    # Check all data_frames have all the same columns
    columns = dataframes[0].columns
    for df in dataframes:
        if not df.columns.equals(columns):
            logger.error("ERROR : Columns do not match !")
            print("Columns do not match in the constraint files.")
    sum_df = pd.concat(dataframes, ignore_index=True)
    duplicates = sum_df[sum_df.duplicated()]
    if not duplicates.empty:
        logger.error("ERROR : Duplicates found:")
        logger.error(f"Duplicates:\n{duplicates}")
        print(f"Duplicates found in the constraint files:\n{duplicates}")
    sum_df.to_csv(CONSTR_TEMP_FILE, index=False, sep=';', header=True)
    constraints = pd.read_csv(
        CONSTR_TEMP_FILE, sep=";", comment="#", skip_blank_lines=True, header=None, names=column_names
    )
    constraints["kpi_name"] = constraints["kpi_name"].str.strip()
    return constraints


def newJournal():
    """
    Create and return an instance of the ScoutJournal class.
    """
    return ScoutJournal()


class ScoutJournal:
    journal_host = None

    def __init__(self):
        try:
            # Establish the SSH connection using the connect method
            self.ssh_connection = connect(
                hostname=REMOTE_TITAN_MOUNT_HOST,
                username=REMOTE_USER,
                password=REMOTE_CRED
            )
            self.journal_host = Host(
                alias="JOURNAL",
                sshConnection=self.ssh_connection,
                isSudo=True
            )
            print("Journal host initialized successfully.")
        except Exception as e:
            print(f"Failed to initialize journal host: {e}")

    def upload_journal(self, file_path, remote_path=None):
        """
        Upload a journal file to the portal.
        :param file_path: Path to the journal file.
        :param remote_path: Path on the remote server where the file will be uploaded.
        :return: True if upload is successful, False otherwise.
        """
        result = False
        try:
            # Upload the file using the Host's uploadFile method
            result = self.journal_host.uploadFile(local_path=file_path, remote_path=remote_path)
            # Log success
            print(f"Successfully uploaded journal file to {REMOTE_TITAN_MOUNT_HOST}:{remote_path}")
        except Exception as e:
            # Log failure
            print(f"Failed to upload journal file: {e}")
        return result

    def get_journal_file(self, file_path, remote_path=None):
        """
        Download a journal file from the portal.
        :param file_path: Path to the journal file.
        :param remote_path: Path on the remote server where the file will be downloaded from.
        :return: True if download is successful, False otherwise.
        """
        result = False
        try:
            result = self.journal_host.downloadFile(remote_path=remote_path, local_path=file_path)
            # Log success
            print(f"Successfully downloaded journal file from {REMOTE_TITAN_MOUNT_HOST}:{remote_path}")
            return True
        except Exception as e:
            # Log failure
            print(f"Failed to download journal file: {e}")
        return result

    def list_remote_files(self, remote_path):
        """
        List files in a remote directory.
        :param remote_path: Path to the remote directory.
        :return: List of files in the remote directory.
        """
        result_list = []
        try:
            # List files using the Host's cmd method
            output = self.journal_host.cmd(f"ls -l {remote_path}")
            # Parse the output to get file names
            result_list = output.splitlines()
        except Exception as e:
            # Log failure
            print(f"Failed to list remote files: {e}")
        return result_list

    def remove_remote_file(self, remote_path):
        """
        Remove a file from the remote server.
        :param remote_path: Path to the remote file.
        :return: True if removal is successful, False otherwise.
        """
        result = False
        try:
            # Remove the file using the Host's cmd method
            self.journal_host.cmd(f"rm -f {remote_path}")
            # Log success
            print(f"Successfully removed remote file: {remote_path}")
            result = True
        except Exception as e:
            # Log failure
            print(f"Failed to remove remote file: {e}")
        return result

    def add_line_to_journal(self, line, file_path, remote_path=None):
        """
        Add a line to the journal file.
        :param line: Line to be added (list or Series).
        :param file_path: Path to the journal file.
        :param remote_path: Path on the remote server where the file will be uploaded.
        return: True if addition is successful, False otherwise.
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        # Download the journal file if needed
        isok = self.get_journal_file(file_path, remote_path)
        # Read the existing journal file
        df = pd.read_csv(file_path, sep=',', header=None, names=COLUMN_NAMES)
        new_row = pd.DataFrame([line], columns=COLUMN_NAMES)
        df = pd.concat([df, new_row], ignore_index=True)
        # Save the updated DataFrame to a new file
        new_file_path = file_path.replace('.csv', '_new.csv')
        df.to_csv(new_file_path, sep=',', index=False, header=False)
        isok2 = self.upload_journal(new_file_path, remote_path)
        if isok and isok2:
            print(f"Successfully added line to journal file: {file_path}")
            return True
        else:
            print(f"Failed to add line to journal file: {file_path}")
            return False

    def extract_last_and_previous_dates(self, file_path, remote_path=None):
        """
        Extract the last row and the previous matching row from the journal file.

        :param file_path: Path to the journal file.
        :param remote_path: Path on the remote server where the file will be downloaded from.
        :return: A dictionary containing the last row and the previous matching row's start and stop dates,
            or None if not found.
        """
        isok = self.get_journal_file(file_path, remote_path)
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        # Read the journal
        df = pd.read_csv(file_path, sep=',', header=None, names=COLUMN_NAMES)
        if df.empty or len(df) < 2:
            print("The journal is empty or does not contain enough rows.")
            return None
        # Extract the last row
        last_row = df.iloc[-1]
        step_name_suffix = last_row["step_name_suffix"]
        testline_name = last_row["testline_name"]
        print(f"Last row: {last_row.to_dict()}")
        # Find the previous matching row
        previous_matches = df.iloc[:-1][
            (df["step_name_suffix"] == step_name_suffix) &
            (df["testline_name"] == testline_name)
        ]
        if previous_matches.empty:
            print("No matching previous row found.")
            return None
        previous_row = previous_matches.iloc[-1]
        previous_start_date = previous_row["start_date"]
        previous_stop_date = previous_row["stop_date"]
        print(f"Matching previous row: {previous_row.to_dict()}")
        return {
            "last_row": last_row.to_dict(),
            "previous_start_date": previous_start_date,
            "previous_stop_date": previous_stop_date,
        }

    def generate_comparator_report(self, template_id, file_path, remote_path=None,
                                   first_period_description=None, second_period_description=None,
                                   alpha_factor=0.001, apikey=None):
        """
        Generate comparator report for testline based on {template_ids} templates with defined start and end date time
        ranges. Start time and end time should be in one month range from current date.
        :param template_id: template IDs as a string value.
        :param file_path: Path to the journal file.
        :param remote_path: Path on the remote server where the journal file will be downloaded from.
        :param string first_period_description: Field contains information about the element (in the software)
            that has been changed in the time range (previous SW version).
        :param string second_period_description: Field contains information about the element (in the software)
            that has been changed in the time range (updated SW version).
        :param float alpha_factor: The alpha index, used in the t-test calculation.
        :param string apikey: The API key for authentication.
        """
        int_template = 1271
        tafscout = taf_scout()
        try:
            tl_name = get_testline_name()
            tafscout.setup_scout(scout_testline_name=tl_name, api_key=apikey, timeout=300)
            int_template = int(template_id)
        except Exception as e:
            print(f"Failed to setup scout: {e}")
            return None
        row_dicts = self.extract_last_and_previous_dates(file_path, remote_path)
        report_name = str(row_dicts["last_row"]["step_name_suffix"])
        int_template_value_list = []
        int_template_value_list.append(int_template)
        previous_start_time = row_dicts['previous_start_date']
        previous_end_time = row_dicts['previous_stop_date']
        last_start_time = row_dicts["last_row"]['start_date']
        last_end_time = row_dicts["last_row"]['stop_date']
        result = tafscout.generate_comparator_report(
            report_name, int_template_value_list, previous_start_time, previous_end_time, last_start_time,
            last_end_time, first_period_description, second_period_description, alpha_factor
        )
        try:
            tafscout.teardown_scout_api()
        except Exception as e:
            print(f"Failed to teardown scout: {e}")
        return result


class DFParser:
    def __init__(self, df_report, constraintFile, value_column='global_result.value'):
        """
        Initialize the DFParser with a DataFrame and other required files.
        Check Constraints and parse the DataFrame.
        :param df_report: pandas.DataFrame containing the report data.
        :param constraintFile: File containing constraints.
        """
        self.df_report = df_report
        original_length = len(self.df_report)
        self.df_report.dropna(subset=[value_column], inplace=True)  # Drop NaN values for value_column
        cleaned_length = len(self.df_report)
        self.constraintFile = constraintFile
        self.counterReport = {}
        self.kpi_instance = None
        Log.fullTrace(f"Parsing: DataFrame report...\nOrignal size: {original_length}\nCleaned size: {cleaned_length}")
        print(f"Parsing: DataFrame report...\nOrignal size: {original_length}\nCleaned size: {cleaned_length}")
        tot_eval = 0
        for idx, row in self.df_report.iterrows():
            self.kpi_instance = self.setKpi(row)
            if self.kpi_instance is not None:
                tot_eval += 1
            Var.clean()
        Log.fullTrace(f"  Evaluated {tot_eval} KPIs")
        print(f"  Evaluated {tot_eval} KPIs")
        self.constraintFile.checkConstraintsIndf(self.counterReport, self.df_report)

    def reportToPortal(self):
        """
        Report the parsed counters to the portal.
        """
        from robot.libraries.BuiltIn import BuiltIn
        for counter in self.counterReport:
            (status, value) = self.counterReport[counter]
            RP_PORTAL.report_pm_counter(counter, value, str(status))

    def setKpi(self, row):
        """
        Set KPI based on the DataFrame row.
        :param row: A row from the DataFrame.
        """
        try:
            value = row['global_result.value']
            kpi = row['code']
            kpi_instance = Kpi(row, 1, kpi, value, kpi)
            return kpi_instance
        except NameError:
            pass
        except ZeroDivisionError:
            pass


class ScoutReportParser:
    """Parse and convert Scout reports to constraint CSV format."""

    # Deviations by family (in percentage)
    # Values can be adjusted as needed
    FAMILY_DEVIATIONS = {
        'Accessibility': 0.5,           # Very low deviation for accessibility
        'Integrity': 5.0,                # Medium deviation for integrity
        'Mobility': 1.0,                 # Low deviation for mobility
        'Retainability': 1.0,            # Low deviation for retainability
        'Usage - Utilization': 5.0,     # High deviation for utilization
        'Usage - Capacity': 5.0,        # High deviation for capacity
        'Usage -  Energy Efficiency': 10.0,  # Medium deviation for energy
        'default': 5.0                  # Default value for unlisted families
    }

    # Order of families in output (must match expected file)
    FAMILY_ORDER = [
        'Usage -  Energy Efficiency',
        'Accessibility',
        'Retainability',
        'Mobility',
        'Integrity',
        'Usage - Utilization',
        'Usage - Capacity'
    ]

    def __init__(self, input_file, output_file=None):
        """
        Initialize the parser.
        :param input_file: Path to raw_scout_report.csv
        :param output_file: Path to output file (optional)
        """
        self.input_file = input_file
        self.output_file = output_file or f"constraint_{os.path.splitext(os.path.basename(input_file))[0]}.csv"

    def parse_scout_report(self):
        """
        Parse the raw_scout_report.csv file using pandas.
        Expected format: ,DistName,EntryName,GroupName,TimeStamp,Value
        :return: DataFrame with parsed and aggregated data
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        try:
            df = pd.read_csv(self.input_file)
            # Extract OAM ID, counter code, and comment
            df['oam_id'] = df['DistName'].apply(self._extract_oam_id)
            df['counter'] = df['EntryName'].apply(self._extract_counter_code)
            df['comment'] = df['EntryName'].apply(self._extract_comment)
            # Filter out rows with missing critical fields
            df = df.dropna(subset=['oam_id', 'counter'])
            # Convert Value to numeric, coercing errors
            df['Value'] = pd.to_numeric(df['Value'], errors='coerce')
            # Group by (oam_id, counter, comment, GroupName) and calculate min/max
            grouped = df.groupby(['oam_id', 'counter', 'comment', 'GroupName'], dropna=False).agg(
                raw_min=('Value', 'min'),
                raw_max=('Value', 'max')
            ).reset_index()
            # Apply deviations
            grouped['deviation'] = grouped['GroupName'].apply(self._get_deviation_for_family)
            grouped['min_value'] = grouped.apply(
                lambda row: self._apply_deviation(row['raw_min'], -row['deviation']), axis=1
            )
            grouped['max_value'] = grouped.apply(
                lambda row: self._apply_deviation(row['raw_max'], row['deviation']), axis=1
            )
            # For negative values, ensure min < max (swap if needed)
            # (because -80 < -70, so the more negative value must be min)

            def swap_if_needed(row):
                if row['min_value'] > row['max_value']:
                    return pd.Series({'min_value': row['max_value'], 'max_value': row['min_value']})
                return pd.Series({'min_value': row['min_value'], 'max_value': row['max_value']})

            grouped[['min_value', 'max_value']] = grouped.apply(swap_if_needed, axis=1)
            # Add variant column
            grouped['variant'] = 'ALL'
            # Rename GroupName to group_name
            grouped = grouped.rename(columns={'GroupName': 'group_name'})
            # Select and reorder columns
            result = grouped[['oam_id', 'counter', 'min_value', 'max_value', 'variant', 'comment', 'group_name']]
            return result.sort_values(['group_name', 'oam_id', 'counter'])
        except FileNotFoundError:
            print(f"Error: File not found: {self.input_file}")
            return None
        except Exception as e:
            print(f"Error during parsing: {e}")
            import traceback
            traceback.print_exc()
            return None

    def _extract_counter_code(self, entry_name):
        """
        Extract counter code from EntryName.
        Examples:
        - "[NR_5061b] 5G Average..." -> "NR_5061"
        - "[MRBTS_5600a] SBTS..." -> "MRBTS_5600"
        :param entry_name: EntryName field value
        :return: Counter code or None
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        if pd.isna(entry_name):
            return None
        match = re.match(r'\[([^\]]+)\]', str(entry_name))
        if match:
            code = match.group(1)
            code = re.sub(r'[a-z]+$', '', code)
            return code
        return None

    def _extract_comment(self, entry_name):
        """
        Extract comment (description) from EntryName.
        :param entry_name: EntryName field value
        :return: Description or empty string
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        if pd.isna(entry_name):
            return ''
        match = re.match(r'\[[^\]]+\]\s*(.*)', str(entry_name))
        return match.group(1).strip() if match else ''

    def _apply_deviation(self, value, percent):
        """
        Apply percentage deviation to a value.
        :param value: Numeric value
        :param percent: Deviation percentage (positive or negative)
        :return: Adjusted value
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        if pd.isna(value):
            return None
        deviation = value * (percent / 100.0)
        adjusted = value + deviation
        # For values between 0 and 100 (percentages, ratios), ensure logical bounds
        if 0 <= value <= 100:
            adjusted = max(0, min(100, adjusted))
        elif value >= 0 and adjusted < 0:
            adjusted = 0
        return adjusted

    def _get_deviation_for_family(self, family_name):
        """
        Return configured deviation for a given family.
        :param family_name: Family name (e.g., 'Accessibility', 'Integrity')
        :return: Deviation percentage for this family
        """
        return self.FAMILY_DEVIATIONS.get(family_name, self.FAMILY_DEVIATIONS['default'])

    def _extract_oam_id(self, dist_name):
        """
        Extract OAM ID from DistName field.
        Examples:
        - "7_20_UTE5GCLASSTL005/NRCELL-6" -> "NRCELL[@id='6']"
        - "7_20_UTE5GCLASSTL005/bts" -> "NRBTS[@id='1']"
        :param dist_name: DistName field value
        :return: Formatted OAM ID or None
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        if pd.isna(dist_name):
            return None
        parts = str(dist_name).split('/')
        if len(parts) < 2:
            return None
        element = parts[-1]
        if element.startswith('NRCELL-'):
            cell_id = element.replace('NRCELL-', '')
            return f"NRCELL[@id='{cell_id}']"
        elif element == 'bts':
            return "NRBTS[@id='1']"
        return None

    def format_value(self, value):
        """
        Format a value according to output file rules.
        :param value: Value to format
        :return: Formatted value
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]
        if pd.isna(value) or value is None:
            return 'None'
        if isinstance(value, (int, float)):
            rounded = round(value, 2)
            return str(int(rounded)) if rounded == int(rounded) else str(rounded)
        return str(value)

    def write_constraint_file(self, df):
        """
        Write constraint file in expected format.
        Data is grouped by family (group_name) and sorted by counter.
        :param df: DataFrame with parsed data
        """
        if df is None or df.empty:
            print("No data to write")
            return
        try:
            with open(self.output_file, 'w') as f:
                # Header
                f.write("#oam_id        ; Counter_or_KPI;       Min;       Max; Variant;   Comment from MIND/JUMP\n")
                # Get unique families and order them
                families = df['group_name'].unique()
                ordered_families = [fam for fam in self.FAMILY_ORDER if fam in families]
                # Add any families not in FAMILY_ORDER at the end
                ordered_families.extend([fam for fam in families if fam not in self.FAMILY_ORDER])
                # Group by family in the specified order
                for family_name in ordered_families:
                    group = df[df['group_name'] == family_name].sort_values(['oam_id', 'counter'])
                    f.write(f"# ===== {family_name} =====\n")
                    for _, row in group.iterrows():
                        min_val = self.format_value(row['min_value'])
                        max_val = self.format_value(row['max_value'])
                        oam_id = str(row['oam_id']).ljust(15)
                        counter = str(row['counter']).ljust(12)
                        min_str = min_val.rjust(10)
                        max_str = max_val.rjust(10)
                        variant = str(row['variant']).rjust(8)
                        comment = str(row['comment'])
                        line = f"{oam_id};   {counter};{min_str};{max_str};{variant};   {comment}\n"
                        f.write(line)
            print(f"Constraint file created: {self.output_file}")
            print(f"Number of lines: {len(df)}")
            print(f"Number of families: {df['group_name'].nunique()}")
        except Exception as e:
            print(f"Error during writing: {e}")
            import traceback
            traceback.print_exc()

    def convert(self):
        """Execute complete conversion."""
        print(f"Reading from: {self.input_file}")
        print("Configured deviations by family:")
        for family, deviation in sorted(self.FAMILY_DEVIATIONS.items()):
            if family != 'default':
                print(f"  - {family}: ±{deviation}%")
        print(f"  - Other families (default): ±{self.FAMILY_DEVIATIONS['default']}%")
        df = self.parse_scout_report()
        if df is not None:
            print(f"Writing to: {self.output_file}")
            self.write_constraint_file(df)
            return self.output_file
        return None


def new_scout_report_parser(input_file, output_file=None):
    """
    Create a new ScoutReportParser instance.
    Factory function for Robot Framework keyword usage.
    :param input_file: Path to raw Scout report CSV file
    :param output_file: Optional path to output constraint file
    :return: ScoutReportParser instance
    """
    return ScoutReportParser(input_file, output_file)


class ExcelComparator:
    """
    Analyzer for comparing Scout Excel comparator reports.
    Validates structure, columns, and data formats between reference and fetched reports.
    """

    def __init__(self, reference_file=None, fetched_file=None):
        """
        Initialize the Excel comparator.

        :param reference_file: Path to reference Excel file (optional)
        :param fetched_file: Path to fetched/generated Excel file (optional)
        """
        self.reference_file = reference_file
        self.fetched_file = fetched_file
        self.df_reference = None
        self.df_fetched = None
        self.comparison_results = {}

    def load_files(self, reference_file=None, fetched_file=None):
        """
        Load Excel files into pandas DataFrames.

        :param reference_file: Path to reference Excel file (overrides instance variable)
        :param fetched_file: Path to fetched Excel file (overrides instance variable)
        :return: True if both files loaded successfully, False otherwise
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]

        ref_path = reference_file or self.reference_file
        fetch_path = fetched_file or self.fetched_file

        if not ref_path or not fetch_path:
            logger.error("Both reference and fetched file paths must be provided")
            return False

        try:
            if not os.path.exists(ref_path):
                logger.error(f"Reference file not found: {ref_path}")
                return False
            if not os.path.exists(fetch_path):
                logger.error(f"Fetched file not found: {fetch_path}")
                return False

            self.df_reference = pd.read_excel(ref_path)
            self.df_fetched = pd.read_excel(fetch_path)

            if self.df_reference.empty:
                logger.error("Reference Excel file is empty")
                return False
            if self.df_fetched.empty:
                logger.error("Fetched Excel file is empty")
                return False

            logger.info(f"Reference file: {len(self.df_reference)} rows × {len(self.df_reference.columns)} columns")
            logger.info(f"Fetched file: {len(self.df_fetched)} rows × {len(self.df_fetched.columns)} columns")

            return True
        except Exception as e:
            logger.error(f"Error loading Excel files: {e}")
            return False

    def compare_columns(self):
        """
        Compare column names between reference and fetched files.

        :return: Dictionary with comparison results including mismatches
        """
        if self.df_reference is None or self.df_fetched is None:
            logger.error("Files must be loaded before comparison")
            return {"success": False, "error": "Files not loaded"}

        reference_columns = self.df_reference.columns.tolist()
        fetched_columns = self.df_fetched.columns.tolist()

        num_core_columns = len(reference_columns)
        mismatches = []

        # Check if fetched file has at least as many columns as reference
        if len(fetched_columns) < num_core_columns:
            return {
                "success": False,
                "error": f"Fetched file has fewer columns ({len(fetched_columns)}) than reference ({num_core_columns})"
            }

        # Verify each core column matches
        for i in range(num_core_columns):
            expected = reference_columns[i]
            actual = fetched_columns[i]
            if expected != actual:
                mismatches.append({
                    "index": i,
                    "expected": expected,
                    "actual": actual
                })

        # Identify additional columns in fetched file
        additional_columns = []
        if len(fetched_columns) > num_core_columns:
            additional_columns = fetched_columns[num_core_columns:]

        result = {
            "success": len(mismatches) == 0,
            "num_core_columns": num_core_columns,
            "num_fetched_columns": len(fetched_columns),
            "mismatches": mismatches,
            "additional_columns": additional_columns,
            "reference_columns": reference_columns,
            "fetched_columns": fetched_columns
        }

        self.comparison_results["columns"] = result
        return result

    def validate_data_formats(self):
        """
        Validate data formats for key columns in the fetched file.

        :return: Dictionary with validation results
        """
        if self.df_fetched is None:
            logger.error("Fetched file must be loaded before validation")
            return {"success": False, "error": "Fetched file not loaded"}

        fetched_columns = self.df_fetched.columns.tolist()
        validation_results = {}
        all_valid = True

        # Validate Entity Count Problem (should be Yes/No)
        if 'Entity Count Problem' in fetched_columns:
            unique_vals = self.df_fetched['Entity Count Problem'].dropna().unique().tolist()
            valid = all(val in ['Yes', 'No', ''] for val in unique_vals)
            validation_results['Entity Count Problem'] = {
                "valid": valid,
                "unique_values": unique_vals,
                "expected": "Yes/No format"
            }
            all_valid = all_valid and valid

        # Validate Interval Problem (should be Yes/No)
        if 'Interval Problem' in fetched_columns:
            unique_vals = self.df_fetched['Interval Problem'].dropna().unique().tolist()
            valid = all(val in ['Yes', 'No', ''] for val in unique_vals)
            validation_results['Interval Problem'] = {
                "valid": valid,
                "unique_values": unique_vals,
                "expected": "Yes/No format"
            }
            all_valid = all_valid and valid

        # Validate Range column format
        if 'Range' in fetched_columns:
            unique_vals = self.df_fetched['Range'].dropna().unique().tolist()
            expected_range = 'Reference \nCurrent'
            has_expected = expected_range in unique_vals if len(unique_vals) > 0 else False
            validation_results['Range'] = {
                "valid": has_expected,
                "unique_values": unique_vals,
                "expected": "Reference \\nCurrent"
            }

        result = {
            "success": all_valid,
            "validations": validation_results
        }

        self.comparison_results["data_formats"] = result
        return result

    def generate_comparison_report(self, verbose=True):
        """
        Generate a comprehensive comparison report.

        :param verbose: If True, print detailed information
        :return: Dictionary with all comparison results
        """
        if self.df_reference is None or self.df_fetched is None:
            logger.error("Files must be loaded before generating report")
            return {"success": False, "error": "Files not loaded"}

        # Run all comparisons
        column_comparison = self.compare_columns()
        data_validation = self.validate_data_formats()

        overall_success = column_comparison["success"] and data_validation["success"]

        report = {
            "success": overall_success,
            "reference_file": self.reference_file,
            "fetched_file": self.fetched_file,
            "reference_shape": (len(self.df_reference), len(self.df_reference.columns)),
            "fetched_shape": (len(self.df_fetched), len(self.df_fetched.columns)),
            "column_comparison": column_comparison,
            "data_validation": data_validation
        }

        if verbose:
            self._print_report(report)

        return report

    def _print_report(self, report):
        """Print formatted comparison report."""
        print("\n" + "="*80)
        print("EXCEL COMPARATOR REPORT")
        print("="*80)

        print(f"\nReference file: {report['reference_file']}")
        print(f"Fetched file:   {report['fetched_file']}")

        print(f"\nReference shape: {report['reference_shape'][0]} rows × {report['reference_shape'][1]} columns")
        print(f"Fetched shape:   {report['fetched_shape'][0]} rows × {report['fetched_shape'][1]} columns")

        print("\n" + "-"*80)
        print("COLUMN COMPARISON")
        print("-"*80)

        col_comp = report['column_comparison']
        if col_comp['success']:
            print(f"✓ All {col_comp['num_core_columns']} core columns match reference format")
        else:
            print(f"✗ {len(col_comp['mismatches'])} column mismatches detected:")
            for mm in col_comp['mismatches']:
                print(f"  Column [{mm['index']}]: Expected '{mm['expected']}', got '{mm['actual']}'")

        if col_comp['additional_columns']:
            print(f"\nAdditional columns in fetched file ({len(col_comp['additional_columns'])}):")
            for idx, col in enumerate(col_comp['additional_columns'], start=col_comp['num_core_columns']):
                print(f"  [{idx}] {col}")

        print("\n" + "-"*80)
        print("DATA FORMAT VALIDATION")
        print("-"*80)

        data_val = report['data_validation']
        for col_name, val_result in data_val['validations'].items():
            status = "✓" if val_result['valid'] else "✗"
            print(f"{status} {col_name}: {val_result['expected']}")
            if not val_result['valid']:
                print(f"  Unexpected values: {val_result['unique_values']}")

        print("\n" + "="*80)
        print(f"OVERALL RESULT: {'PASS ✓' if report['success'] else 'FAIL ✗'}")
        print("="*80 + "\n")

    def get_first_n_rows(self, n=5, columns_limit=10):
        """
        Get first N rows of fetched data.

        :param n: Number of rows to retrieve
        :param columns_limit: Maximum number of columns to include
        :return: DataFrame slice or None
        """
        if self.df_fetched is None:
            return None

        num_cols = min(columns_limit, len(self.df_fetched.columns))
        return self.df_fetched.iloc[:n, :num_cols]


def new_excel_comparator(reference_file=None, fetched_file=None):
    """
    Factory function to create an ExcelComparator instance.
    For use in Robot Framework or standalone Python scripts.

    :param reference_file: Path to reference Excel file
    :param fetched_file: Path to fetched Excel file
    :return: ExcelComparator instance
    """
    return ExcelComparator(reference_file, fetched_file)


class ScoutComparatorAnalyzer:
    """
    Python implementation of the VBA createConstraintFile_inline.vba script.
    Analyzes Scout comparator Excel reports (Chart Data tab) and generates constraint CSV files.
    """

    # Family deviations (in percentage)
    FAMILY_DEVIATIONS = {
        'Accessibility': 0.5,
        'Integrity': 5.0,
        'Mobility': 1.0,
        'Retainability': 1.0,
        'Usage - Utilization': 5.0,
        'Usage - Capacity': 5.0,
        'Usage -  Energy Efficiency': 10.0,
        'default': 5.0
    }

    def __init__(self, excel_file, sheet_name=None, legacy_mode=False):
        """
        Initialize the Scout comparator analyzer.

        :param excel_file: Path to Excel file containing Scout comparator report
        :param sheet_name: Name of the sheet to analyze (default: auto-detect)
        :param legacy_mode: If True, comment out NRBTS lines and None/None constraints
        """
        self.excel_file = excel_file
        self.sheet_name = sheet_name
        self.legacy_mode = legacy_mode
        self.df = None
        self.data_dict = {}
        self.detected_format = None  # 'chart_data' or 'comparator_details'

    def load_data(self):
        """
        Load Excel data from the specified sheet (auto-detects if not specified).

        :return: True if successful, False otherwise
        """
        pd = pcsv.import_with_auto_install(['pandas'])[0]

        try:
            if not os.path.exists(self.excel_file):
                logger.error(f"Excel file not found: {self.excel_file}")
                return False

            # Auto-detect sheet if not specified
            if self.sheet_name is None:
                excel_file = pd.ExcelFile(self.excel_file)
                available_sheets = excel_file.sheet_names

                # Try to find Chart Data sheet first
                if 'Chart Data' in available_sheets:
                    self.sheet_name = 'Chart Data'
                    self.detected_format = 'chart_data'
                else:
                    # Use first sheet and detect format
                    self.sheet_name = available_sheets[0]
                    self.detected_format = 'comparator_details'

                logger.info(f"Auto-detected sheet: '{self.sheet_name}' (format: {self.detected_format})")
            else:
                # Try to detect format from sheet name
                if 'Chart Data' in self.sheet_name:
                    self.detected_format = 'chart_data'
                else:
                    self.detected_format = 'comparator_details'

            # Read the sheet
            self.df = pd.read_excel(self.excel_file, sheet_name=self.sheet_name)

            if self.df.empty:
                logger.error(f"No data found in sheet '{self.sheet_name}'")
                return False

            logger.info(f"Loaded {len(self.df)} rows from '{self.sheet_name}' sheet")
            return True

        except Exception as e:
            logger.error(f"Error loading Excel file: {e}")
            return False

    def _extract_oam_id(self, dist_name):
        """
        Extract OAM ID from distribution name.
        Example: "testline/NRCELL-6" -> "NRCELL[@id='6']"
        Example: "NRCELL-6" -> "NRCELL[@id='6']"
        Example: "testline/bts" -> "NRBTS[@id='1']"
        Example: "bts" -> "NRBTS[@id='1']"

        :param dist_name: Distribution name from Chart Data or ComparatorReportDetails
        :return: OAM ID string or None
        """
        if not dist_name or pd.isna(dist_name):
            return None

        # Split by '/' and get the last element (or the only element if no slash)
        parts = str(dist_name).strip().split('/')
        element = parts[-1]  # Get last part (works for both "testline/bts" and "bts")

        if element.startswith('NRCELL-'):
            cell_id = element[7:]  # Remove 'NRCELL-' prefix
            return f"NRCELL[@id='{cell_id}']"
        elif element.lower() == 'bts':
            return "NRBTS[@id='1']"

        return None

    def _extract_counter_code(self, entry_name):
        """
        Extract counter code from entry name.
        Example: "[NR_5004a] UL Average BLER" -> "NR_5004"

        :param entry_name: Entry name from Chart Data
        :return: Counter code or None
        """
        if not entry_name or pd.isna(entry_name):
            return None

        import re
        # Extract text within brackets
        match = re.search(r'\[([^\]]+)\]', str(entry_name))
        if not match:
            return None

        code = match.group(1)
        # Remove trailing lowercase letter (variant suffix)
        code = re.sub(r'[a-z]+$', '', code)
        return code

    def _extract_comment(self, entry_name):
        """
        Extract comment/description from entry name.
        Example: "[NR_5004a] UL Average BLER" -> "UL Average BLER"

        :param entry_name: Entry name from Chart Data
        :return: Comment string or empty string
        """
        if not entry_name or pd.isna(entry_name):
            return ""

        import re
        # Extract text after brackets
        match = re.search(r'\[[^\]]+\]\s*(.*)', str(entry_name))
        if match:
            return match.group(1).strip()
        return ""

    def _infer_group_name(self, comment):
        """
        Infer group/family name from comment text.

        :param comment: Comment text
        :return: Group name string
        """
        comment_lower = comment.lower()

        if any(word in comment_lower for word in ['bler', 'block error', 'error rate']):
            return 'Integrity'
        elif any(word in comment_lower for word in ['handover', 'mobility']):
            return 'Mobility'
        elif any(word in comment_lower for word in ['throughput', 'capacity', 'traffic']):
            return 'Usage - Capacity'
        elif any(word in comment_lower for word in ['utilization', 'usage']):
            return 'Usage - Utilization'
        elif any(word in comment_lower for word in ['energy', 'power']):
            return 'Usage -  Energy Efficiency'
        elif any(word in comment_lower for word in ['setup', 'establishment', 'access']):
            return 'Accessibility'
        elif any(word in comment_lower for word in ['drop', 'release', 'retention']):
            return 'Retainability'
        else:
            return 'Other'

    def analyze_chart_data(self):
        """
        Analyze data and build internal data dictionary.
        Supports both 'chart_data' and 'comparator_details' formats.

        :return: True if successful, False otherwise
        """
        if self.df is None:
            logger.error("Data not loaded. Call load_data() first.")
            return False

        pd, numpy = pcsv.import_with_auto_install(['pandas', 'numpy'])

        self.data_dict = {}

        if self.detected_format == 'comparator_details':
            # Handle ComparatorReportDetails format
            # Columns: Code, Name, Dist Name, Range, Values, ...
            for idx, row in self.df.iterrows():
                # Extract fields from column names
                counter_code = row.get('Code', None)
                entry_name = row.get('Name', None)
                dist_name = row.get('Dist Name', None)
                values_str = row.get('Values', None)

                # Skip empty rows
                if pd.isna(dist_name) or pd.isna(counter_code):
                    continue

                # Extract components
                oam_id = self._extract_oam_id(dist_name)
                # Counter code is already in Code column - just remove variant suffix
                counter_code_clean = str(counter_code).strip() if counter_code else None
                if counter_code_clean:
                    # Remove trailing lowercase letter (variant suffix like 'c' in 'NR_5055c')
                    import re
                    counter_code_clean = re.sub(r'[a-z]+$', '', counter_code_clean)
                comment = str(entry_name) if not pd.isna(entry_name) else ""

                # Try to infer group from name (basic categorization)
                group_name = self._infer_group_name(comment)

                if not oam_id or not counter_code_clean:
                    continue

                # Create unique key
                key = f"{oam_id}|{counter_code_clean}|{comment}"

                # Initialize if new
                if key not in self.data_dict:
                    self.data_dict[key] = {
                        'values': [],
                        'group_name': group_name,
                        'oam_id': oam_id,
                        'counter_code': counter_code_clean,
                        'comment': comment
                    }

                # Parse Values column (may contain multiple values)
                if not pd.isna(values_str) and str(values_str).strip():
                    # Values might be: "0, 0, 0, 0\n0, 0, 0, 0\n" (comma+newline separated)
                    value_lines = str(values_str).strip().split('\n')
                    for line in value_lines:
                        line = line.strip()
                        if line:
                            # Split by comma
                            val_parts = line.split(',')
                            for val_str in val_parts:
                                val_str = val_str.strip()
                                if val_str and val_str not in ['Reference', 'Current', '']:
                                    try:
                                        value = float(val_str)
                                        self.data_dict[key]['values'].append(value)
                                    except (ValueError, TypeError):
                                        pass
        else:
            # Handle original Chart Data format
            # Expected columns: Distribution, Entry, Group, some columns, Value
            # Column indices: 1=Distribution (0-based), 2=Entry, 3=Group, 5=Value

            for idx, row in self.df.iterrows():
                # Extract fields (adjust column indices based on actual structure)
                dist_name = row.iloc[1] if len(row) > 1 else None
                entry_name = row.iloc[2] if len(row) > 2 else None
                group_name = row.iloc[3] if len(row) > 3 else None
                value_str = row.iloc[5] if len(row) > 5 else None

                # Skip empty rows
                if pd.isna(dist_name) or pd.isna(entry_name):
                    continue

                # Extract components
                oam_id = self._extract_oam_id(dist_name)
                counter_code = self._extract_counter_code(entry_name)
                comment = self._extract_comment(entry_name)

                if not oam_id or not counter_code:
                    continue

                # Create unique key
                key = f"{oam_id}|{counter_code}|{comment}"

                # Initialize if new
                if key not in self.data_dict:
                    self.data_dict[key] = {
                        'values': [],
                        'group_name': str(group_name) if not pd.isna(group_name) else '',
                        'oam_id': oam_id,
                        'counter_code': counter_code,
                        'comment': comment
                    }

                # Add value if numeric
                if not pd.isna(value_str) and str(value_str).strip():
                    try:
                        value = float(value_str)
                        self.data_dict[key]['values'].append(value)
                    except (ValueError, TypeError):
                        pass

        logger.info(f"Analyzed {len(self.data_dict)} unique counter/KPI entries")
        return True

    def _apply_deviation(self, min_val, max_val, group_name, comment):
        """
        Apply deviation percentage to min/max values based on family.

        :param min_val: Minimum value
        :param max_val: Maximum value
        :param group_name: Group/family name
        :param comment: Comment text
        :return: Tuple of (adjusted_min, adjusted_max)
        """
        # Determine deviation percentage
        if 'delay' in comment.lower():
            deviation = 30.0
        else:
            deviation = self.FAMILY_DEVIATIONS.get(group_name, self.FAMILY_DEVIATIONS['default'])

        # Apply deviation to min (negative direction)
        dev_amount = min_val * (-deviation / 100.0)
        adjusted_min = min_val + dev_amount

        # Clamp to valid range
        if 0 <= min_val <= 100:
            adjusted_min = max(0, min(100, adjusted_min))
        elif min_val >= 0 and adjusted_min < 0:
            adjusted_min = 0

        # Apply deviation to max (positive direction)
        dev_amount = max_val * (deviation / 100.0)
        adjusted_max = max_val + dev_amount

        # Clamp to valid range
        if 0 <= max_val <= 100:
            adjusted_max = max(0, min(100, adjusted_max))
        elif max_val >= 0 and adjusted_max < 0:
            adjusted_max = 0

        # Ensure min <= max
        if adjusted_min > adjusted_max:
            adjusted_min, adjusted_max = adjusted_max, adjusted_min

        # Force min to 0 for BLER KPIs
        if 'BLER' in comment:
            adjusted_min = 0

        return adjusted_min, adjusted_max

    def _format_value(self, value, is_number_kpi=False):
        """
        Format a value for constraint file output.

        :param value: Numeric value or None
        :param is_number_kpi: True if this is a "number" KPI (should be integer)
        :return: Formatted string
        """
        if value is None or (isinstance(value, float) and pd.isna(value)):
            return "None"

        if is_number_kpi:
            # Round to integer appropriately
            return str(int(value))
        else:
            # Round to 2 decimal places
            rounded = round(value, 2)
            if rounded == int(rounded):
                return str(int(rounded))
            return str(rounded)

    def generate_constraint_file(self, output_file=None):
        """
        Generate constraint CSV file from analyzed data.

        :param output_file: Output file path (if None, generates in Downloads or /tmp)
        :return: Path to generated file or None on error
        """
        if not self.data_dict:
            logger.error("No data to generate constraint file. Call analyze_chart_data() first.")
            return None

        # Determine output file path
        if output_file is None:
            timestamp = time.strftime("%Y%m%d_%H%M%S")
            output_file = f"/tmp/constraint_{timestamp}.csv"

        # Organize data by family
        families = {}

        for key, entry in self.data_dict.items():
            group_name = entry['group_name']
            oam_id = entry['oam_id']
            counter_code = entry['counter_code']
            comment = entry['comment']
            values = entry['values']

            # Calculate min/max
            if values:
                min_val = min(values)
                max_val = max(values)
                min_val, max_val = self._apply_deviation(min_val, max_val, group_name, comment)
            else:
                min_val = None
                max_val = None

            # Determine if this is a "number" KPI
            is_number_kpi = 'number' in comment.lower()

            # Format values
            min_str = self._format_value(min_val, is_number_kpi)
            max_str = self._format_value(max_val, is_number_kpi)

            # Create formatted line
            oam_id_padded = oam_id.ljust(15)
            counter_padded = counter_code.ljust(12)
            min_formatted = min_str.rjust(10)
            max_formatted = max_str.rjust(10)
            variant_padded = "ALL".rjust(8)

            line = f"{oam_id_padded};   {counter_padded};{min_formatted};{max_formatted};{variant_padded};   {comment}"

            # Apply legacy mode rules if enabled
            if self.legacy_mode:
                if line.startswith("NRBTS[@id='1']"):
                    line = "# " + line
                elif ";      None;      None;" in line:
                    line = "# " + line

            # Add to family group
            if group_name not in families:
                families[group_name] = []

            # Sort key: counterCode|oamId
            sort_key = f"{counter_code}|{oam_id}"
            families[group_name].append((sort_key, line))

        # Write output file
        try:
            with open(output_file, 'w') as f:
                # Write header
                f.write("#oam_id        ; Counter_or_KPI;       Min;       Max; Variant;   Comment from MIND/JUMP\n")

                # Write families in order
                for family_name in sorted(families.keys()):
                    f.write(f"# ===== {family_name} =====\n")

                    # Sort lines within family
                    sorted_lines = sorted(families[family_name], key=lambda x: x[0])

                    for _, line in sorted_lines:
                        f.write(line + "\n")

            logger.info(f"Constraint file generated: {output_file}")
            logger.info(f"  Total entries: {len(self.data_dict)}")
            logger.info(f"  Families: {len(families)}")

            return output_file

        except Exception as e:
            logger.error(f"Error writing constraint file: {e}")
            return None


def new_scout_comparator_analyzer(excel_file, sheet_name='Chart Data', legacy_mode=False):
    """
    Factory function to create a ScoutComparatorAnalyzer instance.
    Python equivalent of the VBA createConstraintFile_inline.vba script.

    :param excel_file: Path to Scout comparator Excel file
    :param sheet_name: Sheet name to analyze (default: 'Chart Data')
    :param legacy_mode: If True, comment NRBTS and None/None lines
    :return: ScoutComparatorAnalyzer instance
    """
    return ScoutComparatorAnalyzer(excel_file, sheet_name, legacy_mode)


def fetch_comparator_report_and_save_excel(report_id, output_excel_path, expected_kpis=None, expected_dist_names=None,
                                           testline_name=None, api_token=None):
    """
    Fetches the comparator report data from Scout API and saves it as an Excel file.

    Uses the Scout API to retrieve the report data in JSON format, then flattens and converts it to Excel.
    Authentication is done via apitoken query parameter (same method used by taf.sw.scout library).

    :param report_id: The comparator report ID (e.g., "1165894")
    :param output_excel_path: Path to save the resulting Excel file
    :param expected_kpis: List of KPI codes to filter (e.g., ['NR_5055c', 'NR_5057e']). If None, all KPIs are included.
    :param expected_dist_names: List of distribution/entity names to filter (e.g., ['bts', 'NRCELL-1']). If None,
                        all entities are included.
    :param testline_name: Scout testline name (optional, not currently used)
    :param api_token: Scout API token for authentication
    :return: True if successful, False otherwise
    """
    if not api_token:
        logger.error("API token is required for Scout API access")
        return False

    try:
        # Build the API endpoint URL (following taf.sw.scout pattern)
        base_url = "https://scout.nsn-rdnet.net"
        api_version = "v1"
        # Use comparator_reports endpoint (not aggregated_comparator_reports)
        endpoint = f"comparator_reports/{report_id}/"

        # Construct full URI
        from urllib.parse import urljoin
        api_base_uri = urljoin(urljoin(base_url, 'future/api/'), api_version) + '/'
        uri = urljoin(api_base_uri, endpoint)

        # Add apitoken as query parameter (taf library pattern)
        params = {'apitoken': api_token}

        logger.info(f"Fetching comparator report {report_id} from Scout API...")
        response = requests.get(url=uri, params=params, verify=False, timeout=300)

        if response.status_code != 200:
            logger.error(f"Failed to fetch report: Status {response.status_code}: {response.text[:500]}")
            return False

        # Parse the JSON response
        data = response.json()
        logger.info(f"Received JSON response with keys: {list(data.keys())}")

        # Extract the report data from JSON API format
        if 'data' in data and 'attributes' in data['data']:
            report_data = data['data']['attributes'].get('report', {})
            kpis_data = report_data.get('kpis', {})

            if not kpis_data:
                logger.error("No KPI data found in report")
                return False

            # Get KPI metadata (name, unit) - may need to be fetched separately
            # For now, use the KPI code as the name
            kpi_metadata = {}

            # FILTER: Only include KPI codes if expected_kpis parameter is provided
            if expected_kpis is not None:
                filtered_kpis = {k: v for k, v in kpis_data.items() if k in expected_kpis}
                if filtered_kpis:
                    logger.info(f"Filtered API response: {len(filtered_kpis)}/{len(kpis_data)} KPIs")
                    kpis_data = filtered_kpis
                # else: use all KPIs if filtering doesn't match (backwards compatibility)

            # Flatten the nested KPI structure into rows for Excel matching web UI format
            # One row per (KPI_code, entity) combination, preserving entity distinctions
            rows = []
            for kpi_code, kpi_info in kpis_data.items():
                kpi_data = kpi_info.get('data', {})
                kpi_name = kpi_metadata.get(kpi_code, {}).get('name', kpi_code)
                kpi_unit = kpi_metadata.get(kpi_code, {}).get('unit', '')

                # Process each entity (bts, cells, etc.)
                for entity_name, entity_data in kpi_data.items():
                    # FILTER: Skip entity if expected_dist_names parameter is provided and entity is not in the list
                    if expected_dist_names is not None and entity_name not in expected_dist_names:
                        continue
                    calculations = entity_data.get('calculations', {})
                    current_period = entity_data.get('current_period', {})
                    reference_period = entity_data.get('reference_period', {})

                    # Format values to match web UI Excel format
                    status = calculations.get('status', '')
                    p_value = calculations.get('p')
                    avg_diff = calculations.get('average_diff', {}).get('value')

                    # Format interval and entity count problems as "No"/"Yes"
                    interval_problem = "Yes" if calculations.get('interval_problem', False) else "No"
                    entity_count_problem = "Yes" if calculations.get('entity_count_problem', False) else "No"

                    # Combine count, min, max, average, median into formatted strings
                    ref_count = reference_period.get('count', '')
                    ref_min = reference_period.get('min', '')
                    ref_max = reference_period.get('max', '')
                    ref_avg = reference_period.get('average', '')
                    ref_median = reference_period.get('median', '')

                    cur_count = current_period.get('count', '')
                    cur_min = current_period.get('min', '')
                    cur_max = current_period.get('max', '')
                    cur_avg = current_period.get('average', '')
                    cur_median = current_period.get('median', '')

                    # Format Count as "Reference \nCurrent" if both exist
                    count_str = ""
                    if ref_count != '' and cur_count != '':
                        count_str = f"{ref_count} \n{cur_count}"
                    elif ref_count != '':
                        count_str = str(ref_count)
                    elif cur_count != '':
                        count_str = str(cur_count)

                    # Same for other fields
                    min_str = f"{ref_min} \n{cur_min}" if ref_min != '' and cur_min != '' else ""
                    max_str = f"{ref_max} \n{cur_max}" if ref_max != '' and cur_max != '' else ""
                    avg_str = f"{ref_avg} \n{cur_avg}" if ref_avg != '' and cur_avg != '' else ""
                    median_str = f"{ref_median} \n{cur_median}" if ref_median != '' and cur_median != '' else ""

                    # Extract raw measurement values for Values column
                    # API provides data as [[value, timestamp], [value, timestamp], ...]
                    # Extract just the values (first element of each pair)
                    ref_data = reference_period.get('data', [])
                    cur_data = current_period.get('data', [])

                    ref_values = [item[0] for item in ref_data] if ref_data else []
                    cur_values = [item[0] for item in cur_data] if cur_data else []

                    # Format Values column to match web UI Excel format
                    # Format: "val1, val2, val3, val4\nval1, val2, val3, val4\n"
                    if ref_values or cur_values:
                        # We have actual measurement data
                        # Convert None to empty string for display
                        ref_vals_str = ', '.join(
                            str(v) if v is not None else ''
                            for v in ref_values
                        ) if ref_values else ', , , '
                        cur_vals_str = ', '.join(
                            str(v) if v is not None else ''
                            for v in cur_values
                        ) if cur_values else ', , , '
                        values_str = f"{ref_vals_str}\n{cur_vals_str}\n"
                    else:
                        # No raw values available - use placeholder format matching reference file
                        if status == 'error' or (not ref_count and not cur_count):
                            # Empty data format
                            values_str = ', , , \n, , , \n'
                        else:
                            # Use placeholder with statistics repeated or empty
                            values_str = ', , , \n, , , \n'

                    # Build row matching web UI Excel column order and names
                    row = {
                        'Code': kpi_code,
                        'Name': kpi_name,  # KPI description (not available from API, using code)
                        'Dist Name': entity_name,  # Entity name (bts, NRCELL-1, etc.)
                        'Range': 'Reference \nCurrent',  # Fixed value for format
                        'Values': values_str,
                        'Unit': kpi_unit,  # Not available from API
                        'Count': count_str,
                        'Min': min_str,
                        'Max': max_str,
                        'Average': avg_str,
                        'Avg Diff': avg_diff if avg_diff is not None else '',
                        'Median': median_str,
                        'Measurement ID': '',  # Not available from API
                        'Measurement Name': '',  # Not available from API
                        'Other Failed Related Dist Names': '',  # Not available from API
                        'P': p_value if p_value is not None else '',
                        'Entity Count Problem': entity_count_problem,
                        'Interval Problem': interval_problem,
                        'Status': status,
                        # Additional API columns to the right
                        'T-Stat': calculations.get('t_stat', ''),
                        'CV': calculations.get('cv', ''),
                        'DF': calculations.get('df', ''),
                        'Current Count': cur_count,
                        'Current Min': cur_min,
                        'Current Max': cur_max,
                        'Current Average': cur_avg,
                        'Current Median': cur_median,
                        'Reference Count': ref_count,
                        'Reference Min': ref_min,
                        'Reference Max': ref_max,
                        'Reference Average': ref_avg,
                        'Reference Median': ref_median,
                    }
                    rows.append(row)

            # Create DataFrame with column order matching web UI Excel
            column_order = [
                'Code', 'Name', 'Dist Name', 'Range', 'Values', 'Unit', 'Count', 'Min', 'Max',
                'Average', 'Avg Diff', 'Median', 'Measurement ID', 'Measurement Name',
                'Other Failed Related Dist Names', 'P', 'Entity Count Problem', 'Interval Problem',
                'Status',
                # Additional API columns
                'T-Stat', 'CV', 'DF', 'Current Count', 'Current Min', 'Current Max',
                'Current Average', 'Current Median', 'Reference Count', 'Reference Min',
                'Reference Max', 'Reference Average', 'Reference Median'
            ]

            df = pd.DataFrame(rows, columns=column_order)
            df.to_excel(output_excel_path, index=False)

            # Enable text wrapping on cells with newlines
            # Ensures multi-line values display correctly in Excel
            try:
                from openpyxl import load_workbook
                from openpyxl.styles import Alignment

                wb = load_workbook(output_excel_path)
                ws = wb.active

                # Text wrapping on cells that contain newlines
                for row in ws.iter_rows():
                    for cell in row:
                        if (cell.value and isinstance(cell.value, str) and
                                '\n' in cell.value):
                            cell.alignment = Alignment(
                                wrap_text=True, vertical='top')

                wb.save(output_excel_path)
                logger.info('Wrap text enabled on cells with newlines')
            except Exception as e:
                logger.warning(f'Could not apply wrap text: {e}')

            logger.info(
                f"Saved comparator report as Excel: {output_excel_path} "
                f"({len(df)} rows, {len(df.columns)} columns)"
            )
            return True
        else:
            logger.error(f"Unexpected response format: {list(data.keys())}")
            return False

    except Exception as e:
        logger.error(f"Failed to fetch or save comparator report: {e}")
        import traceback
        logger.error(traceback.format_exc())
        return False
