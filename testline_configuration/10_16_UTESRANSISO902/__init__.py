__maintainer__ = "Mateusz Kawka"
__email__ = "mateusz.kawka@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection


_pdu_1 = Gude("10.42.168.101", [1, 2, 3], "EPC", "8220-1")
_pdu_2 = Gude("10.42.169.6", [4, 5], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="FRMr3.3_3T6R",
    radio_type=RadioTypes.AHLOB,
    serial_number="BL2244D50Y4",
    pdu_port=_pdu_1.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    radio_type=RadioTypes.AWHQN,
    serial_number="AH242307925",
    pdu_port=_pdu_1.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    radio_type=RadioTypes.AHEB,
    serial_number="L1181207093",
    pdu_port=_pdu_1.pdu_ports[3],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163715537",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223303275",
    rus=[_rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="L1163914316",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172902324",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309850",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1220804863",
    rus=[_rmod_1, _rmod_3],
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_5],
    pdu_port=_pdu_2.pdu_ports[5],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224102499",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A.103",
    serial_number="L1224102498",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_2],
    oam_ip=NetworkAddress("10.42.175.22"),
    instance_id=1305,
)
_enb_sbts_2 = RealEnb(system_module=_smod_2, rms=[_rmod_1, _rmod_3], master=_enb_sbts_1)
_enb_sbts_1.slave = _enb_sbts_2


# _rnc = RNC(
#     rnc_id=34,
#     oms_ip=NetworkAddress("10.44.44.250"),
#     logging_ssh_connection_details=SshServiceDetails(
#         addr="10.44.44.90", username="SYSTEM", password="SYSTEM"
#     ),
# )

# _bsc = BSC(
#     name="BSC_mcBSC32",
#     logging_telnet_connection_details=TelnetConnectionDetails(
#         addr="10.42.215.4", username="SYSTEM", password="SYSTEM"
#     ),
# )

_app_server_1 = TafUeAppServer(
    app_server_name="IPERF_WG",
    address="10.44.184.246",
#    bind_interface_ip="10.45.168.53",
    user="syslab",
    password="Pass4System!",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, server_close_delay=50
)

_android1 = TafUeAndroid(
    serial_number="H2J9FI1G803B1400024",
    ue_pc_address="10.42.172.133",
    data_transfer=[_data_transfer_iperf],
    capabilities=["H2J9FI1G803B1400024"],
    #    ue_pc_port="9090",
    proxy_mngr_port="9955",
    network_mode_switch_method="adb",
    is_rooted="no",
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.109", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.184.110", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO902",
    ues=[_android1],
)

__all__ = ["tl"]
