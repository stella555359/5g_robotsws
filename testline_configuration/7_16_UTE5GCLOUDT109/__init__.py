__maintainer__ = "Bartosz Kozlowski"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "bartosz.1.kozlowski@nokia.com"

import os
from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    )
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import EPCSim, RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


test_line_config_dir = os.path.dirname(os.path.abspath(__file__))




_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_attenuator = JFW(ip_addr="10.42.54.74", port=3001, attenuation_port_numbers=[13, 14, 15, 16, 21, 22, 23, 24], pdu_port=_pdu_atten.pdu_ports[7]
)


_pdu1 = Gude(
    addr="10.42.208.152",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru1 = Gude(
    addr="10.44.206.130",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)  # PDU AHLOA OWB  ##port 3

_pdu_ru2 = Gude(
    addr="10.44.206.131",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8220-1",
)  # PDU AHLOA 366  ##port 11

_pdu_ru3 = ATEN(
    addr="10.44.177.90", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8]
)  # PDU AHLOA  367 ##port 6

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="N/A", username="root", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(addr="N/A", username="N/A"),
    pdu_port=_pdu_ru1.pdu_ports[3],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9191227366",
    radio_type="AHLOA",
    attenuation_ports=_attenuator.attenuator_ports,
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="N/A", username="root", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(addr="N/A", username="N/A"),
    pdu_port=_pdu_ru2.pdu_ports[11],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="K9191227367",
    radio_type="AHLOA",
    attenuation_ports=_attenuator.attenuator_ports,
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="N/A", username="root", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(addr="N/A", username="N/A"),
    pdu_port=_pdu_ru3.pdu_ports[6],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL1934G10WB",
    radio_type="AHLOA",
    attenuation_ports=_attenuator.attenuator_ports,
)


_abil_master = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")
_abil_slave = CapacityUnit(addr="192.168.253.21", hardware_type="ABIL")
_abil_loner = CapacityUnit(addr="192.168.253.22", hardware_type="ABIL")

# _abil_master = CapacityUnit(addr="fsp-1a")
# _abil_slave = CapacityUnit(addr="fsp-1b")
# _abil_loner = CapacityUnit(addr="fsp-1c")

_smod_nr = CommonUnit(
    hardware_type="ASIK",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu1.pdu_ports[9],
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    hardware_version="474021A.101",
    serial_number="L1182514155"
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129"),
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
        v4="10.44.76.84",
        v6="2a00:8a00:6000:607c::1:6114",
        vlan_id=821
    ),
    x2u=NetworkAddress(
        v4="10.44.76.147",
        v6="2a00:8a00:6000:607c::1:6213",
        vlan_id=822
    ),
    s1u=NetworkAddress(
        v4="10.44.76.211",
        v6="2a00:8a00:6000:607c::1:6313",
        vlan_id=823
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.76.20",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.19",
    vlan_id=824,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)
_du = DU(airscale=Airscale([_smod_nr]), rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=50096, global_bts_id=50096)

_epc_core = EPCSim(
    mme_ip="10.1.1.101",
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="127.0.0.1", username="ute", password="ute"
    ),
    mcc=540,
    mnc=10,
    dir_path="/home/ute/epcsim",
    cfg_filename="simple_new.cfg",
    edaemon_port=10111,
    egate_port=20111,
)

_core = RealCore5G(mcc=540, mnc=1)

_fsp_5 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    product_code="473096A.103",
    serial_number="L1181620087"
)

_smod_lte = CommonUnit(
    hardware_type="ASIA",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_fsp_5],
    pdu_port=_pdu1.pdu_ports[1],
    hardware_version="473095A.203",
    serial_number="L1172903289"
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_smod_lte]),
    x2_link_addr=NetworkAddress(
        v4="10.44.76.85",
        vlan_id=820,
    ),
    global_bts_id=40096,
    instance_id=40096,
)

_lte.m = NetworkAddress(v4="10.44.76.21")

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.79", username="ute", password="ute"
    ),
    connections=[_cbts]
)

_ue_pc_ssh = SshServiceDetails("10.42.22.199", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="10.44.184.246",
    user="syslab",
    password="Pass4System!"
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.199",
    ue_pc_port="8001",
    serial_number="HZQN1876FAL33100052",
    imsi="540017000000035",
    capabilities=["REAL_UE_NSA"],
    data_transfer=[_iperf_ue],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_android_ue_2 = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.199",
    ue_pc_port="8001",
    serial_number="HZQN1876BAK92700772",
    imsi="540017000000054",
    capabilities=["REAL_UE_SA"],
    data_transfer=[_iperf_ue],
    voice_call_technology_timeout = 60.0,
    voice_call_dialing_timeout = -1.0
)

_netact = Netact(
    addr="10.63.2.98",
    nom=NOM(
        ssh_connections_info=SshServiceDetails(
            addr="10.63.2.98", username="root", password="arthur"
        ),
        https_main_info=HttpConnectionDetails(
            addr="10.63.2.98", username="omc", password="Nokia_150"
        ),
    ),
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_4xANDROID_ASIK_ABIL_3xAHLOA_ENB",
    gnbs=[_cbts],
    enbs=[_lte],
    core=_epc_core,
    ues=[_android_ue_1, _android_ue_2],
    attenuator=_attenuator,
    pdus=[_pdu1, _pdu_ru1, _pdu_ru2, _pdu_ru3],
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    nms=_netact,
)

tl.lte_mplane = _lte.m
tl.max_atten_value = 80
tl.tl_type = "sa"
tl.smod_slave = True

__all__ = ["tl"]
