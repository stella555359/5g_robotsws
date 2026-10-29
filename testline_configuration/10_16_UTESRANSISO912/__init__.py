__maintainer__ = "Przemyslaw Kempa"
__email__ = "przemyslaw.kempa@nokia.com"

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
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.44.167.18", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.44.167.56", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3 = Gude("10.44.167.54", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHEGA.value,
    serial_number="K9190221265",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2339N49QC",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)


_fsp_1 = CapacityUnit(
    addr="192.168.252.6",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1173007583",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_1, _rmod_2],
)

_fsp_2 = CapacityUnit(
    addr="192.168.252.6",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213114806",
    pdu_port=_pdu_1.pdu_ports[2],
)

_fsp_3 = CapacityUnit(
    addr="192.168.252.6",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1215008483",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIL",
    hardware_version="474767A.103",
    serial_number="L1224102514",
)

_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
    ],
    oam_ip=NetworkAddress("10.44.166.44"),
    instance_id=1052,
)

_app_server_1 = TafUeAppServer(
    app_server_name="IPERF_WG",
    address="10.44.184.246",
    user="ranpz4",
    # bind_interface_ip="10.42.129.2",
    password="pass4Pezet$ry",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    # bind_ue_ip='10.42.129.2',
    version=3,
)

_android1 = TafUeAndroid(
    serial_number="xxx",
    ue_pc_address="xxx",
    data_transfer=[_data_transfer_iperf],
    capabilities=["xxx"],
    ue_pc_port="9090",
    network_mode_switch_method="keyevents",
    airplane_mode_switcher_text="Airplane mode",
    is_rooted="no",
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.189", username="ute"),
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
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO912",
    ues=[_android1],
)

__all__ = ["tl"]
