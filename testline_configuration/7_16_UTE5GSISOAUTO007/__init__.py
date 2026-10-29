__maintainer__ = "Jakub Rychlik"
__team__ = "I_5GSC_5G_PZ1_WRO_4"
__email__ = "I_5GSC_5G_PZ1_WRO_4@internal.nsn.com"
__owner_email__ = "jakub.rychlik@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.ue import Android
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    serial_number="HZQN1876BAKC2300254",
    ue_pc_address="10.44.72.240",
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.240",
        username="wro5goam",
        password="Uteadmin1@"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    data_transfer=[_nokia_iperf],
    is_rooted="yes",
    airplane_mode_switcher_text="Aeroplane mode",
    service_call_attach=16,
    service_call_detach=16,
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip='10.44.67.202',
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::5b6f", vlan_id=460),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::5c6f", vlan_id=461),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::5d6f", vlan_id=462),
)

_pdu_asil = Gude(addr="10.44.177.143", port_numbers=[4], model="EPC", version="8221-1")
_pdu_rus = Gude(addr="10.44.177.143", port_numbers=[1, 2, 3], model="EPC", version="8221-1")

_pdus = [_pdu_rus, _pdu_asil]

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    serial_number="BL2048G1RCA",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.135",
        username="root",
        password=""
    ),
    pdu_port=_pdu_rus.pdu_ports[1],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    serial_number="BL2048G1RE7",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132",
        username="root",
        password=""
    ),
    pdu_port=_pdu_rus.pdu_ports[2],
)

_gnb_ru3 = RU(
    ru_hw_group="Unknown",
    radio_type="AHLOA",
    serial_number="BL2048G1RED",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.132", 
        username="serviceuser", 
        password="umniedziala"
    ),
    pdu_port=_pdu_rus.pdu_ports[3],
)


_core = RealCore5G(mcc=555, mnc=10)

_abio1_du1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    serial_number="L1204104958",
    product_code="475266A.101",
    rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3]
)

_asil_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_du1],
    pdu_port=_pdu_asil.pdu_ports[4],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1203700857",
    product_code="474767A.101",
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.154", username="ute", password="ute"
    ),
    connections=[_asil_du1],
)

_airscale_gnb_1 = Airscale(
    common_units=[_asil_du1],
    product_code="473098A",
)

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3])

_cbts = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50913, instance_id=50913)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASILL_ABIO_3xAHLOA",
    core=_core,
    pdus=_pdus,
    ues=[_nokia]
)
