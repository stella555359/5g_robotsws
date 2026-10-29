__maintainer__ = "Kamil Ostrzolek"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "kamil.ostrzolek@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation
from taf.config.testline.appserver import AppServer
from taf.config.testline.ue import Android
from taf.config.testline.hardware_controller import AmiaFanHardwareController
from taf.config.testline.attenuator import TopYoung

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.72", username="ute", password="ute"
    )
)

_pdu_rmod1 = ATEN(addr="10.42.61.94", port_numbers=[2])
_pdu_asib = ATEN(addr="10.44.206.56", port_numbers=[2])
_pdus = [_pdu_rmod1, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:6030",
        vlan_id=820,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:6001"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:6130", vlan_id=821),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:6221", vlan_id=822),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:6321", vlan_id=823),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AZQG",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="serviceuser", password="umniedziala"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[2],
)

_core = RealCore5G(mcc=555, mnc=10)

_abil1_du1 = CapacityUnit(addr="192.168.253.20")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil1_du1],
    pdu_port=_pdu_asib.pdu_ports[2],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=50323, instance_id=50323)

_lte = RealEnb(
    system_module=Airscale(common_units=[_asib_du1]),
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::1:6128", vlan_id=821),
    global_bts_id=40323,
)

_lte.m = NetworkAddress(v6="2a00:8a00:6000:607c::1:6028", vlan_id=820)

_ue_pc_ssh = SshServiceDetails("10.42.63.236", "wro5goam", password="Uteadmin1@")

_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="572f1457",
    server_dir="/cygdrive/c/pyro_server/ta_ue_android_plugin/ue",
    python_path="python2",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/opt/iperf/",
)

_appserver_ssh = AppServer(iperf_details=_iperf)

_rpi_smod = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.91", username="pi", password="raspberry"
    )
)

_rpi_rmod = AmiaFanHardwareController(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.54.143", username="pi", password="pi"
    )
)

_attenuator = TopYoung(
    ip_addr="10.42.61.194", port=["1-1.4", "1-1.3"], attenuation_port_numbers=[4, 3]
)

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_RPI-EAC_ASIKL_ABILB1_AZQG",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    enbs=_lte,
    ues=[_android_ue],
    appserver=_appserver_ssh,
    hardware_controllers=[_rpi_smod, _rpi_rmod],
    attenuator=_attenuator,
)

__all__ = ["tl"]
