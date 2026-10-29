__maintainer__ = "UTE team"
__team__ = "UTE team"
__email__ = "ute@nokia.com"
__owner_email__ = "UTE Lab Team"


import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress, RoutingInformation
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, ATEN, RRB, APC, Gude

from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    Android,
    Qualcomm,
    QualcommUeType,
)
from taf.config.testline.appserver import AppServer


# added in taf.meta 5.4
from taf.config.testline.attenuator import AttenuationPort, TopYoung, HBTE, JFW
from taf.config.testline.core import RealCore
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)


from taf.config.testline.enb import (
    Enb,
    SimEnb,
    RealEnb,
    LTEEmuEnb,
    PrismaEnb,
    DocomoEnb,
)


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
# #host
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.69.212", username="ute", password="uteUTE!"
    )
)

_attenuator = HBTE(
    ip_addr="10.69.70.4",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="50PA-574",
)
# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.69.69.212", username="ute", password="uteUTE!", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.69.9.10",
    iperf_path="iperf",
    port="54015",
)

_appserver = AppServer(_iperf)


#

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.82.7", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="f5c49ba7",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "RRM1_MSM845"],
)

_xiaomi12 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.82.7", username="csv1-tester", password="Nokia123!"
    ),
    serial_number="40a39a3c",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "xiaomi12"],
)

##RealEnb
_real_enb_pdu = FACOM(addr="10.69.70.40", port_numbers=[8])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
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


# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.69.70.40", port_numbers=[6])

_ru_0 = RU(
    ru_hw_group="AHEGB",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[6],
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
    addr="192.168.255.129",
    # addr="10.69.68.210",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
)

_capacity_unit = CapacityUnit(
    addr="192.168.255.129",
    hardware_type="ABIO",
)

_gnb_pdu = FACOM(addr="10.69.70.40", port_numbers=[8])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[8],
    hardware_type="ASOE",
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
    airscale=_airscale, rus=[_ru_0], f1_m_ip_addr="10.68.152.243", cablinks=_ru_cablinks
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.68.152.243",
        vlan_id=None,
        routing=RoutingInformation(gateway="10.69.68.192", ip_prefix_length=27),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.68.152.243", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.68.152.243", username="Nemuadmin", password="nemuuser"
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
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10723, global_bts_id=10723)




tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classical_bts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_QC_ASILR_ABIO_AZQP_AZHL",
    #enbs=[_lte_real_enb],
    ues=[_xiaomi12,_android],
    appserver=_appserver,
    core=RealCore(mcc=460, mnc=0),
    attenuator=_attenuator,
)

__all__ = ["tl"]
