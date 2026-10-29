import re
import os
import yaml
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.core import EPCSim, LTEEmuCore, PrismaCore
from taf.config.testline.core import RealCore
from taf.config.testline import RU, DU
from taf.config.testline.pdu import TopYoung
from taf.config.testline.pdu import HBTE, Gude
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android, Qualcomm
from taf.config.testline.gnb import CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.gnb.du import Cablink, Endpoint
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
from taf.config.testline.switch import DellS4048ONSwitch, DellS4048TONSwitch
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.appserver import AppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeFastmile
from taf.config.testline.appserver import TafUeAppServer

__maintainer__ = "Ovidiu Popa"
__team__ = "VRF TSR1 5"
__email__ = "ovidiu.popa@nokia.com"
__owner__ = "Ovidiu Popa"

# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

#_attenuator = AHBTE(
#    ip_addr="10.101.51.41",
#    port=5000,
#    attenuation_port_numbers=[1, 2, 3, 4],
#    model="PA-16-16-6-127-0.5-B-S",
#)
# host
#_host = TestPc(
#    default_ssh_connection_details=SshServiceDetails(
#        addr="10.57.167.223", username="ute", password="iW_K#8.ute%A10h0m0ra"
#    )
#)

# epcsim
_epc_sim = EPCSim(
    mme_ip="10.110.66.198",
    mcc="262",
    mnc="3",
    tac="270",
    default_ssh_connection_details=SshServiceDetails(
        addr="10.70.112.199", username="test", password="NOKIA123"
    ),
    edaemon_port=10000,
    egate_port=20000,
    dir_path="/opt/iphy/latest",
    cfg_filename="LRC.cfg",
)

_mtk_appserver_ssh = SshServiceDetails(
    addr="10.70.222.52",
    username="cmw_sg8",
    password="Bestcm@8",
)

_iperf_details_on_appserver = IperfDataTransferDetails(
    ssh_connection_details=_mtk_appserver_ssh,
    network_interface_address="10.70.222.52",
    iperf_path="iperf",
    port=58426,
)

_appserver = AppServer(_iperf_details_on_appserver)
_mtk_host_ssh = SshServiceDetails(
    addr="10.68.86.36", username="MN5GRAN", password="nokia123@"
)

_iperf_details_on_mtk = IperfDataTransferDetails(
    ssh_connection_details=_mtk_host_ssh,
    network_interface_address="",
    iperf_path="/data/local/tmp/iperf",
    port=58427,
)

# CI_Detail_UE_Type='MTK'
_mtk = MediaTek(
    ssh_connection_details=_mtk_host_ssh,
    server_dir="c:/pyro_server",
    server_port=8080,
    edb_file_path="auto",
    imei="846346065356813",
    imsi="262033100009249",
    apn_url="wap2.nokia.com",
    iperf_details=_iperf_details_on_mtk,
    capabilities=["MEDIATEK_UE_M70",'SA'],
)

# 5GRU for classicalBTS RU PB
#_ru_pdu = HBTE(addr="10.255.1.90", port_numbers=[11])

_ru_pdu = Gude(
    addr="10.255.1.90",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_ru_pdu.pdu_ports[11].contactor = "NORMALLY_CLOSED"

_ru = RU(
    ru_hw_group="hw_group",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.100.3",
        username="serviceuser",
        password="bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=",
    ),
    pdu_port=_ru_pdu.pdu_ports[11],
    radio_type=RadioTypes.AZQC,
)

# #DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    rus=([_ru])
)

_ru_cablinks = Cablink(
    source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
    target=Endpoint(unit=_ru, label="SFP", port_id=1),
)

#_gnb_pdu = HBTE(addr="10.255.1.91", port_numbers=[1])

_gnb_pdu = Gude(
    addr="10.255.1.91",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",	
    version="8220-1",
)

_gnb_pdu.pdu_ports[1].contactor = "NORMALLY_CLOSED"

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[1],
    hardware_type="ASIB",
)


_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(
    airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.15.232.66", cablinks=_ru_cablinks
)
# CU
_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.15.232.66",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.15.232.66", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.15.232.66", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.15.232.66",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    x2u=NetworkAddress(
        v4="10.15.232.66",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
    s1u=NetworkAddress(
        v4="10.15.232.66",
        routing_v4=RoutingInformation(gateway="10.15.232.1/24"),
    ),
)

# cloud_topology
_tl_cloud_topology = "CLOUD_SRAN_N_10666_1ASIB_1ABIO_1AEQM_CBRS_12"
# classicalbts
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=10666, global_bts_id=10666)

_pdus = [_ru_pdu, _gnb_pdu]

#host
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.5.47.62", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_classical_bts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        )
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_classical_bts],
    appserver=_appserver,
    ues=[_mtk],
    core=_epc_sim,
    tl_cloud_topology=_tl_cloud_topology,
	pdus=_pdus,
)
