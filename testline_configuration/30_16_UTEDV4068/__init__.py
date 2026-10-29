__maintainer__ = "Volha Tsekalo"
__team__ = "DCM"
__email__ = "volha.tsekalo@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, Connection
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN, Gude, EPC
from taf.config.testline.dcm_specific import MMTVM, DCMMiddleware

__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.1", vlan_id=286),
    x2u=NetworkAddress(v4="10.0.1.1", vlan_id=286),
    s1u=NetworkAddress(v4="10.0.1.1", vlan_id=286),
)

_cu_gnb_2 = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    )
)

_pdu_gnb = Gude(addr="10.44.200.83", port_numbers=[4, 9], model="EPC", version="8220-1")
_pdu_apo = Gude(addr="10.44.200.83", port_numbers=[3], model="EPC", version="8220-1")
_pdu_apo_2 = Gude(addr="10.44.200.84", port_numbers=[8], model="EPC", version="8220-1")

_abip_1_gnb_1 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1233201685",
)

_abio_2_gnb_1 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="A104",
    serial_number="L1214608146",
)

_abio_1_gnb_2 = CapacityUnit(
    addr="192.168.253.22",
    hardware_type="ABIO",
    hardware_version="A102",
    serial_number="L1204506011",
)

_asim_gnb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_1_gnb_1, _abio_2_gnb_1],
    hardware_type="ASIM",
    hardware_version="A101",
    serial_number="L1224503571",
    pdu_port=_pdu_gnb.pdu_ports[4],
)

_asil_gnb_2 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_1_gnb_2],
    hardware_type="ASIL",
    hardware_version="A103",
    serial_number="L1241300501",
    pdu_port=_pdu_gnb.pdu_ports[9],
)

_ue1 = Airphone(
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
                    CapacityUnit(addr='192.168.253.84', hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo.pdu_ports[3]
            )
        ]
    ),
)

_ue2 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    "192.168.200.2", "toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type='ASIL',
                capacity_units=[
                    CapacityUnit(addr='192.168.253.84', hardware_type="ABIO")
                ],
                pdu_port=_pdu_apo_2.pdu_ports[8]
            )
        ]
    ),
)

_airscale_gnb_1 = Airscale([_asim_gnb_1])
_airscale_gnb_2 = Airscale([_asil_gnb_2])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[])
_du_2_gnb_1 = DU(airscale=_airscale_gnb_2, rus=[])

_cbts_1 = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=2, instance_id=2
)

_cbts_2 = ClassicalBts(
    cu=_cu_gnb_2, dus=[_du_2_gnb_1]
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.66.237", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=2,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.221.222", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts_1, _cbts_2],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.221.225", username="ute", password="UTE.debian12"
    ),
    connections=[_asim_gnb_1, _asil_gnb_2,
                Connection(interface="eth2", interface_type="lmp", device=_ue1),
                Connection(interface="eth3", interface_type="lmp", device=_ue2),
                _mediator,
                ],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1],
    gnbs=[_cbts_1, _cbts_2],
    ues=[_ue1, _ue2],
    pdus=[_pdu_gnb, _pdu_apo, _pdu_apo_2],
)


class Mediator:
    class GuestOS:
        hostname = "172.16.11.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.221.222"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.66.237"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = 2

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT


setattr(tl, "mediator", Mediator)
