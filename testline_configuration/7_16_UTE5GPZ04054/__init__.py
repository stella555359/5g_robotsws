__maintainer__ = "Adam Mazik"
__team__ = "DCM"
__email__ = "adam.mazik@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import ATEN, Gude, EPC


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.200.70", port_numbers=[1, 2], model="EPC", version="8221-1")

_abio_gnb_primary_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1213108442",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_primary_1],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1232304340",
    pdu_port=_pdu_gnb.pdu_ports[1],
)

_abio_gnb_secondary_1 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214206794",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_secondary_1],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1211204410",
    pdu_port=_pdu_gnb.pdu_ports[2],
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.115", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.115", username="ute", password="ute"
    ),
    connections=[_asil_gnb_secondary],
)

_airscale_gnb_1 = Airscale([_asil_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    pdus=[_pdu_gnb],
)

setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.75.115")

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.128")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "admin")

setattr(tl, "specific_convert_mmt_dir", "/cygdrive/c/ute/MMT")

setattr(tl, "enable_af_ssh_reset_WA", "no")
setattr(tl, "enb_type", "lrc")
setattr(tl, 'gnb_id_list', [1])
setattr(tl, "windows_control_pc_user", "ute")
setattr(tl, "windows_control_pc_pwd", "ute")
setattr(tl, 'oam_http_addr', '192.168.255.129')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')
setattr(tl, "ute_control_pc_host", "10.42.75.115")
setattr(tl, "gnb_control_pc_host", ["10.42.75.115"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.42.75.115")
setattr(tl, "l3sim_host", "10.42.75.115")
