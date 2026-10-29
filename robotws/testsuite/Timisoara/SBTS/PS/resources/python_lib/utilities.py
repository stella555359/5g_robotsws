import re


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
