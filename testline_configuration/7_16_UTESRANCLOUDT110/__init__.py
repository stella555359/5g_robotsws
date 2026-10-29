__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = ""

from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import JFW
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

_pdu_su = Gude(
    addr="10.44.200.109",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru1 = Gude(
    addr="10.44.200.110",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_pdu_ru2 = Gude(
    addr="10.44.200.126",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8041-1",
)

_attenuator = JFW(
    ip_addr="10.42.54.178", port=3001, attenuation_port_numbers=range(1, 19), pdu_port=_pdu_su.pdu_ports[9]
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)


_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.10", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[5],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="1M214615756",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[0:4],
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.18", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[2],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZHM",
    serial_number="1M213405078",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[4:8],
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.128", username="root", password="umniedziala"

    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[1],
    ru_hw_group="FRMr5.1_1_2T4R",
    radio_type="AZHM",
    serial_number="1M223101955",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[8:12],
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="rfsw",
        password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[10],
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AHEC",
    serial_number="6Q183336317",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[12:16],
)

_ru5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="umniedziala"

    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[9],
    ru_hw_group="FRMr5_4T4R",
    radio_type="AZNA",
    serial_number="EA215052912",
    attenuation_ports=list(_attenuator.attenuator_ports.keys())[16:18],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211200992",
    rus=[_ru2, _ru3, _ru4]
)

_fsp_6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1222606875",
    rus=[_ru5]
)
_fsp_7 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.104",
    serial_number="L1211506433",
    rus=[_ru1]
)

_common_unit = CommonUnit(
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1203708183",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5, _fsp_6, _fsp_7],
    pdu_port=_pdu_su.pdu_ports[1]
)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
)

_cu.m = NetworkAddress(
    v4="10.42.84.5",
    vlan_id=517,
    routing=RoutingInformation(gateway="10.42.84.1", ip_prefix_length=26),
)

_du = DU(Airscale([_common_unit]), rus=[_ru1, _ru2, _ru3, _ru4, _ru5])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=55100, instance_id=55100)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=310, mnc=260)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.144", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts.dus[0].airscale.common_units[0]
        )
    ]
)

_realcore_appsrv_ipv4 = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.197.170",
    bind_interface_ip="10.42.197.170",
    user="5g",
    password="2019H@slo"
)
 
_realcore_appsrv_ipv6 = TafUeAppServer(
    app_server_name="realcore",
    address="10.45.168.53",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:ee05",
    user="syslab",
    password="system"
)

_iperf_ue_ipv4 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv4,
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com'
)

_iperf_ue_ipv4_nsa = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv4,
    interval=1,
    server_close_delay=50,
    interface_name='n26wro'
)

_iperf_ue_ipv6 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv6,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com'
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.22.237", "wro5grrm", password="5gpass!1")

_android_ue1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.237",
    ue_pc_port="8001",
    serial_number="R5CT62PXMLV",
    imsi="310260560003292",
    phone_number='+358485600003292',
    capabilities=["SA_VONR", "CNI_03"],
    data_transfer=[_iperf_ue_ipv4],
    network_mode_switch_method='adb'
)

_android_ue2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.237",
    ue_pc_port="8001",
    serial_number="NAAIOC1802899KE",
    imsi="310260560003291",
    phone_number='+358485600003291',
    capabilities=["SA_VONR"],
    data_transfer=[_iperf_ue_ipv4],
    network_mode_switch_method='adb'
)

_android_ue3 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.237",
    ue_pc_port="8001",
    serial_number="0123456789ABCDEF",
    imsi="001016900023030",
    phone_number='+358485630023030',
    capabilities=["MTK_NSA"],
    data_transfer=[_iperf_ue_ipv4_nsa],
    network_mode_switch_method='adb'
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_SRAN_CLASSICAL_HALFRACK_SA_NSA_3xANDROID_1xASIB_3xABIO_3xAZHM_AZNA_AHEC_GNB",
    attenuator=_attenuator,
    core=_real_core,
    ues=[_android_ue1, _android_ue2, _android_ue3],
    pdus=[_pdu_su, _pdu_ru1, _pdu_ru2],
)

tl.max_atten_value = 40
tl.tl_type = "sa/nsa"
tl.smod_slave = False

__all__ = ["tl"]

