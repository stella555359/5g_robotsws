from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)
        self.remote_scf_path = ''

    def modify_scf(self, context):
        taf_scf = self.scf_handler
        mrbts = taf_scf.raml.cmData.MRBTS[0]
        mrbts.NRBTS[0].NRCELL[0].nrarfcn.value = '633372'
        mrbts.NRBTS[0].NRCELL[0].frequencyDensityThresNrb0.value = '277'
        mrbts.NRBTS[0].NRCELL[0].frequencyDensityThresNrb1.value = '277'
        mrbts.NRBTS[0].NRCELL[0].gscn.value = '1584'
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].nrarfcnDl.value = '126900'
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].nrarfcnUl.value = '136100'
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].chBwDl.value = '20MHz'
        mrbts.NRBTS[0].NRCELL[0].NRCELL_FDD[0].chBwUl.value = '20MHz'
        mrbts.NRBTS[0].NRCELL[0].p0NominalPucch.value = '-82'
        mrbts.NRBTS[0].NRCELL[0].p0NominalPusch.value = '-72'
        mrbts.NRBTS[0].NRCELL[0].preambleTransMax.value = 'n200'
        mrbts.NRBTS[0].NRCELL[0].prachConfigurationIndex.value = '12'
        mrbts.NRBTS[0].NRCELL[0].rsrpThresholdSSB.value = '11'
        mrbts.NRBTS[0].NRCELL[0].ssPbchBlockPower.value = '0'
        mrbts.NRBTS[0].NRCELL[0].zeroCorrelationZoneConfig.value = '14'
        mrbts.NRBTS[0].NRCELL[0].ssBurstSetPeriod.value = '20'
        mrbts.NRBTS[0].NRCELL[0].type0CoresetConfigurationIndex.value = '7'
        mrbts.NRBTS[0].NRCELL[0].type0SearchSpaceConfigurationIndex.value = '4'
        mrbts.NRBTS[0].NRCELL[0].pMax.value = '260'
        mrbts.NRBTS[0].NRCELL[0].physCellId.value = '60'
        mrbts.NRBTS[0].NRCUUP[0].gNbCuUpId.value = '0'
        mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].outputConfiguration1Pps.value = 'EnabledWithBtsInputReference'
        mrbts.MNL[0].MNLENT[0].SYNC[0].CLOCK[0].GNSSE[0].gnssControlMode.value = 'GPS-GLONASS'
        mrbts.NRBTS[0].SNSSAI[0].sd.value = '13714341'
