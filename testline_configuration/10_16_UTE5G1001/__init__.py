__maintainer__ = "Kamil Galczynski"
__team__ = "I_MN_RAN_RD_VRF_WRO_1_5"
__email__ = "i_mi_mn_ran_rd_vrf_wro1_5@nokia.com"
__owner_email__ = "kamil.galczynski@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (SshServiceDetails, HttpConnectionDetails)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import Gude
from taf.config.testline import Connection

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_pdu = Gude(
    addr="10.44.177.185",
    port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    model="EPC", version="8221-1"
)
_pdus = [_pdu]

### GNB1
_common_unit1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    capacity_units=[
        CapacityUnit(addr="192.168.253.20", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.21", hardware_type="ABIO"),
        CapacityUnit(addr="192.168.253.22", hardware_type="ABIO"),
    ],
    pdu_port=_pdus[0].pdu_ports[3],
    hardware_type="ASIM"
)

_cu1 = CU(backhaul_site_oam_ip='192.168.255.129',
              oam_ssh_connection_details=SshServiceDetails(
                  addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'),
              oam_http_connection_details=HttpConnectionDetails(
                  addr='192.168.255.129', username='Nemuadmin', password='nemuuser', port=443),
              x2c=NetworkAddress(v4='10.0.1.1', vlan_id=3586),
              x2u=NetworkAddress(v4='10.0.1.1', vlan_id=3586),
              s1u=NetworkAddress(v4='10.0.1.1', vlan_id=3586),
              )

_du1 = DU(airscale=Airscale(common_units=[_common_unit1]))

_cbts1 = ClassicalBts(cu=_cu1, dus=[_du1], instance_id=21648751)

### AP1
_ue1 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.86", hardware_type="ABIO"),
                ],
                pdu_port=_pdus[0].pdu_ports[9],
            )
        ]
    ),
)

### AP2
_ue2 = Airphone(
    egate=SshServiceDetails("", ""),
    l2_ssh_connection_details=SshServiceDetails("", ""),
    l3_ssh_connection_details=SshServiceDetails("", ""),
    l1=Airscale(
        common_units=[
            CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr="192.168.200.2", username="toor4nsn", password="oZPS0POrRieRtu"
                ),
                hardware_type="ASIL",
                capacity_units=[
                    CapacityUnit(addr="192.168.253.87", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.88", hardware_type="ABIO"),
                ],
                pdu_port=_pdus[0].pdu_ports[4],
            )
        ]
    ),
)

### TestPC1
_test_pc1 = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr="10.44.149.156",
        username="ute",
        password="uteUTE!",
    ),
    connections=[
        Connection(
            interface="eth1",
            interface_type="lmp",
            device=_cbts1.dus[0].airscale.common_units[0],
        ),
        Connection(interface="eth5", interface_type="lmp", device=_ue2),
    ],
)

tl = TestLine(
    test_pc=_test_pc1,
    test_pcs=[_test_pc1],
    gnbs=[_cbts1],
    tl_cloud_topology="CLOUD_5G_I_MP_AP_[LOOO][LOO]",
    ues=[_ue2],
    pdus=[_pdus],
)
__all__ = ["tl"]
