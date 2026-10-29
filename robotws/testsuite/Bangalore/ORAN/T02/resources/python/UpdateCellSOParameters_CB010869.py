import xml.etree.ElementTree as ET
import datetime


def update_lbps_start_time(
    input_file, output_file,
    new_day, new_hour, new_minute, new_duration
):
    """Update the LBPS start time values in the XML file."""
    # Register namespaces
    namespaces = {'ns': 'raml21.xsd'}

    # Element names
    period_list = 'lbpsPeriodList'
    cell_period_list = 'lbpsCellPeriodList'

    starthour = "lbpsStartTimeHour"
    startminute = "lbpsStartTimeMinute"
    day = "lbpsDayOfWeek"
    duration = "lbpsDuration"

    cell_starthour = "lbpsCellStartTimeHour"
    cell_startminute = "lbpsCellStartTimeMinute"
    cell_day = "lbpsCellDayOfWeek"
    cell_duration = "lbpsCellDuration"

    cso_starthour = "lbpsCsoThresStartTimeHour"
    cso_startminute = "lbpsCsoThresStartTimeMinute"
    cso_day = "lbpsCsoThresDayOfWeek"
    cso_duration = "lbpsCsoThresDuration"

    # Parse the XML file
    tree = ET.parse(input_file)
    root = tree.getroot()

    updated = False

    # Update lbpsPeriodList
    for item in root.findall(
        ".//ns:list[@name='{}']/ns:item".format(period_list), namespaces
    ):
        for element in item.findall("ns:p", namespaces):
            name = element.attrib.get("name")
            if name == starthour:
                element.text = str(new_hour)
                updated = True
            elif name == startminute:
                element.text = str(new_minute)
                updated = True
            elif name == day:
                element.text = str(new_day)
                updated = True
            elif name == duration:
                element.text = str(new_duration)
                updated = True

    # Update lbpsCellPeriodList
    for item in root.findall(
        ".//ns:list[@name='{}']/ns:item".format(cell_period_list), namespaces
    ):
        for element in item.findall("ns:p", namespaces):
            name = element.attrib.get("name")
            if name == cell_starthour:
                element.text = str(new_hour)
                updated = True
            elif name == cell_startminute:
                element.text = str(new_minute)
                updated = True
            elif name == cell_day:
                element.text = str(new_day)
                updated = True
            elif name == cell_duration:
                element.text = str(new_duration)
                updated = True

    # Update lbpsCsoLoadThresList
    for item in root.findall(
        ".//ns:list[@name='lbpsCsoLoadThresList']/ns:item", namespaces
    ):
        for element in item.findall("ns:p", namespaces):
            name = element.attrib.get("name")
            if name == cso_starthour:
                element.text = str(new_hour)
                updated = True
            elif name == cso_startminute:
                element.text = str(new_minute)
                updated = True
            elif name == cso_day:
                element.text = str(new_day)
                updated = True
            elif name == cso_duration:
                element.text = str(new_duration)
                updated = True

    if not updated:
        print("No matching elements found to update.")

    # Write the updated XML to a new file
    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    print(f"Updated XML saved to {output_file}")


def remove_ns_prefix(input_file, output_file):
    """Remove namespace prefixes from XML tags and attributes."""
    tree = ET.parse(input_file)
    root = tree.getroot()

    for elem in root.iter():
        if elem.tag.startswith("{"):
            _, local_tag = elem.tag.split("}", 1)
            elem.tag = local_tag
        else:
            elem.tag = elem.tag.replace("ns0:", "")

    for elem in root.iter():
        elem.attrib = {
            k.replace("ns0:", ""): v for k, v in elem.attrib.items()
        }

    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    print(f"Updated XML saved to {output_file}")


def calculate_day_name(year, month, day):
    """Return day of the week (e.g., 'Monday') for a given date."""
    date_obj = datetime.date(year, month, day)
    return date_obj.strftime("%A")


def calculate_datetime():
    """Calculate the current day (3-letter), hour, and minute + 5 min."""
    curr_time = datetime.datetime.now()
    print("Current Time:", curr_time)

    time_plus_5 = curr_time + datetime.timedelta(minutes=5)
    print("Time + 5 minutes:", time_plus_5)

    year, month, day = time_plus_5.year, time_plus_5.month, time_plus_5.day
    hour, minute = time_plus_5.hour, time_plus_5.minute

    day_name = calculate_day_name(year, month, day)
    short_day = day_name[:3]  # e.g., "Mon" for Monday

    print(short_day, hour, minute)
    return short_day, hour, minute


# Example usage
return_value = calculate_datetime()
print("Return Value:", return_value)
