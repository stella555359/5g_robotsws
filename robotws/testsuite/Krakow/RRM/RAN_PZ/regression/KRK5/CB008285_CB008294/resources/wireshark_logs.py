import os
import re
import subprocess
import time
from taf.analyzer.pcap import pcap
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
from taf.rfrl.utilities.test_config import get_log_path
from taf.collectors.l1l2bip import l1l2bip
from taf.collectors.core import core
from robot.libraries.BuiltIn import BuiltIn


wireshark_dir = '/usr/lib/x86_64-linux-gnu/wireshark/plugins/4.0/epan/'


class NoMessageInPcap(Exception):
    pass


class WrongValue(Exception):
    pass


def start_collect_bh_pcap(capture_file, interface='any', additional_options=None):
    gnb_log = GnbLog()
    gnb_log.start_tcpdump_on_smod(interface=interface, capture_file=capture_file, background=True,
                                  additional_options=additional_options)


def stop_collect_bh_pcap(capture_file, log_dir=None):
    gnb_log = GnbLog()
    gnb_log.stop_tcpdump_on_smod()
    gnb_log.download_tcpdump_from_bts(interface='FCT', log_file_name=capture_file, log_dir=log_dir)


def initialize_pcap():
    return pcap()


def verify_xnap_messages_in_pcap(pcap_file, xnap_messages):
    pcap = initialize_pcap()
    for xnap_message in xnap_messages:
        pcap_parser = pcap.setup(infile=pcap_file)
        field_values_in_packets = pcap.get_field_value(field_name=xnap_message['field_name'], fmt='showname',
                                                       filter=xnap_message['display_filter'], pcap_parser=pcap_parser)
        if xnap_message['nr_of_packets'] and len(field_values_in_packets) < xnap_message['nr_of_packets']:
            raise NoMessageInPcap("Wrong number of packets with field=`{}`: {}, should be {}".
                                  format(xnap_message['field_name'], len(field_values_in_packets),
                                         xnap_message['nr_of_packets']))
        else:
            log_info_to_console('Correct number of packets with field=`{}`: {}'.format(xnap_message['field_name'],
                                                                                       len(field_values_in_packets)),
                                log_hierarchy=3)
        if field_values_in_packets and xnap_message['field_values']:
            log_info_to_console('Fields: {}'.format(field_values_in_packets))
            for field_values_in_packet in field_values_in_packets:
                for field_value in field_values_in_packet:
                    if field_value in xnap_message['field_values']:
                        log_info_to_console('Field `{}` has correct `{}` value'.format(xnap_message['field_name'],
                                                                                       field_value),
                                            log_hierarchy=3)
                    else:
                        raise WrongValue('Field `{}` has incorrect `{}` value'.format(
                            xnap_message['field_name'], field_value))


def curl_command(url, output_file):
    curl_cmd = [
        'curl',
        url,
        '-o',
        output_file
    ]
    proc = subprocess.Popen(curl_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out, err = proc.communicate()
    if proc.returncode != 0:
        raise Exception('`curl` command {} failed. \nSTDOUT: {} \nSTDERR: {} \nRETURN_CODE: {}'.
                        format(' '.join(curl_cmd), out, err, proc.returncode))


def unify_sw_version(sw_version):
    if not sw_version:
        gnb_du = GnbDuOperations()
        sw_version = gnb_du.get_bts_sw_version()
    sw_version = re.sub('SBTS.*_ENB_9999', 'SBTS00_ENB_9999', sw_version)
    return sw_version


def get_mcshark_pattern(sw_version):
    return r'"*(mcshark-4\.0-\d+\.\d+\.\d+-{}\+buster\.so)"*'.format(sw_version)


def download_mcshark_plugin(sw_version=None):
    log_path = get_log_path()
    index_file_name = '{}/index.html'.format(log_path)
    sw_version = unify_sw_version(sw_version=sw_version)
    curl_command(
        url='https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/{}/'
        .format(sw_version),
        output_file=index_file_name
    )
    mcshark_plugin_name = None
    with open(index_file_name) as index_file:
        mcshark_found = False
        for l_no, line in enumerate(index_file):
            match = re.search(get_mcshark_pattern(sw_version=sw_version), line)
            if match:
                mcshark_plugin_name = match.group(1)
                mcshark_found = True
                break
        if not mcshark_found:
            raise Exception('Correct MCShark plugin file name not found in {}'.format(index_file_name))
    plugin_file = '{}/{}'.format(log_path, mcshark_plugin_name)
    curl_command(
        url='https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark/{}/{}'.format(
            sw_version, mcshark_plugin_name),
        output_file=plugin_file
    )
    return plugin_file


def verify_mcshark_plugin(sw_version=None):
    sw_version = unify_sw_version(sw_version=sw_version)
    plugins_list = os.listdir(wireshark_dir)
    plugins_list = ' '.join(plugins_list)
    match = re.search(get_mcshark_pattern(sw_version=sw_version), plugins_list)
    if match:
        log_info_to_console('Correct Wireshark plugin installed: {}'.format(match.group(1)), log_hierarchy=2)
    else:
        log_info_to_console('Need to download and install correct MCshark plugin', log_hierarchy=2)
        plugin_file = download_mcshark_plugin(sw_version=sw_version)
        install_mcshark_plugin(plugin_file=plugin_file)


def install_mcshark_plugin(plugin_file):
    cmp_cmd = 'sudo cp {} {}'.format(plugin_file, wireshark_dir)
    os.system(cmp_cmd)


def collect_gnb_bip_trace(period=10):
    webservice = {
        'host': BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}'),
        'user': BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.username}'),
        'password': BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.password}'),
        'port': 443
    }
    l1l2_bip = l1l2bip()
    l1l2_bip.create_interface_mirroring_l1l2bip_collector(name='l1l2_bip', webservice=webservice, timeout=150)
    core_collector = core()
    core_collector.setup_collectors(names='l1l2_bip')
    core_collector.start_collectors(names='l1l2_bip')
    time.sleep(period)
    core_collector.stop_collectors(names='l1l2_bip')
    core_collector.collect_collectors(names='l1l2_bip', target_dir='/home/ute/grabania')


def check_no_ca(capture_file):
    pcap_filter = 'nr-rrc&&f1ap.procedureCode == 12'
    pcap = initialize_pcap()
    pcap_parser = pcap.setup(infile=capture_file, display_filter=pcap_filter)
    scelltoaddmodlist = pcap.get_field_value_by_xpath(
        xpath='.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellToAddModList', attribute_name='showname',
        pcap_parser=pcap_parser)
    if len(scelltoaddmodlist) == 0:
        log_info_to_console('No CA in {} file.'.format(capture_file))
    else:
        raise Exception('CA found in {} file.'.format(capture_file))


def check_dl_and_ul_ca(capture_file, dl_cc, ul_cc):
    dl_cc -= 1
    ul_cc -= 1
    pcap_filter = 'nr-rrc&&f1ap.procedureCode == 12'
    pcap = initialize_pcap()
    pcap_parser = pcap.setup(infile=capture_file, display_filter=pcap_filter)
    scelltoaddmodlist = pcap.get_field_value_by_xpath(
        xpath='.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellToAddModList', attribute_name='showname',
        pcap_parser=pcap_parser)
    scelltoaddmodlist_dl = pcap.get_field_value_by_xpath(
        xpath='.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellConfigCommon_element//'
              'nr-rrc.downlinkConfigCommon_element',
        attribute_name='showname',
        pcap_parser=pcap_parser)
    scelltoaddmodlist_ul = pcap.get_field_value_by_xpath(
        xpath='.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellConfigCommon_element//'
              'nr-rrc.uplinkConfigCommon_element',
        attribute_name='showname',
        pcap_parser=pcap_parser)

    if len(scelltoaddmodlist_dl) != dl_cc:
        raise Exception('Wrong {} DL CA in {} file.'.format(len(scelltoaddmodlist_dl), capture_file))
    if len(scelltoaddmodlist_ul) != ul_cc:
        raise Exception('Wrong {} UL CA in {} file.'.format(len(scelltoaddmodlist_ul), capture_file))


def verify_rrc_setup(capture_file, initial_bwp=False):
    filter = 'f1ap.procedureCode && nr-rrc.firstActiveDownlinkBWP_Id'
    field_name = 'nr-rrc.firstActiveDownlinkBWP_Id'
    pcap = initialize_pcap()
    pcap_parser = pcap.setup(infile=capture_file)
    field_values_in_packets = pcap.get_field_value(field_name=field_name, fmt='showname',
                                                   filter=filter, pcap_parser=pcap_parser)
    if not field_values_in_packets:
        raise Exception('No messages with firstActiveDownlinkBWP_Id field found.')
    initial_bwp_value = '0' if initial_bwp is True else '1'
    for field_values_in_packet in field_values_in_packets:
        for field_value in field_values_in_packet:
            if field_value != 'firstActiveDownlinkBWP_Id: {}'.format(initial_bwp_value):
                log_info_to_console('Field `{}` has correct `{}` value'.format(field_name, field_value),
                                    log_hierarchy=3)
            else:
                raise WrongValue('Field `{}` has incorrect `{}` value'.format(field_name, field_value))


def check_csi_report(capture_file, exp_cqi, exp_beam_report):
    pcap_filter = '((nr-rrc.setup_element)&&!(nr-rrc.rrcReconfiguration_element)) && (f1ap.procedureCode == 12)'
    pcap = initialize_pcap()
    pcap_parser = pcap.setup(infile=capture_file, display_filter=pcap_filter)
    cqi_list = pcap.get_field_value_by_xpath(
        xpath='.//nr-rrc.cri_RI_PMI_CQI_element//..//..//nr-rrc.reportConfigType//nr-rrc.pucch_Resource',
        pcap_parser=pcap_parser)
    beam_report_list = pcap.get_field_value_by_xpath(
        xpath='.//nr-rrc.ssb_Index_RSRP_element//..//..//nr-rrc.reportConfigType//nr-rrc.pucch_Resource',
        pcap_parser=pcap_parser)

    for cqi in cqi_list:
        if int(cqi) != int(exp_cqi):
            raise Exception('Wrong CQI, {} != {}, check {} file.'.format(cqi, exp_cqi, capture_file))
        else:
            log_info_to_console('Correct CQI, {} == {}.'.format(cqi, exp_cqi), log_hierarchy=2)
    for beam_report in beam_report_list:
        if int(beam_report) != int(exp_beam_report):
            raise Exception('Wrong BEAM, {} != {}, check {} file.'.format(beam_report, exp_beam_report, capture_file))
        else:
            log_info_to_console('Correct BEAM, {} == {}.'.format(beam_report, exp_beam_report), log_hierarchy=2)
