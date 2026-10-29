"""
:copyright: Nokia Networks
:authors:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
:maintainers:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
"""
import glob
import subprocess
import time
import logging
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import logger
from ta_egate_cmd_parser import ta_egate_cmd_parser
from ute_wtssim import ute_wtssim
from ta_emss import ta_emss
from ta5g_iphy import ta5g_iphy
from ta_messaging.message_flows import get_flow
from taf.transport.ssh import ssh
from taf.sbts.oam.coam.admin import admin
from taf.ul.alarms_watchdog import alarms_watchdog
from ta5g_testline_management import ta5g_testline_management

from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.ue_handling import ue_handling
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.traffic_handling import traffic_handling

admin = admin()
ta_testline_mgmt = ta5g_testline_management()
ta5g_iphy = ta5g_iphy()


def block_all_cells(cell_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='block')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if cell_type == "LTE":
        cells = emss.get_existing_objects_of_given_type("LNCEL")
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
    elif cell_type == "NR":
        cells = emss.get_existing_objects_of_given_type("NRCELL")
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"

    for cell in cells:
        cell_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}",
                                                     parameter_list=["blockingState"],
                                                     connection="block")[0]['parameters']['blockingState']
        if cell_state == "Unblocked":
            admin.block_cell(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}", connection="block")

    admin.teardown(connection='block')


def block_cell(cell_id, cell_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='block')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if cell_type == "LTE":
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
        cell = f"LNCEL-{cell_id}"
    elif cell_type == "NR":
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"
        cell = f"NRCELL-{cell_id}"
    cell_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}",
                                                 parameter_list=["blockingState"],
                                                 connection="block")[0]['parameters']['blockingState']
    if cell_state == "Unblocked":
        admin.block_cell(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}", connection="block")

    admin.teardown(connection='block')


def unblock_all_cells(cell_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='unblock')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if cell_type == "LTE":
        cells = emss.get_existing_objects_of_given_type("LNCEL")
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
    elif cell_type == "NR":
        cells = emss.get_existing_objects_of_given_type("NRCELL")
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"
    for cell in cells:
        cell_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}",
                                                     parameter_list=["blockingState"],
                                                     connection="unblock")[0]['parameters']['blockingState']
        if cell_state == "Blocked":
            admin.unblock_cell(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}", connection="unblock")

    admin.teardown(connection='unblock')


def unblock_cell(cell_id, cell_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='unblock')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if cell_type == "LTE":
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
        cell = f"LNCEL-{cell_id}"
    elif cell_type == "NR":
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"
        cell = f"NRCELL-{cell_id}"
    cell_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}",
                                                 parameter_list=["blockingState"],
                                                 connection="unblock")[0]['parameters']['blockingState']
    if cell_state == "Blocked":
        admin.unblock_cell(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}", connection="unblock")

    admin.teardown(connection='unblock')


def lock_all_cells(cell_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='cell_lock')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if cell_type == "LTE":
        cells = emss.get_existing_objects_of_given_type("LNCEL")
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
    elif cell_type == "NR":
        cells = emss.get_existing_objects_of_given_type("NRCELL")
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"

    for cell in cells:
        cell_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}",
                                                     parameter_list=["administrativeState"],
                                                     connection="cell_lock")[0]['parameters']['administrativeState']
        if cell_state == "Unlocked":
            admin.lock(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}", connection="cell_lock")

    admin.teardown(connection='cell_lock')


def unlock_all_cells(cell_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='cell_unlock')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if cell_type == "LTE":
        cells = emss.get_existing_objects_of_given_type("LNCEL")
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
    elif cell_type == "NR":
        cells = emss.get_existing_objects_of_given_type("NRCELL")
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"

    for cell in cells:
        cell_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}",
                                                     parameter_list=["administrativeState"],
                                                     connection="cell_unlock")[0]['parameters']['administrativeState']
        if cell_state == "Locked":
            admin.unlock(dist_name=f"MRBTS-{mrbts_id}/{bts}/{cell}", connection="cell_unlock")

    admin.teardown(connection='cell_unlock')


def block_rat(rat_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='rat_block')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if rat_type == "LTE":
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
    elif rat_type == "NR":
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"
    rat_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}",
                                                parameter_list=["blockingState"],
                                                connection="rat_block")[0]['parameters']['blockingState']
    if rat_state == "Unblocked":
        admin.block_rat(rat=rat_type, connection="rat_block")

    admin.teardown(connection='rat_block')


def unblock_rat(rat_type):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='rat_unblock')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    if rat_type == "LTE":
        bts = f"LNBTS-{emss.get_object_id(moc='LNBTS')}"
    elif rat_type == "NR":
        bts = f"NRBTS-{emss.get_object_id(moc='NRBTS')}"
    rat_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/{bts}",
                                                parameter_list=["blockingState"],
                                                connection="rat_unblock")[0]['parameters']['blockingState']
    if rat_state == "Blocked":
        admin.unblock_rat(rat=rat_type, connection="rat_unblock")

    admin.teardown(connection='rat_unblock')


def block_bts():
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='bts_block')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    bts_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}",
                                                parameter_list=["blockingState"],
                                                connection="bts_block")[0]['parameters']['blockingState']
    if bts_state == "Unblocked":
        admin.block(connection="bts_block")

    admin.teardown(connection='bts_block')


def unblock_bts():
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='bts_unblock')
    emss = ta_emss(host='10.0.1.1')
    mrbts_id = emss.get_object_id(moc="MRBTS")
    bts_state = admin.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}",
                                                parameter_list=["blockingState"],
                                                connection="bts_unblock")[0]['parameters']['blockingState']
    if bts_state == "Blocked":
        admin.unblock(timeout=600, connection="bts_unblock")

    admin.teardown(connection='bts_unblock')


def site_reset():
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='site_reset')
    emss = ta_emss(host='10.0.1.1')
    admin.reset_site(connection="site_reset", wait_for_reconnection=False, graceful_cell_shutdown=True)
    emss.wait_for_enb_discovery(timeout=600)
    admin.teardown(connection='site_reset')


def rat_reset(rat_type, graceful_cell_shutdown=True, reset_type=None):
    admin.connect_to(bts_host="192.168.255.129", bts_port=443, use_ssl=True, name='rat_reset')
    emss = ta_emss(host='10.0.1.1')
    admin.rat_reset(rat_type=rat_type, connection='rat_reset', graceful_cell_shutdown=graceful_cell_shutdown,
                    reset_type=reset_type, timeout=300)
    emss.wait_for_enb_discovery(timeout=300)
    emss.wait_for_enb_on_air(timeout=600)
    admin.teardown(connection='rat_reset')


def check_radios_availability():
    emss = ta_emss(host='10.0.1.1')
    ta_testline_mgmt.wait_for_testline_icmp_echo_replies_and_ssh_services()
    rmod_count = len(emss.get_existing_objects_of_given_type(type_of_objects='RMOD'))
    ta5g_iphy.wait_until_given_number_of_radio_modules_is_up(rmod_count=rmod_count, alias="check_radios")
