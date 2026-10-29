__maintainer__ = "Julia Wijas"
__team__ = "I_MN_RAN_RD_VRF_WRO3_4"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails, HttpConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.dcap import DcapBasic
from taf.config.testline import RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.177",
        v6="2a00:8a00:6000:607c::1:ae24",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.243",
        v6="2a00:8a00:6000:607c::1:af25",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.51",
        v6="2a00:8a00:6000:607c::1:b025",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.113",
        v6="2a00:8a00:6000:607c::1:b124",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    ngu=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b226",
        v4="10.44.70.177",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b201/120"),
    ),
    ngc=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b322",
        v4="10.44.70.242",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b301/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.68.243",
        v6="2a00:8a00:6000:607c::1:af25",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.51",
        v6="2a00:8a00:6000:607c::1:b025",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)
_pdu_sm = Gude(addr="10.44.206.157", port_numbers=[9], model="EPC", version="8221-1")
_pdu_rm = Gude(addr="10.44.205.210", port_numbers=[1], model="EPC", version="8221-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="cMAAr6.2_32T32R",
    radio_type="AQQQ",
    serial_number="1M230706089",
    product_code="475788A.103",
    pdu_port=_pdu_rm.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="",
    serial_number="",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[9],
    hardware_type="ASIM",
    hardware_version="",
    serial_number="",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=50220,
    oam_ip=NetworkAddress(
       v4="10.44.68.177",
       v6="2a00:8a00:6000:607c::1:ae24",
       vlan_id=903,
       routing_v4=RoutingInformation(gateway="10.44.68.129", ip_prefix_length=26),
       routing_v6=RoutingInformation(
         gateway="2a00:8a00:6000:607c::1:ae01", ip_prefix_length=120
      ),
  )
)

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=50220, instance_id=50220, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.42.53.28", username="ute", password="UTE.debian12",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_sm, _pdu_rm]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL169",
    pdus=_pdus,
)

__all__ = ["tl"]
