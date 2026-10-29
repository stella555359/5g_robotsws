__maintainer__ = "arunkumar.a@nokia.com"
__team__ = "MN_RAN_Pz_BLR_2_SG"
__email__ = "arunkumar.a@nokia.com"

from taf.config.testline.airscale import CapacityUnit, CommonUnit, Airscale
from taf.config.testline.connection_details import SshServiceDetails, TelnetConnectionDetails
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import Gude, RRB
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAt, PluginAtClassType
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol

_test_pc_master = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.43.54.217", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.129")],
)
# taf.ue
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.58.241.84",
                               user="ftpuser",
                               password="ftpuser",
                               expected_prompt="ftpuser"
                            )

_data_transfer_iperf = TafUeDataTransferProtocol(protocol_name='iperf',   # this class will be replaced with TafUeDataTransferProtocol in the next release
                                                app_server=_app_server_1,
                                                interval=1,
                                                binary_path='C:/iperf/iperf.exe',
                                                server_close_delay='100',
                                                version=2, 
                                                dt_from_uepc=True,
                                                interface_name= 'Cellular 14',
                                                )           # default value is "False", if set to "True" dt is run from interface on ue pc
 

Quectel_UE_1 = TafUeAt(com_port='7',
                capabilities=['Quectel_UE_1'],
                ue_pc_address='10.53.203.91',
                ue_pc_login='inbabtslabuser',
                ue_pc_password='BT5l@bus3rl0g1n',
                ue_pc_expected_prompt='inbabtslabuser',
                class_name= PluginAtClassType.quectel,
                data_transfer=[_data_transfer_iperf],
                ue_pc_port='80')
Quectel_UE_2 = TafUeAt(com_port='25',
                capabilities=['Quectel_UE_2'],
                ue_pc_address='10.53.203.91',
                ue_pc_login='inbabtslabuser',
                ue_pc_password='BT5l@bus3rl0g1n',
                ue_pc_expected_prompt='inbabtslabuser',
                class_name= PluginAtClassType.quectel,
                data_transfer=[_data_transfer_iperf],
                ue_pc_port='80')
Quectel_UE_3 = TafUeAt(com_port='62',
                capabilities=['Quectel_UE_3'],
                ue_pc_address='10.53.203.91',
                ue_pc_login='noklab\inbabtslabuser',
                ue_pc_password='BT5l@bus3rl0g1n',
                ue_pc_expected_prompt='inbabtslabuser',
                class_name= PluginAtClassType.quectel,
                data_transfer=[_data_transfer_iperf],
                ue_pc_port='80')


_IP_PDU_1 = RRB("10.41.155.176", [1,2,3])
_IP_PDU_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[2].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[3].contactor = "NORMALLY_OPENED"
#_pdus = [_IP_PDU_1, _IP_PDU_2]
_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA213650574 ",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="EA213650568",
    pdu_port=_IP_PDU_1.pdu_ports[3],
)

_bbmod_1 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIP",
    serial_number="L1232907578",
    rus=[_rmod_1, _rmod_2] 
)

_bbmod_2 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIA",
    serial_number="L1170412477",
    rus=[_rmod_2] 
)
sysmod = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1, _bbmod_2],
    pdu_port=_IP_PDU_1.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="DH212871553",
    test_pc=_test_pc_master,
)
_smod_1 = Airscale([sysmod])
_enb_sbts_1 = RealEnb(system_module=_smod_1,
                    rms=[_rmod_1, _rmod_2],
                    oam_ip=[NetworkAddress(v4="10.53.203.195")]
                    )
_test_pc_master.connections.append(Connection(interface="eth1", 
                                            device=_enb_sbts_1.system_module.common_units[0],
                                            interface_type="lmp")
                                )
tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master],
#    pdus=_pdus,
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIM_1ABIP_2AREA",
    ues=[Quectel_UE_1, Quectel_UE_2, Quectel_UE_3],
)
__all__ = ["tl"]
