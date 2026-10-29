######################################
#  TestLine 102 Ulm                  #
######################################
__maintainer__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__team__ = "MN ECE ULM R&D L3NRT 07 SqdGp63"
__email__ = "I_ECE_RD_ULM_SQD_63@internal.nsn.com"
__owner_email__ = "vasileios.papoutsis@nokia.com"

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
from taf.config.testline.core import RealCore4G
from taf.config.testline.ue import TM500
from taf.config.testline.pdu import APC
from taf.config.testline.radio import RU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit

# from taf.config.testline.attenuator import Attenuator, AttenuationPort

_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="kiwi323.delab3.nsn", username="dpdktests", password="qwer2009!"
    )
)

_real_core_4G = RealCore4G(mcc="555", mnc="10")

_gnb2_comu_pdu = APC(addr="10.46.139.53", port_numbers=[4])

_gnb2_cu = CU(
    backhaul_site_oam_ip="192.168.255.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.2", username="Nemuadmin", password="nemuuser", port="443"
    ),
)

_gnb2_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.2", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb2_capu1],
    pdu_port=_gnb2_comu_pdu.pdu_ports[4],
    hardware_type="ASIK",
)

_gnb2_airscale = Airscale(common_units=[_gnb2_comu])

# _gnb2_rm_attenuator = Attenuator(ip_addr="10.46.133.94",
#                                  port="3001",
#                                  attenuation_port_numbers=[4, 12],
#                                  model="JFW")

# _gnb2_rm_attenuation_port1 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=4)

# _gnb2_rm_attenuation_port2 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=12)

_gnb2_rf_pdu = APC(addr="10.46.139.59", port_numbers=[4])

_gnb2_du_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb2_rf_pdu.pdu_ports[4],
    radio_type="AEQN",
    attenuation_ports=None,
)

_gnb2_du = DU(airscale=_gnb2_airscale, rus=[_gnb2_du_rm])

_gnb2 = ClassicalBts(cu=_gnb2_cu, dus=[_gnb2_du])

_gnb1_comu_pdu = APC(addr="10.46.139.59", port_numbers=[3])

_gnb1_cu = CU(
    backhaul_site_oam_ip="192.168.255.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.3", username="Nemuadmin", password="nemuuser", port="443"
    ),
)

_gnb1_capu1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIL")

_gnb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_gnb1_capu1],
    pdu_port=_gnb1_comu_pdu.pdu_ports[3],
    hardware_type="ASIK",
)

_gnb1_airscale = Airscale(common_units=[_gnb1_comu])

# _gnb1_rm_attenuator = Attenuator(ip_addr="10.46.133.94",
#                                  port="3001",
#                                  attenuation_port_numbers=[4, 12],
#                                  model="JFW")

# _gnb1_rm_attenuation_port1 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=4)

# _gnb1_rm_attenuation_port2 = AttenuationPort(attenuator=_rm_attenuator,
#                                              port_no=12)

_gnb1_rf_pdu = APC(addr="10.46.139.59", port_numbers=[3])

_gnb1_du_rm = RU(
    ru_hw_group="",
    default_ssh_connection_details=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="1.1.1.1", username="root", password="umniedziala"
    ),
    pdu_port=_gnb1_rf_pdu.pdu_ports[3],
    radio_type="AEQN",
    attenuation_ports=None,
)

_gnb1_du = DU(airscale=_gnb1_airscale, rus=[_gnb1_du_rm])

_gnb1 = ClassicalBts(cu=_gnb1_cu, dus=[_gnb1_du])

_enb_comu_pdu = APC(addr="10.46.139.61", port_numbers=[7, 8])

_enb2_capu = CapacityUnit(addr="192.168.253.20")

_enb2_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.16.180", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb2_capu],
    pdu_port=_enb_comu_pdu.pdu_ports[8],
)

_enb2_airscale = Airscale(common_units=[_enb2_comu])

_enb2 = RealEnb(system_module=_enb2_airscale)

_enb1_capu = CapacityUnit(addr="192.168.253.20")

_enb1_comu = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.47.16.170", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_enb1_capu],
    pdu_port=_enb_comu_pdu.pdu_ports[7],
)

_enb1_airscale = Airscale(common_units=[_enb1_comu])

_enb1 = RealEnb(system_module=_enb1_airscale)

_tm500_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="ul5gueapp304", username="dpdktests", password="qwer2009!"
    ),
    network_interface_address="10.44.35.231",
    iperf_path="/usr/bin/iperf",
)

_tm500 = TM500(
    tma_host=SshServiceDetails(
        addr="tmapc304.delab3.nsn", username="viavi4user", password="qwer2009!"
    ),
    tma_command_port=5003,
    pdu_port=None,
    tma_path="C:\\Program Files (x86)\\Aeroflex\\TM500\\5G NR - NLA 4.30.0 NG270120201\\Test Mobile Application\\TmaApplication.exe",
    iperf_details=_tm500_iperf,
    imsi="555107000000044",
    sec_key="00112233445566778899AABBCCDDEEFF",
)

_core_iperf = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="app-srv29", username="user3", password="user3"
    ),
    network_interface_address="10.44.35.231",
    iperf_path="/usr/bin/iperf",
)

_core_appserver = AppServer(iperf_details=_core_iperf)

tl = TestLine(
    test_pc=_host,
    gnbs=[_gnb1, _gnb2],
    enbs=[_enb1, _enb2],
    core=_real_core_4G,
    ues=[_tm500],
    appserver=_core_appserver,
    tl_cloud_topology="NON_CM",
)

__all__ = ["tl"]
