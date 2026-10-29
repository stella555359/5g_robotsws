__maintainer__ = "Przemyslaw Sas"
__team__ = "siso"
__email__ = "przemyslaw.sas@nokia.com"

from taf.config.testline.airscale import Airscale, CapacityUnit, CoreUnit
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
from taf.config.testline.bts2g import Bts2G
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import PDNAndroidDetails, TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CoreUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc

_pdu_1 = Gude("10.44.167.19", [12], "EPC", "8220-1")  # ASOG
_pdu_2 = Gude("10.44.167.67", [2], "EPC", "8221-1")  # AHEH
_pdu_3 = Gude("10.44.167.78", [3, 6], "EPC", "8220-1")  # AHFII & # AHEB
_pdu_4 = Gude("10.44.167.41", [11, 12], "EPC", "8220-1")  # FRHC
_pdu_5 = Gude("10.44.167.70", [12], "EPC", "8221-1")  # AHEGC
# _pdu_6 = Gude("10.44.167.2", [7], "EPC", "8221-1")  # AKQJ
_pdu_7 = Gude("10.44.167.37", [11], "EPC", "8220-1")  # AREA
# _pdu_8 = Gude("10.44.167.60", [2], "EPC", "8220-1")  # AHEGA
_pdu_9 = Gude("10.44.167.53", [9], "EPC", "8220-1")  # AHPDB

_rmod_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGC",
    serial_number="EA214454211",
    pdu_port=_pdu_5.pdu_ports[12],
)

_rmod_2 = RU(
    ru_hw_group="FRMr6.2a_4T4R",
    radio_type="AHPDB",
    serial_number="RW233000481",
    pdu_port=_pdu_9.pdu_ports[9],
)

_rmod_3 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="L1141314519",
    pdu_port=_pdu_4.pdu_ports[12],
)

_rmod_4 = RU(
    ru_hw_group="FRMr3.1_6T6R",
    radio_type="FRHC",
    serial_number="L1141611336",
    pdu_port=_pdu_4.pdu_ports[11],
)

_rmod_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEB",
    serial_number="L1181207106",
    pdu_port=_pdu_3.pdu_ports[3],
)

_rmod_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="AHEH",
    serial_number="L1184103947",
    pdu_port=_pdu_2.pdu_ports[2],
)

# _rmod_7 = RU(
#     ru_hw_group="cMAAr6.2_8T8R_eCPRI",
#     radio_type="AKQJ",
#     serial_number="1M220223978",
#     pdu_port=_pdu_6.pdu_ports[7],
# )

_rmod_8 = RU(
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="AREA",
    serial_number="L1184911206",
    pdu_port=_pdu_7.pdu_ports[11],
)

_rmod_9 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type="AHFII",
    serial_number="BL2222N4087",
    pdu_port=_pdu_3.pdu_ports[6],
)

# _rmod_10 = RU(
#     ru_hw_group="FRMr5.1_2T4R",
#     radio_type="AHEGA",
#     serial_number="K9181421455",
#     pdu_port=_pdu_8.pdu_ports[2],
# )

# _fsp_1 = CapacityUnit(  # Fake BBMOD
#     addr="192.168.255.129",
#     hardware_type="ABIA",
#     hardware_version="473096A.103",
#     serial_number="L1171216177",
#     pdu_port=_pdu_1.pdu_ports[12],
#     rus=[
#         _rmod_1,
#         _rmod_2,
#         _rmod_3,
#         _rmod_4,
#         _rmod_5,
#         _rmod_6,
#         _rmod_7,
#         _rmod_8,
#         _rmod_9,
#         _rmod_10,
#     ],
# )

_fct_1 = CoreUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASOG",
    serial_number="L1241503045",
    hardware_version="476254A.101",
    pdu_port=_pdu_1.pdu_ports[12],
    rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4, _rmod_5, _rmod_6, _rmod_8, _rmod_9],
)

_smod_1 = Airscale(core_units=[_fct_1])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[
        _rmod_1,
        _rmod_2,
        _rmod_3,
        _rmod_4,
        _rmod_5,
        _rmod_6,
        # _rmod_7,
        _rmod_8,
        _rmod_9,
        # _rmod_10,
    ],  # set all RMODs used
    oam_ip=NetworkAddress("10.42.24.43"),  # set U/C-plane
    instance_id=1180,  # set MRBTS-ID
)

# _rnc = RNC(                                                                               # if configuration has 3G enter information about RNC
#     rnc_id=40,                                                                               # set RNC ID which you use
#     oms_ip=NetworkAddress("10.44.79.108"),                                                   # set OMS IP which you use
#     logging_ssh_connection_details=SshServiceDetails(
#         addr="10.44.168.91", username="Nemuadmin", password="nemuuser"                        # set U/C-plane of WCDMA, and OMS login username/password
#     ),
# )

_bsc = BSC(  # if configuration has 2G enter information about BSC
    name="BSC23",  # set BSC ID which you use
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.23.132",
        username="PZUSER4",
        password="Ut3pa5s#1be1",
        # set login IP, username and password which you use
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.121.20", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_1.system_module.core_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1],
    enbs=[_enb_sbts_1],
    bscs=[_bsc],
    # rncs=[_rnc],
)

__all__ = ["tl"]
