__maintainer__ = "Maciej Cupial"
__team__ = "DCM"
__email__ = "maciej.cupial@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.dcm_specific import MMTVM, DCMMiddleware
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RU, Connection
from taf.config.testline.pdu import Gude
from taf.config.testline.nms import NMS, NetAct


__all__ = ["tl"]

_cu_gnb = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=460),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=461),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=462),
)

_pdu_gnb = Gude(addr="10.44.200.118", port_numbers=[10], version="8221-1")
_pdu_ap1 = Gude(addr="10.44.200.118", port_numbers=[11], version="8221-1")
_pdu_ap2 = Gude(addr="10.44.200.118", port_numbers=[12], version="8221-1")
_pdu_rus = Gude(addr="10.44.206.16", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], version="8221-1")
_pdus = [_pdu_gnb, _pdu_ap1, _pdu_ap2, _pdu_rus]

_ru_1 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="00002472",
    pdu_port=_pdu_rus.pdu_ports[1],
)

_ru_2 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="00002473",
    pdu_port=_pdu_rus.pdu_ports[2],
)

_ru_3 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="00002474",
    pdu_port=_pdu_rus.pdu_ports[3],
)

_ru_4 = RU(
    ru_hw_group="",
    radio_type="SJEOSQA",
    serial_number="00002475",
    pdu_port=_pdu_rus.pdu_ports[4],
)

_ru_5 = RU(
    ru_hw_group="",
    radio_type="SJEOSQA",
    serial_number="00002476",
    pdu_port=_pdu_rus.pdu_ports[5],
)

_ru_6 = RU(
    ru_hw_group="",
    radio_type="SJEOSQA",
    serial_number="00002477",
    pdu_port=_pdu_rus.pdu_ports[6],
)

_ru_7 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="00002450",
    pdu_port=_pdu_rus.pdu_ports[7],
)

_ru_8 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="00002451",
    pdu_port=_pdu_rus.pdu_ports[8],
)

_ru_9 = RU(
    ru_hw_group="",
    radio_type="34L4CRRU",
    serial_number="00002452",
    pdu_port=_pdu_rus.pdu_ports[9],
)

_ru_10 = RU(
    ru_hw_group="",
    radio_type="SJEOSQA",
    serial_number="00002453",
    pdu_port=_pdu_rus.pdu_ports[10],
)

_ru_11 = RU(
    ru_hw_group="",
    radio_type="SJEOSQA",
    serial_number="00002454",
    pdu_port=_pdu_rus.pdu_ports[11],
)

_ru_12 = RU(
    ru_hw_group="",
    radio_type="SJEOSQA",
    serial_number="00002455",
    pdu_port=_pdu_rus.pdu_ports[12],
)

_abip_gnb = CapacityUnit(
    addr="192.168.253.38",
    hardware_type="ABIP",
    hardware_version="A102",
    serial_number="L1240903952",
)

_smod = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_gnb],
    pdu_port=_pdu_gnb.pdu_ports[10],
    hardware_type="ASIL",
    hardware_version="102",
    serial_number="L1220403397",
)

_airscale_gnb = Airscale(common_units=[_smod])

_du_gnb = DU(
    airscale=_airscale_gnb,
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6, _ru_7, _ru_8, _ru_9, _ru_10, _ru_11, _ru_12]
)


_cbts = ClassicalBts(
    cu=_cu_gnb, dus=[_du_gnb], global_bts_id=1, instance_id=1
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
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIO')],
                pdu_port=_pdu_ap1.pdu_ports[11]
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
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIO')],
                pdu_port=_pdu_ap2.pdu_ports[12]
          )
       ]
    ),
)

_mmtvm_med = MMTVM(
    mmtvm_connection_info=SshServiceDetails(
        addr="10.42.221.236", username="plwrranpzk3", password="p_5PvX7#a3jz"
    ),
    dct_interface=1,
)

_mediator = DCMMiddleware(
    middleware_maintenance_connection=SshServiceDetails(
        addr="192.168.129.3", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hostos=SshServiceDetails(addr="10.42.75.232", username="root", password="uteadmin"),
    mmt=_mmtvm_med,
    gnbs=[_cbts],
)

_lmp_vm_gnb = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.75.16", username="ute", password="UTE.debian12"
    ),
    connections=[_smod,
                Connection(interface="eth2", interface_type="lmp", device=_ue1),
                Connection(interface="eth3", interface_type="lmp", device=_ue2),
                _mediator,
                ],
)

_cmwas_node = SshServiceDetails(
    addr="10.8.103.155",
    username="omc",
    password="Medsql!_1893",
    port=22,
)
_fmwas_node = SshServiceDetails(
    addr="10.8.103.156",
    username="omc",
    password="Medsql!_1893",
    port=22,
)
_nms = NMS(
    netact=NetAct(
        ssh_connections_info=[_cmwas_node, _fmwas_node],

        https_main_info=HttpConnectionDetails(
            addr="srnclab5011lbwas.srntre.nsn-rdnet.net",
            username="ran01",
            password="Nokia_456",
            port=443
        ),
    ),
)

tl = TestLine(
    test_pc=_lmp_vm_gnb,
    test_pcs=[_lmp_vm_gnb],
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_DCM_I_[LP]_AP_[LOOO][LOOO]_MED",
    ues=[_ue1, _ue2],
    nms=_nms,
    pdus=[_pdus],
)

class Mediator:
    class GuestOS:
        hostname = "10.42.45.18"
        username = "root"
        password = "uteadmin"

    class HostOS:
        hostname = "10.42.75.232"
        username = "root"
        password = "uteadmin"

    class MMT:
        hostname = "10.42.221.236"
        username = "plwrranpzk3"
        password = "p_5PvX7#a3jz"
        dct_interface = '2'

    hostname = "192.168.129.3"
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"

    guest_os = GuestOS
    host_os = HostOS
    mmt_vm = MMT

setattr(tl, "mediator", Mediator)