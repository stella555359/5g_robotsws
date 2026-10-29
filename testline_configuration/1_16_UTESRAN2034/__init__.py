__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "AT&T"
__bucket__ = "x"

from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline.airscale import Airscale
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU
from taf.config.testline.testline import TestLine
from taf.config.testline import Connection
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.testpc import TestPc

# smod port
# rm port 1, 2, 3, 4, 5, 6, 9, 10
_pdu_1 = Gude(
    addr="10.42.80.37",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_lte_ru1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIA",
    serial_number="K9192534008",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)

_lte_ru2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIA",
    serial_number="K9194625967",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[10],
)

_gnb_shared_ru1 = RU(
    ru_hw_group="UHIE",
    radio_type="UHIE",
    serial_number="LBALLU-YD192410737",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.66", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_gnb_shared_ru2 = RU(
    ru_hw_group="UHIE",
    radio_type="UHIE",
    serial_number="LBALLU-YD192410738",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.67", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_gnb_shared_ru3 = RU(
    ru_hw_group="UHIE",
    radio_type="UHIE",
    serial_number="LBALLU-YD192410734",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.68", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[3],
)

_gnb_shared_ru4 = RU(
    ru_hw_group="UHFA",
    radio_type="UHFA",
    serial_number="LBALLU-YD17450P7RD",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_gnb_shared_ru5 = RU(
    ru_hw_group="UHFA",
    radio_type="UHFA",
    serial_number="LBALLU-YD17450P7LH",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.35", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[5],
)

_gnb_shared_ru6 = RU(
    ru_hw_group="UHFA",
    radio_type="UHFA",
    serial_number="LBALLU-YD17450P7LQ",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.36", username="", password="", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[4],
)

_abia_1 = CapacityUnit(
    addr="192.168.253.32",
    serial_number="L1173915559",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    rus=[_lte_ru1, _lte_ru2],
)

_abia_2 = CapacityUnit(
    addr="192.168.253.36",
    serial_number="L1194900564",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    rus=[
        _gnb_shared_ru1,
        _gnb_shared_ru2,
        _gnb_shared_ru3,
        _gnb_shared_ru4,
        _gnb_shared_ru5,
        _gnb_shared_ru6,
    ],
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1, _abia_2],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="K9181029132",
)

# ================================================  GNB  ==================


_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.149",
        vlan_id="286",
        routing=RoutingInformation(gateway="10.42.19.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.42.19.149", v6="2a00:8a00:6000:603a:277:e4ff:fe08:4095", vlan_id=286
    ),
    x2u=NetworkAddress(
        v4="10.42.18.149", v6="2a00:8a00:6000:6039:277:e4ff:fe08:4095", vlan_id=285
    ),
    s1u=NetworkAddress(
        v4="10.42.21.149", v6="2a00:8a00:6000:603c:277:e4ff:fe08:4095", vlan_id=288
    ),
)

_abil_gnb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1200401614",
    rus=[
        _gnb_shared_ru4,
        _gnb_shared_ru5,
        _gnb_shared_ru6,
    ],
)

_abil_gnb_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIL",
    hardware_version="474020B.101",
    serial_number="L1194704721",
    rus=[
        _gnb_shared_ru1,
        _gnb_shared_ru2,
        _gnb_shared_ru3,
    ],
)

_asik_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_gnb_1, _abil_gnb_2],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIK",
    hardware_version="474021A.103",
    serial_number="L1204606607",
)

_airscale_gnb_1 = Airscale(common_units=[_asik_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[
        _gnb_shared_ru1,
        _gnb_shared_ru2,
        _gnb_shared_ru3,
        _gnb_shared_ru4,
        _gnb_shared_ru5,
        _gnb_shared_ru6,
    ],
)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[
        _lte_ru1,
        _lte_ru2,
        _gnb_shared_ru1,
        _gnb_shared_ru2,
        _gnb_shared_ru3,
        _gnb_shared_ru4,
        _gnb_shared_ru5,
        _gnb_shared_ru6,
    ],
)
_pdus = [_pdu_1]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=54002, instance_id=54002
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.133.229", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_lte.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.133.91", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_gnb_1.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_RFS_AIR_B4_B5_ASIKL_B1_B2_3xUHIE_3xUHFA_2xAHFIA_UTECA",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
