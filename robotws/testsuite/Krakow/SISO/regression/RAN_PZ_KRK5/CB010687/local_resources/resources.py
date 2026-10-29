import os
import time
import psutil
import logging
import shlex
import subprocess
import taf.rfrl.utilities.logger.custom_logger as logger
import taf.rfrl.bts.commissioning as comm
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.test_config import get_repository_path
from taf.hw.pdu.interface import pdu


def upload_swconfig_to_bts():
    gnb_du = GnbDuOperations()
    sw_config_path = '{}/testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010687/local_resources/configs/swconfig.txt'\
        .format(get_repository_path())
    gnb_du.upload_swconfig(sw_config_path=sw_config_path)


def perform_bts_recommissioning(prefix_tag=None):
    prefix_tag = prefix_tag if prefix_tag != 'null' else None
    comm.perform_full_commissioning_on_classical_gnb(prefix_tag=prefix_tag)
    time.sleep(300)


def power_off(host, port, alias, model):
    pdu_obj = pdu()
    if model == "HPE":
        pdu_obj.setup_pdu(host=host, alias=alias, model=model, snmp_user=SNMP_USER)
    elif model == "FPFH":
        pdu_obj.setup_pdu(host=host, alias=alias, model=model)
    logger.log_info_to_console(f"Power off {port} for {alias}", log_hierarchy=2)
    pdu_obj.power_off(port=port, pdu_device=alias)
    time.sleep(5)
    port_status = pdu_obj.get_port_status(port=port, pdu_device=alias)
    logger.log_info_to_console(f"Port status {port_status}", log_hierarchy=2)


def power_on(host, port, alias, model):
    pdu_obj = pdu()
    if model == "HPE":
        pdu_obj.setup_pdu(host=host, alias=alias, model=model, snmp_user=SNMP_USER)
    elif model == "FPFH":
        pdu_obj.setup_pdu(host=host, alias=alias, model=model)
    logger.log_info_to_console(f"Power on {port} for {alias}", log_hierarchy=2)
    pdu_obj.power_on(port=port, pdu_device=alias)
    time.sleep(5)
    port_status = pdu_obj.get_port_status(port=port, pdu_device=alias)
    logger.log_info_to_console(f"Port status {port_status}", log_hierarchy=2)
