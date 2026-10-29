def read_and_process_slotProcessingDurationBudget_file(file_path,
                                                       budget_check_value):
    # Track if any slotProcessingDurationBudget values were found
    budget_found = False
    with open(file_path, 'r') as file:
        for line in file:
            if ('slotProcessingDurationBudget' in line and
                    'LOADTYPEMIXED' in line):
                columns = line.split(';')
                for i in range(len(columns)):
                    if columns[i] == 'slotProcessingDurationBudget':
                        # Set budget_found to True if a value is found
                        budget_found = True
                        if i + 1 < len(columns):
                            budget_value = columns[i + 1].strip()
                            if budget_value != budget_check_value:
                                # Return False if any value doesn't match
                                return False
    # Return True only if values were found and all matched
    if budget_found:
        return True
    else:
        # Return None if no slotProcessingDurationBudget values were found
        return None


def read_and_process_slotProcessingDurationBudget_switch(file_path,
                                                         budget_check_values):
    # Track if each budget value is found
    budget_found = {value: False for value in budget_check_values}
    with open(file_path, 'r') as file:
        for line in file:
            if ('slotProcessingDurationBudget' in line and
                    'LOADTYPEMIXED' in line):
                columns = line.split(';')
                for i in range(len(columns)):
                    if columns[i] == 'slotProcessingDurationBudget':
                        if i + 1 < len(columns):
                            budget_value = columns[i + 1].strip()
                            if budget_value in budget_check_values:
                                # Mark the budget value as found
                                budget_found[budget_value] = True
    # Return True only if all budget values were found
    if all(budget_found.values()):
        return True
    # Return False if only some budget values were found
    elif any(budget_found.values()):
        return False
    else:
        # Return None if no budget values were found
        return None
