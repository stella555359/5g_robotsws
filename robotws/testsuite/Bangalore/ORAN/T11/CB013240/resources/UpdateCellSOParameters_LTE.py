import xml.etree.ElementTree as ET
import datetime


def update_lbps_start_time(input_file, output_file, new_day, new_hour, new_minute, new_duration):
    # Register namespaces
    namespaces = {'ns': 'raml21.xsd'}

    # Parse the XML file
    tree = ET.parse(input_file)
    root = tree.getroot()

    # Update lbpsStartTimeHour and lbpsStartTimeMinute in lbpsPeriodList
    updated = False
    for item in root.findall(".//ns:list[@name='lbpsPeriodList']/ns:item", namespaces):
        for element in item.findall("ns:p", namespaces):
            if element.attrib.get("name") == "lbpsStartTimeHour":
                element.text = str(new_hour)
                updated = True
            elif element.attrib.get("name") == "lbpsStartTimeMinute":
                element.text = str(new_minute)
                updated = True
            elif element.attrib.get("name") == "lbpsDayOfWeek":
                element.text = str(new_day)
                updated = True
            elif element.attrib.get("name") == "lbpsDuration":
                element.text = str(new_duration)
                updated = True

    # Update lbpsCellStartTimeHour and lbpsCellStartTimeMinute in lbpsCelPeriodList
    for item in root.findall(".//ns:list[@name='lbpsCelPeriodList']/ns:item", namespaces):
        for element in item.findall("ns:p", namespaces):
            if element.attrib.get("name") == "lbpsCellStartTimeHour":
                element.text = str(new_hour)
                updated = True
            elif element.attrib.get("name") == "lbpsCellStartTimeMinute":
                element.text = str(new_minute)
                updated = True
            elif element.attrib.get("name") == "lbpsCellDayOfWeek":
                element.text = str(new_day)
                updated = True
            elif element.attrib.get("name") == "lbpsCellDuration":
                element.text = str(new_duration)
                updated = True

    # Ensure elements were updated
    if not updated:
        print("No matching elements found to update.")

    # Write the updated XML to a new file
    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    print(f"Updated XML saved to {output_file}")


def remove_ns_prefix(input_file, output_file):
    # Parse the XML file
    tree = ET.parse(input_file)
    root = tree.getroot()

    # Remove the `ns0:` prefix from all tags
    for elem in root.iter():
        if elem.tag.startswith("{"):
            # Extract the namespace and local tag name
            _, local_tag = elem.tag.split("}", 1)
            elem.tag = local_tag
        else:
            elem.tag = elem.tag.replace("ns0:", "")

    # Remove `ns0:` from attributes as well, if present
    for elem in root.iter():
        elem.attrib = {k.replace("ns0:", ""): v for k, v in elem.attrib.items()}

    # Write the updated XML to a new file
    tree.write(output_file, encoding="utf-8", xml_declaration=True)
    print(f"Updated XML saved to {output_file}")


# from datetime import datetime, timedelta
def __dayCalculationSO__(year, month, day):
    # calculate day
    objectdate_object = datetime.date(year, month, day)
    nameday_name = objectdate_object.strftime("%A")
    return nameday_name


def calculateDateTime():
    # calculate datetime

    CurrTime = datetime.datetime.now()

    print(CurrTime)
    now_plus_5 = CurrTime + datetime.timedelta(minutes=10)
    print(now_plus_5.year, now_plus_5.month, now_plus_5.day, now_plus_5.hour, now_plus_5.minute)
    currDay = __dayCalculationSO__(now_plus_5.year, now_plus_5.month, now_plus_5.day)
    print(currDay, now_plus_5.hour, now_plus_5.minute)
    return currDay[:3], now_plus_5.hour, now_plus_5.minute


returnValue = calculateDateTime()
print(returnValue[0], returnValue[1], returnValue[2])

# Specify file paths and values
try:
    input_file = '/home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/CB010992_Script/CB010992SCF.xml'
    output_file = '/home/ute/robotws/testsuite/Bangalore/ORAN/SG02/CRT2Suite/CB010992_Script/modified_CB010992SCF.xml'
    new_duration = 15
    new_day = 'Mon'
    new_hour = 20
    new_minute = 20

    # Call the function to update the XML file
    update_lbps_start_time(input_file, output_file, new_day, new_hour, new_minute, new_duration)
except Exception as e:
    print(f"An error occurred: {e}")
