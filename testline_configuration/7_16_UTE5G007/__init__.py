__maintainer__ = "Grzegorz Niedzwiedz"
__team__ = "TRSSEC"
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
        v4="10.44.65.70",
        v6="2a00:8a00:6000:607c::5a33",
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.44.65.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5a01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.65.134",
        v6="2a00:8a00:6000:607c::5b33",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.65.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5b01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.65.223",
        v6="2a00:8a00:6000:607c::5c33",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5c01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.66.33",
        v6="2a00:8a00:6000:607c::5d33",
        vlan_id=462,
        routing_v4=RoutingInformation(gateway="10.44.66.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5d01/120"),
    ),
#    ngu=NetworkAddress(
#        v4="10.44.66.33",
#        v6="2a00:8a00:6000:607c::5d33",
#        vlan_id=462,
#        routing_v4=RoutingInformation(gateway="10.44.66.1/26",)
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5d01/120"),
#    ),
#    ngc=NetworkAddress(
#        v4="10.44.84.28",
#        v6="2a00:8a00:6000:607c::1:6533",
#        vlan_id=892,
#        routing_v4=RoutingInformation(gateway="10.44.84.1/26"),
#        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6501/120"),
#    ),
    xnc=NetworkAddress(
        v4="10.44.65.134",
        v6="2a00:8a00:6000:607c::5b33",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.65.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5b01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.65.223",
        v6="2a00:8a00:6000:607c::5c33",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5c01/120"),
    ),
)

_pdu_1 = ATEN("10.42.61.23", [2], "", "")
_pdu_2 = ATEN("10.42.61.23", [1], "", "")
_pdu_3 = Gude(addr="10.44.206.131", port_numbers=[12], model="EPC", version="8220-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="",
    radio_type="AHCA",
    serial_number="AS213013200",
    product_code="473966A.101",
    pdu_port=_pdu_3.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232001210",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIP",
    hardware_version="475792A.101",
    serial_number="L1232105734",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
    	addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1233503210",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
    	addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_2.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1232304202",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=51135,
    oam_ip=NetworkAddress(
       v4="10.44.65.70",
       vlan_id=459,
       routing_v4=RoutingInformation(gateway="10.44.65.65/26"),
    )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    master=_enb_sbts_1,
    )

_enb_sbts_1.slave = _enb_sbts_2

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51135, instance_id=51135, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.156.210", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(
        addr="10.44.156.216", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_1, _pdu_2, _pdu_3]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL007",
    pdus=_pdus,
)

__all__ = ["tl"]
