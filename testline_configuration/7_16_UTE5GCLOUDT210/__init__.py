__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)

_pdu_1 = Gude("10.44.200.19", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_2 = Gude("10.44.200.21", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")
_pdu_3 = Gude("10.44.200.23", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8220-1")

#enb_port = _pdu_2[9]
#enb_AHEC = _pdu_3[11]

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_attenuator = TopYoung(
    ip_addr="10.42.61.88",
    port=3001,
    attenuation_port_numbers=range(1, 25),
    pdu_port=_pdus[0].pdu_ports[2])

_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru1 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[2].pdu_ports[10],
    ru_hw_group="",
    radio_type="AZQS",
)

_abio_master = CapacityUnit(
    addr="192.168.253.20", 
    hardware_type="ABIO",
    rus=[_ru1]
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master],
    hardware_type="ASIB",
    pdu_port=_pdus[1].pdu_ports[4],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.137.24",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.137.81",
        routing=RoutingInformation(
            gateway="10.44.137.65",
            ip_prefix_length=26,
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.137.145",
        routing=RoutingInformation(gateway="10.44.137.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.137.219",
        routing=RoutingInformation(gateway="10.44.137.193", ip_prefix_length=26),
    ),
)
_utf_http = HttpConnectionDetails(
    addr="10.44.180.37", username="utfuser", password="utfadmin!"
)
_utf = DcapBasic(connection_details=_utf_http)

_du = DU(_airscale)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51001, instance_id=51001, dcap=_utf)

_core = RealCore5G(mcc=310, mnc=260)

_core_ssh = SshServiceDetails(addr="10.45.168.53", username="5g", password="2019H@slo")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP")

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=None
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lteenb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.137.25",
        routing=RoutingInformation(gateway="10.44.137.1", ip_prefix_length=26),
    ),
    global_bts_id=40011,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.180.176", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="192.168.60.200",
    iperf_path="/usr/bin/iperf",
)


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.194.153", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]]
)

_ue_pc_ssh = SshServiceDetails("10.42.22.123", "wro5grrm", password="5gpass!1")

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIBL_ABIOB1_1xAZQS_ENB",
    core=_core,
    ues=[_qualcomm_ue],
    attenuator=_attenuator,
    attenuators=[_attenuator],
)

__all__ = ["tl"]
