from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.connections as connections
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from taf.converters.eventdecoder import eventdecoder
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.core import CollectorKeywords
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti.tcpdump_collector import start_tcpdump_on_test_pc
from taf.transport.ssh import ssh
import os
import re
import json
import csv

default_cell_dist_id = ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1']
src_ip = tl.gnbs[0].cu.backhaul_site_oam_ip.v4  # mplane
dest_ip = tl.test_pc.default_ssh_connection_details.addr  # UTE VM


@logged_keyword
def start_tti_traces_in_streaming_mode(tcpdump_filename='tti_tcpdump'):
    blog('TTI Traces are forwarded to IP: ' + str(dest_ip))
    tcpdump_collector = start_tcpdump_on_tti_interface(tcpdump_filename=tcpdump_filename)
    start_generation_of_tti_trace_using_taf_sbts(tcpdump_collector)


def start_tcpdump_on_tti_interface(tcpdump_filename='tti_tcpdump'):
    connection = connections.connect_to_test_pc()
    interface_name = identify_interface_with_ip(dest_ip, connection)
    blog('Identifed interface for tcpdump on Test PC is : ' + str(interface_name))
    collector = start_tcpdump_on_test_pc(interface=interface_name, option='port 5678', collector=tcpdump_filename)
    return collector


def start_generation_of_tti_trace_using_taf_sbts(tcpdump_collector, tti_collector_name='TTI'):
    executor = {'host': tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr,
                'user': tl.gnbs[0].cu.oam_http_connection_details.username,
                'password': tl.gnbs[0].cu.oam_http_connection_details.password,
                'port': 443,
                'release': assign_release_version()}
    l2_stream_config_1 = {'trace_type': 'Component'}
    l2_stream_configuration = [l2_stream_config_1]
    tti_collector = l2stream3()
    tti_collector.create_sbts_l2stream_collector(name=tti_collector_name, webservice=executor,
                                                 source_ip_addr=src_ip,
                                                 destination_ip_addr=dest_ip,
                                                 collector=tcpdump_collector,
                                                 l2_stream_configuration=l2_stream_configuration)
    core = CollectorKeywords()
    core.setup_collectors(names=tti_collector_name)
    core.start_collectors(names=tti_collector_name)
    core.set_suite_alias(tti_collector_name)
    blog('TTI streaming started!')


@logged_keyword
def stop_tti_traces_in_streaming_mode(tti_collector_name='TTI', tti_output_dir=None, decoded_output_file=None,
                                      tcpdump_filename='tti_tcpdump', with_decode=True,
                                      output_file_format='legacyCsv'):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = os.path.join(tti_collector_name, testname) if decoded_output_file is None \
        else os.path.join(tti_collector_name, '{}_{}'.format(testname, decoded_output_file))
    tti_output_dir = outputdir if tti_output_dir is None else tti_output_dir

    stop_generation_of_tti_trace_using_taf(tti_output_dir=tti_output_dir)
    tti_pcap_path = os.path.join(tti_output_dir, tti_collector_name, tcpdump_filename, tcpdump_filename + '.pcap')
    if with_decode:
        convert_tti_to_output_file_format(
            input_file_path=tti_pcap_path, output_file=decoded_output_file, output_file_format=output_file_format)
    blog('TTI streaming stopped!')
    return os.path.join(robot_globals.outputdir(), decoded_output_file + '.dlAndUl.csv')


def teardown_tti_traces_in_streaming_mode(tti_collector_name='TTI', tti_output_dir=None, decoded_output_file=None,
                                          tcpdump_filename='tti_tcpdump', with_decode=True,
                                          output_file_format='legacyCsv'):
    try:
        stop_tti_traces_in_streaming_mode(tti_collector_name=tti_collector_name, tti_output_dir=tti_output_dir,
                                          decoded_output_file=decoded_output_file, tcpdump_filename=tcpdump_filename,
                                          with_decode=with_decode, output_file_format=output_file_format)
    except Exception:
        blog('TTI traces have already been collected. Teardown will not download TTI traces.')


def stop_generation_of_tti_trace_using_taf(tti_output_dir, tti_collector_name='TTI'):
    core = CollectorKeywords()
    core.stop_collectors(names=tti_collector_name)
    core.collect_collectors(names=tti_collector_name, target_dir=tti_output_dir)
    core.teardown_collectors(names=tti_collector_name)


def convert_tti_to_output_file_format(input_file_path=None, output_file='decoded_tti', output_file_format='legacyCsv'):
    ed = eventdecoder()
    ed.create_eventdecoder_converter(name='converter', input_file_path=input_file_path,
                                     output_file_format=output_file_format,
                                     output_file_path=os.path.join(robot_globals.outputdir(), output_file))
    ed.convert(name='converter')
    return os.path.join(robot_globals.outputdir(), output_file)


def identify_interface_with_ip(ip, connection):
    _ssh = ssh()
    cl_output = _ssh.execute("ip -o -4 addr show | awk '{print $2\" \"$4}'" + " | grep {ip}".format(ip=ip),
                             connection=connection)
    words = cl_output.split()
    interface_name = words[0] if words else None
    return interface_name


def assign_release_version():
    smod_conn = connections.connect_to_smod()
    _ssh = ssh()
    version_file = _ssh.execute(command='ls /ffs/run/TargetBD*.xml', connection=smod_conn)
    return version_file.split()[-1].split('TargetBD_')[-1].split('_')[0]


def read_csv_file_to_var(tti_collector_name='TTI', tti_output_dir=None, decoded_output_file=None,
                         tcpdump_filename='tti_tcpdump', with_decode=True,
                         output_file_format='legacyCsv'):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = \
        os.path.join(tti_collector_name, testname) if decoded_output_file is None else decoded_output_file
    tti_output_dir = outputdir if tti_output_dir is None else tti_output_dir
    file = os.path.join(robot_globals.outputdir(), decoded_output_file + '.dlAndUl.csv')
    f = open(file, 'r')
    content = f.read()
    f.close()
    return content


def check_bler(threshold):
    def count_bler(content, keyword, key):
        ack_count = 0
        nack_count = 0
        for word in content.split('\n'):
            if re.findall(keyword, word, re.IGNORECASE):
                ack_count += 1
                if re.findall(key, word):
                    nack_count += 1
        return ack_count, nack_count
    ul_bler = 0
    dl_bler = 0
    content = read_csv_file_to_var()
    ack_amount_ul, nack_amount_ul = count_bler(content, 'ulHarqRxData', 'NOK')
    ack_amount_dl, nack_amount_dl = count_bler(content, 'dlHarqRxDataArray', 'NACK')
    print(ack_amount_ul + nack_amount_ul)
    print(ack_amount_dl + nack_amount_dl)
    if nack_amount_ul:
        ul_bler = (nack_amount_ul / (ack_amount_ul + nack_amount_ul)) * 100
    if nack_amount_dl:
        dl_bler = (nack_amount_dl / (ack_amount_dl + nack_amount_dl)) * 100
    print("ul_bler: ", ul_bler)
    print("dl_bler: ", dl_bler)
    return ul_bler <= int(threshold) and dl_bler <= int(threshold)


def check_numOfLayers(numOfLayersUl, numOfLayersDl):
    def check_layers(content, keyword, num):
        layers = []
        for word in content.split('\n'):
            if re.findall(keyword, word, re.IGNORECASE):
                if re.findall('numOfLayers', word):
                    parameters_list = (word.split(":")[1]).split(",")
                    val_start = int((len(parameters_list)/2))
                    position = parameters_list.index("numOfLayers")
                    layers.append(parameters_list[position+val_start])
        count = sum(1 for i in layers if i != "RANK"+num)
        print(keyword + " :", layers)
        return (count / (len(layers) + count)) * 100
    content = read_csv_file_to_var()
    LayersDl = check_layers(content, 'dlFdSchedData', numOfLayersDl)
    LayersUl = check_layers(content, 'ulFdSchedData', numOfLayersUl)
    print(LayersDl)
    print(LayersUl)
    return LayersDl <= 20 and LayersUl <= 20


def check_mcs(mcs_level=21):
    def check_layers(content, keyword, msg):
        layers = []
        for word in content.split('\n'):
            if re.findall(keyword, word, re.IGNORECASE):
                if re.findall(msg, word):
                    parameters_list = (word.split(":")[1]).split(",")
                    val_start = int((len(parameters_list)/2))
                    position = parameters_list.index(msg)
                    try:
                        if int(parameters_list[position+val_start]):
                            layers.append(parameters_list[position+val_start])
                    except Exception:
                        print("Wrong value!")
        print(keyword + " :", layers)
        count = sum(1 for i in layers if int(i) < mcs_level)
        print("count: ", count)
        print("len: ", len(layers))
        return (count / (len(layers) + count)) * 100
    content = read_csv_file_to_var()
    LayersDl = check_layers(content, 'dlFdSchedData', 'rrmDlScaledMcs')
    LayersUl = check_layers(content, 'ulFdSchedData', 'rrmUlScaledMcs')
    print(LayersDl)
    print(LayersUl)
    return LayersDl <= 5 and LayersUl <= 10


def check_modulation(expected_modulation, traffic_type):
    """
    Parameters:
    expected_modulation (int): e.g.: 64, 256
    traffic_type (str): ul, dl or uldl

    Returns:
    bool: True, False
    """
    def get_modulation_value(word, msg):
        parameters_list = word.split(",")
        val_start = 0
        for param in parameters_list:
            try:
                int(param)
                break
            except ValueError:
                val_start += 1
        position = parameters_list.index(msg)
        return (parameters_list[position+val_start])

    def collect_modulation(content, expected_modulation):
        msg = 'mcsTable'
        modulations_dl = set()
        modulations_ul = set()
        row_no = 1
        for row in content.split('\n'):
            if re.findall('dlFdSchedData', row, re.IGNORECASE) and re.findall(msg, row):
                modulation_value = get_modulation_value(row, msg)
                if modulation_value != expected_modulation:
                    print('Downlink modulation in row number {} of csv is not as expected. '
                          'Is: {}, should be {}'.format(row_no, modulation_value, expected_modulation))
                modulations_dl.add(modulation_value)
            if re.findall('ulFdSchedData', row, re.IGNORECASE) and re.findall(msg, row):
                modulation_value = get_modulation_value(row, msg)
                if modulation_value != expected_modulation:
                    print('Uplink modulation in row number {} of csv is not as expected. '
                          'Is: {}, should be {}'.format(row_no, modulation_value, expected_modulation))
                modulations_ul.add(modulation_value)
            row_no += 1
        return modulations_dl, modulations_ul
    content = read_csv_file_to_var()
    if traffic_type not in ["ul", "dl", "uldl"]:
        raise Exception('traffic_type argument is invalid: should be ul, dl or uldl')
    expected_modulation = "QAM{}".format(str(expected_modulation))
    qam_dl, qam_ul = collect_modulation(content, expected_modulation)
    if traffic_type == 'ul':
        print('ulFdSchedData: {}'.format(qam_ul))
        return len(qam_ul) == 1 and expected_modulation in qam_ul
    if traffic_type == 'dl':
        print('dlFdSchedData: {}'.format(qam_dl))
        return len(qam_dl) == 1 and expected_modulation in qam_dl
    if traffic_type == 'uldl':
        print('ulFdSchedData: {}'.format(qam_ul))
        print('dlFdSchedData: {}'.format(qam_dl))
        return len(qam_ul) == 1 and expected_modulation in qam_ul and \
            len(qam_dl) == 1 and expected_modulation in qam_dl


def read_json_tti(tti_collector_name='TTI', decoded_output_file=None):
    outputdir = robot_globals.outputdir()
    testname = robot_globals.testname()
    decoded_output_file = os.path.join(tti_collector_name, testname) if decoded_output_file is None \
        else os.path.join(tti_collector_name, '{}_{}'.format(testname, decoded_output_file))
    file_json = os.path.join(outputdir, decoded_output_file + '.json')
    print("file_json: ", file_json)
    with open(file_json, 'r') as json_content:
        content = json.load(json_content)
    return content


def check_bler_json(threshold, traffic_type, decoded_output_file):
    tti_content = read_json_tti(decoded_output_file=decoded_output_file)
    ul_results = []
    dl_results = []
    for tti_event in tti_content['events']:
        if 'ulHarqRxData' in tti_event:
            ul_results.append(tti_event['ulHarqRxData']['body']['crcResult'])
        if 'dlHarqRxDataArray' in tti_event:
            dl_results.extend([nestedArray_el['ackNack'] for nestedArray_el in
                              tti_event['dlHarqRxDataArray']['body']['nestedArray']])
    nack_amount_ul = ul_results.count('NOK')
    nack_amount_dl = dl_results.count('NACK')
    if traffic_type == 'uldl':
        if not ul_results:
            print('No crcResult in ulHarqRxData for {} traffic'.format(traffic_type))
            return False
        if not dl_results:
            print('No nestedArray with ackNack in dlHarqRxDataArray for {} traffic'.format(traffic_type))
            return False
        ul_bler = (nack_amount_ul / len(ul_results)) * 100
        dl_bler = (nack_amount_dl / len(dl_results)) * 100
        print('ul_bler: {}%, dl_bler: {}%, should be <= threshold: {}%'.format(ul_bler, dl_bler, threshold))
        return ul_bler <= int(threshold) and dl_bler <= int(threshold)
    if traffic_type == 'ul':
        if not ul_results:
            print('No crcResult in ulHarqRxData for {} traffic'.format(traffic_type))
            return False
        ul_bler = (nack_amount_ul / len(ul_results)) * 100
        print('ul_bler: {}%, should be <= threshold: {}%'.format(ul_bler, threshold))
        return ul_bler <= int(threshold)
    if traffic_type == 'dl':
        if not dl_results:
            print('No nestedArray with ackNack in dlHarqRxDataArray for {} traffic'.format(traffic_type))
            return False
        dl_bler = (nack_amount_dl / len(dl_results)) * 100
        print('dl_bler: {}%, should be <= threshold: {}%'.format(dl_bler, threshold))
        return dl_bler <= int(threshold)


def check_num_of_layers_json(numOfLayersUl, numOfLayersDl, threshold, traffic_type):
    tti_content = read_json_tti()
    ul_results = []
    dl_results = []
    for tti_event in tti_content['events']:
        if 'ulFdSchedData' in tti_event:
            ul_results.append(tti_event['ulFdSchedData']['body']['numOfLayers'])
        if 'dlFdSchedData' in tti_event:
            dl_results.append(tti_event['dlFdSchedData']['body']['numOfLayers'])
    correct_layers_ul = ul_results.count('RANK{}'.format(numOfLayersUl))
    correct_layers_dl = dl_results.count('RANK{}'.format(numOfLayersDl))
    if traffic_type == 'uldl':
        if not ul_results:
            print('No numOfLayers in ulFdSchedData for {} traffic'.format(traffic_type))
            return False
        if not dl_results:
            print('No numOfLayers in dlFdSchedData for {} traffic'.format(traffic_type))
            return False
        layers_ul = (correct_layers_ul / len(ul_results)) * 100
        layers_dl = (correct_layers_dl / len(dl_results)) * 100
        print('layers_ul: {}%, layers_dl: {}%, should be >= threshold: {}%'.format(layers_ul, layers_dl, threshold))
        return layers_ul >= int(threshold) and layers_dl >= int(threshold)
    if traffic_type == 'ul':
        if not ul_results:
            print('No numOfLayers in ulFdSchedData for {} traffic'.format(traffic_type))
            return False
        layers_ul = (correct_layers_ul / len(ul_results)) * 100
        print('layers_ul: {}%, should be >= threshold: {}%'.format(layers_ul, threshold))
        return layers_ul >= int(threshold)
    if traffic_type == 'dl':
        if not dl_results:
            print('No numOfLayers in dlFdSchedData for {} traffic'.format(traffic_type))
            return False
        layers_dl = (correct_layers_dl / len(dl_results)) * 100
        print('layers_dl: {}%, should be >= threshold: {}%'.format(layers_dl, threshold))
        return layers_dl >= int(threshold)


def check_mcs_json(treshold_ul, treshold_dl, traffic_type, mcs_level=21):
    tti_content = read_json_tti()
    ul_results = []
    dl_results = []
    for tti_event in tti_content['events']:
        if 'ulFdSchedData' in tti_event:
            ul_results.append(tti_event['ulFdSchedData']['body']['rrmUlScaledMcs'])
        if 'dlFdSchedData' in tti_event:
            dl_results.append(tti_event['dlFdSchedData']['body']['rrmDlScaledMcs'])
    count_ul = sum(1 for i in ul_results if int(i) < mcs_level)
    count_dl = sum(1 for i in dl_results if int(i) < mcs_level)
    if traffic_type == 'uldl':
        if not ul_results:
            print('No rrmUlScaledMcs in ulFdSchedData for {} traffic'.format(traffic_type))
            return False
        if not dl_results:
            print('No rrmDlScaledMcs in dlFdSchedData for {} traffic'.format(traffic_type))
            return False
        mcs_ul = (count_ul / len(ul_results)) * 100
        mcs_dl = (count_dl / len(dl_results)) * 100
        print('mcs_ul: {}%. Should be <= treshold_ul {}%.\nmcs_dl: {}%. '
              'Should be <= treshold_dl: {}.%'.format(mcs_ul, treshold_ul, mcs_dl, treshold_dl))
        return mcs_ul <= int(treshold_ul) and mcs_dl <= int(treshold_dl)
    if traffic_type == 'ul':
        if not ul_results:
            print('No rrmUlScaledMcs in ulFdSchedData for {} traffic'.format(traffic_type))
            return False
        mcs_ul = (count_ul / len(ul_results)) * 100
        print('mcs_ul: {}%. Should be <= treshold_ul {}%.'.format(mcs_ul, treshold_ul))
        return mcs_ul <= int(treshold_ul)
    if traffic_type == 'dl':
        if not dl_results:
            print('No rrmDlScaledMcs in dlFdSchedData for {} traffic'.format(traffic_type))
            return False
        mcs_dl = (count_dl / len(dl_results)) * 100
        print('mcs_dl: {}%. Should be <= treshold_dl {}%.'.format(mcs_dl, treshold_dl))
        return mcs_dl <= int(treshold_dl)


def check_modulation_json(expected_modulation, threshold, traffic_type):
    tti_content = read_json_tti()
    ul_results = []
    dl_results = []
    for tti_event in tti_content['events']:
        if 'ulFdSchedData' in tti_event:
            ul_results.append(tti_event['ulFdSchedData']['body']['mcsTable'])
        if 'dlFdSchedData' in tti_event:
            dl_results.append(tti_event['dlFdSchedData']['body']['mcsTable'])
    correct_qam_ul = ul_results.count('QAM{}'.format(expected_modulation))
    correct_qam_dl = dl_results.count('QAM{}'.format(expected_modulation))
    if traffic_type == 'uldl':
        if not ul_results:
            print('No mcsTable in ulFdSchedData for {} traffic'.format(traffic_type))
            return False
        if not dl_results:
            print('No ulFdSchedData in dlFdSchedData for {} traffic'.format(traffic_type))
            return False
        qam_ul = (correct_qam_ul / len(ul_results)) * 100
        qam_dl = (correct_qam_dl / len(dl_results)) * 100
        print('qam_ul: {}%, qam_dl: {}%, should be >= threshold: {}%'.format(qam_ul, qam_dl, threshold))
        return qam_ul >= int(threshold) and qam_dl >= int(threshold)
    if traffic_type == 'ul':
        if not ul_results:
            print('No mcsTable in ulFdSchedData for {} traffic'.format(traffic_type))
            return False
        qam_ul = (correct_qam_ul / len(ul_results)) * 100
        print('qam_ul: {}%, should be >= threshold: {}%'.format(qam_ul, threshold))
        return qam_ul >= int(threshold)
    if traffic_type == 'dl':
        if not dl_results:
            print('No ulFdSchedData in dlFdSchedData for {} traffic'.format(traffic_type))
            return False
        qam_dl = (correct_qam_dl / len(dl_results)) * 100
        print('qam_dl: {}%, should be >= threshold: {}%'.format(qam_dl, threshold))
        return qam_dl >= int(threshold)


def check_prb_json(actDlMuMimo=False, numOfUEs=1):
    tti_content = read_json_tti()
    rntis, numOfPRBs, startPrbs = [], [], []
    count, startprb = {}, {}
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rnti = tti_event['dlFdSchedData']['body']['eventHeader']['rnti']
            if rnti not in rntis:
                rntis.append(rnti)
            count[rnti] = count.get(rnti, 0) + 1
    sorted_count = sorted(count.items(), key=lambda x: x[1], reverse=True)
    print("Counted found RNTIs: ", sorted_count)
    used_rntis = [rnti[0] for rnti in sorted_count[:numOfUEs]]
    print("used_rntis: ", used_rntis)
    zero_prb = 0
    prbs_count = 0
    for tti_event in tti_content['events']:
        for rnti in used_rntis:
            if 'dlFdSchedData' in tti_event:
                if rnti == tti_event['dlFdSchedData']['body']['eventHeader']['rnti']:
                    start_prb = tti_event['dlFdSchedData']['body']['startPrb']
                    if 'startPrb' in tti_event['dlFdSchedData']['body']:
                        prbs_count += 1
                    if tti_event['dlFdSchedData']['body']['startPrb'] == 0:
                        zero_prb += 1
                    if tti_event['dlFdSchedData']['body']['numOfPrb'] not in numOfPRBs:
                        numOfPRBs.append(tti_event['dlFdSchedData']['body']['numOfPrb'])
                    if start_prb not in startPrbs:
                        startPrbs.append(start_prb)
                    startprb[start_prb] = startprb.get(start_prb, 0) + 1
    print("numOfPRBs: ", numOfPRBs)
    print("startPrbs:", startPrbs)
    print("startPrbs 0 count: ", zero_prb)
    print("startPrbs all count: ", prbs_count)
    sorted_startprb = sorted(startprb.items(), key=lambda x: x[1], reverse=True)
    print("sorted_startprb: ", sorted_startprb)
    if actDlMuMimo:
        assert zero_prb/prbs_count * 100 >= 98, f"StartPrb 0 need to be present in at least 98% of messages, " \
                                                f"actDlMuMimo set to {actDlMuMimo}: {startPrbs}"
    else:
        assert len(numOfPRBs) > 1, f"numOfPRBs has the same value for slots and actDlMuMimo set to {actDlMuMimo}"
        assert len(startPrbs) > 1, f"startPrb has the same value for slots and actDlMuMimo set to {actDlMuMimo}"
    return True


def check_muMimoSchedData_exist(should_exist):
    tti_content = read_json_tti()
    for tti_event in tti_content['events']:
        if 'muMimoSchedData' in tti_event:
            return True if should_exist else False
    return False if should_exist else True


def check_ue_paired():
    rntis = []
    count = {}
    tti_content = read_json_tti()
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rnti = tti_event['dlFdSchedData']['body']['eventHeader']['rnti']
            if rnti not in rntis:
                rntis.append(rnti)
            count[rnti] = count.get(rnti, 0) + 1
    sorted_count = sorted(count.items(), key=lambda x: x[1], reverse=True)
    print("Counted found RNTIs: ", sorted_count)
    used_rntis = [rnti[0] for rnti in sorted_count[:2]]
    tti_content = read_json_tti()
    for tti_event in tti_content['events']:
        for rnti in used_rntis:
            if 'muMimoSchedData' in tti_event:
                if rnti == tti_event['muMimoSchedData']['body']['eventHeader']['rnti']:
                    status = tti_event['muMimoSchedData']['body']['status']
                    assert status == "PAIRED", f"UE {rnti} not paired, status: {status}"
    return True


def check_beamId_for_rntis():
    tti_content = read_json_tti()
    rntis = {}
    for tti_event in tti_content['events']:
        if 'muMimoSchedData' in tti_event:
            if tti_event['muMimoSchedData']['body']['eventHeader']['rnti'] not in rntis:
                rntis[tti_event['muMimoSchedData']['body']['eventHeader']['rnti']] = \
                    tti_event['muMimoSchedData']['body']['beamId']
    if len(rntis.keys()) > 1:
        if all(rntis[key] == list(rntis.values())[0] for key in rntis):
            print("BeamID the same for rntis, should be different")
            return False
    else:
        print(f"Only {len(rntis.keys())} rnti found!")
        return False
    return True


def check_rach_based_on_ttitrace_json(decoded_output_file):
    tti_content = read_json_tti(decoded_output_file=decoded_output_file)
    rach_results = set()
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            rach_results.add(tti_event['dlFdSchedData']['body']['dciFormat'])
    print(rach_results)
    result = 'DL_10_MSG4' in rach_results
    if result:
        return True
    else:
        print('No dlFdSchedData.dciFormat equal to DL_10_MSG4 in TTI .json '
              'MSG4 not found. Rach verification fail')
        return False


def check_beam_pattern_based_on_ttitrace_json(beam_template_path, decoded_output_file, lower_treshold, higher_treshold):
    def _check_beam_pattern_exists(*args):
        for arg in args:
            if not arg:
                raise Exception("Lack of dlSrsBmBestBeamPatternId or dlSrsBmPairBeams2ndPatternId"
                                " or ulSrsBmBestBeamPatternId or ulSrsBm2ndBestBeamPatternId")

    def _get_azimuth_angle(beam_template_data, pattern_counts):
        for row in beam_template_data:
            for k, v in pattern_counts.items():
                if str(k) == row['PatternID']:
                    v['azimuthAngle'] = row['azimuthAngle']
        return pattern_counts

    def _get_max_pattern_id(pattern_counts):
        return max(pattern_counts,
                   key=lambda x: pattern_counts[x]['amount'])

    def _assert_pattern_in_range(max_pattern, pattern_counts, lower_treshold, higher_treshold, message):
        try:
            expected_azimuth_angle = float(pattern_counts[max_pattern]['azimuthAngle'])
        except KeyError:
            raise Exception(f"Lack of azimuthAngle for beam PatternID {max_pattern}")
        assert int(lower_treshold) <= expected_azimuth_angle <= int(higher_treshold), \
            f"{message} Azimuth angle for beam PatternID {max_pattern} " \
            f"is not between {lower_treshold} and {higher_treshold}: is {expected_azimuth_angle}"

    # collect PatternIDs from TTIs
    tti_content = read_json_tti(decoded_output_file=decoded_output_file)
    dft_beam_start_pattern_id = None
    dlSrsBmBestBeamPatternId_counts = {}
    dlSrsBmPairBeams2ndPatternId_counts = {}
    ulSrsBmBestBeamPatternId_counts = {}
    ulSrsBm2ndBestBeamPatternId_counts = {}

    for tti_event in tti_content['events']:
        if 'dlBeamData' in tti_event:
            dl_best_pattern_id = tti_event['dlBeamData']['body']['dlSrsBmBestBeamPatternId']
            dl_second_best_pattern_id = tti_event['dlBeamData']['body']['dlSrsBmPairBeams2ndPatternId']
            if dl_best_pattern_id not in dlSrsBmBestBeamPatternId_counts:
                dlSrsBmBestBeamPatternId_counts[dl_best_pattern_id] = {'amount': 0}
            if dl_second_best_pattern_id not in dlSrsBmPairBeams2ndPatternId_counts:
                dlSrsBmPairBeams2ndPatternId_counts[dl_second_best_pattern_id] = {'amount': 0}
            dlSrsBmBestBeamPatternId_counts[dl_best_pattern_id]['amount'] += 1
            dlSrsBmPairBeams2ndPatternId_counts[dl_second_best_pattern_id]['amount'] += 1
            if dft_beam_start_pattern_id is None:
                dft_beam_start_pattern_id = tti_event['dlBeamData']['body']['dftBeamStartPatternId']
        if 'ulBeamData' in tti_event or 'ulSrsBeamData' in tti_event:
            body = tti_event['ulBeamData']['body'] if 'ulBeamData' in tti_event else tti_event['ulSrsBeamData']['body']
            try:
                ul_best_pattern_id = body['ulSrsBmBestBeamPatternId']
                ul_second_best_pattern_id = body['ulSrsBm2ndBestBeamPatternId']
            except KeyError:
                continue
            if ul_best_pattern_id not in ulSrsBmBestBeamPatternId_counts:
                ulSrsBmBestBeamPatternId_counts[ul_best_pattern_id] = {'amount': 0}
            if ul_second_best_pattern_id not in ulSrsBm2ndBestBeamPatternId_counts:
                ulSrsBm2ndBestBeamPatternId_counts[ul_second_best_pattern_id] = {'amount': 0}
            ulSrsBmBestBeamPatternId_counts[ul_best_pattern_id]['amount'] += 1
            ulSrsBm2ndBestBeamPatternId_counts[ul_second_best_pattern_id]['amount'] += 1
    _check_beam_pattern_exists(dlSrsBmBestBeamPatternId_counts, dlSrsBmPairBeams2ndPatternId_counts,
                               ulSrsBmBestBeamPatternId_counts, ulSrsBm2ndBestBeamPatternId_counts)

    # read template content
    template_file = f"DFTBeam_dftBeamStartPatternId_{dft_beam_start_pattern_id}.csv"
    template_file_path = f"{beam_template_path}/{template_file}"
    beam_template_data = []
    with open(template_file_path, mode="r", newline="") as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            beam_template_data.append(row)

    # get azimuthAngle for every pattern ID from TTI
    dlSrsBmBestBeamPatternId_counts = _get_azimuth_angle(beam_template_data, dlSrsBmBestBeamPatternId_counts)
    ulSrsBmBestBeamPatternId_counts = _get_azimuth_angle(beam_template_data, ulSrsBmBestBeamPatternId_counts)
    dlSrsBmPairBeams2ndPatternId_counts = _get_azimuth_angle(beam_template_data, dlSrsBmPairBeams2ndPatternId_counts)
    ulSrsBm2ndBestBeamPatternId_counts = _get_azimuth_angle(beam_template_data, ulSrsBm2ndBestBeamPatternId_counts)

    print('dlSrsBmBestBeamPatternId results', dlSrsBmBestBeamPatternId_counts)
    print('ulSrsBmBestBeamPatternId results', ulSrsBmBestBeamPatternId_counts)
    print('dlSrsBmPairBeams2ndPatternId results', dlSrsBmPairBeams2ndPatternId_counts)
    print('ulSrsBm2ndBestBeamPatternId results', ulSrsBm2ndBestBeamPatternId_counts)

    max_dlSrsBmBestBeamPatternId = _get_max_pattern_id(dlSrsBmBestBeamPatternId_counts)
    max_ulSrsBmBestBeamPatternId = _get_max_pattern_id(ulSrsBmBestBeamPatternId_counts)
    max_dlSrsBmPairBeams2ndPatternId = _get_max_pattern_id(dlSrsBmPairBeams2ndPatternId_counts)
    max_ulSrsBm2ndBestBeamPatternId = _get_max_pattern_id(ulSrsBm2ndBestBeamPatternId_counts)

    # check if angles from beam teamplate for Patterns from TTI are in defined range
    _assert_pattern_in_range(max_dlSrsBmBestBeamPatternId, dlSrsBmBestBeamPatternId_counts, lower_treshold,
                             higher_treshold, 'dlSrsBmBestBeamPatternId')
    _assert_pattern_in_range(max_ulSrsBmBestBeamPatternId, ulSrsBmBestBeamPatternId_counts, lower_treshold,
                             higher_treshold, 'ulSrsBmBestBeamPatternId')
    _assert_pattern_in_range(max_dlSrsBmPairBeams2ndPatternId, dlSrsBmPairBeams2ndPatternId_counts, lower_treshold,
                             higher_treshold, 'dlSrsBmPairBeams2ndPatternId')
    _assert_pattern_in_range(max_ulSrsBm2ndBestBeamPatternId, ulSrsBm2ndBestBeamPatternId_counts, lower_treshold,
                             higher_treshold, 'ulSrsBm2ndBestBeamPatternId')
    return True


def check_dlfdscheddata_mupair_exist_in_ttitrace(decoded_output_file):
    tti_content = read_json_tti(decoded_output_file=decoded_output_file)

    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            if tti_event['dlFdSchedData']['body']['muStatus'] == 'MUPAIR':
                return True
    return False


def check_selected_BeamId_tti(best=33, second=25):
    tti_content = read_json_tti()
    best_list, second_list = [], []
    for tti_event in tti_content['events']:
        if 'dlBeamData' in tti_event:
            if tti_event['dlBeamData']['body']['selectedBestBeamId'] == best:
                best_list.append(tti_event['dlBeamData']['body']['selectedBestBeamId'])
            if tti_event['dlBeamData']['body']['selected2ndBeamId'] == second:
                second_list.append(tti_event['dlBeamData']['body']['selected2ndBeamId'])
    print("selectedBestBeamId: ", best_list)
    print("selected2ndBeamId: ", second_list)
    assert len(best_list) > 1, f"wrong selectedBestBeamId {best_list}"
    assert len(second_list) > 1, f"wrong selected2ndBeamId {second_list}"
    return True


def check_ulSrsBm_tti():
    tti_content = read_json_tti()
    is_beam_pattern = False
    for tti_event in tti_content['events']:
        if 'ulBeamData' in tti_event:
            body = tti_event['ulBeamData']['body']
            try:
                assert body['ulSrsBmBestBeamPatternId'], f"ulSrsBmBestBeamPatternId is empty"
                assert body['ulSrsBm2ndBestBeamPatternId'], f"ulSrsBm2ndBestBeamPatternId is empty"
                assert body['ulSrsBm3rdBestBeamPatternId'], f"ulSrsBm3rdBestBeamPatternId is empty"
                assert body['ulSrsBm4thBestBeamPatternId'], f"ulSrsBm4thBestBeamPatternId is empty"
                is_beam_pattern = True
            except KeyError:
                continue
        if 'ulSrsBeamData' in tti_event:
            body = tti_event['ulSrsBeamData']['body']
            try:
                assert body['ulSrsBmBestBeamPatternId'], f"ulSrsBmBestBeamPatternId is empty"
                assert body['ulSrsBm2ndBestBeamPatternId'], f"ulSrsBm2ndBestBeamPatternId is empty"
                assert body['ulSrsBm3rdBestBeamPatternId'], f"ulSrsBm3rdBestBeamPatternId is empty"
                assert body['ulSrsBm4thBestBeamPatternId'], f"ulSrsBm4thBestBeamPatternId is empty"
                is_beam_pattern = True
            except KeyError:
                continue
    return is_beam_pattern


def check_beamType_tti():
    tti_content = read_json_tti()
    for tti_event in tti_content['events']:
        if 'dlFdSchedData' in tti_event:
            body = tti_event['dlFdSchedData']['body']
            assert body['beamType'] == 'PMI', f"beamType is not equal PMI, beamType={body['beamType']}"
    return True
