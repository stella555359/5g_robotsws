import os
import yaml
import re
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
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
from taf.config.testline.attenuator import AttenuationPort
from taf.config.testline.attenuator import HBTE as AHBTE
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.appserver import AppServer

from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeFastmile
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc

__maintainer__ = "Ovidiu Popa"
__team__ = "VRF TSR1 5"
__email__ = "ovidiu.popa@nokia.com"
__owner__ = "Ovidiu Popa"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# PA
_attenuator = AHBTE(
    ip_addr="10.101.48.124",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
    model="PA-16-16-6-127-0.5-B-S",
)

# host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.244", username="ute", password="UTE.debian12"
    )
)

# 5GRU for classicalBTS RU PB
_ru1_pdu = Gude(addr="10.255.1.90", port_numbers=[10])

_ru1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.64.2",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_ru1_pdu.pdu_ports[10],
    radio_type=RadioTypes.AZNA,
)

_ru2_pdu = Gude(addr="10.255.1.95", port_numbers=[6])

_ru2 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.64.2",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_ru2_pdu.pdu_ports[6],
    radio_type=RadioTypes.AZQC,
)



# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.15.236.63", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_gnb_pdu = Gude(addr="10.255.1.94", port_numbers=[12])
_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[12],
)
_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale, rus=[_ru1, _ru2], f1_m_ip_addr="10.15.236.63")

# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.236.63",
        routing_v4=RoutingInformation(gateway="10.15.236.1/24"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.236.63", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.236.63", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.63",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.63",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    s1u=NetworkAddress(
        v4="110.15.232.63",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
)

# RealEnb  enb&enb_HBTE ip_addr
_lmp_connection_enb = SshServiceDetails(
    addr="10.15.236.37", username="toor4nsn", password="oZPS0POrRieRtu"
)
_enb_pdu = Gude(addr="10.255.1.94", port_numbers=[6])
_common_unit_1 = CommonUnit(
    lmp_connection=_lmp_connection_enb,
    capacity_units=[],
    pdu_port=_enb_pdu.pdu_ports[6],
)
_real_enb = Airscale(common_units=[_common_unit_1])
_lte_real_enb = RealEnb(airscale=_real_enb)

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10663, global_bts_id=10663)

_appserver_ssh = SshServiceDetails(
    addr="10.57.173.234",
    username="vrf3_sg8",
    password="vrf3@sg8",
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.57.173.234",
    iperf_path="iperf",
    port=58999,
)

_appserver = AppServer(_iperf_details_on_appserver)

# for FastMile CPE 1
_fastmile_appserver_1 = TafUeAppServer(
    app_server_name='APP_SERVER_2',
    address='10.57.173.234',
    user='vrf3_sg8',
    password='vrf3@sg8',
    bind_interface_ip='10.57.173.234',
    expected_prompt='[cmw_sg8@APPServer-3 ~]$ ',
    binary_path='/usr/bin/iperf',
    ports=[48025, 48180])

_fastmile_data_transfer_1 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_fastmile_appserver_1,
    interval=1,
    binary_path='iperf',
    version=2)

_fastmile_1= TafUeFastmile(
    com_port='15',
    ue_pc_address='10.68.86.193',
    root_password='c9da6892c68d',
    ue_manage_ip='192.168.1.1',
    serial_number='',
    data_transfer=[_fastmile_data_transfer_1],
    ue_pc_port=5555,
    version='3.2',
    capabilities=['REAL_FASTMILE_UE1', 'nokia_fastmile'])

# for FastMile CPE 2
_fastmile_appserver_2 = TafUeAppServer(
    app_server_name='APP_SERVER_2',
    address='10.57.173.234',
    user='vrf3_sg8',
    password='vrf3@sg8',
    bind_interface_ip='10.57.173.234',
    expected_prompt='[cmw_sg8@APPServer-3 ~]$ ',
    binary_path='/usr/bin/iperf',
    ports=[48026, 48181])

_fastmile_data_transfer_2 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_fastmile_appserver_2,
    interval=1,
    binary_path='iperf',
    version=2)

_fastmile_2= TafUeFastmile(
    com_port='30',
    ue_pc_address='10.68.86.37',
    root_password='8cda4c62c677',
    ue_manage_ip='192.168.1.1',
    serial_number='',
    data_transfer=[_fastmile_data_transfer_2],
    ue_pc_port=5555,
    version='3.2',
    capabilities=['REAL_FASTMILE_UE1', 'nokia_fastmile'])

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    enbs=[_lte_real_enb],
    appserver=_appserver,
    ues=[_fastmile_1, _fastmile_2],
    core=RealCore(mcc=540, mnc=1),
    attenuator=[_attenuator],
)
