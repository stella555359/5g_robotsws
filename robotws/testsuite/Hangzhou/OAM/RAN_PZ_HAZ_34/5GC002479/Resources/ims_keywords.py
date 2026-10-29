import random
import time
import json
import os
from datetime import datetime, timezone, timedelta
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger as robot_logger
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.utilities import tl_config
from taf.pdu import pdu
from taf.pdu.device_status import DeviceStatus
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin import admin
import paramiko
import pytz


builtin = BuiltIn()

ROBOT_LIBRARY_SCOPE = 'TEST SUITE'


def _perform_cmd_over_ssh(cmd_line, hostname, username, password=None, ssh_key_file_path=None, port=22,
                          timeout=180):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(hostname=hostname, port=port, username=username, key_filename=ssh_key_file_path,
                       password=password, look_for_keys=False,
                       banner_timeout=180,
                       timeout=180)
    # cmd_line = cmd_line.encode().decode("unicode-escape").replace('\\', '/')
    stdin, stdout, stderr = ssh_client.exec_command(cmd_line, timeout=timeout)
    err = stderr.read().decode("utf-8").replace('\r', "").replace('\n', "")
    result = stdout.read().decode("utf-8").replace('\r', "").replace('\n', "")
    ssh_client.close()
    return err, result


def check_instance_connection(robot_instance_name, bts_id=0, du_id=0, conn_alias=None):
    py_instance = builtin.get_library_instance(robot_instance_name)
    return _check_instance_connection(py_instance, bts_id=bts_id, du_id=du_id, conn_alias=conn_alias)


def _check_instance_connection(instance_name, bts_id=0, du_id=0, conn_alias=None):
    instance = builtin.get_library_instance(instance_name)
    if not conn_alias:
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
    # try:
    #     conn_instance = instance.admin.store.get(conn_alias)
    # except AliasLookupError:
    #     builtin.run_keyword("log", "[{}] Already disconnected".format(conn_alias), "console=no")
    builtin.run_keyword("log", "[{}] force reconnected".format(conn_alias), "console=no")
    instance.connect(bts_id=bts_id, du_id=du_id, force=True)
    return conn_alias


def validation_scf_online(robot_instance_name, scf_file, bts_id=0, du_id=0, conn_alias=None):
    try:
        api = builtin.get_library_instance(robot_instance_name).admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        return api.validate_scf_online(scf_file, connection=conn_alias)
    except Exception as e:
        builtin.run_keyword("log", f"{robot_instance_name} validate scf online Error: [{e}]", "console=no")


def instance_disconnect(robot_instance_name, bts_id=0, du_id=0, conn_alias=None):
    try:
        api = builtin.get_library_instance(robot_instance_name).admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        api.teardown(conn_alias)
    except Exception as e:
        builtin.run_keyword("log", f"{robot_instance_name} Teardown Error: [{e}]", "console=no")


def instance_reset_admin(robot_instance_name, bts_id=0, du_id=0, conn_alias=None):
    try:
        api = builtin.get_library_instance(robot_instance_name).admin
        conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
        api.reset_admin(conn_alias)
    except Exception as e:
        builtin.run_keyword("log", f"{robot_instance_name} Reset Admin Error: [{e}]", "console=no")


def get_gnb_cell_ids(bts_id=0, du_id=0):
    all_global_cell_ids = None
    try:
        gnb_cell = builtin.get_library_instance("gnbcell")
        _check_instance_connection(gnb_cell, bts_id=bts_id, du_id=du_id)
        all_global_cell_ids = gnb_cell._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id)
        gnb_cell.disconnect(bts_id=bts_id, du_id=du_id)
        del gnb_cell
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")
    finally:
        return all_global_cell_ids


def get_gnb_ru(bts_id=0, du_id=0):
    rus = []
    try:
        gnb_rus = builtin.get_library_instance("gnbru")
        conn_alias = _check_instance_connection(gnb_rus, bts_id=bts_id, du_id=du_id)
        mo = gnb_rus.admin.get_managed_objects(
            class_name="RMOD_R",
            timeout=10,
            connection=conn_alias
        )
        for ru in mo:
            rus.append(
                {
                    "distName": ru["distName"],
                    "productCode": ru["parameters"]["productCode"],
                    "serialNumber": ru["parameters"]["serialNumber"],
                    "productName": ru["parameters"]["productName"],
                    "radioMasterDN": ru["parameters"]["radioMasterDN"],
                    "ru_id": ru["distName"].split("-")[-1]
                }
            )
        gnb_rus.disconnect(bts_id=bts_id, du_id=du_id)
        del gnb_rus
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")
    finally:
        return rus


def reset_gnb_ru(ru_unit, bts_id=0, du_id=0):
    response = None
    try:
        gnb_rus = builtin.get_library_instance("gnbru")
        conn_alias = _check_instance_connection(gnb_rus, bts_id=bts_id, du_id=du_id)
        response = gnb_rus.admin.reset_unit(
            ru_unit["distName"], reset_type="Hard", timeout=600, force_radio_reset=True, connection=conn_alias
        )
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")
    finally:
        return response


def reset_enb_ru(bts_host, ru_unit, bts_id=0, du_id=0):
    api = admin()
    conn_alias = device_aliases.rest_bts_du.format("ENB", bts_id, du_id)
    try:
        api.connect_to(bts_host=bts_host, name=conn_alias)
        mo = api.get_frm(timeout=10, connection=conn_alias)
        for ru in mo:
            if ru["productCode"] == ru_unit["productCode"] and \
                    ru["serialNumber"] == ru_unit["serialNumber"]:
                dist_name = ru["id"]["internal"]
                rslt = api.reset_unit(
                    dist_name, reset_type="Hard", timeout=600, force_radio_reset=True, connection=conn_alias
                )
                builtin.run_keyword("log", "reset_enb_ru: [{}]".format(rslt), "console=no")
                break
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")


def collect_IMS_file_from_eNB(log_dir, bts_id=0, du_id=0):
    api = admin()
    conn_alias = device_aliases.rest_bts_du.format("ENB", bts_id, du_id)
    try:
        now = datetime.now().strftime("%Y%m%d-%H%M%S")
        sw_ver = api.get_sw_version(connection=conn_alias)
        snapshot_file_name = "Log_IMS_{}_{}_{}.{}".format(conn_alias, sw_ver, now, "bin")
        snapshot_path = os.path.join(log_dir, snapshot_file_name)
        api.collect_infomodel_log_from_current_session(snapshot_path, connection=conn_alias)
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")
    finally:
        api.teardown(conn_alias)
        del api


def get_gnb_rus_count(bts_id=0, du_id=0):
    gnb_rus_count = None
    try:
        gnb_rus = builtin.get_library_instance("gnbru")
        _check_instance_connection(gnb_rus, bts_id=bts_id, du_id=du_id)
        gnb_rus_count = gnb_rus.get_count_of_radios(bts_id=bts_id, du_id=du_id)
        gnb_rus.disconnect(bts_id=bts_id, du_id=du_id)
        del gnb_rus
    except Exception as e:
        print(e)
    finally:
        return gnb_rus_count


def get_active_alarms(allowed_alarms=[], bts_id=0, du_id=0):
    not_allowed_alarms = []
    gnb_bbu = builtin.get_library_instance("gnbbbu")
    conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
    alarms = gnb_bbu.admin.get_active_alarms(connection=conn_alias)
    if allowed_alarms:
        for alarm in alarms:
            if str(alarm['additionalFaultID']) not in allowed_alarms:
                not_allowed_alarms.append(alarm)
    return not_allowed_alarms


def save_alarms(alarms, directory_path):
    if alarms:
        os.makedirs(directory_path, exist_ok=True)
        json_file_path = os.path.join(
                directory_path,
                "alarms.json"
            )
        with open(json_file_path, 'w') as jsfile:
            json.dump(alarms, jsfile, indent=4, sort_keys=True, default=str)


def save_results(kpi_results, json_file_path=None):
    if json_file_path is None:
        json_file_path = os.path.join(
            builtin.get_variable_value("${res_path}"),
            "results_all" + "_".join(kpi_results) + ".json"
        )
    with open(json_file_path, 'w') as jsfile:
        json.dump(kpi_results, jsfile, indent=4, sort_keys=True, default=str)


def calculate_kpi_average(kpi_results):
    ts = [v['delta'].total_seconds() for v in kpi_results]
    avg = sum(ts) / len(ts)
    return round(avg, 2)


def power_reset_gnb(gnb_id=0, du_id=0):
    pdu_device = pdu()
    pdu_device.setup_pdu(
        model=tl_config.tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].pdu_port.pdu.vendor,
        host=tl_config.tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].pdu_port.pdu.addr
    )
    builtin.log(pdu_device)
    pdu_status = pdu_device.get_port_status(
        tl_config.tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].pdu_port.port_no,
    )
    builtin.log("gnb pdu device status defore reset= %s" % pdu_status)
    pdu_device.reset_ports(
        tl_config.tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].pdu_port.port_no,
    )
    kpi_params = {'kpi3': {'start_point_timestamp': datetime.now(pytz.utc)}}
    count = 0
    while True:
        pdu_status = pdu_device.get_port_status(
            tl_config.tl.gnbs[gnb_id].dus[du_id].airscale.common_units[0].pdu_port.port_no,
        )
        if pdu_status != DeviceStatus.PENDING or count > 24:
            break
        count += 1
        time.sleep(5)
    del pdu_device
    return kpi_params


def webEM_power_reset_gnb(gnb_id=0, du_id=0, reset_with_snapshot=False, timeout=1200):
    response = None
    try:
        gnb_bbu = builtin.get_library_instance("gnbbbu")
        conn_alias = _check_instance_connection(gnb_bbu, bts_id=gnb_id, du_id=du_id)
        response = gnb_bbu.admin.power_reset(
            reset_with_snapshot=reset_with_snapshot,
            wait_for_reconnection=None,
            timeout=timeout,
            detailed_output=False,
            connection=conn_alias
        )
    except Exception as e:
        builtin.run_keyword("log", "error occurred: [{}]".format(e), "console=no")
    finally:
        return response


def get_remot_utc_datetime(datetime_format="%Y-%m-%d %H:%M:%S",
                           hostname="192.168.255.129",
                           username="toor4nsn",
                           password="oZPS0POrRieRtu",
                           timeout=30):
    err, date_string = _perform_cmd_over_ssh(
        hostname=hostname,
        username=username,
        password=password,
        cmd_line=f"date -u '+{datetime_format}'",
        timeout=timeout)
    if err and "WARNING" not in err.upper():
        raise AssertionError(err)
    return datetime.strptime(date_string, datetime_format)


def get_start_point_timestamp(kpi_names):
    kpi_params = {}
    for kpi_name in kpi_names:
        kpi_params.update({kpi_name: {'start_point_timestamp': datetime.now(pytz.utc)}})
    return kpi_params


def get_gnb_bbus_distnames(bts_id=0, du_id=0):
    bbus_distnames = []
    try:
        gnb_bbu = builtin.get_library_instance("gnbbbu")
        conn_alias = _check_instance_connection(gnb_bbu, bts_id=bts_id, du_id=du_id)
        ffb_info = gnb_bbu.admin.get_fbb_info(timeout=300, connection=conn_alias)
        builtin.log("ffb_info= {}".format(ffb_info))
        for v in ffb_info:
            bbus_distnames.append(v["id"]["internal"])
    except Exception as e:
        pass
    return bbus_distnames


def get_random_choice(choises):
    if isinstance(choises, int):
        return random.choice(range(choises))
    return random.choice(choises)


def get_shared_ru(ru_units):
    for ru_unit in ru_units:
        if ru_unit["radioMasterDN"] and "SMOD_EXT" in ru_unit["radioMasterDN"]:
            return ru_unit
    return {}


def create_csv_file_results(path, sw_version):
    csv_file_path = os.path.join(path, "KPI_Results.csv")
    with open(csv_file_path, "w") as csv_file:
        csv_file.write("***System Management_KPIs_Top***\n")
        csv_file.write("***{}***\n".format(sw_version))


def finalized_csf_results(path):
    csv_file_path = os.path.join(path, "KPI_Results.csv")
    with open(csv_file_path, "a") as csv_file:
        csv_file.write("***System Management_KPIS_Bottom***\n")


def save_kpi_to_csv_results(iteration, path, kpi_results, alarms=[]):
    csv_file_path = os.path.join(path, "KPI_Results.csv")
    str_alarms = "alarms|"
    if alarms:
        for alarm in alarms:
            str_alarms += r"{}:{}|".format(alarm['additionalFaultID'], alarm['alarmDetail'])
    with open(csv_file_path, "a") as csv_file:
        for kpi, res in kpi_results.items():
            if res:
                device_info = ""
                re = res[-1]
                if re["device_info"]:
                    device_info = r"_{}_{}".format(
                        re["device_info"]["product_name"],
                        re["device_info"]["serial_number"]
                    )
                if re["detailed_results"] and "NR" in re["detailed_results"].keys() and \
                        re["detailed_results"]["NR"]["delta"]:
                    kpi_value = "{:.2f}".format(re["detailed_results"]["NR"]["delta"].total_seconds())
                else:
                    kpi_value = "None"

                csv_file.write(
                    "loop_{};{}{};{};{}\n".format(
                        iteration,
                        kpi,
                        device_info,
                        kpi_value,
                        str_alarms
                    )
                )


def offline_plan_Activtaion_operation(bts_id=0, du_id=0):
    gnb_bbu = builtin.get_library_instance("gnbbbu")
    conn_alias = device_aliases.rest_bts_du.format("GNB", bts_id, du_id)
    mo = gnb_bbu.admin.get_managed_objects(class_name="NRBTS_A", timeout=10, connection=conn_alias)
    dist_name = mo[0]['distName']
    params = gnb_bbu.admin.get_parameters(dist_name=dist_name, pattern=".*", timeout="300", connection=conn_alias)
    # get parameter dictionary
    value = params['srb1RlcAmProf']
    value['dlMaxRetxThreshold'] = 't6' if value['dlMaxRetxThreshold'] != 't6' else 't8'
    # apply an offline plan activation
    dist_name = "/".join(dist_name.split('/')[-2:]).replace("_A", "")
    gnb_bbu.admin.perform_parameter_recommissioning(
        dist_name=dist_name,
        parameter="srb1RlcAmProf",
        operation="update",
        value=[value],
        connection=conn_alias,
        timeout=600
    )


def save_swconfig_file(local_dir, filename="backup_swconfig.txt"):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(
        hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    )
    localfile = os.path.join(local_dir, filename)
    try:
        sftp = ssh_client.open_sftp()
        sftp.get("/ffs/run/swconfig.txt", localfile)
    except Exception as e:  # pylint: disable=broad-except
        robot_logger.debug(f" Error occured when transfering swconfig file: [{e}]")

    sftp.close()
    ssh_client.close()
