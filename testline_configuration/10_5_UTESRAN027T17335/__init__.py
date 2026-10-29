__maintainer__ = "Jim.3.Liu"
__team__ = "NSB MN SRAN Prod HZH RRM 3 Vrf"
__email__ = "jim.3.liu@nokia-sbell.com"


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
from taf.config.testline.enb import (
    RealEnb
)
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
    addr="10.69.4.46", username="rrm2-tester", password="Nokia123!", port="54015"
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
    addr="10.56.201.211", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIL",
)

_gnb_pdu = FACOM(addr="10.56.201.151", port_numbers=[3])

_common_unit_0 = CommonUnit(
    lmp_connection=_lmp_connection,
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[3],
    hardware_type="ASIK"
)

_airscale = Airscale([_common_unit_0])


# RealEnb
_real_enb_pdu = FACOM(addr="10.56.201.151", port_numbers=[3])

_common_unit_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.56.201.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[],
    pdu_port=_real_enb_pdu.pdu_ports[3],
    hardware_type="ASIL"
)

_real_enb = Airscale(common_units=[_common_unit_2])


_lte_real_enb = RealEnb(airscale=_real_enb, rms=None)

# attenuator
_attenuator = HBTE(
    ip_addr="10.56.201.152",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    model="TAS16T16-51-120-1S-DES",
)

# 5GRU for classicalBTS
_ru_0_pdu = FACOM(addr="10.56.201.151", port_numbers=[4])

_ru_0 = RU(
    ru_hw_group="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.50.2", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(
        addr="172.22.50.2", username="root", password="root"
    ),
    pdu_port=_ru_0_pdu.pdu_ports[4],
    radio_type="AHLOA",
    # signal_analyzer=None,
    attenuation_ports=[
        _attenuator.attenuator_ports[1],
        _attenuator.attenuator_ports[2],
        _attenuator.attenuator_ports[3],
        _attenuator.attenuator_ports[4],
        _attenuator.attenuator_ports[5],
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
        _attenuator.attenuator_ports[8],
        _attenuator.attenuator_ports[9],
        _attenuator.attenuator_ports[10],
        _attenuator.attenuator_ports[11],
        _attenuator.attenuator_ports[12],
        _attenuator.attenuator_ports[13],
        _attenuator.attenuator_ports[14],
        _attenuator.attenuator_ports[15],
        _attenuator.attenuator_ports[16],
    ],
    serial_number=None,
)

_ru_cablinks = [
    Cablink(
        source=Endpoint(unit=_capacity_unit, label="SFP", port_id=1),
        target=Endpoint(unit=_ru_0, label="SFP", port_id=1),
    )
]

_du = DU(airscale=_airscale,
         rus=[_ru_0],
         f1_m_ip_addr="10.69.4.4",
         cablinks=_ru_cablinks,
)

_cu = CU(
    backhaul_site_oam_ip="10.56.201.211",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.56.201.211", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.56.201.211", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.56.201.211", vlan_id=None),
    x2u=NetworkAddress(v4="10.56.201.211", vlan_id=None),
    s1u=NetworkAddress(v4="10.56.201.211", vlan_id=None),
)

_cbts = ClassicalBts(cu=_cu, dus=[_du],instance_id=37096, global_bts_id=37096)

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
        addr="10.56.202.134", username="five-tester", password="Nokia123!"
    ),
    serial_number="R5CN20BJXTL",
    server_dir="C:\cygwin64",
    python_path="C:/Users/five-tester/AppData/Local/Programs/Python/Python39/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "RRM2_S20"],
)

_android = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.56.202.134", username="five-tester", password="Nokia123!"
    ),
    serial_number="9YS0220730009229",
    server_dir="C:\cygwin64",
    python_path="C:/Users/five-tester/AppData/Local/Programs/Python/Python39/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["Commercial", "RRM2_HUAWEI"],
)

# #host
_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.56.198.65", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], ue_config],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIK_ABIL_3xAHLOA",
    ues=[ue_config],
    enbs=[_lte_real_enb],
    appserver=_appserver,
    core=RealCore(mcc=262, mnc=3),
    attenuator=_attenuator,
)

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
tl_ultracaller = os.path.join(_CFG_DIR, "uc_config.yaml")

__all__ = ["tl", "tl_ultracaller"]