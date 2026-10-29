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
    addr="10.70.177.57", username="ute", password="Ut3pa5s#ff97", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.70.177.57",
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

_site1_pdu = FPFH(addr="10.108.190.136", port_numbers=[1])
_site1_pdu_rru = FPFH(addr="10.108.190.136", port_numbers=[3])
_attenuator = TopYoung(
    ip_addr="10.106.230.150",
    port=23,
    attenuation_port_numbers=[i for i in range(1, 8)],
    model="8*8"
)
_ru_0 = RU(
    ru_hw_group="AHEGHA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_site1_pdu_rru.pdu_ports[3],
    radio_type=RadioTypes.AHEGHA,
    signal_analyzer=None,
    serial_number="K9242630015",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1]]
    ],
)

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIL")

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_site1_pdu.pdu_ports[1],
    hardware_type="ASIL"
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
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1112, global_bts_id=1112)

# 5GRU for classicalBTS for NRBTS1112


# DU for classicalBTS LNBTS1112
_lmp_connection_1112 = SshServiceDetails(
    addr="10.69.71.97", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_1112 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIL")


_common_unit_1112 = CommonUnit(
    lmp_connection=_lmp_connection_1112,
    capacity_units=[_capacity_unit_1112],
    pdu_port=_site1_pdu.pdu_ports[1],
    hardware_type="ASIL"
)

_airscale_1112 = Airscale(common_units=[_common_unit_1112])

_du_1112 = DU(
    airscale=_airscale_1112,
    rus=[_ru_0],
    f1_m_ip_addr="10.69.71.97",
)

_cu_1112 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.230.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.230.211", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.230.211",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.106.230.193", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_1112 = ClassicalBts(
    dus=[_du_1112], cu=_cu_1112, instance_id=1112, global_bts_id=1112
)

###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDROIDX2_CA_ASIML_ABIPB1_AZQI"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.196.134", username="ute", password="uteUTE!"
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
