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

_site1_pdu = FPFH(addr="10.108.190.140", port_numbers=[1,3])
_site1_pdu_rru = FPFH(addr="10.108.190.140", port_numbers=[2,4,6])
# _site1_pdu_rru_2 = FPFH(addr="10.108.190.140", port_numbers=[4])
_attenuator = TopYoung(
    ip_addr="10.68.254.183",
    port=8000,
    attenuation_port_numbers=[i for i in range(1, 16)],
    model="TAS16T16-51-120-1S-DES"
)

_ru_AHPMDA = RU(
    ru_hw_group="AHPMDA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[2],
    radio_type=RadioTypes.AHPMDA,
    signal_analyzer=None,
    serial_number="1M223213280",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1]]
    ],
)

_ru_AZQI = RU(
    ru_hw_group="AZQI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[4],
    radio_type=RadioTypes.AZQI,
    signal_analyzer=None,
    serial_number="K9184238544",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [5]]
    ],
)

_ru_AEHC = RU(
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
        _attenuator.attenuator_ports[i] for i in [i for i in [5]]
    ],
)

# _lmp_connection = SshServiceDetails(
#     addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
# )

_capacity_unit_37541 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIM")

_capacity_unit_11226 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIB")

# _common_unit_0 = CommonUnit(
#     lmp_connection=_lmp_connection,
#     capacity_units=[_capacity_unit_0],
#     pdu_port=_site1_pdu.pdu_ports[3],
#     hardware_type="ASIM"
# )

# _airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks_37541 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_37541, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AHPMDA, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit_37541, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_AZQI, label="SFP", port_id=1),
    )
]

_ru_cablinks_11226 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_11226, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_AEHC, label="SFP", port_id=1),
    )
]

# _du = DU(
#     airscale=_airscale,
#     rus=[_ru_0,_ru_1],
#     f1_m_ip_addr="192.168.255.129",
#     cablinks=_ru_cablinks,
# )

# _cu = CU(
#     backhaul_site_oam_ip=NetworkAddress(
#         v4="10.68.254.205",
#         vlan_id=10,
#         routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
#     ),
#     oam_ssh_connection_details=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     oam_http_connection_details=HttpConnectionDetails(
#         addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
#     ),
#     x2c=NetworkAddress(
#         v4="10.68.254.205",
#         vlan_id=10,
#         routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
#     ),
#     x2u=NetworkAddress(
#         v4="10.68.254.205",
#         vlan_id=10,
#         routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
#     ),
#     s1u=NetworkAddress(
#         v4="10.68.254.205",
#         vlan_id=10,
#         routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
#     ),
# )

# classicalbts
# _classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=37541, global_bts_id=37541)

# 5GRU for classicalBTS for NRBTS37541


# DU for classicalBTS LNBTS37541
_lmp_connection_37541 = SshServiceDetails(
    addr="10.68.254.205", username="toor4nsn", password="oZPS0POrRieRtu"
)

_lmp_connection_11226 = SshServiceDetails(
    addr="10.68.254.204", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_37541 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIM")

_capacity_unit_11226 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIB")


_common_unit_37541 = CommonUnit(
    lmp_connection=_lmp_connection_37541,
    capacity_units=[_capacity_unit_37541],
    pdu_port=_site1_pdu.pdu_ports[3],
    hardware_type="ASIM"
)

_common_unit_11226 = CommonUnit(
    lmp_connection=_lmp_connection_11226,
    capacity_units=[_capacity_unit_11226],
    pdu_port=_site1_pdu.pdu_ports[1],
    hardware_type="ASIB"
)

_airscale_37541 = Airscale(common_units=[_common_unit_37541])
_airscale_11226 = Airscale(common_units=[_common_unit_11226])

_du_37541 = DU(
    airscale=_airscale_37541,
    rus=[_ru_AHPMDA, _ru_AZQI],
    f1_m_ip_addr="10.68.254.205",
    cablinks=_ru_cablinks_37541,
)

_du_11226 = DU(
    airscale=_airscale_11226,
    rus=[_ru_AEHC],
    f1_m_ip_addr="10.68.254.204",
    cablinks=_ru_cablinks_11226,
)

_cu_37541 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.68.254.205",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.254.205", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.254.205", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.68.254.205",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.68.254.205",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.68.254.205",
        vlan_id=10,
        routing=RoutingInformation(gateway="10.68.254.193", ip_prefix_length=26),
    ),
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
_classical_bts_37541 = ClassicalBts(
    dus=[_du_37541], cu=_cu_37541, instance_id=37541, global_bts_id=37541
)

_classical_bts_11226 = ClassicalBts(
    dus=[_du_11226], cu=_cu_11226, instance_id=11226, global_bts_id=11226
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROID_ASIM_ABIP_ABIO_AZQI_AHPMDA"
)
# #host VM pc
_host_37541 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.196.138", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts_37541.dus[0].airscale.common_units[0], ue_config],
)

_host_11226 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.196.137", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts_11226.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_host_37541,
    test_pcs=[_host_37541,_host_11226],
    gnbs=[_classical_bts_37541, _classical_bts_11226],
    tl_cloud_topology=_tl_cloud_topology,
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# old version keyword under robotws5g/resource compatibility workaround
