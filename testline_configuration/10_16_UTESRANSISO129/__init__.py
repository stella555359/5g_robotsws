__maintainer__ = "Anna Plecha"
__team__ = "siso"
__email__ = "anna.plecha@nokia.com"
__owner_email__ = "anna.plecha@nokia.com"

from typing import Optional, List, Union
from enum import Enum
from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import DU, CU, ClassicalBts
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude, BKT

# from taf.config.testline.pdu import ATEN
from taf.config.testline.radio import RU
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol

from taf.config.testline.testpc import TestPc, Connection



_snmp_user_data = dict(
    userName="standard",
    authKey="standard",
    privKey="standard",
    authProtocol="SHA",
    privProtocol="AES",
)

_pdu_1 = Gude("10.44.167.17", [4, 8], "EPC", "8220-1")  # SMOD
_pdu_2 = Gude("10.44.167.56", [7, 8], "EPC", "8220-1")  # AAFB, AAIB
_pdu_3 = Gude("10.44.167.60", [7], "EPC", "8220-1")  # AZRB
_pdu_4 = Gude("10.44.167.55", [1, 7], "EPC", "8220-1")  # AHFII, AHEGHA
_pdu_5 = Gude("10.44.167.54", [6, 7], "EPC", "8220-1")  # AHLOA, AHEGC
#_pdu_6 = BKT(addr="10.42.134.13", port_numbers=[7], snmp_user=_snmp_user_data ) # FHFB
#_pdu_7 = Gude("10.44.167.53", [5], "EPC", "8220-1")  # FHFB
_pdu_8 = Gude("10.44.167.42", [2], "EPC", "8221-1")    #AXEGHA

_rmod_1 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="BL1919HL0AH",
    pdu_port=_pdu_2.pdu_ports[7],
    product_code="474119A.101",
    radio_type="AAFB",
)  # AAFB
_rmod_2 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    serial_number="YK184500053",
    pdu_port=_pdu_2.pdu_ports[8],
    product_code="474198A.101",
    radio_type="AAIB",
)  # AAIB
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    serial_number="BL2339N49U8",
    pdu_port=_pdu_4.pdu_ports[7],
    product_code="474514A.102",
    radio_type="AHFII",
)  # AHFII
_rmod_4 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    serial_number="BL2351H69VK",
    pdu_port=_pdu_4.pdu_ports[1],
    product_code="474036A.101",
    radio_type="AHEGHA",
)  # AHEGHA
_rmod_5 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2138G1LC6",
    pdu_port=_pdu_5.pdu_ports[7],
    product_code="474712A.101",
    radio_type="AHLOA",
)  # AHLOA
_rmod_6 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA202453568",
    pdu_port=_pdu_5.pdu_ports[6],
    product_code="474331A.101",
    radio_type="AHEGC",
)  # AHEGC
_rmod_7 = RU(
    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
    serial_number="AH191500382",
    pdu_port=_pdu_3.pdu_ports[7],
    product_code="474510A.102",
    radio_type="AZRB",
)  # AZRB
#_rmod_8 = RU(
#    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
#    serial_number="L1150300018",
#    pdu_port=_pdu_6.pdu_ports[7],
#    product_code="474510A.102",
#    radio_type="FHFB",
#)  # FHFB
#_rmod_9 = RU(
#    ru_hw_group="FRMTDr5.1b_1_2T2R_LP",
#    serial_number="L1150300015",
#    pdu_port=_pdu_7.pdu_ports[5],
#    product_code="474510A.102",
#    radio_type="FHFB",
#)  # FHFB
_rmod_10 = RU(
    ru_hw_group="RU_FDr8_4T4R",
    serial_number="L1260200043",
    pdu_port=_pdu_8.pdu_ports[2],
    product_code="476626A.X25",
    radio_type="AXEGHA",
)  # AXEGHA


_fsp_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    serial_number="L1172804856",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_4],  # AHEGHA
)

_fsp_2 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIQ",
    serial_number="L1233105867",
    pdu_port=_pdu_1.pdu_ports[8],
    rus=[_rmod_3, _rmod_5, _rmod_6, _rmod_7],
#    rus=[_rmod_3, _rmod_5, _rmod_6, _rmod_7, _rmod_8, _rmod_9],  # AZRB, AHLOA, AHFII, AHEGC, FHFB, FHFB
)

_fsp_3 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIP",
    serial_number="L1232807119",
    pdu_port=_pdu_1.pdu_ports[8],
 #   rus=[_rmod_5],  # AHLOA
)

_fsp_4 = CapacityUnit(
    addr="192.168.254.125",
    hardware_type="ABIO",
    serial_number="L1211302335",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_1, _rmod_2],  # AAFIA
)
_fsp_5 = CapacityUnit(
    addr="192.168.254.126",
    hardware_type="ABIA",
    serial_number="K9173831139",
    pdu_port=_pdu_1.pdu_ports[4],
 #   rus=[_rmod_5],  # 
)
_fsp_6 = CapacityUnit(
    addr="192.168.254.127",
    hardware_type="ABIQ",
    serial_number="L1233003900",
    pdu_port=_pdu_1.pdu_ports[4],
    rus=[_rmod_10],  # 
)
_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[8],
    hardware_type="ASIM",
    serial_number="L1233106076",
)

_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[4],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1190601903",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
#        _rmod_1,
#        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        _rmod_7,
    ],
    oam_ip=NetworkAddress("10.42.24.212"),
    instance_id=1050,
)

_enb_sbts_2 = RealEnb(
	system_module=_smod_2,
	rms=[_rmod_1, _rmod_2, _rmod_10],
	master=_enb_sbts_1)
_enb_sbts_1.secondary = _enb_sbts_2

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


_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.132", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)
_test_pc_2 = TestPc(
    SshServiceDetails(addr="10.42.121.135", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(interface="eth1", device=_enb_sbts_2.system_module.common_units[0], interface_type="lmp"),
        ],
   )

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
)

__all__ = ["tl"]
