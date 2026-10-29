__maintainer__ = "Piotr Pinderak"
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
from taf.config.testline.radio import RU, RadioTypes, FujitsuRadioTypes, FujitsuRU
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
        v4="10.45.178.31",
        v6="2a00:8a00:6000:607c::1:9723",
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
        v4="10.45.178.95",
        v6="2a00:8a00:6000:607c::1:9823",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.159",
        v6="2a00:8a00:6000:607c::1:9923",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.223",
        v6="2a00:8a00:6000:607c::1:9a23",
        vlan_id=854,
        routing_v4=RoutingInformation(gateway="10.45.178.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9a01/120"),
    ),
    ngu=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:9b23",
        v4="10.45.179.31",
        vlan_id=855,
        routing_v4=RoutingInformation(gateway="10.45.179.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9b01/120"),
    ),
    ngc=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:9c23",
        v4="10.45.179.95",
        vlan_id=856,
        routing_v4=RoutingInformation(gateway="10.45.179.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9c01/120"),
    ),
    xnc=NetworkAddress(
        v4="10.45.178.95",
        v6="2a00:8a00:6000:607c::1:9823",
        vlan_id=852,
        routing_v4=RoutingInformation(gateway="10.45.178.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9801/120"),
    ),
    xnu=NetworkAddress(
        v4="10.45.178.159",
        v6="2a00:8a00:6000:607c::1:9923",
        vlan_id=853,
        routing_v4=RoutingInformation(gateway="10.45.178.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:9901/120"),
    ),
)

_pdu_sm = Gude(addr="10.44.206.157", port_numbers=[2], model="EPC", version="8221-1")
_pdu_ru1 = Gude(addr="10.44.205.210", port_numbers=[2], model="EPC", version="8221-1")
_pdu_ru2 = Gude(addr="10.44.177.178", port_numbers=[12], model="EPC", version="8221-1")

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AZQI",
    serial_number="1M222634134",
    product_code="475243A.101",
    pdu_port=_pdu_ru1.pdu_ports[2],
)

# _rmod_2 = FujitsuRU(
#     radio_type=FujitsuRadioTypes.OFEGSA.value,
#     serial_number="00492",
#     hw_version="0100",
#     product_code="FJRU-N75N3N1-G",
#     pdu_port=_pdu_ru2.pdu_ports[12],
#     netconf_ssh_configuration=SshServiceDetails(addr="10.202.120.135", username="fjncuser0", password="ncCl2fjRu+autH0")
# )

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="",
    serial_number="",
    rus=[_rmod_1,], #rus=[_rmod_1, _rmod_2],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_sm.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.104",
    serial_number="L1250309549",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    instance_id=50248,
    oam_ip=NetworkAddress(
       v4="10.45.178.31",
       v6="2a00:8a00:6000:607c::1:9723",
       vlan_id=851,
       routing_v4=RoutingInformation(gateway="10.44.178.1", ip_prefix_length=26),
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
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=50248, instance_id=50248, dcap=_dcap
)


_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.156.143", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp")
    ],
)

_pdus = [_pdu_sm, _pdu_ru1,  _pdu_ru2]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL189",
    pdus=_pdus,
)

__all__ = ["tl"]
