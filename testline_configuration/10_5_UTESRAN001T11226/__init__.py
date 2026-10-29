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

__maintainer__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_3@internal.nsn.com"
__team__ = "NSB MN RAN RD VRF HAZ1 3"
__email__ = "I_NSB_MN_RAN_RD_VRF_HAZ1_3@internal.nsn.com"
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Iperf
# _appserver_ssh = SshServiceDetails(
#     addr="10.108.184.78", username="ute", password="ute", port="50002"
# )
_appserver_ssh = SshServiceDetails(
    addr="10.21.41.122", username="ute", password="UTE.debian12", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.21.41.122",
    iperf_path="/usr/bin/",
    port="50002",
)
_appserver = AppServer(_iperf)

ue_config_path = os.path.join(_cfg_dir, "TestData/inseego2.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(stream=f, Loader=yaml.FullLoader)
else:
    ue_config = ""

_site1_pdu = FPFH(addr="10.108.190.140", port_numbers=[1])
_site1_pdu_rru = FPFH(addr="10.108.190.140", port_numbers=[6])
_attenuator = TopYoung(
    ip_addr="10.68.254.183",
    port=23,
    attenuation_port_numbers=[i for i in range(1, 16)],
    model="16*2"
)

_ru_0 = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[6],
    radio_type=RadioTypes.AEHC,
    signal_analyzer=None,
    serial_number="L1202407671",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1]]
    ],
)

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIB")

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[1],
    hardware_type="ASIB"
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_0, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0],
    f1_m_ip_addr="192.168.255.129",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=11226, global_bts_id=11226)

# 5GRU for classicalBTS for NRBTS11226


# DU for classicalBTS LNBTS11226
_lmp_connection_11226 = SshServiceDetails(
    addr="10.69.254.204", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_11226 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIB")


_common_unit_11226 = CommonUnit(
    lmp_connection=_lmp_connection_11226,
    capacity_units=[_capacity_unit_11226],
    pdu_port=_site1_pdu.pdu_ports[1],
    hardware_type="ASIB"
)

_airscale_11226 = Airscale(common_units=[_common_unit_11226])

_du_11226 = DU(
    airscale=_airscale_11226,
    rus=[_ru_0],
    f1_m_ip_addr="10.69.254.204",
)

_cu_11226 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.254.204", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.254.204", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.68.254.204",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts_11226 = ClassicalBts(
    dus=[_du_11226], cu=_cu_11226, instance_id=11226, global_bts_id=11226
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROID_ASIB_ABIC_AEHC"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.196.137", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# old version keyword under robotws5g/resource compatibility workaround
