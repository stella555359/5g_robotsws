__maintainer__ = ""
__email__ = ""

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G

from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.172", username="ute", password="ute"
    ),
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.174", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_pdu_1 = Gude(
    addr="10.255.1.33",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_2 = Gude(
    addr="10.255.1.34",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_3 = Gude(
    addr="10.255.1.35",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_1.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[12].contactor = "NORMALLY_CLOSED"


_fsp_0 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1221800940",
)

_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9173814768",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="473096A.104",
    serial_number="EA194854635",
)

_fct_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_0],
    pdu_port=_pdu_2.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203601874",
)

_fct_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[12],
    hardware_type="ASIA",
    hardware_version="473095A.203",
    serial_number="L1171423753",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="K9173851729",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.127", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7170944805",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.126", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.FHEL.value,
    serial_number="EA165181782",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.121", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA171530033",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.123", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[8],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.FRGY.value,
    serial_number="EA170731303",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.9.119", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[9],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1T1R",
    radio_type=RadioTypes.AHFIC.value,
    serial_number="K9200421900",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)

_fsp_0.rus = ([_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5])
_fsp_1.rus = ([])
_fsp_2.rus = ([_rmod_6])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],
    oam_ip=NetworkAddress("10.15.247.39"),
    instance_id=10339,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_6],
    master=_enb_sbts_1,
)

_enb_sbts_1.slave = _enb_sbts_2

_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_sbts_2.system_module.common_units[0],
        interface_type="lmp",
    )
)

_bsc = BSC(
    name="BSC_KAISA_SBTS",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.92.249.108", username="TIMISO", password="TI2019"
    ),
)

_rnc = RNC(
    rnc_id=252,
    oms_ip=NetworkAddress("10.92.249.149"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.91.190.126", username="Nemuadmin", password="Nokia@123"
    ),
)


_app_server = TafUeAppServer(
    app_server_name="APP_1",
    address="10.5.26.74",
    user="ftp2_user1",
    password="Aikon_123456",
)

_data_transfer_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server, interval=1, server_close_delay=50
)

_android_1 = TafUeAndroid(
    serial_number="R58W20JHW7P",
    capabilities=["LTE_only"],
    ue_pc_address="10.5.60.218",
    data_transfer=[_data_transfer_iperf],
    ue_pc_port="5001",
    service_call_attach="16",
    service_call_detach="16",
    ssh_connection_details=SshServiceDetails(
        addr="10.5.60.218",
        username="wro5gqt",
        password="5Gqtmoth",
    ),
    network_mode_switch_method="adb",
    airplane_mode_switcher_text="Airplane",
    airplane_mode_confirm_button_text="OK",
    path_to_network_mode_type="Mobile networks/Preferred network type",
    secret_code="*#*#4636#*#*",
    is_rooted="no",
)


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    ues=[_android_1],
    tl_cloud_topology="CLOUD_SRAN_LWG_10339_1ASIA_2ABIA_2FXDB_1FHEL_2FRGY",
    bscs=[_bsc],
    rncs=[_rnc],
)


__all__ = ["tl"]
