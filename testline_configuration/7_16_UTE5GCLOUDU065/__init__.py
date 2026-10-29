__maintainer__ = "Michal Hadrysiak"
__owner_email__ = "michal.hadrysiak@nokia.com"
__team__ = "pz2wro3"
__email__ = "michal.hadrysiak@nokia.com"

import os
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts


_pdu_1 = Gude("10.44.205.205", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "")


_ru1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="K9184308067",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.206", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[1],
)
_ru2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2120V0D3F",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.207", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[2],
)
_ru3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHFIB.value,
    serial_number="BL2043V0PX4",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="192.168.253.210", port=2323
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_1.pdu_ports[3],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204604563",
    rus=[_ru1],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266A.102",
    serial_number="L1204706775",
    rus=[_ru2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.30",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1214403561",
    rus=[_ru3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.46",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173716155",
    rus=[_ru1],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173313947",
    rus=[_ru2],
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163607880",
    rus=[_ru3],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201100993",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIB",
    hardware_version="473095A.203",
    serial_number="L1171209493",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_du_1 = DU(_smod_1, rus=[_ru1, _ru2, _ru3])
_cu_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.44.95.102"),  # 5G M-plane
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)


_gnbs_1 = ClassicalBts(
    cu=_cu_1, dus=[_du_1], global_bts_id=4053, instance_id=4053
)  # 5G


_enb_sbts_1 = RealEnb(
    system_module=_smod_2,
    rms=[_ru1, _ru2, _ru3],
    oam_ip=NetworkAddress("10.44.95.102"),
    master=_gnbs_1,
)

_gnbs_1.slave = _enb_sbts_1


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.53.20", username="ute"),
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
    SshServiceDetails(addr="10.42.53.21", username="ute"),
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
    enbs=[_enb_sbts_1],
    gnbs=[_gnbs_1],
    pdus=[_pdu_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xASIB_3xABIO_3xABIA_3xAHFIB",
)

__all__ = ["tl"]
