# CB009333 variables
import os

from robot.libraries.BuiltIn import BuiltIn


def get_builtin_value(param_name, default=None):
    return BuiltIn().get_variable_value('${{{}}}'.format(param_name), default)


tl = get_builtin_value(param_name="tl")
OUTPUT_DIR = BuiltIn().get_variable_value("${OUTPUT_DIR}")
SUITE_NAME = BuiltIn().get_variable_value("${SUITE_NAME}")
NOKIA_PASS = tl.gnbs[0].cu.oam_ssh_connection_details.password
NOKIA_USERNAME = tl.gnbs[0].cu.oam_ssh_connection_details.username
NOKIA_LOGIN = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
AP_IP = tl.ues[0].l1.common_units[0].lmp_connection.addr
HTTP_PASS = tl.gnbs[0].cu.oam_http_connection_details.password
HTTP_LOGIN = tl.gnbs[0].cu.oam_http_connection_details.username

# Delta Files
CB009333_A_TC001_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-A_TC001_DELTA.json')
CB009333_A_TC004_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-A_TC004_DELTA.json')
CB009333_B_TC006_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-B_TC006_DELTA.json')
CB009333_C_TC007_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-C_TC007_DELTA.json')
CB009333_C_TC011_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-C_TC011_DELTA.json')
CB009333_D_TC013_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-D_TC013_DELTA.json')
CB009333_E_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                'CB009333-E_DELTA.json')
CB009333_F_TC018_DELTA = os.path.join(os.path.dirname(os.path.realpath(__file__)), 'delta_files',
                                      'CB009333-F_TC018_DELTA.json')

# UE capability
UE_CAP_C = 'E1A05000574F5A031640030340160BF160019C2EB41409B20C39F30C7942C0E098040623800D07C4' \
           '6AAD608C21A08107880C24B64C15048E3C873E31CF9863CA16070387813F8000000FE00000001281' \
           'C46040000100EA0F11800308C000108020020230380A80A01B1CF87083639F0CFD5555504800F840' \
           '500603007403000301F0A40100000000800001004000000020000040100000400800003004000020' \
           '0200001401000802008020000180100000C0080000700400003802001000000040000400200100C0' \
           '3004000048020000280100080802002001000070040020580E0080000C9250020681A5C92800034B' \
           '9250060681A0681A5C928020340D034B92500C0681A0681A0681A069724A0100D0340D0340D2E494' \
           '0381A0681A0681A0681A069704A0000D2E4940001A9C928010340D4E4940101A0681A9C128000353' \
           '92500E0681A0681A0681A0681A9C928030340D0340D4E4940001A1C928070340D0340D0340D0340D' \
           '0E4940081A068724A00C0D0340D034382500006860080000E03B953595358295819581B5833594B5' \
           '933580B581958115943591B5BA460AD0381000009652504000065949010000296525040000E59490' \
           '1000049652404000165949010000696524040001E594901000089652404000265949010000A96524' \
           '040002E5949410000C9652504010340D965250400036594940D52AAAA55174AAAE95455058AA0715' \
           '40E2A94C55268AA031540A2A9355523AAAED4050C6052402010080C0603018040201008040203018' \
           '0C06030080402010080402010080402010080402010080402010080406000100081000C10100C018' \
           '040300002800'
# GSCN
GSCN_VALUE_FDD = {'3': '1559', '4': '1595'}
GSCN_VALUE_TDD = {'1': '7915', '2': '8019'}

# TTITrace
RELEASE_NO_CONV = 'SBTS00'
COLLECTOR_NAME = 'l2stream3'

# DCAP
BTS_DETAILS = {'host': '10.0.1.2', 'username': HTTP_LOGIN, 'password': HTTP_PASS, 'port': '443'}
DCAP_PROFILE = ['immediateSnapshot_5g', 'pmFiles5g', 'SCF5g', 'L2Ps_Sherpa', 'L2Lo_Sherpa', 'L2HiRlc_Sherpa',
                'L2HiPdcp_Sherpa', 'cp_5g', 'control_plane_interface=True', 'L2Ps_Component', 'L2Lo_Component',
                'condor5gSyslog']

# Syslog prints
SYSLOG_PRINTS_CA = ['ActiveProcedure set to scellAdditionBlind',
                    'send NrRelSCellSetupResp to cprt']
# 19/04/24: SYSLOG_PRINTS_DRX update as CPRT trace 'Drx active Available' has been removed from syslog
# SYSLOG_PRINTS_DRX = ['Drx active Available', drx OnDurationTimer::start','ActiveProcedure set to drxConfigProcedure',
#                     'ActiveProcedure reset from drxConfigProcedure, busy: true, status: Completed']
# 05/11/24: SYSLOG_PRINTS_DRX update as status format is changed
# SYSLOG_PRINTS_DRX = ['drx OnDurationTimer::start', 'ActiveProcedure set to drxConfigProcedure',
#                     'ActiveProcedure reset from drxConfigProcedure, busy: true, status: Completed']
# 21/01/25: SYSLOG_PRINTS_DRX update as status format is changed
# SYSLOG_PRINTS_DRX = ['drx OnDurationTimer::start', 'ActiveProcedure set to drxConfigProcedure',
#                     'ActiveProcedure reset from drxConfigProcedure, busy: true, status']
SYSLOG_PRINTS_DRX = ['drx OnDurationTimer::start', 'drxConfigurationMode:ACTIVATED']

NSA_ONLY_SIB_RECEPTION_DICT = {1: [1]}
CA_CELL_SIB_RECEPTION_DICT = {2: [1, 2]}
ALL_CELLS_SIB_RECEPTION_DICT = {2: [1, 2, 3, 4]}
