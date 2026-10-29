import subprocess
import pkgutil
import importlib
import os
import math


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def is_pandas_installed():
    return bool(pkgutil.find_loader('pandas'))


def install_and_import_pandas():
    print("pandas library installation")
    if not is_pandas_installed():
        install_package('pandas')
    return importlib.import_module('pandas')


def is_tkinter_installed():
    return bool(pkgutil.find_loader('tkinter'))


def install_and_import_tkinter():
    print("tkinter library installation")
    if not is_tkinter_installed():
        install_package('tkinter')
    return importlib.import_module('tkinter')


def dl_validation_multibwp(filepath, dl_slot, K1, csiperiod):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)
    df1 = df[df['type'] == 'dlFdSchedData']
    cellbwp = df1['cellBwpId'].unique()
    cellbwp.sort()
    print('cellbwp', cellbwp)
    for idx in cellbwp:
        df2 = df1[df1['cellBwpId'] == idx]
        slot = df2['slot'].unique()
        k1 = df2['K1'].unique()
        slot.sort()
        k1.sort()
        print("DL Scheduled Slot-{0} and K1-{1} for BWP-{2}".format(slot, k1, idx))
        if idx != 4.0:
            if not (slot == dl_slot).all():
                slot_not_sch = set(dl_slot) - set(slot)
                print("Data not scheduled on DL slots-{0} for BWP-{1}".format(slot_not_sch, idx))
                return 'Fail'
        else:
            print("INFO: As per PR868093 All DL slots may or may not take part for scheduling for BWP-4")
            slot_not_sch = set(dl_slot) - set(slot)
            if len(slot_not_sch) != 0:
                print("INFO: Data not scheduled on DL slots-{0} for BWP-4".format(slot_not_sch))
            else:
                print("INFO: Data scheduled on All DL slots-{0} for BWP-4".format(slot))

        if idx != 4.0:
            if not (k1 == K1).all():
                k1_not_att = set(K1) - set(k1)
                print("K1 not attained-{0} for BWP-{1}".format(k1_not_att, idx))
                return 'Fail'
        else:
            print("INFO: As per PR868093 All K1 may or may not used for scheduling for BWP-4")
            k1_not_att = set(K1) - set(k1)
            if len(k1_not_att) != 0:
                print("INFO: K1 not used for DL scheduling-{0} for BWP-4".format(k1_not_att))
            else:
                print("INFO: All K1 used for DL scheduling-{0} for BWP-4".format(k1))

    sfn_diff = csiperiod / 10
    df3 = df[(df['type'] == 'csiRsSchedData') & (df['csiRsTraceType'] == 'CELLTRS')]
    csi_slot = df3['slot'].unique()
    csi_slot.sort()
    for slot in csi_slot:
        df4 = df3[df3['slot'] == slot]
        df4 = df4.copy()
        df4['sfn_diff'] = df4['sfn'].diff()
        df4 = df4.dropna().reset_index(drop=True)
        df4['not_equal_sfn_diff'] = df4['sfn_diff'] != sfn_diff
        df4['validation'] = df4['not_equal_sfn_diff'].apply(lambda x: "FAIL" if x else "PASS")
        failed_rows = df4[df4['validation'] == "FAIL"]
        if failed_rows.empty:
            print("All rows passed ")
        else:
            print("Validation failed")
            print(failed_rows)
            return 'Fail'

    return 'Pass'


def ul_validation_multibwp(filepath, ul_slot, K2, csiperiod):
    pd = install_and_import_pandas()
    df = pd.read_csv(filepath, low_memory=False)
    df1 = df[df['type'] == 'ulFdSchedData']
    cellbwp = df1['cellBwpId'].unique()
    cellbwp.sort()
    print('cellbwp', cellbwp)
    for idx in cellbwp:
        df2 = df1[df1['cellBwpId'] == idx]
        slot = df2['slot'].unique()
        k2 = df2['K2'].unique()
        slot.sort()
        k2.sort()
        print("UL Scheduled Slot-{0} and K2-{1} for BWP-{2}".format(slot, k2, idx))
        if idx != 4.0:
            if not (slot == ul_slot).all():
                slot_not_sch = set(ul_slot) - set(slot)
                print("Data not scheduled on UL slots-{0} for BWP-{1}".format(slot_not_sch, idx))
                return 'Fail'
        else:
            print("INFO: As per PR868093 All UL slots may or may not take part for scheduling for BWP-4")
            slot_not_sch = set(ul_slot) - set(slot)
            if len(slot_not_sch) != 0:
                print("INFO: Data not scheduled on UL slots-{0} for BWP-4".format(slot_not_sch))
            else:
                print("INFO: Data scheduled on All UL slots-{0} for BWP-4".format(slot))

        if idx != 4.0:
            if not (k2 == K2).all():
                k2_not_att = set(K2) - set(k2)
                print("K2 not attained-{0} for BWP-{1}".format(k2_not_att, idx))
                return 'Fail'
        else:
            print("INFO: As per PR868093 All K2 may or may not used for scheduling for BWP-4.0")
            k2_not_att = set(K2) - set(k2)
            if len(k2_not_att) != 0:
                print("INFO: K2 not used for UL scheduling-{0} for BWP-4".format(k2_not_att))
            else:
                print("INFO: All K2 used for UL scheduling-{0} for BWP-4".format(k2))

    sfn_diff = csiperiod / 10
    df3 = df[(df['type'] == 'csiRsSchedData') & (df['csiRsTraceType'] == 'CELLTRS')]
    csi_slot = df3['slot'].unique()
    csi_slot.sort()
    for slot in csi_slot:
        df4 = df3[df3['slot'] == slot]
        df4 = df4.copy()
        df4['sfn_diff'] = df4['sfn'].diff()
        df4 = df4.dropna().reset_index(drop=True)
        df4['not_equal_sfn_diff'] = df4['sfn_diff'] != sfn_diff
        df4['validation'] = df4['not_equal_sfn_diff'].apply(lambda x: "FAIL" if x else "PASS")
        failed_rows = df4[df4['validation'] == "FAIL"]
        if failed_rows.empty:
            print("All rows passed ")
        else:
            print("Validation failed")
            print(failed_rows)
            return 'Fail'
    return 'Pass'


def merge_multiple_csv(filepath, dire):
    pd = install_and_import_pandas()
    df_list = []
    csv_file_list = sorted(os.listdir(filepath))
    print("csv file", csv_file_list)

    for i in range(0, len(csv_file_list)):
        if 'output_' + dire + '_formated_' + str(i) + '.csv' in csv_file_list:
            file = 'output_' + dire + '_formated_' + str(i) + '.csv'
            print('file', file)
            df_list.append(
                pd.read_csv(
                    os.path.join(
                        filepath,
                        file),
                    low_memory=False))
            os.remove(os.path.join(filepath, file))
    df = pd.concat(df_list, ignore_index=True)
    filename = 'output_' + dire + '_formated.csv'
    df.to_csv(os.path.join(filepath, filename), index=False)


def syslog_search(filename, search_strings):
    try:
        with open(filename, 'r') as file:
            lines = file.readlines()
        wrn_results = []
        err_results = []
        for line in lines:
            for search_string in search_strings:
                if search_string in line:
                    if search_string == 'WRN/':
                        wrn_results.append(line)
                    elif search_string == 'ERR/':
                        err_results.append(line)

        # Export results to CSV file
        directory_path, file_path = os.path.split(filename)
        txt_file_path = os.path.join(directory_path, 'filtered_syslog.txt')
        print("txt_file_path: ", txt_file_path)
        with open(txt_file_path, 'w') as filtered_syslog:
            if wrn_results:
                filtered_syslog.write('Results for \'WRN/\':\n')
                for line in wrn_results:
                    filtered_syslog.write(line.strip() + '\n')
            else:
                filtered_syslog.write('No \'WRN/\' results found.\n')

            if err_results:
                filtered_syslog.write('Results for \'ERR/\':\n')
                for line in err_results:
                    filtered_syslog.write(line.strip() + '\n')
            else:
                filtered_syslog.write('No \'ERR/\' results found.\n')

    except FileNotFoundError:
        print("File not found:", filename)


def Verify_Max_UEs_PerSlot(file_path, expected_ue_total):
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(file_path)
    print("directory_path: ", directory_path)
    # Step 1: Read the CSV file with low_memory=False to suppress DtypeWarning
    df = pd.read_csv(file_path, low_memory=False)
    # Step 2: Determine whether it's UL or DL based on filename
    file_name = os.path.basename(file_path).lower()
    if 'ul' in file_name:
        ue_column = 'fdSchedInfo.scheduledUes'
    else:
        ue_column = 'fdSchedInfo[0].scheduledUes'
    # Validate the expected column exists
    if ue_column not in df.columns:
        raise ValueError(
            f"Expected UE column '{ue_column}' not found in the input file.")
    # Step 3: Create the key column
    df['key'] = df['sfn'].astype(
        str) + '_' + df['slot'].astype(str) + '_' + df['hfnTickCount'].astype(str)
    # Step 4: Keep only necessary columns
    df = df[['key', ue_column, 'physCellId']].dropna()

    # Step 5: Merge values per key

    def merge_values(values):
        return ','.join(str(v).strip() for v in values if pd.notna(v))

    grouped_df = df.groupby('key').agg({
        ue_column: merge_values,
        'physCellId': merge_values
    }).reset_index()

    # Step 6: Calculate total UEs per key

    def calculate_ue_total(ue_string):
        try:
            ue_values = [float(val.strip())
                         for val in str(ue_string).split(',') if val.strip()]
            return sum(ue_values)
        except BaseException:
            return 0.0

    grouped_df['UE_Total'] = grouped_df[ue_column].apply(calculate_ue_total)
    # Step 7: Add PASS/FAIL result column
    grouped_df['Result'] = grouped_df['UE_Total'].apply(
        lambda x: 'PASS' if x == expected_ue_total else f'FAIL - Total UEs != {expected_ue_total} (Found {x})')
    # Step 8: Save the final grouped DataFrame
    output_path = directory_path + 'Max_UEs_PerSlot.csv'
    grouped_df.to_csv(output_path, index=False)
    print(f"? Final grouped file with physCellId saved to: {output_path}")
    # Final pass/fail decision
    if (grouped_df['Result'] == 'PASS').any():
        final_result = f"PASS - Max UEs per slot is {expected_ue_total}"
    else:
        final_result = f"FAIL - Max UEs per slot not achieved (Expected {expected_ue_total})"
    print(f"? Final Verdict: {final_result}")


def Verify_K2(input_file):
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(input_file)
    print("directory_path: ", directory_path)
    try:
        # Read input CSV
        df = pd.read_csv(input_file)
        # Filter for type == 'ulFdSchedData'
        filtered_df = df[df["type"] == "ulFdSchedData"]
        # Select specific columns
        columns_to_keep = [
            "K2",
            "hfnTickCount",
            "rnti",
            "sfn",
            "slot",
            "physCellId"]
        filtered_df = filtered_df[columns_to_keep]
        # Remove rows where K2 == 65535
        filtered_df = filtered_df[filtered_df["K2"] != 65535]
        # Compute DL_slot
        filtered_df["DL_slot"] = filtered_df["slot"] - filtered_df["K2"]
        # Create Key = sfn_DL_slot_hfnTickCount
        filtered_df["Key"] = (
                filtered_df["sfn"].astype(str) + "_" +
                filtered_df["DL_slot"].astype(str) + "_" +
                filtered_df["hfnTickCount"].astype(str)
        )
        # Validation rule sets
        rules = {
            (0, 1, 10, 11): [4],
            (2, 12): [4, 5],
            (3, 13): [5, 6]
        }
        validation_issues = []
        pass_messages = []
        for dl_slots, expected_k2s in rules.items():
            for dl in dl_slots:
                subset = filtered_df[filtered_df["DL_slot"] == dl]
                actual_k2s = set(subset["K2"].unique())
                missing_k2s = [
                    k2 for k2 in expected_k2s if k2 not in actual_k2s]
                if missing_k2s:
                    for k2 in missing_k2s:
                        validation_issues.append(
                            f"DL_slot={dl} is missing expected K2={k2}")
            if not any(dl in filtered_df["DL_slot"].values for dl in dl_slots):
                validation_issues.append(
                    f"No records found for DL_slot(s): {dl_slots}")
            elif not missing_k2s:
                pass_messages.append(
                    f"? For DL_slot {list(dl_slots)}, K2 is {', '.join(map(str, expected_k2s))}")
        # Save output CSV
        output_file = directory_path + "K2.csv"
        filtered_df.to_csv(output_file, index=False)
        print(f"Filtered data saved to {output_file}")
        # Final validation output
        if validation_issues:
            print("Validation issues found:")
            for issue in validation_issues:
                print(" -", issue)
            return []
        else:
            for msg in pass_messages:
                print(msg)
            return pass_messages
    except Exception as e:
        print(f"An error occurred: {e}")
        return []


def Verify_HARQ_slots(
        input_file: str,
        actEnhancedPDSCHSchSplSlot: int,
        guardPeriodLength: int) -> str:
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(input_file)
    print("directory_path: ", directory_path)
    """
    Filters DL HARQ data from CSV, checks slot values based on configs,
    saves filtered data to a CSV file, and returns pass/fail with comments.
    Args:
        input_file (str): Path to the input CSV file.
        actEnhancedPDSCHSchSplSlot (int): Special slot config (0 or 1).
        guardPeriodLength (int): Guard period length (expected: 6 or 4).
    Returns:
        str: Result message with PASS/FAIL and explanation.
    """
    try:
        # Read CSV
        df = pd.read_csv(input_file)
        # Filter on 'type' column
        filtered_df = df[df["type"] == "dlHarqRxDataArray"]
        # Keep only required columns
        selected_columns = ["hfnTickCount", "sfn", "slot", "physCellId"]
        filtered_df = filtered_df[selected_columns]
        # Drop empty columns
        filtered_df = filtered_df.dropna(axis=1, how='all')
        # Save filtered DataFrame
        output_file = directory_path + "HARQ_slots.csv"
        filtered_df.to_csv(output_file, index=False)
        print(f"Filtered data saved to {output_file}")
        # Define required slots and comments
        if actEnhancedPDSCHSchSplSlot == 0 and guardPeriodLength == 6:
            required_slots = [6, 7, 8, 16, 17, 18]
            comment = (
                "PASS: HARQ is scheduled on the slots 6, 7, 8, 16, 17, 18. "
                "No scheduling of HARQ on 4 & 14 because the spl slot is not used for scheduling PDSCH.")
        elif actEnhancedPDSCHSchSplSlot == 1 and guardPeriodLength == 4:
            required_slots = [4, 6, 7, 8, 14, 16, 17, 19]
            comment = (
                "PASS: HARQ is scheduled on the slots 4, 6, 7, 8, 14, 16, 17, 19. "
                "Scheduling of HARQ on 4 & 14 because the spl slot are used for scheduling PDSCH.")
        else:
            return "FAIL: Unsupported actEnhancedPDSCHSchSplSlot and guardPeriodLength configuration."
        # Check if all required slots are present
        slot_values = filtered_df["slot"].dropna().unique()
        if all(slot in slot_values for slot in required_slots):
            return comment
        else:
            return "FAIL: Required slot values are missing from the data."
    except Exception as e:
        return f"FAIL: An error occurred - {e}"


def Verify_K1(
        input_file,
        actEnhancedPDSCHSchSplSlot=0,
        guardPeriodLength=6):
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(input_file)
    print("directory_path: ", directory_path)
    # Step 1 & 2: Read the file
    df = pd.read_csv(input_file)
    # Step 3: Filter rows
    df = df[df['type'] == 'dlFdSchedData']
    # Step 4: Select required columns
    required_cols = ['hfnTickCount', 'sfn', 'slot', 'physCellId', 'K1']
    df = df[required_cols]
    # Step 5: Drop entirely empty columns
    df = df.dropna(axis=1, how='all')
    # Ensure slot and K1 are integers (in case they are strings)
    df['slot'] = pd.to_numeric(df['slot'], errors='coerce')
    df['K1'] = pd.to_numeric(df['K1'], errors='coerce')
    result = "FAIL"
    comment = "Conditions not met."
    if actEnhancedPDSCHSchSplSlot == 0 and guardPeriodLength == 6:
        slots_to_check = [0, 1, 2, 10, 11, 12]
        df_check = df[df['slot'].isin(slots_to_check)]
        if all(df_check['K1'] == 6):
            result = "PASS"
            comment = "K1 is 6 for the slots 0, 1, 2, 10, 11, 12. No scheduling of PDSCH on the spl slot."
    elif actEnhancedPDSCHSchSplSlot == 1 and guardPeriodLength == 4:
        main_slots = [0, 1, 2, 10, 11, 12]
        extra_slots = [3, 13]
        df_main = df[df['slot'].isin(main_slots)]
        df_extra = df[df['slot'].isin(extra_slots)]
        if all(df_main['K1'] == 6) and all(df_extra['K1'] == 11):
            result = "PASS"
            comment = "K1 is 6 for the slots 0, 1, 2, 10, 11, 12 & K1 is 11 for slots 3, 13"
    # Optional: write filtered df to file
    output_file = directory_path + "K1.csv"
    df.to_csv(output_file, index=False)
    return result, comment


def Verify_RA_slots(input_file, prach_config_index):
    pd = install_and_import_pandas()

    # Convert prach_config_index to int (fixes key mismatch in map)
    prach_config_index = int(prach_config_index)

    # Define output file
    output_file = 'filtered_preamble_data.csv'
    directory_path, filename = os.path.split(input_file)
    output_path = os.path.join(directory_path, output_file)

    # Read CSV with safe options
    df = pd.read_csv(input_file, dtype=str, low_memory=False)

    # Filter rows where type == 'preambleData'
    df_filtered = df[df['type'] == 'preambleData']

    # Keep relevant columns
    columns_to_keep = ['hfnTickCount', 'sfn', 'slot', 'physCellId']

    df_selected = df_filtered[columns_to_keep]

    # Clean slot values safely
    df_selected.loc[:, 'slot'] = pd.to_numeric(
        df_selected['slot'], errors='coerce')
    df_cleaned = df_selected.dropna(subset=['slot'])
    df_cleaned.loc[:, 'slot'] = df_cleaned['slot'].astype(int)

    # Save cleaned file
    df_cleaned.to_csv(output_path, index=False)
    print(f"Filtered data written to: {output_path}")

    # Expected RA slot per PRACH config index
    slot_check_map = {
        98: 19,
        93: 9,
        195: 15
    }

    if prach_config_index in slot_check_map:
        expected_slot = slot_check_map[prach_config_index]
        print("Expected slot:", expected_slot)

        unique_slots = df_cleaned['slot'].unique()
        print("Unique slots found:", unique_slots)
        print("Set comparison:", set(unique_slots) == {expected_slot})

        if set(unique_slots) == {expected_slot}:
            return "PASS", f"RA preamble is scheduled in slot {expected_slot}."
        else:
            return "FAIL", f"Unexpected slot values found: {list(unique_slots)}. Expected only slot {expected_slot}."
    else:
        return "INFO", f"Prach config index {prach_config_index} not handled in slot check map."


def Verify_SRS_beam(input_file):
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(input_file)
    print("directory_path:", directory_path)

    validation_issues = []
    pass_messages = []

    try:
        # Read input CSV
        df = pd.read_csv(input_file)

        # Filter for rows where type == 'dlFdSchedData'
        filtered_df = df[df["type"] == "dlFdSchedData"]

        # Check condition
        if filtered_df.empty:
            validation_issues.append(
                "No rows found with type 'dlFdSchedData'.")
        elif "beamType" not in filtered_df.columns:
            validation_issues.append("'beamType' column is missing.")
        elif not any(filtered_df["beamType"] == "DFTNONTAPERING"):
            validation_issues.append(
                "No rows found with beamType 'DFTNONTAPERING'.")
        else:
            pass_messages.append(
                "Validation passed: beamType 'DFTNONTAPERING' found.")

        # Save filtered output
        output_file = os.path.join(directory_path, "SRS_beam.csv")
        filtered_df.to_csv(output_file, index=False)
        print(f"Filtered data saved to {output_file}")

        # Final output
        if validation_issues:
            print("Validation issues found:")
            for issue in validation_issues:
                print(" -", issue)
            return []
        else:
            for msg in pass_messages:
                print(msg)
            return pass_messages

    except Exception as e:
        print(f"Error during verification: {str(e)}")
        return []


def Verify_CA_Checks(file_path, direction):
    pd = install_and_import_pandas()
    direction = direction.strip().lower()
    if direction not in ["ul", "dl"]:
        raise ValueError("Direction must be 'ul' or 'dl'.")

    print(f"Processing {direction.upper()} file: {file_path}")
    df = pd.read_csv(file_path)
    df.columns = df.columns.str.strip().str.lower()

    if 'type' not in df.columns:
        raise ValueError("'type' column is missing in the input file.")

    df['type'] = df['type'].astype(str).str.strip().str.lower()

    # Select relevant types based on direction
    valid_types = {
        "ul": ["ulfdscheddata", "csisrreportdata"],
        "dl": ["dlfdscheddata", "csisrreportdata"]
    }
    detected_types = [t for t in valid_types[direction]
                      if t in df['type'].unique()]
    if not detected_types:
        raise ValueError(
            f"No relevant types found for direction '{direction}'.")

    def check_cell_mapping(df_sub, cell_id, expected_type):
        ue_values = df_sub[df_sub['physcellid'] ==
                           cell_id]['uetype'].dropna().str.upper().unique()
        ue_values = [val for val in ue_values if val != "FAKE"]
        print(
            f"Checking physCellId {cell_id}: found ueType values {ue_values}")
        return expected_type in ue_values

    for dtype in detected_types:
        print(f"\n=== Processing data type: {dtype.upper()} ===")
        df_type = df[df['type'] == dtype].copy()

        if dtype.endswith("fdscheddata"):
            required_cols = [
                "type",
                "hfntickcount",
                "sfn",
                "slot",
                "physcellid",
                "uetype",
                "txnumber"]
            missing = [
                col for col in required_cols if col not in df_type.columns]
            if missing:
                print(f"Skipping {dtype}: missing columns {missing}")
                continue

            df_type = df_type[required_cols].dropna(axis=1, how='all')
            df_type['physcellid'] = pd.to_numeric(
                df_type['physcellid'], errors='coerce')
            df_type['uetype'] = df_type['uetype'].astype(
                str).str.strip().str.upper()

            print("=== PCELL/SCELL Validation ===")
            print(
                f"physCellId 55 is PCELL: {'YES' if check_cell_mapping(df_type, 55, 'PCELL') else 'NO'}")
            print(
                f"physCellId 56 is SCELL: {'YES' if check_cell_mapping(df_type, 56, 'SCELL') else 'NO'}")
            print(
                f"physCellId 57 is SCELL: {'YES' if check_cell_mapping(df_type, 57, 'SCELL') else 'NO'}")

            print("=== New retransmission check ===")
            retransmit_count = df_type[df_type['txnumber'].astype(
                float) > 1].shape[0]
            if retransmit_count > 3:
                print(
                    f"Retransmission check: FAIL (txNumber > 1 occurred {retransmit_count} times)")
            else:
                print(
                    f"Retransmission check: PASS (txNumber > 1 occurred {retransmit_count} times)")

        elif dtype == "csisrreportdata":
            if 'dtx' not in df_type.columns:
                print("Skipping DTX check: 'dtx' column missing.")
                continue
            print("=== DTX check ===")
            dtx_count = df_type['dtx'].astype(
                str).str.upper().value_counts().get("DTX", 0)
            if dtx_count > 5:
                print(f"DTX check: FAIL (too many DTX received: {dtx_count})")
            else:
                print(f"DTX check: PASS (DTX occurrences: {dtx_count})")

        # Save filtered output
        output_file = f"{dtype}_{direction}_filtered.csv"
        df_type.to_csv(output_file, index=False)
        print(f"Saved filtered data to: {output_file}")


def Verify_multiple_UE_scheduling(input_file):
    pd = install_and_import_pandas()
    directory_path, filename = os.path.split(input_file)
    print("directory_path:", directory_path)

    validation_issues = []
    pass_messages = []

    try:
        # Read input CSV
        df = pd.read_csv(input_file)

        # Filter for rows where type == 'dlLoadControlData'
        filtered_df = df[df["type"] == "dlLoadControlData"]

        # Check condition on column 'fdSchedInfo[0].scheduledUes'
        if filtered_df.empty:
            validation_issues.append(
                "No rows found with type 'dlLoadControlData'.")
        elif "fdSchedInfo[0].scheduledUes" not in filtered_df.columns:
            validation_issues.append(
                "'fdSchedInfo[0].scheduledUes' column is missing.")
        elif not any(filtered_df["fdSchedInfo[0].scheduledUes"] == 16):
            # If the column contains integers, compare with integer 16
            # If they are strings, compare with "16"
            validation_issues.append(
                "No rows found with 'fdSchedInfo[0].scheduledUes' == 16.")
        else:
            pass_messages.append(
                "Validation passed: 'fdSchedInfo[0].scheduledUes' == 16 found.")

        # Save filtered output
        output_file = os.path.join(directory_path, "UE_scheduling.csv")
        filtered_df.to_csv(output_file, index=False)
        print(f"Filtered data saved to {output_file}")

        # Final output
        if validation_issues:
            print("Validation issues found:")
            for issue in validation_issues:
                print(" -", issue)
            return []
        else:
            for msg in pass_messages:
                print(msg)
            return pass_messages

    except Exception as e:
        print(f"Error during verification: {str(e)}")
        return []
