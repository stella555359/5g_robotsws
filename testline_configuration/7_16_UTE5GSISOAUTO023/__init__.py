__team__ = "MN RAN Pz 1 WRO 4 SG"
__owner__ = "MN RAN Pz 1 WRO 4 SG"
__maintainer__ = "Robert Wsiaki"
__email__ = "robert.wsiaki@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline import RealEnb, TopYoung
from taf.config.testline import NetworkAddress
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.connection_details import IperfDataTransferDetails
from taf.config.testline.ue import Android


__all__ = ["tl"]

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="10.42.220.176",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v6="2a00:8a00:6000:607c::4731", vlan_id=525),
    x2u=NetworkAddress(v6="2a00:8a00:6000:607c::4731", vlan_id=525),
    s1u=NetworkAddress(v6="2a00:8a00:6000:607c::4731", vlan_id=525),
)

_pdu_enb = Gude(addr="10.44.177.174", port_numbers=[10], model="EPC", version="8221-1")

_pdu_gnb = Gude(addr="10.44.177.174", port_numbers=[9], model="EPC", version="8221-1")
_pdu_shared_rus = Gude(
    addr="10.44.206.11", port_numbers=[10, 12], model="EPC", version="8221-1"
)
_pdu_shared_rus_2 = Gude(
    addr="10.44.177.189", port_numbers=[1, 2, 3, 4], model="EPC", version="8221-1"
)

_ru_1 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AAFB",
    serial_number="BL2105H26LW",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.132", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_shared_rus.pdu_ports[10],
)

_ru_2 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AAFB",
    serial_number="BL2105H26OJ",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.133", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_shared_rus_2.pdu_ports[3],
)

_ru_3 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AAFB",
    serial_number="BL2105H26OW",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.128", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_shared_rus_2.pdu_ports[4],
)

_ru_4 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AAFB",
    serial_number="BL2105J30BI",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.130", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_shared_rus.pdu_ports[12],
)

_ru_5 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AAFB",
    serial_number="BL2030I23D8",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_shared_rus_2.pdu_ports[2],
)

_ru_6 = RU(
    ru_hw_group="5Ggen4_LowF_4T4R",
    radio_type="AAFB",
    serial_number="BL2105I26VE",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.73.131", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    pdu_port=_pdu_shared_rus_2.pdu_ports[1],
)


_abia_enb_1 = CapacityUnit(
    addr="192.168.253.39", hardware_type="ABIA", serial_number="L1181620156"
)

_abia_enb_2 = CapacityUnit(
    addr="192.168.253.43", hardware_type="ABIA", serial_number="L1173007565"
)

_abia_enb_3 = CapacityUnit(
    addr="192.168.253.47", hardware_type="ABIA", serial_number="L1171213700"
)

_asia_enb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1, _abia_enb_2, _abia_enb_3],
    pdu_port=_pdu_enb.pdu_ports[10],
    hardware_type="ASIA",
    serial_number="L1162802455",
)


_abio_gnb = CapacityUnit(
    addr="192.168.253.22",
    rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
    hardware_type="ABIO",
    serial_number="L1205102689",
)

_asim_gnb = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abio_gnb],
    pdu_port=_pdu_gnb.pdu_ports[9],
    hardware_type="ASIM",
    serial_number="L1224309139",
)

_airscale_gnb_1 = Airscale(common_units=[_asim_gnb])
_airscale_enb_1 = Airscale(common_units=[_asia_enb])
_du_1_gnb_1 = DU(
    airscale=_airscale_gnb_1, rus=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6]
)

_cbts = ClassicalBts(
    cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=1, instance_id=50523
)

_enb_1 = RealEnb(
    airscale=_airscale_enb_1,
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v6="2a00:8a00:6000:607c::4732", vlan_id="525"),
    global_bts_id=40523,
    instance_id=40523,
    oam_ip=NetworkAddress(v4="10.42.220.177"),
    rms=[_ru_1, _ru_2, _ru_3, _ru_4, _ru_5, _ru_6],
)

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.139", username="ute", password="ute"
    ),
    connections=[_asim_gnb],
)

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.140", username="ute", password="ute"
    ),
    connections=[_enb_1],
)

_core = RealCore5G()

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_ASIML_ABIOB1_3xAAFB_shared_3xAAIB_shared_CPRI_ENB",
    core=_core,
    pdus=[_pdu_gnb, _pdu_shared_rus, _pdu_shared_rus_2, _pdu_enb],
)
