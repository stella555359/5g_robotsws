__maintainer__ = "Anna Gibała-Wojtal"
__team__ = "MN VRF WRO34"
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
        v4="10.44.90.148",
        v6="2a00:8a00:6000:607c::1:be32",
        vlan_id=488,
        routing_v4=RoutingInformation(gateway="10.44.90.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:be01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.90.214",
        v6="2a00:8a00:6000:607c::1:bf32",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.91.24",
        v6="2a00:8a00:6000:607c::1:c032",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.91.86",
        v6="2a00:8a00:6000:607c::1:c132",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.91.86",
        v6="2a00:8a00:6000:607c::1:c132",
        vlan_id=491,
        routing_v4=RoutingInformation(gateway="10.44.91.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c101/120"),
    ),
    ngc=NetworkAddress(
        v4="10.44.91.150",
        v6="2a00:8a00:6000:607c::1:c232",
        vlan_id=492,
        routing_v4=RoutingInformation(gateway="10.44.91.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c201/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.90.214",
        v6="2a00:8a00:6000:607c::1:bf32",
        vlan_id=489,
        routing_v4=RoutingInformation(gateway="10.44.90.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:bf01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.91.24",
        v6="2a00:8a00:6000:607c::1:c032",
        vlan_id=490,
        routing_v4=RoutingInformation(gateway="10.44.91.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c001/120"),
    ),
)

_pdu_sm = Gude(addr="10.44.206.160", port_numbers=[6], model="EPC", version="8220-1")
_pdu_ru = Gude(addr="10.44.177.229", port_numbers=[5], model="EPC", version="8221-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.21.0.4", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    serial_number="L1204110701",
    product_code="475124B.M01",
    pdu_port=_pdu_ru.pdu_ports[5],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[],
    pdu_port=_pdu_sm.pdu_ports[6],
    hardware_type="ASOE",
    hardware_version="475587A.101",
    serial_number="EA211854121",
    rus=[_rmod_1],
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=51044,
    oam_ip=NetworkAddress(
       v4="10.44.90.148",
       v6="2a00:8a00:6000:607c::1:be32",
       vlan_id=488,
       routing_v4=RoutingInformation(gateway="10.44.90.129", ip_prefix_length=26),
       routing_v6=RoutingInformation(
         gateway="2a00:8a00:6000:607c::1:be01/120", ip_prefix_length=120
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
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=51044, instance_id=51044, dcap=_dcap
)


_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.178.62", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")
    ],
)

_pdus = [_pdu_sm, _pdu_ru]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_AEHC_eCPRI_WRO_TRS",
    pdus=_pdus,
)

__all__ = ["tl"]
