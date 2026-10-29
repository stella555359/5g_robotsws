# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Valentin Suru"
__email__ = "valentin.suru@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, FPFH
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline import Connection
from taf.config.testline.attenuator import TopYoung

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc


_pdu_1 = Gude(
    addr="10.255.1.124", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.1.125", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8221-1",
)
_pdu_3 = FPFH(
    addr="10.255.1.165",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    )

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_attenuator = TopYoung(
    ip_addr="10.42.60.141",
    port=3001,
    attenuation_port_numbers=[10, 11, 12, 13, 14, 17, 18, 19, 20, 21, 22],    
    model="TAS_24T24_02G6_90_1S_EJS",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDA",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
    attenuation_ports=[
        _attenuator.attenuator_ports[17],
        _attenuator.attenuator_ports[18],
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[20],
    ],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHCA",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[22],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHEC",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
    ],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXCB",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type="FHEL",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.10.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
    attenuation_ports=[
        _attenuator.attenuator_ports[10],
    ],
)

_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AEQQ",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.30", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[2],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AENB",
    serial_number="10.255.1.165",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.34", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA194854734",
    rus=[_rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="DH234521671",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213709062",
    rus=[_rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH220472134",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.15.236.216"),
    instance_id=10816,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.226", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.71",
                               user="ftp_user1",
                               password="Aikon_1234@#",
                               bind_interface_ip="10.5.26.71")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="bcee3519",
    ue_pc_address="10.5.29.151",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.5.29.151",
        username="wcdmata",
        password="Aikon_123456*8",
    ),
    ue_pc_port="9090",
    imsi="555109900000962",
    imei="860978050326152",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["NOKIA83"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_NLW_10816_1ASIB_1ABIN_1ABIO_1ABIA_1AHPMDA_1AHCA_1AHEC_1FXCB_1FHEL_1AEQQ_1AENB",
    pdus=_pdus,
    attenuator=[_attenuator],
)


__all__ = ["tl"]
