__maintainer__ = "Mateusz Chryplewicz"
__team__ = "siso"
__email__ = "mateusz.chryplewicz@nokia.com"

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


_pdu_1 = Gude(
    "10.44.167.116", [2], "EPC", "8220-1"
)  # port2 ASIB_426
_pdu_2 = Gude(
    "10.44.167.116", [3], "EPC", "8220-1"
)  # FXDB_385
_pdu_3 = Gude(
    "10.44.167.117", [12], "EPC", "8220-1"
) # FXDB_616
_pdu_4 = Gude(
    "10.44.167.103", [8], "EPC", "8220-1"
) # AHEGC_238
_pdu_5 = Gude(
    "10.44.167.106", [5, 6], "EPC", "8220-1"
) # AHEGC_131  AHEGC_567

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    serial_number="EA202453567",  # AHEGC_567
    pdu_port=_pdu_5.pdu_ports[6],
    radio_type="AHEGC",
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    serial_number="EA214454238",  # AHEGC_238
    pdu_port=_pdu_4.pdu_ports[8],
    radio_type="AHEGC",
)
_rmod_3 = RU(
    ru_hw_group="FRMrRH5.1_4T4R",
    serial_number="EA200262131",  # AHEGC_131
    pdu_port=_pdu_5.pdu_ports[5],
    radio_type="AHEGC",
)
_rmod_4 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    serial_number="F7160919385",  # FXDB_385
    pdu_port=_pdu_2.pdu_ports[3],
    radio_type="FXDB",
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R",
    serial_number="F7164310616",  # FXDB_616
    pdu_port=_pdu_3.pdu_ports[12],
    radio_type="FXDB",
)

_fsp_1 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1172817760",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_1, _rmod_2, _rmod_3],
)

_fsp_2 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1163605467",
    pdu_port=_pdu_1.pdu_ports[2],
    rus=[_rmod_4, _rmod_5],
)

_fsp_3 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIA",
    serial_number="L1172911400",
    pdu_port=_pdu_1.pdu_ports[2],
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[2],
    hardware_type="ASIB",
    serial_number="L1201002875",
)


_smod_1 = Airscale([_fct_1])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
    ],
    oam_ip=NetworkAddress("10.42.67.29"),
    instance_id=1166,
)

_bsc = BSC(
    name="asBSC-25",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.196.183", username="VRFUSER", password="VRFPASSWORD"
    ),
)

_app_server_1 = TafUeAppServer(  # IPERF MODULE - link to shared Iperf/FTP servers maintained by SRN you can find below this section
    app_server_name="gta-srn-appserver-985",  # set iperf server name    NOTE: When you using ANP from WG then you must use Iperf from WG. Same for the case of APN GT <-> Iperf GT
    address="10.44.184.246",  # set iperf IP address
    user="ranpz",  # set iperf username
    password="Pass4Testers!",  # set iperf password
    # bind_interface_ip="10.42.129.2",                                             # [OPTIONAL] if any server requires bind interface then set appropriate IP address
)  # END IPERF MODULE

_data_transfer_iperf = TafUeDataTransferProtocol(  # DATA TRANSFER MODULE
    protocol_name="iperf",  # protocol - don't change
    app_server=_app_server_1,  # set server from previous module
    interval=1,  # iperf package interval - don't change
    server_close_delay=50,  # server close delay - don't change
    version=3,  # set iperf version
    # bind_interface_ip="10.42.129.2",                                            # [OPTIONAL] if any server requires bind interface then set appropriate IP address
)  # END DATA TRANSFER MODULE

_android1 = TafUeAndroid(  # FIRST UE MODULE
    serial_number="9f2414c",  # set UE serial number
    ue_pc_address="10.42.36.124",  # set IP address your UE PC
    data_transfer=[
        _data_transfer_iperf
    ],  # choice of data transfer method - don't change
    capabilities=["9f2414c"],  # choice UE -  set UE serial number
    ue_pc_port="9090",  # set port number on which you run the proxy on UE PC
    proxy_mngr_port="9955",  # set port number on which you run proxy manager on UE PC
    network_mode_switch_method="adb",  # UE control method - choose "adb" or "keyevents". The version using "keyevents" can be found below in SECOND UE MODULE
    is_rooted="no",  # whether UE is rooted - set "yes" or "no" depending on whether your UE is rooted
)  # END FIRST UE MODULE

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.100", username="ute"),  # BTSID 1166
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
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO808INDOSAT",
    bscs=[_bsc],
)


__all__ = ["tl"]
