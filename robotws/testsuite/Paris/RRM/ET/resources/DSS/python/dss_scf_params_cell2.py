import dss_resources as rs

# MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1

DSS_PARAMS_TO_ADD_CELL2 = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        class_name='com.nokia.srbts.nrbts:NRDSSLTE',
        version='NRBTSCL5G20A_2003_200'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRRELLTE-1',
        class_name='com.nokia.srbts.nrbts:NRRELLTE',
        version='NRBTSCL5G20A_2003_200'),
]
#        dist_name='MRBTS-' + str(${MRBTS_ID}) + '/NRBTS-2/NRCELL-1/NRDSSLTE-1',


DSS_LIST_NAME_PARAMS_TO_ADD_CELL2 = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='enbPlmn'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='lteNrDssDlRatio'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='lteNrDssMbsfnRatio'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='lteNrDssUlRatio'),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRRELLTE-1',
        list_name='enbPlmn'),
]

#    <managedObject class="com.nokia.srbts.nrbts:BWP_PROFILE" distName="MRBTS-1/NRBTS-1/BWP_PROFILE-1"
#    version="NRBTSCL5G20A_2003_200" operation="create">
#      <p name="bwpType">initial</p>
#      <list name="locationAndBandwidthDl">
#        <item>
#          <p name="cRbSizeDl">coreset0</p>
#          <p name="cRbStartDl">coreset0</p>
#        </item>
#      </list>
#      <list name="locationAndBandwidthUl">
#        <item>
#          <p name="cRbSizeUl">allRb</p>
#          <p name="cRbStartUl">crb0</p>
#        </item>
#      </list>
#    </managedObject>

#    <managedObject class="com.nokia.srbts.nrbts:BWP_PROFILE" distName="MRBTS-1/NRBTS-1/BWP_PROFILE-2"
#        version="NRBTSCL5G20A_2003_200" operation="create">
#      <p name="bwpType">dedicated</p>
#      <list name="locationAndBandwidthDl">
#        <item>
#          <p name="cRbSizeDl">allRb</p>
#          <p name="cRbStartDl">crb0</p>
#        </item>
#      </list>
#      <list name="locationAndBandwidthUl">
#        <item>
#          <p name="cRbSizeUl">allRb</p>
#          <p name="cRbStartUl">crb0</p>
#        </item>
#      </list>
#    </managedObject>

#    <managedObject class="com.nokia.srbts.nrbts:PDCCH_CONFIG_COMMON"
#    distName="MRBTS-1/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_COMMON-1"
#    version="NRBTSCL5G20A_2003_200" operation="create">
#      <list name="coresetCommon">
#        <item>
#          <p name="cceToRegMapping">interleaved</p>
#          <p name="coresetId">4</p>
#          <p name="cRbStart">0</p>
#          <p name="duration">1</p>
#          <p name="interleaverSize">n3</p>
#          <p name="regBundleSize">n2</p>
#          <p name="size">96</p>
#        </item>
#      </list>
#      <list name="searchSpaceCommon">
#        <item>
#          <p name="coresetId">4</p>
#          <p name="dciFormat">formats0-0-And-1-0</p>
#          <p name="duration">1</p>
#          <p name="monitoringSymbolWithinSlot">symbol_2</p>
#          <p name="numOfPdcchCandidatesInAL16">n0</p>
#          <p name="numOfPdcchCandidatesInAL4">n4</p>
#          <p name="numOfPdcchCandidatesInAL8">n0</p>
#          <p name="periodicity">sl1</p>
#          <p name="searchSpaceId">1</p>
#          <p name="searchSpaceType">Type1</p>
#          <p name="slotOffset">0</p>
#        </item>
#      </list>
#    </managedObject>

#    <managedObject class="com.nokia.srbts.nrbts:PDCCH_CONFIG_DEDICATED"
#    distName="MRBTS-1/NRBTS-1/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1"
#    version="NRBTSCL5G20A_2003_200" operation="create">
#      <list name="searchSpaceDedicated">
#        <item>
#          <p name="coresetId">4</p>
#          <p name="dciFormat">formats0-0-And-1-0</p>
#          <p name="duration">1</p>
#          <p name="monitoringSymbolWithinSlot">symbol_2</p>
#          <p name="numOfPdcchCandidatesInAL1">n0</p>
#          <p name="numOfPdcchCandidatesInAL16">n0</p>
#          <p name="numOfPdcchCandidatesInAL2">n0</p>
#          <p name="numOfPdcchCandidatesInAL4">n4</p>
#          <p name="numOfPdcchCandidatesInAL8">n0</p>
#          <p name="periodicity">sl1</p>
#          <p name="searchSpaceId">2</p>
#          <p name="searchSpaceType">Type3</p>
#          <p name="slotOffset">0</p>
#        </item>
#        <item>
#          <p name="coresetId">4</p>
#          <p name="dciFormat">formats0-1-And-1-1</p>
#          <p name="duration">1</p>
#          <p name="monitoringSymbolWithinSlot">symbol_2</p>
#          <p name="numOfPdcchCandidatesInAL1">n0</p>
#          <p name="numOfPdcchCandidatesInAL16">n0</p>
#          <p name="numOfPdcchCandidatesInAL2">n4</p>
#          <p name="numOfPdcchCandidatesInAL4">n2</p>
#          <p name="numOfPdcchCandidatesInAL8">n0</p>
#          <p name="periodicity">sl1</p>
#          <p name="searchSpaceId">3</p>
#          <p name="searchSpaceType">UE-Specific</p>
#          <p name="slotOffset">0</p>
#        </item>
#      </list>
#    </managedObject>

DSS_LIST_ITEMS_PARAMS_TO_ADD_CELL2 = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='enbPlmn',
        elements=dict(mcc='311', mnc='489', mncLength='3')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='lteNrDssDlRatio',
        elements=dict(maxNrDssRatio='70', minNrDssRatio='15', dlResourceSharingAlgo='DL PRB load based')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='lteNrDssMbsfnRatio',
        elements=dict(maxValue='50', minValue='50')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        list_name='lteNrDssUlRatio',
        elements=dict(maxNrDssRatio='70', minNrDssRatio='20')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRRELLTE-1',
        list_name='enbPlmn',
        elements=dict(mcc='311', mnc='489', mncLength='3')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-161', actPdcchCceFragmentControl='false',
                      pdcchResourcePreference='peakRate', actUpperThrAckNackFiltering='false',
                      actUpperThrAckNackHrFiltering='false', cellBwpId='0')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-170', actPdcchCceFragmentControl='false',
                      pdcchResourcePreference='peakRate', actUpperThrAckNackFiltering='false',
                      actUpperThrAckNackHrFiltering='false', cellBwpId='1'))
]


DSS_NSA_LIST_ITEMS_PARAMS_TO_DELETE_CELL2 = [
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-161', actPdcchCceFragmentControl='false',
                      pdcchResourcePreference='peakRate',  actUpperThrAckNackFiltering='false',
                      actUpperThrAckNackHrFiltering='false', cellBwpId='0')),
    dict(
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2',
        list_name='cellBwpList',
        elements=dict(bwpDN='MRBTS-1/NRBTS-1/BWP_PROFILE-170', actPdcchCceFragmentControl='false',
                      pdcchResourcePreference='peakRate', actUpperThrAckNackFiltering='false',
                      actUpperThrAckNackHrFiltering='false', cellBwpId='1'))
]


#      <p name="dssDlTPollRetr">ms80</p>
#      <p name="dssDlTProhib">ms0</p>
#      <p name="dssUlTPollRetr">ms5</p>
#      <p name="dssUlTProhib">ms0</p>
#      <p name="eNodeBId">1</p>
#      <p name="lcrId">1</p>
#      <p name="ltePhyCellId">11</p>
#      <p name="ssbPosition">pos1</p>

DSS_LIST_ELEMENTS_PARAMS_TO_ADD_CELL2 = [

]

#    <managedObject class="com.nokia.srbts.nrbts:PDCCH"
#    distName="MRBTS-1/NRBTS-1/BWP_PROFILE-1/PDCCH-1" version="NRBTSCL5G20A_2003_200" operation="create">
#      <p name="alSelection">static</p>
#      <p name="dciDedicatedAggregationLevel">AL4</p>
#      <p name="dciPagingAggregationLevel">AL4</p>
#      <p name="dciRaCompletionAggregationLevel">AL4</p>
#      <p name="dciRaMsg2AggregationLevel">AL4</p>
#      <p name="dciSiAggregationLevel">AL4</p>
#    </managedObject>

#   <managedObject class="com.nokia.srbts.nrbts:PDCCH"
#   distName="MRBTS-1/NRBTS-1/BWP_PROFILE-2/PDCCH-1" version="NRBTSCL5G20A_2003_200" operation="create">
#      <p name="alSelection">static</p>
#      <p name="dciDedicatedAggregationLevel">AL4</p>
#      <p name="dciPagingAggregationLevel">AL4</p>
#      <p name="dciRaCompletionAggregationLevel">AL4</p>
#      <p name="dciRaMsg2AggregationLevel">AL4</p>
#      <p name="dciSiAggregationLevel">AL4</p>
#    </managedObject>

#  15/05/2021 : remove actNrIdleMode  from DSS_ELEMENTS_PARAMS_TO_ADD
# dict(
#     value='false',
#    dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
#     p_name='actNrIdleMode'),

DSS_ELEMENTS_PARAMS_TO_ADD_CELL2 = [
    dict(
        value='false',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='actLteNrDssFastAlloc'),
    dict(
        value='false',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='actLteNrDssLteCatM'),
    dict(
        value='false',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='actLteNrDssPdcchLoadResAlloc'),
    dict(
        value='false',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='actDssMsg3Enh'),
    dict(
        value='ms80',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='dssDlTPollRetr'),
    dict(
        value='ms0',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='dssDlTProhib'),
    dict(
        value='ms5',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='dssUlTPollRetr'),
    dict(
        value='ms0',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='dssUlTProhib'),
    dict(
        value='1',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='dssMaxNumberOfDlDcis'),
    dict(
        value='1',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='eNodeBId'),
    dict(
        value='1',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='lcrId'),
    dict(
        value='11',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='ltePhyCellId'),
    dict(
        value='pos1',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='ssbPosition'),
    dict(
        value='1',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRRELLTE-1',
        p_name='eNodeBId'),
    dict(
        value='false',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='actRateMatchedCsiIm'),
    dict(
        value='disabled',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='lteNrDssFastAllocPerfEnh'),
    dict(
        value='false',
        dist_name='MRBTS-1/NRBTS-1/NRCELL-2/NRDSSLTE-1',
        p_name='actUlAdaptReTxEnhDss'),
]

#      <p name="remoteNeType">ENB</p>
#      <p name="localNeDN">MRBTS-1/NRBTS-2</p>
#      <p name="ipV4AddressDN1">MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-6/IPADDRESSV4-1</p>
#      <p name="sctpAssocMaxRetrans">7</p>
#      <p name="sctpDscp">46</p>
#      <p name="sctpHeartbeatInterval">20</p>
#      <p name="sctpMaxPayloadSize">1395</p>
#      <p name="sctpRtoMax">30000</p>
#      <p name="sctpRtoMin">1000</p>
#      <p name="sctpSackDelay">200</p>
#      <p name="sctpSackFreq">2</p>
#      <p name="sctpWaitTimeInitSeqRetry">240</p>
#      <p name="udpDscp">18</p>
