__maintainer__ = "Krystian Wojakiewicz"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "krystian.wojakiewicz@nokia.com"
__owner_email__ = "krystian.wojakiewicz@nokia.com"

from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb
from taf.config.testline.ue import Android
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
from taf.config.testline.pdu import ATEN, Gude
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_pdu_su = Gude(
    addr="10.44.177.224",
    port_numbers=[2],
    model="EPC",
    version="8221-1",
)

#A6:BL2106G10JG, B2:BL2106G10I2
_pdu_ru1_2 = Gude(
    addr="10.44.206.130",
    port_numbers=[6, 8],
    model="EPC",
    version="8220-1",
)

#A1:BL2016G1AO2
_pdu_ru3 = Gude(
    addr="10.44.206.170",
    port_numbers=[1],
    model="EPC",
    version="8221-1",
)

#B1:EA174510889
_pdu_ru_lte = Gude(
    addr="10.44.177.224",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
)

_pdu_att = Gude(
    addr="10.44.177.53",
    port_numbers=[7],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_su, _pdu_ru1_2, _pdu_ru3, _pdu_ru_lte, _pdu_att]

_RUE_attenuator = JFW(
    ip_addr="10.42.54.74", port=3001, attenuation_port_numbers=[9, 10, 17, 18, 11, 12]
)  # Attenuator ports

_RUE_attenuator.pdu_port = _pdu_att.pdu_ports[7]

_abil_master = CapacityUnit(addr="fsp-1a")
_abil_slave = CapacityUnit(addr="fsp-1b")
_abil_loner = CapacityUnit(addr="fsp-1c")
# _abil_master = CapacityUnit(addr="192.168.253.20")
# _abil_slave = CapacityUnit(addr="192.168.253.21")
# _abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_su.pdu_ports[2],
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
    x2c=NetworkAddress(v4="10.44.65.172", v6="2a00:8a00:6000:607c::5b64", vlan_id=460),
    x2u=NetworkAddress(v4="10.44.65.236", v6="2a00:8a00:6000:607c::5c44", vlan_id=461),
    s1u=NetworkAddress(v4="10.44.66.44", v6="2a00:8a00:6000:607c::5d44", vlan_id=462),
)

_netact = Netact(
    addr="10.68.122.16",
    nom=NOM(
        ssh_connections_info=SshServiceDetails(
            addr="10.68.122.16", username="root", password="arthur"
        ),
        https_user_mgmt_info=HttpConnectionDetails(
            addr="10.68.122.16", username="omc", password="Nokia_150"
        ),
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.76.40",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.76.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.26",
    vlan_id=458,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1_2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[0:2],
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1_2.pdu_ports[8],
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[2:4],
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru3.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHLOA",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[4:6],
)

_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2, _ru_3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=51989, global_bts_id=51989)

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
        v4="10.44.80.219",
        v6="2a00:8a00:6000:607c::5640",
        vlan_id=455,
        routing=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    global_bts_id=40055,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.73", username="ute", password="ute"
    ),
    connections=[_cbts]
)

_realcore = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    connections=[_cbts]
)

_realcore_appsrv_ipv4 = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="10.44.184.246",
    user="syslab",
    password="Pass4System!"
)

_realcore_appsrv_ipv6 = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:fe06",
    user="syslab",
    password="Pass4System!"
)

_nuc_ue_pc_ssh = SshServiceDetails("10.42.22.208", "wro5grrm", password="5gpass!1")

_iperf_ue_ipv4 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_ipv4,
    binary_path='/data/data/com.nokia.android.application/',
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
    interface_name='fast'
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.208",
    serial_number="HZQN1876FAL33100502",
    imsi="234300100000137",
    phone_number='+358485620000137',
    capabilities=["SA_VONR", "REAL_UE_SA"],
    data_transfer=[_iperf_ue_ipv4],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    #service_call_attach='11',
    #service_call_detach='11'
)

_android_ue_2 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.22.208",
    serial_number="R5CT62PZ25K",
    imsi="310260560003293",
    phone_number='+358485600003293',
    capabilities=["R5CT62PZ25K"],
    data_transfer=[_iperf_ue_ipv6],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach='16',
    service_call_detach='16'
)


tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_VIAVI_ASIKL_ABILB1_3xAHCA",
    gnbs=[_cbts],
    core=_epc_core,
    enbs=[_lte],
    pdus=_pdus,
    ues=[_android_ue_1, _android_ue_2],
    attenuator=_RUE_attenuator,
    test_pcs=[_test_pc, _realcore_appsrv_ipv4, _realcore_appsrv_ipv6],
    nms=_netact,
)

tl.max_atten_value = 70
tl.tl_type = "sa"
tl.smod_slave = False

__all__ = ["tl"]
