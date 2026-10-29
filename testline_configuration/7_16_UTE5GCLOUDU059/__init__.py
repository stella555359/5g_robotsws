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
    addr="10.44.177.227",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.44.205.183",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.205.184",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_4 = Gude(
    addr="10.44.205.229",
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
    serial_number="1M231207675",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr=" 172.22.0.2", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[5],
)

_rmod_2 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    radio_type=RadioTypes.AQQJ.value,
    serial_number="1M233608965",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_3 = RU(
    ru_hw_group="cMAAr6.1_32T32R_eCPRI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="serviceuser",
        password="v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=",
    ),
    radio_type=RadioTypes.AQQJ.value,
    serial_number="1M231207671",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.10", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9231307353",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPB.value,
    serial_number="EA222355913",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="root"
    ),
    radio_type=RadioTypes.AHPJ.value,
    serial_number="K9231302139",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_rmod_7 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.154",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    radio_type=RadioTypes.AEQZ.value,
    serial_number="1M222539748",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.154", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[12],
)


_fsp_1 = CapacityUnit(
    addr="192.168.255.1",
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213153979",
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
)


_fsp_2 = CapacityUnit(
    addr="192.168.255.1",
    hardware_type="ASOE",
    hardware_version="475587A.102",
    serial_number="EA213353962",
    rus=[_rmod_6, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA213153979",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASOE",
    hardware_version="A.102",
    serial_number="EA213353962",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_du_1 = DU(_smod_1)


_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.206"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)


_du_2 = DU(_smod_2)


_cu_2 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.207.243"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.44.207.243", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.44.207.243", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=4020, instance_id=4020)
_gnbs_2 = ClassicalBts(cu=_cu_2, dus=[_du_2], global_bts_id=55230, instance_id=55230)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.249", username="ute"),
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
    SshServiceDetails(addr="10.42.53.121", username="ute"),
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
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_3xAQQJ_1xAHPJ_1xAHPB_GNB_UTECA",
    pdus=[_pdu_1, _pdu_2, _pdu_3],
)

__all__ = ["tl"]
