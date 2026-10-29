import csv


def Check_TTI_Parameters_Values(file_path, type_ue_mode):
    """
    This function processes a CSV file containing TTI (Transmission Time Interval) parameters and filters rows based on
    specific conditions. It checks for certain priority indices and evaluates conditions on specific fields related
    to MAC CE (Medium Access Control Control Element) parameters.
    Functionality:
    1. Opens the CSV file specified by `file_path` and reads its contents using `csv.DictReader`.
    2. Iterates through each row in the CSV file and filters rows based on the following conditions:
       - The `dlFdSchedData.priorityIndex` field must be either 'DLMACCE' or 'P09_DLMACCE'.
       - Depending on the `type_ue_mode`:
         - If `type_ue_mode` is 'SA_UE', the function checks if:
           - `dlFdSchedData.macCe.hasSCellActDeact` equals 1, and
           - `dlFdSchedData.macCe.sCellActDeact` equals either 6 or 0.
         - If the above condition is met, the row is added to the result list.
         - Alternatively, if `type_ue_mode` is 'NSA_UE' and `dlFdSchedData.macCe.hasSCellActDeact` equals 4
           and `dlFdSchedData.macCe.sCellActDeact` equals 0, the row is also added to the result list.
    3. The filtered rows are stored in the `result` list as dictionaries containing the relevant fields.
    4. Prints the filtered results and the total count of rows that meet the conditions.
    5. Returns the count of rows that satisfy the conditions.

    Parameters:
    :param file_path (str):    The path to the CSV file containing TTI parameters.
    :param type_ue_mode (str): The UE (User Equipment) mode type. Possible values: 'SA_UE' (Standalone UE),
                                                                                   'NSA_UE' (Non-standalone UE).
    :return: Returns the count of rows that satisfy the conditions
    """

    result = []

    # Open the CSV file and read its contents
    with open(file_path, mode='r') as file:
        reader = csv.DictReader(file)

        # Iterate through rows and filter based on the condition
        for row in reader:
            if row['dlFdSchedData.priorityIndex'] == 'DLMACCE' or row['dlFdSchedData.priorityIndex'] == 'P09_DLMACCE':
                has_val = float(row['dlFdSchedData.macCe.hasSCellActDeact'])
                act_val = float(row['dlFdSchedData.macCe.sCellActDeact'])
                if type_ue_mode == 'SA_UE' and has_val == 1 and (act_val == 6 or act_val == 0):
                    result.append({
                        'dlFdSchedData.macCe.hasSCellActDeact': has_val,
                        'dlFdSchedData.macCe.sCellActDeact': act_val
                    })
                elif type_ue_mode == 'NSA_UE' and has_val == 4 and act_val == 0:
                    result.append({
                        'dlFdSchedData.macCe.hasSCellActDeact': has_val,
                        'dlFdSchedData.macCe.sCellActDeact': act_val
                    })

    print(result)
    print("Length of result:", len(result))
    return len(result)
