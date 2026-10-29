__maintainer__ = "I_MN_5GSC_KRK_AUTO"
__team__ = "I_MN_5GSC_KRK_AUTO"
__email__ = "I_MN_5GSC_KRK_AUTO@internal.nsn.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline import NetworkAddress, RU, RoutingInformation
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.pdu import PduPort, FPFH


# The most commonly used testline configuration. #

_test_pc_enb_default_ssh_connection_details = SshServiceDetails(
    addr="10-7-UTESRAN366.sc5g.krk-lab.nsn-rdnet.net",
    username="ute",
    password="ute",
)
_lmp_ip = "192.168.255.129"
_enb_bh_ip = "10.83.183.116"
_enb_oam_ip = _lmp_ip
_enb_oam_backhaul_ip = NetworkAddress(
    v4="{}/23".format(_enb_bh_ip),
    routing_v4=RoutingInformation(gateway="10.83.183.254"),
    vlan_id=503,
)
_enb_instance_id = 75366
_enb_global_bts_id = 75366
_enb_du_common_unit_hardwarde_type = "ASIA"
_enb_ru_ip = NetworkAddress(v4="172.16.11.49")
_enb_pdu = FPFH(
    port_numbers=[1],
    addr="FPFH-GK04-1.sc5g-leg.krk-lab.nsn-rdnet.net",
    login="admin",
    password="admin",
    model="FPFH",
    protocol="http",
)
_enb_ru_hw_group = "FXED"

##############################################################
# Default values
_default_ssh_lmp_connection = SshServiceDetails(
    addr=_lmp_ip,
    username="toor4nsn",
    password="oZPS0POrRieRtu",
)
_default_oam_http_connection = HttpConnectionDetails(
    addr=_enb_oam_ip,
    username="Nemuadmin",
    password="nemuuser",
    port=443,
)

##############################################################
# Important!: check and change below if other than default #
# Test PCs
_test_pc_enb = TestPc(
    default_ssh_connection_details=_test_pc_enb_default_ssh_connection_details
)

_du_lmp_connection_gnb = _default_ssh_lmp_connection
_du_lmp_connection_gnb.proxy = _test_pc_enb_default_ssh_connection_details

_ru_enb = RU(
    ru_hw_group=_enb_ru_hw_group,
    default_ssh_connection_details=SshServiceDetails(
        addr=_enb_ru_ip.v4,
        username="root",
        password="asmr",
    ),
    pdu_port=PduPort(pdu=_enb_pdu, port_no=6),
)
_abia_master_enb = CapacityUnit(addr="192.168.253.38", rus=[_ru_enb])
_du_common_unit_enb = CommonUnit(
    lmp_connection=_default_ssh_lmp_connection,
    capacity_units=[_abia_master_enb],
    pdu_port=PduPort(pdu=_enb_pdu, port_no=1),
    hardware_type=_enb_du_common_unit_hardwarde_type,
    hardware_version="L11",
)

_airscale_enb = Airscale(common_units=[_du_common_unit_enb])

_enb = RealEnb(
    airscale=_airscale_enb,
    system_module=_airscale_enb,
    rms=[_ru_enb],
    instance_id=_enb_instance_id,
    global_bts_id=_enb_global_bts_id,
    oam_ip=NetworkAddress(v4=_enb_oam_ip),
)

# Testline
tl = TestLine(
    enbs=[_enb],
    test_pc=_test_pc_enb,
    test_pcs=[_test_pc_enb],
    tl_cloud_topology="CLOUD_SRAN_L_1ASIA_1ABIA_1FXED",
)
__all__ = ["tl"]
