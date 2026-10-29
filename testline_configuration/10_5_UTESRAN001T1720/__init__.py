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
    TM500,
    Qualcomm,
    QualcommUeType,
    Android,
)  # added in taf.meta.5.4
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

__maintainer__ = "Yang, Mengli"
__team__ = "NSB MN SRAN Prod HZH RRM 3 Vrf"
__email__ = "mengli.yang@nokia-sbell.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.90.16", username="ute", password="ute"
    )
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.69.90.16", username="ute", password="ute", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.90.16",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)


# Qualcomm
_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.68.161.144", username="shujin", password="Nokia@123"
    ),
    serial_number="f29bfcd4",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM3_Qualcomm8250", "Qualcomm"]
    # capabilities=['REAL_ANDROID_UE']
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.68.161.144", username="shujin", password="Nokia@123"
    ),
    serial_number="f29bfcd4",
    # serial_number='9YS0219B29021344',
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["RRM3_Qualcomm8250", "Qualcomm"]
    # capabilities=['RRM3_HuaweiMat30X', 'Commercial']
    # capabilities=['REAL_ANDROID_UE']
)

_sigspark = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.68.161.144", username="shujin", password="Nokia@123"
    ),
    serial_number="f29bfcd4",
    server_dir="C:/Program Files (x86)/DingLi/Pilot Pioneer10.4.9.96---07301640/Pioneer.exe",
    python_path="C:/Python27",
    iperf_details=_iperf,
    imsi="262033031521182",
)

##RealEnb
_real_enb_pdu = FACOM(addr="10.57.242.6", port_numbers=[1])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.68.161.46", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[1],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

## attenuator
_attenuator = TopYoung(
    ip_addr="10.57.243.53",
    port=3000,
    attenuation_port_numbers=[7, 8, 9, 10],
    model="TAS16T16-51-120-1SDES",
)

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.57.242.20", port_numbers=[1])

_ru_0 = RU(
    ru_hw_group="Below6GHz",  # Above6GHz or Below6GHz
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.148", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[1],
    radio_type=RadioTypes.AWHQE.value,
    signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
    ],
    serial_number=None,
)


## DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.68.161.45", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_gnb_pdu = FACOM(addr="10.57.242.4", port_numbers=[5])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[5],
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(airscale=_airscale, rus=[_ru_0], f1_m_ip_addr="10.68.161.45")

##CU
_f1m = NetworkAddress(v4="9.9.1.1", v6="xxxx", vlan_id=1)
_f1c = NetworkAddress(v4="9.9.1.2", v6="xxxx", vlan_id=2)
_f1u = NetworkAddress(v4="9.9.1.3", v6="xxxx", vlan_id=3)
_x2c = NetworkAddress(v4="9.9.2.1", v6="xxxx", vlan_id=1)
_x2u = NetworkAddress(v4="9.9.2.2", v6="xxxx", vlan_id=2)
_s1c = NetworkAddress(v4="9.9.3.1", v6="xxxx", vlan_id=1)
_s1u = NetworkAddress(v4="9.9.3.2", v6="xxxx", vlan_id=2)
_tracing = NetworkAddress(v4="9.9.1.2", v6="xxxx", vlan_id=1)

_cu = CU(
    backhaul_site_oam_ip="10.68.161.45",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.161.45", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.161.45", username="Nemuadmin", password="nemuuser"
    ),
    f1m=_f1m,
    f1c=_f1c,
    f1u=_f1u,
    x2c=_x2c,
    x2u=_x2u,
    s1c=_s1c,
    s1u=_s1u,
    tracing=_tracing,
)


# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1720, global_bts_id=1720)

_tl_cloud_topology = "CLOUD_5G_BB3"

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    enbs=[_lte_real_enb],
    ues=[_sigspark, _android1],
    appserver=_appserver,
    attenuator=_attenuator,
)


# old version keyword under robotws5g/resource compatibility workaround
# tl = TestlineWrapper(tl)
