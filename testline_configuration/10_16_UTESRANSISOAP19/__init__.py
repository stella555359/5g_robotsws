__maintainer__ = "Marcin Szulc"
__email__ = "marcin.szulc@nokia.com"

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (SshServiceDetails, HttpConnectionDetails)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN

_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


##


##_pdu_1 = Gude('10.42.168.245', [7, 10, 6], 'EPC', '') #ASIK-port7; FSMF-port10; ASIB-port6



_pdu = ATEN(addr='10.44.167.164', port_numbers=[6, 7, 10])   #ASOH-port7; APH1-port10; APH2-port6
_pdus = [_pdu]


_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    hardware_type='ASOH',
    capacity_units=[],
    pdu_port=_pdus[0].pdu_ports[7],
)

_airscale = Airscale([_common_unit])

_cu = CU(
         backhaul_site_oam_ip='10.0.1.2',
         oam_ssh_connection_details=SshServiceDetails(
            addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'
         ),
         oam_http_connection_details=HttpConnectionDetails(
            addr='192.168.255.129', username='Nemuadmin', password='nemuuser'
         ),
         x2c=NetworkAddress(v4='10.0.1.1', vlan_id=1457),
         x2u=NetworkAddress(v4='10.0.1.2', vlan_id=1457),
         s1u=NetworkAddress(v4='10.0.1.2', vlan_id=1457),
         ngu=NetworkAddress(v4='10.0.1.2', vlan_id=1457),
         )

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du])

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
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIO'),
                    CapacityUnit(addr='192.168.253.85', hardware_type='ABIO'),
                    CapacityUnit(addr='192.168.253.86', hardware_type='ABIO')],
                pdu_port=_pdus[0].pdu_ports[10],
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
                    CapacityUnit(addr='192.168.253.84', hardware_type='ABIO'),
                    CapacityUnit(addr='192.168.253.85', hardware_type='ABIO')],
                pdu_port=_pdus[0].pdu_ports[6],
            )
        ]
    ),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr='10.42.121.19',
        username='ute',
        password='UTE.debian12'
    ),
    connections=[_cbts.dus[0].airscale.common_units[0], _ue1, _ue2],
)

tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    tl_cloud_topology="CLOUD_5G_O_H_AP_[LOOO][LOO]",
    ues=[_ue1 ,_ue2],
    pdus=_pdus
)

__all__ = ["tl"]
