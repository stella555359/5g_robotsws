__maintainer__ = "Karol Palac"
__team__ = "MN 5G&SC 5G Pz 2 WRO 5 SG"
__email__ = "I_5GSC_5G_PZ2_WRO_5@internal.nsn.com"
__owner_email__ = "karol.palac@nokia.com"

import os
import yaml
from taf.config.testline.cloud_hosting import (
    MasterNode,
    K8S,
    ComputeNode,
    CloudDeployment,
    HelmChart,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)

from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CloudBts, CU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import MediaTek, Android, PreferredVlan
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit, SlotId

from taf.config.testline.attenuator import TopYoung

from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.appserver import AppServer

_ue_config = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)


_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.172.97", username="ute", password="ute"
    )
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.45.172.100", username="ute", password="ute"
    )
)

_pdu_1 = Gude("10.45.172.140", [7, 8, 9, 10, 11], "EPC", "8221-1")
_pdu_2 = Gude("10.45.177.14", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "EPC", "8221-1")
_pdu_3 = Gude("10.45.177.15", [1, 3, 4, 5, 6, 7], "EPC", "8221-1")

_pdus = [_pdu_1, _pdu_2, _pdu_3]

_attenuator = TopYoung(
    ip_addr="10.45.176.181",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
                              18, 19, 20, 21, 22, 23, 24],
)
_attenuator2 = TopYoung(
    ip_addr="10.45.176.182",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
                              18, 19, 20, 21, 22, 23, 24],
)

_abio_master = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101")
_abio_slave = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101")
_abio_loner = CapacityUnit(addr="fd5f:4268:2387:a881:40:43ff:fe80:1101")
_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu_1.pdu_ports[7],
)

_common_unit2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu_1.pdu_ports[8],
)

_airscale1 = Airscale([_common_unit1])

_airscale2 = Airscale([_common_unit2])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.76.47/26",
        v6=None,
        vlan_id=820,
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
        v4="10.45.173.104/26",
        v6="2a00:8a00:6000:607c::a:d2",
        vlan_id=106,
    ),
    x2u=NetworkAddress(
        v4="10.45.173.168/26",
        v6="2a00:8a00:6000:607c::a:112",
        vlan_id=107,
    ),
    s1u=NetworkAddress(
        v4="10.45.173.228/26",
        v6="2a00:8a00:6000:607c::a:152",
        vlan_id=108,
    ),
    xnc=NetworkAddress(
        v4="10.45.173.104/26",
        v6="2a00:8a00:6000:607c::a:d2",
        vlan_id=106,
    ),
    xnu=NetworkAddress(
        v4="10.45.173.168/26",
        v6="2a00:8a00:6000:607c::a:112",
        vlan_id=107,
    ),
    ngc=NetworkAddress(
        v4="10.45.175.227/26",
        v6="2a00:8a00:6000:607c::a:212",
        vlan_id=120,
    ),
    ngu=NetworkAddress(
        v4="10.45.173.228/26",
        v6="2a00:8a00:6000:607c::a:152",
        vlan_id=108,
    ),
)

_du1 = DU(_airscale1,)

_du2 = DU(_airscale2,)

_cbts1 = ClassicalBts(cu=_cu, dus=[_du1], global_bts_id=50894, instance_id=50894)
_cbts2 = ClassicalBts(cu=_cu, dus=[_du2], global_bts_id=50894, instance_id=50894)

_core = RealCore5G(mcc=310, mnc=260)
_core_ssh = SshServiceDetails(addr="10.45.168.53", username="5g", password="2019H@slo")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=_core_ssh,
    network_interface_address="10.45.168.53",
    iperf_path="/data/data/com.nokia.android.application/iperf",
)

_ue_pc_ssh = SshServiceDetails("10.44.234.144", "wro5grrm", password="5gpass!1")

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASIL_ABIO_MULTIRAT_WPT",
    core=_core,
    pdus=_pdus,
    ues=[_ue_config],
    attenuators=[_attenuator, _attenuator2],
)
__all__ = ["tl"]
