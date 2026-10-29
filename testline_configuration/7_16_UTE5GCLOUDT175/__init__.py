__maintainer__ = "Sergiu Bobeica"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "sergiu.bobeica@nokia.com"
__owner_email__ = "sergiu.bobeica@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.ue import Android
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline import RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.pdu import Gude
from taf.config.testline.attenuator import JFW

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.176", username="ute", password="ute"
    )
)

_pdu1 = Gude(addr="10.42.61.167", port_numbers=[1, 2, 5], model="EPC", version="8221-1")

_pdu2 = Gude(addr="10.44.206.13", port_numbers=[11, 12], model="EPC", version="8221-1")

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu2.pdu_ports[12],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.68.137",
        vlan_id=903,
        routing=RoutingInformation(gateway="10.44.68.129/26"),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    f1m=None,
    f1c=None,
    f1u=None,
    x2c=NetworkAddress(
        v4="10.44.68.201",
        vlan_id=904,
        routing=RoutingInformation(gateway="10.44.68.193/26"),
    ),
    x2u=NetworkAddress(
        v4="10.44.70.9",
        vlan_id=905,
        routing=RoutingInformation(gateway="10.44.70.1/26"),
    ),
    s1u=NetworkAddress(
        v4="10.44.70.73",
        vlan_id=906,
        routing=RoutingInformation(gateway="10.44.70.65/26"),
    ),
)

_cu.sync = NetworkAddress(
    v4="10.44.70.137",
    vlan_id=907,
    routing=RoutingInformation(gateway="10.44.70.129/26"),
)

_ru_1 = RU(
    ru_hw_group="hw_group",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu1.pdu_ports[2],
)

_ru_2 = RU(
    ru_hw_group="hw_group",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu1.pdu_ports[5],
)

_ru_3 = RU(
    ru_hw_group="hw_group",
    radio_type="AHLOA",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(
        addr="TO_UPDATE", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu1.pdu_ports[1],
)


_du = DU(_airscale, rus=[_ru_1, _ru_2, _ru_3])

_classical_bts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50046, instance_id=50046)

_core = RealCore5G(mcc=555, mnc=10)

_core_ssh = SshServiceDetails(addr="10.44.156.176", username="ute", password="ute")

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_capacity_unit = CapacityUnit(addr="192.168.253.20")

_common_unit_lte = CommonUnit(
    _common_unit_lte_ssh, capacity_units=[_capacity_unit], pdu_port=_pdu2.pdu_ports[11]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lteenb = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.79.10",
        vlan_id=910,
        routing=RoutingInformation(gateway="10.44.79.1/26"),
    ),
    global_bts_id=40069,
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.175", username="ute", password="ute"
    ),
    connections=[_lteenb],
)

_iperf_ue = IperfDataTransferDetails(
    ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    ),
    network_interface_address="10.42.197.170",
    iperf_path="/data/data/com.magicandroidapps.iperf/bin/iperf",
)

_ue_pc_ssh = SshServiceDetails("10.42.22.157", "sranwro1", password="Welcomewro1")

# _android_ue = Android(
#     ssh_connection_details=_ue_pc_ssh,
#     serial_number='7bbaefa',
#     server_dir='/cygdrive/c/pyro_server/ta_ue_plugin_android/ue',
#     python_path='C:/Python27/python.exe',
#     qcat_path='C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe',
#     diag_cfg_path='C:/pyro_server/DIAG.cfg',
#     imsi='555106900020069',
#     iperf_details=_iperf_ue
# )

_attenuator = JFW(
    ip_addr="10.42.54.118",
    port=3001,
    attenuation_port_numbers=range(1, 17),
    model="TAS_16T16_0_2G6_90_1S_DEJS",
)

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "askey_ue.yaml"
)

tl = TestLine(
    test_pc=_test_pc,
    test_pcs=[_test_pc, _test_pc_enb],
    gnbs=[_classical_bts],
    enbs=[_lteenb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AHLOA_ENB",
    core=_core,
    ues=[_qualcomm_ue],
    attenuator=_attenuator,
)

__all__ = ["tl"]
