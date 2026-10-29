__maintainer__ = "Bartosz Kozlowski"
__team__ = "MN RAN RD VRF WRO2 6"
__email__ = "bartosz.1.kozlowski@nokia.com"
__owner_email__ = "marta.irasiak-gaciarek@nokia.com"

import os
from taf.config.testline import DU, RU, NetworkAddress, RoutingInformation, RealEnb, Connection
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
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.attenuator import JFW
from taf.config.testline.nms import Netact, NOM
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_pdu_atten = Gude(
    addr="10.44.177.53",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)  # Attenuator ##port 6

_attenuator = JFW(
    ip_addr="10.42.54.218", port=3001, attenuation_port_numbers=[1, 3, 5, 7], pdu_port=_pdu_atten.pdu_ports[6]
)  # # Attenuator ports

_pdu1 = Gude(
    addr="10.42.208.152",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
)  # PDU FRGT, ASIB (NR) & ASIA (LTE)  ##port 5, 12

_pdu_rus = Gude(
    addr="10.44.206.187",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC",
    version="8221-1",
) # AHPF, AHPF ## port 9, 10

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="S", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AHPF",
    pdu_port=_pdu_rus.pdu_ports[9]
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AHPF",
    pdu_port=_pdu_rus.pdu_ports[10]
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="FRGT",
    pdu_port=_pdu1.pdu_ports[5]
)

# _abil_master = CapacityUnit(addr="192.168.253.20")
# _abil_slave = CapacityUnit(addr="192.168.253.21")
# _abil_loner = CapacityUnit(addr="192.168.253.22")

_abio_master = CapacityUnit(addr="fsp-1a", hardware_type="ABIO")
_abio_slave = CapacityUnit(addr="fsp-1b", hardware_type="ABIO")
_abio_loner = CapacityUnit(addr="fsp-1c", hardware_type="ABIO")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIB",
    hardware_version="473764A.102",
    serial_number="L1212713709",
    capacity_units=[_abio_master, _abio_slave, _abio_loner],
    pdu_port=_pdu1.pdu_ports[12],
    rus=[_ru_1, _ru_2]
)

_airscale = Airscale([_common_unit])

_du = DU(airscale=_airscale, rus=[_ru_1, _ru_2])

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
        v4="10.44.85.158", v6="2a00:8a00:6000:607c::1:6154", vlan_id=821
    ),
    x2u=NetworkAddress(
        v4="10.44.76.176", v6="2a00:8a00:6000:607c::1:6232", vlan_id=822
    ),
    s1u=NetworkAddress(
        v4="10.44.76.241", v6="2a00:8a00:6000:607c::1:6332", vlan_id=823
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.85.103",
    vlan_id=820,
    routing=RoutingInformation(gateway="10.44.85.65", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.77.47",
    vlan_id=824,
    routing=RoutingInformation(gateway="10.44.77.1", ip_prefix_length=26),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=51990, global_bts_id=51990)

_core = RealCore5G(mcc=540, mnc=1)

_ue_pc_ssh = SshServiceDetails("10.42.22.105", "wro5grrm", password="5gpass!1")

_abia = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A.103",
    product_code="473096A.103",
    serial_number="EA184674565",
    rus=[_ru_3]
)

_smod_lte = CommonUnit(
    hardware_type="ASIA",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_smod_lte]),
    rms=[_ru_3],
    x2_link_addr=NetworkAddress(
        v4="10.44.85.159",
        vlan_id=820,
    ),
    global_bts_id=40076,
    instance_id=40076,
)

_lte.m = NetworkAddress(v4="10.44.85.104")

_realcore_appsrv = TafUeAppServer(
    app_server_name="realcore",
    address="10.44.184.246",
    bind_interface_ip="10.44.184.246",
    user="syslab",
    password="Pass4System!"
)

_iperf_ue_sa = TafUeDataTransferProtocol(
    protocol_name='iperf',
    app_server=_realcore_appsrv,
    binary_path='/data/data/com.nokia.android.application/',
    interval=1,
    server_close_delay=50
)

_hmd_ue = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    ue_pc_address="10.42.22.105",
    ue_pc_port="8001",
    serial_number="HZQN1876AAK60100489",
    imsi="540017000000045",
    capabilities=["REAL_UE_NSA", "REAL_UE"],
    data_transfer=[_iperf_ue_sa],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
)

_qcm_ue = TafUeAndroid(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="e4c47fd8",
    ue_pc_port="8001",
    ue_pc_address="10.42.22.105",
    imsi="540018000002049",
    phone_number="+358485610002049",
    capabilities=["BENCHMARK_UE", "REAL_UE"],
    data_transfer=[_iperf_ue_sa],
    voice_call_technology_timeout=60.0,
    voice_call_dialing_timeout=-1.0
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

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.66", username="ute", password="ute"
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

tl = TestLine(
    gnbs=[_cbts],
    # enbs=[_lte],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB",
    # core=_epc_core,
    ues=[_hmd_ue, _qcm_ue],
    pdus=[_pdu_atten, _pdu1, _pdu_rus],
    attenuator=_attenuator,
    test_pc=_test_pc,
    test_pcs=[_test_pc],
    nms=_netact,
)

tl.max_atten_value = 80
tl.tl_type = "sa"

__all__ = ["tl"]
