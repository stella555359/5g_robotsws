__maintainer__ = "UUF"
__team__ = "MN_RAN_Pz_3_WRO_3"
__email__ = "I_MN_RAN_PZ_3_WRO_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"

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
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

# smod port 5, 6
_pdu_sm = Gude(
    addr="10.42.77.244",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 10, 11, 12
_pdu_shared_ru_1 = Gude(
    addr="10.42.60.197",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_shared_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GND",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_shared_ru_1.pdu_ports[10],
)
_shared_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GR1",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_shared_ru_1.pdu_ports[11],
)
_shared_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2032G1GNN",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_shared_ru_1.pdu_ports[12],
)

_abia_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:1124",
    hardware_type="ABIA",
    hardware_version="473096A",
    serial_number="L1171612380",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_1],
    pdu_port=_pdu_sm.pdu_ports[6],
    hardware_type="ASIA",
    hardware_version="473095A",
    serial_number="L1171612380",
)

# ================================================  GNB  ==================
_cu_gnb_1 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.19.176",
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
        v4="10.42.19.176", v6="2a00:8a00:6000:6039:277:e4ff:fe12:e674", vlan_id=286
    ),
    x2u=NetworkAddress(
        v4="10.42.18.176", v6="2a00:8a00:6000:6039:277:e4ff:fe12:e674", vlan_id=285
    ),
    s1u=NetworkAddress(
        v4="10.42.21.176", v6="2a00:8a00:6000:603c:277:e4ff:fe12:e674", vlan_id=288
    ),
)

_abio_gnb_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0101",
    serial_number="L1204101488",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_1],
    pdu_port=_pdu_sm.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="473098A",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_shared_ru_1, _shared_ru_2, _shared_ru_3]
)

_enb_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[_shared_ru_1, _shared_ru_2, _shared_ru_3],
)
_pdus = [_pdu_sm, _pdu_shared_ru_1]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=6044, instance_id=6044
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.178", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_enb_lte.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.168", username="ute"),
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
    tl_cloud_topology="CLOUD_RFS_AIBR_B4_AIBL_B1_3AHLOA_UUF_1",
    enbs=[_enb_lte],
    pdus=_pdus,
)

__all__ = ["tl"]
