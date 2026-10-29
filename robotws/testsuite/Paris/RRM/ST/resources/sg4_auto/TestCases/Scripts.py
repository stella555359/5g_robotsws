
import taf.ue as ue
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn
from taf.collectors.l1l2bip import InterfaceL1L2BIPCollectorFactory
from datetime import datetime
import logging
import shutil
import time
import re
from pathlib import Path
import taf.transport.ssh as ssh
import taf.collectors.btslog as btslog
import taf.collectors.core as core
# import taf.analyzer.iperf_throughput as tput
import sys
# import PySimpleGUI as sg
import os

try:
    import matplotlib.pyplot as plt
except ImportError:
    pass
    # TODO fix because tmp for pipelines
    # os.system('pip install matplotlib')
    # import matplotlib.pyplot as plt


def call_keyword(keyword):
    return BuiltIn().run_keyword(keyword)


def file_exists(file):
    return os.path.isfile(file)


def reset_site(tl):
    coam = admin()
    coam.connect_to(bts_host=tl.gnbs[0].cu.oam_ssh_connection_details.addr, name='coam_admin')
    print('Resetting gNB...')
    coam.reset_site(connection='coam_admin')
    coam.teardown('coam_admin')


def activate_traces():
    coam = admin
    coam.connect_to(bts_host='10.14.49.20', name='coam_admin')
    coam.start_uplane_l1_trace(
        source_ip='10.14.49.20', dscp=15, destination_ip='10.14.39.217', destination_port=5678, connection='coam_admin')


# def get_file_to_convert(tti_folder, pcapcsv):
#     action = 'convert' if pcapcsv == 'pcap' else 'process'
#     # xtrastr = '' if pcapcsv == 'pcap' else '\.dlAndUl'
#     layout = [
#         [sg.Text("Select " + pcapcsv + " file to " + action + ":")],
#         [sg.InputText(key='file_path'),
#          sg.FileBrowse(file_types=((pcapcsv + " Files", "*." + pcapcsv + "*"), ("All Files", "*.*")),
#                        initial_folder=tti_folder)],
#         [sg.Button("OK"), sg.Button("Cancel")]
#     ]
#     window = sg.Window("TTI trace conversion", layout)
#
#     while True:
#         event, values = window.read()
#
#         if event == sg.WIN_CLOSED or event == "Cancel":
#             break
#         elif event == "OK":
#             # selected_file = re.sub(r'\.pcap[0-9]?|' + xtrastr + '.csv', '',
#             #                        values['file_path'].replace('&', r'\&').replace('-', r'\-'))
#             selected_file = values['file_path'].replace('&', r'\&').replace('-', r'\-')
#             break
#
#     window.close()
#     return os.path.split(selected_file)


def check_cells_on_air(tl):
    coam = admin()
    coam.connect_to(bts_host=tl.gnbs[0].cu.oam_ssh_connection_details.addr, name='coam_admin')
    cell_status_all = coam.get_cells_info(cell_type='nr', timeout=30, connection='coam_admin')
    # cells = list(d['globalCellId'] for d in cell_status)
    onAir = True
    for cell_status in cell_status_all:
        if (cell_status['status']['administrativeState'].casefold() != "unlocked" or
            cell_status['status']['blockingState'].casefold() != "unblocked" or
            cell_status['status']['operationalState'].casefold() != "enabled" or
                cell_status['status']['proceduralStatus'].casefold() != "configured"):
            onAir = False
    bts_status = coam.get_bts_statuses(timeout=30, connection='coam_admin')
    if (bts_status['operationalState'].casefold() != "enabled" or
        bts_status['proceduralState'].casefold() != "onair" or
            bts_status['blockingState'].casefold() != "unblocked"):
        onAir = False
    coam.teardown('coam_admin')
    return onAir


def get_tti_trace_decoder():
    coam = admin()
    software_info = coam.get_gnb_sw_version()
    files_base_link = 'http://files.ute.nsn-rdnet.net/builds/enb/base'
    files_base_link_branches = \
        'https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public/System_Release'


# def start_bip_trace(tl, destFile):
#     # logging.basicConfig(
#     #                     level=logging.DEBUG,
#     #                     format="%(asctime)s %(name)s %(message)s")
#
#     webservice = {'host': tl.gnbs[0].cu.oam_http_connection_details.addr,
#                   'user': tl.gnbs[0].cu.oam_http_connection_details.username,
#                   'password': tl.gnbs[0].cu.oam_http_connection_details.password,
#                   'port': 443}
#     configuration = {'name': 'l1l2bip',
#                      'webservice': webservice,
#                      'timeout': 250}
#
#     l1l2bip_collector = InterfaceL1L2BIPCollectorFactory().create(configuration=configuration, existing_arguments={})
#     l1l2bip_collector.setup()
#     l1l2bip_collector.start()
#     ch = sg.popup_ok("L1L2 is running, press to stop", title="Stop")
#     todayDate = datetime.now().strftime("%Y%m%d")
#     todayHour = datetime.now().strftime("%H%M%S")
#     destFile = destFile.replace("%D", todayDate).replace("%H", todayHour)
#     l1l2bip_collector.stop()
#     l1l2bip_collector.collect(target_dir="/tmp")
#     listfiles = os.listdir("/tmp/l1l2bip")
#     listpaths = [os.path.join("/tmp/l1l2bip", basename) for basename in listfiles]
#     pcap_file = max(listpaths, key=os.path.getctime)
#     shutil.copy(pcap_file, destFile)
#     l1l2bip_collector.teardown()
#
#     sg.popup_ok("Trace " + destFile + " created successfully", title="Stop")


# def show_msg(msg):
#     sg.popup_ok(msg, title="Info")
