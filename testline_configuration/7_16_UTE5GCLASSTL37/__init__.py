__maintainer__ = "Sylwia Pawlak"
__team__ = "MN RAN RD VRF WRO1 4"
__email__ = "sylwia.pawlak@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    IperfDataTransferDetails,
    IperfDataTransferIperfOptions,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline import RealEnb, Leoni, SwitchChannel, SwitchModule
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude, ATEN
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.ue import TafUeAndroid
from taf.config.testline.appserver import TafUeAppServer
from taf.config.testline.taf_ue_data_transfer_protocol import TafUeDataTransferProtocol
from taf.config.testline.ue import Android
import os


__all__ = ["tl"]

_pdu = Gude(addr="10.44.177.72", port_numbers=[3, 10], model="EPC", version="8221-1")
_pdu_rmod_nr_1 = Gude(
    addr="10.44.177.72", port_numbers=[1], model="EPC", version="8221-1")
_pdu_rmod_nr_2 = Gude(
    addr="10.44.177.56", port_numbers=[11], model="EPC", version="8221-1")
# _pdu_rmod_lte = Gude(
#     addr="10.44.177.45", port_numbers=[4], model="EPC", version="8221-1")
_pdu_shieldbox = Gude(
    addr="10.44.177.72", port_numbers=[6], model="EPC", version="8221-1")

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.45.178.207", v6=None, vlan_id=852),
    x2u=NetworkAddress(v4="10.45.178.143", v6=None, vlan_id=853),
    s1u=NetworkAddress(v4="10.45.178.207", v6=None, vlan_id=854),
)

_gnb_ru_1 = RU(
    radio_type="AHFIB",
    ru_hw_group="",
    serial_number="BL1945V00HE",
    default_ssh_connection_details = SshServiceDetails(
        addr="172.16.81.133",
        username="rfsw",
        password="0q/7SXKjF2AlAba+yisrCxQiKz1PRJJ0IVDZuh/sOaA=",
    ),

    pdu_port=_pdu_rmod_nr_1.pdu_ports[1],
)

_gnb_ru_2 = RU(
    radio_type="AZHM",
    ru_hw_group="",
    serial_number="4H211430008",
    default_ssh_connection_details=SshServiceDetails(
        addr="",
        username="serviceuser",
        password="wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=",
    ),
    pdu_port=_pdu_rmod_nr_2.pdu_ports[11],
)
# # 4G radio units
# _ru_lte = RU(
#     radio_type="FXFB",
#     ru_hw_group="",
#     serial_number="L1130507333",
#     pdu_port=_pdu_rmod_lte.pdu_ports[4],
# )

# Baseband modules
_capacity_unit_nr_1 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1183608773",
)
_capacity_unit_nr_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIL",
    hardware_version="A.102",
    serial_number="L1190611724",
)
_capacity_unit_nr_3 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIN",
    hardware_version="A.102",
    serial_number="L1214511933",
)

# _capacity_unit_lte_1 = CapacityUnit(
#     addr="192.168.253.21",
#     hardware_type="ABIA",
#     hardware_version="A.103",
#     serial_number="EA190880426",
# )

_asib = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_capacity_unit_nr_1, _capacity_unit_nr_2, _capacity_unit_nr_3],
    pdu_port=_pdu.pdu_ports[10],
    hardware_type="ASIB",
    serial_number="DH203662589",
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.41", username="ute", password="ute"
    ),
    connections=[_asib],
)

_airscale_gnb_1 = Airscale(common_units=[_asib])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_gnb_ru_1,_gnb_ru_2])

# _abia_enb_1 = CapacityUnit(
#     addr="192.168.253.21", hardware_type="ABIA", serial_number="EA190880426"
# )

# _asia_enb_1 = CommonUnit(
#     lmp_connection=SshServiceDetails(
#         addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
#     ),
#     capacity_units=[_abia_enb_1],
#     hardware_type="ASIA",
#     pdu_port=_pdu.pdu_ports[3],
#     serial_number="L1172903287",
# )


# _airscale_enb_1 = Airscale(common_units=[_asia_enb_1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=50447, instance_id=50447
)

_core = RealCore5G()

# _enb_1 = RealEnb(
#     airscale=_airscale_enb_1,
#     system_module=_airscale_enb_1,
#     rms=[_ru_lte],
#     global_bts_id=40447,
#     instance_id=40447,
#     oam_ip=NetworkAddress(v4="10.45.179.141"),
# )

# _lmp_vm_enb_1 = TestPc(
#     default_ssh_connection_details=SshServiceDetails(
#         addr="10.44.149.42", username="ute", password="ute"
#     ),
#     connections=[_enb_1],
# )

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts],
#    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_4xASKEY_ASIBL_2xABILL_ABIN_AHFIB_AZHM",
    core=_core,
    pdus=[_pdu, _pdu_rmod_nr_1, _pdu_rmod_nr_2],
)