import re
from robot.api.deco import keyword


@keyword
def verify_throughput_value_from_file(
    filename, section_label, column_name, expected_min, expected_max
):
    column_order = ["Current", "Minimum", "Maximum", "Average"]

    expected_min = float(expected_min)
    expected_max = float(expected_max)

    with open(filename, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    value = None

    for line in lines:
        if section_label.lower() == "total":
            if re.match(r"\d+\s+cells", line.strip()):
                parts = re.findall(r"[\d.]+", line)
                if len(parts) >= 4:
                    try:
                        index = column_order.index(column_name)
                        value = float(parts[index])
                        break
                    except (IndexError, ValueError):
                        raise AssertionError(
                            f"Failed to parse value for 'Total {column_name}'."
                        )
        elif line.strip().startswith(section_label):
            parts = re.findall(r"[\d.]+", line)
            if len(parts) >= 4:
                try:
                    index = column_order.index(column_name)
                    value = float(parts[index])
                    break
                except (IndexError, ValueError):
                    raise AssertionError(
                        f"Failed to parse value for '{section_label} {column_name}'."
                    )

    if value is None:
        raise AssertionError(
            f"Section '{section_label}' not found in file '{filename}'."
        )

    print(f"{section_label} {column_name}: {value:.3f} Mbps")

    if expected_min <= value <= expected_max:
        print(
            f"{section_label} {column_name}: {value:.3f} Mbps is within the expected range "
            f"{expected_min:.2f} - {expected_max:.2f} Mbps."
        )
    else:
        raise AssertionError(
            f"{section_label} {column_name}: {value:.3f} Mbps is OUTSIDE the expected range "
            f"{expected_min:.2f} - {expected_max:.2f} Mbps."
        )
