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
    MediaTek,
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

from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeFastmile
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

__maintainer__ = "Ovidiu Popa"
__team__ = "VRF_TSR_T05"  # TL owner's team
__email__ = "ovidiu.popa@nokia.com"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# NR
#_attenuator = AHBTE(
#    ip_addr="10.101.48.114",
#    port=5000,
#    attenuation_port_numbers=[6, 8, 14, 16],
#    model="PA-16-16-6-127-0.5-B-S",
#)

# LTE
#_attenuator_LTE = AHBTE(
#    ip_addr="10.101.48.124",
#    port=5000,
#    attenuation_port_numbers=[10, 12, 14, 16],
#    model="PA-16-16-6-127-0.5-B-S",
#)

# host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.175", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")]
)

# 5GRU for classicalBTS RU PB
_ru_pdu = Gude(addr="10.255.1.95", port_numbers=[1])
_ru_pdu.pdu_ports[1].contactor = "NORMALLY_CLOSED"

_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
    radio_type=RadioTypes.AWHQU,
)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20",
                              hardware_type='ABIO',
                              serial_number='L1223203668',
                              hardware_version='475266A.104U',
                              rus=([_ru]))
_gnb_pdu = Gude(addr="10.255.1.94", port_numbers=[5])
_gnb_pdu.pdu_ports[5].contactor = "NORMALLY_CLOSED"
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[5],
    hardware_type='ASIM',
    serial_number='L1242410082',
    hardware_version='475765A.104'
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.15.236.36")

# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.236.36",
        routing_v4=RoutingInformation(gateway="10.15.236.1", ip_prefix_length=24),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.236.36", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.236.36", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.36",
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.36",
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.36",
        routing_v4=RoutingInformation(gateway="10.15.232.1", ip_prefix_length=24),
    ),
)

# RealEnb  enb&enb_HBTE ip_addr
_lmp_connection_enb = SshServiceDetails(
    addr="10.15.236.35", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20",
                              hardware_type='ABIO',
                              serial_number='L1221404046',
                              hardware_version='475266A.104')
_enb_pdu = Gude(addr="10.255.1.95", port_numbers=[2])
_enb_pdu.pdu_ports[2].contactor = "NORMALLY_CLOSED"
_common_unit_1 = CommonUnit(
    lmp_connection=_lmp_connection_enb,
    capacity_units=[_capacity_unit],
    pdu_port=_enb_pdu.pdu_ports[2]
)
_real_enb = Airscale(common_units=[_common_unit_1])
#_lte_real_enb = RealEnb(system_module=_real_enb)
_lte_real_enb = RealEnb(_real_enb)
#airscale=_airscale, f1_m_ip_addr="10.15.236.35")

#_appserver_ssh = SshServiceDetails(
#    addr="10.57.173.234",
#    username="vrf3_sg8",
#    password="vrf3@sg8",
#)

#_iperf_details_on_appserver = IperfDataTransferDetails(
#    ssh_connection_details=_appserver_ssh,
#    network_interface_address="10.57.173.234",
#    iperf_path="iperf",
#    port=48999,
#)

#_appserver = AppServer(_iperf_details_on_appserver)

# for FastMile CPE 1
#_fastmile_appserver_1 = TafUeAppServer(
#    app_server_name='APP_SERVER_2',
#    address='10.57.173.234',
#    user='vrf3_sg8',
#    password='vrf3@sg8',
#    bind_interface_ip='10.57.173.234',
#    expected_prompt='[cmw_sg8@APPServer-3 ~]$ ',
#    binary_path='/usr/bin/iperf',
#    ports=[48008, 48482])

#_fastmile_data_transfer_1 = TafUeDataTransferProtocol(
#    protocol_name='iperf',
#    app_server=_fastmile_appserver_1,
#    interval=1,
#    binary_path='iperf',
#    version=2)

#_fastmile_1= TafUeFastmile(
#    com_port='4',
#    ue_pc_address='10.68.86.17',
#    root_password='78cae8b233f7',
#    ue_manage_ip='192.168.1.1',
#    serial_number='',
#    data_transfer=[_fastmile_data_transfer_1],
#    ue_pc_port=5555,
#    version='3.2',
#    capabilities=['REAL_FASTMILE_UE1', 'nokia_fastmile'])

# for FastMile CPE 2
#_fastmile_appserver_2 = TafUeAppServer(
#    app_server_name='APP_SERVER_2',
#    address='10.57.173.234',
#    user='vrf3_sg8',
#    password='vrf3@sg8',
#    bind_interface_ip='10.57.173.234',
#    expected_prompt='[cmw_sg8@APPServer-3 ~]$ ',
#    binary_path='/usr/bin/iperf',
#    ports=[48009, 48483])

#_fastmile_data_transfer_2 = TafUeDataTransferProtocol(
#    protocol_name='iperf',
#    app_server=_fastmile_appserver_2,
#    interval=1,
#    binary_path='iperf',
#    version=2)

#_fastmile_2= TafUeFastmile(
#    com_port='4',
#    ue_pc_address='10.68.86.19',
#    root_password='2adacc328fef',
#    ue_manage_ip='192.168.1.1',
#    serial_number='',
#    data_transfer=[_fastmile_data_transfer_2],
#    ue_pc_port=5555,
#    version='3.2',
#    capabilities=['REAL_FASTMILE_UE2', 'nokia_fastmile'])

# cloud_topology
_tl_cloud_topology = "CLOUD_SRAN_NL_10636_ASIM_ABIO_AWHQU"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10636, global_bts_id=10636)
_host.connections.append(Connection(interface="eth1", device=_classical_bts.dus[0].airscale.common_units[0], interface_type="lmp"))
tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    enbs=[_lte_real_enb],
#    appserver=_appserver,
#    ues=[_fastmile_1, _fastmile_2],
    core=RealCore(mcc=540, mnc=1),
#    attenuator=[_attenuator, _attenuator_LTE],
    tl_cloud_topology=_tl_cloud_topology,
)
