__maintainer__ = "Jakub Rychlik"
__email__ = "jakub.rychlik@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, TopYoung
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import Android
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.pdu import Gude, ATEN

__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.205.28", port_numbers=[3], model="EPC", version="8221-1")
_pdu_gnb_ru = Gude(addr="10.44.205.162", port_numbers=[9, 10], model="EPC", version="8221-1")
_pdu_gnb_ru_1 = Gude(addr="10.44.205.57", port_numbers=[11], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.205.28", port_numbers=[4], model="EPC", version="8221-1")
_pdu_enb_ru_1 = Gude(addr="10.44.205.57", port_numbers=[10], model="EPC", version="8221-1")

_gnb_ru_1 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZQP",
    serial_number="1M204213774",
    product_code="475198A.102",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.105", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[10],
)

_gnb_ru_2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZQI",
    serial_number="1M210122531",
    product_code="475243A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.103", port=3000, username=""),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[11],
)

_gnb_ru_3 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AKQJ",
    serial_number="1M222600204",
    product_code="475824A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(addr="10.255.33.104", port=3000, username=""),
    pdu_port=_pdu_gnb_ru.pdu_ports[9],
)

_abil1_gnb_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0126",
    hardware_type="ABIL",
    serial_number="L1183410128",
    rus=[_gnb_ru_3]
)

_abil2_gnb_1 = CapacityUnit(
    addr="fd5f:4268:2387:a881:0040:43ff:fe80:0226",
    hardware_type="ABIL",
    serial_number="L1183608761",
    rus=[_gnb_ru_1, _gnb_ru_2]
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_gnb_1, _abil2_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASIB",
    serial_number="DH211167000",
)

_attenuator = TopYoung(
    ip_addr="10.42.61.222",
    port=3001,
    attenuation_port_numbers=range(1, 16),
    # model="50PA-905",
    # serial_number="30020011358",
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.67.211",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2923", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2923", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c:0000:0000:0000:2923", vlan_id=401),
)

_airscale_gnb_1 = Airscale([_asib_gnb_1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3])

_cbts = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50183)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.131", username="ute", password="ute"
    ),
    connections=[_asib_gnb_1],
)

_enb_ru = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AHEH",
    serial_number="EA203150671",
    default_ssh_connection_details=TelnetConnectionDetails(
        addr="172.16.8.128", port=2323
    ),
    pdu_port=_pdu_enb_ru_1.pdu_ports[10],
)

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    serial_number="RW192102477",
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[4],
    serial_number="L1171419596",
    hardware_type="ASIA",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    rms=[_enb_ru],
    global_bts_id=40183,
    instance_id=40183,
    x2_link_addr=NetworkAddress(
        v6="2a00:8a00:6000:607c:0000:0000:0000:2924", vlan_id=401
    ),
    oam_ip=NetworkAddress(v4="10.44.67.241"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.250", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_core = RealCore5G()

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
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.97", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="4b5f805c",
    ue_pc_address="10.42.22.97",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=True,
    service_call_attach=16,
    service_call_detach=16,
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_android],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AZQP_AZQI_AKQJ_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru_1, _pdu_enb, _pdu_enb_ru_1],
    attenuators=[_attenuator],
)
