__maintainer__ = "Bartosz Galczynski"
__team__ = "PZ_2_WRO_6_SG"
__email__ = "bartosz.galczynski@nokia.com"
__owner_email__ = "adam.florek@nokia.com"

import os
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

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_attenuator24 = JFW(
    ip_addr="10.42.221.139", port=3001, attenuation_port_numbers=range(1, 25)
)
_attenuator12 = JFW(
    ip_addr="10.42.54.10", port=3001, attenuation_port_numbers=range(1, 13)
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2="10.27.194.14")

_abio_master = CapacityUnit(addr="fsp-1a")
_abio_slave = CapacityUnit(addr="fsp-1b")
_abio_loner = CapacityUnit(addr="fsp-1c")

_abia_master = CapacityUnit(addr="fsp-2a")
_abia_slave = CapacityUnit(addr="fsp-2b")
_abia_loner = CapacityUnit(addr="fsp-2c")

_abia_master2 = CapacityUnit(addr="fsp-3a")
_abia_slave2 = CapacityUnit(addr="fsp-3b")
_abia_loner2 = CapacityUnit(addr="fsp-3c")

_pdu_smod = Gude(
    addr="10.44.205.189", port_numbers=[7, 10], model="EPC", version="8221-1"
)

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_master, _abio_slave, _abio_loner, _abia_master, _abia_slave, _abia_loner, _abia_master2,
                    _abia_slave2, _abia_loner2],
    pdu_port=_pdu_smod.pdu_ports[10],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu", port=443
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.224.14",
    vlan_id=915,
    routing=RoutingInformation(gateway="10.44.224.1", ip_prefix_length=26),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AHPMDB",
)

_du = DU(_airscale, rus=[_ru])

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=234, mnc=30)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abio_loner], pdu_port=None
)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.18", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo"
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='everywhere/rmnet_data3'
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.18",
    ue_pc_port="8001",
    serial_number="N9AIOC14611A3M",
    imsi="234300100000516",
    phone_number='+358485620000516',
    capabilities=["REAL_UE"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    airplane_mode_switcher_text="Airplane",
    airplane_mode_confirm_button_text="OK",
    secret_code="*#*#4636#*#*",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_android_ue_2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.18",
    ue_pc_port="8001",
    serial_number="HZQN1876AAK92900482",
    imsi="234300100000514",
    phone_number='+358485620000514',
    capabilities=["REAL_UE_NSA"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    airplane_mode_switcher_text="Airplane",
    airplane_mode_confirm_button_text="OK",
    secret_code="*#*#4636#*#*",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_android_ue_3 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.18",
    ue_pc_port="8001",
    serial_number="HZQN1876AAKA1500051",
    imsi="234300100000515",
    phone_number='+358485620000515',
    capabilities=["REAL_UE_SA"],
    data_transfer=[_iperf_ue],
    network_mode_switch_method="ADB",
    airplane_mode_switcher_text="Airplane",
    airplane_mode_confirm_button_text="OK",
    secret_code="*#*#4636#*#*",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50807, instance_id=50807)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.206",
        vlan_id=487,
        routing=RoutingInformation(gateway="10.44.225.129", ip_prefix_length=26),
    ),
    global_bts_id=40807,
    oam_ip=NetworkAddress(v4="10.44.225.142"),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.125", username="ute", password="ute"
    ),
    connections=[_cbts]
)

_realcore = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    connections=[_cbts]
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.158.11", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_lte]
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _realcore, _lte_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB",
    attenuators=[_attenuator24, _attenuator12],
    core=_real_core,
    ues=[_android_ue_3, _android_ue_2, _android_ue_1],
    enbs=[_lte],
    pdus=[_pdu_smod],
)

tl.max_atten_value = 90
tl.qxdm_username = "krystian.wojakiewicz@nokia.com"
tl.qxdm_password = "Password1"

_cells_atten = {"0_13/14": [307, 310, 316], "0_15/16": [308, 311, 317], "0_17/18": [306, 309, 315],
                "1_1/2": [301, 303, 314], "1_3/4": [300, 304, 312], "1_5/6": [302, 305, 313]}

tl.cells_atten = _cells_atten

__all__ = ["tl"]
