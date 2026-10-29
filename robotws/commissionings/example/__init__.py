__maintainer__ = 'Artur Stepniak'
__team__ = 'I_UTE_CORE_5G'
__email__ = 'I_UTE_CORE_5G@internal.nsn.com'


################################################################################
# New custom commissioning
#
# It let's you do whatever SCF modification you want, it's not restricted by
# parameters supported by cloud agents
################################################################################
from cloud5g.commissioning import CustomCommissioningBase


# your class needs to be named 'CustomCommissioning'
# if this class is defined, legacy custom commissioning will not be performed
class CustomCommissioning(CustomCommissioningBase):
    def __init__(self, scf_path):
        # remember to call parent's class init
        super(CustomCommissioning, self).__init__(scf_path)
        # If you want agents to download SCF from non-default path on BTS,
        # you should specify the path in the below attribute.
        # Don't edit it if agent's default should be used
        self.remote_scf_path = '/bts/path/to/scf.xml'

    def modify_scf(self, context):
        # to modify SCF you should access the below attribute. It's already
        # initialized with local SCF path.
        # It's an instance of taf.internal.scf.SCF class
        taf_scf = self.scf_handler

        # agents may modify MRBTS and/or NRBTS ID's.
        # context stores the correct values of those variables
        mrbts = context.mrbts
        nrbts = context.nrbts

        # context stores many other information
        # See https://wrgitlab.int.net.nokia.com/
        # 5G/CLOUD/cloud_5g/commissioning/blob/master/cloud5g/commissioning/context.py

        # you don't need to call self.scf_handler.save()
        # the modified file will be saved automatically
