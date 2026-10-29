__maintainer__ = 'Bartlomiej Lebda'
__team__ = 'I_5GSC_5G_PZ1_WRO_6_GMS'
__email__ = 'I_5GSC_5G_PZ1_WRO_6@internal.nsn.com'

from cloud5g.commissioning import CustomCommissioningBase
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = '/opt/nokia/SS_MzOam/cloud-siteoam/siteoam/site_conf/5G19/SBTS5G19_5g_pid11.xml'

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts_id = context.mrbts

        for apeqm in mrbts.EQM[0].APEQM[0:]:
            apeqm.rapProfile.value = "5G19/rap/5g_pid11_4CC_eoc"

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

        num_of_cells_to_add = 3
        nrcellgrp = [0]

        for number in nrcellgrp:
            list = mrbts.NRBTS[0].NRCELLGRP[number].nrCellList
            new = int(mrbts.NRBTS[0].NRCELLGRP[number].nrCellList[0].value) + 1
            for num in range(new, new + num_of_cells_to_add):
                p = P().create(value=num)
                list.append(p)

        id_cells_to_add = [2, 3, 4]
        for num in id_cells_to_add:
            new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELL-{}'.format(num)
            mrbts.NRBTS[0].NRCELL[0].clone_tree_to(new_nrcell)

        value = 0
        for cell in range(0, 4):
            if cell > 0:
                mrbts.NRBTS[0].NRCELL[cell].physCellId.value += value
                mrbts.NRBTS[0].NRCELL[cell].lcrId.value -= value
            mrbts.NRBTS[0].NRCELL[cell].pMax.value = 210
            value += 1

        nrarfcn_4cells = {mrbts.NRBTS[0].NRCELL[0].nrarfcn: '2073979',
                          mrbts.NRBTS[0].NRCELL[1].nrarfcn: '2075645',
                          mrbts.NRBTS[0].NRCELL[2].nrarfcn: '2077311',
                          mrbts.NRBTS[0].NRCELL[3].nrarfcn: '2078977'
                          }

        for p, p_value in nrarfcn_4cells.items():
            p.value = p_value

        gscn_4cells = {mrbts.NRBTS[0].NRCELL[0].gscn: '22454',
                       mrbts.NRBTS[0].NRCELL[1].gscn: '22460',
                       mrbts.NRBTS[0].NRCELL[2].gscn: '22466',
                       mrbts.NRBTS[0].NRCELL[3].gscn: '22472',
                       }

        for p, p_value in gscn_4cells.items():
            p.value = p_value

        mrbts.NRBTS[0].NRDU[0].gNbDuId.value = 1
