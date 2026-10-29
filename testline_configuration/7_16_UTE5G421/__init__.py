__maintainer__ = "Julia Wijas"
__team__ = "MN_VRF_WRO34"
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
        v4="10.44.64.39",
        v6="2a00:8a00:6000:607c::5521",
        vlan_id=454,
        routing_v4=RoutingInformation(gateway="10.44.64.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5501/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.64.102",
        v6="2a00:8a00:6000:607c::5621",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5601/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.64.132",
        v6="2a00:8a00:6000:607c::5721",
        vlan_id=456,
        routing_v4=RoutingInformation(gateway="10.44.64.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5701/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.64.196",
        v6="2a00:8a00:6000:607c::5820",
        vlan_id=457,
        routing_v4=RoutingInformation(gateway="10.44.64.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5801/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.65.4",
        v6="2a00:8a00:6000:607c::5921",
        vlan_id=458,
        routing_v4=RoutingInformation(gateway="10.44.65.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5901/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.84.72",
        v6="2a00:8a00:6000:607c::1:6621",
        vlan_id=893,
        routing_v4=RoutingInformation(gateway="10.44.84.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6601/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.64.102",
        v6="2a00:8a00:6000:607c::5621",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5601/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.64.132",
        v6="2a00:8a00:6000:607c::5721",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.44.64.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5701/120"),
    ),
)

_pdu_sm = Gude(addr="10.44.206.26", port_numbers=[12], model="EPC", version="8220-1")
_pdu_rm = Gude(addr="10.44.206.26", port_numbers=[2], model="EPC", version="8220-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AWHQX",
    serial_number="EB2239R2001",
    product_code="475927A.101",
    pdu_port=_pdu_rm.pdu_ports[2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[],
    pdu_port=_pdu_sm.pdu_ports[12],
    hardware_type="ASOF",
    hardware_version="476147A.101",
    serial_number="EA234450262",
    rus=[_rmod_1],
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=51098,
    oam_ip=NetworkAddress(
       v4="10.44.64.39",
       v6="2a00:8a00:6000:607c::5521",
       vlan_id=454,
       routing_v4=RoutingInformation(gateway="10.44.64.1", ip_prefix_length=26),
       routing_v6=RoutingInformation(
         gateway="2a00:8a00:6000:607c::5501", ip_prefix_length=120
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
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=51098, instance_id=51098, dcap=_dcap
)


_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.149.53", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")
    ],
)

_pdus = [_pdu_sm, _pdu_rm]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL421",
    pdus=_pdus,
)

__all__ = ["tl"]
