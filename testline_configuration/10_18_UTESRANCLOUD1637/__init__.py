import os
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import RealCore
from taf.config.testline import RU, DU
from taf.config.testline.pdu import Gude
from taf.config.testline.pdu import HBTE
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.gnb import CU, ClassicalBts
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
from taf.config.testline import RealEnb
from taf.compatibility.configuration import TestlineWrapper
from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.attenuator import HBTE as AHBTE
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.appserver import AppServer

__maintainer__ = "Ovidiu Popa"
__team__ = "VRF TSR1 5"
__email__ = "ovidiu.popa@nokia.com"
__owner__ = "Ovidiu Popa"
# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

_attenuator = AHBTE(
    ip_addr="10.101.51.50",
    port=5000,
    attenuation_port_numbers=[5, 6, 7, 8],
    model="PA-16-16-6-127-0.5-B-S",
)
# host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.176", username="ute", password="UTE.debian12"
    )
)

_appserver_ssh = SshServiceDetails(
    addr="10.57.162.11", username="cmw_sg8", password="cm@8", port="58999"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.57.162.11",
    iperf_path="/usr/bin/iperf",
    port="58010",
)
_appserver = AppServer(_iperf)
_appserver.iperf_details.port = 58011

# CI_Detail_UE_Type='Huawei Mate 30 Pro 5G'
_ue1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.68.86.165", username="nokia5G", password="noki@123"
    ),
    serial_number="9YS0220221014539",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    iperf_details=_iperf,
    capabilities=["SG8_mate30pro", "huawei"],
)


# 5GRU for classicalBTS RU PB
_ru_pdu = Gude(addr="10.255.1.90", port_numbers=[10])

_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.49", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[10],
    radio_type=RadioTypes.AAHF,
    attenuation_ports=[
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.15.236.37", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_gnb_pdu = Gude(addr="10.255.1.94", port_numbers=[6])
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[6],
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.15.236.37")

# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.236.37",
        routing_v4=RoutingInformation(gateway="10.15.236.1/24"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.236.37", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.236.37", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.37",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.37",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.37",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
)


# cloud_topology
_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AEQI"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=1001, global_bts_id=51001)


tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    appserver=_appserver,
    ues=[_ue1],
    core=RealCore(mcc=540, mnc=1),
    attenuator=_attenuator,
    tl_cloud_topology=_tl_cloud_topology,
)
