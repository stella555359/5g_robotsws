import re
import subprocess
import os
import psutil
from robot.libraries.BuiltIn import BuiltIn


def detected_alarms_parser(output):
    output = str(output)
    parsed_output = "Detected fault(s):"
    for match in re.findall(r"DetectedAlarm\("
                            r"detection_time=(.*?), "
                            r"alarm_id=(.*?), "
                            r"fault_id=(.*?), "
                            r"fault_name=(.*?), "
                            r"hw_path=(.*?), "
                            r"severity=(.*?), "
                            r"reason=(.*?), "
                            r"unit_path=(.*?), "
                            r"impacted_cells_count=(.*?), "
                            r"fault_signature=(.*?)\)", output):
        detection_time = match[0]
        fault_id = match[2]
        fault_name = match[3]
        unit_path = match[7]
        parsed_output += "\n Detection time:" + detection_time
        parsed_output += "\n Fault ID:" + fault_id
        parsed_output += "\n Fault name:" + fault_name
        parsed_output += "\n Unit path:" + unit_path
        parsed_output += "\n"
    return parsed_output


def generate_table(headers, data):
    column_widths = [
        max(len(str(header)), max(len(str(row[i])) for row in data))
        for i, header in enumerate(headers)
    ]
    table = "+"
    for width in column_widths:
        table += "-" * (width + 2) + "+"
    table += "\n"
    table += "|"
    for header, width in zip(headers, column_widths):
        table += f" {str(header):<{width}} |"
    table += "\n"
    table += "+"
    for width in column_widths:
        table += "-" * (width + 2) + "+"
    table += "\n"
    for row in data:
        table += "|"
        for item, width in zip(row, column_widths):
            table += f" {str(item):<{width}} |"
        table += "\n"
    table += "+"
    for width in column_widths:
        table += "-" * (width + 2) + "+"
    table += "\n"
    print(table)


def return_text_in_frame(text):
    text_length = len(text)
    frame_top = "+" + "-" * (text_length + 2) + "+"
    frame_middle = f"| {text} |"
    frame_bottom = "+" + "-" * (text_length + 2) + "+"
    text_in_frame = f"{frame_top}\n{frame_middle}\n{frame_bottom}"
    return text_in_frame


def increase_swap_memory(size: str, dir="/tmp"):
    """
    Increases swap memory in Linux by creating a swap file.
    Args:
        size (str): Desired swap memory size (e.g., '2GB', '500MB').
        dir (str, optional): Path to the swap file. Defaults to '/tmp'
    Returns:
        str: Status message indicating success or failure.
    """
    try:
        if not size.lower().endswith(('mb', 'gb')):
            return "Invalid size format. Please use MB or GB."

        numeric_value = float(size[:-2])
        unit = size[-2:].lower()

        if unit == 'gb':
            numeric_value *= 1024
        swap_file_path = os.path.join(dir, "swap")

        if os.path.exists(swap_file_path):
            return f"Swap file already exists at {swap_file_path}."

        subprocess.run(['sudo', 'fallocate', '-l', f'{numeric_value}M', swap_file_path])
        subprocess.run(['sudo', 'chmod', '600', swap_file_path])
        subprocess.run(['sudo', 'mkswap', swap_file_path])
        subprocess.run(['sudo', 'swapon', swap_file_path])

        swap_info = psutil.swap_memory()
        swap_total_gb = swap_info.total / (1024.0 ** 3)
        ram_info = psutil.virtual_memory()
        ram_total_gb = ram_info.total / (1024.0 ** 3)
        return f"Swap file created and enabled successfully ({size})." \
               f" Total swap memory: {swap_total_gb:.2f}GB." \
               f" Total RAM: {ram_total_gb:.2f}GB."

    except Exception as e:
        return f"Error: {str(e)}"


def set_custom_log_level(set_loglevel=None):
    """
    Sets the custom log level in Robot Framework.

    This function allows setting the log level to one of the following valid levels:
    TRACE, DEBUG, INFO, WARN, ERROR, NONE. It takes an optional argument `set_loglevel`,
    and if not provided, it checks for the `${SET_LOGLEVEL}` variable. If neither the argument
    nor the variable are set, it keeps the default log level (TRACE).

    Args:
        set_loglevel (str, optional): The desired log level. If not provided, `${SET_LOGLEVEL}`
        is used. If none is available, the log level remains unchanged.
    """
    valid_log_levels_pattern = r'TRACE|DEBUG|INFO|WARN|ERROR|NONE'

    if not set_loglevel:
        set_loglevel = BuiltIn().get_variable_value('${SET_LOGLEVEL}', 'not_exist')

    if set_loglevel == 'not_exist':
        BuiltIn().log("No log level provided, keeping default log level (TRACE).", level="WARN")
        return

    matches = re.findall(f'^({valid_log_levels_pattern})$', set_loglevel)

    if matches:
        BuiltIn().set_log_level(set_loglevel)
        BuiltIn().log(f"Log level set to: {set_loglevel}", level="WARN")
    else:
        BuiltIn().log(f"Invalid log level: {set_loglevel}. Keeping the current log level (TRACE).", level="WARN")
