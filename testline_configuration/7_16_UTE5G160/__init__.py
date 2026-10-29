__maintainer__ = "Filip Tuznik"
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
        v4="10.45.178.11",
        v6="2a00:8a00:6000:607c::1:970c",
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
    x2c=NetworkAddress(
        v4="10.45.178.75",
        v6="2a00:8a00:6000:607c::1:980c",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.139",
        v6="2a00:8a00:6000:607c::1:990c",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.203",
        v6="2a00:8a00:6000:607c::1:9a0c",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9a01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.45.179.11",
        v6="2a00:8a00:6000:607c::1:9c0c",
        vlan_id=855,
        routing_v4=RoutingInformation(gateway="10.45.179.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9c01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.45.179.75",
        v6="2a00:8a00:6000:607c::1:9b0c",
        vlan_id=856,
        routing_v4=RoutingInformation(gateway="10.45.179.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9b01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.45.178.75",
        v6="2a00:8a00:6000:607c::1:980c",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.45.178.139",
        v6="2a00:8a00:6000:607c::1:990c",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
)

_pdu_sm= Gude(addr="10.44.206.157", port_numbers=[10], model="EPC", version="8221-1")
_pdu_rm= Gude(addr="10.44.177.75", port_numbers=[1], model="EPC", version="8221-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password="umniedziala"
    ),
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZQP",
    serial_number="1M203665224",
    product_code="475198A.102",
    pdu_port=_pdu_rm.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIQ",
    hardware_version="",
    serial_number="",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101 ",
    serial_number="L1204110706",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=51130,
    oam_ip=NetworkAddress(
       v4="10.45.178.11",
       v6="2a00:8a00:6000:607c::1:970c",
       vlan_id=851,
       routing_v4=RoutingInformation(gateway="10.45.178.1", ip_prefix_length=26),
       routing_v6=RoutingInformation(
         gateway="2a00:8a00:6000:607c::1:9701", ip_prefix_length=120
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
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=51130, instance_id=51130, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.156.56", username="ute", password="ute",
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
    tl_cloud_topology="CLOUD_SRAN_TL160",
    pdus=_pdus,
)

__all__ = ["tl"]
