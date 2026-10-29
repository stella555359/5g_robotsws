import subprocess
import pkgutil
import importlib


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


def verify_dl_muting_in_tti_trace(csv_file, dl_slots):
    """
    Counts the number of rows in a CSV file where 'type' is 'dlFdSchedData' and 'slot' is 9 or 19.
    Args:
        csv_file: The path to the CSV file.
        dl_slots: list of sfn slots where muting is applied.
    Returns:
        The number of rows matching the criteria.
    """
    pd = install_and_import_pandas()
    print(f"Debug Manasa csv {csv_file} and dl_slots {dl_slots[0]}   {dl_slots[1]}")
    df = pd.read_csv(csv_file, low_memory=False)
    filtered_df = df[
        (df['type'] == 'dlFdSchedData') &
        ((df['slot'] == int(dl_slots[0])) | (df['slot'] == int(dl_slots[1])))]
    row_count = len(filtered_df)
    print(f"Number of rows with 'type' = 'dlFdSchedData' and 'slot' = {dl_slots[0]} or {dl_slots[1]}: {row_count}")
    return row_count

# Example usage:
# verify_dl_muting_in_tti_trace("/home/ute/output_dl_formated.csv",[9,19])
