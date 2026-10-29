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

        mrbts.EQM[0].APEQM[0].ASIRMOD[0].prodCodePlanned.value = '474657A'

        CABLINK_1 = mrbts.EQM[0].HWTOP[0].CABLINK[0]
        CABLINK_1.firstEndpointLabel.value = 'BACKPLANE'
        CABLINK_1.secondEndpointLabel.value = 'BACKPLANE'

        CABLINK_2 = mrbts.EQM[0].HWTOP[0].CABLINK[1]
        CABLINK_2.firstEndpointLabel.value = 'QSFP'
        CABLINK_2.secondEndpointLabel.value = 'SFP'
        CABLINK_2.secondEndpointPortId.value = '2'

        mrbts.MNL[0].MNLENT[0].PMCADM[0].reportingIntervalPm.value = '15min'

        mrbts.MNL[0].MNLENT[0].SYNC[0].TIME[0].timeZone.value = '(GMT+1) Europe/Warsaw'

        mrbts.NRBTS[0].actMultVlan.value = 'false'
        mrbts.NRBTS[0].TRACKINGAREA[0].fiveGsTac.value = '0'

        NRCELL_1 = mrbts.NRBTS[0].NRCELL[0]
        NRCELL_1.configuredEpsTac.value = '1'
        NRCELL_1.gscn.value = '6498'
        NRCELL_1.nrarfcn.value = '518598'
        NRCELL_1.physCellId.value = '1'
        NRCELL_1.lcrId.value = '1'
        NRCELL_1.prachConfigurationIndex.value = '96'
        NRCELL_1.pMaxNROwnCell.value = '20'
        NRCELL_1.pMax.value = '200'
        NRCELL_1.freqBandIndicatorNR.value = '41'
        NRCELL_1.tddFrameStructure[0].frameStructureType.value = 'tdLte'
        NRCELL_1.tddFrameStructure[0].guardPeriodLength.value = '4Symbols'
        NRCELL_1.tddFrameStructure[0].lteToNrFrameShift.value = '0ms'
        NRCELL_1.tddFrameStructure[0].ulDlDataSlotRatio.value = '2/8'

        NRCELL_1.actBeamforming.value = 'false'
        NRCELL_1.targetTotalLoad.value = '0'
        NRCELL_1.mcsIndexForArtificialLoad.value = '0'
        NRCELL_1.ssbScs.value = '30 KHz'
        NRCELL_1.beamSet[0].basicBeamSet.value = 'beamSet_1'

        NRCELL_1.nrCellType.value = '4DL2UL'
        NRCELL_1.cellBarred.value = 'notBarred'

        p = P().create(name='nrBtsBeamRefinementP2', value='false')
        NRCELL_1.beamSet[0].append(p)

        mrbts.NRBTS[0].NRCELLGRP[0].ssBurstSetPeriod.value = '10'
        mrbts.NRBTS[0].NRCELLGRP[0].numberOfTransmittedSsBlocks.value = '1 beam'

        NRBTS_1 = mrbts.NRBTS[0]
        if mrbts.btsName.value == '7_21_CLOUD026TL061':
            NRBTS_1.mcc.value = '460'
            NRBTS_1.mnc.value = '6'
            NRBTS_1.mncLength.value = '2'
        else:
            NRBTS_1.mcc.value = '555'
            NRBTS_1.mnc.value = '10'
            NRBTS_1.mncLength.value = '2'

        # MRBTS-1/NRBTS-1/NRCELLGRP-0  => NRCELLGRP
        id_cellgrp_to_add = [1]
        for index in id_cellgrp_to_add:
            new_cellgrp = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELLGRP-{}'.format(index)
            mrbts.NRBTS[0].NRCELLGRP[0].clone_tree_to(new_cellgrp)
            mrbts.NRBTS[0].NRCELLGRP[1].nrCellList[0].value = '2'

        id_object_to_add = [2]
        for num in id_object_to_add:
            # MRBTS-1900/EQM-1/APEQM-1/ASIRMOD-1  => HUB
            new_asirmod = 'MRBTS-' + str(mrbts_id) + '/EQM-' + str(nrbts_id) + '/APEQM-' + str(nrbts_id) + \
                          '/ASIRMOD-{}'.format(num)
            mrbts.EQM[0].APEQM[0].ASIRMOD[0].clone_tree_to(new_asirmod)
            # MRBTS-1900/EQM-1/APEQM-1/CABINET-1/BBMOD-1 => ABIL
            new_bbmod = 'MRBTS-' + str(mrbts_id) + '/EQM-' + str(nrbts_id) + '/APEQM-' + str(nrbts_id) + \
                        '/CABINET-' + str(nrbts_id) + '/BBMOD-{}'.format(num)
            mrbts.EQM[0].APEQM[0].CABINET[0].BBMOD[0].clone_tree_to(new_bbmod)
            # add cablink-2 for the first BBMod;MRBTS-1900/EQM-1/HWTOP-1/CABLINK-1 => CABLINK
            new_cablink = 'MRBTS-' + str(mrbts_id) + '/EQM-' + str(nrbts_id) + '/HWTOP-' + str(nrbts_id) + \
                          '/CABLINK-{}'.format(num)
            mrbts.EQM[0].HWTOP[0].CABLINK[1].clone_tree_to(new_cablink)
            mrbts.EQM[0].HWTOP[0].CABLINK[1].secondEndpointPortId.value = '1'

        # clone CABLINK for the second BBMOD/HUB
        id_cablink_to_add = [4, 5, 6]
        for index in id_cablink_to_add:
            new_cablink = 'MRBTS-' + str(mrbts_id) + '/EQM-' + str(nrbts_id) + '/HWTOP-' + str(nrbts_id) + \
                          '/CABLINK-{}'.format(index)
            if index == 4:
                mrbts.EQM[0].HWTOP[0].CABLINK[0].clone_tree_to(new_cablink)
                mrbts.EQM[0].HWTOP[0].CABLINK[3].firstEndpointPortId.value = '2'
                mrbts.EQM[0].HWTOP[0].CABLINK[3].secondEndpointDN.value = 'MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-2'
            elif index == 5:
                mrbts.EQM[0].HWTOP[0].CABLINK[1].clone_tree_to(new_cablink)
                mrbts.EQM[0].HWTOP[0].CABLINK[4].firstEndpointDN.value = 'MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-2'
                mrbts.EQM[0].HWTOP[0].CABLINK[4].secondEndpointDN.value = 'MRBTS-1/EQM-1/APEQM-1/ASIRMOD-2'
            else:
                mrbts.EQM[0].HWTOP[0].CABLINK[2].clone_tree_to(new_cablink)
                mrbts.EQM[0].HWTOP[0].CABLINK[5].firstEndpointDN.value = 'MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-2'
                mrbts.EQM[0].HWTOP[0].CABLINK[5].secondEndpointDN.value = 'MRBTS-1/EQM-1/APEQM-1/ASIRMOD-2'

        # MRBTS-1900/NRBTS-1/NRCELL-1  => Cell
        id_cell_to_add = [2]
        for num in id_cell_to_add:
            new_nrcell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-{}'.format(num)
            mrbts.NRBTS[0].NRCELL[0].clone_tree_to(new_nrcell)

            new_lcelnr = 'MRBTS-' + str(mrbts_id) + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'.format(num)
            mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[0].clone_tree_to(new_lcelnr)

            # set the clone LCELNR to ASIRMOD-2
            for index in range(1, 5):
                if index in [1, 2]:
                    mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[index - 1].antlDN.value = \
                            'MRBTS-1/EQM-1/APEQM-1/ASIRMOD-2/ASIANTL-1'
                else:
                    mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[1].CHANNELGROUP[0].CHANNEL[index - 1].antlDN.value = \
                            'MRBTS-1/EQM-1/APEQM-1/ASIRMOD-2/ASIANTL-2'

            # add ASIRMOD channel group & set them to the target value
            for index in [1, 2]:
                chan5 = 'MRBTS-' + str(mrbts_id) + \
                    '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{0}/CHANNELGROUP-1/CHANNEL-{1}'.format(index, num + 4)
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[index - 1].CHANNELGROUP[0].CHANNEL[2].clone_tree_to(chan5)
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[index - 1].CHANNELGROUP[0].CHANNEL[4].antlDN.value = \
                    'MRBTS-1/EQM-1/APEQM-1/ASIRMOD-{0}/ASIANTL-3'.format(index)
                chan6 = 'MRBTS-' + str(mrbts_id) + \
                    '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{0}/CHANNELGROUP-1/CHANNEL-{1}'.format(index, num + 5)
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[index - 1].CHANNELGROUP[0].CHANNEL[2].clone_tree_to(chan6)
                mrbts.MNL[0].MNLENT[0].CELLMAPPING[0].LCELNR[index - 1].CHANNELGROUP[0].CHANNEL[5].antlDN.value = \
                    'MRBTS-1/EQM-1/APEQM-1/ASIRMOD-{0}/ASIANTL-4'.format(index)

            mrbts.NRBTS[0].NRCELL[num - 1].nrCellType.value = '4DL2UL'
            mrbts.NRBTS[0].NRCELL[num - 1].cellBarred.value = 'notBarred'

            nrarfcns_2cells = ['518598', '518598']
            mrbts.NRBTS[0].NRCELL[num - 1].nrarfcn.value = nrarfcns_2cells[num - 1]

        # set physical cell id and lcrid
        for cell in range(0, 2):
            if cell > 0:
                mrbts.NRBTS[0].NRCELL[cell].physCellId.value += cell
                mrbts.NRBTS[0].NRCELL[cell].lcrId.value += cell

        # to add nrcellgrp list MRBTS-1900/NRBTS-1/NRDU-1
        num_of_cells_to_add = 1
        nrcellgrp = [0]
        for number in nrcellgrp:
            list = mrbts.NRBTS[0].NRDU[number].refNrCellGroup
            new = int(mrbts.NRBTS[0].NRDU[number].refNrCellGroup[0].value) + 1
            for num in range(new, new + num_of_cells_to_add):
                p = P().create(value=num)
                list.append(p)

        # change cell parameters to make it could be reach on-air status
        # MRBTS-1900/NRBTS-1/NRCELL-1/2
        for index in [1, 2]:
            mrbts.NRBTS[0].NRCELL[index - 1].actDl256Qam.value = 'true'
            mrbts.NRBTS[0].NRCELL[index - 1].dlMimoMode.value = '4x4 or 4x2 Closed Loop Spatial Multiplexing'
