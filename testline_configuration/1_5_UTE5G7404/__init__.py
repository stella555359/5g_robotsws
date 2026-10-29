__maintainer__ = "meng meng"
__team__ = "I_MN_RAN_RD_RF_FV_CN_2_GMS"
__email__ = "meng.1.meng@nokia-sbell.com"


from taf.config.testline.pdu import HBTE, TopYoung
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.connection_details import (
    SshServiceDetails,
    TelnetConnectionDetails,
    HttpConnectionDetails,
)

from taf.config.testline.radio import RadioTypes, RU
from taf.config.testline.gnb.du import DU


# *****************************pdu************************
_gnb_pdu = HBTE(addr="10.101.35.226", port_numbers=[5])
_radio_pdu = TopYoung(addr="10.101.35.185", port_numbers=[5])


# *****************************radio***********************
_ru = RU(
    ru_hw_group="Below6GHz",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.8.2",
        username="rfsw",
        password="KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=",
    ),
    pdu_port=_radio_pdu.pdu_ports[5],
    radio_type=RadioTypes.AKQJ,
    serial_number="1M220107688",
)

# *****************************gNB***********************

_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.36", hardware_type="ABIP", rus=[_ru])


_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[5],
    hardware_type="ASIM",
)

_airscale = Airscale(common_units=[_common_unit_0])

_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.101.35.242")

_cu = CU(
    backhaul_site_oam_ip="10.101.35.242",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.101.35.242", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.101.35.242", username="Nemuadmin", password="nemuuser"
    ),
)

# **************************classicalbts************************
_classical_bts = ClassicalBts(dus=[_du], cu=_cu, instance_id=7404, global_bts_id=7404)


# ***************************host**********************************
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.106.207.227", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_classical_bts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        )
    ],
)


# ********************************cloud_topology**********************
_tl_cloud_topology = "CLOUD_RF_FEVE"

tl = TestLine(
    test_pc=_host,
    test_pcs=[_host],
    gnbs=[_classical_bts],
    tl_cloud_topology=_tl_cloud_topology,
)

# *****************************common*********************
# common
__all__ = ["tl"]
