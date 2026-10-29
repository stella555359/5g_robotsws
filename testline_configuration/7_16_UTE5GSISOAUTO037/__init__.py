__maintainer__ = "Urszula Plocienniczak"
__team__ = "5G_PZ_1_WRO_4_SG"
__email__ = "urszula.plocienniczak@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid


__all__ = ["tl"]

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_Server_WG",
    bind_interface_ip="10.44.184.246",
    address="10.44.184.246", user="ranpz", password="Pass4Testers!")

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh)


_nokia = TafUeAndroid(
   serial_number="HZQN1876BAKC2300428",
    ue_pc_address="10.42.36.151",
    ssh_connection_details=SshServiceDetails(
        addr="10.42.36.151", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_iperf],
    network_mode_switch_method="adb",
)

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.44.46.188",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::1:a2ef", vlan_id=370),
    x2u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::1:a2ef", vlan_id=370),
    s1u=NetworkAddress(v4=None, v6="2a00:8a00:6000:607c::1:a2ef", vlan_id=370),
)

_pdu_enb = ATEN(addr="10.44.167.209", port_numbers=[4])

_pdu_enb_ru = Gude(addr="10.44.167.206", port_numbers=[8], version="8221-1")

_enb_ru_1 = RU(
    ru_hw_group="oZPS0POrRieRtu",
    radio_type="AQNA",
    serial_number="L1224605017",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.9.129",
        username={
            "SBTS22R4": "rfsw",
        },
        password={
            "SBTS22R4": "dV0s7Yk/kE100lIN53JdoX/bjZ+J3kXU4g4HMXda+ew=",
        },
    ),
    pdu_port=_pdu_enb_ru.pdu_ports[8],
)

_asoe_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_pdu_enb.pdu_ports[4],
    serial_number="EA213153868",
    hardware_type="ASOE",
)

_airscale_enb_1 = Airscale(common_units=[_asoe_enb_1])

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    global_bts_id=1,
    instance_id=40611,
    oam_ip=NetworkAddress(v4="10.44.46.188"),
    rms=[_enb_ru_1],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.40.128", username="ute", password="ute"
    ),
    connections=[_asoe_enb_1],
)

_core = RealCore5G()


tl = TestLine(
    test_pc=_lmp_vm_enb_1,
    test_pcs=[_lmp_vm_enb_1],
    enbs=[_enb_1],
    core=_core,
    ues=[_nokia],
    pdus=[_pdu_enb, _pdu_enb_ru],
)