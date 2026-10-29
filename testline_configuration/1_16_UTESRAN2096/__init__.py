__maintainer__ = "UUF"
__team__ = "I_MN_RAN_RD_VRF_WRO3_3"
__email__ = "I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com"
__owner_email__ = "tomasz.szylkowski@nokia.com"
__customer__ = "TMO US"
__bucket__ = "Special"
__rack__ = "GTA-1046"

from taf.config.testline.connection_details import HttpConnectionDetails
from taf.config.testline import NetworkAddress
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
from taf.config.testline.lmi import SerialOverTcp, Remote


# smod port 5, 6
_pdu_1 = Gude(
    addr="10.42.199.246",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)
# rm port 4, 5, 6
_pdu_2 = Gude(
    addr="10.42.60.195",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdus = [_pdu_1, _pdu_2]

# ************************************************ RMs *************************************************

_ahloa1 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2050G1SQL",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[4],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.14", port=5001),
        ]
    ),
)
_ahloa2 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2050G1SO2",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[5],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.16", port=5001),
        ]
    ),
)
_ahloa3 = RU(
    ru_hw_group="FRMr5.1a_2_4T4R_TrueWB",
    radio_type="AHLOA",
    serial_number="BL2050G1SQP",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_2.pdu_ports[6],
    lmi=SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.26.15", port=5001),
        ]
    ),
)

# ************************************************ ENB1 ************************************************

_abia1 = CapacityUnit(
    addr="172.16.9.129",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172906427",
    rus=[_ahloa1, _ahloa2, _ahloa3],
)

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1173014143",
    capacity_units=[_abia1],
    pdu_port=_pdu_1.pdu_ports[6],
)

_real_asia = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    rms=[_ahloa1, _ahloa2, _ahloa3],
    global_bts_id=1903, instance_id=1903
)

# ************************************************ GNB1 ************************************************

_abil1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1203900898",
    rus=[_ahloa1, _ahloa2, _ahloa3],
)

_asik = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIK",
    hardware_version="474021A.102",
    serial_number="L1201003687",
)

_airscale_asik = Airscale(common_units=[_asik])

_du_asik = DU(airscale=_airscale_asik, rus=[_ahloa1, _ahloa2, _ahloa3])

_cu_asik = CU(
    backhaul_site_oam_ip="10.42.19.182",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.42.19.182", v6="", vlan_id=286),
    x2u=NetworkAddress(v4="10.42.18.182", v6="", vlan_id=285),
    s1u=NetworkAddress(v4="10.42.21.182", v6="", vlan_id=288),
)

_classical_asik = ClassicalBts(
    cu=_cu_asik, dus=[_du_asik], global_bts_id=6050, instance_id=6050
)

# ************************************************ VMs ************************************************

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.250.184", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_airscale_asik.common_units[0],
            interface_type="lmp",
        )
    ],
)

_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.250.174", username="ute"),
    connections=[
        Connection(
            interface="eth1",
            device=_real_asia.system_module.common_units[0],
            interface_type="lmp",
        )
    ],
)
# ************************************************ SUM ************************************************

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    gnbs=[_classical_asik],
    tl_cloud_topology="CLOUD_RFS_AIR_B4_ASIKL_B1_3AHLOA_UUF_3_UTECA",
    enbs=[_real_asia],
    pdus=_pdus,
)

__all__ = ["tl"]
