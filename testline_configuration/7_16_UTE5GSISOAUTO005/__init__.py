__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__maintainer__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__email__ = "I_EXT_5G_SISO_CRT@internal.nsn.com"

import os
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
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.lmi import SerialOverTcp, Remote

__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53", user="5g", password="2019H@slo",
    bind_interface_ip="10.45.168.53"
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_android = TafUeAndroid(
    serial_number="be3c0555",
    ue_pc_address="10.42.22.97",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.97", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],

    qualcomm_prototype=True,
    data_transfer=[_iperf],
    service_call_attach=16,
    service_call_detach=16,
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.200",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::290d", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::290d", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::290d", vlan_id=401),
)

_pdu_gnb = Gude(addr="10.44.205.26", port_numbers=[7], model="EPC", version="8221-1")

_pdu_gnb_ru = Gude(addr="10.44.205.80", port_numbers=[4], model="EPC", version="8221-1")

_pdu_enb = Gude(addr="10.44.205.26", port_numbers=[6], model="EPC", version="8221-1")

_pdu_enb_ru = Gude(addr="10.44.205.28", port_numbers=[12], model="EPC", version="8221-1")

_ru_1 = RU(
    ru_hw_group="cMAAr6.2_8T8R_eCPRI",
    radio_type="AKQJ",
    serial_number="1M222600258",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2",
        username="serviceuser",
        password="oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=",
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[4],
    lmi=SerialOverTcp(uart_mapping=[
        Remote(addr="10.255.33.95", port=3000), 
    ]),

)

_abio_1_gnb_1_loner = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0106",
    rus=[_ru_1],
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="DH221042341",
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_1_loner],
    pdu_port=_pdu_gnb.pdu_ports[7],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="L1213102689",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.44", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1])

_enb_ru = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AREA",
    serial_number="K9221528890",
    default_telnet_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_enb_ru.pdu_ports[12],
)

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A102",
    serial_number="K9171936951",
)

_asib_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A101",
    serial_number="L1214315618",
)

_airscale_enb_1 = Airscale(common_units=[_asib_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50147, instance_id=50147
)

_core = RealCore5G()

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::290b", vlan_id=401),
    global_bts_id=40147,
    instance_id=40147,
    oam_ip=NetworkAddress(v4="10.44.67.230", vlan_id=401),
    rms=[_enb_ru],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.239", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBR_ABIO_AKQJ",
    core=_core,
    ues=[_android],
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_enb, _pdu_enb_ru],
)
