__maintainer__ = "Philippe Gaborieau"
__team__ = "MN 5G&SC Pz 5G I&V 2 NPS 4 SG"
__email__ = "philippe.gaborieau@nokia.com"
__owner_email__ = "philippe.gaborieau@nokia.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.testpc import TestPc
from taf.config.testline.gnb.du import RU, DU
from taf.config.testline.pdu import ATEN, FACOM, PduPort
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.enb import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline.gnb.du import Cablink, Endpoint

__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_vm_ute = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.58.3", username="ute", password="uteUTE!"
    )
)

_pdu_du = ATEN(addr="10.5.115.114", port_numbers=[1, 2])

_du0_capacity_unit_L_0 = CapacityUnit(addr="192.168.253.20")

_common_unit_0_L = CommonUnit(
    hardware_type="ASIB",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_du0_capacity_unit_L_0],
    pdu_port=_pdu_du.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit_0_L])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.14.48.60",
        vlan_id="1000",
        routing_v4=RoutingInformation(gateway="10.14.49.254", ip_prefix_length=23),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.60", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.14.48.60", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.28.24.97",
        vlan_id="4003",
        routing_v4=RoutingInformation(gateway="10.28.24.102", ip_prefix_length=29),
    ),
    x2u=NetworkAddress(
        v4="10.28.24.98",
        vlan_id="4003",
        routing_v4=RoutingInformation(gateway="10.28.24.102", ip_prefix_length=29),
    ),
    s1u=NetworkAddress(
        v4="10.28.24.98",
        vlan_id="4003",
        routing_v4=RoutingInformation(gateway="10.28.24.102", ip_prefix_length=29),
    ),
    tracing=None,
)

_abio_master = CapacityUnit(addr="192.168.253.36")
_abio_lokia = CapacityUnit(addr="192.168.253.37")
_abio_lokib = CapacityUnit(addr="192.168.253.38")

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.1", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abio_lokia, label="SFP", port_id=1),
        target=Endpoint(unit=_ru1, label="SFP", port_id=2),
    )
]

_du = DU(_airscale, rus=[_ru1], cablinks=_ru_cablinks)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=60, global_bts_id=60)

# 4G radio units
_radio_units_enb = [
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="UHMB",
    )
]

# 4G anchor BTS
_capacity_units_enb = [CapacityUnit(addr="192.168.253.20", hardware_type="ABIA")]

_common_unit_enb = CommonUnit(
    hardware_type="ASIA",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=_capacity_units_enb,
    pdu_port=_pdu_du.pdu_ports[2],
)

_airscale_enb = Airscale(common_units=[_common_unit_enb])

_lte_enb = RealEnb(
    airscale=_airscale_enb,
    rms=_radio_units_enb,
    instance_id=10060,
    global_bts_id=10060,
    oam_ip=NetworkAddress(
        v4="10.14.49.41",
        routing_v4=RoutingInformation(gateway="10.14.49.254", ip_prefix_length=23),
    ),
    x2_link_addr=NetworkAddress(v4="10.28.15.221"),
)

_core = RealCore5G(mcc=540, mnc=1)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIB_ABIO_AEQN_eCPRI"

_ue_pc_ssh = SshServiceDetails(
    addr="10.0.96.24", username="cv5g1_5", password="P@scal5G"
)

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    serial_number="27fe6c88",
    server_dir="C:/UEManager/ue_manager_files/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/UEManager/ue_manager_files/pyro_server/DIAG.cfg",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=SshServiceDetails(
            addr="10.14.42.250", username="ran5g", password="nokia2018"
        ),
        iperf_path="/usr/bin/iperf",
    ),
)

tl = TestLine(
    test_pc=_vm_ute,
    gnbs=[_cbts],
    enbs=[_lte_enb],
    tl_cloud_topology=_tl_cloud_topology,
    core=_core,
    ues=[_android_ue],
)
