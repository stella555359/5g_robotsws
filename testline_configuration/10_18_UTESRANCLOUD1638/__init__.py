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
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.gnb import CU, ClassicalBts, CloudBts
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
__team__ = "VRF TSR 5"
__email__ = "ovidiu.popa@nokia.com"
__owner__ = "Ovidiu Popa"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# NR
# _attenuator = AHBTE(
#     ip_addr="10.101.48.114",
#     port=5000,
#     attenuation_port_numbers=[6, 8, 14, 16],
#     model="PA-16-16-6-127-0.5-B-S",
# )

# host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.20.242", username="ute", password="UTE.debian12"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")]
)

# 5GRU for classicalBTS RU PB
_ru_pdu_1 = Gude(addr="10.255.1.95", port_numbers=[3])
_ru_pdu_1.pdu_ports[3].contactor = "NORMALLY_CLOSED"
_ru_pdu_2 = Gude(addr="10.255.1.95", port_numbers=[4])
_ru_pdu_2.pdu_ports[4].contactor = "NORMALLY_CLOSED"
_ru_pdu_3 = Gude(addr="10.255.1.95", port_numbers=[5])
_ru_pdu_3.pdu_ports[5].contactor = "NORMALLY_CLOSED"

_ru_1 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="root",
        password="umniedziala",
    ),
    pdu_port=_ru_pdu_1.pdu_ports[3],
    radio_type=RadioTypes.AWHQU,
)
_ru_2 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="root",
        password="umniedziala",
    ),
    pdu_port=_ru_pdu_2.pdu_ports[4],
    radio_type=RadioTypes.AWHQU,
)
_ru_3 = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="root",
        password="umniedziala",
    ),
    pdu_port=_ru_pdu_3.pdu_ports[5],
    radio_type=RadioTypes.AWHQU,
)
# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)
_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ASOG",
    serial_number='L1244410091',
    hardware_version='093801A.104',
    rus=[_ru_1,_ru_2,_ru_3],
)

_gnb_pdu = Gude(addr="10.255.1.94", port_numbers=[10])
_gnb_pdu.pdu_ports[10].contactor = "NORMALLY_CLOSED"

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[10],
    hardware_type="ASOG",
)

_ru_1_cablinks = Cablink(
    source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
    target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
)
_ru_2_cablinks = Cablink(
    source=Endpoint(unit=_capacity_unit, label="SFP", port_id=2),
    target=Endpoint(unit=_ru_2, label="SFP", port_id=1),
)
_ru_3_cablinks = Cablink(
    source=Endpoint(unit=_capacity_unit, label="SFP", port_id=3),
    target=Endpoint(unit=_ru_3, label="SFP", port_id=1),
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(
    airscale=_airscale, rus=[_ru_1,_ru_2,_ru_3], f1_m_ip_addr="10.15.236.38", cablinks=[_ru_1_cablinks,_ru_2_cablinks,_ru_3_cablinks]
)

# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.236.38",
        routing_v4=RoutingInformation(gateway="10.15.236.1/24"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.236.38", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.236.38", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.38",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.38",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.38",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
)

_tl_cloud_topology = "CLOUD_SRAN_N_10638_ASOG_3AWHQU"

# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10638, global_bts_id=10638)
_host.connections.append(Connection(interface="eth1", device=_classical_bts.dus[0].airscale.common_units[0], interface_type="lmp"))


# _appserver_ssh = SshServiceDetails(
#     addr="10.57.191.239", username="vrf3_sg8", password="vrf3@sg8", port="48480"
# )

# _iperf_details_on_appserver = IperfDataTransferDetails(
#     ssh_connection_details=_appserver_ssh,
#     network_interface_address="10.57.191.239",
#     iperf_path="iperf",
#     port=48480,
# )

# _appserver = AppServer(_iperf_details_on_appserver)

# # for FastMile CPE 1
# _fastmile_appserver_1 = TafUeAppServer(
#     app_server_name='APP_SERVER_2',
#     address='10.57.191.239',
#     user='vrf3_sg8',
#     password='vrf3@sg8',
#     bind_interface_ip='10.57.191.239',
#     expected_prompt='[vrf3_sg8@appserver ~]$ ',
#     binary_path='/usr/bin/iperf',
#     ports=[48480, 48481])

# _fastmile_data_transfer_1 = TafUeDataTransferProtocol(
#     protocol_name='iperf',
#     app_server=_fastmile_appserver_1,
#     interval=1,
#     binary_path='iperf',
#     version=2)

# _fastmile_1= TafUeFastmile(
#     com_port='3',
#     ue_pc_address='10.0.176.56',
#     root_password='e87a47326535',
#     ue_manage_ip='192.168.1.1',
#     serial_number='',
#     data_transfer=[_fastmile_data_transfer_1],
#     ue_pc_port=5555,
#     version='3.2',
#     capabilities=['REAL_FASTMILE_UE1', 'nokia_fastmile'])

tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
    # appserver=_appserver,
    # ues=[_fastmile_1],
    core=RealCore(mcc=540, mnc=1),
    # attenuator=[_attenuator],
)
