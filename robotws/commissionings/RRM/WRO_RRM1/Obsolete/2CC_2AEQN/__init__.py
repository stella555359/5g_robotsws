from cloud5g.commissioning import CustomCommissioningBase

from taf.internal.scf.managed_object import ManagedObject
from taf.internal.scf.list import List
from taf.internal.scf.list import Item
from taf.internal.scf.list import P


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def add_object_with_params(self, distname=None, klass=None, version=None, list_name=None, mo=None, **kwargs):

        if klass is not None:
            mo = ManagedObject().create(klass=klass, dist_name=distname, version=version, operation="create")

        if kwargs:
            if list_name is not None:
                for name, value in kwargs.items():
                    new_list = List().create(list_name)
                    item = Item().create()
                    p = P().create(name=name, value=value)
                    item.append(p)
                    new_list.append(item)
                    mo.append(new_list)

            else:
                for name, value in kwargs.items():
                    p = P().create(name=name, value=value)
                    mo.append(p)

        self.scf_handler.raml.cmData.append(mo)

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts_id = context.mrbts
        nrbts_id = context.nrbts
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        id_radio_to_add = [2]
        for num in id_radio_to_add:
            new_rmod = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-{}'.format(num)
            mrbts.EQM[0].APEQM[0].RMOD[0].clone_tree_to(new_rmod)

        prod_code = {mrbts.EQM[0].APEQM[0].RMOD[0].prodCodePlanned: '474736A.101',
                     mrbts.EQM[0].APEQM[0].RMOD[1].prodCodePlanned: '474736A.X21'
                     }

        for p, p_value in prod_code.items():
            p.value = p_value

        CABLINK_1 = mrbts.EQM[0].HWTOP[0].CABLINK[0]
        CABLINK_1.firstEndpointLabel.value = 'BACKPLANE'
        CABLINK_1.secondEndpointLabel.value = 'BACKPLANE'

        CABLINK_3 = mrbts.EQM[0].HWTOP[0].CABLINK[2]
        CABLINK_3.secondEndpointDN.value = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-2'
        CABLINK_3.secondEndpointPortId.value = '2'

        mrbts.MNL[0].MNLENT[0].PMCADM[0].reportingIntervalPm.value = '15min'

        mrbts.MNL[0].MNLENT[0].SYNC[0].TIME[0].timeZone.value = '(GMT+1) Europe/Warsaw'
        mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList[0]. \
            syncInputType.value = '1pps/ToD from external GNSS receiver'
        mrbts.NRBTS[0].actMultVlan.value = 'true'
        mrbts.NRBTS[0].TRACKINGAREA[0].fiveGsTac.value = '124'

        NRCELL_1 = mrbts.NRBTS[0].NRCELL[0]
        NRCELL_1.configuredEpsTac.value = '124'
        NRCELL_1.gscn.value = '1'
        NRCELL_1.physCellId.value = '50'
        NRCELL_1.lcrId.value = '1'
        NRCELL_1.prachConfigurationIndex.value = '98'
        NRCELL_1.tddFrameStructure[0].frameStructureType.value = 'semiStatic'
        NRCELL_1.tddFrameStructure[0].guardPeriodLength.value = '2Symbols'
        NRCELL_1.tddFrameStructure[0].lteToNrFrameShift.value = '0ms'
        NRCELL_1.tddFrameStructure[0].ulDlDataSlotRatio.value = '1/4'

        mrbts.TNLSVC[0].TNL[0].IPNO[0].IPRT[0].staticRoutes.remove()

        id_cells_to_add = [2]
        for num in id_cells_to_add:
            new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-{}'.format(num)
            mrbts.NRBTS[0].NRCELL[0].clone_tree_to(new_nrcell)

            new_lcelnr = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.format(num)
            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].clone_tree_to(new_lcelnr)

        for channel in mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[0:]:
            channel.resourceDN.value = 'MRBTS-' + str(mrbts_id) + '/EQM-1/APEQM-1/RMOD-2/PHYANT-1'

        id_cellgrp_to_add = [1]
        for num in id_cellgrp_to_add:
            new_cellgrp = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELLGRP-{}'.format(num)
            mrbts.NRBTS[0].NRCELLGRP[0].clone_tree_to(new_cellgrp)

        mrbts.NRBTS[0].NRCELLGRP[1].nrCellList.remove()
        new_list = List().create("nrCellList")
        p = P().create(value=id_cells_to_add[0])
        new_list.append(p)
        mrbts.NRBTS[0].NRCELLGRP[1].append(new_list)

        p = P().create(value=id_cellgrp_to_add[0])
        mrbts.NRBTS[0].NRDU[0].refNrCellGroup.append(p)

        value = 50
        for cell in range(0, 2):
            if cell > 0:
                mrbts.NRBTS[0].NRCELL[cell].physCellId.value = value
                mrbts.NRBTS[0].NRCELL[cell].lcrId.value += cell
            value += 1
