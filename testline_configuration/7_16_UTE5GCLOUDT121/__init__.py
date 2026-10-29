__maintainer__ = "Krystian Wojakiewicz"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "krystian.wojakiewicz@nokia.com"
__owner_email__ = "krystian.wojakiewicz@nokia.com"

import os
from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline import RealEnb
from taf.config.testline.attenuator import JFW
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


_pdu_su = Gude(
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
)
_pdu_ru2 = Gude(
    addr="10.44.206.187",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)


_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_su.pdu_ports[11],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=834),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
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

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru1.pdu_ports[1],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[4],
    ru_hw_group="",
    radio_type="AHCA",
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru2.pdu_ports[5],
    ru_hw_group="",
    radio_type="AHCA",
)


# AHCA   AS195101611		A1 10.44.206.130 'AA'
# AHCA   AS195101637		A4 10.44.206.187 'CC'
# AHCA   AS195101640		A5 10.44.206.187 'CC'
# ASIK   L1182514156		ZLE (-5-	https://10.42.208.151/)

_du = DU(airscale=_airscale, rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50078, instance_id=50078)

_core = RealCore5G(mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    lmp_connection=_common_unit_lte_ssh, capacity_units=[_abil_loner]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
    pdu_port=_pdu_su.pdu_ports[2],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.80.77",
        v6="2a00:8a00:6000:607c::5b3e",
        vlan_id=460,
        routing=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    global_bts_id=40095,
    oam_ip=NetworkAddress(v4="10.44.85.95"),
)

_lte.m = NetworkAddress(
    v4="10.44.80.17",
    v6="2a00:8a00:6000:607c::5a42",
    vlan_id=459,
    routing=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
)

_nuc_ssh = SshServiceDetails("10.42.22.196", "wro5grrm", password="5gpass!1")

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170"
)

_iperf_ue = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
)

_hmd = TafUeAndroid(
    ssh_connection_details=_nuc_ssh,
    ue_pc_address="10.42.22.196",
    ue_pc_port="8001",
    serial_number="HZQN1876BAK92100806",
    imsi="540017000000037",
    capabilities=["REAL_UE"],
    data_transfer=[_iperf_ue],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yml"
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.120", username="ute", password="ute"
    ),
    connections=[_cbts]
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.65", username="ute", password="Ut3pa5s#1be1"
    ),
    connections=[_lte]
)

_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.184.246", username="syslab", password="Pass4System!"
    ),
    connections=[_cbts]
)

_attenuator = JFW(
    ip_addr="10.42.54.218",
    port=3001,
    attenuation_port_numbers=[
        17,  # cell 2 achca 640 ant 1
        18,  # cell 2 achca 640 ant 2
        19,  # cell 1 achca 611 ant 1
        20,  # cell 1 achca 611 ant 2
        21,  # cell 3 achca 637 ant 1
        22,  # cell 3 achca 637 ant 2
        23,  # cell 3 achca 637 ant 3
        24,  # cell 3 achca 637 ant 4
    ],
)

_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_attenuator.pdu_port = _pdu_atten.pdu_ports[6]

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_NSA_HMD_ASIKL_ABILB1_3xAHCA_ENB",
    gnbs=[_cbts],
    enbs=[_lte],
    core=_core,
    pdus=[_pdu_su, _pdu_ru1, _pdu_ru2],
    ues=[_hmd],
    attenuator=_attenuator,
    test_pc=_test_pc,
    test_pcs=[_test_pc, _lte_test_pc, _realcore_appsrv],
)

__all__ = ["tl"]
