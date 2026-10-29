__maintainer__ = "Tadeusz Marcinkiewicz"
__team__ = "MN_RAN_Pz_3_WRO_02&04"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"
import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.178.30",
        v6="2a00:8a00:6000:607c::1:9707",
        vlan_id=851,
        routing_v4=RoutingInformation(gateway="10.45.178.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9701/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2u=NetworkAddress(
        v4="10.45.178.160",
        v6="2a00:8a00:6000:607c::1:9907",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    x2c=NetworkAddress(
        v4="10.45.178.67",
        v6=" 2a00:8a00:6000:607c::1:9807",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway=" 2a00:8a00:6000:607c::1:9801/120"),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.233",
        v6="2a00:8a00:6000:607c::1:9a07",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9a01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.45.179.3",
        v6="2a00:8a00:6000:607c::1:9b07",
        vlan_id=855,
        routing_v4=RoutingInformation(gateway="10.45.179.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9b01/120/120"),
    ),
    ngc=NetworkAddress(
        v4="10.45.179.67",
        v6=" 2a00:8a00:6000:607c::1:9c07",
        vlan_id=856,
        routing_v4=RoutingInformation(gateway="10.45.179.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9c01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.45.178.67",
        v6="2a00:8a00:6000:607c::1:9807",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    xnu=NetworkAddress(
        v4="10.45.178.160",
        v6="2a00:8a00:6000:607c::1:9907",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
)
_pdu_gnb = Gude(addr="10.44.177.178", port_numbers=[7], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.177.178", port_numbers=[12], model="EPC", version="8221-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.177.178", port_numbers=[10], model="EPC", version="8221-1"
)
_pdu_gnb_ru3 = Gude(
    addr="10.44.205.210", port_numbers=[4], model="EPC", version="8221-1"
)

_pdus = [_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru2, _pdu_gnb_ru3]
_gnb_ru = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWHQX",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[12],
)
_gnb_ru2 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPTD",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[10],
)
_gnb_ru3 = RU(
    ru_hw_group="RF6.2_4T4R_IDRU",
    radio_type="AWPTD",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.54",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_pdu_gnb_ru3.pdu_ports[4],
)
_asof_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[7],
    hardware_type="ASOF",
)
_airscale_gnb_1 = Airscale(common_units=[_asof_gnb_1])
_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_asof_gnb_1, label="SFP", port_id=2),
        target=Endpoint(unit=_gnb_ru, label="SFP", port_id=1),
    )
]
_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru], cablinks=_ru_cablinks)

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51100, instance_id=51100, dcap=_dcap
)
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASOF_AWHQX_AWPTD_AWPTD_P2P_WRO_TRS"

_cu_gnb_1.m = NetworkAddress(
    v4="10.45.178.30",
    v6="2a00:8a00:6000:607c::1:9707",
    vlan_id=851,
    routing_v4=RoutingInformation(gateway="10.45.178.1/26"),
    routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9701/120"),
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.62", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_asof_gnb_1, interface_type="lmp")
    ],
)
tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    gnbs=[_cbts],
    # core=_core,
    tl_cloud_topology=_tl_cloud_topology,
    # enbs=[_enb_1],
    test_pcs=[_lmp_vm_gnb_1],
)
