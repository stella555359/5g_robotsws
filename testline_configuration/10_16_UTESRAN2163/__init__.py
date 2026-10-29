# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Filip Tuznik"
__email__ = "filip.tuznik@nokia.com"

import os
from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU 
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import Connection
from taf.config.testline.attenuator import TopYoung

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

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
    addr="10.42.199.249",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)
_pdu_4 = Gude(
    addr="10.42.199.248",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8221-1",
)

_attenuator = TopYoung(
    ip_addr="10.42.80.135",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],
    model="TAS_24T24_02G6_90_1S_EJS",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type="FXJC",
    serial_number="1M182517526",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
    ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRMF",
    serial_number="L1172015490",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHBCA",
    serial_number="BL1821M0017",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
    attenuation_ports=[
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[22],
        _attenuator.attenuator_ports[23],
        _attenuator.attenuator_ports[24],
    ],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHED",
    serial_number="EA201350053",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
    attenuation_ports=[
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[20],
    ],
)
_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHCA",
    serial_number="1M193311876",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
    attenuation_ports=[
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[16],
    ],
)
_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHDB",
    serial_number="6Q182106746",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
    attenuation_ports=[
        _attenuator.attenuator_ports[2],
    ],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr7.1_64T64R_4D1L",
    radio_type="AVQL",
    serial_number="L1233302262",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
)
_rmod_8 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="K9220703786",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[6],
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
    ],
)
_rmod_9 = RU(
    ru_hw_group="FRMTDr5.1_1_4T4R",
    radio_type="AZNA",
    serial_number="EA204653818",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
    attenuation_ports=[],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805363",
	rus=[_rmod_1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173805313",
	rus=[_rmod_2, _rmod_9],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIL",
    hardware_version="474020A.102",
    serial_number="L1185109746",
	rus=[_rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.32",
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204214723",
	rus=[_rmod_3, _rmod_6],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173824797",
	rus=[_rmod_2, _rmod_4],
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508206",
	rus=[_rmod_7, _rmod_8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1222904288",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1222905879",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_5, _rmod_9],
    oam_ip=NetworkAddress("10.42.183.27"),
    instance_id=8070,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_2, _rmod_3, _rmod_4, _rmod_6, _rmod_7, _rmod_8], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.208", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.209", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4]

_rnc = RNC(
    rnc_id=36,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)
_bsc = BSC(
    name="BSC_mcBSC33",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.44.146.2", username="SYSTEM", password="SYSTEM"
    ),
)



# ---------------- START TAF_UE_PROXY UEs ----------------

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.44.184.246",
                               user="syslab",
                               password="Pass4System!",
                               bind_interface_ip="10.44.184.246")

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 version=3)

_android_1 = TafUeAndroid(
    serial_number="HZQN1876AAKA2800515",
    ue_pc_address="10.42.199.110",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.199.110",
        username="labadmin",
        password="ZAQ!2wsxCDE#",
    ),
    ue_pc_port="9090",
    imsi="555106800098414",
    imei="353137111076496",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    #    airplane_mode_switcher_text ="",
    #    airplane_mode_confirm_button_text ="",
    #    path_to_network_mode_type ="",
    is_rooted="no",
    secret_code='*#*#4636#*#*',
    capabilities=["NOKIA83"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_NLWG_2ASIB_3ABIA_1ABIL_1ABIN_1ABIO_1FXJC_1FRMF_1AHBCA_1AHED_1AHCA_1AHDB_1AVQL_1AHEC_UTECA",
	pdus=_pdus,
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android_1],
    attenuator=[_attenuator],
)

__all__ = ["tl"]
