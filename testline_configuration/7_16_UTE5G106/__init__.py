__maintainer__ = "Anna Sheiko"
__team__ = "MN_RAN_Pz_3_WRO_02&04"
__email__ = "I_EXT_5G_IV_TRSSEC@internal.nsn.com"
import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.64.55",
        v6="2a00:8a00:6000:607c::1:ae17",
        vlan_id=454,
        routing_v4=RoutingInformation(gateway="10.44.64.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5501/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129",  port=443, username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.64.106",
        v6="2a00:8a00:6000:607c::5632",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5601/120"),
    ),
    x2u=NetworkAddress(
        v4="10.44.64.152",
        v6="2a00:8a00:6000:607c::5632",
        vlan_id=456,
        routing_v4=RoutingInformation(gateway="10.44.64.152/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5701/120"),
    ),
    s1u=NetworkAddress(
        v4="10.44.64.215",
        v6="2a00:8a00:6000:607c::5807",
        vlan_id=457,
        routing_v4=RoutingInformation(gateway="10.44.64.193/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5801/120"),
    ),
    ngu=NetworkAddress(
        v4="10.44.70.160",
        v6="2a00:8a00:6000:607c::1:b217",
        vlan_id=458,
        routing_v4=RoutingInformation(gateway="10.44.70.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:b201/120"),
    ),
    ngc=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:6610",
        v4="10.44.84.98",
        vlan_id=893,
        routing_v4=RoutingInformation(gateway="10.44.84.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6601/120"),
    ),
    xnc=NetworkAddress(
        v4="10.44.64.106",
        v6="2a00:8a00:6000:607c::5632",
        vlan_id=455,
        routing_v4=RoutingInformation(gateway="10.44.64.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5601/120"),
    ),
    xnu=NetworkAddress(
        v4="10.44.64.152",
        v6="2a00:8a00:6000:607c::5632",
        vlan_id=456,
        routing_v4=RoutingInformation(gateway="10.44.64.152/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::5701/120"),
    ),
)
_pdu_gnb = Gude(addr="10.44.206.24", port_numbers=[1], model="EPC", version="8220-1")
_pdu_enb = Gude(addr="10.44.206.24", port_numbers=[2], model="EPC", version="8220-1")
_pdu_gnb_ru1 = Gude(
    addr="10.44.206.26", port_numbers=[9], model="EPC", version="8220-1"
)
_pdu_gnb_ru2 = Gude(
    addr="10.44.206.26", port_numbers=[4], model="EPC", version="8220-1"
)
_pdu_gnb_ru3 = Gude(
    addr="10.44.206.26", port_numbers=[5], model="EPC", version="8220-1"
)
_pdu_gnb_ru4 = Gude(
    addr="10.44.206.26", port_numbers=[6], model="EPC", version="8220-1"
)
_pdu_gnb_ru5 = Gude(
    addr="10.44.206.26", port_numbers=[11], model="EPC", version="8220-1"
)

_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2045V0S8M",
    product_code="474216A.101",
    pdu_port=_pdu_gnb_ru1.pdu_ports[9],
)    

_rmod_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password="umniedziala"
    ),
    ru_hw_group="cMAAr6.1_32T32RR",
    radio_type="AEQQ",
    serial_number="1M241903477",
    product_code="475252A.202",
    pdu_port=_pdu_gnb_ru2.pdu_ports[4],
)  

_rmod_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password="umniedziala"
    ),
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AEQQ",
    serial_number="1M220620976",
    product_code="475252A.M01",
    pdu_port=_pdu_gnb_ru3.pdu_ports[5],
)  

_rmod_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password="umniedziala"
    ),
    ru_hw_group="cMAAr6.1_32T32R",
    radio_type="AEQQ",
    serial_number="1M220620975",
    product_code="475252A.M01",
    pdu_port=_pdu_gnb_ru4.pdu_ports[6],
)  
_rmod_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password="w@=EIj7P6R0bVy85OjCVa^ho&8"
    ),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="K9184308067",
    product_code="474216A.101",
    pdu_port=_pdu_gnb_ru5.pdu_ports[11],
)    


_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="	L1204104679",
    rus=[_rmod_1],
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104591",
    rus=[_rmod_2, _rmod_3, _rmod_4 ],
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193577618",
    rus=[_rmod_1],
)

_fsp_4 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA193577752",
    rus=[_rmod_1],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA183143075",
    rus=[_rmod_1],
)

_fct_1 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH204667670",
)

_fct_2 = CommonUnit(
    SshServiceDetails(addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_3, _fsp_4, _fsp_5],
    pdu_port=_pdu_enb.pdu_ports[2],
    hardware_type="ASIA",
    hardware_version="473764A.102",
    serial_number="DH204667670",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1])

_gnb_1 = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50203) #5G
_enb_sbts_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    instance_id=40292,
    oam_ip=NetworkAddress(
       v4="10.44.92.15",
       v6="2a00:8a00:6000:607c::1:c401",
       vlan_id=494,
       routing_v4=RoutingInformation(gateway="10.44.92.1", ip_prefix_length=26),
       routing_v6=RoutingInformation(
         gateway="2a00:8a00:6000:607c::1:c422", ip_prefix_length=120
      ), # 4G
  )
)



_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50203, instance_id=50203, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.44.149.116", username="ute", password="UTE.debian12",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_gnb_1.dus[0].airscale.common_units[0], interface_type="lmp"),
    ],
) # 5G

_test_pc_2 = TestPc(
    SshServiceDetails(
        addr="10.44.178.71", username="ute", password="UTE.debian12",
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"),
    ],
) # 4G


_pdus = [_pdu_gnb, _pdu_enb, _pdu_gnb_ru1, _pdu_gnb_ru2, _pdu_gnb_ru3, _pdu_gnb_ru4]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL106_BellCanada-1",
    pdus=_pdus,
)

__all__ = ["tl"]
