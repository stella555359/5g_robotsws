__maintainer__ = "Filip Jozefczak"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "filip.jozefczak@nokia.com"
__owner_email__ = "filip.jozefczak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer


DEFAULT_PASSWD = "oZPS0POrRieRtu"

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_attenuator = JFW(
    ip_addr="10.42.54.74", port=3001, attenuation_port_numbers=[3, 4, 19, 20], pdu_port = _pdu_atten.pdu_ports[7]
)

_pdu_su_1 = Gude(
    addr="10.42.61.242",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_su_2 = Gude(
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
)

_pdu_ru2 = Gude(
    addr="10.44.206.143",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_su_1, _pdu_su_2, _pdu_ru1, _pdu_ru2]

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="N/A", username="root", password=DEFAULT_PASSWD
    ),
    lmp_connection=SshServiceDetails(addr="N/A", username="N/A"),
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2106G10JC",
    radio_type="AHLOA",
    pdu_port=_pdu_ru1.pdu_ports[2]
)

_ru2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="N/A", username="root", password=DEFAULT_PASSWD
    ),
    lmp_connection=SshServiceDetails(addr="N/A", username="N/A"),
    pdu_port=None,
    ru_hw_group="FRMTDr5.1_1_4T4R",
    serial_number="RW200200748",
    radio_type="AZHA"
)

_ru3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="N/A", username="root", password=DEFAULT_PASSWD
    ),
    lmp_connection=SshServiceDetails(addr="N/A", username="N/A"),
    pdu_port=_pdu_ru2.pdu_ports[12],
    ru_hw_group="FRMr5.1a_4T4R",
    serial_number="BL2106G10JE",
    radio_type="AHLOA"
)

# AHLOA  BL2106G10JC		A2 10.44.206.130 'AA'
# AHLOA  BL2106G10JE		B6 10.44.206.143 'IoDT'
# ASIK   L1182514145        A6 10.44.177.224

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password=DEFAULT_PASSWD
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu_su_2.pdu_ports[6]
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=834),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password=DEFAULT_PASSWD
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.80.68",
        v6="2a00:8a00:6000:607c::5b3b",
        vlan_id=460
    ),
    x2u=NetworkAddress(
        v4="10.44.65.205",
        v6="2a00:8a00:6000:607c::5c06",
        vlan_id=461
    ),
    s1u=NetworkAddress(
        v4="10.44.66.8",
        v6="2a00:8a00:6000:607c::5d06",
        vlan_id=462
    )
)

_cu.m = NetworkAddress(
    v4="10.44.80.4",
    v6="2a00:8a00:6000:607c::5a3b",
    vlan_id=459
)

_cu.sync = NetworkAddress(
    v4="10.44.66.78",
    v6="2a00:8a00:6000:607c::5e06",
    vlan_id=463
)

_du = DU(_airscale, rus=[_ru1, _ru2, _ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=51997, global_bts_id=51997)

_core = RealCore5G(mcc=555, mnc=10)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password=DEFAULT_PASSWD
)

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_abil_loner], pdu_port=_pdu_su_1.pdu_ports[4]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129",
        username="toor4nsn",
        password=DEFAULT_PASSWD
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.80.69",
        v6="2a00:8a00:6000:607c::5b3c",
        vlan_id=460
    ),
    global_bts_id=40097,
)

_lte.m = NetworkAddress(
    v4="10.44.80.5",
    v6="2a00:8a00:6000:607c::5a3c",
    vlan_id=459)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.43",
        username="ute",
        password="uteUTE!"
    ),
    connections=[_cbts]
)

_realcore_appserver = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.184.246",
        username="syslab",
        password="Pass4System!"
    ),
    connections=[_cbts]
)

_netact = Netact(
    addr="10.63.2.98",
    nom=NOM(
        ssh_connections_info=SshServiceDetails(
            addr="10.63.2.98",
            username="root",
            password="arthur"
        ),
        https_main_info=HttpConnectionDetails(
            addr="10.63.2.98",
            username="omc",
            password="Nokia_150"
        ),
    ),
)

# MNC should be 01, but sanity doesn't allow that
_epc_core = EPCSim(
    mme_ip="10.1.1.101",
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="127.0.0.1",
        username="ute",
        password="uteUTE!"
    ),
    mcc=540,
    mnc=11,
    dir_path="/home/ute/epcsim",
    cfg_filename="simple_20ue.cfg",
    edaemon_port=10111,
    egate_port=20111,
)

_nuc_ue_pc_ssh = SshServiceDetails("10.44.72.180", "wro5grrm", password="5gpass!1")

_realcore_appsrv_v4 = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="10.42.197.171",
    user="syslab",
    password="Pass4System!"
)

_iperf_ue_v4 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_v4,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
)

_realcore_appsrv_v6 = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="2a00:8a00:6000:607c:ffff:ffff:ffff:fe06",
    user="syslab",
    password="Pass4System!"
)

_iperf_ue_v6 = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv_v6,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50,
    interface_name='fast.t-mobile.com/rmnet_data0'
)

_android_ue_nokia = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.44.72.180",
    ue_pc_port="8001",
    serial_number="HZQN1876BAK92700694",
    imsi="540017000000080",
    phone_number='+35848560002721',
    capabilities=["SA_NOKIA"],
    data_transfer=[_iperf_ue_v4],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_android_ue_samsung = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    serial_number="R5CT62PY1KT",
    ue_pc_address="10.44.72.180",
    ue_pc_port="8001",
    imsi="310260560002718",
    phone_number="+35848560002718",
    capabilities=["SA_SAMSUNG", "REAL_UE_SA", "REAL_UE_SA_PING"],
    data_transfer=[_iperf_ue_v6],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0,
    service_call_attach=16,
    service_call_detach=16,
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_VIAVI_ASIKL_ABILB1_2xAHCA_AHFIB",
    gnbs=[_cbts],
    enbs=[_lte],
    core=_epc_core,
    ues=[_android_ue_samsung, _android_ue_nokia],
    attenuator=_attenuator,
    pdus=_pdus,
    nms=_netact,
    test_pc=_test_pc,
    test_pcs=[_test_pc, _realcore_appserver]
)

tl.tdd_ports = ["19", "20"]
tl.fdd_ports = ["3", "4"]

tl.smod_slave = True

__all__ = ["tl"]
