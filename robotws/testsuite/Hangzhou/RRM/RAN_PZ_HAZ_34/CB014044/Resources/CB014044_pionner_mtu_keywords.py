import taf.ue.pioneer.client as pioneer
from typing import List


def open_pioneer_client(until_timeout=10, service='pioneer'):
    state = pioneer.startup(until_timeout=until_timeout, service=service)
    if state['State'] != 0:
        print('open failed. retry again!')
        close_pioneer_client(until_timeout=until_timeout, service=service)
        pioneer.startup(until_timeout=until_timeout, service=service)
    else:
        print('open success!')


def close_pioneer_client(until_timeout=10, service='pioneer'):
    state = pioneer.shutdown(until_timeout=until_timeout, service=service)
    if state['State'] == 0:
        print('close success!')


def prepare_ues(host, ssh_username, ssh_password, alias='pioneer', port=30999,
                until_timeout=600):
    pioneer.setup_service(host=host,
                          port=port,
                          ssh_username=ssh_username,
                          ssh_password=ssh_password,
                          alias=alias)
    ues_info = pioneer.prepare_ues(service=alias)
    ues_imei = []
    for info in ues_info:
        if info['imei'] != 'ERROR':
            ues_imei.append(info['imei'])
    ue_group = []
    for index, imei in enumerate(ues_imei):
        pioneer.require_ue(imei=imei, service=alias, ue_alias=f"MTU{index}")
        ue_group.append(f"MTU{index}")
    for ue in ue_group:
        attach_status = pioneer.get_attach_status(until_timeout=until_timeout, ue=ue)
        if attach_status == 'Attached':
            pioneer.poweroff(until_timeout=until_timeout, ue=ue)


def start_ul_traffic_with_pioneer_client_for_different_throughput(ue_num,
                                                                  protocols: List[str],
                                                                  address: List[str],
                                                                  port: List[int],
                                                                  testtime: List[int],
                                                                  bandwidth: List[int],
                                                                  buffersize: List[int],
                                                                  packetsize: List[int],
                                                                  until_timeout,
                                                                  ue: List[str]):
    for i in range(ue_num):
        state = pioneer.startultraffic(protocols[i], address[i], port[i], testtime[i], bandwidth[i], buffersize[i],
                                       packetsize[i], until_timeout, ue[i])
        if state['State'] == 0:
            print(f"{ue[i]} make UL traffic success")
