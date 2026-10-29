__maintainer__ = "Krystian Wojakiewicz"
__team__ = "PZ_2_WRO_6"
__email__ = "krystian.wojakiewicz@nokia.com"
__owner_email__ = "krystian.wojakiewicz@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, NetworkAddress, RealEnb, RoutingInformation
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_RUE_attenuator = JFW(
    ip_addr="10.42.54.218", port=3001, attenuation_port_numbers=[9, 10, 15, 16, 11, 12, 13, 14]
)

_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_RUE_attenuator.pdu_port = _pdu_atten.pdu_ports[6]

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_pdu_su = Gude(
    addr="10.44.177.224",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru1 = Gude(
    addr="10.44.206.130",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)  # PDU AHLOA OTX  ##port 12

_pdu_ru2 = Gude(
    addr="10.44.206.131",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)  # PDU AHLOA OVV  ##port 8

_pdu_ru3 = Gude(
    addr="10.44.206.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)  # PDU AHLOA OTS  ##port 5

_abio_master = CapacityUnit(addr="fsp-1a")
_abio_slave = CapacityUnit(addr="fsp-1b")
_abio_loner = CapacityUnit(addr="fsp-1c")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu_su.pdu_ports[1],
)

_airscale = Airscale([_common_unit])

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
    v4="10.44.88.133",
    vlan_id=480,
    routing=RoutingInformation(gateway="10.44.88.129", ip_prefix_length=26),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[12],
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[0:2],
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[2:4],
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[4:6],
)

_du = DU(_airscale, rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=51994, instance_id=51994)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abio_loner], pdu_port=None
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.126", username="ute", password="ute"
    ),
    connections=[_cbts]
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.22.60", "wro5grrm", password="5gpass!1")

_realcore_appsrv_sa = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246", user="syslab", password="Pass4System!",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:fe06"
)

_iperf_ue_sa = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_sa,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name="fast.t-mobile.com/rmnet_data0"
)

_android_ue_1_sa = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.60",
    ue_pc_port="8001",
    data_transfer=[_iperf_ue_sa],
    serial_number="R5CR418HF3P",
    imsi="310260560002095",
    phone_number="+35848560002095",
    capabilities=[
        "REAL_UE_SA",
        "SA_SAMSUNG",
        "REE_SA_UE",
        "SA_VONR",
        "REAL_UE_SA_PING",
    ],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach="16",
    service_call_detach="16",
)

_android_ue_2_sa = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.60",
    ue_pc_port="8001",
    data_transfer=[_iperf_ue_sa],
    serial_number="R5CR418H2VZ",
    imsi="310260560002094",
    phone_number="+35848560002094",
    capabilities=["REAL_UE_SA", "SA_SAMSUNG", "SA_VONR"],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach="16",
    service_call_detach="16",
)

_android_ue_3_sa = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.60",
    ue_pc_port="8001",
    data_transfer=[_iperf_ue_sa],
    serial_number="R5CR80WCE8M",
    imsi="310260560002720",
    phone_number="+35848560002720",
    capabilities=["SA_INTEGRITY"],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach="14",
    service_call_detach="14",
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.90.68",
        vlan_id=487,
        routing=RoutingInformation(gateway="10.44.90.65", ip_prefix_length=26),
    ),
    global_bts_id=40087,
    oam_ip=NetworkAddress(v4="10.44.90.4"),
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB",
    attenuator=_RUE_attenuator,
    core=_real_core,
    ues=[_android_ue_1_sa, _android_ue_2_sa, _android_ue_3_sa],
    enbs=[_lte],
    pdus=[_pdu_su, _pdu_ru1, _pdu_ru2, _pdu_ru3],
)

tl.max_atten_value = 40
tl.tl_type = "sa"
tl.smod_slave = False

tl.qxdm_username = "krystian.wojakiewicz@nokia.com"
tl.qxdm_password = "Password2"

tl.lte_attenuator_ports = [13, 14]
tl.nr_cell_1_ports = [9, 10]
tl.nr_cell_2_ports = [15, 16]

tl.ho_source_ports = tl.nr_cell_1_ports
tl.ho_target_ports = tl.nr_cell_2_ports

__all__ = ["tl"]
