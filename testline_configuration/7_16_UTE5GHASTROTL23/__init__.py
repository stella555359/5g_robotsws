import os
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.ue import MediaTek
from taf.config.testline.connection_details import (
    SshServiceDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.appserver import AppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.pdn import PDN, PDPTypes
from taf.config.testline.core import RealCore
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    TelnetConnectionDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb


__maintainer__ = "Tomasz Godlewski"
__team__ = "MN RAN RD VRF WRO2 4"
__email__ = "tomasz.1.godlewski@nokia.com"
__owner_email__ = "tomasz.1.godlewski@nokia.com"


_pdu1 = ATEN(addr="10.42.61.80", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu2 = Gude(
    addr="10.44.177.82",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_pdu4 = ATEN(addr="10.42.61.92", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu5 = ATEN(addr="10.44.206.106", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdus = [_pdu1, _pdu2, _pdu4, _pdu5]

_attenuator1 = TopYoung(
    ip_addr="10.42.221.176",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_attenuator2 = TopYoung(
    ip_addr="10.42.61.133",
    port=3001,
    attenuation_port_numbers=range(1, 13),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.85.86/26", v6=None, vlan_id=820),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(v4="10.44.76.75/26", v6=None, vlan_id=821),
    x2u=NetworkAddress(v4="10.44.76.138/26", v6=None, vlan_id=822),
    s1u=NetworkAddress(v4="10.44.76.230/26", v6=None, vlan_id=823),
    xnc=NetworkAddress(v4="10.44.76.75/26", v6=None, vlan_id=821),
    xnu=NetworkAddress(v4="10.44.76.138/26", v6=None, vlan_id=822),
    ngc=NetworkAddress(v4="10.44.84.250/26", v6=None, vlan_id=895),
    ngu=NetworkAddress(v4="10.44.76.230/26", v6=None, vlan_id=823),
)

_cu_gnb.m = NetworkAddress(v4="https://10.44.85.86", v6=None, vlan_id=820)


_rmod_1 = RU(
    ru_hw_group="",
    radio_type="AHFIB",
    serial_number="BL2215V0131",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator1.attenuator_ports[3],
        _attenuator1.attenuator_ports[4],
        _attenuator1.attenuator_ports[9],
        _attenuator1.attenuator_ports[10],
    ],
    pdu_port=_pdu2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="",
    radio_type="ARPA",
    serial_number="K9224924336",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator1.attenuator_ports[5],
        _attenuator1.attenuator_ports[6],
        _attenuator1.attenuator_ports[11],
        _attenuator1.attenuator_ports[12],
    ],
    pdu_port=_pdu1.pdu_ports[8],
)


_rmod_3 = RU(
    ru_hw_group="",
    radio_type="AZHL",
    serial_number="AH212500169",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator2.attenuator_ports[5],
        _attenuator2.attenuator_ports[6],
        _attenuator2.attenuator_ports[11],
        _attenuator2.attenuator_ports[12],
    ],
    pdu_port=_pdu2.pdu_ports[5],
)

_rmod_4 = RU(
    ru_hw_group="",
    radio_type="AEQK",
    serial_number="DH214200001",
    default_telnet_connection_details=TelnetConnectionDetails(addr=None, port=None),
    attenuation_ports=[
        _attenuator2.attenuator_ports[3],
        _attenuator2.attenuator_ports[4],
        _attenuator2.attenuator_ports[9],
        _attenuator2.attenuator_ports[10],
    ],
    pdu_port=_pdu5.pdu_ports[8],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211508220",
    rus=[_rmod_1],
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173643962",
    rus=[_rmod_2],
)

_bbmod_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="EA194457512",
    rus=[_rmod_2],
)

_bbmod_4 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1205002505",
    rus=None,
)

_bbmod_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400365",
    rus=[_rmod_3],
)

_bbmod_6 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400364",
    rus=[_rmod_4],
)

_smod_gnb_master_left = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2, _bbmod_3],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203903743",
)

_smod_gnb_slave_right = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_4, _bbmod_5, _bbmod_6],
    pdu_port=_pdu4.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1212007447",
)

_smod_1 = Airscale([_smod_gnb_master_left])

_smod_2 = Airscale([_smod_gnb_slave_right])

_du_1_gnb = DU(_smod_1, rus=[_rmod_1, _rmod_2])

_du_2_gnb = DU(_smod_2, rus=[_rmod_3, _rmod_4])


_cbts_1 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb], instance_id=50896, global_bts_id=50896
)

_lmp_vm_gnb_1_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.102", username="ute", password="ute"
    ),
    connections=[_cbts_1.dus[0].airscale.common_units[0]],
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb, dus=[_du_2_gnb], instance_id=50896, global_bts_id=50896
)

_lmp_vm_gnb_1_slave = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.77", username="ute", password="ute"
    ),
    connections=[_cbts_2.dus[0].airscale.common_units[0]],
)

_core = RealCore5G(mcc=310, mnc=260)

_nokia_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_proxy_config.yaml"
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1_master,
    test_pcs=[_lmp_vm_gnb_1_master, _lmp_vm_gnb_1_slave],
    gnbs=[_cbts_1, _cbts_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_HASTROTL23_FULLRACK_ASIB_ABIO_ABIA_ABIL_AHFIB_ARPA_AZHL_AEQK",
    core=_core,
    pdus=_pdus,
    ues=[_nokia_ue],
    attenuator=_attenuator1,
    attenuators=[_attenuator1, _attenuator2],
)

__all__ = ["tl"]
