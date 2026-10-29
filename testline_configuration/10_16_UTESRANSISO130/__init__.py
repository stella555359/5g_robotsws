__maintainer__ = "Tomasz Pawlaczyk"
__email__ = "tomasz.pawlaczyk@nokia.com"

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
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection

_pdu_1 = Gude("10.42.168.99", [12], "EPC", "8221-1")
_pdu_2 = Gude("10.42.168.84", [9, 10, 11, 12], "EPC", "8221-1")  # 10-FXJB  11-FXFC  12- AZRB
_pdu_3 = Gude("10.42.168.98", [9], "EPC", "8220-1")    #9-AHPMDG_018
_pdu_4 = Gude("10.42.212.17", [11,12], "EPC", "8220-1")   #11-AHPMDG_020  12-AHPMDG_015

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="FXFC",
    serial_number="F7190428988",
    pdu_port=_pdu_2.pdu_ports[11],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="FXFC",
    serial_number="F7171223043",
    pdu_port=_pdu_2.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="FXJB",
    serial_number="K9171116609",
    pdu_port=_pdu_2.pdu_ports[10],
)

_rmod_4 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    radio_type="AZRB",
    serial_number="AH191500379",
    pdu_port=_pdu_2.pdu_ports[12],
)

_rmod_5 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="YK223200018",
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_6 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="YK223200020",
    pdu_port=_pdu_4.pdu_ports[11],
)

_rmod_7 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHPMDG",
    serial_number="YK223200015",
    pdu_port=_pdu_4.pdu_ports[12],
)

_fsp_1 = CapacityUnit(
    addr="192.168.255.129",
   hardware_type="ABIA",
   hardware_version="473096A.103",
   serial_number="L1171216177",
   pdu_port=_pdu_1.pdu_ports[12],
   rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
)  # Fake BBMOD

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASOG",
    hardware_version="A.101",
    serial_number="L1241503064",
)

_smod_1 = Airscale([_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_7],
    oam_ip=NetworkAddress("10.42.175.63"),
    instance_id=1303,
)

_rnc = RNC(
    rnc_id=25,
    oms_ip=NetworkAddress("10.44.44.219"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.28.72", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC21",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.28.126", username="PZUSER", password="pzpassword"
    ),
)

_app_server_1 = TafUeAppServer(
    app_server_name="IPERF_TMP_GT",
    address="10.42.249.116",
    bind_interface_ip="10.42.249.116",
    user="syslab",
    password="Pass4System!",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_app_server_1,
    interval=1,
    server_close_delay=50,
    bind_ue_ip="10.42.249.116",
    version=3,
)

_android1 = TafUeAndroid(
    serial_number="A00000P660211300032",
    ue_pc_address="10.42.172.177",
    data_transfer=[_data_transfer_iperf],
    capabilities=["A00000P660211300032"],
    ue_pc_port="9089",
    proxy_mngr_port=9955,
    network_mode_switch_method="ADB",
    is_rooted="no",
)


__all__ = ["tl"]


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.78", username="ute", password="UTE.debian12"),
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO130",
    bscs=[_bsc],
    rncs=[_rnc],
    ues=[_android1],
)


__all__ = ["tl"]
