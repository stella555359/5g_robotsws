#Here you have a template for TAF config format in LTE-GSM/WCDMA-LTE/NR-LTE/NR-NR/SBTS Cases.
# Spacing and indentation MUST be taken into account, otherwise Gerrit commits will FAIL
# Please remove ALL comments before any commit
 
# add your email to the following 3 lines
__maintainer__ = "adelina.terteci@nokia.com"
__owner__ = "adelina.terteci@nokia.com"
__email__ = "adelina.terteci@nokia.com"
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, APC
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.fhs import FHS, FhsType
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.ran import RNC
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.optical_switch import Calient
from taf.config.testline.dcap import DcapRnD, DcapBasic
import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
 
# TestPc class defines details about VMs/PC UEs connected to eNB
# Data you need to provide: VM ip, username, pass(defined in Cloud Manager user profile settings), eth1 lmp ip
# You can create as many TestPc objects as you need (for VM1, VM2, PC UE). NetworkAddress for VM2 (192.168.255.130) and for PC (192.168.255.131)
_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.145", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.146", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_3 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.147", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_4 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.148", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# Gude class for PDU defining.

_pdu_1 = Gude("10.255.5.12", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_2 = Gude("10.255.5.13", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1")
_pdu_1.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_pdu_1.pdu_ports[12].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[6].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[7].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[8].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[10].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[11].contactor = "NORMALLY_CLOSED"

# RU class for RMOD defining.
# Data you need to provide: RMOD type (FHEB, FXDB, etc), serial number, IP address, PDU port where it is connected
# You can create as many RU objects as you need (in case of multiple RMODs)
_rmod_1 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7174840571",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_2 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7172002026",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_3 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type=RadioTypes.FRPA.value,
    serial_number="EA194810086",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[2],
)
_rmod_4 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type=RadioTypes.FRMF.value,
    serial_number="AS190626047",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[11],
)
_rmod_5 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB.value,
    serial_number="1M144161121",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_6 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="K9144947335",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_7 = RU(
    ru_hw_group="FRMr3.0_3T6R",
    radio_type=RadioTypes.FRGT.value,
    serial_number="F7172002029",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[10],
)
_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXEB.value,
    serial_number="F7144850885",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[8],
)

_fhs_1 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[9],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q194003190",
    product_code="473922A.102",
    rus=[_rmod_1, _rmod_2],
)

_fhs_2 = FHS(
    fhs_type=FhsType.MDEA.value,
    pdu_port=_pdu_1.pdu_ports[9],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=None,
    test_pc=None,
    optical_switch_channels=None,
    serial_number="6Q201905458",
    product_code="473922A.102",
    rus=[_rmod_6, _rmod_7],
)
 
_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201707614",
    rus=[_rmod_1, _rmod_2],
    fhs=[_fhs_1]
)
_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="474020B.102",
    serial_number="L1172002042",
    rus=[_rmod_1, _rmod_2],
)
_fsp_3 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="474020B.102",
    serial_number="EA184873204",
    rus=[_rmod_3, _rmod_4, _rmod_5],
)
_fsp_4 = CapacityUnit(
    addr="",
    hardware_type="ABIL",
    hardware_version="474020B.102",
    serial_number="L1201705928",    
    rus=[_rmod_6, _rmod_7],
    fhs=[_fhs_2]
)
_fsp_5 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184778072",
    rus=[_rmod_6, _rmod_7],
)
_fsp_6 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="EA184873062",
    rus=[_rmod_3, _rmod_4, _rmod_8],
)

 
# CommonUnit class for SMOD defining.
# Data you need to provide: hardware IP address, username, pass, capacity unit object(if defined), PDU port where it is connected
# serial number and TestPc object which contains data about assigned VM
# You can create as many CommonUnit objects as you need (in case of multiple SMODs)
# Capacity units is mandatory attribute. If not equipped, it should be set with empty list, i.e capacity_units=[]
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu_1.pdu_ports[9],
    hardware_type="ASIK",
    hardware_version="A.102",
    serial_number="EA201957852",
    test_pc=_test_pc_1,
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[11],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202104861",
    test_pc=_test_pc_2,
)
_fct_3 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4],
    pdu_port=_pdu_1.pdu_ports[10],
    hardware_type="ASIK",
    hardware_version="A.203",
    serial_number="L1190109243",
    test_pc=_test_pc_3,
)
_fct_4 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[12],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1202204623",
    test_pc=_test_pc_4,
)  
 

# Airscale class for ASIA defining
# Data you need to provide: object of CommonUnit class you previously defined for your Airscale
_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])
_smod_3 = Airscale([_fct_3])
_smod_4 = Airscale([_fct_4])
 
##### LTE Standalone RELATED #####
 
# RealEnb class for definig LTE/SBTS node.
# Data you need to provide: SMOD object and RMODs you previously defined, OAM IP address, eNB id,  DCAP server - optional
# In case that system_module is Airscale, please initialize system_module field using CommonUnit object like this: system_module=Airscale(common_units=[_fct_n])
_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],   
    instance_id=621076,
    oam_ip=NetworkAddress(v4="10.0.65.76")
)
_enb_lte_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5],   
    instance_id=623076,
    oam_ip=NetworkAddress(v4="10.0.69.76")
)
_enb_lte_3 = RealEnb(
    system_module=_smod_3,
    rms=[_rmod_6, _rmod_7],   
    instance_id=624076,
    oam_ip=NetworkAddress(v4="10.0.65.96")
)
_enb_lte_4 = RealEnb(
    system_module=_smod_4,
    rms=[_rmod_6, _rmod_7, _rmod_8, _rmod_4],
    instance_id=622076,
    oam_ip=NetworkAddress(v4="10.0.69.96")
)

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))

_test_pc_2.connections.append(Connection(interface="eth1", device=_enb_lte_2.system_module.common_units[0], interface_type="lmp"))

_test_pc_3.connections.append(Connection(interface="eth1", device=_enb_lte_3.system_module.common_units[0], interface_type="lmp"))

_test_pc_4.connections.append(Connection(interface="eth1", device=_enb_lte_4.system_module.common_units[0], interface_type="lmp"))

_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.52.28",
                               user="ftp_5g",
                               password="Aikon_4321",
                               bind_interface_ip="10.5.61.134")

_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_data_transfer_iperf_2 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)

_android1 = TafUeAndroid(serial_number='HZQN1876AAK92100198',
                         ue_pc_address='10.5.53.176',
                         data_transfer=[_data_transfer_iperf_1],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.176',
                                                                  username='NOKLAB\rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_1'])

_android2 = TafUeAndroid(serial_number='H0J9DE1CN01C2100350',
                         ue_pc_address='10.5.53.176',
                         data_transfer=[_data_transfer_iperf_2],
                         ssh_connection_details=SshServiceDetails(addr='10.5.53.176',
                                                                  username='NOKLAB\rfsharing',
                                                                  password='Nokia2022!@1'),
                         ue_pc_port='80',
                         capabilities=['REAL_ANDROID_UE_2'])

# TestLine class for defining the whole Testline. This object should be unique
# Data you need to provide: main TestPC object (master), RealEnb object, Bts2G object (If defined), NB object (If defined),
# ClassicalBts object (If defined), Testline Type from Cloud Manager (If defined), BSC and RNC objects (if define), optical switches(if cabled); if not defined, attribute should be deleted
tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2, _test_pc_3, _test_pc_4],
    enbs=[_enb_lte_1, _enb_lte_2, _enb_lte_3, _enb_lte_4],
    tl_cloud_topology="CLOUD_HRAN_RFS_AIL_B1_AIR_B4_AIL_B1-2_AIR_B4-5_MTNRL76_4xFRGT_2xFXEB_1xFRPA_1xFRMF",
    ues=[_android1, _android2],
)
RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK":  False,
    "USER_STOP_AND_FIX":  True 
}
 
#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL76/ues.yaml"
__all__ = ["tl"]
