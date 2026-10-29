__maintainer__ = "arunkumar.a@nokia.com"
__team__ = "MN_RAN_Pz_BLR_2_SG"
__email__ = "arunkumar.a@nokia.com"
__Owner_email__ = "arunkumar.a@nokia.com"

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
        addr="10.43.54.227", username="ute", password="ute"
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
                                                binary_path='/cygdrive/c/iperf/',
                                                server_close_delay='100',
                                                version=2, 
                                                dt_from_uepc=True,
                                                interface_name= 'Cellular 7',
                                                )           # default value is "False", if set to "True" dt is run from interface on ue pc
 
Quectel_UE_1 = TafUeAt(com_port='59',
                capabilities=['Quectel_UE_1'],
                ue_pc_address='10.53.164.144',
                ue_pc_login='inbabtslabuser',
                ue_pc_password='BT5l@bus3rl0g1n',
                ue_pc_expected_prompt='inbabtslabuser',
                class_name= PluginAtClassType.quectel,
                data_transfer=[_data_transfer_iperf],
                ue_pc_port='80')
Quectel_UE_2 = TafUeAt(com_port='5',
                capabilities=['Quectel_UE_2'],
                ue_pc_address='10.53.164.144',
                ue_pc_login='inbabtslabuser',
                ue_pc_password='BT5l@bus3rl0g1n',
                ue_pc_expected_prompt='inbabtslabuser',
                class_name= PluginAtClassType.quectel,
                data_transfer=[_data_transfer_iperf],
                ue_pc_port='80')

_IP_PDU_1 = RRB("10.41.155.166", [1,2])
_IP_PDU_1.pdu_ports[1].contactor = "NORMALLY_OPENED"
_IP_PDU_1.pdu_ports[2].contactor = "NORMALLY_OPENED"

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGB",
    serial_number="K9181925226",
    pdu_port=_IP_PDU_1.pdu_ports[2],
)
_bbmod_1 = CapacityUnit(
    addr="192.168.253.190",
    hardware_type="ABIO",
    serial_number="L1230613546",
    rus=[_rmod_1] 
)
_ASIB_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_bbmod_1],
    pdu_port=_IP_PDU_1.pdu_ports[1],
    hardware_type="ASIB",
    serial_number="DH203461256",
    test_pc=_test_pc_master,
)
_smod_1 = Airscale([_ASIB_1])
_enb_sbts_1 = RealEnb(system_module=_smod_1,
                     rms=[_rmod_1],
                     oam_ip=[NetworkAddress(v4="10.53.203.126")],
                     global_bts_id= "1832",
                     )
_test_pc_master.connections.append(Connection(interface="eth1", device=_enb_sbts_1.system_module.common_units[0], interface_type="lmp"))
tl = TestLine(
    test_pc=_test_pc_master,
    test_pcs=[_test_pc_master],
    enbs=[_enb_sbts_1],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIB_1ABIO_2AHEGA",
    ues=[Quectel_UE_1, Quectel_UE_2,],
)
__all__ = ["tl"]
