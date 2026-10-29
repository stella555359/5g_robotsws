__maintainer__ = "Marta Irasiak"
__team__ = "PZ_2_WRO_6_SG"
__email__ = "marta.irasiak@nokia.com"
__owner_email__ = "marta.irasiak@nokia.com"

import os
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
from taf.config.testline.appserver import AppServer
from taf.config.testline.core import RealCore, RealCore5GDetails, AMF
from taf.config.testline.pdu import Gude, ATEN, APC
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid


def get_dir_path():
    cfg_dir = os.path.dirname(os.path.abspath(__file__))
    return cfg_dir


_pdu_su = Gude(
    addr="10.44.177.157",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdu_ru = Gude(
    addr="10.44.177.79",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu_su, _pdu_ru]

_RUE_attenuator = JFW(
    ip_addr="10.42.221.212",
    port=3001,
    attenuation_port_numbers=range(1, 25),
)  # Attenuator ports

# pdu tumika
# _pdu_atten = Gude(
#     addr="",
#     port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
#     model="EPC",
#     version="8221-1",
# )

# _RUE_attenuator.pdu_port = _pdu_atten.pdu_ports[_]

test_line_config_dir = get_dir_path()

_abip_master = CapacityUnit(addr="fsp-1a")
_abip_slave = CapacityUnit(addr="fsp-1b")
_abip_loner = CapacityUnit(addr="fsp-1c")

_abio_master = CapacityUnit(addr="fsp-2a")
_abio_slave = CapacityUnit(addr="fsp-2b")
_abio_loner = CapacityUnit(addr="fsp-2c")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_master, _abip_slave, _abip_loner, _abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu_su.pdu_ports[7],
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
    x2c=NetworkAddress(v4="10.42.41.73", vlan_id=541),
    x2u=NetworkAddress(v4="10.42.41.137", vlan_id=542),
    s1u=NetworkAddress(v4="10.42.41.201", vlan_id=543),
)

# _netact = Netact(
#     addr="_",
#     nom=NOM(
#         ssh_connections_info=SshServiceDetails(
#             addr="_", username="root", password="_"
#         ),
#         https_main_info=HttpConnectionDetails(
#             addr="_", username="omc", password="_"
#         ),
#     ),
# )

_cu.m = NetworkAddress(
    v4="10.42.41.9",
    vlan_id=540,
    routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.42.65.137",
    vlan_id=544,
    routing=RoutingInformation(gateway="10.42.65.129", ip_prefix_length=26),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.2", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_su.pdu_ports[9],
    ru_hw_group="",
    radio_type="AWHQX",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[16:20],
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.6", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_su.pdu_ports[10],
    ru_hw_group="",
    radio_type="AWHQX",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[20:24],
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.0.10", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_su.pdu_ports[11],
    ru_hw_group="",
    radio_type="AWHQX",
    attenuation_ports=list(_RUE_attenuator.attenuator_ports.keys())[0:4],
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu_ru.pdu_ports[6],
    ru_hw_group="",
    radio_type="AHEGB",
)

# AWHQX http://
# AWHQX http://
# AWHQX http://

_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2, _ru_3, _ru_4])

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=40877, global_bts_id=40877)

_epc_core = EPCSim(
    mme_ip="10.44.201.68",
    tac=7151,
    default_ssh_connection_details=SshServiceDetails(
        addr="127.0.0.1", username="ute", password="ute"
    ),
    mcc=555,
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
    v4="10.27.28.136", vlan_id=None
)

_amf = AMF(oam_ssh_connection_details=_amf_ssh, n2=_amf_n2_addr)

_real_core = RealCore(five_g=RealCore5GDetails(amf=_amf), mcc=555, mnc=10)

_core = RealCore5G(mcc=555, mnc=10)

_abip = CapacityUnit(addr="192.168.253.20")

_asil = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asil]),
    x2_link_addr=NetworkAddress(
        v4="10.42.41.73",
        vlan_id=541,
        routing=RoutingInformation(gateway="10.42.41.1", ip_prefix_length=26),
    ),
    global_bts_id=40877,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.66", username="ute", password="ute"
    ),
    connections=[_cbts]
)

_realcore = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    connections=[_cbts]
)

##
# The correct realcore configuration
_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    connections=[_lte]
)
###

_nuc_ue_pc_ssh = SshServiceDetails("10.42.224.75", "wro5grrm", password="5gpass!1")

_iperf_ue_nsa = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/data/data/com.nokia.android.application/",
)

_iperf_ue_sa = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="2a00:8a00:6000:607c:ffff:ffff:ffff:effb",
    iperf_path="/data/data/com.nokia.android.application/",
)

_android_ue_1 = TafUeAndroid(
    ssh_connection_details=_nuc_ue_pc_ssh,
    ue_pc_address="10.42.224.75",
    serial_number="UE2",
    imsi="555109900000556",
    phone_number='+555109900000556',
    capabilities=["SA_VONR"],
    data_transfer=[_iperf_ue_sa],
    network_mode_switch_method="ADB",
    airplane_mode_switcher_text="Airplane",
    airplane_mode_confirm_button_text="OK",
    secret_code="*#*#4636#*#*",
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

# _android_ue_2 = Android(
#     ssh_connection_details=_nuc_ue_pc_ssh,
#     serial_number="HZQN1876FAL33100350",
#     capabilities=["SA_VONR"],
#     server_dir="/cygdrive/c/pyro_server",
#     python_path="C:/Python27/python.exe",
#     qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
#     diag_cfg_path="C:/pyro_server/DIAG.cfg",
#     imsi="310260560002719",
#     iperf_details=_iperf_ue_sa,
#     iperf_directory="/data/data/com.nokia.android.application/",
#     clear_logs=True,
#     clear_server_files=True,
# )

tl = TestLine(
    # tl_cloud_topology="CLOUD_5G_CLASSICAL_SA_ANDROID_ASIL_ABIP_ABIO_3xAWHQX_1xAHEGB_ENB",
    gnbs=[_cbts],
    core=_epc_core,
    enbs=[_lte],
    ues=[_android_ue_1],
    attenuator=_RUE_attenuator,
    test_pc=_test_pc,
    test_pcs=[_test_pc, _realcore_appsrv],
    # nms=_netact,
)

# _cells_atten = {"0_port1/port2": [id cellki]}

# tl.cells_atten = _cells_atten

__all__ = ["tl"]
