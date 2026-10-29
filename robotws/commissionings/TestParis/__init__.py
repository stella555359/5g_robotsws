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

    def modify_scf(self, context):
        ALG = socket.gethostname()
        print (ALG)
        if socket.gethostname() == '7-10-CLOUD5GNPVT102':
            from taf.internal.scf import SCF
            current_dir = os.path.dirname(os.path.abspath(__file__))
            good_scf = SCF("{path}/{scf}".format(path=current_dir, scf="NPV102-4CC.xml"))
            self.scf_handler = good_scf
            context.mrbts = int(self.scf_handler.raml.cmData.MRBTS[0]['distName'].split('-')[1])
            context.nrbts = int(self.scf_handler.raml.cmData.MRBTS[0].NRBTS[0]['distName'].split('-')[2])
