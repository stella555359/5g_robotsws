# This script was generated automatically, --None-- values indicate lacking data, please fill them manually


__maintainer__ = "Michal Wlosek"
__email__ = "michal.wlosek@nokia.com"

import os
from typing import Optional, List, Union
from enum import Enum

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.attenuator import TopYoung, JFW
from taf.config.testline import RoutingInformation
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)


__all__ = ["tl"]

_pdu_1 = Gude("10.44.200.95", [7, 8], "EPC", "")
_pdu_2 = Gude("10.44.200.96", [1, 2, 3, 4, 5, 6, 7], "EPC", "")
_pdu_3 = Gude("10.44.200.106", [1], "EPC", "")


_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.84.4",
        v6="2a00:8a00:6000:600c::1b04",
        vlan_id=517,
        routing_v4=RoutingInformation(gateway="10.42.84.1/24"),
        routing_v6=RoutingInformation(gateway="GW:2a00:8a00:6000:600c::1b01/120"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.85.4",
        v6="2a00:8a00:6000:600c::1c04",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    x2u=NetworkAddress(
        v4="10.42.85.68",
        v6="2a00:8a00:6000:600c::1d04",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
    s1u=NetworkAddress(
        v4="10.42.85.132",
        v6="2a00:8a00:6000:600c::1e04  ",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngu=NetworkAddress(
        v4="10.42.85.132",
        v6="2a00:8a00:6000:600c::1e04  ",
        vlan_id=520,
        routing_v4=RoutingInformation(gateway="10.42.85.129/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1e01/120"),
    ),
    ngc=NetworkAddress(
        v4="10.42.86.4",
        v6="2a00:8a00:6000:600c::2004",
        vlan_id=521,
        routing_v4=RoutingInformation(gateway="10.42.86.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2004"),
    ),
    xnc=NetworkAddress(
        v4="10.42.85.4",
        v6="2a00:8a00:6000:600c::1c04",
        vlan_id=518,
        routing_v4=RoutingInformation(gateway="10.42.85.1/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1c01/120"),
    ),
    xnu=NetworkAddress(
        v4="10.42.85.68",
        v6="2a00:8a00:6000:600c::1d04",
        vlan_id=519,
        routing_v4=RoutingInformation(gateway="10.42.85.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::1d01/120"),
    ),
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171216180",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223400358",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309881",
)


_smod_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_3.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="L1204110706",
)

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB,
    serial_number="EA223662686",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.135", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB,
    serial_number="EA223662696",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.136", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type=RadioTypes.AHPMDB,
    serial_number="EA223662811",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ,
    serial_number="1M224104228",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ,
    serial_number="1M224104247",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.158", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    radio_type=RadioTypes.AEQQ,
    serial_number="1M224104249",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.162", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2334H60M8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2334H60M6",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)
_rmod_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type=RadioTypes.AHEGHA,
    serial_number="BL2334H60MA",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.132", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)


_airscale_gnb_1 = Airscale(common_units=[_smod_1])
_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
        _rmod_8,
        _rmod_9,
    ],
)
_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=8420, instance_id=8420
)


_bsc = BSC(
    name="BSC-34",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.44.139.55", username="SYSTEM", password="SYSTEM"
    ),
)

_attenuator = JFW(
    ip_addr="10.42.80.120",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
)

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_xiaomi12.yaml")
) as ue_config:
    import yaml

    ue_xiaomi12 = yaml.load(ue_config, yaml.SafeLoader)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.22", username="ute", password="ute"
    ),
    connections=[
        Connection(interface="eth1", device=_smod_1, interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    gnbs=[_cbts],
    ues=[ue_xiaomi12],
    attenuator=_attenuator,
    tl_cloud_topology="CLOUD_SRAN_NLG_1ASIB_1ABIA_2ABIO_3AHEGHA_3AEQQ_3AHPMDB",
    bscs=[_bsc],
)
