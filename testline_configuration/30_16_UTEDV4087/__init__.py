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
from taf.config.testline import Airphone


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

_pdu_gnb = Gude(addr="10.44.200.136", port_numbers=[5, 12], model="EPC", version="8041-1")
_pdu_ap = Gude(addr="10.44.200.136", port_numbers=[1, 2], model="EPC", version="8041-1")

_abio_gnb_primary_1 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="DH223748907",
)

_abio_gnb_primary_2 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214208591",
)

_abio_gnb_primary_3 = CapacityUnit(
    addr="192.168.253.36",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="DH223748967",
)

_asim_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_primary_1, _abio_gnb_primary_2, _abio_gnb_primary_3],
    hardware_type="ASIM",
    hardware_version="A101",
    serial_number="L1224503643",
    pdu_port=_pdu_gnb.pdu_ports[5],
)

_abio_gnb_secondary_1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="DH223447713",
)

_abio_gnb_secondary_2 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="DH223748914",
)

_abio_gnb_secondary_3 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="DH223140696",
)



_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_secondary_1, _abio_gnb_secondary_2, _abio_gnb_secondary_3],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1231605986",
    pdu_port=_pdu_gnb.pdu_ports[12],
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.225", username="ute", password="UTE.debian12"
    ),
    connections=[_asim_gnb_primary],
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.225", username="ute", password="UTE.debian12"
    ),
    connections=[_asil_gnb_secondary],
)

ru1 = RU(
    radio_type="37L4CRRS_TA24423-B10X",
    ru_hw_group="SIMULATED_RU",
    serial_number="00000900",
)

ru2 = RU(
    radio_type="37L4CRRS_TA24423-B10X",
    ru_hw_group="SIMULATED_RU",
    serial_number="00000901",
)

ru3 = RU(
    radio_type="37L4CRRS_TA24423-B10X",
    ru_hw_group="SIMULATED_RU",
    serial_number="00000902",
)

ru4 = RU(
    radio_type="37L4CSRE_NWA-A14438-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2366014536",
)

ru5 = RU(
    radio_type="37L4CSRE_NWA-A14438-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2366014537",
)

ru6 = RU(
    radio_type="37L4CSRE_NWA-A14438-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2366014538",
)

ru7 = RU(
    radio_type="37L4CSRE_NWA-A14438-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2366014539",
)

ru8 = RU(
    radio_type="37L4CSRE_NWA-A14438-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2366014540",
)

ru9 = RU(
    radio_type="37L4CSRE_NWA-A14438-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2366014541",
)

ru10 = RU(
    radio_type="45GSR4CE_NWA-A08317-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2311015395",
)

ru11 = RU(
    radio_type="45GSR4CE_NWA-A08317-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2311015396",
)

ru12 = RU(
    radio_type="45GSR4CE_NWA-A08317-001",
    ru_hw_group="SIMULATED_RU",
    serial_number="Na2311015397",
)

_ap1 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.129", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_ap.pdu_ports[1],
            )
        ]
    ),
)

_ap2 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.131", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO")
                ],
                pdu_port=_pdu_ap.pdu_ports[2],
            )
        ]
    ),
)

_airscale_gnb_1 = Airscale([_asim_gnb_primary, _asil_gnb_secondary])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[ru1, ru2, ru3, ru4, ru5, ru6, ru7, ru8, ru9, ru10, ru11, ru12])

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=1
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts],
    ues=[_ap1, _ap2],
    pdus=[_pdu_gnb, _pdu_ap],
)

setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.61.225")

setattr(tl, "af_type", "AF")
setattr(tl, "af_bmc_ip", "10.42.210.116")
setattr(tl, "af_bmc_username", "admin")
setattr(tl, "af_bmc_passwd", "cmb9.admin")

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
setattr(tl, "ute_control_pc_host", "10.42.61.225")
setattr(tl, "gnb_control_pc_host", ["10.42.61.225"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.42.61.225")
setattr(tl, "l3sim_host", "10.42.61.225")
