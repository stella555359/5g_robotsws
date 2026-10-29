# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Marcel Behen"
__email__ = "marcel.behen@nokia.com"
__owner_email__ = "marcel.behen@nokia.com"
__team__ = "pz2wro3"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN


# testline config variables


_pdu_1 = Gude(
    addr="10.44.177.177",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_2 = Gude(
    addr="10.44.205.153",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_rmod_1 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    radio_type=RadioTypes.AQQJ.value,
    serial_number="1M233608969",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.22.0.2", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    radio_type=RadioTypes.AQQJ.value,
    serial_number="1M233608967",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    radio_type=RadioTypes.AQQJ.value,
    serial_number="K9232920878",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.22.0.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)


_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232032151",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232032131",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[8],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9232032130",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPB.value,
    serial_number="EA222355958",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.154",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    radio_type=RadioTypes.AEQZ.value,
    serial_number="1M222539655",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)


_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ASOE",
    hardware_version="475587A.101",
    serial_number="EA212356638",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
)

_fsp_2 = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204301229",
    rus=[_rmod_7, _rmod_8],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASOE",
    hardware_version="A.101",
    serial_number="EA212356638",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[1],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH222244824",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_du_1 = DU(_smod_1)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.178.35"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)


_du_2 = DU(_smod_2)


_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.45.179.235"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.45.179.235", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.45.179.235", username="Nemuadmin", password="nemuuser", port=443
    ),
)


_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=53085, instance_id=53085)
_gnbs_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=19853, instance_id=19853)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.126", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.44.149.122", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1, _gnbs_2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_3xAQQJ_3xAHPJ_ASIL_ABIO_AHPB_AEQZ_GNB_UTECA",
    pdus=[_pdu_1, _pdu_2],
)

__all__ = ["tl"]
