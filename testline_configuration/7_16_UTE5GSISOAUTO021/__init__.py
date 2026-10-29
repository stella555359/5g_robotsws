__team__ = "MN 5G&SC 5G Pz 1 WRO 4 SG"
__owner__ = "Dawid Urbanski"
__maintainer__ = "Dawid Urbanski"
__email__ = "dawid.1.urbanski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol


__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::292d", vlan_id=401),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::292d", vlan_id=401),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::292d", vlan_id=401),
)

_pdu_gnb = Gude(addr="10.44.205.28", port_numbers=[1], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.205.81", port_numbers=[6], model="EPC", version="8221-1"
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.205.28", port_numbers=[12], model="EPC", version="8221-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_2T2R",
    radio_type="AZQI",
    serial_number="1M203838370",
    product_code="475243A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username={
            "SBTS21B": "root",
            "SBTS22R1": "rfsw",
            "SBTS22R2": "rfsw",
            "SBTS22R3": "rfsw",
        },
        password={
            "SBTS21B": "a2%FgSz3$fHmdusap354xujw7a",
            "SBTS22R1": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
            "SBTS22R2": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
            "SBTS22R3": "5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ=",
        },
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[6],
)

_gnb_ru_2 = RU(
    ru_hw_group="FRMr3.2_6T6R",
    radio_type="FRGX",
    serial_number="EA181010365",
    product_code="473440A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="root",
        password="",
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[12],
)

_abio_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1213905463",
    rus=[_gnb_ru_1, _gnb_ru_2],
)

_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1],
    pdu_port=_pdu_gnb.pdu_ports[1],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="L1220209754",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.148", username="ute", password="uteuteute"
    ),
    connections=[_asib_gnb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50521
)

_core = RealCore5G()

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65", user="5g", password="2019H@slo"
)

_nokia_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    serial_number="HZQN1876AAK90100042",
    ue_pc_address="10.44.72.65",
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.65", username="wro5gsiso", password="oZPS0POrRieRtu"
    ),
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    data_transfer=[_nokia_iperf],
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_NOKIA_ASIBL_ABIOB1_AZQI_FRGX",
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru_1, _pdu_gnb_ru_2],
)
