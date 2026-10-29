from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf import SCF
import os


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        src_file_name = ''
        commissioning_dir = os.path.dirname(os.path.abspath(__file__))
        for file_name in os.listdir(commissioning_dir):
            if file_name.endswith('.xml'):
                src_file_name = file_name

        if os.path.exists(self.scf_path):
            os.rename(self.scf_path, os.path.join(os.path.dirname(self.scf_path), 'BKUP_' + 'SCFC.xml'))

        if len(src_file_name) != 0 and os.path.exists(os.path.join(commissioning_dir, src_file_name)):
            self.scf_handler = SCF(os.path.join(commissioning_dir, src_file_name))
