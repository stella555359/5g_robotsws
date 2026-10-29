__maintainer__ = "Jagoda Kubacka"
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

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.178.17",
        v6="2a00:8a00:6000:607c::1:9712",
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
        v4="10.45.178.81",
        v6="2a00:8a00:6000:607c::1:9812",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.145",
        v6="2a00:8a00:6000:607c::1:9912",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.209",
        v6="2a00:8a00:6000:607c::1:9a12",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9a01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.45.179.17",
        v6="2a00:8a00:6000:607c::1:9c12",
        vlan_id=855,
        routing_v4=RoutingInformation(gateway="10.45.179.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9c01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.45.179.81",
        v6="2a00:8a00:6000:607c::1:9b12",
        vlan_id=856,
        routing_v4=RoutingInformation(gateway="10.45.179.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9b01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.45.178.81",
        v6="2a00:8a00:6000:607c::1:9812",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    xnu=NetworkAddress(
        v4="10.45.178.145",
        v6="2a00:8a00:6000:607c::1:9912",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
)

_pdu_sm = Gude(
    addr="10.44.177.75",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
)

_pdu_rm = Gude(
    addr="10.44.177.76",
    port_numbers=[5],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="AEUB",
    serial_number="AH212600337",
    product_code="474608A.104",
    pdu_port=_pdu_rm.pdu_ports[5],

)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="",
    serial_number="L1231800017",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.23",
    hardware_type="ABIP",
    hardware_version="",
    serial_number="L1232105736",
    rus=[_rmod_1],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIP",
    hardware_version="",
    serial_number="L1234004852",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_sm.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="",
    serial_number="L1203104238",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=51089,
    oam_ip=NetworkAddress(
       v4="10.44.79.39",
       v6="2a00:8a00:6000:607c::1:b509",
       vlan_id=910,
       routing_v4=RoutingInformation(gateway="10.44.79.1/26"),
       routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b501/120"),
  )
)

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "10.42.158.188", port=9443, username="utfuser", password="utfadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51089, instance_id=51089, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.42.53.16", username="ute", password="uteUTE!",
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
    tl_cloud_topology="CLOUD_SRAN_TL100",
    pdus=_pdus,
)

__all__ = ["tl"]
