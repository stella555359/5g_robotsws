from taf.config.testline.testline import TestLine
from taf.config.testline.testpc import TestPc
from taf.config.testline.connection_details import (
        SshServiceDetails,
        HttpConnectionDetails)
from taf.config.testline.gnb import ClassicalBts, CU, DU
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.ue import Airphone
from taf.config.testline import RU, DU
from taf.config.testline.airscale import Airscale, CommonUnit, CapacityUnit


_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr='127.0.0.1',
        username='ute',
        password='ute'))

_lteemu = LTEEmuCore(
    default_ssh_connection_details=SshServiceDetails(
        addr='127.0.0.1',
        username='ute',
        password='ute'),
    dir_path='/opt/iphy',
    cfg_filename='basic_wts_step2.cfg',
    mme_ip='10.0.1.1',
    mcc='311',
    mnc='489',
    tac=333,
    edaemon_port='22222',
    egate_port='10000')


_cu = CU(
    backhaul_site_oam_ip='192.168.255.1',
    oam_ssh_connection_details=SshServiceDetails(
        addr='192.168.255.1',
        username='toor4nsn',
        password='oZPS0POrRieRtu'),
    oam_http_connection_details=HttpConnectionDetails(
        addr='192.168.255.1',
        username='Nemuadmin',
        password='nemuuser',
        port=443))

_capacity_unit = CapacityUnit(
    addr='192.168.253.20')

_common_unit = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.255.1',
        username='toor4nsn',
        password='oZPS0POrRieRtu'),
    capacity_units=[_capacity_unit])

_airscale = Airscale(
    common_units=[_common_unit])

_du = DU(
    airscale=_airscale,
    rus=[])

_cbts = ClassicalBts(
    cu=_cu,
    dus=[_du])

_l3 = SshServiceDetails(
    addr='192.168.200.1',
    username='toor4nsn',
    password='oZPS0POrRieRtu')

_l2 = SshServiceDetails(
    addr='192.168.200.1',
    username='toor4nsn',
    password='oZPS0POrRieRtu')

_airphone_capacity_unit_1 = CapacityUnit(
    addr='192.168.253.84')

_airphone_common_unit_1 = CommonUnit(
    lmp_connection=SshServiceDetails(
        addr='192.168.200.1',
        username='toor4nsn',
        password='oZPS0POrRieRtu'),
    capacity_units=[_airphone_capacity_unit_1])

_airphone_airscale = Airscale(
    common_units=[_airphone_common_unit_1])

_airphone = Airphone(
    egate=_lteemu.default_ssh_connection_details,
    l1=_airphone_airscale,
    l3_ssh_connection_details=_l3,
    l2_ssh_connection_details=_l2)

# Testline
tl = TestLine(
    test_pc=_test_pc,
    gnbs=[_cbts],
    core=_lteemu,
    tl_cloud_topology='',
    ues=[_airphone])
