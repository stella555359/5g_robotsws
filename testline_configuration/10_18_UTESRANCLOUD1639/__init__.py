import os
import yaml
import re
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.core import RealCore
from taf.config.testline import RU, DU
from taf.config.testline.pdu import Gude
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
__team__ = "VRF_TSR_T05"  # TL owner's team
__email__ = "ovidiu.popa@nokia.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

#_attenuator = AHBTE(
#    ip_addr="10.101.40.166",
#    port=5000,
#    attenuation_port_numbers=[7, 8, 9, 10],
#    model="PA-16-16-6-127-0.5-B-S",
#)

# host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.243", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")]
)

#_appserver_ssh = SshServiceDetails(
#    addr="10.57.191.239", username="vrf3_sg8", password="vrf3@sg8", port="48480"
#)

#_iperf = IperfDataTransferDetails(
#    ssh_connection_details=_appserver_ssh,
#    network_interface_address="10.57.191.239",
#    iperf_path="/usr/bin/iperf",
#    port="48480",
#)
#_appserver = AppServer(_iperf)

# SamSung
#_ue1 = Android(
#    ssh_connection_details=SshServiceDetails(addr='10.101.47.229',username='mn5gran',password='nokia123@'),
#    serial_number='RFCW211XACR',
#    server_dir='/cygdrive/c/pyro_server',
#    python_path='/cygdrive/c/Python27/python.exe',
#    iperf_details=_iperf,
#    capabilities=["samsung"]
#)

# 5GRU for classicalBTS RU PB
_ru_pdu = Gude(addr="10.255.1.90", port_numbers=[9])
_ru_pdu.pdu_ports[9].contactor = "NORMALLY_CLOSED"
_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3", username="root", password="umniedziala"
    ),
    pdu_port=_ru_pdu.pdu_ports[9],
    radio_type=RadioTypes.AEQZ,
#    attenuation_ports=[
#        _attenuator.attenuator_ports[7],
#        _attenuator.attenuator_ports[8],
#        _attenuator.attenuator_ports[9],
#        _attenuator.attenuator_ports[10],
#    ],
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20",
                              hardware_type='ABIP',
                              serial_number='L1234800806',
                              hardware_version='475792A.102',
                              rus=([_ru]))
_gnb_pdu = Gude(addr="10.255.1.94", port_numbers=[11])
_gnb_pdu.pdu_ports[11].contactor = "NORMALLY_CLOSED"
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[11],
    hardware_type='ASIM',
    serial_number='L1234204995',
    hardware_version='475765A.104'
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.15.236.39")

# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.236.39",
        routing=RoutingInformation(gateway="10.15.236.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.236.39", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.236.39", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.39",
        routing=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.39",
        routing=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.39",
        routing=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
)

# RealEnb
#_lmp_connection_enb = SshServiceDetails(
#    addr="10.68.88.88", username="toor4nsn", password="oZPS0POrRieRtu"
#)
#_enb_pdu = Gude(addr="10.68.87.37", port_numbers=[8])
#_common_unit_1 = CommonUnit(
#    lmp_connection=_lmp_connection_enb,
#    capacity_units=[],
#    pdu_port=_enb_pdu.pdu_ports[8],
#)
#_real_enb = Airscale(common_units=[_common_unit_1])
#_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# cloud_topology
_tl_cloud_topology = "CLOUD_SRAN_N_10639_ASIM_ABIP_AEQM"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10639, global_bts_id=10639)
_host.connections.append(Connection(interface="eth1", device=_classical_bts.dus[0].airscale.common_units[0], interface_type="lmp"))
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
#    enbs=[_lte_real_enb],
#    appserver=_appserver,
#    ues=[_ue1],
    core=RealCore(mcc=540, mnc=1),
#    attenuator=_attenuator,
    tl_cloud_topology=_tl_cloud_topology,
)
