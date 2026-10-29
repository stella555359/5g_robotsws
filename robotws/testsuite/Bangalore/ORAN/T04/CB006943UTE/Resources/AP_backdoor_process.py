################################################################################
# File           : AP_backdoor_process.py
# Version        : 1.0
# Modified       : Sudarshan Kanapuram 03.03.2026
# Description    :
# Requires files : -
# Requires options: -
# Copyright (C) Nokia 2026. All Rights Reserved.
# Author: Sudarshan Kanapuram
# ================================================================================
# Functions           Descriptions
# -------------------------------------------------------------------------------
#
#
#################################################################################

import logging as logger
from taf.ul.oran_mplane.interface import OranMplane
from mock import patch


class AP_backdoor_process:
    def __init__(self):
        self.check = ""
        self.ADMIN_MSG = """<hardware xmlns="urn:ietf:params:xml:ns:yang:ietf-hardware"><component><class\
        xmlns:o-ran-hw="urn:o-ran:hardware:1.0">o-ran-hw:O-RAN-RADIO</class><state><admin-state/></state>\
        </component></hardware>"""

    def Check_admin_state(
            self, host_ip, user="oru01", pwd="oamterm", state="unlocked"):

        patch("logging.debug", print).start()
        ROUTER = {"session1": {"host": host_ip,
                               "port": 830, "username": user, "password": pwd, "protocol": "ssh"}}

        GET_ADMIN = {"request": self.ADMIN_MSG,
                     "expected_response": "<admin-state>"+state+"</admin-state>"}

        oran_object = OranMplane(router=ROUTER, logger=logger)
        oran_object.connect(session="session1")
        oran_object.get(session="session1", msg_format="xml",
                        msg=GET_ADMIN, validation_mode="string")
        oran_object.close_all_sessions()

    def Create_fault_trigger_xml_msg(self, f_name, f_id, f_source, f_severity, f_mode, f_objects=1):

        FAULT_TGR_MSG = f"""<active-alarm-test-list xmlns="urn:o-ran-test:fm:1.0"><active-alarms>
        <fault-name>{f_name}</fault-name>
        <fault-id>{f_id}</fault-id>
        <fault-source>{f_source}</fault-source>
        <affected-objects>
        <name>{f_objects}</name>
        </affected-objects>
        <fault-severity>{f_severity}</fault-severity>
        <fault-mode>{f_mode}</fault-mode>
        <is-cleared>false</is-cleared>
        </active-alarms>
        </active-alarm-test-list>"""
        return FAULT_TGR_MSG

    def Create_fault_clear_xml_msg(self, f_name, f_id):

        FAULT_CLR_MSG = f"""<active-alarm-test-list xmlns="urn:o-ran-test:fm:1.0">
        <active-alarms>
        <fault-name>{f_name}</fault-name>
        <fault-id>{f_id}</fault-id>
        <is-cleared>true</is-cleared>
        </active-alarms>
        </active-alarm-test-list>"""
        return FAULT_CLR_MSG

    def Send_rpc_for_test_fault(
            self, host_ip, user="oru01", pwd="oamterm", f_name='test', f_id=1, f_source='module',
            f_severity='MAJOR', f_mode='PERSISTENT', f_objects=1, f_clear='No'):

        patch("logging.debug", print).start()
        ROUTER = {"session1": {"host": host_ip,
                               "port": 830, "username": user, "password": pwd, "protocol": "ssh"}}
        if f_clear == 'No':

            SEND_RPC_MSG = {"request": self.Create_fault_trigger_xml_msg(f_name, f_id, f_source, f_severity,
                            f_mode, f_objects), "expected_response": ""}
        else:
            SEND_RPC_MSG = {"request": self.Create_fault_clear_xml_msg(f_name, f_id),
                            "expected_response": ""}
        print("RPC msg: ", SEND_RPC_MSG)
        oran_object = OranMplane(router=ROUTER, logger=logger)
        oran_object.connect(session="session1")
        oran_object.send_rpc(session="session1", msg=SEND_RPC_MSG,
                             msg_format="xml", validation_mode="string")
        oran_object.close_all_sessions()
