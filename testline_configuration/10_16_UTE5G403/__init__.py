__maintainer__ = "Tomasz Stawowczyk"
__team__ = "MN_RAN_Pz_3_WRO_02&04"
__email__ = "i_mn_ran_rd_vrf_wro3_2@internal.nsn.com"
import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline import RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import ATEN, EPC, Gude
from taf.config.testline.radio import RU
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.dcap import DcapBasic

__all__ = ["tl"]
cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_RU_1 = Gude(addr="10.44.200.204", port_numbers=[1, 2, 3], model="EPC", version="8041-1")

_pdu_RU_2 = Gude(addr="10.44.200.207", port_numbers=[6, 7], model="EPC", version="8041-1")

_pdu_RU_3 = Gude(addr="10.44.200.205", port_numbers=[2, 3, 4, 5], model="EPC", version="8041-1")

_pdu_SMOD = Gude(addr="10.44.200.208", port_numbers=[9], model="EPC", version="8041-1")

_enb_ru_1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="UHBA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="root", password="" # N7H7
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_3.pdu_ports[2],
)

_enb_ru_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="UHBA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="root", password="" #  2FCA
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_3.pdu_ports[3],
)

_enb_ru_3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="UHFA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.131", username="root", password="" # 8FEJ
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_3.pdu_ports[4],
)

_enb_ru_4 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="UHFA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.132", username="root", password="" # 841M
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_3.pdu_ports[5],
)

_enb_ru_5 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="UHIE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.132", username="root", password="" # 7TEN
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_2.pdu_ports[6],
)

_enb_ru_6 = RU(
    ru_hw_group="FRMr5.1_1_4T4R",
    radio_type="UHIE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.132", username="root", password="" # R6XB
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_2.pdu_ports[7],
)

_enb_ru_7 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="root", password="" # 1743
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_1.pdu_ports[1],
)

_enb_ru_8 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129", username="root", password="" #  5483
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_1.pdu_ports[2],
)

_enb_ru_9 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHCA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.131", username="root", password="" # 0009
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.1", username="root", password=""
    ),
    pdu_port=_pdu_RU_1.pdu_ports[3],
)
_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1171802204",
    rus=[_enb_ru_1, _enb_ru_2, _enb_ru_3, _enb_ru_4],
)

_abia_enb_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="DH212899353",
    rus=[_enb_ru_5, _enb_ru_6],
)

_abia_enb_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    serial_number="L1172911364",
    rus=[_enb_ru_7, _enb_ru_8, _enb_ru_9],
)

_asiaa_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1, _abia_enb_2, _abia_enb_3],
    pdu_port=_pdu_SMOD.pdu_ports[9],
    hardware_type="ASIAA",
    serial_number="AH181504099",
)


_airscale_enb = Airscale(common_units=[_asiaa_enb])


_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abia_enb_1, label="OPT", port_id=1),
        target=Endpoint(unit=_enb_ru_1, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1, label="OPT", port_id=2),
        target=Endpoint(unit=_enb_ru_2, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1, label="OPT", port_id=4),
        target=Endpoint(unit=_enb_ru_3, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_1, label="OPT", port_id=5),
        target=Endpoint(unit=_enb_ru_4, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2, label="OPT", port_id=1),
        target=Endpoint(unit=_enb_ru_5, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_2, label="OPT", port_id=2),
        target=Endpoint(unit=_enb_ru_6, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_3, label="OPT", port_id=1),
        target=Endpoint(unit=_enb_ru_7, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_3, label="OPT", port_id=2),
        target=Endpoint(unit=_enb_ru_8, label="OPT", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_abia_enb_3, label="OPT", port_id=3),
        target=Endpoint(unit=_enb_ru_9, label="OPT", port_id=1),
    ),
]


_enb_1 = RealEnb(
    system_module=_airscale_enb,
    global_bts_id=40273,
    instance_id=40273,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:600c::2f0b",
        v4="10.42.32.140",
        vlan_id=577,
        routing_v4=RoutingInformation(gateway="10.42.32.65/26"),
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:600c::2e01"),
    ),
)
_dcap = DcapBasic(
    connection_details=HttpConnectionDetails(
        "10.44.180.7", port=9443, username="dcapuser", password="dcapadmin!"
    )
)

_tl_cloud_topology = "Not determinated"


_realcore = RealCore(mcc="1", mnc="1")

_lmp_vm_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.148", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(interface="eth1", device=_asiaa_enb, interface_type="lmp"),
    ],
)

tl = TestLine(
    test_pc=_lmp_vm_enb,
    core=_realcore,
    enbs=[_enb_1],
    tl_cloud_topology=_tl_cloud_topology,
    test_pcs=[_lmp_vm_enb],
    pdus=[_pdu_RU_1, _pdu_RU_2, _pdu_RU_3, _pdu_SMOD],
)

