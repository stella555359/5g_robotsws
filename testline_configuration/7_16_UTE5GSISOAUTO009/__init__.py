__team__ = "MN RAN Pz 1 WRO 9 SGo"
__maintainer__ = "Emilia Pawlaszek"
__email__ = "emilia.pawlaszek@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
	TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import NetworkAddress
from taf.config.testline.pdu import Gude
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.243", port_numbers=[6], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(
    addr="10.44.205.243", port_numbers=[7, 1], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZHM",
    serial_number="4H211630027",
    product_code="475546A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.204", port=3000), 
        Remote(addr="10.255.33.204", port=3001)]),

    pdu_port=_pdu_gnb_ru.pdu_ports[7],
)

_ru_2 = RU(
    ru_hw_group="5Ggen3_HighF_2T2R",
    radio_type="AZHM",
    serial_number="4H211430007",
    product_code="475546A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="rfsw",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.203", port=3000), 
        Remote(addr="10.255.33.203", port=3001)]),

    pdu_port=_pdu_gnb_ru.pdu_ports[1],
)

_asil_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[6],
    hardware_type="ASOE",
    hardware_version="A102",
    serial_number="EA213153879",
)

_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2])

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.234",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::2916", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::2916", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::2916", vlan_id=401),
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=40590
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.43", username="ute", password="uteUTE!"
    ),
    connections=[_asil_gnb_1],
)

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.127", username="wro5goam", password="Uteadmin1@"
    ),
    serial_number="M9AIKN01N511F26",
    ue_pc_address="10.44.72.127",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    network_mode_switch_method="adb",
    ue_pc_port="80",
)
tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_2xAZHM_SA",
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
