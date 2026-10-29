import xml.etree.ElementTree as ET


def verify_rimrs_periodicity(pdml_file, message_name, expected_time_period, time_tolerance):

    tree = ET.parse(pdml_file)
    root = tree.getroot()

    previous_time = None

    for packet in root.findall(".//packet"):
        message_proto = packet.find(f".//proto[@name='{message_name}']")

        if message_proto is not None:
            time_field = packet.find(".//field[@name='frame.time_relative']")
            if time_field is not None:
                current_time = float(time_field.get('show'))
                if previous_time is not None:
                    time_difference = current_time - previous_time

                    if abs(time_difference - expected_time_period) > time_tolerance:
                        raise ValueError(f"message '{message_name}' is not periodic for 19bits, check bip logs")

                    print(f"Message '{message_name}' is periodic every {expected_time_period} s")
                    print(f"The time difference between messages is: {time_difference} s")

                previous_time = current_time
            else:
                print(f"Field 'frame.time_relative' not found in message '{message_name}'")
