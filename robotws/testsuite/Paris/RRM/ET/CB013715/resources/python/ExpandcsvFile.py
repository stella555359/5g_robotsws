import os
import logging
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate


# Function to expand rows with comma-separated values into multiple rows
def expand_rows(df, pattern='UlData_puschReceiveReqGrant_t'):
    expanded_data = []
    for _, row in df.iterrows():
        startPrb_values = str(row['UlData_puschReceiveReqGrant_t.startPrb']).split(',')
        numOfPrb_values = str(row['UlData_puschReceiveReqGrant_t.numOfPrb']).split(',')
        rnti_values = str(row['3gpp.rnti']).split(',')

        max_len = max(len(startPrb_values), len(numOfPrb_values), len(rnti_values))

        for i in range(max_len):
            new_row = row.copy()
            new_row[pattern+'.startPrb'] = startPrb_values[i] if i < len(startPrb_values) else ''
            new_row[pattern+'.numOfPrb'] = numOfPrb_values[i] if i < len(numOfPrb_values) else ''
            new_row['3gpp.rnti'] = rnti_values[i] if i < len(rnti_values) else ''
            expanded_data.append(new_row)

    return pd.DataFrame(expanded_data)


def get_directory(path_to_file):
    return os.path.dirname(path_to_file)


def get_filename_without_extension(path_to_file):
    # Split the file path into the root and extension
    root, _ = os.path.splitext(path_to_file)
    # Get the base name of the file (without the directory path)
    filename_without_extension = os.path.basename(root)
    return filename_without_extension


def expand_file(path_to_csv, pattern='UlData_puschReceiveReqGrant_t'):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df_data = pd.read_csv(path_to_csv, sep=';')
    df = pd.DataFrame(df_data)

    logging.info(df.head(20).to_string())

    # Expand the rows
    expanded_df = expand_rows(df, pattern)

    logging.info(expanded_df.head(20).to_string())

    # Save the expanded DataFrame to a csv file
    name = get_filename_without_extension(path_to_csv)
    filename_csv = str("%s/%s_expand.csv" % (get_directory(path_to_csv), name))
    expanded_df.to_csv(filename_csv, sep=';', index=False)

    print(f"The expanded csv file {filename_csv} has been created successfully.")
    return filename_csv


def main_test():
    # Create a DataFrame from the dictionary
    global pd
    pd = pandas_gate.install_and_import_pandas()
    path_to_csv = '/home/ute/csamson/TRACES/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId1.csv'
    df_data = pd.read_csv(path_to_csv, sep=';')
    df = pd.DataFrame(df_data)

    # Expand the rows
    expanded_df = expand_rows(df, 'UlData_puschReceiveReqGrant_t')

    # Save the expanded DataFrame to a csv file
    name = get_filename_without_extension(path_to_csv)
    filename = str("%s/%s_expand.csv" % (get_directory(path_to_csv), name))
    expanded_df.to_csv(filename, sep=';', index=False)

    print(f"The expanded csv file {filename} has been created successfully.")


def main_test_robot():
    path_to_csv = '/home/ute/csamson/TRACES/pcapprocessed_PRB_Blanking_uldata_puschreceivereq_subcellId1.csv'
    expand_file(path_to_csv, pattern='UlData_puschReceiveReqGrant_t')


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    # main_test()
    main_test_robot()
