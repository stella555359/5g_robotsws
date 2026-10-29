__maintainer__ = "Igor Kleschenok"
__email__ = "igor.kleschenok@nokia.com"
__owner_email__ = "igor.kleschenok@nokia.com"
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


pdu = Gude("10.44.143.13", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="K9200421909",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.128", port=2323
    ),
    pdu_port=pdu.pdu_ports[6],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="K9200421908",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.130", port=2323
    ),
    pdu_port=pdu.pdu_ports[7],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="K9200421904",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.132", port=2323
    ),
    pdu_port=pdu.pdu_ports[8],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AOW",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.133", port=2323
    ),
    pdu_port=pdu.pdu_ports[3],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL2027G1AQ8",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.41.129", port=2323
    ),
    pdu_port=pdu.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHLOA.value,
    serial_number="BL1920G10JO",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.131", port=2323
    ),
    pdu_port=pdu.pdu_ports[5],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204701025",
    rus=[_rmod_1,_rmod_2,_rmod_3,_rmod_4,_rmod_5,_rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1171221080",
    rus=[],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1171121869",
    rus=[],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204101544",
    rus=[_rmod_4,_rmod_5,_rmod_6],
)


_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=pdu.pdu_ports[1],
    hardware_type="ASIM",
    hardware_version="475765A.Y13",
    serial_number="L1223403843",
)
_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=pdu.pdu_ports[2],
    hardware_type="ASIM",
    hardware_version="475765A.Y13",
    serial_number="L1223403850",
)


_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])




_du_1 = DU(_smod_1, rus=[_rmod_4, _rmod_5, _rmod_6])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.42.25.245"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(
    cu=_cu_1, dus=[_du_1], global_bts_id=4040, instance_id=4040
)  # 5G

_enb_sbts_1 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6],
    oam_ip=NetworkAddress("10.42.24.245"),
    global_bts_id=19841,
    instance_id=19841,
)

_ue_pc_ssh = SshServiceDetails("10.44.128.77", "sranwro2", password="Ru1eTheAir!2")

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.99", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_gnbs_1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.109", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIM_ABIO_3AHFIC_3AHLOA_ENB",
    pdus=[pdu],
)

__all__ = ["tl"]
