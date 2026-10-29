__maintainer__ = "Lukasz Klimowicz"
__team__ = "VRF_WRO2_T04"
__email__ = "lukasz.klimowicz@nokia.com"
__owner_email__ = "lukasz.klimowicz@nokia.com"


import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc, Connection
from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import Gude

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_pdu1 = Gude(addr='10.44.200.162', port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], model="EPC", version="8041-1")

_pdus = [_pdu1]

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIO")],
    pdu_port=_pdu1.pdu_ports[12],
)

_airscale = Airscale([_common_unit])

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.1", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.1", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.1.1.1", vlan_id=1227),
    x2u=NetworkAddress(v4="10.1.1.1", vlan_id=1227),
    s1u=NetworkAddress(v4="10.1.1.1", vlan_id=1227),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du], instance_id=716900011)

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
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.92", hardware_type="ABIO")
                ],
                pdu_port=_pdu1.pdu_ports[11],
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.231.56", username="ute", password="UTE.debian12"
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], _ue],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_I_LOO_AP_LOOO",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
