import os
import robot.api.logger as logger
import ipaddress


def increase_ip_address(ip, value=1):
    return str(ipaddress.ip_address(ip)+value)


def get_nradjgnb_address():
    ips = [
        '10.44.91.57', '10.44.91.58',
        '10.44.84.13', '10.44.84.14',
        '2A00:8A00:6000:607C::5C18', '2A00:8A00:6000:607C::5C19',
        '2A00:8A00:6000:607C::1:650F', '2A00:8A00:6000:607C::1:650E'
    ]
    return ips


def get_robustness_addresses():
    return ['10.44.90.238', '2a00:8a00:6000:607c::1:c21d', '10.44.64.98', '2a00:8a00:6000:607c::784']


def get_servedamf_fake_addresses():
    return ['0.0.0.0', '1111:1111:1111:1111::1111', '2222:2222:2222:2222::2222']


def get_servedamf_addresses():
    return ['10.27.28.136', '10.94.232.6', '2a00:8a00:6000:607c::784', '2a00:8a00:6000:607c::781']


def get_ipv4_addresses_xncplane():
    ipv4 = ['10.44.90.238', '10.44.90.237']
    return ipv4


def get_ipv4_addresses_ngcplane():
    ipv4 = ['10.44.91.174', '10.44.91.173']
    return ipv4


def get_ipv6_addresses_xncplane():
    ipv6 = ['2a00:8a00:6000:607c::1:bf21', '2a00:8a00:6000:607c::1:bf22']
    return ipv6


def get_ipv6_addresses_ngcplane():
    ipv6 = ['2a00:8a00:6000:607c::1:c21d', '2a00:8a00:6000:607c::1:c21e']
    return ipv6


def get_all_ipv4_addresses():
    ips = list()
    ips.append(get_ipv4_addresses_xncplane())
    ips.append(get_ipv4_addresses_ngcplane())
    return ips


def get_all_ipv6_addresses():
    ips = list()
    ips.append(get_ipv6_addresses_xncplane())
    ips.append(get_ipv6_addresses_ngcplane())
    return ips


def remove_files(file_to_delete):
    os.remove(f'{file_to_delete}.txt')


def get_formatted_parameters(**kwargs):
    formatted_parameters = list()
    for key, value in kwargs.items():
        formatted_parameters.append({"parameterName": key,
                                     "operation": "update",
                                     "value": value})
    return formatted_parameters


def create_xnlink(address: str, index: int) -> dict:
    id_list = [1, 1, 2, 1, 2]
    xnlink = {
        'cPlaneIpAddr': address, 'cPlaneIpAddrCtrl': 'oamControlled',
        'xnLinkId': index + 1, 'xnTnlId': id_list[int(index)]
    }
    return get_formatted_parameters(**xnlink)


def create_amf_object(administrativeState: str, defaultAMF: str, amfIPAddress: str, ngTnlId: int):
    servedamf = {
        'administrativeState': administrativeState, 'defaultAMF': defaultAMF,
        'amfIPAddress': amfIPAddress, 'ngTnlId': ngTnlId
    }
    return get_formatted_parameters(**servedamf)


def create_nradjgnb_object(nradjgnb1_uPlaneIPAddrList: list):
    gnbPlmn_list = [244, 8, 2]
    nradjgnb_1_dict = {
        'administrativeState': 'Unlocked', 'gNbIdLength': 22, 'gnbPlmn': gnbPlmn_list,
        'gNodeBId': 50276, 'weightForIgnbCaSelection': 1, 'nrAdjGnbId': 1, 'xnLinkRef': 1,
        'xnLinkRef2': 3, 'uPlaneIpAddrList': nradjgnb1_uPlaneIPAddrList
    }
    return get_formatted_parameters(**nradjgnb_1_dict)


def change_servedamfs_fake_ips(bts_id: int):
    amf_addr = get_servedamf_fake_addresses()
    delta = list()
    index = 2
    for amf in amf_addr:
        obj = {
            'distName': f'MRBTS-{bts_id}/NRBTS-{bts_id}/SERVEDAMF-{index}',
            'operation': 'update',
            'parameters': [
                    {
                        'parameterName': 'amfIPAddress',
                        'operation': 'update',
                        'value': amf
                    }
                ]
            }
        delta.append(obj)
        index += 1
    return delta


def split_string_by_space(active_rules: str) -> list:
    return active_rules[0].split(' ')


def get_pcap_packets(pcap_file: str, tshark_filter: str) -> str:
    command = f"tshark -r {pcap_file} -Y '{tshark_filter}' 2>/dev/null | wc -l"
    output = os.popen(command).read()
    logger.info(output, html=True, also_console=True)
    return output
