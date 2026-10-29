from robot.libraries.BuiltIn import BuiltIn
from get_du_version import *


def Covert_BTS_Version(version):
    package = version.split('_')[0]
    if package == 'SBTS22R2':
        scf_name = 'SCF_SBTS22R2_60_100M.xml'
    elif package == 'SBTS22R3':
        scf_name = 'SCF_SBTS22R3_60_100M.xml'
    elif package == 'SBTS22R4':
        scf_name = 'SCF_SBTS00_60_100M.xml'
    else:
        scf_name = 'SCF_SBTS00_60_100M.xml'
    return scf_name
