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
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude, HBTE
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

__maintainer__ = "Weng,keli"
__team__ = "NSB MN SRAN PROD IWK HZ GMS"
__email__ = "keli.weng@nokia-sbell.com"
# 2298 is enb site treate as 5g site
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))


# Iperf
# _appserver_ssh = SshServiceDetails(
#     addr="10.108.184.78", username="ute", password="ute", port="50002"
# )
_appserver_ssh = SshServiceDetails(
    addr="10.56.221.13", username="ute", password="ute", port="50002"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.56.221.13",
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
_real_enb_pdu = HBTE(addr="10.108.164.132", port_numbers=[5])
_attenuator = TopYoung(
    ip_addr="10.108.164.161",
    port=3000,
    attenuation_port_numbers=[i for i in range(1, 257)],
    model="TAS32B8-51-120-1N-DES",
)

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[5],
    hardware_type="ASIB"
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# 5GRU for classicalBTS for LNBTS2298
_ru_0_1_2_pdu = HBTE(addr="10.108.164.153", port_numbers=[2, 3, 4])

_ru_0 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_ru_0_1_2_pdu.pdu_ports[3],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2116G1CFD",
    attenuation_ports=[
        _attenuator.attenuator_ports[i] for i in [i for i in [1, 10, 19, 28]]  # port 20
    ],
)
_ru_1 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_0_1_2_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2111V09PT",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [33, 42, 51, 60]]
    ],
)
_ru_1_cell_66 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_0_1_2_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2111V09PT",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [51, 60]]
    ],
)
_ru_1_cell_2 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.129", username="root", password=""
    ),
    pdu_port=_ru_0_1_2_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2111V09PT",
    attenuation_ports=[
        _attenuator.attenuator_ports[j] for j in [i for i in [33, 42]]
    ],
)
# _ru_2 = RU(
#     ru_hw_group="AZHL",
#     default_ssh_connection_details=SshServiceDetails(
#         addr="172.22.57.162", username="root", password=""
#     ),
#     lmp_connection=SshServiceDetails(
#         addr="172.22.57.162", username="root", password=""
#     ),
#     pdu_port=_ru_0_1_2_pdu.pdu_ports[1],
#     radio_type=RadioTypes.AZHL,
#     signal_analyzer=None,
#     serial_number="YK210500030",
#     attenuation_ports=[
#         _attenuator.attenuator_ports[j]
#         for j in [i for i in [193, 202, 211, 220, 225, 234, 243, 252]]
#     ],
# )
_ru_2 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.33.128", username="root", password=""
    ),
    pdu_port=_ru_0_1_2_pdu.pdu_ports[4],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    serial_number="EA203761482",
    attenuation_ports=[
        _attenuator.attenuator_ports[i]
        for i in [i for i in [65, 66, 67, 68]]  # port 65~68
    ],
)

# DU for classicalBTS LNBTS6231
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_0 = CapacityUnit(addr="192.168.253.20",
                                hardware_type="ASIB")  #
_gnb_pdu = HBTE(addr="10.108.164.132", port_numbers=[6])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit_0],
    pdu_port=_real_enb_pdu.pdu_ports[5],
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
    rus=[_ru_0, _ru_1, _ru_2, _ru_1_cell_66, _ru_1_cell_2],
    f1_m_ip_addr="10.106.243.146",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.243.146",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.151.1", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.243.146", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.243.146", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.243.146",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.151.1", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.243.146",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.151.1", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.243.146",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.151.1", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=2485, global_bts_id=2485)

# 5GRU for classicalBTS for NRBTS6480
_ru_6480_pdu = HBTE(addr="10.108.164.153", port_numbers=[1,2,3,4])

_ru_6480_AHLOA = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_ru_6480_pdu.pdu_ports[3],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2116G1CFD",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [193, 202, 211, 220, 225, 234, 243, 252]]
    ],
)
_ru_6480_AHLOA_2 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_ru_6480_pdu.pdu_ports[4],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    serial_number="BL2118G1DNV",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [193, 202, 211, 220, 225, 234, 243, 252]]
    ],
)
_ru_6480_AHFIB = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    pdu_port=_ru_6480_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHFIB,
    signal_analyzer=None,
    serial_number="BL2111V09PT",
    attenuation_ports=[
        _attenuator.attenuator_ports[j]
        for j in [i for i in [193, 202, 211, 220, 225, 234, 243, 252]]
    ],
)
# DU for classicalBTS LNBTS6480
_lmp_connection_6480 = SshServiceDetails(
    addr="10.106.243.145", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit_6480 = CapacityUnit(addr="192.168.253.20", hardware_type="ASIB")  #
_gnb_pdu_6480 = FACOM(addr="10.108.164.132", port_numbers=[6])

_common_unit_6480 = CommonUnit(
    lmp_connection=_lmp_connection_6480,
    capacity_units=[_capacity_unit_6480],
    pdu_port=_gnb_pdu_6480.pdu_ports[6],
    hardware_type="ASIB"
)

_airscale_6480 = Airscale(common_units=[_common_unit_6480])

_ru_cablinks_6480 = [
    Cablink(
        source=Endpoint(unit=_capacity_unit_6480, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_6480_AHLOA, label="SFP", port_id=1),
    )
]

_du_6480 = DU(
    airscale=_airscale_6480,
    rus=[_ru_6480_AHLOA, _ru_6480_AHLOA_2, _ru_6480_AHFIB],
    f1_m_ip_addr="10.106.243.145",
    cablinks=_ru_cablinks_6480,
)

_cu_6480 = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.106.243.145",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.231.129", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.106.243.145", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.106.243.145", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.106.243.145",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.231.129", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.106.243.145",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.231.129", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.106.243.145",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.231.129", ip_prefix_length=27),
    ),
)

# classicalbts
_classical_bts_6480 = ClassicalBts(
    dus=[_du_6480], cu=_cu_6480, instance_id=6480, global_bts_id=6480
)
###
_tl_cloud_topology = (
    "CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIO_ABIN_AHLOA_AHFIB-ASIKR_ABIL2_AZHL"
)
# #host VM pc
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.213.241", username="ute", password="uteUTE!"
    ),
    connections=[_classical_bts.dus[0].airscale.common_units[0], ue_config],
)
_host_6480 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.108.213.240", username="ute", password="ute"
    ),
    connections=[_classical_bts_6480.dus[0].airscale.common_units[0], ue_config],
)
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host_6480],
    gnbs=[_classical_bts_6480],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    core=RealCore(mcc=460, mnc=2),
    appserver=_appserver,
    ues=[ue_config],
    attenuator=_attenuator,
)
# old version keyword under robotws5g/resource compatibility workaround
# print(tl)
