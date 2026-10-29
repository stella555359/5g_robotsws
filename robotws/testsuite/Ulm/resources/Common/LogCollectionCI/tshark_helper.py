from subprocess import Popen, PIPE


def get_pcap_message_count(pcap_file):
    command = f"tshark -r {pcap_file} -Y bip_event_chaining"
    process = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    output, _ = process.communicate()
    lines = output.decode().splitlines()
    return len(lines)


def get_bip_event_chaining_message_count(pcap_file):
    command = f"tshark -r {pcap_file} -Y bip_event_chaining"
    process = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    output, _ = process.communicate()
    lines = output.decode().splitlines()
    return len(lines)


def get_uldata_prachreceivereq_message_count(pcap_file):
    command = f"tshark -r {pcap_file} -Y uldata_prachreceivereq"
    process = Popen(command, shell=True, stdout=PIPE, stderr=PIPE)
    output, _ = process.communicate()
    lines = output.decode().splitlines()
    return len(lines)
