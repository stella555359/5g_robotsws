__maintainer__ = "None"
__email__ = "None"

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
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.ran import BSC, RNC

import os
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.pdn import PDNTafUeAndroidDetails
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import TafUeAndroid

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.20.108", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.20.107", username="ute"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(
    addr="10.255.1.136",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_2 = Gude(
    addr="10.255.1.137",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)
_pdu_3 = APC(
    addr="10.255.1.138",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    #model="APC",
)
_pdu_4 = Gude(
    addr="10.255.1.139",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_4.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_4.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_3.pdu_ports[8].contactor = "NORMALLY_CLOSED"
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


_fsp_1 = CapacityUnit(
    addr="None",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1182901064",
)

_fsp_2 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="DH221046348",
)

_fsp_3 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214206771",
)

_fsp_4 = CapacityUnit(
    addr="None",
    hardware_type="ABIO",
    hardware_version="A.104",
    serial_number="L1214206732",
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_3.pdu_ports[3],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH220446050",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_3.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1214402627",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",  # ???
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7164314976",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA200357007",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.131", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[6],
)

_rmod_3 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA202356458",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[7],
)

_rmod_4 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="K9221000388",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.128", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[1],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="K9221000280",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[2],
)

_rmod_6 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7172701588",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.134", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)

_rmod_7 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7170929902",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.133", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_8 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQNA.value,
    serial_number="L1223806979",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.154", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[7],
)

_rmod_9 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQNA.value,
    serial_number="L1223804870",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.6", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[8],
)

_rmod_10 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQNA.value,
    serial_number="L1223804872",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.9.10", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[9],
)

_rmod_11 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221604145",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.2", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[11],
)

_rmod_12 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221604147",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.6", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[12],
)

_rmod_13 = RU(
    ru_hw_group="cMAAr6.2_64T64R",
    radio_type=RadioTypes.AQQL.value,
    serial_number="L1221709658",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.8.10", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[10],
)

_rmod_14 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARGA.value,
    serial_number="LR243207762",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[5],
)

_rmod_15 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="L1185109983",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_4.pdu_ports[2],
)

_rmod_16 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARPA.value,
    serial_number="F7195111541",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[11],
)

_rmod_17 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type=RadioTypes.ARPA.value,
    serial_number="F7195114439",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_1.pdu_ports[9],
)
_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_6, _rmod_7, _rmod_4, _rmod_5, _rmod_2, _rmod_3, _rmod_14, _rmod_15],
    oam_ip=NetworkAddress("10.15.236.158"),
    instance_id=10758,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_11, _rmod_12, _rmod_13, _rmod_8, _rmod_9, _rmod_10, _rmod_16, _rmod_17],
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_bsc = BSC(
    name="BSC_DHARANI",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.27.126.20", username="SYSTEM", password="SYSTEM"
    ),
)


_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"))



_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.26.71",
                               user="ftp1_user1",
                               password="Aikon_2022@#")


_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1)

_data_transfer_ping = TafUeDataTransferProtocol(protocol_name='ping',
                                                app_server=_app_server_1,
                                                interval=1)

_data_transfer_ftp = TafUeDataTransferProtocol(protocol_name='ftp',
                                               app_server=_app_server_1,
                                               interval=1)

_android1 = TafUeAndroid(serial_number='H0V9DE1CN01C1200077',
                         capabilities=['LTE_only'],
                         ue_pc_address='10.5.28.57',
                         data_transfer=[_data_transfer_iperf,
                                        _data_transfer_ping,
                                        _data_transfer_ftp],
                         ue_pc_port='80',
                         service_call_attach='16',
                         service_call_detach='16',
                         network_mode_switch_method='ADB',
                         airplane_mode_switcher_text='Airplane',
                         airplane_mode_confirm_button_text='OK',
                         path_to_network_mode_type='Mobile networks/Preferred network type',
                         secret_code='*#*#4636#*#*',
                         is_rooted='no')

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_SRAN_L_10758_1ASIB_2ABIA_1ABIO_1ASIB_2ABIO_3AHPMDA_2AREA_2ARGA_6AZNA",
    bscs=[_bsc],
    # rncs=[_rnc],
    ues=[_android1]
)

__all__ = ["tl"]
