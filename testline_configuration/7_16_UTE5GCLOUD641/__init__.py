__maintainer__ = "Michal Lys"
__team__ = "I_5GSC_5G_PZ1_WRO_6"
__email__ = "I_5GSC_5G_PZ1_WRO_6@internal.nsn.com"
__owner_email__ = "michal.lys@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RU, NetworkAddress
from taf.config.testline.pdu import ATEN, Gude, PduPort
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import RealEnb
from taf.config.testline.core import RealCore5G
from taf.config.testline import RoutingInformation

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.102", username="ute", password="ute"
    )
)

_pdu_rmod1 = Gude(addr="10.44.206.12", port_numbers=[3], model="EPC", version="8221-1")
_pdu_rmod2 = Gude(addr="10.44.206.12", port_numbers=[4], model="EPC", version="8221-1")
_pdu_rmod3 = Gude(addr="10.44.206.12", port_numbers=[5], model="EPC", version="8221-1")
_pdu_asib = Gude(addr="10.44.205.3", port_numbers=[11], model="EPC", version="8221-1")
_pdus = [_pdu_rmod1, _pdu_rmod2, _pdu_rmod3, _pdu_asib]

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v6="2a00:8a00:6000:607c::1:a807",
        vlan_id=897,
        routing_v6=RoutingInformation(gateway="2a00:8a00:6000:607c::1:a801"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::1:b907", vlan_id=898),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::1:aa05", vlan_id=899),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::1:ab05", vlan_id=900),
)

_gnb_ru1 = RU(
    ru_hw_group="Unknown",
    radio_type="AHGD",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="serviceuser", password="root"
    ),
    pdu_port=_pdu_rmod1.pdu_ports[3],
)

_gnb_ru2 = RU(
    ru_hw_group="Unknown",
    radio_type="AHGD",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="serviceuser", password="root"
    ),
    pdu_port=_pdu_rmod2.pdu_ports[4],
)

_gnb_ru3 = RU(
    ru_hw_group="Unknown",
    radio_type="AHGD",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="serviceuser", password="root"
    ),
    pdu_port=_pdu_rmod3.pdu_ports[5],
)

_core = RealCore5G(mcc=555, mnc=10)

_abio1_du1 = CapacityUnit(addr="192.168.253.22")

_asib_du1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio1_du1],
    pdu_port=_pdu_asib.pdu_ports[11],
)

_airscale_gnb_1 = Airscale(common_units=[_asib_du1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru1, _gnb_ru2, _gnb_ru3])

_cbts = ClassicalBts(cu=_cu, dus=[_du_1_gnb_1], global_bts_id=51151, instance_id=51151)

# _ue_pc_ssh = SshServiceDetails("10.44.72.15", "wro5goam", password="Uteadmin1@")

# _android_ue = Android(
# ssh_connection_details=_ue_pc_ssh,
# serial_number="??",
# server_dir="/cygdrive/c/pyro_server/ta_ue_android_plugin/ue",
# python_path="python2",
# qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
# diag_cfg_path="C:/pyro_server/DIAG.cfg",
# )

# _iperf = IperfDataTransferDetails(
# ssh_connection_details=SshServiceDetails(
# addr="10.42.61.65", username="5g", password="2019H@slo"
# ),
# network_interface_address="10.42.197.170",
# iperf_path="/opt/iperf/",
# )

tl = TestLine(
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIBL_ABIOB1_3xAHGD",
    test_pc=_test_pc,
    pdus=_pdus,
    core=_core,
    gnbs=[_cbts],
    # ues=[_android_ue],
    # appserver=_appserver_ssh,
)

__all__ = ["tl"]
