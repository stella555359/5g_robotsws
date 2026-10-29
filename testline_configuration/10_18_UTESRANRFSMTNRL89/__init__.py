__maintainer__ = "ancuta.muresan@nokia.com"
__owner__ = "ancuta.muresan@nokia.com"
__email__ = "ancuta.muresan@nokia.com"


import os
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.connection_details import SshServiceDetails
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.ue import TafUeAt
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, EPC
from taf.config.testline.radio import RU, RadioTypes
#from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.nb import NB
from taf.config.testline.gnb import DU
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc
#from taf.config.testline.dcap import DcapRnD, DcapBasic


_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.19.81", username="ute", password="uteUTE!"),
    connections=[NetworkAddress(v4="192.168.255.126")],
)


_pdu_1 = Gude(addr="10.255.5.117", port_numbers=[3], model="EPC", version="8221-1")
_pdu_2 = Gude(addr="10.255.5.116", port_numbers=[1, 2], model="EPC", version="8221-1")

_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[1].contactor = "NORMALLY_CLOSED"
_pdu_2.pdu_ports[2].contactor = "NORMALLY_CLOSED"


# _dcap_1 = DcapRnD(
#     HttpConnectionDetails(
#         addr="10.5.26.83", port="9443", username="utfuser", password="utfadmin!")
# )


_rmod_1 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q184608997",
    pdu_port=_pdu_2.pdu_ports[1],
)

_rmod_2 = RU(
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q185007212",
    pdu_port=_pdu_2.pdu_ports[2],
)



_fsp_1 = CapacityUnit(
    addr="",
    hardware_type="ABIA",
    hardware_version="A.103",
    serial_number="L1172907766",
    rus=[_rmod_1, _rmod_2]
    )

_fsp_2 = CapacityUnit(
    addr="",
    hardware_type="ABIP",
    hardware_version="A.102",
    serial_number="L1233203468",
    rus=[ ]
    )


_fct_1 = CommonUnit(
    SshServiceDetails(
    addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_1.pdu_ports[3],
    hardware_type="ASIM",
    hardware_version="A.102",
    serial_number="L1230610641",
    test_pc=_test_pc_1,
)

_smod_1 = Airscale([_fct_1])


_enb_lte_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1, _rmod_2],
    instance_id=621089,
   # dcap=_dcap_1,
   # bcf_id='3101',
   )

_test_pc_1.connections.append(Connection(interface="eth1", device=_enb_lte_1.system_module.common_units[0], interface_type="lmp"))


#_bsc = BSC(
#    name="BSC_BUICK",
#    logging_telnet_connection_details=TelnetConnectionDetails(
#        addr="10.5.8.132", username="SYSTEM", password="SYSTEM")
#        )

#_test_pc_1.connections.append(_bsc)


_app_server_1 = TafUeAppServer(app_server_name="APP_1",
                               address="10.5.56.28",
                               user="ftp_5g",
                               password="Aikon_123456",
                               bind_interface_ip="10.5.61.134")



_data_transfer_iperf_1 = TafUeDataTransferProtocol(protocol_name='iperf',
                                                 app_server=_app_server_1,
                                                 interval=1,
                                                 server_close_delay=50)



_at1 = TafUeAt(com_port='5',
               serial_number='',
               capabilities=['Sequans'],
               ue_pc_address='10.5.53.113',
               ue_pc_login='rfsharing',
               ue_pc_password='Nokia2022!@1',
               ue_pc_expected_prompt='rfsharing@ROTMSRANU50080',
               data_transfer=[_data_transfer_iperf_1],
               ue_pc_port='81')


tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_lte_1],
#    bscs=[_bsc],
    ues=[_at1],
)



#TARGET_LOGICAL_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL1/logical_config.yaml"
#DCAP_PROFILES_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL1/dcap_profiles.yaml"
ATTENUATOR_CONFIG_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL89/pa.yaml"
CELL_TARGET_BW_PATH = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL89/cell_target_bw.yaml"

#UTE_UE_CONFIG = "/home/ute/testline_configuration/10_18_UTESRANRFSMTNRL89/ues.yaml"


RFS_TL_FLAGS = {
    "fail_if_unexpected_alarms": True,
    "fail_if_wrn_threshold": True,
    "USER_RTWP_CHECK": False,
    "LK_USERNAME": "ancuta.muresan@nokia.com",
    "LK_PASSWORD": "Nokia1234",
    "USER_DCAP_TRACE_COLLECT": False,
    "USER_DCAP_TRACE_COLLECT_Master": False,
    "USER_STOP_AND_FIX": False,
    "USER_MASTER_TECH": "SBTS",
    "POWER_ON_FLAG": True,
    }


__all__ = ["tl"]