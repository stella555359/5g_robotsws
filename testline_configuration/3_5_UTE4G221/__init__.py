# This script was generated automatically, --None-- values indicate lacking data, please fill them manually

__maintainer__ = "dante"
__email__ = "dante.1.he@nokia-sbell.com"
__owner_email__ = "dante.1.he@nokia-sbell.com"


from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.flexi import Flexi
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU, RadioTypes
from taf.config.testline.ran import BSC, RNC
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc


_pdu_1 = Gude(
    addr="10.108.153.109",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)
_pdu_2 = Gude(
    addr="10.108.153.107",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)
_pdu_3 = Gude(
    addr="10.108.153.97",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="FACOM",
)

_rmod_1 = RU(
    ru_hw_group="FRMr2.3_2T2R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M170601740",
    pdu_port=_pdu_3.pdu_ports[7],
)
_rmod_2 = RU(
    ru_hw_group="FRMr2.3_2T2R",
    radio_type=RadioTypes.FXDB.value,
    serial_number="1M172204053",
    pdu_port=_pdu_3.pdu_ports[1],
)
_rmod_3 = RU(
    ru_hw_group="FRMr2.3_2T2R",
    radio_type=RadioTypes.FXED.value,
    serial_number="1M173257389",
    pdu_port=_pdu_3.pdu_ports[3],
)


_fsp_1 = CapacityUnit(
    addr="192.168.253.18",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA173524672",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.19",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="EA180324190",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="FBBC",
    hardware_version="472797A.101",
    serial_number="L6143200354",
)


_fct_1 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2],
    pdu_port=_pdu_2.pdu_ports[7],
    hardware_type="FSMF",
    hardware_version="A.102",
    serial_number="EA173062623",
)
_fct_2 = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.7", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_3],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="FSMF",
    hardware_version="A.103",
    serial_number="EA173764470",
)

_smod_1 = Flexi([_fct_1])
_smod_2 = Flexi([_fct_2])


_enb_sbts_1 = RealEnb(
    system_module=_smod_1,
    rms=[_rmod_1],
    oam_ip=NetworkAddress("10.108.153.113"),
    instance_id=5050,
)
# _enb_sbts_1 = RealEnb(system_module=_smod_1, rms=[_rmod_1])
_enb_sbts_2 = RealEnb(
    system_module=_smod_2, rms=[_rmod_1, _rmod_2, _rmod_3], master=_enb_sbts_1
)
_enb_sbts_1.slave = _enb_sbts_2


_rnc = RNC(
    rnc_id=36,
    oms_ip=NetworkAddress("10.44.44.218"),
    logging_ssh_connection_details=SshServiceDetails(
        addr="10.44.171.138", username="nokiadmin", password="system"
    ),
)

_bsc = BSC(
    name="BSC_Leopard",
    logging_telnet_connection_details=TelnetConnectionDetails(
        addr="10.42.89.4", username="SYSTEM", password="SYSTEM"
    ),
)

_test_pc_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.161.189", username="ute"
    ),
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
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.161.190", username="ute"
    ),
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
    tl_cloud_topology="CLOUD_SRAN_LWG_2FSMF_3FBBC_2xFXDB_FXED",
    bscs=[_bsc],
    rncs=[_rnc],
)

__all__ = ["tl"]
