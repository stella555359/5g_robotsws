import re
from random import randrange
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import get_tshark_output, \
    split_output_into_frames
from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword
from taf.transport.ssh import ssh


ssh = ssh()


class GenerateNextPort(object):
    def __init__(self):
        self._port_number = randrange(24000, 26000)

    def __call__(self):
        self._port_number += 1
        return self._port_number


GenerateNextPortObject = GenerateNextPort()


def generate_next_port():   # because robot
    return GenerateNextPortObject()


def extract_ue_ip_from_attach_output(attach_result_output):
    ip_pattern = r'(?<=IPv4 Address: )[0-9,.]*'
    match = re.search(ip_pattern, attach_result_output, re.DOTALL)
    assert match, "validation pattern not found in the script output"
    return match.group()


def get_script_path_dictionary(ue_dict):
    script_paths = {}
    for ue_alias, sub_dict in ue_dict.iteritems():
        script_path_dict = sub_dict['CONSTRUCTOR_PARAMETERS']['script_paths']
        script_paths[ue_alias] = {'rc_config': script_path_dict['radio_card_config'],
                                  'attach': script_path_dict['attach'],
                                  'detach': script_path_dict['detach']}
    return script_paths


def find_number_packets_with_filter(pcap_filter, pcap_file):
    try:
        return len(split_output_into_frames(get_tshark_output(pcap_file=pcap_file, lua_attached=True,
                                                              ts_filter=pcap_filter)))
    except AssertionError:
        return 0


def validate_number_of_PDU_sessions_in_pcap(pcap_file, target):
    pcap_filter = "ngap.TransportLayerAddressIPv4  && ngap.NGAP_PDU == 1"
    assert find_number_packets_with_filter(pcap_filter=pcap_filter, pcap_file=pcap_file) == int(target)


def validate_number_of_PDU_releases_in_pcap(pcap_file, target):
    pcap_filter = "ngap.PDUSessionResourceReleaseCommand_element"
    assert find_number_packets_with_filter(pcap_filter=pcap_filter, pcap_file=pcap_file) == int(target)


def median(numbers):
    n = len(numbers)
    numbers.sort()
    if n % 2 == 0:
        return (numbers[n // 2 - 1] + numbers[n // 2]) / 2.0
    else:
        return numbers[n // 2]


@logged_keyword
def verify_throughput_file(file_location, target="30M", tolerance=0.2):
    """Verify tput with given tolerance difference from target
    """

    tput_err = 'Tput is not stable in {0} - got median of {1}, expected {2}'
    with open(file_location) as file:
        if "M" in target:
            target = float(target.replace("M", ""))
        throughput_pattern = r"Bytes\s+(\d+.\d+)\s+Mbits/sec"
        match = re.findall(throughput_pattern, file.read())
        assert match, "throughput pattern not found in the iperf output"
        print(match)
        match = [float(t) for t in match]
        median_throughput = median(match)
        result = (1-tolerance) * target <= median_throughput <= (1+tolerance) * target
        assert result, tput_err.format(file_location, median_throughput, target*(1-tolerance))


# Static IPs for appserver routing
ips_for_route = ["10.42.197.170", "10.44.43.2", "10.44.43.17", "10.44.43.18", "10.44.43.19", "10.44.43.20",
                 "10.44.43.21", "10.44.43.22", "10.44.43.23", "10.44.43.24", "10.44.43.25", "10.44.43.26"]


@logged_keyword
def get_interfaces_from_ip_a_and_route(connection="appserver"):
    """finds pppX - PDU IP assignment using 'ip a' and assigns bind addresses, returns a PDU IP->bind dictionary
    """

    result = ssh.execute("ip a", connection=connection)
    fixture.log_message(message=result)
    # regex pattern that extracts number of ppp from `ip a` command output as
    # well as ip that is assinged to it.
    ppp_pattern = r"\n\d+: ppp(\d+):.+\n.+\n\s+inet (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})"
    matches = re.findall(ppp_pattern, result)
    ip_assignment = {}
    for match in matches:
        ppp_id = int(match[0])
        print(ssh.execute("route del {ip}".format(ip=ips_for_route[ppp_id]), connection=connection))
        print(ssh.execute("route add {ip} dev ppp{id}".format(ip=ips_for_route[ppp_id], id=ppp_id),
                          connection=connection))
        ip_assignment[match[1]] = ips_for_route[ppp_id]
    assert len(ip_assignment) > 0, "Couldn't find UE ip on appserver"
    return ip_assignment


@logged_keyword
def generate_iperf3_server(port, interval=1, tp_format="m", single=True, bind=None, log=None):
    """generates an ipertf3 server command with given parameters
    """

    command = "iperf3 -s -p {port}".format(port=port)
    if tp_format:
        command += " -f {tp_format}".format(tp_format=tp_format)
    if single:
        command += " -1"
    if bind:
        command += " -B {bind}".format(bind=bind)
    if log:
        command += "  --logfile {log}".format(log=log)
    if interval:
        command += "  -i {interval}".format(interval=interval)
    return command


@logged_keyword
def generate_iperf3_client(ip, port, bitrate, time, reverse=False, interval=1, tp_format="m", bind=None, log=None,
                           udp=False):
    """generates an ipertf3 client command with given parameters
    """

    command = "iperf3 -c {ip} -p {port} -t {time} -b {bitrate}".format(ip=ip, port=port, time=time, bitrate=bitrate)
    if tp_format:
        command += " -f {tp_format}".format(tp_format=tp_format)
    if bind:
        command += " -B {bind}".format(bind=bind)
    if log:
        command += "  --logfile {log}".format(log=log)
    if reverse:
        command += "  -R"
    if interval:
        command += "  -i {interval}".format(interval=interval)
    if udp:
        command += "  -u"
    return command
