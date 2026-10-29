import re
import subprocess
import os
import psutil


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


def print_table(headers, data):
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
