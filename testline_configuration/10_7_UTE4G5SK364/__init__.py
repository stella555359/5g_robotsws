__owner__ = "IHT AUTOMATION"
__maintainer__ = "IHT AUTOMATION"
__email__ = "i_iht_automation@internal.nsn.com"

import os

from taf.config.testline.airscale import Airscale, CapacityUnit, CommonUnit
from taf.config.testline.connection_details import (
    HttpConnectionDetails,
    SshServiceDetails,
)
from taf.config.testline.enb import RealEnb
from taf.config.testline.gnb import CU, DU, ClassicalBts
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline.pdu import FPFH
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import Connection, TestPc
from taf.config.testline.ue import CUS, Airphone

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


# PDU1  port1=eNB port2=gNB port3=AP port4=CUS
_pdu1 = FPFH(
    addr="10.255.26.33", port_numbers=[1, 2, 3, 4], login="admin", password="admin"
)


_airscale_gnb = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.255.119", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[
                CapacityUnit(addr="192.168.253.20", hardware_type="ABIO"),
            ],
            pdu_port=_pdu1.pdu_ports[2],
            hardware_type="ASIL",
        )
    ]
)

_du = DU(_airscale_gnb)

_cu = CU(
    backhaul_site_oam_ip="192.168.255.129",
    oam_ssh_connection_details=SshServiceDetails(
        addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr="192.168.255.129", username="Nemuadmin", password="nemuuser"
    ),
    x2c=NetworkAddress(v4="10.0.1.2", vlan_id=1864),
    x2u=NetworkAddress(v4="10.0.1.2", vlan_id=1864),
    s1u=NetworkAddress(v4="10.0.1.2", vlan_id=1864),
)

_gnb = ClassicalBts(cu=_cu, dus=[_du], instance_id=10705003641)

_airscale_enb = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[
                CapacityUnit(addr="192.168.253.20", hardware_type="ABIA"),
            ],
            pdu_port=_pdu1.pdu_ports[1],
            hardware_type="ASIL",
        )
    ]
)

_enb = RealEnb(system_module=_airscale_enb, instance_id=10705003642)

_airscale_ap = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[
                CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
            ],
            pdu_port=_pdu1.pdu_ports[3],
            hardware_type="ASIL",
        )
    ]
)

_ap = Airphone(
    egate=None,
    l3_ssh_connection_details=None,
    l2_ssh_connection_details=None,
    l1=_airscale_ap,
)

_airscale_cus = Airscale(
    common_units=[
        CommonUnit(
            lmp_connection=SshServiceDetails(
                addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
            ),
            capacity_units=[
                CapacityUnit(addr="192.168.253.84", hardware_type="ABIA"),
            ],
            pdu_port=_pdu1.pdu_ports[4],
            hardware_type="ASIB",
        )
    ]
)

_cus = CUS(
    l1=_airscale_cus,
)

_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK364-1.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_gnb.dus[0].airscale.common_units[0],
            interface_type="lmp",
        ),
        _ap,
    ],
)

_test_pc2 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10-7-UTE4G5SK364-2.p05.ska-lab.nsn-rdnet.net",
        username="ute",
        password="ute",
    ),
    connections=[
        Connection(
            interface="eth1",
            device=_enb.system_module.common_units[0],
            interface_type="lmp",
        ),
        _cus,
    ],
)


tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1, _test_pc2],
    gnbs=[_gnb],
    enbs=[_enb],
    tl_cloud_topology="CLOUD_5G_I_LO_AP_LO-4G_I_LA_CUS_BA",
    ues=[_ap, _cus],
    pdus=[_pdu1],
)

__all__ = ["tl"]
