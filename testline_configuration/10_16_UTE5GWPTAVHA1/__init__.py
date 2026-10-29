__maintainer__ = "Sebastian Mikos"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "sebastian.mikos@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.attenuator import JFW
from taf.config.testline.dcap import DcapBasic
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

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)

_pdu_1 = Gude("10.45.177.29", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_2 = Gude("10.45.177.10", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8226-1")

_pdus = [_pdu_1, _pdu_2]

_ru_default_ssh = SshServiceDetails(
    addr="192.168.254.34", username="root", password="umniedziala"
)

_ru_lmp_ssh = SshServiceDetails(addr="", username="")

_ru1 = RU(
    default_ssh_connection_details=_ru_default_ssh,
    lmp_connection=_ru_lmp_ssh,
    pdu_port=_pdus[1].pdu_ports[5],
    ru_hw_group="",
    radio_type="AVHA",
)

_abip_master = CapacityUnit(addr="192.168.253.20", hardware_type="ABIP", rus=[_ru1])

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_master],
    hardware_type="ASIM",
    pdu_port=_pdus[0].pdu_ports[9],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.42.46.141",
        routing=RoutingInformation(gateway="10.42.46.1", ip_prefix_length=26),
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
        v4="10.42.46.77",
        routing=RoutingInformation(
            gateway="10.42.46.65",
            ip_prefix_length=26,
        ),
    ),
    x2u=None,
    s1u=NetworkAddress(
        v4="10.42.46.13",
        routing=RoutingInformation(gateway="10.42.46.1", ip_prefix_length=26),
    ),
)

_utf_http = HttpConnectionDetails(
    addr="10.42.54.132", username="utfuser", password="utfadmin!"
)

_utf = DcapBasic(connection_details=_utf_http)

_du = DU(_airscale)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50670, instance_id=50670, dcap=_utf)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.45.168.53", username="5g", password="2019H@slo")


_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="192.168.60.200",
    iperf_path="/usr/bin/iperf",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.71.37", username="ute", password="ute"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0]]
)

_ue_pc_ssh = SshServiceDetails("10.44.234.220", "plwr5gtp", password="zmienMnie5@")

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIML_ABIPB1_1xAVHA",
    core=_core,
    ues=[_ues],
    attenuators=[],
    pdus=_pdus,
)

__all__ = ["tl"]
