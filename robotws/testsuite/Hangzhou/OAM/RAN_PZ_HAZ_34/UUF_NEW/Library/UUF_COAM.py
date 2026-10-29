import dateutil.parser
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin


coam = admin()
builtin = BuiltIn()


def get_cell_status_list(connection):
    bts_info = coam.get_bts_info(connection=connection, timeout=60)

    cell_info = (
        bts_info.get('requestMessage', {}).get('cells')
        or bts_info.get('cells', {})
    )

    cell_list = [cell for cells in cell_info.values() for cell in cells]

    return [
        {'id': cell.get('id', ''), 'status': cell.get('status', ''),
            'energySavingState': cell.get('energySavingState', '')}
        for cell in cell_list
    ]


def get_hardware_status(connection, hardware_type="all"):
    hw_info = coam.get_detected_hw_info(connection=connection)
    smod_list = hw_info.get("systemModules", [])
    bbmod_list = hw_info.get("basebandModules", [])
    rmod_list = hw_info.get("radioModules", {}).get("rmod", [])
    cable_list = hw_info.get("cables", [])
    smod_status_list = [{"status": smod.get("status", {})} for smod in smod_list]
    bbmod_status_list = [{"status": bbmod.get("status", {})} for bbmod in bbmod_list]
    rmod_status_list = [{"status": rmod.get("status", {})} for rmod in rmod_list]
    cable_status_list = [{"status": cable.get("status", {})} for cable in cable_list]
    hw_status = {}
    if hardware_type == "systemModules":
        hw_status["systemModules"] = smod_status_list
    elif hardware_type == "basebandModules":
        hw_status["basebandModules"] = bbmod_status_list
    elif hardware_type == "radioModules":
        hw_status["radioModules"] = {"rmod": rmod_status_list}
    elif hardware_type == "cables":
        hw_status["cables"] = cable_status_list
    else:
        hw_status = {"systemModules": smod_status_list, "basebandModules": bbmod_status_list,
                     "radioModules": {"rmod": rmod_status_list}, "cables": cable_status_list}
    return hw_status


def uuf_get_format_alarm_list(testline, alarm_type="active"):
    if alarm_type == "active":
        alarm_list = coam.get_active_alarms(connection=testline, timeout=60)
    elif alarm_type == "history":
        alarm_list = coam.get_historic_alarms(
            connection=testline, timeout=300, load_history=True)
    else:
        alarm_list = []

    format_alarm_list = []

    try:
        ALL_CONFIG_SCF = builtin.get_variable_value(
            "${ALL_CONFIG_SCF}", default={})
    except Exception:
        ALL_CONFIG_SCF = {}
    print(ALL_CONFIG_SCF)

    for alarm in alarm_list:
        fault_id = alarm.get("faultId", "")
        if fault_id == "":
            continue

        serial_no = alarm.get("serialNo", "")
        severity = alarm.get("severity", "")
        alarm_id = alarm.get("alarmId", "")
        alarm_name = alarm.get("alarmName", "")
        fault_name = alarm.get("faultName", "")
        config_obj = alarm.get("configObjectName", "")
        bts_obs_time = alarm.get("btsObservationTime", "")
        cleared_time = alarm.get("clearedTime", "")
        suppl_info = alarm.get("supplAlarmInfo", "")

        try:
            config_obj_split = config_obj.split(" ")
            config_obj = config_obj_split[-1] if config_obj_split else "NA"
        except Exception:
            config_obj = "NA"

        productName_1 = (
            ALL_CONFIG_SCF.get(testline, {})
            .get("rmod_serial_mapping", {})
            .get(serial_no, {})
            .get("productName", "N/A")
        )

        productName_2 = (
            ALL_CONFIG_SCF.get(testline, {})
            .get("rmod_dn_mapping", {})
            .get(config_obj, "N/A")
        )

        if productName_1 != "N/A":
            product_name = productName_1
        elif productName_2 != "N/A":
            product_name = productName_2
        else:
            product_name = "N/A"

        # --- appeardTime ---
        try:
            format_appeard_time = datetime.strptime(
                bts_obs_time, "%Y%m%d%H%M%S.%f%z"
            ).strftime("%Y-%m-%d %H:%M:%S.%f%z")
        except Exception:
            format_appeard_time = bts_obs_time

        # --- appeardTimeStamp ---
        try:
            appeard_timestamp = datetime.strptime(
                bts_obs_time, "%Y%m%d%H%M%S.%f%z").timestamp()
        except Exception:
            appeard_timestamp = bts_obs_time

        # --- clearedTime ---
        try:
            format_clear_time = datetime.strptime(
                cleared_time, "%Y%m%d%H%M%S.%f%z"
            ).strftime("%Y-%m-%d %H:%M:%S.%f%z")
        except Exception:
            format_clear_time = cleared_time

        # --- clearedTimeStamp ---
        try:
            cleared_timestamp = datetime.strptime(
                cleared_time, "%Y%m%d%H%M%S.%f%z").timestamp()
        except Exception:
            cleared_timestamp = cleared_time

        # --- assemble formatted alarm ---
        format_alarm_detail = {
            "alarmId": alarm_id,
            "alarmName": alarm_name,
            "faultId": fault_id,
            "faultName": fault_name,
            "severity": severity,
            "appeardTime": format_appeard_time,
            "appeardTimeStamp": appeard_timestamp,
            "clearedTime": format_clear_time,
            "clearedTimeStamp": cleared_timestamp,
            "configObjectName": config_obj,
            "serialNo": serial_no,
            "productName": product_name,
            "supplAlarmInfo": suppl_info,
            "testline": testline,
        }

        format_alarm_list.append(format_alarm_detail)

    return format_alarm_list
