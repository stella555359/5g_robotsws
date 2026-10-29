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
from taf.config.testline.attenuator import HBTE
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore

__maintainer__ = "Xiang Liangliang"
__team__ = "NSB MN SRAN Prod HZH RRM 2 Vrf"
__email__ = "liang.xiang@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))  # 去掉文件名，返回目录
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.70.19.24", username="ute", password="ute"
    )
)

# Iperf
_appserver_ssh = SshServiceDetails(  # Iperf server,  port是否固定？
    addr="10.70.19.24", username="ute", password="ute", port="54015"
)

_iperf = IperfDataTransferDetails(  # UE 端
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.70.19.24",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)


# Qualcomm
_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.70.14.235", username="feat3", password="Nokia@123"
    ),
    serial_number="e7983f30",  # UE 序列号
    server_dir="/cygdrive/c/pyro_server",  # SSH ue 之后的目录
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM3_S20", "Commercial"]
    # capabilities=['REAL_ANDROID_UE']
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.70.14.235", username="feat3", password="Nokia@123"
    ),
    serial_number="e7983f30",
    # server_dir='/cygdrive/c/pyro_server',
    server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.96---07141439/Pioneer.exe",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM3_S20", "Commercial"]
    # capabilities=['RRM3_S20', 'huawei_sigspark']
)
_sigspark = Android(  # sigspark 是什么
    ssh_connection_details=SshServiceDetails(
        addr="10.70.14.235", username="feat3", password="Nokia@123"
    ),
    serial_number="f29bfcd4",
    server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.96---07141439/Pioneer.exe",
    python_path="C:/Python27",
    iperf_details=_iperf,
    imsi="262033031521182",
)

##RealEnb
_real_enb_pdu = FACOM(addr="10.106.243.239", port_numbers=[5])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[5],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

## attenuator
_attenuator = HBTE(
    ip_addr="10.106.243.238",
    port=3000,
    attenuation_port_numbers=[1, 2, 3, 4],
    model="PA-16-16-6-127-0.5-B-S",
)  # 有什么规则

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.106.243.239", port_numbers=[2])

_ru_0 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[2],
    radio_type=RadioTypes.AHLOA,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
    ],
    serial_number=None,
)


## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")  # 基带板ABIA

_gnb_pdu = FACOM(addr="10.106.243.239", port_numbers=[3])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[3],
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
    airscale=_airscale, rus=[_ru_0], f1_m_ip_addr="10.70.14.172", cablinks=_ru_cablinks
)


_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.70.14.172",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.70.14.129", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.70.14.172", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.70.14.172", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.70.14.172",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.70.14.129", ip_prefix_length=27),
    ),
    x2u=NetworkAddress(
        v4="10.70.14.172",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.70.14.129", ip_prefix_length=27),
    ),
    s1u=NetworkAddress(
        v4="10.70.14.172",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.70.14.129", ip_prefix_length=27),
    ),
)


# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1734, global_bts_id=1734)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AHLOA_ENB_20A"

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    ues=[_android, _android1],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=_attenuator,
)


# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
