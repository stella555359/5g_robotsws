# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Civen Chen
:contact: civen.chen@nokia-sbell.com
:maintainer: Civen Chen
:contact: civen.chen@nokia-sbell.com
"""
import logging
import re

from taf.config.testline.info.testline_info import TestlineInfo
from taf.sbts.oam.coam.admin.interface import AdminConnection
from taf.transport.ssh.connection import SSHConnection
from taf.config.testline.gnb.du import DU, NetworkAddress
from taf.ul.rfsw.ssh.facade import RfswSsh
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from multiprocessing import cpu_count
from multiprocessing.dummy import Pool


__all__ = ["check_ecpri_ru_transmit_power_in_normal_range"]


RU_TRANSMIT_POWER_CHECK_LIST = ["AEHC", "AEQZ"]

SUPPORTING_RELEASE = ["22R4"]


class RUPowerCheckFailed(ExecutionFailed):
    def __init__(self, message):
        super(RUPowerCheckFailed, self).__init__(message=message, exit=True)


def transmit_log(message, level="WARN"):
    msg = "[RTPC] {}".format(message)
    if level == "WARN":
        logging.warning(msg)
    elif level == "ERROR":
        logging.error(msg)
    elif level == "EXCEPT":
        logging.exception(msg)
    else:
        logging.info(msg)


def check_ecpri_ru_transmit_power_in_normal_range(pass_ru_power_check=False):
    if pass_ru_power_check:
        transmit_log("Directly pass the check as pass_ru_power_check={}".format(pass_ru_power_check))
        return
    try:
        tl = BuiltIn().get_variable_value("${tl}")
        invalid_results = []
        verified_rus = []
        if not tl:
            logging.warning(
                "Current version only support environment using tl for configuration storage."
            )
            return
        if not TestlineInfo.get_number_of_du(tl):
            logging.warning("Haven't support environments don't have DU.")
            return
        for du in TestlineInfo.get_du_list(tl):
            # Check if testline is supported type, and return correct host/username/password if supported.
            # This first draft only support 5G gnb environment with DU.
            du_login_info = get_host_info_from_du(du)
            if du_login_info:
                du_host, du_username, du_password = du_login_info
            else:
                continue
            cells, hw_info, sw_version, release = get_ru_info_via_admin(du_host)
            if release not in SUPPORTING_RELEASE:
                transmit_log("Haven't support this release SW version {}".format(sw_version))
                return
            if not cells:
                transmit_log(
                    "Current version only support environment with nr cell."
                )
                continue
            cell_config_rmod = []
            # Get enabled cells, ignore power check for locked cells.
            for cell in cells:
                if (
                    cell["status"]["administrativeState"].lower() != "unlocked"
                    or cell["status"]["operationalState"].lower() != "enabled"
                ):
                    transmit_log("Cell not on air, ignore this cell")
                    continue
                cell_config_rmod.append(
                    cell["carrierList"][0]["antennaLineId"]["configuration"]
                    .split("RMOD-")[-1]
                    .split("/")[0]
                )
            if not cell_config_rmod:
                transmit_log("Ignore this DU due to none enable cell detected.")
                continue
            ru_list = hw_info["radioModules"]["rmod"]
            if not ru_list:
                transmit_log("No RU detected, Ignore testline.")
                continue
            ru_dict = {}
            for ru in ru_list:
                if ru["id"]["configuration"].split("RMOD-")[1] not in cell_config_rmod:
                    continue
                if ru["status"]["operationalState"].lower() != "enabled":
                    transmit_log("RU not enabled, ignore this RU.{}".format(ru))
                    continue
                try:
                    ru_dict[ru["serialNumber"]] = ru["id"]["configuration"].split("RMOD-")[1]
                except IndexError as err:
                    transmit_log("By Pass RU due to: {}".format(err))
                    continue
            if not ru_dict:
                transmit_log("Bypass due to empty RU dict generated.")
                continue
            ru_raws, hostname = get_ru_connection_info_via_ssh(du_host, du_username, du_password)
            du_config = {'host': du_host, 'username': du_username, "password": du_password}
            container_id = get_container_id_from_hostname(hostname)
            if not container_id:
                transmit_log("Not adapted FHNET container, bypass for now.")
                continue
            lxc_config = generate_lxc_config(du_config=du_config, container_id=container_id)
            ru_configs = []
            for ru_raw in ru_raws:
                ru_ip = ru_raw.split(";")[0]
                # rmod_index = ru_dict[ru_raw.split(";")[1]]
                ru_type = ru_raw.split(";")[2]
                new_config = {"type": ru_type, "config": {"host": ru_ip}}
                if ru_type not in RU_TRANSMIT_POWER_CHECK_LIST:
                    logging.info("Not supported RU {}, ignore.".format(new_config))
                    continue
                if new_config not in verified_rus:
                    verified_rus.append(new_config)
                    ru_configs.append(new_config)
                    logging.info("Adding {} into check queue".format(new_config))
            rfs = RfswSsh()
            prepare_rus = []
            if len(ru_configs) == 0:
                transmit_log("None linked RU supported, pass this DU.")
                continue
            elif len(ru_configs) == 1:
                prepare_rus.append(rfs.prepare_ru(ru_name=ru_configs[0]["type"],
                                                  hops=[du_config, lxc_config],
                                                  ru_ssh_service=ru_configs[0]["config"],
                                                  release=release.lower()))
            else:
                prepare_rus.append(rfs.prepare_ru(ru_name=ru_configs[0]["type"],
                                                  hops=[du_config, lxc_config],
                                                  ru_ssh_service=ru_configs[0]["config"],
                                                  release=release.lower()))
                for r in ru_configs[1:]:
                    prepare_rus.append(rfs.prepare_next_ru(ru_name=r["type"],
                                                           ru_ssh_service=r["config"]))
            validate_tx_power_on_prepared_ru(rfs, prepare_rus, invalid_results)
            rfs.release()
        if invalid_results:
            for i in invalid_results:
                transmit_log(
                    "{} meeting RU transmit power issue, power value: {}".format(i["RU"], i["power"]),
                    level="ERROR"
                )
            raise RUPowerCheckFailed("Found invalid transmit power.")
        else:
            transmit_log("Power check pass", level="INFO")
            return True
    except RUPowerCheckFailed as err:
        raise err
    except Exception as err:
        logging.exception(err)
        logging.error("Meeting unexpected error. Pass the keyword, "
                      "kindly contact keyword owner with error info for better adaption.")


def get_host_info_from_du(du):
    if type(du) != DU:
        transmit_log("Only Support Classical DU configuration yet.")
        return
    if du.f1_m_ip_addr:
        if type(du.f1_m_ip_addr) == str:
            du_host = du.f1_m_ip_addr
        elif type(du.f1_m_ip_addr) == NetworkAddress:
            du_host = du.f1_m_ip_addr.v4 if du.f1_m_ip_addr.v4 else du.f1_m_ip_addr.v6
        else:
            transmit_log("Invalidate f1_m_ip_addr type configured, not to check on this env.")
            return
    elif du.airscale.common_units:
        du_host = du.airscale.common_units[0].lmp_connection.addr
    else:
        transmit_log("Testline configuration missing cu, not supported.")
        return
    du_username = du.airscale.common_units[0].lmp_connection.username
    du_password = du.airscale.common_units[0].lmp_connection.password
    return du_host, du_username, du_password


def validate_tx_power_on_prepared_ru(rfs, prepare_rus, invalid_results, process_num=None):
    logging.info("Created pool to check RU transmit power.")
    pn = process_num or cpu_count()
    logging.info("Create {} thread pool".format(pn))
    pool = Pool(pn)
    async_results = []
    for prepare_ru in prepare_rus:
        logging.info("Checking prepare RU {}".format(prepare_ru))
        async_results.append(pool.apply_async(retrieve_tx_power_from_prepared_ru,
                                              kwds={"rfs": rfs, "prepare_ru": prepare_ru}))
    pool.close()
    pool.join()
    for ar in async_results:
        result = ar.get()
        if result:
            invalid_results.append(result)
    logging.info("Check finished in this DU.")


def retrieve_tx_power_from_prepared_ru(rfs, prepare_ru):
    powers = rfs.retrieve_tx_power(try_sudo=True, ru=prepare_ru)
    for power in powers:
        if not re.findall(r"-([1-9]\d*\.\d*|0\.\d*[1-9]\d*)", str(power)):
            return {"RU": prepare_ru.name,
                    "power": powers}


def get_ru_info_via_admin(du_host):
    admin_connection = AdminConnection(bts_host=du_host, log_level=logging.ERROR)
    cells = admin_connection.get_cells_info(cell_type="nr", timeout=20)
    hw_info = admin_connection.get_detected_hw_info()
    sw_version = admin_connection.get_sw_version()
    release = get_release_from_sw_version(sw_version)
    disconnect_and_ignore_errors(admin_connection)
    return cells, hw_info, sw_version, release


def get_ru_connection_info_via_ssh(du_host, du_username, du_password):
    ssc = SSHConnection()
    ssc.configure(
        hostname=du_host,
        username=du_username,
        password=du_password,
    )
    ssc.connect()
    ru_raws = ssc.execute("cat /ffs/run/config/FRIps.txt |cut -d ';' -f 3-5", timeout=5).split()
    hostname = ssc.execute("hostname")
    disconnect_and_ignore_errors(ssc)
    return ru_raws, hostname


def disconnect_and_ignore_errors(cnt):
    try:
        cnt.disconnect()
    except Exception:
        pass


def get_release_from_sw_version(sw_version):
    releases = [
        "22R2",
        "22R3",
        "22R4"
    ]
    for release in releases:
        if release in sw_version:
            return release
    else:
        return "Undefined"


def get_container_id_from_hostname(hostname):
    if "fct-0a" in hostname or "asc-0a" in hostname:
        return "0x1018"
    elif "fct-4a" in hostname:
        return "0x2018"
    else:
        return None


def generate_lxc_config(du_config, container_id,
                        host="192.168.255.254", username="toor4nsn", password="oZPS0POrRieRtu",
                        port=22, sudo_enabled=False):
    return {
        'host_hop': du_config,
        'container_id': container_id,
        'host': host,
        'username': username,
        'password': password,
        'port': port,
        'sudo_enabled': sudo_enabled
    }
