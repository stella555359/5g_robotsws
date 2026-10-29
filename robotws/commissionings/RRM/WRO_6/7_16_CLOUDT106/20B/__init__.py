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

    def modify_scf(self, context='51997'):
        if socket.gethostname() == '7-16-CLOUDT106':
            from taf.internal.scf import SCF
            current_dir = os.path.dirname(os.path.abspath(__file__))
            good_scf = SCF("{path}/{scf}".format(path=current_dir, scf="7_16_CLOUDT106.xml"))
            self.scf_handler = good_scf
