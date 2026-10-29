__maintainer__ = "Tomasz Makowski"
__team__ = "RRM team"
__email__ = "tomasz.makowski@nokia.com"
__owner_email__ = "tomasz.makowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.enb import RealEnb
from taf.config.testline.pdu import ATEN, EPC
from taf.config.testline.core import RealCore5G

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.53.76", username="ute", password="ute"
    )
)


_lte_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.209.95", username="ute", password="ute"
    )
)


_realcore_appsrv = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.65", username="5g", password="2019H@slo"
    )
)


_core = RealCore5G(mcc=555, mnc=10)


_pdu1 = ATEN(addr="10.42.61.78", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])

_pdu2 = EPC(addr="10.42.61.241", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12])

_pdus = [_pdu1, _pdu2]

_abil_master = CapacityUnit(addr="192.168.253.20")
_abil_slave = CapacityUnit(addr="192.168.253.21")
_abil_loaner = CapacityUnit(addr="192.168.253.22")

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abil_master, _abil_slave, _abil_loaner],
    pdu_port=_pdu1.pdu_ports[8],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
)

_ru = RU(
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.254.34", username="root", password="root"
    ),
    lmp_connection=SshServiceDetails(addr="", username=""),
    pdu_port=_pdu2.pdu_ports[10],
    ru_hw_group="",
    radio_type="AEQN",
)

_du = DU(_airscale, rus=[_ru])

_cbts = ClassicalBts(cu=_cu, dus=[_du])


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
    _common_unit_lte_ssh, capacity_units=[_abil_loaner], pdu_port=_pdu1.pdu_ports[6]
)

_lteenb = RealEnb(airscale=_airscale, x2_link_addr="10.1.1.110")

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_VIAVI_ASIKA101L_ABILA102B1_AEQN_BRANCH",
    core=_core,
    pdus=_pdus,
    enbs=[_lteenb],
    ues=[_ue],
    test_pcs=[_lte_test_pc, _realcore_appsrv],
)


__all__ = ["tl"]
