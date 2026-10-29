__maintainer__ = "Pawel Zabawczuk"
__team__ = "RRM team"
__email__ = "pawel.k.zabawczuk@nokia.com"
__owner_email__ = "pawel.k.zabawczuk@nokia.com"

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

_cfg_dir = os.path.dirname(os.path.abspath(__file__))
os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_vm_ute = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.14.58.6", username="ute", password="uteUTE!"
    )
)

_pdu_du = ATEN(addr="10.5.115.60", port_numbers=[1, 2])

_du0_capacity_unit_L_0 = CapacityUnit(addr="192.168.253.20")

_common_unit_0_L = CommonUnit(
    hardware_type="ASIL",
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_du0_capacity_unit_L_0],
    pdu_port=_pdu_du.pdu_ports[1],
)

_airscale = Airscale(common_units=[_common_unit_0_L])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.14.48.58",
        vlan_id="1000",
        routing_v4=RoutingInformation(gateway="10.14.49.254", ip_prefix_length=23),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.58", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.0.102.171",
        vlan_id="4002",
        routing_v4=RoutingInformation(gateway="10.0.102.174", ip_prefix_length=32),
    ),
    x2u=NetworkAddress(
        v4="10.0.102.172",
        vlan_id="4002",
        routing_v4=RoutingInformation(gateway="10.0.102.174", ip_prefix_length=29),
    ),
    s1c=NetworkAddress(
        v4="10.0.102.171",
        vlan_id="4002",
        routing_v4=RoutingInformation(gateway="10.0.102.174", ip_prefix_length=29),
    ),
    s1u=NetworkAddress(
        v4="10.0.102.172",
        vlan_id="4002",
        routing_v4=RoutingInformation(gateway="10.0.102.174", ip_prefix_length=32),
    ),
    tracing=None,
)

_abio_master = CapacityUnit(addr="192.168.253.20")
_abio_lokia = CapacityUnit(addr="192.168.253.21")
_abio_lokib = CapacityUnit(addr="192.168.253.22")

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.10.1", username="root", password="a2%FgSz3$fHmdusap354xujw7a"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=None,
    ru_hw_group="",
    radio_type="AEHC",
)

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_abio_lokia, label="SFP", port_id=1),
        target=Endpoint(unit=_ru1, label="SFP", port_id=3),
    )
]

_du = DU(_airscale, rus=[_ru1], cablinks=_ru_cablinks)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=58, global_bts_id=58)

# 4G radio units
_radio_units_enb = [
    RU(
        ru_hw_group="LTE_RADIO",
        radio_type="UHHA",
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
    instance_id=10061,
    global_bts_id=10061,
    oam_ip=NetworkAddress(
        v4="10.14.48.130",
        routing_v4=RoutingInformation(gateway="10.14.49.254", ip_prefix_length=23),
    ),
    x2_link_addr=NetworkAddress(v4="10.0.103.49"),
)

_core = RealCore5G(mcc=540, mnc=1)

_tl_cloud_topology = "CLOUD_5G_CLASSICAL_ASIL_ABIO_AEHC_eCPRI"

_ue_pc_ssh = SshServiceDetails(
    addr="10.0.96.129", username="cv5g1_5", password="P@scal5G"
)

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    capabilities=["REAL_UE", "REAL_ANDROID_UE"],
    serial_number="5b65d3f4",
    server_dir="/cygdrive/d/UEManager/ue_manager_files/pyro_server",
    python_path="python2",
    qcat_path="/cygdrive/c/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="/cygdrive/d/UEManager/ue_manager_files/pyro_server/DIAG.cfg",
    iperf_details=IperfDataTransferDetails(
        network_interface_address="",
        ssh_connection_details=SshServiceDetails(
            addr="10.0.106.16", username="ran5g", password="nokia2018"
        ),
        iperf_path="/usr/bin/iperf",
    ),
)

os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config_cv58.yml"
)

tl = TestLine(
    test_pc=_vm_ute,
    gnbs=[_cbts],
    enbs=[_lte_enb],
    tl_cloud_topology=_tl_cloud_topology,
    core=_core,
    ues=[_android_ue],
)

__all__ = ["tl"]
