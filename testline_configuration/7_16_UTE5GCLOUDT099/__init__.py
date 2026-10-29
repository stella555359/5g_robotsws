__maintainer__ = "Bartosz Galczynski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.galczynski@nokia.com"
__owner_email__ = "bartosz.galczynski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation, Connection
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import JFW, AttenuationPort
from taf.config.testline.pdu import Gude
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_attenuator = JFW(
    ip_addr="10.42.54.74", port=3001, attenuation_port_numbers=[5, 6, 7, 8], pdu_port = _pdu_atten.pdu_ports[7]
)

_pdu1 = Gude(
    addr="10.42.61.242",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.177.224",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru1 = Gude(
    addr="10.44.206.131",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)

_pdu_ru2 = Gude(
    addr="10.44.206.187",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5_4T4R",
    radio_type="AHLOA",
    serial_number="K9183435481",
    pdu_port=_pdu_ru1.pdu_ports[10],
    attenuation_ports=[AttenuationPort(attenuator=_attenuator, port_no=5),
                       AttenuationPort(attenuator=_attenuator, port_no=6)]
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr5_4T4R",
    radio_type="AHLOA",
    serial_number="BL2106G10I1",
    pdu_port=_pdu_ru2.pdu_ports[6],
    attenuation_ports=[AttenuationPort(attenuator=_attenuator, port_no=7),
                       AttenuationPort(attenuator=_attenuator, port_no=8)]
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="AHFB",
    serial_number="EA183011444",
    pdu_port=_pdu2.pdu_ports[7]
)

_fsp_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIP",
    hardware_version="A.Y16",
    product_code="475792A.Y16",
    serial_number="L1224710342",
    rus=[_ru1, _ru2],
)

_fsp_5 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="L1173514566",
    rus=[_ru3, _ru1],
)

_smod_nr = CommonUnit(
    hardware_type="ASIL",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_1],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_version="474767A.101",
    serial_number="L1213707172"
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=834),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.80.76",
        v6="2a00:8a00:6000:607c::5b3d",
        vlan_id=460,
        routing=RoutingInformation(gateway="10.44.80.65", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.65.212",
        v6="2a00:8a00:6000:607c:5c0e",
        vlan_id=461,
        routing=RoutingInformation(gateway="10.44.65.193", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.66.20",
        v6="2a00:8a00:6000:607c::5d0e",
        vlan_id=462,
        routing=RoutingInformation(gateway="10.44.66.1", ip_prefix_length=26),
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.80.16",
    v6="2a00:8a00:6000:607c::5a41",
    vlan_id=459,
    routing=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.66.84",
    v6="2a00:8a00:6000:607c::5e0e",
    vlan_id=463,
    routing=RoutingInformation(gateway="10.44.66.65", ip_prefix_length=26),
)

_du = DU(airscale=Airscale([_smod_nr]))

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50095, instance_id=50095)

_core = RealCore5G(mcc=555, mnc=10)

_smod_lte = CommonUnit(
    hardware_type="ASIA",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5],
    pdu_port=_pdu2.pdu_ports[3],
    hardware_version="473095A.101",
    serial_number="L1163408048"
)

_lte = RealEnb(
    system_module=Airscale(common_units=[_smod_lte]),
    rms=[_ru1, _ru3],
    x2_link_addr=NetworkAddress(
        v4="10.44.80.77",
        v6="2a00:8a00:6000:607c::5b3e",
        vlan_id=460,
        routing=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    global_bts_id=40095,
    instance_id=40095,
    oam_ip=NetworkAddress(v4="10.44.80.17"),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.78", username="ute", password="ute"
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

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.60", username="ute", password="ute"
    ),
    connections=[
        NetworkAddress(v4="192.168.255.126"),
        Connection(
        interface="eth1",
        interface_type="lmp",
        device=_lte.system_module.common_units[0]
        )
    ]
)

_ue_pc_ssh = SshServiceDetails("10.42.22.5", "wro5grrm", password="5gpass!1")

_realcore_appsrv_sa = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    user="syslab",
    password="Pass4System!"
)

_iperf_ue_sa = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_sa,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50
)

_android_ue = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.5",
    serial_number="HZQN1876AAKA2000089",
    imsi="540017000000018",
    phone_number='+35848560002721',
    capabilities=["REAL_UE_SA"],
    data_transfer=[_iperf_ue_sa],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASILL_ABIPL_2xAHLOA_ENB_UTECA",
    gnbs=[_cbts],
    enbs=[_lte],
    core=_core,
    ues=[_android_ue],
    attenuator=_attenuator,
    pdus=[_pdu1],
    test_pc=_test_pc,
    test_pcs=[_test_pc, _lte_test_pc]
)

tl.smod_slave = False

__all__ = ["tl"]
