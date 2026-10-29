from collections import namedtuple


def extract_alarms(data):
    # Initialize an empty list to store the formatted strings
    formatted_alarms = {}
    print(data)
    print('xxx')
    # Iterate over each alarm in the data
    for alarm in data:
        # Extract specificProblem and additionalText1
        fault_id = alarm.additionalText3
        keyword = "additionalFaultID="
        print(fault_id)
        if fault_id is not None:
            fault_id = fault_id[fault_id.find(keyword) + len(keyword):].strip() if keyword in fault_id else None
            fault_id = fault_id.split()[0]
            additionalText = alarm.additionalText1

            # Format the string and append it to the list
            formatted_alarms[fault_id] = additionalText

    # Return the list of formatted strings
    return formatted_alarms
