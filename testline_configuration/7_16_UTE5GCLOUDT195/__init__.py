__maintainer__ = "Pawel Sniady"
__team__ = "MN RAN Pz 2 WRO 5 SG"
__email__ = "I_MN_RAN_PZ2_WRO_5_SG@internal.nsn.com"
__owner_email__ = "pawel.sniady@nokia.com"

import os
from taf.config.testline.pdu import Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.dcap import DcapBasic
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.radio import RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_ues = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue.yaml"
)
_lmp_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_lmp_http = HttpConnectionDetails(
    addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
)
_appserver_ssh = SshServiceDetails(
    addr="10.42.61.65", username="5g", password="2019H@slo"
)
_ue_pc_ssh = SshServiceDetails("10.44.234.173", "wro5grrm", password="5gpass!1")
_vm_ssh = SshServiceDetails(
    addr="10.45.172.124", username="ute", password="Ut3pa5s#1be1"
)
_dcap_http = HttpConnectionDetails(
    addr="10.44.234.5", username="dcapuser", password="dcapadmin!"
)

_pdu_1 = Gude("10.45.177.21", [3, 5, 8, 9, 10, 11], "EPC", "8221-1")
_attenuator_1 = TopYoung(
    ip_addr="10.44.234.4",
    port=3001,
    attenuation_port_numbers=[
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
    ],
)
_rmod_1 = RU(
    ru_hw_group="cMAArChile_64T64R",
    radio_type="AEHC",
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
    ],
    pdu_port=_pdu_1.pdu_ports[9],
)
_rmod_2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],
    pdu_port=_pdu_1.pdu_ports[5],
)
_rmod_3 = RU(
    ru_hw_group="5Ggen5_2T2R", radio_type="AWGUD", pdu_port=_pdu_1.pdu_ports[10]
)
_rmod_4 = RU(
    ru_hw_group="5Ggen5_2T2R", radio_type="AWGUD", pdu_port=_pdu_1.pdu_ports[11]
)
# _rmod_5 = RU(
#     ru_hw_group="5Ggen4_HighF_2T2R",
#     radio_type="AEWB",
# )
# _rmod_6 = RU(
#     ru_hw_group="5Ggen4_HighF_2T2R",
#     radio_type="AEWB",
# )
_fsp_1 = CapacityUnit(
    addr="fsp1s0icom",
    hardware_type="ABIO",
    hardware_version="A.102",
    rus=[_rmod_1, _rmod_2],
)
_fsp_2 = CapacityUnit(addr="fsp2s0icom", hardware_type="ABIO", hardware_version="A.102")
_fsp_3 = CapacityUnit(
    addr="fsp3s0icom",
    hardware_type="ABIO",
    hardware_version="A.102",
    rus=[_rmod_3, _rmod_4],
)
_fct_0 = CommonUnit(
    lmp_connection=_lmp_ssh,
    capacity_units=[_fsp_1, _fsp_2, _fsp_3],
    hardware_type="ASIB",
    hardware_version="A.102",
    pdu_port=_pdu_1.pdu_ports[8],
)
_airscale = Airscale(common_units=[_fct_0])
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.45.173.48/26", v6="2a00:8a00:6000:607c::a:95/122", vlan_id=105
    ),
    oam_ssh_connection_details=_lmp_ssh,
    oam_http_connection_details=_lmp_http,
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.45.173.112/26", v6="2a00:8a00:6000:607c::a:d5/122", vlan_id=106
    ),
    x2u=NetworkAddress(
        v4="10.45.173.176/26", v6="2a00:8a00:6000:607c::a:15/122", vlan_id=107
    ),
    s1u=NetworkAddress(
        v4="10.45.173.236/26", v6="2a00:8a00:6000:607c::a:d5/122", vlan_id=108
    ),
    xnc=NetworkAddress(
        v4="10.45.173.112/26", v6="2a00:8a00:6000:607c::a:d5/122", vlan_id=106
    ),
    xnu=NetworkAddress(
        v4="10.45.173.176/26", v6="2a00:8a00:6000:607c::a:15/122", vlan_id=107
    ),
    ngc=NetworkAddress(
        v4="10.45.175.235/26", v6="2a00:8a00:6000:607c::a:215/122", vlan_id=120
    ),
    ngu=NetworkAddress(
        v4="10.45.173.236/26", v6="2a00:8a00:6000:607c::a:d5/122", vlan_id=108
    ),
)
_du = DU(_airscale, rus=[_rmod_1, _rmod_2, _rmod_3, _rmod_4])
_dcap = DcapBasic(connection_details=_dcap_http)
_bts = ClassicalBts(
    cu=_cu, dus=[_du], global_bts_id=51243, instance_id=51243, dcap=_dcap
)
_vm_lmp_connection = Connection(
    interface="eth1", device=_bts.dus[0].airscale.common_units[0], interface_type="lmp"
)
_vm_1 = TestPc(default_ssh_connection_details=_vm_ssh, connections=[_vm_lmp_connection])
_core = RealCore5G(mcc=310, mnc=260)

tl = TestLine(
    test_pc=_vm_1,
    test_pcs=[_vm_1],
    gnbs=[_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABIOB1-3_AEHC_AHFIB_2xAWGUD_2xAEWB",
    core=_core,
    ues=[_ues],
    attenuators=[_attenuator_1],
    pdus=[_pdu_1],
)

__all__ = ["tl"]
