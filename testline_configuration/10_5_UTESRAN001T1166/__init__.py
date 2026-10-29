import os
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import DU
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude
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
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE, JFW
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "Zhou,Zhiqiang"
__team__ = "NSB MN SRAN Prod HZH RRM 4 Vrf"
__email__ = "zhiqiang.q.zhou@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.212.41", username="ute", password="ute"
    )
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.69.112.179", username="ute", password="ute", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.112.179",
    iperf_path="iperf",
    port="54015",
)

_appserver = AppServer(_iperf)

# Qualcomm
_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.112.154", username="five-tester", password="Nokia123!"
    ),
    serial_number="R5CN20BJXTL",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM4_MIFI", "dingli"],
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.112.154", username="five-tester", password="Nokia123!"
    ),
    serial_number="XPL0219A25005408",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM4_MIFI", "dingli"],
)

_sigspark = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.112.154", username="five-tester", password="Nokia123!"
    ),
    serial_number="31ce8f00",
    server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.107---11121111/Pioneer.exe",
    python_path="C:/Python27/python.exe",
    iperf_details=_iperf,
    imsi="460028001009008",
    capabilities=["REAL_ANDROID_UE", "Dingli"],
)

# _sigspark = Android(
#     ssh_connection_details=SshServiceDetails(
#         addr="10.69.82.19",
#         username="five-tester",
#         password="Nokia123!"),
#     serial_number="31ce8f00",
#     server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.107---11121111/Pioneer.exe",
#     python_path="/cygdrive/c/Python27/python.exe",
#     iperf_details=_iperf,
#     imsi="460028001009008",
#     capabilities=["REAL_ANDROID_UE", "Dingli"]
# )

##RealEnb
_real_enb_pdu = FACOM(addr="10.106.212.232", port_numbers=[8])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.69.68.210", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[8],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

## attenuator
# _attenuator = HBTE(
#     ip_addr="0.0.0.0",
#     port=3001,
#     attenuation_port_numbers=[
#         1,
#         2,
#         3,
#         4],
#     model="PA-16-16-6-127-0.5-B-S")
_attenuator = JFW(
    ip_addr="10.69.71.4",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
    model="50PA-574",
)

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="0.0.0.0", port_numbers=[2])

_ru_0 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHEGB,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
    serial_number=None,
)

## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    # addr="192.168.255.129",
    addr="10.106.212.77",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_gnb_pdu = FACOM(addr="10.106.212.232", port_numbers=[5])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit_0])

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    ),
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=2),
    ),
]

_du = DU(
    airscale=_airscale, rus=[_ru_0], f1_m_ip_addr="10.69.68.210", cablinks=_ru_cablinks
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.69.68.210",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.68.192", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.68.210", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.68.210", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.108.233.27",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.0", ip_prefix_length=25),
    ),
    x2u=NetworkAddress(
        v4="10.108.233.27",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.0", ip_prefix_length=25),
    ),
    s1u=NetworkAddress(
        v4="10.108.233.27",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.108.233.0", ip_prefix_length=25),
    ),
)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1166, global_bts_id=1370)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AHLOA_ENB_20A"

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    ues=[_sigspark, _android1],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=_attenuator,
)

# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
