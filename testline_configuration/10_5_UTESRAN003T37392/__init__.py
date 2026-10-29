__maintainer__ = "Guo Qianqian"
__team__ = "NSB MN SRAN Prod HZH RRM 3 Vrf"
__email__ = "qianqian.guo@nokia.com"


import os
import yaml
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
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
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline import Airphone
from taf.config.testline.pdu import FACOM
from taf.config.testline.appserver import AppServer
from taf.config.testline.attenuator import HBTE, JFW, AttenuationPort, TopYoung
from taf.config.testline.core import RealCore
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    Android,
    Qualcomm,
    QualcommUeType,
)
from taf.config.testline.enb import (
    Enb,
    SimEnb,
    RealEnb,
    LTEEmuEnb,
    PrismaEnb,
    DocomoEnb,
)
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)
from taf.config.testline.enb import (
    RealEnb,
)
# common
__all__ = ["tl"]

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

## attenuator
_attenuator_0 = JFW(
    ip_addr="10.69.53.170",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="TAS16T16-51-120-1N-DES",
)

_attenuator_1 = JFW(
    ip_addr="10.69.53.142",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="TAS16T8-34-120-1N-DES",
)

# Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.106.243.149", username="ute", password="PZ1RRM3!5t6y7u", port="54015"
)

_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.106.243.149",
    iperf_path="/data/data/com.nokia.syve.uemanager.mobile/",
    port="54015",
)

_appserver = AppServer(_iperf)

# DU for classicalBTS
_lmp_connection = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

#Multi BBMOD
_capacity_unit0 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
)

_capacity_unit1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
)

_capacity_unit2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
)

_gnb_pdu = FACOM(addr="10.69.4.14", port_numbers=[1])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit0, _capacity_unit1, _capacity_unit2],
    pdu_port=_gnb_pdu.pdu_ports[1],
    hardware_type="ASIL"
)

_airscale = Airscale([_common_unit_0])

# RealEnb--4G
#_real_enb_pdu = FACOM(addr="10.69.4.14", port_numbers=[2])

#_common_unit_2 = CommonUnit(
#   lmp_connection=SshServiceDetails(
#        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#   ),
#   capacity_units=[],
#    pdu_port=_real_enb_pdu.pdu_ports[2],
#    hardware_type="ASIL"
#)

#_real_enb = Airscale(common_units=[_common_unit_2])

#_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.69.4.14", port_numbers=[3])
_ru_1_pdu = FACOM(addr="10.69.4.14", port_numbers=[4])
_ru_2_pdu = FACOM(addr="10.69.4.14", port_numbers=[5])

_ru_0 = RU(
    ru_hw_group="AEQQ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.2", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.9.2", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[3],
    radio_type="AEQQ",
	serial_number="1M220620972",
    # signal_analyzer=None,
    attenuation_ports=[
        _attenuator_1.attenuator_ports[1],
        _attenuator_1.attenuator_ports[2],
        _attenuator_0.attenuator_ports[2],
    ],
)

_ru_0_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit2, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=2),
    )
]

_ru_1 = RU(
    ru_hw_group="AZQW",
    radio_type="AZQW",
    serial_number="AH220101616",
    attenuation_ports=[
        _attenuator_1.attenuator_ports[5],
        _attenuator_1.attenuator_ports[6],
        _attenuator_1.attenuator_ports[7],
        _attenuator_1.attenuator_ports[8],
    ],

	    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.6", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.9.6", username="root", password="root"
    ),
    pdu_port=_ru_1_pdu.pdu_ports[4],
)

_ru_1_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit0, label="SFP", port_id=2),
        target=Endpoint(unit=_ru_1, label="SFP", port_id=1),
    )
]

_ru_2 = RU(
    ru_hw_group="AEQE",
    radio_type="AEQE",
    serial_number="1M203304681",
    attenuation_ports=[
        _attenuator_1.attenuator_ports[3],
        _attenuator_1.attenuator_ports[4],
        _attenuator_0.attenuator_ports[1],
    ],

	    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.9.10", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.9.10", username="root", password="root"
    ),
    pdu_port=_ru_2_pdu.pdu_ports[5],
)

_ru_2_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit1, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_2, label="SFP", port_id=2),
    )
]

#Multi_RU
_du = DU(airscale=_airscale,
         rus=[_ru_0, _ru_1, _ru_2],
         f1_m_ip_addr="10.69.53.14",
         cablinks=[_ru_0_cablinks, _ru_1_cablinks, _ru_2_cablinks],
)

_cu = CU(
    backhaul_site_oam_ip="10.69.53.14",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.69.53.14", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.69.53.14", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.69.53.14", vlan_id=None),
    x2u=NetworkAddress(v4="10.69.53.14", vlan_id=None),
    s1u=NetworkAddress(v4="10.69.53.14", vlan_id=None),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du],instance_id=37392, global_bts_id=37392)

# mifi
ue_config_path = os.path.join(_CFG_DIR, "TestData/mifi.yml")
if os.path.isfile(ue_config_path):
    with open(ue_config_path) as f:
        ue_config = yaml.load(f, Loader=yaml.FullLoader)
else:
    ue_config = ""

#huawei_mate40
_huawei1 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.143", username="noklab\guoqianqian", password="Nokia@123"
    ),
    serial_number="7TD5T21423000785",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei1"],
)

_huawei2 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.143", username="noklab\guoqianqian", password="Nokia@123"
    ),
    serial_number="7TD0221529001408",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "huawei1"],
)

# Qualcomm8350
_Qualcomm8350 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.143", username="noklab\guoqianqian", password="Nokia@123"
    ),
    serial_number="4035e192",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Qualcomm", "REAL_ANDROID_UE"],
)

# Reami_K50
_Reami_K50 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.69.53.143", username="noklab\guoqianqian", password="Nokia@123"
    ),
    serial_number="862104055416645",
    server_dir="/cygdrive/c/pyro_server",
    python_path="/cygdrive/c/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "Reami_K50"],
)

#ute vm not UE PC
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.69.53.199", username="ute", password="ute"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIL_ABIP_AEQQ",
    ues=[_huawei1, _huawei2, _Reami_K50, _Qualcomm8350],
    #enbs=[_lte_real_enb],
	appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=[_attenuator_0, _attenuator_1],
)

__all__ = ["tl"]