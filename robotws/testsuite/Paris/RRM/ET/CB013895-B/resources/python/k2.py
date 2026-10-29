def Read_And_Process_K2_File(file_path, k2_check_values):
    """
    Reads the given file and checks K2 values based on the provided criteria.
    Excludes lines with fake RNTIs: 0, 65521, 65534, 65535.

    Args:
        file_path (str): Path to the input file.
        k2_check_values (list): List of K2 values to check.

    Returns:
        True if all K2 values match the criteria,
        False if any K2 value does not match,
        None if no K2 values were found.
    """
    fake_rntis = {'0', '65521', '65534', '65535'}
    k2_values = set()
    k2_found = False

    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            if 'ulFdSchedData' in line and not any(f";rnti;{r};" in line for r in fake_rntis):
                columns = line.split(';')
                for i in range(len(columns)):
                    if columns[i].startswith('K2') and i + 1 < len(columns):
                        k2_value = columns[i + 1].strip()
                        k2_values.add(k2_value)
                        k2_found = True

    if not k2_found:
        return None

    # Case 1: All K2 values must be equal to the single value in k2_check_values
    if len(k2_check_values) == 1:
        return all(value == k2_check_values[0] for value in k2_values)

    # Case 2: All values in k2_check_values must be present in the extracted K2 values
    return set(k2_check_values).issubset(k2_values)
