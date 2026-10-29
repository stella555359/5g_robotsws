__maintainer__ = "Maciej Charytoniuk"
__team__ = "5G_PZ_2_WRO_6_SG"
__email__ = "maciej.charytoniuk@nokia.com"
__owner_email__ = "maciej.charytoniuk@nokia.com"

import os
from taf.config.testline import (
    DU,
    RU,
    RealEnb,
    IperfDataTransferDetails,
    NetworkAddress,
    RoutingInformation,
)
from taf.config.testline.testline import TestLine
from taf.config.testline.appserver import AppServer
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN


def get_scf_name():
    from shutil import copyfile

    cfg_dir = os.path.dirname(os.path.abspath(__file__))
    txt = "{path}/{scf}".format(path=cfg_dir, scf="7_16_UTE5GCLOUDT114.txt")
    xml = "{path}/{scf}".format(path=cfg_dir, scf="7_16_UTE5GCLOUDT114.xml")
    copyfile(txt, xml)
    return xml


testline_scf = get_scf_name()

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.48", username="ute", password="ute"
    )
)

_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.156.49", username="ute", password="ute"
    )
)

_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    )
)

_viavi_appserver = AppServer(
    IperfDataTransferDetails(
        ssh_connection_details=SshServiceDetails(
            addr="10.42.61.2", username="ute", password="ute"
        ),
        network_interface_address="",
        iperf_path="iperf",
    )
)

_pdu1 = ATEN(addr="10.44.206.129", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])
_pdus = [_pdu1]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loner],
    pdu_port=_pdu1.pdu_ports[1],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip=NetworkAddress(v4="192.168.255.129", vlan_id=834),
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
        v4="10.44.80.218",
        v6="2a00:8a00:6000:607c::563f",
        vlan_id=455,
        routing=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    x2u=NetworkAddress(
        v4="10.44.64.151",
        v6="2a00:8a00:6000:607c::5734",
        vlan_id=456,
        routing=RoutingInformation(gateway="10.44.64.129", ip_prefix_length=26),
    ),
    s1u=NetworkAddress(
        v4="10.44.64.205",
        v6="2a00:8a00:6000:607c::5834",
        vlan_id=457,
        routing=RoutingInformation(gateway="10.44.64.193", ip_prefix_length=26),
    ),
)

_cu.m = NetworkAddress(
    v4="10.44.80.156",
    v6="2a00:8a00:6000:607c::553f",
    vlan_id=454,
    routing=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
)

_cu.sync = NetworkAddress(
    v4="10.44.65.13",
    v6="2a00:8a00:6000:607c::5933",
    vlan_id=458,
    routing=RoutingInformation(gateway="10.44.65.1", ip_prefix_length=26),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    ru_hw_group="",
    radio_type="AEUB",
)

_du = DU(airscale=_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du], global_bts_id=1)

_core = RealCore5G(mcc=555, mnc=10)


def _adapt_path_from_yml(_ue):
    for k, v in _ue["UE_POOLS"]["ViaviUePool"].items():
        value = v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["radio_card_config"]
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["radio_card_config"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), value
        )
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["attach"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["attach"],
        )
        v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["detach"] = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            v["CONSTRUCTOR_PARAMETERS"]["script_paths"]["detach"],
        )
    return _ue


with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "viavi_config.yml")
) as ue_config:
    import yaml

    _ue = _adapt_path_from_yml(yaml.load(ue_config, yaml.SafeLoader))

_common_unit_lte_ssh = SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
)

_common_unit_lte = CommonUnit(
    lmp_connection=_common_unit_lte_ssh, capacity_units=[_abil_loner]
)

_abia = CapacityUnit(addr="192.168.253.20")

_asia = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia],
)

_lte = RealEnb(
    airscale=Airscale(common_units=[_asia]),
    x2_link_addr=NetworkAddress(
        v4="10.44.80.219",
        v6="2a00:8a00:6000:607c::5640",
        vlan_id=455,
        routing=RoutingInformation(gateway="10.44.80.193", ip_prefix_length=26),
    ),
    global_bts_id=40055,
)

_lte.m = NetworkAddress(
    v4="10.44.80.157",
    v6="2a00:8a00:6000:607c::5540",
    vlan_id=454,
    routing=RoutingInformation(gateway="10.44.80.1", ip_prefix_length=26),
)

tl = TestLine(
    test_pc=_test_pc,
    tl_cloud_topology="CLOUD_5G_CLASSICAL_VIAVI_ASIKL_ABILB1_AEUB_ENB_BRANCH",
    gnbs=[_cbts],
    enbs=[_lte],
    core=_core,
    pdus=_pdus,
    ues=[_ue],
    appserver=_viavi_appserver,
    test_pcs=[_lte_test_pc, _realcore_appsrv],
)

__all__ = ["tl"]
