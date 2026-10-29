__maintainer__ = "Szymon Przybylak"
__email__ = "Szymon Przybylak@nokia.com"

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
from taf.config.testline.testpc import TestPc


from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.airscale import CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.lmi import SerialOverTcp, SerialOverHost, Remote, LMI, Local

_pdu_1 = Gude("10.42.168.168", [5, 6], "EPC", "8220-1")  # ASIB_592, ASIB_956
_pdu_2 = Gude(
    "10.42.169.65", [4, 5, 6, 7, 9], "EPC", "8220-1"
)  # AHEC_835, AHDB_588, AZQP_037, FHED_335, AHFII_069
_pdu_3 = Gude(
    "10.42.168.74", [1, 2, 3], "EPC", "8220-1"
)  # FXDB_872, AREA_149, AREA_384

_LabPc = TestPc(default_ssh_connection_details=SshServiceDetails(
                                         addr="10.42.172.131", username="NOKLAB\\plwrranpz4",password="Ut3pa5s#1be1",
                                            port = "22"))
_lmi_light_1 = SerialOverTcp(
    uart_mapping=[
        Remote(addr="10.255.30.109", port=2003)])
_lmi_1 = LMI(
    product_code="088917A.X02",
    uart_mapping=[Local(port="COM22")],
    host=_LabPc)
_mumin_usb_1 = SerialOverHost(uart_mapping=[Local(port="COM21")],
                                     host=_LabPc)
_mumin_eth_1 = SerialOverTcp(
    uart_mapping=[
            Remote(addr="10.255.30.112", port=2003),
        ]
    )
_mumin_eth_2 = SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.30.110", port=2003),
        ]
    )
_mumin_eth_3 = SerialOverTcp(
        uart_mapping=[
            Remote(addr="10.255.30.111", port=2003),
        ]
    )

_rmod_1 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="L1190309149",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.129", port=2323
    ),
    lmi=_mumin_usb_1,
    pdu_port=_pdu_3.pdu_ports[2],
)
_rmod_2 = RU(
    ru_hw_group="FRMrRH5.1_6T6R",
    radio_type=RadioTypes.AREA.value,
    serial_number="EA192474384",
    lmi=_lmi_1,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.37.130", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[3],
)
_rmod_3 = RU(
    ru_hw_group="FRMr6.2_4T4R",
    radio_type=RadioTypes.AHFII.value,
    serial_number="BL2221N4069",
    lmi=_mumin_eth_1,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.132", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[9],
)
_rmod_4 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHDB.value,
    serial_number="6Q183043588",
    lmi=_mumin_eth_3,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.129", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[5],
)
_rmod_5 = RU(
    ru_hw_group="FRMrRH5.1_2T4R",
    radio_type=RadioTypes.AHEC.value,
    serial_number="6Q182525835",
    lmi=_mumin_eth_2,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.33.130", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[4],
)
_rmod_6 = RU(
    ru_hw_group="FRMr4.0b_4T4R_Corona",
    radio_type=RadioTypes.FHED.value,
    serial_number="K9173100335",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[7],
)
_rmod_7 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type=RadioTypes.AZQP.value,
    serial_number="1M204457006",
    lmi=_lmi_light_1,
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.22.10.10", port=2323
    ),
    pdu_port=_pdu_2.pdu_ports[6],
)
_rmod_8 = RU(
    ru_hw_group="FRMr2.3_3T6R_Vegas",
    radio_type=RadioTypes.FXDB.value,
    serial_number="F7174613872",
    default_telnet_connection_details=TelnetConnectionDetails(
        addr="172.16.11.127", port=2323
    ),
    pdu_port=_pdu_3.pdu_ports[1],
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="K9172558088",
    rus=[_rmod_4, _rmod_6],
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309851",
    rus=[_rmod_5],
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213114810",
    rus=[_rmod_1, _rmod_2, _rmod_3],
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172800089",
    rus=[_rmod_8],
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ABIO",
    hardware_version="475266B.101",
    serial_number="L1223309832",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ABIN",
    hardware_version="474824A.101",
    serial_number="L1204212540",
    rus=[_rmod_7],
)

_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="DH203062592",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_1.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A.102",
    serial_number="L1201102953",
)

_smod_1 = Airscale([_fct_1])
_smod_2 = Airscale([_fct_2])

_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_3, _rmod_4, _rmod_5, _rmod_6],  # TODO
    oam_ip=NetworkAddress("10.42.193.144"),
    instance_id=1304,
)
_enb_sbts_2 = RealEnb(
    system_module=_smod_2,
    rms=[_rmod_1, _rmod_2, _rmod_4, _rmod_5, _rmod_7, _rmod_8],  # TODO
    master=_enb_sbts_1,
)
_enb_sbts_1.slave = _enb_sbts_2

_rnc = RNC(
    rnc_id=38,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.42.91.81", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_mcBSC32",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.215.4", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    SshServiceDetails(addr="10.42.184.24", username="ute"),
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
    SshServiceDetails(addr="10.42.184.25", username="ute"),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            device=_enb_sbts_2.system_module.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc_1,
    test_pcs=[_test_pc_1, _test_pc_2],
    enbs=[_enb_sbts_1, _enb_sbts_2],
    tl_cloud_topology="CLOUD_10_16_UTESRANSISO081",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
