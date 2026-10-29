__maintainer__ = "Szymon Temecki"
__team__ = "I_MN_RAN_RD_VRF_WRO3_4"
__email__ = "I_MN_RAN_RD_VRF_WRO3_4@internal.nsn.com"

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
        v4="10.44.68.160",
        v6="2a00:8a00:6000:607c::1:ae17",
        vlan_id=903,
        routing_v4=RoutingInformation(gateway="10.44.68.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:ae01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129",  port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.68.225",
        v6="2a00:8a00:6000:607c::1:af17",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.33",
        v6="2a00:8a00:6000:607c::1:b017",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.96",
        v6="2a00:8a00:6000:607c::1:b117",
        vlan_id=906,
        routing_v4=RoutingInformation(gateway="10.44.70.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.70.160",
        v6="2a00:8a00:6000:607c::1:b217",
        vlan_id=907,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b201/120"),
    ),
    ngc=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:b317",
        v4="10.44.70.224",
        vlan_id=908,
        routing_v4=RoutingInformation(gateway="10.44.70.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b301/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.68.225",
        v6="2a00:8a00:6000:607c::1:af17",
        vlan_id=904,
        routing_v4=RoutingInformation(gateway="10.44.68.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:af01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.70.33",
        v6="2a00:8a00:6000:607c::1:b017",
        vlan_id=905,
        routing_v4=RoutingInformation(gateway="10.44.70.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b001/120"),
    ),
)

_pdu_sm = Gude(addr="10.44.206.158", port_numbers=[2], model="EPC", version="8221-1")
_pdu_rm = Gude(
    addr="10.44.177.75", port_numbers=[3], model="EPC", version="8221-1"
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    
    pdu_port=_pdu_rm.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="",
    serial_number="",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="",
    serial_number="",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=50293,
    oam_ip=NetworkAddress(
       v4="10.44.68.160",
       v6="2a00:8a00:6000:607c::1:ae17",
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
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=50239, instance_id=50239, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.156.38", username="ute", password="ute",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_sm, _pdu_rm]

tl = TestLine(
    test_pc=_test_pc_1,
    gnbs=[_cbts],
	enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_TL263",
	pdus=_pdus,
    test_pcs=[_test_pc_1],
)

__all__ = ["tl"]
