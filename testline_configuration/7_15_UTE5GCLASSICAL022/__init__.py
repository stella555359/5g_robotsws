######################################
#  TestLine 22 Ulm                   #
######################################
__maintainer__ = "MN ECE RD ULM L2PS 05 SG SQD66"
__team__ = "MN ECE RD ULM L2PS 05 SG SQD66"
__email__ = "martin.waller@nokia.com"

import os

from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.appserver import AppServer
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.ue import TM500
from taf.config.testline.pdu import APC
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

# from taf.config.testline.attenuator import Attenuator, AttenuationPort
# do we stil need?
# _CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.205", username="ute", password="ute"
    )
)

_gnb1_comu_pdu = APC(addr="10.46.139.53", port_numbers=[2])

_gnb1_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port="443"
    ),
    x2c=NetworkAddress(v4="192.168.4.3"),
    x2u=NetworkAddress(v4="192.168.4.3"),
    s1u=NetworkAddress(v4="192.168.4.2"),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_gnb1_comu_pdu.pdu_ports[2],
    hardware_type="ASIB",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])

# _gnb1_rm_attenuator = Attenuator(ip_addr="10.46.138.11",
#                                  port="3001",
#                                  attenuation_port_numbers=[5, 6, 7, 8,],
#                                  model="JFW")

# _gnb1_rm_attenuation_port1 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=7)
# _gnb1_rm_attenuation_port2 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=8)
# _gnb1_rm_attenuation_port3 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=5)
# _gnb1_rm_attenuation_port4 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=6)

_gnb1_rf_pdu = APC(addr="pdu1-659", port_numbers=[2])

_gnb1_du_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[2],
    radio_type="AEQD",
    attenuation_ports=None,
)

_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])


_epcsim = EPCSim(
    mme_ip="192.168.4.2",
    mcc=311,
    mnc=489,
    tac=123,
    default_ssh_connection_details=SshServiceDetails(
        addr="10.47.18.205", username="ute", password="ute"
    ),
    dir_path="/opt/wts",
    cfg_filename="TL22_basic_cfg_realLteEnb.cfg",
    edaemon_port=22222,
    egate_port=20021,
)


_enb_comu_pdu = APC(addr="pdu2-651", port_numbers=[3])

_enb1_capu = CapacityUnit(addr="192.168.253.20")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.4.121", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_enb_comu_pdu.pdu_ports[3],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1 = RealEnb(system_module=_enb1_airscale)


_tm500_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gueapp303", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="192.168.13.1",
    iperf_path="/usr/bin/iperf",
)

_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="10.46.212.228", username="viavi3user", password="qwer2009!"
    ),
    tma_command_port=5003,
    pdu_port=None,
    tma_path="C:\\Program Files (x86)\\Aeroflex\\TM500\\5G_NR\\Test Mobile Application\\TmaApplication.exe",
    iperf_details=_tm500_iperf,
    imsi="311489000000787",
    sec_key="01020304050607080910101010101001",
)

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gappserv303", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="192.168.13.1",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

# Testline
tl = TestLine(
    test_pc=_host,
    gnbs=[_gnb1],
    enbs=[_enb1],
    core=_epcsim,
    ues=[_tm500],
    appserver=_core_appserver,
    tl_cloud_topology="CLASSICAL_5G_TYPE",
)

__all__ = ["tl"]
