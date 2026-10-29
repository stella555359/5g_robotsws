import os

from taf.config.testline import SshServiceDetails, HttpConnectionDetails

__maintainer__ = "Barbier Jean-Michel"
__team__ = "MN 5G RAN I&V 1 Pz 1 SG"
__email__ = "I_UTE_NPS_5G@internal.nsn.com"

from taf.config.testline.testpc import TestPc
from taf.config.testline import RU, DU
from taf.config.testline.pdu import ATEN
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.airscale import CommonUnit, CapacityUnit, Airscale

_host = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.28.0.107", username="ute", password="ute"
    )
)

_gnb_pdu = ATEN(addr="10.14.58.118", port_numbers=[8])
_enb_pdu = ATEN(addr="TO_UPDATE", port_numbers=[8])
_ues_pdu = ATEN(addr="10.14.63.219", port_numbers=[5])
_ru_pdu = ATEN(addr="TO_UPDATE", port_numbers=[1])

_ru = RU(
    ru_hw_group="hw_group",
    radio_type="AAHF",
    default_ssh_connection_details=SshServiceDetails(
        addr="192.168.100.5", username="root", password="umniedziala"
    ),
    lmp_connection=SshServiceDetails(
        addr="10.14.48.241", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_ru_pdu.pdu_ports[1],
)

_du_lmp_connection = SshServiceDetails(
    addr="10.14.48.241", username="toor4nsn", password="oZPS0POrRieRtu"
)

_du_capacity_unit = CapacityUnit(
    addr="fsp1_c", hardware_type="ABIL", hardware_version="A101B1"
)

_du_common_unit_0 = CommonUnit(
    lmp_connection=_du_lmp_connection,
    capacity_units=[_du_capacity_unit],
    pdu_port=_gnb_pdu.pdu_ports[8],
    hardware_type="ASIK",
    hardware_version="A101",
)

_airscale = Airscale(common_units=[_du_common_unit_0])

_du = DU(airscale=_airscale, rus=[_ru])

_cu = CU(
    backhaul_site_oam_ip="10.14.48.241",
    oam_ssh_connection_details=SshServiceDetails(
        addr="10.14.48.241", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(addr="10.14.48.241"),
)

_classical_bts = ClassicalBts(cu=_cu, dus=[_du])

with open(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "ue_config_cv107.yml")
) as ta_ue_config:
    import yaml

    _ue_conf = yaml.load(ta_ue_config)

tl = TestLine(
    test_pc=_host,
    gnbs=[_classical_bts],
    ues=[_ue_conf],
    # tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA101B1")
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIKA101L_ABILA101B1_AAHF",
)

custom = {
    "UES_PDU_ADDR": "10.14.63.219",
    "UE_1_PDU_PORT": "5",
}

__all__ = ["tl"]
