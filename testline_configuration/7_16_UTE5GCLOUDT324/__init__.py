__maintainer__ = "Rafal Kaczmarski"
__team__ = "RRM team"
__email__ = "rafal.kaczmarski@nokia.com"
__owner_email__ = "rafal.kaczmarski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, RealEnb, NetworkAddress, RoutingInformation
from taf.config.testline.core import RealCore5G
from taf.config.testline.attenuator import TopYoung
from taf.config.testline.pdu import Gude
from taf.config.testline.ue import Android

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    )
)

_core = RealCore5G(mcc=540, mnc=1)

_pdu1 = Gude(
    addr="10.44.205.87",
    port_numbers=[6],
    model="EPC",
    version="8221-1",
)

_pdu2 = Gude(
    addr="10.44.205.116",
    port_numbers=[9],
    model="EPC",
    version="8221-1",
)

_pdus = [_pdu1, _pdu2]


_abil_master = CapacityUnit(addr="fd5f:4268:2387:a881:0040:43ff:fe80:1101")
_abil_slave = CapacityUnit(addr="fd5f:4268:2387:a881:0040:43ff:fe80:1106")
_abil_loner = CapacityUnit(addr="fd5f:4268:2387:a881:0040:43ff:fe80:110b")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[6],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(
        v4="10.44.224.42",
        v6="2a00:8a00:6000:607c::2a2a",
        vlan_id=915,
        routing_v4=RoutingInformation(gateway="10.44.224.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2a01", ip_prefix_length=120
        ),
    ),
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(
        v4="10.44.224.106",
        v6="2a00:8a00:6000:607c::2b2a",
        vlan_id=916,
        routing_v4=RoutingInformation(gateway="10.44.224.65", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2b01", ip_prefix_length=120
        ),
    ),
    x2u=NetworkAddress(
        v4="10.44.224.170",
        v6="2a00:8a00:6000:607c::2c2a",
        vlan_id=917,
        routing_v4=RoutingInformation(gateway="10.44.224.129", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2c01", ip_prefix_length=120
        ),
    ),
    s1u=NetworkAddress(
        v4="10.44.224.234",
        v6="2a00:8a00:6000:607c::2d2a",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.224.193", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01", ip_prefix_length=120
        ),
    ),
    ngu=NetworkAddress(
        v4="10.44.224.234",
        v6="2a00:8a00:6000:607c::2d2a",
        vlan_id=918,
        routing_v4=RoutingInformation(gateway="10.44.225.1", ip_prefix_length=26),
        routing_v6=RoutingInformation(
            gateway="2a00:8a00:6000:607c::2d01", ip_prefix_length=120
        ),
    ),
)

_ru1 = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.56.162", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[9],
    ru_hw_group="",
    radio_type="AHFIC",
)

_du = DU(_airscale, rus=[_ru1])

_cbts_1 = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=50848, instance_id=50848)

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(_common_unit_lte_ssh, capacity_units=[_abil_loner])

_attenuator = TopYoung(
    ip_addr="10.42.54.195",
    port=3001,
    attenuation_port_numbers=[1, 2, 3, 4, 5, 6]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.178.82", username="ute", password="ute"
    ),
    connections=[_cbts_1],
)

_ue_pc_ssh = SshServiceDetails("10.42.22.77", "wro5grrm", password="5gpass!1")

_android_ue = os.environ["ABSTRACT_LIB_CONFIG"] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "ue_config.yaml"
)

_android_ue_1 = Android(
    ssh_connection_details=_ue_pc_ssh,
    serial_number="7ed81c7f",
    server_dir="/cygdrive/c/pyro_server",
    python_path="C:/Python27/python.exe",
    qcat_path="C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe",
    diag_cfg_path="C:/pyro_server/DIAG.cfg.txt",
    imsi="555109900000554",
    diag_com="COM9",
    dmc_path="c:/Users/wro5grrm.NOKLAB/Desktop/MCS.dmc",
    licensekeeper="/cygdrive/c/QPM_LK1.5.1",
    iperf_directory="/data/data/com.nokia.android.application/",
)

tl = TestLine(
    test_pc=[_lmp_vm_gnb_1],
    gnbs=[_cbts_1],
    enbs=[],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ANDROID_ASIBR_ABIOB4_AHFIC",
    core=_core,
    pdus=_pdus,
    attenuator=_attenuator,
    test_pcs=[_realcore_appsrv],
    ues=[_android_ue, _android_ue_1],
)

__all__ = ["tl"]

