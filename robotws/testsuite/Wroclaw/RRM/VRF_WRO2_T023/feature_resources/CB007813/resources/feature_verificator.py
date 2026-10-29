import re
from robot.api import logger
import paramiko


def verify_CB007813(log_file):
    """
    Function performing file analysis of RRC Logs
    Its searching for specific stings in files: HANDOVER
    Then in next message looking for result of HO: SUCCESS
    :param log_file: path to QCAT converted txt RRC logs.
    :return (bool):  True if feature was validated with success, False if not.
    """
    validator = 0
    split_pattern = r'([01]?[0-9]|2[0-3]):[0-5][0-9]{1,2}'
    with open(log_file, 'r') as file_log:
        file_log_data = file_log.read()
    file_log_data_list = re.split(split_pattern, file_log_data)
    for record in file_log_data_list:
        if record.find('HANDOVER') != -1:
            logger.info('\n' + str(record) + '\n', html=True, also_console=True)
            if file_log_data_list[file_log_data_list.index(record)+2].find('RACH Result = SUCCESS'):
                second_msg = file_log_data_list[file_log_data_list.index(record) + 2]
                logger.info('\n' + str(second_msg) + '\n', html=True, also_console=True)
                validator += 1
    if validator >= 2:
        return True
    return False


def count_message_occurrence(remote_ip, remote_username, remote_pass, pcap_file, filter):
    """
    Function counting message occurrence in pcap files located on remote Windows host.
    :param remote_ip: IP of Windows remote Wireshark host.
    :param remote_username: Username of Windows remote Wireshark host.
    :param remote_pass: Password of Windows remote Wireshark host.
    :param pcap_file: Path to pcap file on Windows remote Wireshark host.
    :param filter: Wireshark filter for messages.
    """
    tshark_path = "/cygdrive/c/Program\\ Files/Wireshark/tshark.exe -r '{}' -Y '{}' | wc -l"
    cmd = tshark_path.format(str(pcap_file), str(filter))
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(remote_ip, username=remote_username, password=remote_pass)
        _stdin, _stdout, _stderr = client.exec_command(cmd)
        return int(_stdout.read().decode())
    except paramiko.SSHException:
        raise paramiko.SSHException("cant connect to UE PC")
    finally:
        client.close()


def get_field_values_with_filter(remote_ip, remote_username, remote_pass, pcap_file, filter, field):
    """
    Function getting value for message field in pcap files located on remote Windows host.
    :param remote_ip: IP of Windows remote Wireshark host.
    :param remote_username: Username of Windows remote Wireshark host.
    :param remote_pass: Password of Windows remote Wireshark host.
    :param pcap_file: Path to pcap file on Windows remote Wireshark host.
    :param filter: Wireshark filter for packets.
    :param field: Packet field with value we are interested.
    :return binary_numbers: returns binary format value with fixed length: 32.
    """
    tshark_path = '/cygdrive/c/Program\\ Files/Wireshark/tshark.exe -r "{}" -Y "{}" -T fields -e "{}"'
    cmd = tshark_path.format(str(pcap_file), str(filter), str(field))
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(remote_ip, username=remote_username, password=remote_pass)
        _stdin, _stdout, _stderr = client.exec_command(cmd)
        set_of_different_values = set(_stdout.readlines())
    except paramiko.SSHException:
        raise paramiko.SSHException("cant connect to UE PC")
    finally:
        client.close()
    set_of_different_values = [x.rstrip('\r\n') for x in set_of_different_values]
    binary_numbers = ['{0:032b}'.format(int(x)) for x in set_of_different_values]
    return binary_numbers
