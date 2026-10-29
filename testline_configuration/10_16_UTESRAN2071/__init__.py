# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Filip Tuznik"
__email__ = "filip.tuznik@nokia.com"

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
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


_pdu_1 = Gude(
    addr="10.42.80.241",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)


_attenuator = TopYoung(
	    ip_addr="10.42.60.143",
	    port=3001,
	    attenuation_port_numbers=[13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24],    
    model="TAS_24T24_02G6_90_1S_EJS",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.2_3T6R",
    radio_type="FXEF",
    serial_number="EA164111135",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.202", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
    attenuation_ports=[
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[17],
    ],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.2_3T6R",
    radio_type="FXEF",
    serial_number="EA164111126",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.203", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
    attenuation_ports=[
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[16],
        _attenuator.attenuator_ports[18],
    ],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRMD",
    serial_number="RY131214439",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
    attenuation_ports=[
        _attenuator.attenuator_ports[19],
        _attenuator.attenuator_ports[21],
        _attenuator.attenuator_ports[23],
    ],
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.1_3T6R",
    radio_type="FRMD",
    serial_number="RY131205041",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.208", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
    attenuation_ports=[
        _attenuator.attenuator_ports[20],
        _attenuator.attenuator_ports[22],
        _attenuator.attenuator_ports[24],
    ],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1164817850",
	rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIA",
    hardware_version="A.202",
    serial_number="L1165001809",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4],
    oam_ip=NetworkAddress("10.42.183.92"),
    instance_id=101035,
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.156", username="ute"), 
    connections=[
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
_pdus = [_pdu_1]


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
    serial_number="e34b65b0",
    ue_pc_address="10.42.199.118",
    data_transfer=[_data_transfer_iperf],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.199.118",
        username="labadmin",
        password="ZAQ!2wsxCDE#",
    ),
    ue_pc_port="9090",
    imsi="555109900000963",
    imei="861949041138112",
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
#    airplane_mode_switcher_text ="",
#    airplane_mode_confirm_button_text ="",
#    path_to_network_mode_type ="",
    is_rooted ="no",
    secret_code ='*#*#4636#*#*',
    capabilities =["OP6_LTE"],
)

# ---------------- STOP TAF_UE_PROXY UEs -----------------

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_1ABIA_2FXEF_2FRMD_UTECA",
    attenuator=[_attenuator],
    pdus=_pdus,
)

__all__ = ["tl"]
