# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Filip Tuznik"
__email__ = "filip.tuznik@nokia.com"

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
    addr="10.42.60.101", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8220-1",
)
_pdu_2 = Gude(
    addr="10.42.199.250", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8221-1",
)
_pdu_3 = Gude(
    addr="10.42.60.102", 
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 
    model="EPC", 
    version="8220-1",
)

_pdu_4 = FPFH(
    addr="10.42.80.196",
    port_numbers=[1, 2, 3, 4, 5, 6],
    login="admin",
    password="admin",
    )

_attenuator = TopYoung(
    ip_addr="10.42.60.141",
    port=3001,
    attenuation_port_numbers=[10, 11, 12, 13, 14, 17, 18, 19, 20, 21, 22],    
    model="TAS_24T24_02G6_90_1S_EJS",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDA",
    serial_number="K9182817713",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
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
    radio_type="AHMA",
    serial_number="4H182630000",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[3],
    attenuation_ports=[
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[22],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHEC",
    serial_number="6Q181017442",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
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
    serial_number="1M163503246",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.127", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_2T2R_Reno",
    radio_type="FHEF",
    serial_number="L6144123061",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.126", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[7],
    attenuation_ports=[
        _attenuator.attenuator_ports[10],
    ],
)

_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AEQQ",
    serial_number="1M224104496",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.30", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type="AENB",
    serial_number="1M214107266",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.34", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173708092",
    rus=[_rmod_4],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214608298",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204305856",
    rus=[_rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH214543994",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.183.35"),
    instance_id=8085,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.25", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_xiaomi12.yaml")
) as ue_config:
    import yaml

    ue_askey = yaml.load(ue_config, yaml.SafeLoader)

_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.42.60.77",
                               user="syslab",
                               password="system",
                               bind_interface_ip="10.42.129.2")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="bcee3519",
    ue_pc_address="10.42.199.116",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.199.116",
        username="labadmin",
        password="ZAQ!2wsxCDE#",
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
    capabilities =["XIAOMI12"],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_NLW_1ASIB_1ABIN_1ABIO_1ABIA_1AHPMDA_1AHMA_1AHEC_1FXCB_1FHEF_1AEQQ_1AENB_UTECA",
    pdus=_pdus,
    attenuator=[_attenuator],
)


__all__ = ["tl"]
