import os
from robot.libraries.BuiltIn import BuiltIn
import taf.transport.ssh as ssh
from robot.api import logger
from robot.utils import asserts
from datetime import datetime, timedelta
from testsuite.Timisoara.L3.ET.L3_ET_TIM3.resourcesKRK.krk3_common.Python.VRanPmCountersExtension import \
    VRanPmCountersExtension
from ta5g_interface_tools import ta5g_interface_tools
from robot.libraries.XML import XML
from robot.libraries.String import String
import lxml.etree as et
import re


tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
vcu_master_details = tl.cloud_hostings[0].master_node.ssh_connection_details


def vran_cprt_log_collector(namespace, pod, container, output_dirpath=None):
    sshconn = ssh.ssh()
    try:
        sshconn.connect_to(
            hostname=vcu_master_details.addr,
            username=vcu_master_details.username,
            password=vcu_master_details.password
        )

        cprt_filename = "cprt_auto_{date}.log".format(date=datetime.now().strftime("%Y-%m-%dT%H:%M:%S"))
        msg_rc = sshconn.execute("kubectl logs -n {namespace} {pod} -c {container}>{cprt_filename}".format(
            namespace=namespace,
            pod=pod,
            container=container,
            cprt_filename=cprt_filename
        ))

        asserts.assert_equal(len(msg_rc), 0, msg="Log collection failed: {}".format(msg_rc))

        if output_dirpath is None:
            output_dirpath = ta5g_interface_tools().get_robot_output_dir()

        cprt_file_path = "{}/{}".format(output_dirpath, cprt_filename)

        sshconn.download_file(cprt_filename, cprt_file_path)

    finally:
        sshconn.disconnect()

    return cprt_file_path


def get_vran_oampm_cprt_log(output_dirpath):
    create_dir_if_doesnt_exist(output_dirpath)
    return vran_cprt_log_collector(
        namespace=tl.cloud_hostings[0].namespace,
        pod="ute-{}-oampm-0".format(tl.cloud_hostings[0].namespace),
        container="ctr-{}-oampm".format(tl.cloud_hostings[0].namespace),
        output_dirpath=output_dirpath
    )


def evaluate_m55320c18002_pm_value_from_cprt_log(output_dirpath, pm_xml_file_list, measurement_type):
    cprt_oampm_filepath = get_vran_oampm_cprt_log(output_dirpath)

    pm_xml_filepath = VRanPmCountersExtension.find_pm_file_by_distname(
        pm_xml_file_list,
        "PLMN-PLMN/MRBTS-1/NRBTS-1",
        measurement_type
    )[0]
    start_time = XML().get_element_attribute(pm_xml_filepath, 'startTime', xpath=".//PMSetup")
    start_time = datetime.strptime(start_time, "%Y-%m-%dT%H:%M:%S.%f+00:00")
    delta_time = int(XML().get_element_attribute(pm_xml_filepath, 'interval', xpath=".//PMSetup"))
    m55320c18002_val_dict = {'Values': [], 'Weight': [], 'Round': []}

    with open(cprt_oampm_filepath, 'r') as cprt_file:
        cprt_lines = cprt_file.readlines()
        for line in cprt_lines:
            if '[pm::Pm9Interface] M55125C00501(Average|' in line:
                splitted_line = line.split(" ")
                event_timestamp = datetime.strptime(splitted_line[10], "<%Y-%m-%dT%H:%M:%S.%fZ>")
                if start_time < event_timestamp < start_time + timedelta(minutes=delta_time):
                    # splitted_last_elem = ['M55320C18002', 'Average', 'Values', '0', 'in=0', 'was=0']
                    splitted_last_elem = list(filter(None, re.split("\\(|\\)=|\\||/|sum\\)=", splitted_line[-1])))
                    m55320c18002_val_dict[splitted_last_elem[2]].append(int(splitted_last_elem[3]))

        asserts.assert_true(
            all(len(item) == delta_time for item in m55320c18002_val_dict.values()),
            msg="Missing pm record in crpt log"
        )

        sum_of_values = sum(m55320c18002_val_dict['Values'])
        sum_of_weights = sum(m55320c18002_val_dict['Weight'])
        max_of_round = max(m55320c18002_val_dict['Round'])

        logger.debug("\nsamples: {}".format(m55320c18002_val_dict))
        logger.debug("\nsum of value samples: {}\n".format(sum_of_values))
        logger.debug("sum of weight samples: {}\n".format(sum_of_weights))
        logger.debug("max from samples: {}\n".format(max_of_round))

    return int((sum_of_values/sum_of_weights)+(max_of_round/2))


def get_sum_of_all_vnfcs_m55361c00001_values(filepaths_list):
    return int(sum([et.parse(filepath).xpath("sum(//M55361C00001)") for filepath in filepaths_list]))


def create_dir_if_doesnt_exist(dir_path):
    """
    Checks whether given directory exists and creates it if doesn't.

    :param dir_path: absolute path to directory which will be created
    :type dir_path: str
    """
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)


def measure_average_data_rate(ue_id, direction="ul"):
    try:
        wts_runner_inst = BuiltIn().get_library_instance('wtsrunner')
    except Exception as e:
        logger.console(
            "taf.wts.runner instance not exist, before execute please configure wts keywords in robot framework suite"
        )
    wts_runner_inst.qfi_stats(ue=ue_id, pdu="1", qfi="1", dir=direction)

    cmd_result = wts_runner_inst.read_wtsemu_output_until_re(expected="Last data rate", timeout="10")
    logger.console(" \n {}".format(cmd_result))
    average_rate = String().get_regexp_matches(cmd_result, "Average data rate\\s+(\\d+)", 1)
    return int(average_rate[0])
