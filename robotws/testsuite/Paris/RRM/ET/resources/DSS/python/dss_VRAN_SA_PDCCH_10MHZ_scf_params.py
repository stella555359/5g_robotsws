import dss_resources as rs


DSS_SA_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161',
        class_name='com.nokia.srbts.nrbts:BWP_PROFILE',
        version='NRBTSCL5G20A_2003_200',
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        class_name='com.nokia.srbts.nrbts:PDCCH',
        version='NRBTSCL5G20A_2003_200',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON',
        version='NRBTSCL5G20A_2003_200',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170',
        class_name='com.nokia.srbts.nrbts:BWP_PROFILE',
        version='NRBTSCL5G20A_2003_200',
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        class_name='com.nokia.srbts.nrbts:PDCCH',
        version='NRBTSCL5G20A_2003_200',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDSCH-1',
        class_name='com.nokia.srbts.nrbts:PDSCH',
        version='NRBTSCL5G20A_2003_200',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON',
        version='NRBTSCL5G20A_2003_200',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        class_name='com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED',
        version='NRBTSCL5G20A_2003_200',
        nodeType='Vdu'),
]


DSS_SA_LIST_NAME_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161',
        list_name='locationAndBandwidthDl',
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161',
        list_name='locationAndBandwidthUl',
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170',
        list_name='locationAndBandwidthDl',
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170',
        list_name='locationAndBandwidthUl',
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='coresetDedicated',
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        list_name='dynamicAggregationLevelSet',
        nodeType='Vdu')
]


DSS_SA_LIST_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161',
        list_name='locationAndBandwidthDl',
        elements=dict(cRbSizeDl='coreset0', cRbStartDl='coreset0'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161',
        list_name='locationAndBandwidthUl',
        elements=dict(cRbSizeUl='allRb', cRbStartUl='crb0'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170',
        list_name='locationAndBandwidthDl',
        elements=dict(cRbSizeDl='allRb', cRbStartDl='crb0'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170',
        list_name='locationAndBandwidthUl',
        elements=dict(cRbSizeUl='allRb', cRbStartUl='crb0'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL2='n0',
                      numOfPdcchCandidatesInAL8='n0', periodicity='sl80', searchSpaceId='4', searchSpaceType='Type0A',
                      slotOffset='47')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL2='n0',
                      numOfPdcchCandidatesInAL8='n0', periodicity='sl10', searchSpaceId='5', searchSpaceType='Type1',
                      slotOffset='6'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL2='n0',
                      numOfPdcchCandidatesInAL8='n0', periodicity='sl40', searchSpaceId='6', searchSpaceType='Type2',
                      slotOffset='27'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='coresetDedicated',
        elements=dict(cceToRegMapping='nonInterleaved', coresetId='4', cRbStart='0', duration='1',
                      interleaverSize='none',
                      regBundleSize='n6', size='48'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='3',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL1='n2', numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL2='n2',
                      numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL8='n0', periodicity='sl10',
                      searchSpaceId='7',
                      searchSpaceType='Type3', slotOffset='2'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='3',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL1='n2', numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL2='n2',
                      numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL8='n0', periodicity='sl10',
                      searchSpaceId='8',
                      searchSpaceType='Type3', slotOffset='6'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        elements=dict(coresetId='0', dciFormat='formats0-1-And-1-1', duration='3',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL1='n2', numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL2='n2',
                      numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL8='n0', periodicity='sl10',
                      searchSpaceId='9',
                      searchSpaceType='UE-Specific', slotOffset='2'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        elements=dict(coresetId='0', dciFormat='formats0-1-And-1-1', duration='3',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL1='n2', numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL2='n2',
                      numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL8='n0', periodicity='sl10',
                      searchSpaceId='10',
                      searchSpaceType='UE-Specific', slotOffset='6'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        elements=dict(coresetId='4', dciFormat='formats0-1-And-1-1', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL1='n2', numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL2='n2',
                      numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL8='n0', periodicity='sl10',
                      searchSpaceId='11',
                      searchSpaceType='UE-Specific', slotOffset='5'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1/PDCCH_CONFIG_DEDICATED-1',
        list_name='searchSpaceDedicated',
        elements=dict(coresetId='4', dciFormat='formats0-1-And-1-1', duration='3',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL1='n2', numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL2='n2',
                      numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL8='n0', periodicity='sl10',
                      searchSpaceId='12',
                      searchSpaceType='UE-Specific', slotOffset='9'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL2='n0',
                      numOfPdcchCandidatesInAL8='n0', periodicity='sl80', searchSpaceId='1', searchSpaceType='Type0A',
                      slotOffset='47'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL2='n0',
                      numOfPdcchCandidatesInAL8='n0', periodicity='sl10', searchSpaceId='2', searchSpaceType='Type1',
                      slotOffset='6'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1/PDCCH_CONFIG_COMMON-1',
        list_name='searchSpaceCommon',
        elements=dict(coresetId='0', dciFormat='formats0-0-And-1-0', duration='1',
                      monitoringSymbolWithinSlot='symbol_2',
                      numOfPdcchCandidatesInAL16='n0', numOfPdcchCandidatesInAL4='n2', numOfPdcchCandidatesInAL2='n0',
                      numOfPdcchCandidatesInAL8='n0', periodicity='sl40', searchSpaceId='3', searchSpaceType='Type2',
                      slotOffset='27')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        list_name='dynamicAggregationLevelSet',
        elements=dict(aggregationLevelList='AL1_AL2_AL4', cqiCorrectionUp='8', cqiDciCssAl1='101',
                      cqiDciCssAl16='0', cqiDciCssAl2='69', cqiDciCssAl4="33",
                      cqiDciCssAl8='10', highOlcCqiOffset='100', lowOlcCqiOffset='1100',
                      pCqiErasureActTimer='160', pCqiErasureReduction='1'),
        nodeType='Vdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-161', cellBwpId='0'),
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-170', cellBwpId='1'),
        nodeType='VcuVdu'),
]


DSS_SA_LIST_ITEMS_PARAMS_TO_DELETE = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-161', cellBwpId='0'),
        nodeType='VcuVdu'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-1',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-170', cellBwpId='1'),
        nodeType='VcuVdu'),
]


DSS_SA_LIST_ELEMENTS_PARAMS_TO_ADD = [

]


DSS_SA_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        value='initial',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161',
        p_name='bwpType',
        nodeType='VcuVdu'),
    dict(
        value='static',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='alSelection',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='dciDedicatedAggregationLevel',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='dciPagingAggregationLevel'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='dciRaCompletionAggregationLevel'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='dciRaMsg2AggregationLevel',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='dciSiAggregationLevel',
        nodeType='Vdu'),
    dict(
        value='notAllowed',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-161/PDCCH-1',
        p_name='downgradeAL16toAL8',
        nodeType='Vdu'),
    dict(
        value='dedicated',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170',
        p_name='bwpType',
        nodeType='VcuVdu'),
    dict(
        value='dynamic',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='alSelection',
        nodeType='Vdu'),
    dict(
        value='AL2',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='dciDedicatedAggregationLevel',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='dciPagingAggregationLevel',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='dciRaCompletionAggregationLevel',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='dciRaMsg2AggregationLevel',
        nodeType='Vdu'),
    dict(
        value='AL4',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='dciSiAggregationLevel',
        nodeType='Vdu'),
    dict(
        value='notAllowed',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDCCH-1',
        p_name='downgradeAL16toAL8',
        nodeType='Vdu'),
    dict(
        value='config1',
        dist_name='MRBTS-1/NRBTS-1/BWP_PROFILE-170/PDSCH-1',
        p_name='pdschRat0RbgConfig',
        nodeType='Vdu')
]
