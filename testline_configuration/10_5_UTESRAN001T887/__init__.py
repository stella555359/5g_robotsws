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

__maintainer__ = "Niky Lu"
__team__ = "NSB MN RAN Pz1 HAZ7"
__email__ = "nicky.lu@nokia-sbell.com"
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.68.254.194", username="ute", password="ute", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.68.254.194",
    iperf_path="/usr/bin/",
    port="50002",
)
_appserver = AppServer(_iperf)
# Iperf
_appserver_ssh_2 = SshServiceDetails(
    addr="10.68.254.195", username="ute", password="ute", port="50003"
)
_iperf_2 = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh_2,
    network_interface_address="10.68.254.195",
    iperf_path="/usr/bin/",
    port="50003",
)
_appserver_2 = AppServer(_iperf_2)

ue_config_path = os.path.join(_cfg_dir, "TestData/inseego2.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(stream=f, Loader=yaml.FullLoader)
else:
    ue_config = ""

# _android = Android(
#     ssh_connection_details=SshServiceDetails(
#         addr="10.70.14.235", username="feat3", password="Nokia@123"
#     ),
#     serial_number="e7983f30",
#     # server_dir='/cygdrive/c/pyro_server',
#     server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.96---07141439/Pioneer.exe",
#     python_path="/cygdrive/c/Python27/python.exe",
#     qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
#     diag_cfg_path="C:/pyro_server/DIAG.cfg",
#     iperf_details=_iperf,
#     capabilities=["RRM3_S20", "Commercial"]
#     # capabilities=['RRM3_S20', 'huawei_sigspark']
# )

# #RealEnb#
_real_enb_pdu = FACOM(addr="10.108.191.38", port_numbers=[2])
_attenuator = HB(
    ip_addr="10.108.237.67",
    port=5000,
    attenuation_port_numbers=[i for i in range(1, 257)],
    model="PA-16-16-6-127-0.5-B-S",
)
_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.56.5.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[2],
    hardware_type="ASIB"
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# RUs for classicalBTS for NRBTS887
_ru_0_pdu = HBTE(addr="10.108.191.39", port_numbers=[1])
_ru_1_pdu = HBTE(addr="10.108.191.39", port_numbers=[5])
_ru_2_pdu = HBTE(addr="10.108.191.39", port_numbers=[3])
_ru_3_pdu = HBTE(addr="10.108.191.39", port_numbers=[6])

_ru_0 = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.56.6", username="root", password=""
    ),
    pdu_port=_ru_0_pdu.pdu_ports[1],
    radio_type=RadioTypes.AEHC,
    signal_analyzer=None,
    serial_number="L1202407674",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [255]
    ],
)
_ru_1 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.128", username="root", password=""
    ),
    pdu_port=_ru_1_pdu.pdu_ports[5],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2037V0LIO",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [7, 37, 70, 104]
    ],
)
_ru_2 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.129", username="root", password=""
    ),
    pdu_port=_ru_2_pdu.pdu_ports[3],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2106G10A9",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [9, 42, 75, 108]
    ],
)
_ru_3 = RU(
    ru_hw_group="AHFIG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    pdu_port=_ru_3_pdu.pdu_ports[6],
    radio_type=RadioTypes.AHFIG,
    signal_analyzer=None,
    serial_number="K9203119603",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [19, 49, 82, 116]
    ],
)

_ru_1_mtk = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.128", username="root", password=""
    ),
    pdu_port=_ru_1_pdu.pdu_ports[5],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2037V0LIO",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [8, 39, 69, 102, 134]
    ],
)
_ru_3_mtk = RU(
    ru_hw_group="AHFIG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    pdu_port=_ru_3_pdu.pdu_ports[6],
    radio_type=RadioTypes.AHFIG,
    signal_analyzer=None,
    serial_number="K9203119603",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [20, 51, 81, 114, 146]
    ],
)
_ru_6_cell22 = RU(
    ru_hw_group="AHFIG",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    pdu_port=_ru_3_pdu.pdu_ports[6],
    radio_type=RadioTypes.AHFIG,
    signal_analyzer=None,
    serial_number="K9203119603",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [131, 140, 146, 153]
    ],
)
# DU for classicalBTS NRBTS887
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIB")
_gnb_pdu = FACOM(addr="10.108.191.38", port_numbers=[1])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_gnb_pdu.pdu_ports[1],
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
    rus=[_ru_0, _ru_1, _ru_2, _ru_3, _ru_1_mtk, _ru_3_mtk, _ru_6_cell22],
    f1_m_ip_addr="10.56.5.132",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.132",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.132", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.132", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.132",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.132",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.132",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
)

_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=887, global_bts_id=887)

# RU for classicalBTS for LNBTS2138
_ru_2138_pdu = HBTE(addr="10.108.191.39", port_numbers=[4])

_ru_2138 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.77.130", username="root", password=""
    ),
    pdu_port=_ru_2138_pdu.pdu_ports[4],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2146V0QO4",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [23, 53, 86, 120]]
    ],
)

# DU for classicalBTS LNBTS2138
_lmp_connection_2138 = SshServiceDetails(
    addr="10.56.5.131", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_2138 = CapacityUnit(addr="192.168.253.20",
                                   hardware_type="ASIA")
_gnb_pdu_2138 = FACOM(addr="10.108.191.38", port_numbers=[2])

_common_unit_2138 = CommonUnit(
    lmp_connection=_lmp_connection_2138,
    capacity_units=[_capacity_unit_2138],
    pdu_port=_gnb_pdu_2138.pdu_ports[2],
    hardware_type="ASIA"
)

_airscale_2138 = Airscale(common_units=[_common_unit_2138])

_ru_cablinks_2138 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_2138, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_2138, label="SFP", port_id=1),
    )
]

_du_2138 = DU(
    airscale=_airscale_2138,
    rus=[_ru_2138],
    f1_m_ip_addr="10.56.5.131",
    cablinks=_ru_cablinks_2138,
)

_cu_2138 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.56.5.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.5.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.5.131", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.56.5.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.56.5.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.56.5.131",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.56.5.129", ip_prefix_length=26),
    ),
)

# classicalbts
_classical_bts_2138 = ClassicalBts(
    dus=[_du_2138], cu=_cu_2138, instance_id=2138, global_bts_id=2138
)
###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBR_ABIO_ABIL2_AEHC_AHFIB_AHLOA_AHFIG"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.135", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
_host_2138 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.136", username="ute", password="UTE.debian12"
    ),
    connections=[_classical_bts_2138.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_host,
    test_pcs=[_host, _host_2138],
    gnbs=[_classical_bts, _classical_bts_2138],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    appservers=[_appserver, _appserver_2],
    ues=[ue_config],
    attenuator=_attenuator,
)
# old version keyword under robotws5g/resource compatibility workaround
# print(tl)
