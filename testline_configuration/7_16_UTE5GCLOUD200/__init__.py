__maintainer__ = "Patryk Marciniak"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_7@internal.nsn.com"
__owner_email__ = "patryk.marciniak@nokia.com"

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

_attenuator = JFW(
    ip_addr="10.42.61.245",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

# ASIL, ASIL_master
_pdu1 = Gude(addr="10.42.61.167", port_numbers=[1, 4], model="EPC", version="8221-1")

# AEQV, AHGA, AZQJ, AHCA
_pdu2 = Gude(
    addr="10.44.177.34", port_numbers=[1, 2, 3, 4], model="EPC", version="8221-1"
)

# AHLOA, AHEGB, ARGA, AZQO
_pdu3 = Gude(
    addr="10.44.177.99", port_numbers=[1, 2, 3, 5], model="EPC", version="8221-1"
)

_pdus = [_pdu1, _pdu2, _pdu3]

_abin = CapacityUnit(addr="192.168.253.20")
_abio1 = CapacityUnit(addr="192.168.253.21")
_abio2 = CapacityUnit(addr="192.168.253.22")

_common_unit_master = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abin, _abio1, _abio2],
    pdu_port=_pdu1.pdu_ports[4],
)

_abia = CapacityUnit(addr="192.168.253.20")
_abio3 = CapacityUnit(addr="192.168.253.21")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia, _abio3],
    pdu_port=_pdu1.pdu_ports[1],
)

_airscale = Airscale([_common_unit_master, _common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.70.237",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
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
        v4="10.44.68.238",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.46",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.108",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.70.237",
    vlan_id=907,
    routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AEQV",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHGA",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[3],
    ru_hw_group="",
    radio_type="AZZQJ",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOA",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[2],
    ru_hw_group="",
    radio_type="AHEGB",
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[3],
    ru_hw_group="",
    radio_type="ARGA",
)

_ru_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu3.pdu_ports[5],
    ru_hw_group="",
    radio_type="AZQO",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50040, instance_id=50040)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.24", username="ute", password="ute"
    ),
    connections=[_cbts],
)

_core = RealCore5G(mcc=555, mnc=10)

tl = TestLine(
    test_pc=_test_pc,
    # test_pcs=_lte_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHLOA",
    pdus=_pdus,
)

__all__ = ["tl"]
