BTS_DIST = 'MRBTS-37611/NRBTS-37611'


tddFrameStructure_1 = [{
            'frameStructureType': 'tdLte',
            'guardPeriodLength': '4Symbols',
            'lteToNrFrameShift': '3ms',
            'tdLteUlDlConfig': 'tdLteConfig2'
         }
    ]


tddFrameStructure_2 = [{
            'frameStructureType': 'semiStatic',
            'guardPeriodLength': '2Symbols',
            'ulDlDataSlotRatio': '3/7'
         }
    ]


tddFrame_cb008406 = [{
            'frameStructureType': 'semiStatic',
            'guardPeriodLength': '4Symbols',
            'tdLteUlDlConfig': 'tdLteConfig2',
            'ulDlDataSlotRatio': '4/6'
         }
    ]


"""
   <managedObject class="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON" distName="MRBTS-37611/NRBTS-37611/
   BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1" version="NRBTSCL26R2_2602_101" operation="create">
      <list name="searchSpaceCommon">
        <item>
          <p name="coresetId">0</p>
          <p name="dciFormat">formats0-0-And-1-0</p>
          <p name="duration">1</p>
          <p name="monitoringSymbolWithinSlot">symbol_0</p>
          <p name="numOfPdcchCandidatesInAL16">n0</p>
          <p name="numOfPdcchCandidatesInAL2">n0</p>
          <p name="numOfPdcchCandidatesInAL4">n2</p>
          <p name="numOfPdcchCandidatesInAL8">n0</p>
          <p name="periodicity">sl10</p>
          <p name="searchSpaceId">1</p>
          <p name="searchSpaceType">Type0A</p>
          <p name="slotOffset">6</p>
        </item>
        <item>
          <p name="coresetId">0</p>
          <p name="dciFormat">formats0-0-And-1-0</p>
          <p name="duration">1</p>
          <p name="monitoringSymbolWithinSlot">symbol_0_1</p>
          <p name="numOfPdcchCandidatesInAL16">n0</p>
          <p name="numOfPdcchCandidatesInAL2">n0</p>
          <p name="numOfPdcchCandidatesInAL4">n2</p>
          <p name="numOfPdcchCandidatesInAL8">n0</p>
          <p name="periodicity">sl1</p>
          <p name="searchSpaceId">2</p>
          <p name="searchSpaceType">Type1</p>
          <p name="slotOffset">0</p>
        </item>
        <item>
          <p name="coresetId">0</p>
          <p name="dciFormat">formats0-0-And-1-0</p>
          <p name="duration">3</p>
          <p name="monitoringSymbolWithinSlot">symbol_0</p>
          <p name="numOfPdcchCandidatesInAL16">n0</p>
          <p name="numOfPdcchCandidatesInAL2">n0</p>
          <p name="numOfPdcchCandidatesInAL4">n2</p>
          <p name="numOfPdcchCandidatesInAL8">n0</p>
          <p name="periodicity">sl10</p>
          <p name="searchSpaceId">3</p>
          <p name="searchSpaceType">Type2</p>
          <p name="slotOffset">0</p>
        </item>
      </list>
    </managedObject>
 """
searchSpaceCommon = [
    {
        'coresetId': 0,
        'dciFormat': 'formats0-0-And-1-0',
        'duration': 1,
        'monitoringSymbolWithinSlot': 'symbol_0',
        'numOfPdcchCandidatesInAL16': 'n0',
        'numOfPdcchCandidatesInAL2': 'n0',
        'numOfPdcchCandidatesInAL4': 'n2',
        'numOfPdcchCandidatesInAL8': 'n0',
        'periodicity': 'sl10',
        'searchSpaceId': 1,
        'searchSpaceType': 'Type0A',
        'slotOffset': 6
    },
    {
        'coresetId': 0,
        'dciFormat': 'formats0-0-And-1-0',
        'duration': 1,
        'monitoringSymbolWithinSlot': 'symbol_0_1',
        'numOfPdcchCandidatesInAL16': 'n0',
        'numOfPdcchCandidatesInAL2': 'n0',
        'numOfPdcchCandidatesInAL4': 'n2',
        'numOfPdcchCandidatesInAL8': 'n0',
        'periodicity': 'sl1',
        'searchSpaceId': 2,
        'searchSpaceType': 'Type1',
        'slotOffset': 0
    },
    {
        'coresetId': 0,
        'dciFormat': 'formats0-0-And-1-0',
        'duration': 3,
        'monitoringSymbolWithinSlot': 'symbol_0',
        'numOfPdcchCandidatesInAL16': 'n0',
        'numOfPdcchCandidatesInAL2': 'n0',
        'numOfPdcchCandidatesInAL4': 'n2',
        'numOfPdcchCandidatesInAL8': 'n0',
        'periodicity': 'sl10',
        'searchSpaceId': 3,
        'searchSpaceType': 'Type2',
        'slotOffset': 0
    }
]


"""
    <managedObject class="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON" distName="MRBTS-37611/NRBTS-37611/
    BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1" version="NRBTSCL26R2_2602_101" operation="create">
      <list name="searchSpaceCommon">
        <item>
          <p name="coresetId">0</p>
          <p name="dciFormat">formats0-0-And-1-0</p>
          <p name="duration">1</p>
          <p name="monitoringSymbolWithinSlot">symbol_0</p>
          <p name="numOfPdcchCandidatesInAL16">n0</p>
          <p name="numOfPdcchCandidatesInAL2">n0</p>
          <p name="numOfPdcchCandidatesInAL4">n2</p>
          <p name="numOfPdcchCandidatesInAL8">n0</p>
          <p name="periodicity">sl10</p>
          <p name="searchSpaceId">4</p>
          <p name="searchSpaceType">Type0A</p>
          <p name="slotOffset">6</p>
        </item>
        <item>
          <p name="coresetId">0</p>
          <p name="dciFormat">formats0-0-And-1-0</p>
          <p name="duration">1</p>
          <p name="monitoringSymbolWithinSlot">symbol_0_1</p>
          <p name="numOfPdcchCandidatesInAL16">n0</p>
          <p name="numOfPdcchCandidatesInAL2">n0</p>
          <p name="numOfPdcchCandidatesInAL4">n2</p>
          <p name="numOfPdcchCandidatesInAL8">n0</p>
          <p name="periodicity">sl1</p>
          <p name="searchSpaceId">5</p>
          <p name="searchSpaceType">Type1</p>
          <p name="slotOffset">0</p>
        </item>
        <item>
          <p name="coresetId">0</p>
          <p name="dciFormat">formats0-0-And-1-0</p>
          <p name="duration">3</p>
          <p name="monitoringSymbolWithinSlot">symbol_0</p>
          <p name="numOfPdcchCandidatesInAL16">n0</p>
          <p name="numOfPdcchCandidatesInAL2">n0</p>
          <p name="numOfPdcchCandidatesInAL4">n2</p>
          <p name="numOfPdcchCandidatesInAL8">n0</p>
          <p name="periodicity">sl10</p>
          <p name="searchSpaceId">6</p>
          <p name="searchSpaceType">Type2</p>
          <p name="slotOffset">0</p>
        </item>
      </list>
    </managedObject>
"""
searchSpaceCommon_1 = [
    {
        'coresetId': 0,
        'dciFormat': 'formats0-0-And-1-0',
        'duration': 1,
        'monitoringSymbolWithinSlot': 'symbol_0',
        'numOfPdcchCandidatesInAL16': 'n0',
        'numOfPdcchCandidatesInAL2': 'n0',
        'numOfPdcchCandidatesInAL4': 'n2',
        'numOfPdcchCandidatesInAL8': 'n0',
        'periodicity': 'sl10',
        'searchSpaceId': 4,
        'searchSpaceType': 'Type0A',
        'slotOffset': 6
    },
    {
        'coresetId': 0,
        'dciFormat': 'formats0-0-And-1-0',
        'duration': 1,
        'monitoringSymbolWithinSlot': 'symbol_0_1',
        'numOfPdcchCandidatesInAL16': 'n0',
        'numOfPdcchCandidatesInAL2': 'n0',
        'numOfPdcchCandidatesInAL4': 'n2',
        'numOfPdcchCandidatesInAL8': 'n0',
        'periodicity': 'sl1',
        'searchSpaceId': 5,
        'searchSpaceType': 'Type1',
        'slotOffset': 0
    },
    {
        'coresetId': 0,
        'dciFormat': 'formats0-0-And-1-0',
        'duration': 3,
        'monitoringSymbolWithinSlot': 'symbol_0',
        'numOfPdcchCandidatesInAL16': 'n0',
        'numOfPdcchCandidatesInAL2': 'n0',
        'numOfPdcchCandidatesInAL4': 'n2',
        'numOfPdcchCandidatesInAL8': 'n0',
        'periodicity': 'sl10',
        'searchSpaceId': 6,
        'searchSpaceType': 'Type2',
        'slotOffset': 0
    }
]


"""
      <list name="coresetDedicated">
        <item>
          <p name="cceToRegMapping">nonInterleaved</p>
          <p name="coresetId">1</p>
          <p name="cRbStart">0</p>
          <p name="duration">1</p>
          <p name="interleaverSize">none</p>
          <p name="regBundleSize">n6</p>
          <p name="size">270</p>
        </item>
      </list>
"""
coresetDedicated = [
    {
        'cceToRegMapping': 'nonInterleaved',
        'coresetId': 1,
        'cRbStart': 0,
        'duration': 1,
        'interleaverSize': 'none',
        'regBundleSize': 'n6',
        'size': 270
    }
]


tddFrameStructure_all_cb008406 = [
    dict(dist_name=BTS_DIST + '/NRCELL-1', parameter='tddFrameStructure', value=tddFrame_cb008406, operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2', parameter='tddFrameStructure', value=tddFrame_cb008406, operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3', parameter='tddFrameStructure', value=tddFrame_cb008406, operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4', parameter='tddFrameStructure', value=tddFrame_cb008406, operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1', parameter='actNrRim', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2', parameter='actNrRim', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3', parameter='actNrRim', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4', parameter='actNrRim', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1', parameter='actBadUplinkRadioRedirect', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2', parameter='actBadUplinkRadioRedirect', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3', parameter='actBadUplinkRadioRedirect', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4', parameter='actBadUplinkRadioRedirect', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1', parameter='actBadUlRadioHoRej', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2', parameter='actBadUlRadioHoRej', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3', parameter='actBadUlRadioHoRej', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4', parameter='actBadUlRadioHoRej', value='disabled', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1',
         parameter='actFastMuteSrsBeamForRi', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1',
         parameter='actFastMuteSrsBeamForRi', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1',
         parameter='actFastMuteSrsBeamForRi', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1',
         parameter='actFastMuteSrsBeamForRi', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1',
         parameter='actRiDetectTriggerDlMitigation', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1',
         parameter='actRiDetectTriggerDlMitigation', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1',
         parameter='actRiDetectTriggerDlMitigation', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1',
         parameter='actRiDetectTriggerDlMitigation', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1',
         parameter='actRiPilotDlMute', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1',
         parameter='actRiPilotDlMute', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1',
         parameter='actRiPilotDlMute', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1',
         parameter='actRiPilotDlMute', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1',
         parameter='actRimAsymmetricIndication', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1',
         parameter='actRimAsymmetricIndication', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1',
         parameter='actRimAsymmetricIndication', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1',
         parameter='actRimAsymmetricIndication', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1',
         parameter='actRimMitigationExtend', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1',
         parameter='actRimMitigationExtend', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1',
         parameter='actRimMitigationExtend', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1',
         parameter='actRimMitigationExtend', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1',
         parameter='actRimSoftDlMuting', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1',
         parameter='actRimSoftDlMuting', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1',
         parameter='actRimSoftDlMuting', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1',
         parameter='actRimSoftDlMuting', value='false', operation='update'),
    dict(dist_name=BTS_DIST + '/BWP_PROFILE-0/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         parameter='searchSpaceCommon', value=searchSpaceCommon, operation='update'),
    dict(dist_name=BTS_DIST + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_COMMON-1',
         parameter='searchSpaceCommon', value=searchSpaceCommon_1, operation='update'),
    dict(dist_name=BTS_DIST + '/BWP_PROFILE-44/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
         parameter='coresetDedicated', value=coresetDedicated, operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELLGRP-1',
         parameter='numberOfTransmittedSsBlocks', value='1 beam', operation='update'),
 ]


tddFrameStructure_all_1 = [
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='tddFrameStructure', value=tddFrameStructure_1, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='tddFrameStructure', value=tddFrameStructure_1, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-3', parameter='tddFrameStructure', value=tddFrameStructure_1, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-4', parameter='tddFrameStructure', value=tddFrameStructure_1, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-3', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-4', parameter='prachConfigurationIndex', value='92', operation='update')
]

tddFrameStructure_all_2 = [
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='tddFrameStructure', value=tddFrameStructure_2, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='tddFrameStructure', value=tddFrameStructure_2, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-3', parameter='tddFrameStructure', value=tddFrameStructure_2, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-4', parameter='tddFrameStructure', value=tddFrameStructure_2, operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-4', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-3', parameter='actIncUlPdcchCapacity', value='false', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-1', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-2', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-3', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST+'/NRCELL-4', parameter='prachConfigurationIndex', value='92', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1', parameter='rimDlMutingMaxRange',
         value='DL+special slots', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1', parameter='rimDlMutingMaxRange',
         value='DL+special slots', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1', parameter='rimDlMutingMaxRange',
         value='DL+special slots', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1', parameter='rimDlMutingMaxRange',
         value='DL+special slots', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1', parameter='rsPattern2Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1', parameter='rsPattern2Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1', parameter='rsPattern2Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1', parameter='rsPattern2Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-1/NRRIM_PROFILE-1', parameter='rsPattern1Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-2/NRRIM_PROFILE-1', parameter='rsPattern1Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-3/NRRIM_PROFILE-1', parameter='rsPattern1Period',
         value='2.5ms', operation='update'),
    dict(dist_name=BTS_DIST + '/NRCELL-4/NRRIM_PROFILE-1', parameter='rsPattern1Period',
         value='2.5ms', operation='update'),
]

sgnb_chg_flow_message = dict(order_list=['id-positioningInformationUpdate',
                                         'id-MeasurementFailureIndication',
                                         'id-MeasurementAbort'],)
