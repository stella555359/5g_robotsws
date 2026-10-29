import re
import xml.etree.ElementTree as ET
from taf.selenium.sbts.interface import sbts
from robot.api import logger
import time
from robot.errors import ExecutionFailed
from taf.gnb.oam.coam.admin import admin


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
            print("msg 'dldata_pdschsendreql1sw'not found on any slo.")
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


def check_rs2_detection():
    alarm = sbts()
    count = 1
    while count < 20:
        fault_info = alarm.get_active_alarm_detailed_info(fault_id=7527)
        Additional_information = fault_info["Additional information"]["Supplementary alarm information"]
        if "RIM RS1 and RS2 is detected" in Additional_information:
            logger.console(Additional_information)
            break
        count += 1
        time.sleep(60)
    else:
        logger.console("RIM RS1 and RS2 is not detected")


def check_if_alarm_is_active(fault_id, timeout, interval_time=60):
    api = admin()
    connection = api.connect_to(bts_host='192.168.255.129')

    start_time = time.time()
    while time.time() - start_time < int(timeout):
        alarms = connection.get_active_alarms()
        for alarm in alarms:
            if int(alarm['faultId']) == int(fault_id):
                logger.console(f"Fault {fault_id} is detected")
                connection.teardown_admin()
                return
        time.sleep(interval_time)
    else:
        connection.teardown_admin()
        raise ExecutionFailed(
            message=f'Fault {fault_id} is not detected!',
            continue_on_failure=True,
        )


def check_if_rs1_and_rs2_are_detected(timeout, interval_time=60):
    api = admin()
    connection = api.connect_to(bts_host='192.168.255.129')

    start_time = time.time()
    while time.time() - start_time < int(timeout):
        alarms = connection.get_active_alarms()
        for alarm in alarms:
            alarm_info = alarm.get('supplAlarmInfo')
            if alarm_info and 'Both RIM RS1 and RS2 are detected' in alarm_info:
                logger.console(alarm_info)
                connection.teardown_admin()
                return
        time.sleep(interval_time)
    else:
        connection.teardown_admin()
        raise ExecutionFailed(
                message='RIM RS1 and RS2 are NOT detected!',
                continue_on_failure=True,
            )
