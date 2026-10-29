import os
import yaml
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import DU
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude, HBTE, FPFH
from taf.config.testline.pdu import TopYoung as TP
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    Android,
    Qualcomm,
    QualcommUeType,
)
from taf.config.testline.enb import (
    Enb,
    SimEnb,
    RealEnb,
    LTEEmuEnb,
    PrismaEnb,
    DocomoEnb,
)

# added in taf.meta 5.4
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.gnb.networkaddress import NetworkAddress  # add in taf.meta 5.4
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)

# from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE as HB
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "I_HAZ1_RRM7_CODER_TEAM@internal.nsn.com"
__team__ = "NSB_MN_RAN_RD_VRF_HAZ1_3_GMS"
__email__ = "I_HAZ1_RRM7_CODER_TEAM@internal.nsn.com"
# 10787 is enb site treate as 5g site
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.56.198.156", username="ute", password="UTE.debian12", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.198.156",
    iperf_path="/usr/bin/",
    port="50002",
)
_appserver = AppServer(_iperf)

ue_config_path = os.path.join(_cfg_dir, "TestData/inseego.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(stream=f, Loader=yaml.FullLoader)
else:
    ue_config = ""
# #RealEnb#
_real_enb_pdu = FPFH(addr="10.108.190.98", port_numbers=[2,3])
_gnb_pdu_301 = FPFH(addr="10.108.190.100", port_numbers=[1,2,3,4,5])

_attenuator = TopYoung(
    ip_addr="10.106.201.133",
    port=3000,
    attenuation_port_numbers=[i for j in range(5, 257, 8) for i in range(j, j+4)],
    model="TAS32B8-51-120-1N-DES",
)

# 5GRU for classicalBTS for LNBTS11423
_ru_pdu_AZHL_AEHC = FPFH(addr="10.108.190.98", port_numbers=[5, 6])


_ru_AZHL_U1 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.8.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC.pdu_ports[6],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="AH211400646",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [133, 142, 149, 158, 165, 174, 181, 190]]
    ],
)
_ru_AZHL_U2 = RU(
    ru_hw_group="AZHL",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.8.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC.pdu_ports[6],
    radio_type=RadioTypes.AZHL,
    signal_analyzer=None,
    serial_number="AH211400646",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [135, 144, 151, 160, 167, 176, 183, 192]]
    ],
)

_ru_AEHC_U1 = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.9.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC.pdu_ports[5],
    radio_type=RadioTypes.AEHC,
    signal_analyzer=None,
    serial_number="L1204708713",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [5, 14]]
    ],
)

_ru_AEHC_U2 = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.9.2", username="root", password=""
    ),
    pdu_port=_ru_pdu_AZHL_AEHC.pdu_ports[5],
    radio_type=RadioTypes.AEHC,
    signal_analyzer=None,
    serial_number="L1204708713",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [7, 16]]
    ],
)

_ru_301_AEHC = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_gnb_pdu_301.pdu_ports[3],
    radio_type=RadioTypes.AEHC,
    signal_analyzer=None,
    serial_number="L1203604935",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [197, 206]]
    ],
)
# DU for classicalBTS LNBTS10787
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIL")  #
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_real_enb_pdu.pdu_ports[2],
    hardware_type="ASIL"
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AEHC_U2, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_AZHL_U2, _ru_AEHC_U2,
         _ru_AZHL_U1, _ru_AEHC_U1],
    f1_m_ip_addr="10.106.201.195",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.201.195",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.201.193/28"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.201.195", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.201.195", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.201.195",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.201.193/28"),
    ),
    x2u=NetworkAddress(
        v4="10.106.201.195",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.201.193/28"),
    ),
    s1u=NetworkAddress(
        v4="10.106.201.195",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.201.193/28"),
    ),
)

# DU for classicalBTS LNBTS6480
_lmp_connection_301 = SshServiceDetails(
    addr="10.106.201.196", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_301 = CapacityUnit(addr="192.168.253.20",
                                    hardware_type="ASIL")  #


_common_unit_301 = CommonUnit(
    lmp_connection=_lmp_connection_301,
    capacity_units=[_capacity_unit_301],
    pdu_port=_gnb_pdu_301.pdu_ports[5],
    hardware_type="ASIL"
)

_airscale_301 = Airscale(common_units=[_common_unit_301])

_ru_cablinks_301 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_301, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_301_AEHC, label="SFP", port_id=1),
    )
]

_du_301 = DU(
    airscale=_airscale_301,
    rus=[_ru_301_AEHC],
    f1_m_ip_addr="10.106.201.196",
    cablinks=_ru_cablinks_301,
)

_cu_301 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.201.193/27"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.201.196", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.201.196", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.106.201.193/27"),
    ),
    x2u=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.56.5.129/27"),
    ),
    s1u=NetworkAddress(
        v4="10.106.201.196",
        vlan_id=None,
        routing_v4=RoutingInformation(gateway="10.56.5.129/27"),
    ),
)
# classicalbts
_classical_bts_11423 = ClassicalBts(dus=[_du], cu=_cu, instance_id=11423, global_bts_id=11423)
###
# classicalbts
_classical_bts_301 = ClassicalBts(
    dus=[_du_301], cu=_cu_301, instance_id=301, global_bts_id=301
)
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROID_ASIL_ABIO_ABIP_AZHL_AEHC_MCS"
)
# #host VM pc
_host_11423 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.201.225", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_11423.dus[0].airscale.common_units[0], ue_config],
)
_host_301 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.201.224", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts_301.dus[0].airscale.common_units[0], ue_config],
)
tl = TestLine(
    test_pc=_host_11423,
    test_pcs=[_host_11423, _host_301],
    gnbs=[_classical_bts_11423, _classical_bts_301],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# print(tl)
# old version keyword under robotws5g/resource compatibility workaround