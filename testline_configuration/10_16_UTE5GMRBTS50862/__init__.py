__maintainer__ = "Tomasz Brzazgacz"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "I_MN_RAN_PZ2_WRO7_SG_GMS@internal.nsn.com"
__owner_email__ = "tomasz.brzazgacz@nokia.com"
__scout__ = "https://scout.nsn-rdnet.net/testlines/MRBTS-50862/preview"
__omnia__ = "https://omnia.krk-lab.nsn-rdnet.net/testline_id/TL7696"

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

_pdu1 = Gude(
    addr="10.44.177.203",
    port_numbers=[1, 2, 6, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(addr="10.44.177.204", port_numbers=[1, 3], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[3],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.255.33",
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
        v4="10.44.255.33",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.255.33",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.255.33",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
    ),
    tracing=None,
)

_cu.sync = NetworkAddress(
    v4="10.44.255.33",
    vlan_id=907,
    routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[10],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.166", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[11],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.146", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.253.206", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[2],
    ru_hw_group="",
    radio_type="FRCG",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.224.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="FRGP",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.253.202", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[1],
    ru_hw_group="",
    radio_type="FRHB",
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu1.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHCA",
)

_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50862, instance_id=50862)

_core = RealCore5G(mcc=450, mnc=6)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.196", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_cbts],
)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(_common_unit_lte_ssh, capacity_units=[_abil_loner])

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte_test_pc_40862 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.190", username="ute", password="ute"
    )
)

_lte_test_pc_40863 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.191", username="ute", password="ute"
    )
)

_lte_40862 = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.224.33",
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
    ),
    global_bts_id=40862,
    instance_id=40862,
)

_lte_40863 = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.224.161",
        vlan_id=910,
        routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
    ),
    global_bts_id=40863,
    instance_id=40863,
)

_lte_40862.m = NetworkAddress(
    v4="10.44.224.33",
    vlan_id=909,
    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
)

_lte_40863.m = NetworkAddress(
    v4="10.44.224.161",
    vlan_id=909,
    routing_v4=RoutingInformation(gateway="10.44.78.193/26"),
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHLOA_ENB",
    pdus=_pdus,
)

__all__ = ["tl"]
