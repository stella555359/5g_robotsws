__maintainer__ = "zhlu"
__team__ = "MN_RAN_PZ_1_HAZ_12"
__email__ = "zhonggenn.lu@nokia-sbell.com"
__owner_email__ = "zhonggenn.lu@nokia-sbell.com"

import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude, TopYoung, FACOM, FPFH
from taf.config.testline.pdu import HBTE as PBHBTE
from taf.config.testline.attenuator import HBTE
from taf.config.testline.radio import RadioTypes
from taf.config.testline import LicenseKeeper

_pdu_1 = FACOM(
    addr="10.108.153.134",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_2 = FACOM(
    addr="10.108.161.144",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)
_pdu_3 = PBHBTE(
    addr="10.106.245.174",
    port_numbers=[1, 2, 3, 4, 5, 6],
)
_pdu_4 = TopYoung(
    addr="10.106.161.162",
    port_numbers=[1, 2, 3, 4, 5, 6],
)
_pdu_5 = FACOM(
    addr="10.106.245.168",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)


_pdus = [_pdu_1, _pdu_2, _pdu_3, _pdu_4, _pdu_5]

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_5.pdu_ports[8],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    serial_number="6Q180811675",
    radio_type=RadioTypes.AZNC,
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128",
        username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_4.pdu_ports[2],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="EA220857473",
    radio_type=RadioTypes.AHEGC,
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_5.pdu_ports[7],
    ru_hw_group="FRMr5.1_1_4T4R_LP",
    serial_number="AH203500433",
    radio_type=RadioTypes.AHIB,
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2 ", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_3.pdu_ports[1],
    ru_hw_group="cMAAr6.1_8T8R_eCPRI",
    serial_number="1M222529142",
    radio_type=RadioTypes.AZHM,
)
_ru5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.11.127", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_5.pdu_ports[6],
    ru_hw_group="FRMr3.2_6T6R",
    serial_number="F7183109055",
    radio_type=RadioTypes.FXDD,
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222401735",
)
_fsp_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIN",
    hardware_version="474824A.103",
    serial_number="L1213709055",
)
_fsp_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1214502593",
)
_fsp_4 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIP",
    hardware_version="475792A.Y16",
    serial_number="L1224710362",
)
_fsp_5 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIA",
    hardware_version="473096A.102",
    serial_number="K9172230611",
)
_fsp_6 = CapacityUnit(
    addr="192.168.253.44",
    hardware_type="ABIA",
    hardware_version="L1170317775",
    serial_number="L1170317775",
)

_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    pdu_port=_pdu_1.pdu_ports[5],
    hardware_type="ASIM",
    hardware_version="475765A.Y13",
    serial_number="L1223306888",
)

_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_4, _fsp_5, _fsp_6],
    pdu_port=_pdu_2.pdu_ports[8],
    hardware_type="ASIM",
    hardware_version="475765A.Y13",
    serial_number="L1223202178",
)

_airscale1 = Airscale(common_units=[_common_unit1])

_airscale2 = Airscale(common_units=[_common_unit2])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.108.153.228",
        v6=None,
        vlan_id=None,
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.108.153.228", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.108.153.228", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.108.153.228",
        v6=None,
        vlan_id=None,
    ),
    x2u=NetworkAddress(
        v4="10.108.153.228",
        v6=None,
        vlan_id=None,
    ),
    s1u=NetworkAddress(
        v4="10.108.153.228",
        v6=None,
        vlan_id=None,
    ),
)

_du1 = DU(
    airscale=_airscale1,
    rus=[_ru1, _ru2, _ru3],
    f1_m_ip_addr="192.168.255.129",
)


_du2 = DU(
    airscale=_airscale2,
    rus=[_ru4, _ru5],
)

_cbts1 = ClassicalBts(cu=_cu, dus=[_du1], instance_id=2567, global_bts_id=2567)

_cbts2 = ClassicalBts(cu=_cu, dus=[_du2], instance_id=2567, global_bts_id=2567)

_core = RealCore5G(mcc=262, mnc=3)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.151", username="ute", password="uteUTE!"
    ),
    connections=[_cbts1],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.152.152", username="ute", password="uteUTE!"
    ),
    connections=[_cbts2],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_SRAN_CLASSICAL_NLWG_2ASIM_2ABIA_1ABIP_2ABIO_1ABIN_1AZHM_1AHEGC_1AZNC_1AHIB_1FXDD_2567",
    core=_core,
    pdus=_pdus,
)

__all__ = ["tl"]
