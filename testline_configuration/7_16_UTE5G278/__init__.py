__maintainer__ = "Piotr Pinderak"
__team__ = "I_MN_RAN_RD_VRF_WRO3_4"
__email__ = "I_MN_RAN_RD_VRF_WRO3_4@internal.nsn.com"
__owner_email__ = "piotr.pinderak@nokia.com"
__customer__ = "RJIO"

import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
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

_cu_gnb = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.66.164",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129/0"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", port=443, username="Nemuadmin", password="nemuuser"
    ),
    s1u=NetworkAddress(
        v4="10.44.66.164",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129/0"),
    ),
    ngu=NetworkAddress(
        v4="10.44.66.164",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129/0"),
    ),
    ngc=NetworkAddress(
        v4="10.44.66.164",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129/0"),
    ),
    xnc=NetworkAddress(
        v4="10.44.66.204",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129/0"),
    ),
    xnu=NetworkAddress(
        v4="10.44.67.43",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129/0"),
    ),
)

_pdu_sm_1 = Gude(addr="10.44.206.160", port_numbers=[4], model="EPC", version="8220-1")
_pdu_sm_2 = Gude(addr="10.44.206.160", port_numbers=[7], model="EPC", version="8220-1")
_pdu_ru1 = Gude(addr="10.44.206.161", port_numbers=[1], model="EPC", version="8226-1")
_pdu_ru2 = Gude(addr="10.44.206.161", port_numbers=[6], model="EPC", version="8226-1")
_pdu_ru3 = Gude(addr="10.44.206.161", port_numbers=[3], model="EPC", version="8226-1")


_rmod_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="cMAAr7.1_32T32R",
    radio_type="AQQJ",
    serial_number="K9232129571",
    product_code="476383A.108",
    pdu_port=_pdu_ru1.pdu_ports[1],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.32.136", port=5001),
        ]
    ),
)

_rmod_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPB",
    serial_number="K9200910377",
    product_code="474119A.101",
    pdu_port=_pdu_ru2.pdu_ports[6],
    lmi=SerialOverTcp(
    uart_mapping=[
        Remote(addr="10.255.32.137", port=5001),
    ]
    ),

)

_rmod_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="a2%FgSz3$fHmdusap354xujw7"
    ),
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AHPJ",
    serial_number="K9232737244",
    product_code="476403A.101",
    pdu_port=_pdu_ru3.pdu_ports[3],
    lmi=SerialOverTcp(
    uart_mapping=[
        Remote(addr="10.255.32.138", port=5001),
    ]
    ),

)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_sm_1.pdu_ports[4],
    hardware_type="ASOG",
    hardware_version="476254A.101",
    serial_number="L1240913069",
    rus=[_rmod_2, _rmod_3],
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_sm_2.pdu_ports[7],
    hardware_type="ASOH",
    hardware_version="476255A.101",
    serial_number="L1241601566",
    rus=[_rmod_1],
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2, _rmod_3],
    instance_id=50207,
    oam_ip=NetworkAddress(
        v4="10.44.66.164",
        vlan_id=464,
        routing_v4=RoutingInformation(gateway="10.44.66.129", ip_prefix_length=0),
    )
)

_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1],
    master=_enb_sbts_1,
    )

_enb_sbts_1.slave = _enb_sbts_2

_du_1_gnb_1 = DU(airscale=_smod_1, rus=[_rmod_1, _rmod_2, _rmod_3])

_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "127.0.0.1", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_1_gnb_1], global_bts_id=50207, instance_id=50207, dcap=_dcap
)

_test_pc_1 = TestPc(
    SshServiceDetails(
        addr="10.42.53.60", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp"),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(
        addr="10.44.178.63", username="ute", password="UTE.debian12"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.129"),
        Connection(
            interface="eth1", 
            device=_enb_sbts_2.system_module.common_units[0], 
            interface_type="lmp"),
    ],
)


_pdus = [_pdu_sm_1, _pdu_sm_2, _pdu_ru1, _pdu_ru2, _pdu_ru3]

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_TL278_RJIO-2",
    pdus=_pdus,
)

__all__ = ["tl"]
