import xml.etree.ElementTree as ET


def check_dl_mitigation_started(pdml_file, slots_to_check):
    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()
        found_on_slots = []

        for slot_to_check in slots_to_check:
            found = False

            for proto in root.findall(".//proto[@name='dldata_pdschsendreql1sw']"):
                slot_field = proto.find(".//field[@name='3gpp.slot']")
                rnti_field = proto.find(".//field[@name='3gpp.rnti']")

                if slot_field is not None and rnti_field is not None:
                    slot_value = int(slot_field.get("show").split(":")[-1].strip())
                    rnti_value = int(rnti_field.get("show").split(":")[-1].strip())

                    if slot_value == int(slot_to_check) and rnti_value != 65535:
                        found = True
                        found_on_slots.append(slot_to_check)
                        break

            if found:
                continue

        if found_on_slots:
            error_message = f"'dldata_pdschsendreql1sw' found on slot(s) {', '.join(found_on_slots)}"
            raise Exception(error_message)
        else:
            print("msg 'dldata_pdschsendreql1sw' not found on any slo.")
            return 'None'
    except Exception as e:
        return str(e)


def check_dl_mitigation_stopped(pdml_file, slots_to_check):
    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()
        not_found_on_slots = []

        for slot_to_check in slots_to_check:
            found = False

            for proto in root.findall(".//proto[@name='dldata_pdschsendreql1sw']"):
                slot_field = proto.find(".//field[@name='3gpp.slot']")

                if slot_field is not None:
                    slot_value = int(slot_field.get("show").split(":")[-1].strip())

                    if slot_value == int(slot_to_check):
                        found = True
                        break

            if not found:
                not_found_on_slots.append(slot_to_check)

        if not_found_on_slots:
            error_message = f"'dldata_pdschsendreql1sw' not found on slot(s) {', '.join(not_found_on_slots)}"
            raise Exception(error_message)
        else:
            return 'None'  # 'dldata_pdschsendreql1sw' found on all specified slots
    except Exception as e:
        return str(e)
