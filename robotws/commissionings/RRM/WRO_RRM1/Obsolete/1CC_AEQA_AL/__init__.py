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
        mrbts = taf_scf.raml.cmData.MRBTS[0]

        mrbts.MNL[0].MNLENT[0].PMCADM[0].reportingIntervalPm.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrCellUtilization.value = '5min'

        mrbts.MNL[0].MNLENT[0].SYNC[0].TIME[0].timeZone.value = '(GMT+1) Europe/Warsaw'
        mrbts.NRBTS[0].actMultVlan.value = 'true'
        mrbts.NRBTS[0].TRACKINGAREA[0].fiveGsTac.value = '7150'

        NRCELL_1 = mrbts.NRBTS[0].NRCELL[0]
        NRCELL_1.configuredEpsTac.value = '7150'
        NRCELL_1.gscn.value = '1'
        NRCELL_1.nrarfcn.value = '633334'
        NRCELL_1.physCellId.value = '50'
        NRCELL_1.prachConfigurationIndex.value = '98'
        NRCELL_1.drxProfile1[0].drxInactivityTimer.value = '20ms'
        NRCELL_1.tddFrameStructure[0].frameStructureType.value = 'semiStatic'
        NRCELL_1.tddFrameStructure[0].guardPeriodLength.value = '2Symbols'
        NRCELL_1.tddFrameStructure[0].lteToNrFrameShift.value = '0ms'
        NRCELL_1.tddFrameStructure[0].ulDlDataSlotRatio.value = '1/4'

        NRCELL_1.actBeamforming.value = 'true'
        NRCELL_1.targetTotalLoad.value = '100'
        NRCELL_1.mcsIndexForArtificialLoad.value = '0'
        NRCELL_1.beamSet[0].basicBeamSet.value = 'beamSet_8'
        NRCELL_1.beamSet[0].nrBtsBeamRefinementP2.value = 'false'
        NRCELL_1.ssbScs.value = '30 KHz'
        mrbts.NRBTS[0].NRCELLGRP[0].ssBurstSetPeriod.value = '20'
        mrbts.NRBTS[0].NRCELLGRP[0].numberOfTransmittedSsBlocks.value = '8 beams'
