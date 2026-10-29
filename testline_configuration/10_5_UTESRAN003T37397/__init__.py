__maintainer__ = "Yang Mengli"
__team__ = "NSB MN RAN RD VRF HAZ1 2"
__email__ = "mengliyang@nokia-sbell.com"


import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC, RRB, APC, Gude
from taf.config.testline.core import RealCore
from taf.config.testline.attenuator import HBTE
from taf.config.testline.gnb.du import Cablink, Endpoint
from taf.config.testline.appserver import AppServer
from taf.config.testline.core import RealCore
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    Android,
    Qualcomm,
    QualcommUeType,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)

# common
__all__ = ["tl"]

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.69.53.816", username="rrm2-tester", password="Nokia123!", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.212.49",
    iperf_path="/home/",
    port="54015",
)

_appserver = AppServer(_iperf)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="10.69.53.81", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIA",
)

_gnb_pdu = FACOM(addr="10.69.4.14", port_numbers=[1])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[1],
    hardware_type="ASIL",
)

_airscale = Airscale([_common_unit_0])

# RealEnb
_real_enb_pdu = FACOM(addr="10.69.4.14", port_numbers=[1])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.69.53.81", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[1],
    hardware_type="ASIB",
)

_real_enb = Airscale(common_units=[_common_unit_2])

_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# attenuator
_attenuator_0 = TopYoung(
    ip_addr="10.69.53.170",
    port=23,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="TAS16T16-51-120-1S-DES",
)

_attenuator_1 = TopYoung(
    ip_addr="10.69.53.165",
    port=23,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="TAS16T16-51-120-1S-DES",
)

# 5GRU for classicalBTS
_ru_pdu = FACOM(addr="10.97.65.6", port_numbers=[1, 2, 3])

_ru_0 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
    radio_type="AHLOA",
    # signal_analyzer=None,
    attenuation_ports=[
        _attenuator_0.attenuator_ports[1],
        _attenuator_0.attenuator_ports[2],
        _attenuator_0.attenuator_ports[3],
        _attenuator_0.attenuator_ports[4],
        _attenuator_0.attenuator_ports[5],
        _attenuator_0.attenuator_ports[6],
        _attenuator_0.attenuator_ports[7],
        _attenuator_0.attenuator_ports[8],
        _attenuator_0.attenuator_ports[9],
        _attenuator_0.attenuator_ports[10],
        _attenuator_0.attenuator_ports[11],
        _attenuator_0.attenuator_ports[12],
        _attenuator_0.attenuator_ports[13],
        _attenuator_0.attenuator_ports[14],
        _attenuator_0.attenuator_ports[15],
        _attenuator_0.attenuator_ports[16],
    ],
    serial_number=None,
)

_ru_1 = RU(
    ru_hw_group="AHFIB",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    pdu_port=_ru_pdu.pdu_ports[2],
    radio_type="AHFIB",
    # signal_analyzer=None,
    attenuation_ports=[
        _attenuator_0.attenuator_ports[10],
        _attenuator_0.attenuator_ports[12],
        _attenuator_0.attenuator_ports[14],
        _attenuator_0.attenuator_ports[16],
    ],
    serial_number=None,
)


_ru_2 = RU(
    ru_hw_group="AEHC",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.16.37.129", username="root", password="root"
    ),
    pdu_port=_ru_pdu.pdu_ports[3],
    radio_type="AEHC",
    # signal_analyzer=None,
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
        _attenuator_1.attenuator_ports[9],
        _attenuator_1.attenuator_ports[10],
        _attenuator_1.attenuator_ports[11],
        _attenuator_1.attenuator_ports[12],
        _attenuator_1.attenuator_ports[13],
        _attenuator_1.attenuator_ports[14],
        _attenuator_1.attenuator_ports[15],
        _attenuator_1.attenuator_ports[16],
    ],
    serial_number=None,
)

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(
    airscale=_airscale,
    rus=[_ru_0, _ru_1, _ru_2],
    f1_m_ip_addr="10.69.53.81",
    cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip="10.69.53.81",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.53.81", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.53.81", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.69.53.81", vlan_id=None),
    x2u=NetworkAddress(v4="10.69.53.81", vlan_id=None),
    s1u=NetworkAddress(v4="10.69.53.81", vlan_id=None),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=37397, global_bts_id=37397)

# Mifi
ue_config_path = os.path.join(_CFG_DIR, "TestData/mifi.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(f, Loader=yaml.FullLoader)
else:
    ue_config = ""

# Qualcomm
_android1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.18", username="rrm2-tester", password="Nokia123!"
    ),
    serial_number="R5CN20BJXTL",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "RRM2_S20"],
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.18", username="rrm2-tester", password="Nokia123!"
    ),
    serial_number="9YS0220730009229",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "RRM2_HUAWEI"],
)

Samsung_vonr = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.18", username="rrm2-tester", password="Nokia123!"
    ),
    serial_number="RFCX50GDL7Y",
    server_dir="/cygdrive/c/pyro_server",
    # python_path="C:/Python27/python.exe",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "samsung"],
)

_M80 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.18", username="rrm2-tester", password="Nokia123!"
    ),
    serial_number="0123456789ABCDEF",
    server_dir="/cygdrive/c/pyro_server",
    # python_path="C:/Python27/python.exe",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "REAL_ANDROID_UE"],
)

# #host
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.53.201", username="ute", password="uteUTE!"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_NSA_SA_1xQC_2xASIL_2xABIL_1xABIO_1xAHLOA_1xAHFIB_1xAEHC",
    ues=[Samsung_vonr, _M80],
    enbs=[_lte_real_enb],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=[_attenuator_0, _attenuator_1],
)
__all__ = ["tl"]
