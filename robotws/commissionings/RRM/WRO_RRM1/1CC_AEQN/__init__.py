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

        CABLINK_1 = mrbts.EQM[0].HWTOP[0].CABLINK[0]
        CABLINK_1.firstEndpointLabel.value = 'BACKPLANE'
        CABLINK_1.secondEndpointLabel.value = 'BACKPLANE'

        CABLINK_2 = mrbts.EQM[0].HWTOP[0].CABLINK[1]
        CABLINK_2.firstEndpointPortId.value = '1'
        CABLINK_2.secondEndpointPortId.value = '2'

        mrbts.MNL[0].MNLENT[0].PMCADM[0].reportingIntervalPm.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrX2CB.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrF1CD.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrRacCu.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrF1CC.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrF1UCInterface.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrF1UDInterface.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrF1UU.value = '5min'
        mrbts.NRBTS[0].NRPMRNL[0].miNrX2UInterface.value = '5min'
        mrbts.NRBTS[0].freqBandIndicatorEutra[0].value = '28'
        mrbts.NRBTS[0].nsaInactivityTimer.value = '3600'
        mrbts.NRBTS[0].actMultVlan.value = 'true'
        mrbts.NRBTS[0].TRACKINGAREA[0].fiveGsTac.value = '124'

        mrbts.MNL[0].MNLENT[0].SYNC[0].TIME[0].timeZone.value = '(GMT+1) Europe/Warsaw'
        mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].syncInputList[0].\
            syncInputType.value = '1pps/ToD from external GNSS receiver'

        NRCELL_1 = mrbts.NRBTS[0].NRCELL[0]
        NRCELL_1.configuredEpsTac.value = '124'
        NRCELL_1.gscn.value = '1'
        NRCELL_1.physCellId.value = '50'
        NRCELL_1.lcrId.value = '1'
        NRCELL_1.prachConfigurationIndex.value = '98'
        NRCELL_1.tddFrameStructure[0].frameStructureType.value = 'semiStatic'
        NRCELL_1.tddFrameStructure[0].guardPeriodLength.value = '2Symbols'
        # NRCELL_1.tddFrameStructure[0].lteToNrFrameShift.value = '0ms'
        NRCELL_1.tddFrameStructure[0].ulDlDataSlotRatio.value = '1/4'
