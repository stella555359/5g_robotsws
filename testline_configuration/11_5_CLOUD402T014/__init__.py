import os
from collections import OrderedDict
from taf.config.testline.cloud_hosting import (
    ControlNode,
    NCIR,
    CloudDeployment,
    DeploymentFlavorStack,
    DeploymentNetworkStack,
    DeploymentVnfStack,
)
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.core import EPCSim, LTEEmuCore, PrismaCore
from taf.config.testline import RU, DU
from taf.config.testline.pdu import FACOM, PduPort, Pdu, EPC
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU, ClassicalBts
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.ue import (
    AirphoneCloud,
    Airphone,
    Prisma,
    TM500,
    Qualcomm,
    QualcommUeType,
    Android,
)  # added in taf.meta.5.4
from taf.config.testline import Enb, SimEnb, RealEnb, RadioModule, LTEEmuEnb, PrismaEnb
from taf.config.testline.attenuator import AttenuationPort, TopYoung
from taf.config.testline.radio import (
    RadioTypes,
    SCRadioTypes,
    RU,
    SC5GRadio,
    SC4GRadio,
    RadioModule,
)

__maintainer__ = "yuqiugang"
__team__ = "I_NSB_MN_5GSC_5GSW_ENG_AIC_SI_CN_PCI_GMS <I_NSB_MN_5GSC_5GSW_ENG_AIC_SI_CN_PCI@internal.nsn.com>"
__email__ = "qiugang.yu@nokia-sbell.com"


# common
__all__ = ["tl"]

_cfg_dir = os.path.dirname(os.path.abspath(__file__))

# #host
_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.57.167.113", username="ute", password="ute"
    )
)

# #Iperf
_appserver_ssh = SshServiceDetails(
    addr="10.57.252.108", username="root", password="APPpass"
)
_iperf = IperfDataTransferDetails(
    ssh_connection_details=_appserver_ssh,
    network_interface_address="10.57.252.108",
    iperf_path="/cygdrive/c/iperf",
)
# #UE
_android_0 = Android(
    ssh_connection_details=SshServiceDetails(
        addr="10.97.122.176", username="labadmin", password="L@badmin$"
    ),
    serial_number="c28eb6e0",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg",
    iperf_details=_iperf,
    capabilities=["ANDROID_UE0", "REAL_UE"],
)

# _attenuator = TopYoung('10.57.238.18', 3000, [1, 2, 3, 4], 'TAS16T16-51-120-1SDES')
_attenuator = TopYoung(
    ip_addr="10.97.122.175",
    port=5000,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8],
)

# Real 5G Core is used in real world.  here use EPCsim as the 5GC class is not implemented in tl config lib yet.
_epc_sim = EPCSim(
    mme_ip="10.110.149.102",
    mcc="262",
    mnc="3",
    tac="0",
    default_ssh_connection_details=SshServiceDetails(
        addr="10.110.149.10", username="hztester", password="Nokia_1234"
    ),
    edaemon_port=10000,
    egate_port=20000,
    dir_path="/opt/iphy/latest",
    cfg_filename="LRC.cfg",
)


# #5GRU
_ru_pdu = FACOM(addr="10.57.241.208", port_numbers=[2])

_ru = RU(
    ru_hw_group="Below6GHZ",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.52", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.254.52", username="user", password="pass"
    ),
    pdu_port=_ru_pdu.pdu_ports[2],
    radio_type=RadioTypes.AAHF,
    attenuation_ports=[
        _attenuator.attenuator_ports[6],
        _attenuator.attenuator_ports[7],
    ],
)

# #DU
# _lmp_connection = SshServiceDetails(addr='10.57.228.6', username='toor4nsn', password='oZPS0POrRieRtu')

_capacity_unit = CapacityUnit(addr="192.168.253.22")

_gnb_pdu = FACOM(addr="10.57.241.205", port_numbers=[2])

_common_unit_0 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.97.121.18", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[2],
)


_airscale = Airscale(common_units=[_common_unit_0])


_du = DU(airscale=_airscale, rus=[_ru])


##cu
_cu = CU(
    backhaul_site_oam_ip="10.97.121.18",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.97.121.18", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.97.121.18", username="Nemuadmin", password="nemuuser"
    ),
)


_cu4g = CU(
    backhaul_site_oam_ip="10.97.122.144",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.97.122.144", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.97.122.144", username="Nemuadmin", password="nemuuser"
    ),
)

# _cbts
_cbts = ClassicalBts(dus=[_du], cu=_cu, instance_id=3006)


# #DU
# _lmp_connection = SshServiceDetails(addr='10.57.228.6', username='toor4nsn', password='oZPS0POrRieRtu')

# _capacity_unit = CapacityUnit(addr='6.6.6.6')

_gnb_pdu_4g = FACOM(addr="10.69.23.66", port_numbers=[8])

_common_unit_0_4g = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="10.97.122.144", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=None,
    pdu_port=_gnb_pdu_4g.pdu_ports[8],
)

_airscale4g = Airscale(common_units=[_common_unit_0_4g])


_du4g = DU(airscale=_airscale4g, rus=None)

##cu
_cu4g = CU(
    backhaul_site_oam_ip="10.97.122.144",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.97.122.144", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="10.97.122.144", username="Nemuadmin", password="nemuuser"
    ),
)

# _cbts4g
_cbts4g = ClassicalBts(dus=[_du4g], cu=_cu4g, instance_id=4621)


##cloud_topology
_tl_cloud_topology = "CLOUD_5G_BB3"

tl = TestLine(
    test_pc=_host,
    gnbs=[_cbts, _cbts4g],
    core=_epc_sim,
    ues=[_android_0],
    tl_cloud_topology=_tl_cloud_topology,
    attenuator=[_attenuator],
)
