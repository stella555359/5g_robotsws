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


_pdu1 = APC(addr="10.42.168.8", port_numbers=[1, 2, 3, 4, 5, 6, 7, 8])


_pdus = [_pdu1]

_cu1 = CU(
    backhaul_site_oam_ip="10.0.1.2",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=4007),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=4007),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=4007),
    ngu=NetworkAddress(v4="10.0.1.2", vlan_id=4007),
)

_abio_du1 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asil_du1 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[2],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abio_du1],
)

_du1 = DU(airscale=Airscale(common_units=[_asil_du1]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1], instance_id=716090541)

_cu2 = CU(
    backhaul_site_oam_ip="10.0.1.3",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.3", vlan_id=4007),
    x2u=NetworkAddress(v4="10.0.1.3", vlan_id=4007),
    s1u=NetworkAddress(v4="10.0.1.3", vlan_id=4007),
    ngu=NetworkAddress(v4="10.0.1.3", vlan_id=4007),
)

_abio_du2 = CapacityUnit(addr="192.168.253.20", hardware_type="ABIO")

_asil_du2 = CommonUnit(
    pdu_port=_pdu1.pdu_ports[3],
    lmp_connection=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    hardware_type="ASIL",
    capacity_units=[_abio_du2],
)

_du2 = DU(airscale=Airscale(common_units=[_asil_du2]))

_cbts2 = ClassicalBts(cu=_cu2, dus=[_du2], instance_id=716090542)

_ue = Airphone(
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    SshServiceDetails("", ""),
    Airscale(
        [
            CommonUnit(
                pdu_port=_pdu1.pdu_ports[4],
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
		    CapacityUnit(addr="192.168.253.92", hardware_type="ABIO"),
                ],
            )
        ]
    ),
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.171.64",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts1.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ue,
    ],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.42.171.65",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_cbts2.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_cbts1, _cbts2],
    tl_cloud_topology="CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD",
    ues=[_ue],
    pdus=_pdus,
)

__all__ = ["tl"]
