# This file will add needed testline configuration, which are not yet included in UTE Cloud

from robot.libraries.BuiltIn import BuiltIn
from taf.config.testline.core import LTEEmuCore
from taf.config.testline.enb import LTEEmuEnb

tl = BuiltIn().get_variable_value("${tl}")

_lteemu = LTEEmuCore(
    default_ssh_connection_details=tl.test_pc.default_ssh_connection_details,
    dir_path='/opt/iphy/latest',
    cfg_filename='basic_setup.cfg',
    mme_ip='10.0.1.1',
    mcc='311',
    mnc='489',
    tac=333,
    edaemon_port='22222',
    egate_port='10000')

_lteemuenb = LTEEmuEnb(
    default_ssh_connection_details=tl.test_pc.default_ssh_connection_details,
    dir_path=_lteemu.dir_path,
    cfg_filename=_lteemu.cfg_filename)

if not tl.core:
    tl.core = _lteemu

if not tl.enbs:
    tl.enbs = [_lteemuenb]

if str(tl.gnbs[0].cu.oam_http_connection_details.port) != '443':
    tl.gnbs[0].cu.oam_http_connection_details.port = 443
