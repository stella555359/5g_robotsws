__maintainer__ = "Grzegorz Niedzwiedz"
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
        v4="10.44.65.90",
        v6="2A00:8A00:6000:607C::5A18",
        vlan_id=459,
        routing_v4=RoutingInformation(gateway="10.44.65.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5A01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.65.154",
        v6="2A00:8A00:6000:607C::5B18",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.65.129/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5B01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.65.218",
        v6="2A00:8A00:6000:607C::5C18",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5C01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.66.26",
        v6="2A00:8A00:6000:607C::5D18",
        vlan_id=462,
        routing_v4=RoutingInformation(gateway="10.44.66.1/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5D01/120"),
    ),
    ngu=NetworkAddress(
        v6="2A00:8A00:6000:607C::5E18",
        v4="10.44.66.90",
        vlan_id=463,
        routing_v4=RoutingInformation(gateway="10.44.66.65/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5E01/120"),
    ),
    ngc=NetworkAddress(
        v6="2A00:8A00:6000:607C::1:650F",
        v4="10.44.84.13",
        vlan_id=892,
        routing_v4=RoutingInformation(gateway="10.44.84.1/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::1:6501/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.65.154",
        v6="2A00:8A00:6000:607C::5B18",
        vlan_id=460,
        routing_v4=RoutingInformation(gateway="10.44.65.129/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5B01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.65.218",
        v6="2A00:8A00:6000:607C::5C18",
        vlan_id=461,
        routing_v4=RoutingInformation(gateway="10.44.65.193/26"),
        routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5C01/120"),
    ),
)


_pdu_sm = ATEN(addr="10.44.206.28", port_numbers=[6])
_pdu_rm = Gude(
    addr="10.44.177.46",
    port_numbers=[11],
    model="EPC",
    version="8221-1",
)

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1930G11PP",
    product_code="474331A.101",
    pdu_port=_pdu_rm.pdu_ports[11],

)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="",
    serial_number="",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[6],
    hardware_type="ASIM",
    hardware_version="",
    serial_number="L1223306809",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=50290,
    oam_ip=NetworkAddress(
       v4="10.44.65.90",
       v6="2A00:8A00:6000:607C::5A18",
       vlan_id=459,
       routing_v4=RoutingInformation(gateway="10.44.65.65/26"),
       routing_v6=RoutingInformation(gateway="2A00:8A00:6000:607C::5A01/120"),
    )
)

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="utfuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=51073, instance_id=51073, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.156.53", username="ute", password="uteUTE!",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
)

_pdus = [_pdu_sm, _pdu_rm]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIO_AHLOA_WRO_TRS",
    pdus=_pdus,
)

__all__ = ["tl"]
