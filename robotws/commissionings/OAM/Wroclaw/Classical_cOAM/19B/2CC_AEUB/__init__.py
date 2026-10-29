__maintainer__ = 'Pawel Rokicki'
__team__ = '5G_IV7_WRO_6'
__email__ = 'I_MN_5GSC_PZ_5G_IV7_WRO_6@internal.nsn.com'

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

        if distname is not None:
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
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        # add cablink and bbmod
        mrbts.EQM[0].HWTOP[0].CABLINK[0].firstEndpointLabel.value = "BACKPLANE"
        mrbts.EQM[0].HWTOP[0].CABLINK[0].secondEndpointLabel.value = "BACKPLANE"

        # modify cell_1
        mrbts.NRBTS_1.NRCELL[0].configuredEpsTac.value = '0'
        mrbts.NRBTS_1.NRCELL[0].gscn.value = '22446'
        mrbts.NRBTS_1.NRCELL[0].dllaIniMcs.value = '8'
        mrbts.NRBTS_1.NRCELL[0].nrarfcn.value = '2071675'
        mrbts.NRBTS_1.NRCELL[0].pMax.value = '190'
        mrbts.NRBTS_1.NRCELL[0].type0SearchSpaceConfigurationIndex.value = '0'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].frameStructureType.value = 'semiStatic'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].guardPeriodLength.value = '2Symbols'
        mrbts.NRBTS_1.NRCELL[0].tddFrameStructure[0].ulDlDataSlotRatio.value = '1/4'

        # add new cell
        num = 2
        new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-1/NRCELL-2'
        mrbts.NRBTS_1.NRCELL[0].clone_tree_to(new_nrcell)

        list = mrbts.NRBTS_1.NRCELLGRP[0].nrCellList
        p = P().create(value=num)
        list.append(p)

        mrbts.NRBTS_1.NRCELL[1].nrarfcn.value = 2073339
        mrbts.NRBTS_1.NRCELL[1].gscn.value = 22452
        mrbts.NRBTS_1.NRCELL[1].physCellId.value += 1
        mrbts.NRBTS_1.NRCELL[1].lcrId.value += 1

        new_lcelnr = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'
        mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].clone_tree_to(new_lcelnr)
