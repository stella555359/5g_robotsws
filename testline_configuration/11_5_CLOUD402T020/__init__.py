__maintainer__ = "Xuan Eahsuan"
__team__ = "I_NSB_MN_5GSC_5GSW_ENG_AIC_SI_CN_RRM_OM@internal.nsn.com"  # TL owner's team
__email__ = "eahsuan.xuan@nokia-sbell.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC
from taf.config.testline import RU, DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import (
    Enb,
    SimEnb,
    RealEnb,
    RadioModule,
    LTEEmuEnb,
    PrismaEnb,
    DocomoEnb,
)
from taf.config.testline.attenuator import (
    AttenuationPort,
    RadioRack,
)  # added in taf.meta 5.4
from taf.config.testline.legacy import SCF
from taf.config.testline.ue import Android
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_attenuator = RadioRack(
    ip_addr="10.57.238.26",
    port="5000",
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

_ru_pdu = FACOM(addr="10.57.241.207", port_numbers=[4])

_ru = RU(
    ru_hw_group="Below6GHZ",  # Above6GHZ or Below6GHZ
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.53", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.53", username="user", password="pass"
    ),
    # pdu_port=_ru_pdu.pdu_ports[2],
    radio_type=RadioTypes.AZQH,
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
    ],
)
#########5G_gNB_Start##########

_gnb_pdu = FACOM(addr="10.57.241.205", port_numbers=[5])
_capacity_unit = CapacityUnit(addr="192.168.253.20")
_common_unit_0 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.57.230.12", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[5],
)
_airscale = Airscale(common_units=[_common_unit_0])
_cu = CU(
    backhaul_site_oam_ip="10.57.230.12",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.57.230.12", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.57.230.12", username="Nemuadmin", password="nemuuser"
    ),
)

# _du = DU(airscale=_airscale, rus=None)
_du = DU(airscale=_airscale, rus=[_ru], f1_m_ip_addr="10.57.230.12")
_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=3235, global_bts_id=3235)
#########5G_gNB_Stop##########

#########4G_eNB_Start##########
_real_enb_pdu = FACOM(addr="10.57.241.205", port_numbers=[5])
_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.57.238.21", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[5],
)

_real_enb = Airscale(common_units=[_common_unit_2])
_lte_real_enb = RealEnb(
    airscale=_real_enb, rms=None, instance_id=3236, global_bts_id=3236
)
#########4G_eNB_Stop##########

#########Testpc##########
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.157.148", username="ute", password="ute"
    )
)


#########LteEmu##########
_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.238.5", username="nokia", password="nokia123"
    ),
    dir_path="/home/nokia/LTEemu_core2_64_3252",
    cfg_filename="basic_wts_step1.cfg",
    mme_ip="",
    edaemon_port="22222",
    egate_port="9880",
)


_appserver_ssh = SshServiceDetails(addr="10.57.157.148", username="ute", password="ute")
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.57.157.148",
    iperf_path="/usr/bin/iperf",
    port="59029",
)
_qualcomm = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.57.130.126", username="rock.1.wang", password="nokiaE2E@2020"
    ),
    serial_number="d3db6e29",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["REAL_ANDROID_UE"],
)

# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    enbs=[_lte_real_enb],
    core=_lteemu,
    attenuator=_attenuator,
    tl_cloud_topology="",
    ues=[_qualcomm],
)


__all__ = ["tl"]
