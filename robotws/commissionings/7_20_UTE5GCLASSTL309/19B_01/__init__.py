import os
from cloud5g.commissioning import CustomCommissioningBase
import socket

from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context='51020'):
        ALG = socket.gethostname()
        print (ALG)
        if socket.gethostname() == '7-20-UTE5GCLASSTL309':
            from taf.internal.scf import SCF
            current_dir = os.path.dirname(os.path.abspath(__file__))
            good_scf = SCF(
                "{path}/{scf}".format(
                    path=current_dir,
                    scf="SCF_5G_Load.608_Full_Configuration_scf_MRBTS-309_Nokia_Paris_Saclay_CV309_20200904-1346.xml"
                )
            )
            self.scf_handler = good_scf
