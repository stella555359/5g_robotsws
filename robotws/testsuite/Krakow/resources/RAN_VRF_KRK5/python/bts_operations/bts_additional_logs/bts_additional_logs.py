import os
import re
import subprocess
import time
import taf.collectors.l1l2bip.interface as l1l2bip
from taf.analyzer.pcap import pcap
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.utilities.test_config import get_log_path, get_repository_path
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
from taf.rfrl.utilities.utf_lab.ute_utf_lab import UteUtfLab
from taf.sw.dcap.rd import rd


class BtsAdditionalLogs:
    # artifactory = 'https://artifactory-espoo1.int.net.nokia.com/artifactory/wslte5g_plugins-local/'
    artifactory = 'https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/'
    local_wireshark_dir = '/home/ute/.local/lib/wireshark/plugins/'
    wireshark_profiles_path = '/home/ute/.config/wireshark/profiles'
    wslte_tool = 'install_wslte_plugins.bash'

    @staticmethod
    def create_dir_for_additional_logs():
        return get_log_path()

    @staticmethod
    def get_bts_sw_version():
        gnb_du = GnbDuOperations()
        sw_version = gnb_du.get_bts_sw_version()
        sw_version = re.sub('SBTS.*_ENB_9999', 'SBTS00_ENB_9999', sw_version)
        return sw_version

    @staticmethod
    def update_wireshark_profile(profile):
        profile = '{}/{}'.format(get_repository_path(), profile)
        cmd = 'cp -r {} {}'.format(profile, BtsAdditionalLogs.wireshark_profiles_path)
        log_info_to_console(cmd)
        os.system(cmd)

    @staticmethod
    def unify_sw_version(sw_version):
        if not sw_version:
            gnb_du = GnbDuOperations()
            sw_version = gnb_du.get_bts_sw_version()
        sw_version = re.sub('SBTS.*_ENB_9999', 'SBTS00_ENB_9999', sw_version)
        return sw_version

    @staticmethod
    def get_mcshark_pattern(sw_version):
        return r'"*(mcshark-4\.0-\d+\.\d+\.\d+-{}\+buster\.so)"*'.format(sw_version)

    @staticmethod
    def get_token():
        """
        How to generate token for artifactory:
        https://confluence.ext.net.nokia.com/ +
        pages/viewpage.action?pageId=490810396#EEArtifactMgmtFAQ-Howtosetupauthenticateduser
        """
        # espoo1 token
        # token = 'cmVmdGtuOjAxOjE4MTU3MzQ0NjU6N0loZmx1RWxRZlZBdm5VNUwzdFozYmRnSG42'
        # hz1 token
        token = 'cmVmdGtuOjAxOjE3ODU0NDg5MDk6am5QNURubXB1MFlISzZVTk5ObFZ0OWhKajJ5'
        return token

    @staticmethod
    def curl_command(url, output_file):
        curl_cmd = [
            'curl',
            '-H',
            'Authorization: Bearer {}'.format(BtsAdditionalLogs.get_token()),
            url,
            '-o',
            output_file
        ]
        result = subprocess.run(curl_cmd, capture_output=True, text=True)
        if result.returncode != 0:
            raise Exception('`curl` command {} failed. \nSTDOUT: {} \nSTDERR: {} \nRETURN_CODE: {}'.
                            format(' '.join(curl_cmd), result.stdout, result.stderr, result.returncode))
        if not os.path.exists(output_file):
            raise FileNotFoundError('{} was not found'.format(output_file))

    @staticmethod
    def get_latest_plugin_version(plugin):
        folder = {
            'nsetapx': 'NSETAP_X',
            'nsetap': 'NSETAP',
            'mcshark': 'MCSHARK'
        }
        pattern = r'({}-\d+\.\d+\.\d+)\/\<\/a\>\s+(\S+\s\S+)'.format(plugin)
        log_path = get_log_path()
        file_path = '{}/{}.html'.format(log_path, plugin)
        url = '{}/{}/'.format(BtsAdditionalLogs.artifactory, folder[str(plugin).lower()])
        BtsAdditionalLogs.curl_command(
            url=url,
            output_file=file_path
        )
        plugin_dict = {}
        with open(file_path) as file_handler:
            for line in file_handler:
                match = re.search(pattern, line)
                if match:
                    converted_time = time.strptime(match.group(2), '%d-%b-%Y %H:%M')
                    plugin_dict[converted_time] = match.group(1)
        if not plugin_dict:
            raise Exception('No `{}` version found in {}'.format(plugin, url))
        plugin_dates = list(plugin_dict.keys())
        plugin_dates.sort()
        return plugin_dict[plugin_dates[-1]]

    @staticmethod
    def install_wireshark_plugin(plugin, profile=None):
        if plugin in ['nsetapx', 'nsetap']:
            plugin_version = BtsAdditionalLogs.get_latest_plugin_version(plugin=plugin)
            plugin_version = plugin_version.replace('-', ' ')
            plugin_part = '--{}'.format(plugin_version.replace('-', ' '))
        elif plugin.lower() == 'mcshark':
            plugin_part = '--sbts {}'.format(BtsAdditionalLogs.get_bts_sw_version())
        else:
            log_warn_to_console('Unknown `{}` plugin.')
            return 0
        install_cmd = './{} --authtoken {} {} --force'.format(BtsAdditionalLogs.wslte_tool,
                                                              BtsAdditionalLogs.get_token(),
                                                              plugin_part)
        log_info_to_console(install_cmd)
        os.system(install_cmd)

    @staticmethod
    def download_wslte_plugin_tool():
        BtsAdditionalLogs.curl_command(
            url='{}/tools/{}'.format(BtsAdditionalLogs.artifactory, BtsAdditionalLogs.wslte_tool),
            output_file=BtsAdditionalLogs.wslte_tool
        )
        chmod_cmd = ('chmod +x {}'.format(BtsAdditionalLogs.wslte_tool))
        os.system(chmod_cmd)

    @staticmethod
    def configure_wireshark_plugins(plugins, profile=None):
        if profile:
            BtsAdditionalLogs.update_wireshark_profile(profile=profile)
        BtsAdditionalLogs.download_wslte_plugin_tool()
        for plugin in plugins:
            BtsAdditionalLogs.install_wireshark_plugin(plugin=plugin)

    @staticmethod
    def remove_wireshark_plugins():
        if os.path.exists(BtsAdditionalLogs.local_wireshark_dir):
            rm_cmd = 'sudo rm -rf {}'.format(BtsAdditionalLogs.local_wireshark_dir)
            log_info_to_console(rm_cmd)
            os.system(rm_cmd)

    @staticmethod
    def start_collect_bts_pcap(capture_file, interface='br0', bts_id=0):
        gnb_log = GnbLog()
        gnb_log.start_tcpdump_on_smod(interface=interface, capture_file=capture_file, background=True, bts_id=bts_id)

    @staticmethod
    def stop_collect_bts_pcap(capture_file, log_dir=None, bts_id=0):
        gnb_log = GnbLog()
        gnb_log.stop_tcpdump_on_smod(bts_id=bts_id)
        if not log_dir:
            log_dir = get_log_path()
        return gnb_log.download_tcpdump_from_bts(interface='FCT', log_file_name=capture_file, log_dir=log_dir,
                                                 bts_id=bts_id)

    @staticmethod
    def start_gnb_bip_trace(host, user='Nemuadmin', password='nemuuser', port=443, collector_name='l1l2_bip',
                            timeout=600):
        webservice = {
            'host': host,
            'user': user,
            'password': password,
            'port': port
        }
        bip_collector = l1l2bip.l1l2bip()
        bip_collector.create_interface_mirroring_l1l2bip_collector(name=collector_name, webservice=webservice,
                                                                   timeout=timeout)
        bip_collector.setup_collectors(names=collector_name)
        bip_collector.start_collectors(names=collector_name)
        bip_collector.set_suite_alias(collector_name)
        log_info_to_console('BIP logs collection started', log_hierarchy=2)

    @staticmethod
    def stop_gnb_bip_trace(collector_name='l1l2_bip', logs_dir=None):
        bip_collector = l1l2bip.l1l2bip()
        bip_collector.stop_collectors(names=collector_name)
        bip_collector.collect_collectors(names=collector_name, target_dir=logs_dir)
        bip_collector.teardown_collectors(names=collector_name)
        log_info_to_console('BIP logs collection stopped', log_hierarchy=2)

    @staticmethod
    def verify_messages_in_pcap(pcap_file, messages, log_type):
        errors = []
        for message in messages:
            pcap_analyzer = pcap()
            pcap_parser = pcap_analyzer.setup(infile=pcap_file)
            field_values_in_packets = pcap_analyzer.get_field_value(field_name=message['field_name'],
                                                                    fmt='showname',
                                                                    filter=message['display_filter'],
                                                                    pcap_parser=pcap_parser)
            if log_type == 'bts_pcap':
                if message['nr_of_packets'] and len(field_values_in_packets) < message['nr_of_packets']:
                    errors.append("Wrong number of packets with field=`{}`: {}, should be {}".
                                  format(message['field_name'], len(field_values_in_packets), message['nr_of_packets']))
                else:
                    log_info_to_console('Correct number of packets with field=`{}`: {}'
                                        .format(message['field_name'], len(field_values_in_packets)),
                                        log_hierarchy=3)
            elif log_type == 'bip':
                if len(field_values_in_packets) == 0:
                    raise Exception(
                        'Number of BIP messages should more than 0, filter={}'.format(message['display_filter']))
            else:
                raise Exception('Unsupported log type {}'.format(log_type))
            if field_values_in_packets and message['field_values']:
                for field_values_in_packet in field_values_in_packets:
                    for field_value in field_values_in_packet:
                        if field_value in message['field_values']:
                            log_info_to_console('Field `{}` has correct `{}` value'
                                                .format(message['field_name'], field_value), log_hierarchy=3)
                        else:
                            errors.append('Field `{}` has incorrect `{}` value'.
                                          format(message['field_name'], field_value))
        if errors:
            raise Exception("Errors found during pcap messages verification: {}".format(errors))

    @staticmethod
    def start_dcap_logs(dcap_host, gnb_ip, gnb_port=443, dcap_profile=['cp_5g'], dcap_port=443, dcap_username='utfuser',
                        dcap_password='utfadmin!'):
        dcap = UteUtfLab()
        dcap.connect(host=dcap_host, port=dcap_port, username=dcap_username, password=dcap_password)
        dcap.add_gnb(gnb_ip=gnb_ip, gnb_port=gnb_port)
        trace_id = dcap.start_trace_gnb(gnb_ip=gnb_ip, gnb_port=gnb_port, gnb_custom_profile=dcap_profile)
        dcap.wait_for_trace_running(trace_id=trace_id)
        return trace_id

    @staticmethod
    def stop_dcap_logs(trace_id, dcap_host, log_dir=None, trace_file_name=None, dcap_port=443, dcap_username='utfuser',
                       dcap_password='utfadmin!', delete_trace=False):
        dcap = UteUtfLab()
        dcap.connect(host=dcap_host, port=dcap_port, username=dcap_username, password=dcap_password)
        dcap.stop_trace(trace_id=trace_id,)
        trace_file_path = dcap.get_results(trace_id=trace_id, log_dir=log_dir, with_name=trace_file_name)
        if delete_trace:
            dcap.delete_trace(trace_id=trace_id)
        return trace_file_path

    @staticmethod
    def decode_emil_logs_with_dcap(emil_log, emil_filter, dcap_host, dcap_port=443, dcap_username='utfuser',
                                   dcap_password='utfadmin!', dcap_rd_version='dcapv3', dcap_secure=True):
        dcap = rd()
        dcap.connect_to(host=dcap_host, port=dcap_port, username=dcap_username, password=dcap_password,
                        rd_version=dcap_rd_version, secure=dcap_secure)
        upload_result = dcap.upload_encoded_file(file_name=emil_log)
        decoded_content = dcap.get_decoded_file_contents_in_json(session_id=upload_result['session_id'],
                                                                 data_source_id=upload_result['file_ids'][0],
                                                                 what='source',
                                                                 filter=emil_filter)
        return decoded_content

    @staticmethod
    def delete_bts_from_dcap(bts_id, dcap_host, dcap_port='443', dcap_username='utfuser', dcap_password='utfadmin!',
                             dcap_rd_version='dcapv3', dcap_secure=True):
        dcap = rd()
        dcap.connect_to(host=dcap_host, port=dcap_port, username=dcap_username, password=dcap_password,
                        rd_version=dcap_rd_version, secure=dcap_secure)
        all_bts_info = dcap.get_all_bts_info()
        for bts_info in all_bts_info:
            if int(bts_info['mr_bts_id']) == int(bts_id):
                dcap.delete_bts(bts_id=bts_info['id'])
                log_info_to_console(f'MRBTS-{bts_id} removed from DCAP: {dcap_host}')
                break
