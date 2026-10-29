__owner__ = "ancuta.muresan@nokia@nokia.com"
__maintainer__ = "ancuta.muresan@nokia@nokia.com"
__email__ = "ancuta.muresan@nokia@nokia.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import Gude, FPFH, PSU
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit, CoreUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.dcap import DcapRnD, DcapBasic
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.lmi import SerialOverHost,SerialOverTcp,Local, Remote
from taf.config.testline import NetAct

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.5.21.194", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.5.21.195", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)
_pdu_1 = Gude("10.255.2.111", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_2 = Gude("10.255.2.112", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8220-1")
_pdu_1.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_rmod_6 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHEH.value,
    serial_number="EA201954818",
    pdu_port=_pdu_2.pdu_ports[2],
)

_rmod_9 = RU(
    ru_hw_group="",
    radio_type=RadioTypes.AHPE.value,
    serial_number="1M202303582",
    pdu_port=_pdu_2.pdu_ports[10],
)

_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="B.101",
    serial_number="L1200807021",
    rus=[_rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="B.102",
    serial_number="EA210255369",
    rus=[_rmod_9],    
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIQ",
    hardware_version="A.102",
    serial_number="L1233103984",
    rus=[_rmod_6],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    hardware_version="A.102",
    serial_number="L1204605738",
    rus=[_rmod_9],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[7],
    hardware_type="ASIK",
    hardware_version="A.101",
    serial_number="L1204302086",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3, _fsp_4],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1204107367",
    test_pc=_test_pc_2,
)
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_netact_ssh_2002 = SshServiceDetails(
    addr="10.82.47.15", username="omc", password='Medsql!_1893'
)
   
_netact_http_2002 = HttpConnectionDetails(
    addr="srnclab2002lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_2002 = NetAct(_netact_ssh_2002, _netact_http_2002)

_netact_ssh_1052 = SshServiceDetails(
    addr="10.63.2.155", username="omc", password='Medsql!_1893'
)

_netact_http_1052 = HttpConnectionDetails(
    addr="srnclab1052lbwas.srnblr.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_1052 = NetAct(_netact_ssh_1052, _netact_http_1052)

_netact_ssh_5012 = SshServiceDetails(
    addr="10.8.103.177", username="omc", password='Medsql!_1893'
)

_netact_http_5012 = HttpConnectionDetails(
    addr="srnclab5012lbwas.srntre.nsn-rdnet.net", username="omc", password="Medsql!_1893"

)
_netact_5012 = NetAct(_netact_ssh_5012, _netact_http_5012)


#_dcap_1 = DcapRnD(
#    HttpConnectionDetails(
#        addr="10.5.21.194", port="9443", username="dcapuser", password="dcapadmin!"
#    )
#)



_cu_1 = CU(
    backhaul_site_oam_ip="None",
    oam_ssh_connection_details=SshServiceDetails(
        addr="None", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="None", username="Nemuadmin", password="nemuuser"
    ),
)
_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_6 ,_rmod_9],
    instance_id=623122,
#    dcap=_dcap_1,
)
_test_pc_1.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_1.system_module.common_units[0],
        interface_type="lmp",
    )
)

_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_6, _rmod_9],
    instance_id=624122,
#    dcap=_dcap_1,
)
_test_pc_2.connections.append(
    Connection(
        interface="eth1",
        device=_enb_lte_2.system_module.common_units[0],
        interface_type="lmp",
    )
)
_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp4_5g",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.140")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)                                                 

_android1 = TafUeAndroid(serial_number='AQKSLVH040M93000067',
                         ue_pc_address='10.5.55.134',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.55.134',
                                                                  username='rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['SBTS2_LTE_PC419'])

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1,_test_pc_2],
    enbs=[_enb_lte_1, _enb_lte_2],
    bscs=[None],
    rncs=[None],
    tl_cloud_topology="CLOUD_10_18_UTESRANRFSMTNRL122",
    ues=[_android1],
    nms=_netact_5012,
)

CELL_TARGET_BW_PATH = ("/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL122/cell_target_bw.yaml")
                         
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "POWER_ON_FLAG": True,
    "fail_if_wrn_threshold": True,
    "SYSLOG_CHECK": False,
#    "USER_DCAP_TRACE_COLLECT": False,
#    "USER_DCAP_TRACE_COLLECT_Master": False,
#    "USER_DCAP_TRACE_COLLECT_Slave": False,
}
__all__ = ["tl"]
