# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "Szymon Startek"
__email__ = "szymon.startek@nokia.com"
__owner_email__ = "szymon.startek@nokia.com"
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
    addr="10.44.205.181",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.44.177.86",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_3 = Gude(
    addr="10.44.177.85",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AEQE.value,
    serial_number="1M222319491",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AQQK.value,
    serial_number="L1221705856",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.2.2", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AEHC.value,
    serial_number="K9221730212",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.6", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)
_rmod_4 = RU(
    ru_hw_group="cMAAr6.2 64T64R",
    radio_type=RadioTypes.AQQQA.value,
    serial_number="YK224500037",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.0.162", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEGC.value,
    serial_number="EA210351036",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)
_rmod_7 = RU(
    ru_hw_group="cMMAr6.1_8T8R_eCPRI",
    radio_type=RadioTypes.AZHL.value,
    serial_number="K9200421904",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.1.10", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)
_rmod_6 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="AH212600299",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="475792A.102",
    serial_number="L1234301764",
    rus=[_rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223310000",
    rus=[_rmod_1, _rmod_3, _rmod_4],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309879",
    rus=[_rmod_2, _rmod_5, _rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1203700874",
)

_smod_1 = Airscale([_fct_1])

_du_1 = DU(_smod_1)
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.95.121"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_gnbs_1 = ClassicalBts(cu=_cu_1, dus=[_du_1], global_bts_id=55014, instance_id=55014)

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_5,
    ],
    oam_ip=NetworkAddress("10.44.95.121"),
    global_bts_id=55014,
    instance_id=55014,
)


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.44.149.121", username="ute"),
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
    test_pcs=[_test_pc_1],
    gnbs=[_gnbs_1],
    enbs=[_enb_sbts_1],
    pdus=[_pdu_1, _pdu_2, _pdu_3],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_2xABIO_ABIL_AEQE_AEHC_AQQK_AQQQA_AZHL_AHEGC",
)

__all__ = ["tl"]
