__maintainer__ = "Jagoda Kubacka"
__team__ = "I_MN_RAN_RD_VRF_WRO3_4"
__email__ = "I_MN_RAN_RD_VRF_WRO3_4@internal.nsn.com"
__owner_email__ = "jagoda.kubacka@nokia.com"

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
from taf.config.testline.lmi import SerialOverTcp, Remote


cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.220.196",
        v6="2a00:8a00:6000:607c::8e06",
        vlan_id=454,
        routing_v4=RoutingInformation(gateway="10.44.80.129", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5501", ip_prefix_length=120),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.220.204",
        v6="2a00:8a00:6000:607c::8f06",
        vlan_id=494,
        routing_v4=RoutingInformation(gateway="10.44.92.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c401", ip_prefix_length=120),
    ),
    x2u=NetworkAddress(
        v4="10.42.220.212",
        v6="2a00:8a00:6000:607c::9006",
        vlan_id=495,
        routing_v4=RoutingInformation(gateway="10.44.92.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:c501", ip_prefix_length=120),
    ),
    s1u=NetworkAddress(
        v4="10.42.220.220",
        v6="2a00:8a00:6000:607c::9106",
        vlan_id=457,
        routing_v4=RoutingInformation(gateway="10.44.64.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5801", ip_prefix_length=120),
    ),
    ngu=NetworkAddress(
        v4="10.42.220.220",
        v6="2a00:8a00:6000:607c::9106",
        vlan_id=457,
        routing_v4=RoutingInformation(gateway="10.44.64.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5801", ip_prefix_length=120),
    ),
    ngc=NetworkAddress(
        v4="10.42.220.236",
        v6="2a00:8a00:6000:607c::9306",
        vlan_id=893,
        routing_v4=RoutingInformation(gateway="10.44.84.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6601", ip_prefix_length=120),
    ),
    xnc=NetworkAddress(
        v4="10.42.220.204",
        v6="2a00:8a00:6000:607c::8f06",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5601", ip_prefix_length=120),
    ),
    xnu=NetworkAddress(
        v4="10.42.220.212",
        v6="2a00:8a00:6000:607c::9006",
        vlan_id=456,
        routing_v4=RoutingInformation(gateway="10.44.64.129", ip_prefix_length=26),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5701", ip_prefix_length=120),
    ),
)

_pdu_sm_1 = Gude(
    addr="10.44.206.160",
    port_numbers=[10],
    model="EPC",
    version="8221-1",
)

_pdu_rm_1 = Gude(
    addr="10.44.206.225",
    port_numbers=[4],
    model="EPC",
    version="8221-1",
)

_pdu_rm_2 = Gude(
    addr="10.44.177.46",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    ru_hw_group="AHCA",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_pdu_rm_1.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="AHLOA",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8",
    ),
    pdu_port=_pdu_rm_2.pdu_ports[11],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204304813",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104672",
    rus=[_rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="L1214601276",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_sm_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="474767A.101",
    serial_number="DH220345041",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=51226,
    oam_ip=NetworkAddress(
       v4="10.42.220.196",
       vlan_id=459,
       routing_v4=RoutingInformation(gateway="10.44.65.65", ip_prefix_length=26),
  )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_2],
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
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=51226, instance_id=51226
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.42.158.201", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(
        addr="10.42.158.120", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_sm_1, _pdu_rm_1, _pdu_rm_2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL174_NESAS",
    pdus=_pdus,
)

__all__ = ["tl"]