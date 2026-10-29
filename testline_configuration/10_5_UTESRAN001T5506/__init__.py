__maintainer__ = 'UTE team'
__team__ = 'UTE team'
__email__ = 'ute@nokia.com'
__owner_email__ = 'UTE Lab Team'

import os
from taf.config.testline.testline import TestLine
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (SshServiceDetails, HttpConnectionDetails)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.gnb.networkaddress import NetworkAddress
from taf.config.testline import Airphone
from taf.config.testline.pdu import ATEN
from taf.config.testline.pdu import FPFH


_CFG_DIR = os.path.dirname(os.path.abspath(__file__))


_pdu = FPFH(addr='10.108.190.218', port_numbers=[2,3], login="admin", password="admin")
_pdus = [_pdu]



_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.129',username='toor4nsn',password='oZPS0POrRieRtu'
    ),
    hardware_type='ASIL',
    capacity_units=[
        CapacityUnit(addr="192.168.253.36", hardware_type='ABIO'),
        CapacityUnit(addr="192.168.253.40", hardware_type="ABIO")],
        pdu_port=_pdus[0].pdu_ports[3],
)
		
_airscale = Airscale([_common_unit])

_cu = CU(backhaul_site_oam_ip='192.168.255.129',
    oam_ssh_connection_details=SshServiceDetails(
        addr='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu'),
    oam_http_connection_details=HttpConnectionDetails(
        addr='192.168.255.129', username='Nemuadmin', password='nemuuser', port=443),
    x2c=NetworkAddress(v4='10.0.1.1', vlan_id=766),
    x2u=NetworkAddress(v4='10.0.1.1', vlan_id=766),
    s1u=NetworkAddress(v4='10.0.1.1', vlan_id=766),
)

_du = DU(_airscale)

_cbts = ClassicalBts(cu=_cu, dus=[_du],instance_id=10555061)


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
                hardware_type='ASIL',
                capacity_units=[
                    CapacityUnit(addr="192.168.253.84", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.85", hardware_type="ABIO"),
                    CapacityUnit(addr="192.168.253.86", hardware_type="ABIO")],
                pdu_port=_pdus[0].pdu_ports[2],
			)
		]
	),
)

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr='10.56.198.25',
        username='ute',
        password='ute'
        ),
        connections=[_cbts.dus[0].airscale.common_units[0], _ue],
)

tl = TestLine(test_pc=_test_pc,
              gnbs=[_cbts],
              tl_cloud_topology='CLOUD_5G_X_XX_AP_',
              ues=[_ue],
              pdus=_pdus)

__all__ = ['tl']