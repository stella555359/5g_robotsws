import os
from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
        SshServiceDetails,
        OpenStackConnectionDetails,
        BmcConnectionDetails,
        HttpConnectionDetails)
from taf.config.testline.cloud_hosting import (
        NCIR,
        ControlNode,
        CloudDeployment,
        DeploymentFlavorStack,
        DeploymentNetworkStack,
        DeploymentVnfStack)
from taf.config.testline.gnb.gnb import ClassicalBts, CU, DU
from taf.config.testline.legacy import (CONFIG_5G, AirPhone, Control, Host,
                                        L1emu, SCF, EPCSim, RF, Pdu)
from taf.config.testline.core import EPCSim, LTEEmuCore
from taf.config.testline.ue import Airphone, AirphoneCloud
from taf.config.testline.pdu import ATEN
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit
from taf.compatibility.configuration import TestlineWrapper
from taf.config.cbts import create_configuration_data
from taf.config.testline.pdu import FACOM
from taf.config.testline.legacy import (SCF)
from taf.config.testline import RealEnb, LTEEmuEnb
from getpass import getpass


isAio = False
L1byPass_flag = None
AIRPHONE_airscaleNodeID = ['0x50', '0x52']
airscaleNodeID = ['0x10', '0x12']
airphone_testline_type = 'irfhead'
tlName = "tl33-5gbts"

# For automatic install
gNB_Package_path = '/ebs/selamri/YAFT'
YAFT_path = '/ebs/selamri/YAFT'
_CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_cu = CU(backhaul_site_oam_ip='10.14.33.180',
         oam_ssh_connection_details=SshServiceDetails(
             addr='10.14.33.180', username='toor4nsn', password='oZPS0POrRieRtu'),
         oam_http_connection_details=HttpConnectionDetails(
             addr='10.14.33.180', username='Nemuadmin', password='nemuuser', port=3600))

_pdu = ATEN(addr='10.14.32.68', port_numbers=[1, 2])

_common_unit_0 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='10.14.33.180', username='toor4nsn', password='oZPS0POrRieRtu'),
    capacity_units=None,
    pdu_port=_pdu.pdu_ports[1])

_airscale = Airscale(common_units=[_common_unit_0])
_du = DU(airscale=_airscale)
_cbts = ClassicalBts(cu=_cu, dus=[_du])
_test_pc = TestPc(default_ssh_connection_details=SshServiceDetails(
    addr='10.181.49.46', username='ca_psci5g', password='Welcome123'))
_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr='10.14.33.176', username='ute', password='ute'),
    dir_path='/home/ute/WTS/',
    cfg_filename='TL33_basic_wts_step2.cfg',
    mme_ip='',
    edaemon_port='22222', egate_port='9880')
# AirPhone
_l3 = SshServiceDetails(
    addr='10.5.112.73',
    username='toor4nsn',
    password='oZPS0POrRieRtu')
_l2 = SshServiceDetails(
    addr='10.5.112.73',
    username='toor4nsn',
    password='oZPS0POrRieRtu')

_lteSim = LTEEmuEnb(
    default_ssh_connection_details=SshServiceDetails(
        addr='10.14.33.176',
        username='ute',
        password='ute'
    ),
    dir_path='/home/ute/WTS',
    cfg_filename='TL33_basic_wts_step2.cfg')

_airphone_common_unit_1 = CommonUnit(
                lmp_connection=SshServiceDetails(
                    addr='10.5.112.73',
                    username='toor4nsn',
                    password='oZPS0POrRieRtu'),
                capacity_units=[],
                pdu_port=_pdu.pdu_ports[2])

_airphone_cloud = AirphoneCloud(oam_ssh_connection_details=SshServiceDetails(
                                addr='10.5.112.73', username='toor4nsn', password='oZPS0POrRieRtu'),
                                oam_http_connection_details=HttpConnectionDetails(
                                addr='10.5.112.73', username='Nemuadmin', password='nemuuser'))

_airphone_capacity_unit_1 = CapacityUnit(addr='10.5.112.73')

_airphone_airscale = Airscale(common_units=[_airphone_common_unit_1])

_airphone = Airphone(egate=None,
                     airphone_cloud=_airphone_cloud,
                     l1=_airphone_airscale,
                     l3_ssh_connection_details=_l3,
                     l2_ssh_connection_details=_l2)

tl = TestLine(test_pc=_test_pc, gnbs=[_cbts], enbs=[_lteSim], core=_lteemu, ues=[_airphone],
              tl_cloud_topology='CLOUD_5G_CLASSICAL_ASIK_ABIL_AEUA_cOAM')
tl = TestlineWrapper(tl)
