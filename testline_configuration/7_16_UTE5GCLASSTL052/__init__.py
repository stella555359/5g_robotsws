__maintainer__ = "Adrian Karas"
__email__ = "adrian.karas@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    TelnetConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU
from taf.config.testline import DU, RoutingInformation
from taf.config.testline.radio import RU
from taf.config.testline.pdu import Gude
from taf.config.testline.gnb.networkaddress import NetworkAddress

__all__ = ["tl"]

_pdu_gnb = \
	Gude(addr="10.44.177.67", port_numbers=[7, 8], model="EPC", version="8221-1")
_pdu_radios = \
	Gude(addr="10.44.177.56", port_numbers=[1,2,4,5,6,7,8,10], model="EPC", version="8221-1"
)

_ahloa1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G10P7",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.132", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_radios.pdu_ports[7],
)

_ahloa2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL2040G1M4T",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.133", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_radios.pdu_ports[8],
)

_ahloa3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHLOA",
    serial_number="BL1933G10P6",
    product_code="474331A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.131", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_radios.pdu_ports[4],
)

_ahfib1 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2240V0BIE",
    product_code = "474216A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.128", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_radios.pdu_ports[5],
)

_ahfib2 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2230V04S4",
    product_code="474216A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.130", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_radios.pdu_ports[6],
)

_ahfib3 = RU(
    ru_hw_group="FRMr5.1a_4T4R",
    radio_type="AHFIB",
    serial_number="BL2240V0BFP",
    product_code="474216A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.16.33.129", username="root", password="umniedziala"
    ),
    pdu_port=_pdu_radios.pdu_ports[10],
)
_azhl1 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZHL",
    serial_number="AH211900792",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.2", username="rfsw", password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    pdu_port=_pdu_radios.pdu_ports[2],
)

_azhl2 = RU(
    ru_hw_group="cMAAr6.1_8T8R",
    radio_type="AZHL",
    serial_number="YK203400071",
    product_code="475432A.101",
    default_ssh_connection_details=SshServiceDetails(
        addr="172.22.8.154", username="rfsw", password="5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ="
    ),
    pdu_port=_pdu_radios.pdu_ports[1],
)

_abioL1 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008294",
    rus=[_ahloa1, _ahloa2, _ahloa3],
)
_abioL2 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204108967",
    rus=[_ahfib1, _ahfib2, _ahfib3],
)
_abiaL3 = CapacityUnit(
    addr="192.168.253.28",
    hardware_type="ABIA",
    hardware_version="473096A.106",
    serial_number="L1204507421",
    rus=[_ahfib1, _ahfib2, _ahfib3],
)
_abioR4 = CapacityUnit(
    addr="192.168.253.20",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204104708",
    rus=[_azhl1, _azhl2],
)
_abioR5 = CapacityUnit(
    addr="192.168.253.24",
    hardware_type="ABIO",
    hardware_version="475266A.101",
    serial_number="L1204008311",
    rus=[_azhl1, _azhl2],
)
_asil_L = CommonUnit(
    lmp_connection=SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abioL1, _abioL2, _abiaL3],
    pdu_port=_pdu_gnb.pdu_ports[7],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="L1213810572",
)
_asil_R = CommonUnit(
    lmp_connection=SshServiceDetails(
    addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    capacity_units=[_abioR4, _abioR5],
    pdu_port=_pdu_gnb.pdu_ports[8],
    hardware_type="ASIL",
    hardware_version="A.101",
    serial_number="DH220345492",
)

_cu = CU(
    backhaul_site_oam_ip="10.45.178.9",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser", port=443
    ),
    x2c=NetworkAddress(
        v4="10.45.178.73",
        vlan_id=852,
        routing_v4=RoutingInformation(
            gateway="10.45.178.65", destIpAddr="255.255.255.192"
        ),
    ),
    x2u=NetworkAddress(
        v4="10.45.178.137",
        vlan_id=853,
        routing_v4=RoutingInformation(
            gateway="10.45.178.129", destIpAddr="255.255.255.192"
        ),
    ),
    s1u=NetworkAddress(
        v4="10.45.178.201",
        vlan_id=854,
        routing_v4=RoutingInformation(
            gateway="10.45.178.193", destIpAddr="255.255.255.192"
        ),
    ),
)
airscale_gnb=Airscale(common_units=[_asil_L, _asil_R])

_du = DU(
	airscale=airscale_gnb, rus=[_ahloa1, _ahloa2, _ahloa3, _ahfib1, _ahfib2, _ahfib3, _azhl1, _azhl2]
)

_gnb = ClassicalBts(cu=_cu, dus=[_du], instance_id=50432, global_bts_id=50432)

_lmp_vm_gnb_primary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.174", username="ute", password="uteUTE!"
    ),
    connections=[_asil_L],
)
_lmp_vm_gnb_secondary = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.175", username="ute", password="uteUTE!"
    ),
    connections=[_asil_R],
)

tl = TestLine(
    test_pc=_lmp_vm_gnb_primary,
    test_pcs=[_lmp_vm_gnb_primary, _lmp_vm_gnb_secondary],
    gnbs=[_gnb],
    tl_cloud_topology="CLOUD_5G_CLASSICAL_2xANDROID_ASIKL_ABILB1_3xAHLOA",
    pdus=[_pdu_gnb, _pdu_radios],
)
