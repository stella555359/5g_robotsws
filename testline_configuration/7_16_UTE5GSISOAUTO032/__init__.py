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
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.ue import TafUeAndroid

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
    x2c=NetworkAddress(v4="10.45.178.110", vlan_id=852),
    x2u=NetworkAddress(v4="10.45.178.110", vlan_id=852),
    s1u=NetworkAddress(v4="10.45.178.110s", vlan_id=852),
)

_pdu_gnb = Gude(addr="10.44.205.245", port_numbers=[6], model="EPC", version="8221-1")

_pdu_gnb_ru_1 = Gude(
    addr="10.44.205.18", port_numbers=[2], model="EPC", version="8221-1"
)

_pdu_gnb_ru_2 = Gude(
    addr="10.44.205.18", port_numbers=[3], model="EPC", version="8221-1"
)

_pdu_gnb_ru_3 = Gude(
    addr="10.44.205.245", port_numbers=[8], model="EPC", version="8221-1"
)

_gnb_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZHL",
    serial_number="AH220801618",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_1.pdu_ports[2],
)

_gnb_ru_2 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZHL",
    serial_number="AH220801622",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_gnb_ru_2.pdu_ports[3],
)

_gnb_ru_3 = RU(
    ru_hw_group="5Ggen4_LowF_8T8R",
    radio_type="AZHL",
    serial_number="AH212600310",
    product_code="475432A.101",
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
    pdu_port=_pdu_gnb_ru_3.pdu_ports[8],
)

_abio_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="L1210903857",
    rus=[_gnb_ru_1, _gnb_ru_2],
)
_abio_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A103",
    serial_number="	L1214208569",
    rus=[_gnb_ru_1, _gnb_ru_2],
)
_asib_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1],
    pdu_port=_pdu_gnb.pdu_ports[6],
    hardware_type="ASIB",
    hardware_version="A102",
    serial_number="DH211167057",
)

_airscale_gnb_1 = Airscale(common_units=[_asib_gnb_1])

_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1,
    rus=[_gnb_ru_1, _gnb_ru_2, _gnb_ru_3],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.180", username="ute", password="uteuteute"
    ),
    connections=[_asib_gnb_1],
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50997, instance_id=50997
)

_core = RealCore5G()

_appserver_ssh = TafUeAppServer(
    app_server_name="APP_1", address="10.45.168.53", user="5g", password="2019H@slo"
)

_iperf = TafUeDataTransferProtocol(
    protocol_name="iperf",
    app_server=_appserver_ssh,
)

_nokia = TafUeAndroid(
    ssh_connection_details=SshServiceDetails(
        addr="10.44.72.130", username="wro5goam", password="Uteadmin1@"
    ),
    serial_number="M9AIKN01N508EMH",
    ue_pc_address="10.44.72.130",
    data_transfer=[_iperf],
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    qualcomm_prototype=False,
    network_mode_switch_method="adb",
    ue_pc_port="80",
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
    ues=[_nokia],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASUS_ASIBL_ABIOB1B2_2xAZHL",
    core=_core,
    pdus=[
        _pdu_gnb,
        _pdu_gnb_ru_1,
        _pdu_gnb_ru_2,
        _pdu_gnb_ru_3,
    ],
)
