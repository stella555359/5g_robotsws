# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "monika.ceglarek@nokia.com"
__email__ = "monika.ceglarek@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.lmi import LMI, SerialOverTcp, SerialOverHost, Remote, Local

pdu_1 = Gude("10.44.205.141", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC")
pdu_2 = Gude("10.44.177.17", [8], "EPC")
pdu_3 = Gude("10.44.205.188", [6], "EPC")
pdu_4 = Gude("10.44.177.86", [9], "EPC")


# in admin terminal: radio-modules-ls
_rmod_1 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDJ",
    serial_number="LR231913110",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDD",
    serial_number="6Q205001523",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=pdu_1.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHPMDD",
    serial_number="AS212202689",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=pdu_1.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="FXED",
    serial_number="F7165111382",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.127", port=2323
    ),
    pdu_port=pdu_1.pdu_ports[4],
)
_rmod_5 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQP",
    serial_number="1M213805762",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=2323
    ),
    pdu_port=pdu_2.pdu_ports[8],
)
_rmod_6 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQK",
    serial_number="DH223908263",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.10", port=2323
    ),
    pdu_port=pdu_3.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_64T64R_eCPRI",
    radio_type="AEQE",
    serial_number="1M221313326",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.162", port=2323
    ),
    pdu_port=pdu_4.pdu_ports[9],
)


# on 4g BTS rio-ip FSPX (where X-1,2,3)
_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="102",
    product_code="473096A.102",
    serial_number="L1163605480",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="102",
    product_code="473096A.102",
    serial_number="L1163319122",
    rus=[_rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="104",
    product_code="475266A.104",
    serial_number="L1221801835",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
# on 5g BTS rio-ip FSP1
_fsp_4 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="104",
    product_code="475266A.104",
    serial_number="L1220704096",
    rus=[_rmod_5, _rmod_6, _rmod_7],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="102",
    serial_number="DH200762500",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=pdu_1.pdu_ports[7],
    hardware_type="ASIA",
    hardware_version="101",
    serial_number="L1162802405",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_du_1 = DU(_smod_1)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.214"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=53083, instance_id=53083)

_du_2 = DU(_smod_2)
_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.214"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.119", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], master=_gnbs_1)
_gnbs_1.slave = _gnbs_2

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.53.112", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.53.113", username="ute", password="UTE.debian12"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1, _gnbs_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_1xASIA_2xABIA_1xASIB_2xABIO_1xAEQE_1xAEQK_1xAEQP_2xAHPMDD_1xAHPMDJ",
    pdus=[pdu_1, pdu_2, pdu_3, pdu_4],
)

__all__ = ["tl"]
