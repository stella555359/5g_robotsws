__maintainer__ = "Tomasz Krol"
__email__ = "tomasz.krol@nokia.com"

import os

from taf.config.testline.testpc import TestPc
from taf.config.testline import RU, DU
from taf.config.testline.pdu import ATEN, PduPort
from taf.config.testline.ue import Android
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.airscale import CommonUnit, CapacityUnit, Airscale
from taf.config.testline.enb import RealEnb
from taf.config.testline.core import EPCSim
from taf.config.testline.attenuator import AttenuationPort, JFW
from taf.config.testline.pdu import PduPort, ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    SCRadioConnectionDetails,
    TelnetConnectionDetails,
    IperfDataTransferDetails,
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.52.205.118", username="ute", password="ute"
    )
)

_ru_pdu = ATEN(addr="0.0.0.0", port_numbers=[1])

_ru_1 = RU(  # TODO
    ru_hw_group="hw_group",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.253.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
)

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="10.24.78.42"),
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.24.78.42", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.24.78.42", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.24.78.42"),
    x2u=NetworkAddress(v4="10.24.78.42"),
    s1u=NetworkAddress(v4="10.24.78.42"),
)

_du_lmp_connection = SshServiceDetails(
    addr="10.24.78.42",
    username="toor4nsn",
    password="oZPS0POrRieRtu",
)

_du_capacity_unit = CapacityUnit(
    addr="192.168.253.21", hardware_type="ABIL", hardware_version="A101B1"
)

_du_common_unit = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    hardware_type="ASIK",
    pdu_port=PduPort(pdu=ATEN(addr="1.1.1.1", port_numbers=[1]), port_no=1),
)

_airscale = Airscale(common_units=[_du_common_unit])

_du = DU(airscale=_airscale, rus=[_ru_1], f1_m_ip_addr="10.24.78.42")

_bts = ClassicalBts(cu=_cu, dus=[_du])

_core = EPCSim(
    default_ssh_connection_details=SshServiceDetails(
        addr="7_7_cloudt283.sc5g.krk-lab.nsn-rdnet.net",  # TODO Change IP
        username="ute",
        password="ute",
    ),
    dir_path="/epcsim",
    cfg_filename="sim2.cfg",
    mme_ip="10.253.165.33",
    mcc=244,
    mnc=8,
    tac=1024,
    edaemon_port=12345,
    egate_port=60001,
)

# #RealEnb
_real_enb_pdu = ATEN(addr="0.0.0.0", port_numbers=[4])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.24.78.76", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[4],
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

_ue_pc_ssh = SshServiceDetails(
    addr="10.52.205.106", username="usnap-scpadm", password="Scp@dm1!"
)
_appserver_ssh = SshServiceDetails(
    addr="10.4.130.74", username="scpadm", password="scpadm"
)
_android_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.4.134.145",
    iperf_path="/data/local/tmp/iperf-android",
)
_android_ue = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="7d586bb0",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    dmc_path="c:/usb/Config-4G-5G-SDx55-RFP_v0.4.dmc",
    diag_com="MDM",
    iperf_details=_android_iperf,
    capabilities=["REAL_ANDROID_UE"],
)

_attenuator = JFW(ip_addr="10.52.206.56", port=3001, attenuation_port_numbers=[3, 4])

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_bts],
    core=_core,
    ues=[_android_ue],
    attenuator=_attenuator,
    tl_cloud_topology="TL14",
)

__all__ = ["tl"]
