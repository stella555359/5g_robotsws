from robot.libraries.BuiltIn import BuiltIn
from get_bts_version import *


def Covert_BTS_Version(version):
    package = version.split('_')[0]
    if package == 'SBTS22R1':
        scf_name = 'SCF_SBTS22R1.xml'
    elif package == 'SBTS21B':
        scf_name = 'SCF_SBTS21B.xml'
    elif package == 'SBTS22R2':
        scf_name = 'SCF_SBTS00.xml'
    else:
        scf_name = 'SCF_SBTS00.xml'
    return scf_name
