import gc
import os
import re
import json
import datetime
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.logs as logs
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.rrm_fixture as fixture
from robot.libraries.Collections import Collections
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.pcap_verification.tsharkWithLuaVerifier \
    import TSharkCommandAssembler
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.pcap_verification.message_to_tree \
    import message_to_tree
from testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.preconditions_py import mrbts_id, \
    nrbts_id, bts_prefix
from robot.api import logger
from taf.sbts.oam.coam.admin import admin

coam = admin()
parameters = ['dlFlowControlAlgo*', 'dataSplitGainT*', 'dlDataSplitMode*',
              'dddsPeriod*', 'minThFlowCtrl*', 'maxTransferDelay*']
parameters_after23R2 = ['dataSplitGainT*', 'dlDataSplitMode*',
                        'dddsPeriod*', 'minThFlowCtrl*', 'maxTransferDelay*']
parameter_filter = ['BearerSetupReq*', 'scgSplitBearerParams*', 'scgSplitBearerParams*',
                    'x*UFlowControlParams*', 'x*UFlowControlParams*', 'x*UFlowControlParams*']
parameter_filter_after22R3 = ['*BearerSetupReq*', 'scgSplitBearerParams*', 'scgSplitBearerParams*',
                              'flowControlParams*', 'flowControlParams*', 'flowControlParams*']
parameter_filter_after23R2 = ['splitBearerParams*', 'splitBearerParams*',
                              'secondaryPathParams*', 'secondaryPathParams*', 'secondaryPathParams*']
path = os.getcwd()
nsaDrbParam_list_elements = {
    'actPrioritizeX2AfterInactivity': 'true',
    'actX2DuplicateTxNSA3x': 'false',
    'dlDataSplitBufferBuildUpThreshold': 5,
    'dlDataSplitBufferBuildUpThresholdPrioritizeX2': 5,
    'dlDataSplitGainThreshold': 5,
    'inactivityThresholdForPrioritizeX2': 300,
    'inactivityThresholdForRestartPrioritizeX2': 100,
    'initialDLTrafficRouting': 'initDLoverX2U',
    'nsa3xBearerAllowed': 'true',
    'prioritizeX2Period': 500,
    'reTxPrioritizationType': 'retxPrioSameLink',
}


def get_current_time():
    time = datetime.datetime.now().replace(microsecond=0)
    return time


def set_nsaDrbParam_list_elements():
    sw_release_name = logs.get_software_release_name()
    if sw_release_name == 'SBTS22R3' or sw_release_name == 'SBTS22R4':
        return nsaDrbParam_list_elements
    else:
        nsaDrbParam_list_elements['dlNumOfCongOrGainDdds'] = 2
        return nsaDrbParam_list_elements


def check_parameters_in_BearerSetupReq(log_path, dlFlowControlAlgo, dlDataSplitGainThreshold, dlDataSplitMode,
                                       dddsPeriodX2, minThFlowCtrlX2, maxTransferDelayX2, swVersion):
    filter = 'itf_l2_hi_cu_user_bearersetupreq'
    parameter_value = [dlFlowControlAlgo,
                       dlDataSplitGainThreshold,
                       dlDataSplitMode,
                       dddsPeriodX2,
                       minThFlowCtrlX2,
                       maxTransferDelayX2]
    output = TSharkCommandAssembler()\
        .with_filter(filter) \
        .with_pcap_file(log_path) \
        .build()
    if 'SBTS22R1' in swVersion or 'SBTS22R2' in swVersion:
        parameter_filter_use = parameter_filter
    elif 'SBTS22R4' in swVersion:
        parameter_filter_use = parameter_filter_after22R3
    else:
        parameter_filter_use = parameter_filter_after23R2
        parameters = parameters_after23R2
        parameter_value = [dlDataSplitGainThreshold,
                           dlDataSplitMode,
                           dddsPeriodX2,
                           minThFlowCtrlX2,
                           maxTransferDelayX2]
    for i in range(len(parameters)):
        print("parameter_value[%d] = %s" % (i, parameter_value[i]))
        print("parameters[%d] = %s" % (i, parameters[i]))
        print("message_to_tree.find(parameters[%d]) = %s"
              % (i, message_to_tree(output).find(parameters[i])))
        print("parameter_filter_use[%d] = %s" % (i, parameter_filter_use[i]))
        print("filter = %s"
              % message_to_tree(output).find(parameters[i]).filter(parameter_filter_use[i]))
        print("first val = %s"
              % message_to_tree(output).find(parameters[i]).filter(parameter_filter_use[i]).first()['val'])
        r_1 = '.*' + parameter_value[i]
        assert re.match(r_1, message_to_tree(output).find(parameters[i]).
                        filter(parameter_filter_use[i]).first()['val']), \
            'Parameter {} is not correct, \n  expected= {}, \n  current= {}'.format(
                parameters[i][:-1], parameter_value[i],
                message_to_tree(output).find(parameters[i]).filter(parameter_filter_use[i]).first()['val'])


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": "update"
            }
        ]
    }
    return parameter_delta


def set_dlFlowControlAlgo_parameter_for_all_drbs(value):
    delta_list = []
    for drb_nr in range(14):
        distname = '{}/NRDRB-{}'.format(bts_prefix, str(drb_nr + 1))
        delta_list.append(create_delta(distname, 'dlFlowControlAlgo', value))
        delta = json.dumps(delta_list)
    coam.perform_delta_recommissioning(delta_file=delta)


def set_data_split_mode_parameter_for_all_drbs(dl_split, ul_split, ul_threshold, ul_split_not_capable_ue=''):
    delta_list = []
    list_elements = set_nsaDrbParam_list_elements()
    list_elements['dlDataSplitMode'] = dl_split
    list_elements['ulDataPath'] = ul_split
    list_elements['ulDataPathForUlSplitNotCapableUe'] = ul_split_not_capable_ue
    list_elements['ulDataSplitThreshold'] = ul_threshold
    for drb_nr in range(14):
        distname = '{}/NRDRB-{}'.format(bts_prefix, str(drb_nr + 1))
        delta_list.append(create_delta(distname, 'nsaDrbParam', [list_elements]))
        delta = json.dumps(delta_list)
    coam.perform_delta_recommissioning(delta_file=delta)


def check_qos_group(pcap_file):
    filter = 'x2ap.SgNBAdditionRequestAcknowledge_element'
    output = TSharkCommandAssembler()\
        .with_filter(filter) \
        .with_pcap_file(pcap_file) \
        .build()
    return message_to_tree(output).find('qCI').filter('mCG-E-RAB-Level-QoS-Parameters').first()['val']


def verify_traffic_volume_in_given_time_period(time_period, direction, counters_value, deviation):
    gc.collect()
    time_interval = int(fixture.get_robot_variable('${PM counter interval}'))
    tput_deviation = float(deviation.strip('%'))/100
    data_throughput = int(fixture.get_robot_variable('${tput}'))
    data_vol_f1 = float(counters_value[fixture.get_robot_variable('${vol_f1_counter_id}')][str(nrbts_id)])
    data_vol_x2 = float(counters_value[fixture.get_robot_variable('${vol_x2_counter_id}')][str(nrbts_id)])
    assert data_vol_x2 != 0, 'There is no traffic via x2 interface'
    if fixture.get_robot_variable('${dl_split}') == 'dlOverX2U' or \
            fixture.get_robot_variable('${ul_split}') == 'ulOverLte':
        assert data_vol_f1 == 0, 'There is traffic via f1u despite {} split traffic set to x2u only'.format(direction)
    # sum_of_data_volume in Mbits - counters values in kilobytes so recalculation is needed
    sum_of_data_volume = ((data_vol_f1 + data_vol_x2)/1000)*8
    defined_data_volume = data_throughput * time_interval
    data_volume_difference = int((abs(defined_data_volume - sum_of_data_volume)/defined_data_volume)*100)
    if defined_data_volume > sum_of_data_volume:
        assert abs(defined_data_volume - sum_of_data_volume) <= (defined_data_volume * tput_deviation), \
            'Difference between expected and measured {} data volume checked in {}. time period is {}%, more than ' \
            'set {} devation \n  Expected data volume: {}Gbits, \n  Current data volume: {}Gbits'.\
            format(direction.upper(), time_period, data_volume_difference, deviation, int(defined_data_volume / 1000),
                   int(sum_of_data_volume / 1000))


def verify_max_throughput_in_given_time_period(time_period, direction, counters_value, deviation):
    gc.collect()
    tput_deviation = float(deviation.strip('%')) / 100
    data_throughput = int(fixture.get_robot_variable('${tput}'))
    data_max_f1 = float(counters_value[fixture.get_robot_variable('${max_tput_f1_counter_id}')][str(nrbts_id)])
    data_max_x2 = float(counters_value[fixture.get_robot_variable('${max_tput_x2_counter_id}')][str(nrbts_id)])
    # sum_of_max_data in Mbits - counters values in byte so recalculation is needed
    sum_of_max_data = ((data_max_f1 + data_max_x2)/1000000)*8
    max_tput_difference = int((abs(data_throughput - sum_of_max_data)/data_throughput)*100)
    if data_throughput > sum_of_max_data:
        assert abs(data_throughput - sum_of_max_data) <= (data_throughput * tput_deviation), \
            'Difference between expected and measured {} maximum tput checked in {}. time period is {}%, more than ' \
            'set {} devation. \n  Expected max tput: {}Mbit/s \n  Current max tput: {}Mbit/s'.\
            format(direction.upper(), time_period, max_tput_difference, deviation, data_throughput,
                   int(sum_of_max_data))
    logger.info('{}: {} split traffic in {}. time period with {} devation is as expected. '
                '\n Traffic over 5G: {}Mbit/s, \n Traffic over 4G: {}Mbit/s'.
                format(get_current_time(), direction.upper(), time_period, deviation,
                       round((data_max_f1/1000000)*8, 1), round((data_max_x2/1000000)*8, 1)), also_console=True)


def check_gtp_packets(pcap_file, time_period):
    filter = 'nr_u.PDU.Type == 1'
    output = TSharkCommandAssembler() \
        .with_filter(filter) \
        .inject_additional_parameters('-T fields -e nr_u.PDU.Type') \
        .with_pcap_file(pcap_file) \
        .build()
    assert len(output) != 0, 'There is no DL Data Delivery Status messages in {}. measured time period'.format(
        time_period)


def get_file_for_Load(package):
    release, names = package.split("_", 1)
    if package.find("_9999_") >= 0:
        files = get_file_for_SBTS22R1_Load(package)
    else:
        files = get_file_for_SBTS21B_Load(package)
    return files


def get_file_for_SBTS21B_Load(package):
    os.chdir(path)
    release1, gnb, brand, packet, names = package.split("_", 4)
    release, num = package.split("_", 1)
    for i in range(0, 50):
        packet1 = packet.lstrip("0")
        packet = int(packet1) - i
        packet1 = "%06d" % packet
        packet = str(packet1)
        files = (
            release1
            + "_"
            + gnb
            + "_"
            + brand
            + "_"
            + packet
            + "_"
            + names
            + "_luashark.zip"
        )
        os.system(
            "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
            % (release, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def get_file_for_SBTS22R1_Load(package):
    os.chdir(path)
    release1, gnb, brand, packet, names = package.split("_", 4)
    release1 = release1.lstrip("SBTS")
    package = package.replace(release1, "00")
    release, num = package.split("_", 1)
    for i in range(0, 3):
        packet1 = packet.lstrip("0")
        packet = int(packet1) - i
        packet1 = "%06d" % packet
        packet = str(packet1)
        names = names.lstrip("0")
        for m in range(0, 15):
            if i == 0:
                name = int(names) - m
            else:
                name = 15 - m
            if name == 0:
                break
            name1 = "%06d" % name
            name1 = str(name1)
            files = (
                release
                + "_"
                + gnb
                + "_"
                + brand
                + "_"
                + packet
                + "_"
                + name1
                + "_luashark.zip"
            )
        os.system(
            "sudo wget https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/%s/%s"
            % (release, files)
        )
        file_path = os.path.join(path, files)
        if os.access(file_path, os.F_OK):
            return files
            break
    return "No Found"


def unzip_file(files):
    os.system("rm -rf /home/ute/luashark/*")
    os.chdir(path)
    os.system("mv %s /home/ute/luashark/" % files)
    os.chdir("/home/ute/luashark/")
    os.system("unzip *")
    os.chdir("/home/ute/")
    os.system("rm -rf %s" % files)
