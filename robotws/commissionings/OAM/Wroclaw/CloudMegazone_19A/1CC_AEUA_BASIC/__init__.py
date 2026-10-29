__maintainer__ = 'Bartlomiej Lebda'
__team__ = 'I_5GSC_5G_PZ1_WRO_6_GMS'
__email__ = 'I_5GSC_5G_PZ1_WRO_6@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11.xml'

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        for apeqm in mrbts.EQM[0].APEQM[0:]:
            apeqm.rapProfile.value = "5G19/rap/5g_pid11_eoc"

        for mnlent in mrbts.MNL[0].MNLENT[0:]:
            mnlent.FEATCADM[0].systemAcctPermEnable.value = "false"
            mnlent.SECADM[0].actServiceAccountSsh.value = "true"
            mnlent.SECADM[0].ethernetPortSecurityEnabled.value = "false"

        for cellgrp in mrbts.NRBTS[0].NRCELLGRP[1:]:
            cellgrp.remove()

        for cell in mrbts.NRBTS[0].NRCELL[1:]:
            cell.remove_tree()

        for cell in mrbts.NRBTS_1.NRCELLGRP[0].nrCellList[1:]:
            cell.remove()

        mrbts.NRBTS[0].NRDU[0].gNbDuId.value = 1
