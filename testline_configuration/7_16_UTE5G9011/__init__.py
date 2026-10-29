__maintainer__ = "ET_OMICRON"
__team__ = "VRF_WRO2_12"
__email__ = "I_L3_WRO_OMICRON_ET"
__owner_email__ = "I_L3_WRO_OMICRON_ET@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import APC


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu = APC(addr="10.42.168.195", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])


_pdus = [_pdu]

_cu = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=201),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=201),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=201),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=201),
)

_abio_du = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asil_du = CommonUnit(
    pdu_port=_pdu.pdu_ports[1],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abio_du],
)

_du = DU(airscale=Airscale(common_units=[_asil_du]))

_cbts = ClassicalBts(cu=_cu, dus=[_du])

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu.pdu_ports[3],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                ],
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.185.11",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ue,
    ],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_I_LO_AP_LO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
