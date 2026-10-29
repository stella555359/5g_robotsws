__maintainer__ = "Damian Matusiak"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_7@internal.nsn.com"
__owner_email__ = "damian.matusiak@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

_attenuator = JFW(
    ip_addr="10.42.61.157",
    port=3001,
    attenuation_port_numbers=range(1, 17),
    model="TAS_24T24_02G6_90_1S_EJS",
)

_pdu1 = Gude(
    # AHLOA:BL2106G10AK, AHLOA:BL2106G10HY
    addr="10.44.205.249",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)
_pdu2 = Gude(
    # AEHC:L1204708689, AEHC:L1204708724
    addr="10.44.205.242",
    port_numbers=[1, 2],
    model="EPC",
    version="8221-1",
)
_pdu3 = Gude(
    # SMOD:51779/51780
    addr="10.42.61.167",
    port_numbers=[3],
    model="EPC",
    version="8221-1",
)
_pdus = [_pdu1, _pdu2, _pdu3]


_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")


_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu3.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.164",
        vlan_id=903,
        routing=RoutingInformation(gateway="10.44.68.129"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.68.230",
        vlan_id=904,
        routing=RoutingInformation(gateway="10.44.68.193"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.38",
        vlan_id=905,
        routing=RoutingInformation(gateway="10.44.70.1"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.100",
        vlan_id=906,
        routing=RoutingInformation(gateway="10.44.70.65"),
    ),
)

_cu.sync = NetworkAddress(
    v4="10.44.70.164",
    vlan_id=907,
    routing=RoutingInformation(gateway="10.44.70.129"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.49.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AEHC",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.49.6", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AEHC",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51779, instance_id=51779)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.229", username="ute", password="ute"
    ),
    connections=[_cbts],
)

_core = RealCore5G(mcc=540, mnc=1)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="",  # to do
    core=_core,
    ues=[_qualcomm_ue],
    attenuator=_attenuator,
    pdus=_pdus,
)

__all__ = ["tl"]
