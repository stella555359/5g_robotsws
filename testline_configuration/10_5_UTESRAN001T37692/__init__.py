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
    addr="10.56.107.178", username="ute", password="UTE.debian12", port="50002"
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

_site1_pdu = FPFH(addr="10.69.101.24", port_numbers=[5])
_site1_pdu_rru = FPFH(addr="10.69.101.27", port_numbers=[4])
_site1_pdu_rru_2 = FPFH(addr="10.69.101.27", port_numbers=[1])
_site1_pdu_rru_3 = FPFH(addr="10.69.101.27", port_numbers=[2])
_site1_pdu_rru_4 = FPFH(addr="10.69.101.24", port_numbers=[4])
_site1_pdu_rru_5 = FPFH(addr="10.69.101.24", port_numbers=[6])
_attenuator = TopYoung(
    ip_addr="10.0.81.18",
    port=23,
    attenuation_port_numbers=[i for i in range(1, 16)],
    model="16*2"
)
_ru_0 = RU(
    ru_hw_group="AVQA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[4],
    radio_type=RadioTypes.AVQA,
    signal_analyzer=None,
    serial_number="L1251601726",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [7]]
    ],
)
_ru_1 = RU(
    ru_hw_group="AVQA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru_2.pdu_ports[1],
    radio_type=RadioTypes.AVQA,
    signal_analyzer=None,
    serial_number="L1251601728",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [4]]
    ],
)
_ru_2 = RU(
    ru_hw_group="AVQA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru_2.pdu_ports[1],
    radio_type=RadioTypes.AVQA,
    signal_analyzer=None,
    serial_number="L1251601727",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [5]]
    ],
)
_ru_3 = RU(
    ru_hw_group="AHPB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru_2.pdu_ports[1],
    radio_type=RadioTypes.AHPB,
    signal_analyzer=None,
    serial_number="EA232250509",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1]]
    ],
)
_ru_4 = RU(
    ru_hw_group="AHPJ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru_2.pdu_ports[1],
    radio_type=RadioTypes.AHPJ,
    signal_analyzer=None,
    serial_number="K9232737233",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [3]]
    ],
)

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASOE")

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[5],
    hardware_type="ASOE"
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
    rus=[_ru_0,_ru_1],
    f1_m_ip_addr="192.168.255.129",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=37692, global_bts_id=37692)

# 5GRU for classicalBTS for NRBTS37692


# DU for classicalBTS LNBTS37692
_lmp_connection_37692 = SshServiceDetails(
    addr="10.56.107.69", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_37692 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASOE")


_common_unit_37692 = CommonUnit(
    lmp_connection=_lmp_connection_37692,
    capacity_units=[_capacity_unit_37692],
    pdu_port=_site1_pdu.pdu_ports[5],
    hardware_type="ASOE"
)

_airscale_37692 = Airscale(common_units=[_common_unit_37692])

_du_37692 = DU(
    airscale=_airscale_37692,
    rus=[_ru_0,_ru_1],
    f1_m_ip_addr="10.56.107.69",
)

_cu_37692 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.107.69", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.107.69", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.107.69",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.107.65", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts_37692 = ClassicalBts(
    dus=[_du_37692], cu=_cu_37692, instance_id=37692, global_bts_id=37692
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_ASOE_AHPB_AHPJ_VRF"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.107.178", username="ute", password="uteUTE!"
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
