__maintainer__ = "Pawel Wisniewski"
__team__ = "MN 5G&SC 5G Pz 2 WRO 7 SG"
__email__ = "pawel.1.wisniewski@nokia.com"
__owner_email__ = "spatrycja.lis@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.attenuator import JFW
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline import NetworkAddress, RoutingInformation
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb
from taf.config.testline.pdu import Gude
from taf.config.testline.flexi import Flexi
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline import TafUeDataTransferProtocol
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.fhs import FHS, FhsType

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_qualcomm_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ues.yaml"
)

# VMs
_test_pc_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.236", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

_test_pc_enb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.35", username="ute", password="ute"
    ),
    connections=[NetworkAddress(v4="192.168.255.126")],
)

# LTE
_pdu1 = Gude(
    addr="10.44.205.247", port_numbers=[11], model="EPC", version="8221-1"
)
# RUs 5G
_pdu2 = Gude(
    addr="10.44.177.62", port_numbers=[1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8221-1"
)

# AHCA_WALL_40860
_pdu3 = Gude(
    addr="10.44.177.96", port_numbers=[5, 4], model="EPC", version="8221-1"
)

# FRHB / AHGA
_pdu4 = Gude(
    addr="10.44.205.248", port_numbers=[7, 8], model="EPC", version="8221-1"
)

# 5G ASIL
_pdu5 = Gude(
    addr="10.42.61.167", port_numbers=[5], model="EPC", version="8221-1"
)

_pdu6 = Gude(
    addr="10.44.200.93", port_numbers=[1], model="EPC", version="8041-1"
)

_pdus = [_pdu1, _pdu2, _pdu3, _pdu4, _pdu5, _pdu6]

_app_server_1 = TafUeAppServer(
    app_server_name="APP_1",
    address="10.42.61.65",
    user="5g",
    password="2019H@slo",
    bind_interface_ip="10.42.197.170",
    expected_prompt="dummy_prompt",
)

_data_transfer_iperf_1 = TafUeDataTransferProtocol(
    protocol_name="iperf", app_server=_app_server_1, interval=1, version=3  # OPTIONAL
)  # OPTIONAL

_ue = TafUeAndroid(
    serial_number="R3CW30ACGQP",
    capabilities=["REAL_UE", "nokia", "UUF_L3CALL"],
    ue_pc_address="10.42.224.65",
    data_transfer=[_data_transfer_iperf_1],
    ssh_connection_details=SshServiceDetails(
        addr="10.42.22.157", username="wro5grrm", password="5gpass!1"
    ),
    qualcomm_prototype=True,
)

_CELL_MAP = {
    541: {"att_alias": "att_1", "att_ports": [1]},
    542: {"att_alias": "att_1", "att_ports": [2]},
    543: {"att_alias": "att_1", "att_ports": [3]},
    545: {"att_alias": "att_1", "att_ports": [4]},
    546: {"att_alias": "att_1", "att_ports": [5]},
    547: {"att_alias": "att_1", "att_ports": [6]},
    548: {"att_alias": "att_1", "att_ports": [7]},
    550: {"att_alias": "att_1", "att_ports": [9]},
    551: {"att_alias": "att_1", "att_ports": [10]},
    544: {"att_alias": "att_1", "att_ports": [11, 12, 13, 14]},
    540: {"att_alias": "att_1", "att_ports": [15, 16, 17, 18]},
    444: {"att_alias": "att_1", "att_ports": [19, 20]},  # enb
    440: {"att_alias": "att_1", "att_ports": [21, 22]},  # enb
    442: {"att_alias": "att_1", "att_ports": [23, 24]},  # enb
}

_attenuator = JFW(
    ip_addr="10.42.54.161",
    port=3001,
    attenuation_port_numbers=range(1, 25),
)

_ru_1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
        pdu_port=_pdu2.pdu_ports[7],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_2 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.6", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[1],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_3 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.10", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[2],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_4 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.154", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[11],
    ru_hw_group="",
    radio_type="FRGY",
)

_ru_5 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.158", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[5],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_6 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[10],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_7 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.2", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[6],
    ru_hw_group="",
    radio_type="AEQN",
)

_ru_8 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.6", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[8],
    ru_hw_group="",
    radio_type="FRGY",
)

_ru_9 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.10", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu6.pdu_ports[1],
    ru_hw_group="",
    radio_type="FRGY",
)

_ru_10 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.158", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_11 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[12],
    ru_hw_group="",
    radio_type="AEQY",
)

_ru_1_enb = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    pdu_port=_pdu3.pdu_ports[5],
    radio_type="AHCA",
)

_ru_2_enb = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    pdu_port=_pdu4.pdu_ports[8],
    radio_type="FRHB",
)

_ru_3_enb = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.57.162", username="root", password=""
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    pdu_port=_pdu4.pdu_ports[7],
    radio_type="AHGA",
)

# FHSes
_fhs_enb = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu3.pdu_ports[4],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="YY221310261",
    product_code="473922A.102",
    rus=[_ru_1_enb, _ru_2_enb, _ru_3_enb],
)

_fhs_gnb = FHS(
    fhs_type=FhsType.MDCD.value,
    pdu_port=_pdu2.pdu_ports[3],
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.37.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    lmp_connection=SshServiceDetails(
        addr="192.168.255.124", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    optical_switch_channels=None,
    serial_number="6Q203706844",
    product_code="473922A.102",
    rus=[_ru_4, _ru_8, _ru_9],
)

# * BBMOD *
_abio_1 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5]
)

_abio_2 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    rus=[_ru_6, _ru_7, _ru_8, _ru_11]
)

_abio_3 = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    rus=[_ru_9, _ru_10],
    fhs=[_fhs_gnb]
)

_abio_1_lte = CapacityUnit(
    addr="",
    hardware_type="ABIO",
    rus=[_ru_1_enb, _ru_2_enb, _ru_3_enb],
    fhs=[_fhs_enb]
)

# * SMOD *
_asim_gnb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    pdu_port=_pdu5.pdu_ports[5],
    capacity_units=[_abio_1, _abio_2, _abio_3]
)

_asia_enb = CommonUnit(
    SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    pdu_port=_pdu1.pdu_ports[11],
    capacity_units=[_abio_1_lte]
)

_smod_gnb = Flexi([_asim_gnb])
_smod_enb = Flexi([_asia_enb])


_cu_smod_gnb = CU(backhaul_site_oam_ip=NetworkAddress(v4="10.44.70.205"),
                  oam_ssh_connection_details=SshServiceDetails(addr='192.168.255.129',
                                                               username='toor4nsn', password='oZPS0POrRieRtu'),
                  oam_http_connection_details=HttpConnectionDetails(addr='192.168.255.129',
                                                                    username='Nemuadmin', password='nemuuser'))

_du_smod_gnb = DU(airscale=Airscale([_asim_gnb]), rus=[_ru_1, _ru_2, _ru_3, _ru_6, _ru_7, _ru_8, _ru_9, _ru_10])

_gnb_nr_1 = ClassicalBts(cu=_cu_smod_gnb, dus=[_du_smod_gnb], instance_id=50804)
_test_pc_gnb_1.connections.append(Connection(interface="eth1",
                                             device=_gnb_nr_1.dus[0].airscale.common_units[0], interface_type="lmp"))

_enb_sbts = RealEnb(
    system_module=_smod_enb,
    rms=[_ru_1_enb, _ru_2_enb, _ru_3_enb],
    oam_ip=NetworkAddress("10.45.178.13"),
    global_bts_id=40860,
    instance_id=40860,
)

_enb_sbts.m = NetworkAddress(v4="10.45.178.13")
_enb_sbts.x2_link_addr = NetworkAddress(v4="10.45.178.13")

_test_pc_enb.connections.append(_enb_sbts.system_module.common_units[0])


tl = TestLine(
    test_pc=_test_pc_enb,
    test_pcs=[_test_pc_gnb_1, _test_pc_enb],
    gnbs=[_gnb_nr_1],
    enbs=[_enb_sbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASILR_ABIOB1B2_2xFBBC_FSMF_4xAEQN_8xAEQY_FRCG_FRHB_FRGY",
    ues=[_ue],
    attenuator=[_attenuator],
    pdus=_pdus,
)

tl.CELL_MAP = _CELL_MAP

__all__ = ["tl"]
