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
from taf.config.testline import DU, RU, NetworkAddress, RealEnb, RoutingInformation, Connection
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.attenuator import JFW
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_attenuator24 = JFW(
    ip_addr="10.42.221.139", port=3001, attenuation_port_numbers=range(1, 25)
)
_attenuator12 = JFW(
    ip_addr="10.42.54.10", port=3001, attenuation_port_numbers=range(1, 13)
)

_pdu_smod = Gude(
    addr="10.44.205.189", port_numbers=[5, 6], model="EPC", version="8221-1"
)

_pdu_ru1 = Gude(
    addr="10.44.177.38", port_numbers=[3, 6, 9], model="EPC", version="8221-1"
)

_pdu_ru2 = Gude(
    addr="10.44.177.30", port_numbers=[10, 11, 12], model="EPC", version="8221-1"
)

_pdu_ru3 = Gude(
    addr="10.44.177.28", port_numbers=[1, 2, 3], model="EPC", version="8221-1"
)

_pdu_ru4 = Gude(
    addr="10.44.177.40", port_numbers=[6, 11, 12], model="EPC", version="8221-1"
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS205305077"
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.133", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS205301563"
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1_4T4R",
    radio_type="AHPMDB",
    serial_number="AS205305075"
)

_ru4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.134", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARHA",
    serial_number="1M205131716"
)

_ru5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.135", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARHA",
    serial_number="1M205014990"
)

_ru6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.136", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1_1_6T6R",
    radio_type="ARHA",
    serial_number="1M205131732"
)

_ru7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.136", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGG",
    serial_number="RW233201466"
)

_ru8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.135", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGG",
    serial_number="RW233201435"
)

_ru9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.134", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHEGG",
    serial_number="RW233201437"
)

_ru10 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.6", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZQJ",
    serial_number="1M204964013"
)

_ru11 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.10", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZQJ",
    serial_number="1M205101948"
)

_ru12 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.18", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMTDr5.1a_1_8T8R",
    radio_type="AZQJ",
    serial_number="1M205101951"
)

_fsp1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172901140",
    rus=[_ru7, _ru8, _ru9],
)

_fsp2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIA",
    hardware_version="473096A.103",
    serial_number="L1172902551",
    rus=[],
)

_fsp3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211200988",
    rus=[_ru1, _ru2, _ru3, _ru4, _ru5, _ru6],
)

_fsp5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1204104968",
    rus=[_ru1, _ru2, _ru3, _ru7, _ru8, _ru9],
)

_fsp6 = CapacityUnit(
    addr="192.168.253.40",
    hardware_type="ABIO",
    hardware_version="475266A.103",
    serial_number="L1211201063",
    rus=[_ru10, _ru11, _ru12],
)

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2="10.27.194.14")

_secondary_smod = CommonUnit(
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="DH200762639",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp5, _fsp6],
    pdu_port=_pdu_smod.pdu_ports[6],
)

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
    v4="10.44.224.15",
    vlan_id="N/A",
    routing=RoutingInformation(gateway="10.44.224.1", ip_prefix_length=26),
)

_du = DU(Airscale([_secondary_smod]))

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=40810, instance_id=50810)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=234, mnc=30)

_master_smod = CommonUnit(
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1201106392",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp1, _fsp2, _fsp3],
    pdu_port=_pdu_smod.pdu_ports[5]
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_master_smod]),
    x2_link_addr=NetworkAddress(
        v4="10.44.225.143",
        vlan_id=487,
        routing=RoutingInformation(gateway="10.44.225.129", ip_prefix_length=26),
    ),
    global_bts_id=40810,
    instance_id=40810,
    oam_ip=NetworkAddress(v4="10.44.225.143"),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.226.157", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_lte.system_module.common_units[0]
        ),
    ]
)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.18", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.45.168.53",
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

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ANDROID_ASIB_ABIO_3xAHLOA_ENB",
    attenuators=[_attenuator24, _attenuator12],
    core=_real_core,
    ues=[_android_ue_1, _android_ue_2, _android_ue_3],
    enbs=[_lte],
    pdus=[_pdu_smod],
)

tl.max_atten_value = 90
tl.qxdm_username = "krystian.wojakiewicz@nokia.com"
tl.qxdm_password = "Password1"

_cells_atten = {"0_7/8": [151, 157], "0_9/10": [152, 158], "0_11/12": [150, 156],
                "0_19/20": [155, 106, 109, 115], "0_21/22": [154, 108, 111, 117],
                "0_23/24": [153, 107, 110, 116], "1_7/8": [159, 100, 103, 112], "1_9/10": [160, 102, 104, 113],
                "1_11/12": [161, 101, 105, 114]}

tl.cells_atten = _cells_atten

__all__ = ["tl"]
