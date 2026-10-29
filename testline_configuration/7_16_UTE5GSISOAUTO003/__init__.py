__maintainer__ = "Manuela Markowska"
__team__ = "5G_PZ_1_WRO_4_SG"
__email__ = "manuela.markowska@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb, TafUeAppServer
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


__all__ = ["tl"]

_pdu_gnb = Gude(addr="10.44.177.144", port_numbers=[8], model="EPC", version="8221-1")
_pdu_enb = Gude(addr="10.44.177.144", port_numbers=[10], model="EPC", version="8221-1")
_pdu_gnb_ru1 = Gude(addr="10.44.177.147", port_numbers=[7, 8], model="EPC", version="8221-1")
_pdu_gnb_ru2 = Gude(addr="10.44.177.81", port_numbers=[8, 9, 10, 11], model="EPC", version="8221-1")


_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1", address="10.45.168.53", user="5g", password="2019H@slo",
    bind_interface_ip="10.45.168.53"
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_android = TafUeAndroid(
    serial_number="0123456789ABCDEF",
    ue_pc_address="10.42.22.198",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.198", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    is_rooted=True
)

_attenuator = TopYoung(
    ip_addr="10.42.221.208",
    port=3001,
    attenuation_port_numbers=range(1, 24),
    model="TAS24T24-0.2G6-90-1S-EJS",
    serial_number="30021030018",
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.251.12",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::fa08", vlan_id=38),
    x2u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::fa08", vlan_id=38),
    s1u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::fa08", vlan_id=38),
)

_ru_1 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL2030H22UB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.132",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[10],
)

_ru_2 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL2030H236N",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[7],
)

_ru_3 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAFB",
    serial_number="BL2030H22TZ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[11],
)

_ru_4 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2030I231E",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[9],
)

_ru_5 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2031I23TW",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    pdu_port=_pdu_gnb_ru2.pdu_ports[8],
)

_ru_6 = RU(
    ru_hw_group="cMAAr5.1_16T16R",
    radio_type="AAIB",
    serial_number="BL2049I26N1",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130",
        username="toor4nsn",
        password="oZPS0POrRieRtu",
    ),
    pdu_port=_pdu_gnb_ru1.pdu_ports[8],
)


_abio1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A101",
    serial_number="L1204008305",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)


_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIM",
    # hardware_version="A102",
    serial_number="L1233503188",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.152", username="ute", password="uteuteute"
    ),
    connections=[_asim_gnb_1],
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb_1])


_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)


_cbts = ClassicalBts(
    cu=_cu_gnb_1,
    dus=[_du_1_gnb_1],
    global_bts_id=50164,
    instance_id=50164,
)

_core = RealCore5G()


_abia_enb_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A104",
    serial_number="DH195290980",
)

_abia_enb_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A104",
    serial_number="DH195290431",
)

_abia_enb_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
    hardware_version="A103",
    serial_number="L1190308953",
)

_asia_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1, _abia_enb_2, _abia_enb_3],
    pdu_port=_pdu_enb.pdu_ports[10],
    hardware_type="ASIA",
    hardware_version="A203",
    serial_number="AH184015057",
)

_airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::fa08", vlan_id=38),
    global_bts_id=40164,
    instance_id=40164,
    oam_ip=NetworkAddress(v4="10.44.251.204"),
    rms=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.237", username="ute", password="uteuteute"
    ),
    connections=[_enb_1],
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_FULLRACK_ASIML_ABIOB1_ASIAR_B4B5B6_3xAAFB_shared_3xAAIB_shared_CPRI_ENB",
    core=_core,
    ues=[_android],
    pdus=[_pdu_gnb, _pdu_gnb_ru1, _pdu_gnb_ru2],
    attenuator=_attenuator,
)
