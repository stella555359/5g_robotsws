__maintainer__ = "Adrian Karas"
__email__ = "adrian.karas@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Leoni
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.ue import Android


__all__ = ["tl"]


_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.45.168.53",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.45.168.53",
)

_iperf = TafUeDataTransferProtocol(
    app_server=_appserver_ssh, protocol_name="iperf", version=3
)

_asus = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.137", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="M6AIKN009217SWX",
    ue_pc_address="10.42.224.137",
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_iperf],
    is_rooted=True,
    airplane_mode_switcher_text="Airplane mode",
)

_xiaomi = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.224.137", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    serial_number="78532eb2",
    ue_pc_address="10.42.224.137",
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_iperf],
    is_rooted=True,
    airplane_mode_switcher_text="Aeroplane mode"
)

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.66.168",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::602c", vlan_id=465),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::602c", vlan_id=465),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::602c", vlan_id=465),
)

_pdu_gnb = Gude(addr="10.44.206.8", port_numbers=[3], model="EPC", version="8220-1")

# akqj 0939, azqp
_pdu_gnb_ru = Gude(
    addr="10.44.206.218", port_numbers=[2, 5], model="EPC", version="8220-1"
)

# akqj 7697, azqs
_pdu_gnb_ru_2 = Gude(
    addr="10.44.206.11", port_numbers=[2, 5], model="EPC", version="8221-1"
)

_pdu_enb = Gude(addr="10.44.206.8", port_numbers=[11], model="EPC", version="8220-1")

_pdu_enb_ru = Gude(addr="10.44.206.8", port_numbers=[7], model="EPC", version="8220-1")

_asoe_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_gnb.pdu_ports[3],
    hardware_type="ASOE",
    serial_number="EA212356765",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.27", username="ute", password="ute"
    ),
    connections=[_asoe_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asoe_gnb_1])

# _gnb_ru_1 = RU(
#     ru_hw_group="5Ggen4_HighF_2T2R",
#     radio_type="AKQJ",
#     serial_number="1M220107697",
#     product_code="475824A.101",
#     lmp_connection=SshServiceDetails(
#         addr="10.255.33.87",
#         port=3000,
#         username=""
#     ),
#     default_ssh_connection_details=SshServiceDetails(
#         addr="192.168.254.52", username="root", password="root"
#     ),
#     pdu_port=_pdu_gnb_ru_2.pdu_ports[2],
# )

# _gnb_ru_2 = RU(
#     ru_hw_group="5Ggen4_HighF_2T2R",
#     radio_type="AKQJ",
#     serial_number="1M224640939",
#     product_code="475824A.101",
#     lmp_connection=SshServiceDetails(
#         addr="10.255.33.86",
#         port=3000,
#         username=""
#     ),
#     default_ssh_connection_details=SshServiceDetails(
#         addr="192.168.254.52", username="root", password="root"
#     ),
#     pdu_port=_pdu_gnb_ru.pdu_ports[2],
# )

# _gnb_ru_3 = RU(
#     ru_hw_group="5Ggen4_HighF_2T2R",
#     radio_type="AZQP",
#     serial_number="1M210729804",
#     product_code="475198A.102",
#     lmp_connection=SshServiceDetails(
#         addr="10.255.33.112",
#         port=3000,
#         username=""
#     ),
#     default_ssh_connection_details=SshServiceDetails(
#         addr="192.168.254.52", username="root", password="root"
#     ),
#     pdu_port=_pdu_gnb_ru.pdu_ports[5],
# )

_gnb_ru_4 = RU(
    ru_hw_group="5Ggen4_HighF_2T2R",
    radio_type="AZQS",
    serial_number="1M231308419",
    product_code="475664A.101",
    lmp_connection=SshServiceDetails(
        addr="10.255.33.113",
        port=3000,
        username=""
    ),
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="root"
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[5],
)

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_gnb_ru_4]
)  # rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3, _gnb_ru_4]

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50569, instance_id=50569
)

_core = RealCore5G()

_ru_lte = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="FRGU",
    serial_number="AS180324515",
    pdu_port=_pdu_enb_ru.pdu_ports[7],
)

_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20", hardware_type="ABIA", serial_number="RW192102443"
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    hardware_type="ASIA",
    pdu_port=_pdu_enb.pdu_ports[11],
    serial_number="L1172906979",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    airscale=_airscale_enb_1,
    rms=[_ru_lte],
    global_bts_id=8578,
    instance_id=8578,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::5f2b", vlan_id=464),
    oam_ip=NetworkAddress(v4="10.44.66.181"),
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.249", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    ues=[_asus, _xiaomi],
    core=_core,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASOE_2xAKQJ_AZQP_AZQS_ENB",
    pdus=[_pdu_gnb, _pdu_gnb_ru, _pdu_gnb_ru_2, _pdu_enb, _pdu_enb_ru],
)
