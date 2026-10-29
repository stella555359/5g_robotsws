__maintainer__ = "Maciej Cupial"
__team__ = "DCM"
__email__ = "maciej.cupial@nokia.com"


from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, Connection
from taf.config.testline.pdu import Gude


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4='10.0.1.2', vlan_id=4093),
    x2u=NetworkAddress(v4='10.0.1.2', vlan_id=4093),
    s1u=NetworkAddress(v4='10.0.1.2', vlan_id=4093),
)


_cu_gnb_2 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4='10.0.1.2', vlan_id=4093),
    x2u=NetworkAddress(v4='10.0.1.2', vlan_id=4093),
    s1u=NetworkAddress(v4='10.0.1.2', vlan_id=4093),
)

_pdu_gnb = Gude(addr="10.44.200.70", port_numbers=[10, 11, 12], model="EPC", version="8220-1")

_abio_gnb_primary_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101299",
)

_abio_gnb_primary_2 = CapacityUnit(
    addr="192.168.253.26",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101301",
)

_asil_gnb_primary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_primary_1, _abio_gnb_primary_2],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1232215383",
    pdu_port=_pdu_gnb.pdu_ports[11],
)

_abio_gnb_secondary_1 = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101310",
)

_abio_gnb_secondary_2 = CapacityUnit(
    addr="192.168.253.42",
    hardware_type="ABIO",
    hardware_version="A105",
    serial_number="L1232101307",
)

_asil_gnb_secondary = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb_secondary_1, _abio_gnb_secondary_2],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1232302261",
    pdu_port=_pdu_gnb.pdu_ports[10],
)


_airscale_gnb_1 = Airscale(common_units=[_asil_gnb_primary])

_airscale_gnb_2 = Airscale(common_units=[_asil_gnb_secondary])

_du_1 = DU(airscale=_airscale_gnb_1)

_du_2 = DU(airscale=_airscale_gnb_2)

_cbts_1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1]
)

_cbts_2 = ClassicalBts(cu=_cu_gnb_2, dus=[_du_2])

_ue = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.1", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type='ASIL',
                capacity_units=[
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIO')],
                pdu_port=_pdu_gnb.pdu_ports[12]
          )
       ]
    ),
)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.215", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_cbts_1.dus[0].airscale.common_units[0]
        ),
        Connection(
            interface="eth2",
            interface_type="lmp",
            device=_ue
        )
    ]
)

_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.61.131", username="ute", password="UTE.debian12"
    ),
    connections=[
        Connection(
           interface="eth1",
           interface_type="lmp",
           device=_cbts_2.dus[0].airscale.common_units[0]
        ),
    ]

)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_cbts_1, _cbts_2],
    pdus=[_pdu_gnb],
    tl_cloud_topology="CLOUD_DCM_I_[LO][LO]_AP_[LOO]",
    ues=[_ue]
)


class EGen:
    hostname = "10.42.75.246"
    username = "ute"
    password = "egenDCM2137@"


class KVM:
    hostname = "10.42.221.229"


setattr(tl, "kvm", KVM)

setattr(tl, "egen", EGen)
setattr(tl, "mrbts_id", "1")
setattr(tl, "ltesim_pc_host", "10.42.221.215")

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
setattr(tl, 'oam_http_addr', '192.168.255.1')
setattr(tl, 'oam_http_port', '443')
setattr(tl, 'oam_http_username', 'Nemuadmin')
setattr(tl, 'oam_http_password', 'nemuuser')
setattr(tl, "ute_control_pc_host", "10.42.221.215")
setattr(tl, "gnb_control_pc_host", ["10.42.221.215"])
setattr(tl, "gnb_control_pc_user", "ute")
setattr(tl, "gnb_control_pc_pwd", "ute")
setattr(tl, "epc_host", "10.42.221.215")
setattr(tl, "l3sim_host", "10.42.221.215")
setattr(tl, "ntp_server_ip_address", "10.42.248.70")
