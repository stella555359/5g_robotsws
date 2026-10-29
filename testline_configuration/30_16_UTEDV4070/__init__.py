__maintainer__ = "Sebastian Kupisiewicz"
__team__ = "DCM"
__email__ = "sebastian.kupisiewicz@nokia.com"

from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU
from taf.config.testline.pdu import Gude

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

_pdu_gnb = Gude(addr="10.44.200.72", port_numbers=[10, 11], model="EPC", version="8220-1")
_pdu_apo = Gude(addr="10.44.200.72", port_numbers=[9], model="EPC", version="8220-1")

ru1 = RU(
    radio_type="TA24395-B20X",
    ru_hw_group="Simulated_RU",
    serial_number="00002472",
)

_abio_gnb_primary_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214610524",
)

_abio_gnb_primary_2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1240601617",
)

_abio_gnb_primary_3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214206804",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_primary_1, _abio_gnb_primary_2, _abio_gnb_primary_3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1213613017",
    pdu_port=_pdu_gnb.pdu_ports[10]
)

_abio_gnb_secondary_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="104",
    serial_number="L1214610543",
)

_abio_gnb_secondary_2 = CapacityUnit(
    addr="192.168.253.21",
    hardware_type="ABIO",
    hardware_version="103",
    serial_number="L1211201068",
)

_abio_gnb_secondary_3 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="101",
    serial_number="L1223310037",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_secondary_1, _abio_gnb_secondary_2, _abio_gnb_secondary_3],
    hardware_type="ASIL",
    hardware_version="A101",
    serial_number="L1214008193",
    pdu_port=_pdu_gnb.pdu_ports[11],
)

#_ue = Airphone(
#    egate=SshServiceDetails("", ""),
#    l2_ssh_connection_details=SshServiceDetails("", ""),
#    l3_ssh_connection_details=SshServiceDetails("", ""),
#    l1=Airscale(
#        common_units=[
#            CommonUnit(
#                lmp_connection=SshServiceDetails(
#                    "192.168.200.129", "toor4nsn", password="oZPS0POrRieRtu"
#                ),
#                hardware_type="ASIL",
#                capacity_units=[
#                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
#                ],
#                pdu_port=_pdu_apo.pdu_ports[9],
#            )
#        ]
#    ),
#
#)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.140", username="ute", password="ute"
    ),
    connections=[_asil_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.140", username="ute", password="ute"
    ),
    connections=[_asil_gnb_secondary],
)

_airscale_gnb_1 = Airscale([_asil_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[ru1])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=2, instance_id=2
)


tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],


    pdus=[_pdu_gnb],
)


class WTS:
        hostname = "10.42.221.140"
        username = "ute"
        password = "ute"


class KVM:
    hostname = "10.42.221.229"


setattr(tl, "kvm", KVM)

setattr(tl, "mrbts_id", "2")
setattr(tl, "mrbts_id", "2")
setattr(tl, "ltesim_pc_host", "10.42.221.140")
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
setattr(tl, "ute_control_pc_host", "10.42.221.140")
setattr(tl, "gnb_control_pc_host", ["10.42.221.140"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.42.221.140")
setattr(tl, "l3sim_host", "10.42.221.140")
