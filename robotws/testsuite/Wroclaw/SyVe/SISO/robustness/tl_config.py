__maintainer__ = "Jakub Szymczakiewicz Sebastian Lupkowski"
__team__ = "5G_PZ_1_WRO_1_SG"
__email__ = "jakub.szymczakiewicz@nokia.com, sebastian.lupkowski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import RealEnb
from taf.config.testline.gnb.du import DU, RU
from taf.config.testline.core import RealCore5G
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress

__all__ = ["tl"]

cfg_dir = os.path.dirname(os.path.abspath(__file__))

# vlan_id - fill with the same VLAN which is on WebEM and fill correct IP adresses

_cu_gnb_1 = CU(
    backhaul_site_oam_ip="192.168.255.1",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(v4="adress_IP_x2c", v6=None, vlan_id=0),
    x2u=NetworkAddress(v4="adress_IP_x2u", v6=None, vlan_id=0),
    s1u=NetworkAddress(v4="adress_IP_s1u", v6=None, vlan_id=0),
)
# port_numbers - replace with the current port on pdu and replace IP addresses

_pdu_gnb = Gude(addr="adress_IP_pdu_gnb", port_numbers=[0], version="8221-1")

_pdu_enb = Gude(addr="adress_IP_pdu_enb", port_numbers=[0], version="8221-1")

_pdu_enb_ru = Gude(addr="adress_IP_pdu_enb_ru", port_numbers=[0], version="8221-1")

_pdu_gnb_ru = Gude(addr="adress_IP_pdu_gnb_ru", port_numbers=[0], version="8221-1")

# please replace dummy values with the real ones

_ru_1 = RU(
    ru_hw_group="radio_family",
    radio_type="radio_name",
    serial_number="serial_number_RU",
    product_code="product_code_RU",
    default_ssh_connection_details=SshServiceDetails(
        addr="adress_ip_RU",
        username={
            "SBTS00": "username",
        },
        password={
            "SBTS00": "password",
        },
    ),
    pdu_port=_pdu_gnb_ru.pdu_ports[0],
)

# please replace dummy values with the real ones

_abip_gnb_1 = CapacityUnit(
    addr="address_IP_bbmod_gnb",
    hardware_type="bbmod_name",
    hardware_version="bbmod_version",
    serial_number="bbmod_serial_number",
)

# please replace dummy values with the real ones

_smod1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abip_gnb_1],
    pdu_port=_pdu_gnb.pdu_ports[0],
    hardware_type="smod_name",
    hardware_version="smod_version",
    serial_number="smod_serial_number",
)

# please replace dummy values with the real ones

_lmp_vm_gnb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="address_IP_vm_gnb", username="username", password="password"
    ),
    connections=[_smod1],
)

_airscale_gnb_1 = Airscale(common_units=[_smod1])

_du_1_gnb_1 = DU(airscale=_airscale_gnb_1, rus=[_ru_1])

# please replace dummy values with the real ones

_cbts = ClassicalBts(cu=_cu_gnb_1, dus=[_du_1_gnb_1], global_bts_id=0, instance_id=0)

_core = RealCore5G()

# please replace dummy values with the real ones

_enb_ru_1 = RU(
    ru_hw_group="radio_family_enb",
    radio_type="radio_name_enb",
    serial_number="radio_serial_number_enb",
    default_ssh_connection_details=TelnetConnectionDetails(addr="", port=2323),
    pdu_port=_pdu_enb_ru.pdu_ports[0],
)

# please replace dummy values with the real ones

_abia_enb_1 = CapacityUnit(
    addr="address_IP_bbmod_enb",
    hardware_type="bbmod_name_enb",
    hardware_version="bbmod_version_enb",
    serial_number="bbmod_serial_enb",
)

# please replace dummy values with the real ones

_asib_enb_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abia_enb_1],
    pdu_port=_pdu_enb.pdu_ports[0],
    serial_number="smod_serial_number_enb",
)

_airscale_enb_1 = Airscale(common_units=[_asib_enb_1])

# please replace dummy values with the real ones

_enb_1 = RealEnb(
    system_module=_airscale_enb_1,
    x2_link_addr=NetworkAddress(v4="address_ip_x2_enb", vlan_id=0),
    global_bts_id=0,
    instance_id=0,
    oam_ip=NetworkAddress(v4="mplane_address_ip_enb"),
    rms=[_enb_ru_1],
)

# please replace dummy values with the real ones

_lmp_vm_enb_1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="address_ip_vm_enb", username="username", password="password"
    ),
    connections=[_enb_1],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_1,
    test_pcs=[_lmp_vm_gnb_1, _lmp_vm_enb_1],
    gnbs=[_cbts],
    enbs=[_enb_1],
    core=_core,
    pdus=[_pdu_gnb, _pdu_gnb_ru],
)
