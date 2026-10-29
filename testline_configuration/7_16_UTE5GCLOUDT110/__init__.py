__maintainer__ = "Krystian Wojakiewicz"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "krystian.wojakiewicz@nokia.com"
__owner_email__ = "krystian.wojakiewicz@nokia.com"

import os
from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import EPCSim, RealCore5G
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import Gude, ATEN, APC
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid, TafUeMtk
from taf.config.testline.pdn import PDN, PDPTypes


def get_dir_path():
    cfg_dir = os.path.dirname(os.path.abspath(__file__))
    return cfg_dir


_pdu_su = Gude(
    addr="10.44.206.120",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru = Gude(
    addr="10.44.205.56",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

# APC is not supported.
# _pdu_ru2 = APC(
#     addr="10.44.206.94",
#     port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
#     model="APC",
# )

_pdus = [_pdu_su, _pdu_ru]


_RUE_attenuator = JFW(
    ip_addr="10.42.221.87",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
)  # Attenuator ports

_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_RUE_attenuator.pdu_port = _pdu_atten.pdu_ports[7]

test_line_config_dir = get_dir_path()

_abil_master = CapacityUnit(addr="fsp-1a")
_abil_slave = CapacityUnit(addr="fsp-1b")
_abil_loner = CapacityUnit(addr="fsp-1c")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_su.pdu_ports[4],
)

_airscale = Airscale([_common_unit])

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
    x2c=NetworkAddress(v4="10.44.76.81", vlan_id=821),
    x2u=NetworkAddress(v4="10.44.76.169", vlan_id=822),
    s1u=NetworkAddress(v4="10.44.76.234", vlan_id=823),
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

_cu.m = NetworkAddress(
    v4="10.44.76.17",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.16",
    vlan_id=824,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[2],
    ru_hw_group="",
    radio_type="AZHM",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[0:4],
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[3],
    ru_hw_group="",
    radio_type="AZHM",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[4:8],
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    # pdu_port=_pdu_ru2.pdu_ports[5],
    ru_hw_group="",
    radio_type="AZHM",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[8:12],
)

# AZHM http://10.44.206.94 [5] 1M222603349
# AZHM http://10.44.205.56/dashboard.html [2] 1M222706935
# AZHM http://10.44.205.56/dashboard.html [3] 1M222706900

_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2, _ru_3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=51031, global_bts_id=51031)

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

_amf_ssh = SshServiceDetails(
    addr="to_be_updated", username="to_be_updated", password="to_be_updated"
)

_amf_n2_addr = NetworkAddress(
    v4="10.94.232.6", v6="2a00:8a00:4000:65ef:ffff:ffff:ffff:b804", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_core = RealCore5G(mcc=555, mnc=10)


_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.85.144",
        vlan_id=821,
        routing=RoutingInformation(gateway="10.44.85.129", ip_prefix_length=26),
    ),
    global_bts_id=40024,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.217", username="ute", password="ute"
    ),
    connections=[_cbts]
)


##
# The correct realcore configuration
_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:fe06",
    user="syslab",
    password="Pass4System!"
)
###

_realcore_appsrv_mtk = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.61.65",
    # bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:effb",
    user="5g",
    password="2019H@slo"
)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.5", "wro5grrm", password="5gpass!1")


_iperf_ue_sa = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name="fast"
)

_iperf_ue_mtk = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_mtk,
    interval=1,
    server_close_delay=50,
    interface_name="fast"
    # interface_name="5gwro1"
)


_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.5",
    ue_pc_port="8001",
    serial_number="HZQN1876AAK92900311",
    imsi="3102600560002721",
    phone_number='+35848560002721',
    capabilities=["SA_VONR"],
    data_transfer=[_iperf_ue_sa],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)


_android_ue_2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number="HZQN1876AAK92900481",
    ue_pc_address="10.44.72.5",
    ue_pc_port="8001",
    imsi="310260560002719",
    phone_number='+35848560002719',
    capabilities=["SA_VONR"],
    data_transfer=[_iperf_ue_sa],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

# _pdns = [
#     PDN(pdp_type=PDPTypes.IP.value, apn="fast.t-mobile.com"),
# ]

_android_mtk_ue = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.5",
    ue_pc_port="8001",
    serial_number="0123456789ABCDEF",
    data_transfer=[_iperf_ue_mtk],
    imsi="310260560002722",
    phone_number='+35848560002722',
    capabilities=["MTK"],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_SA_3xANDROID_2xASIB_2xABIO_ABIA_3xAZHM_AZNA_AHEC_ENB",
    gnbs=[_cbts],
    core=_epc_core,
    enbs=[_lte],
    ues=[_android_ue_1, _android_ue_2, _android_mtk_ue], #_android_mtk_ue removed temporarly
    attenuator=_RUE_attenuator,
    test_pc=_test_pc,
    test_pcs=[_test_pc, _realcore_appsrv],
    nms=_netact,
)

__all__ = ["tl"]
