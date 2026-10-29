from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.OAM.RAN_PZ_HAZ_34.libraries.global_vars import *

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Wang Lei'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_7_GMS <I_MN_5G_RAN_IV4_LINE_HZG_7@internal.nsn.com>'
__email__ = 'lei.24.wang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-' + _gnb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PARAMS_TO_MODIFY_8847_2426_A = [
    dict(value='20', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value=[dict(csiReportPeriodicity='slots320')], dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='periodicCsiAcquisition'),
    dict(value=[dict(csiReportPeriodicity='slots320')], dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='periodicCsiAcquisition'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='srPeriodicity'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='srPeriodicity'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='actAdaptiveSr'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='actAdaptiveSr'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='preferredVoNrSrPeriod'),
    dict(value='1', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='2', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRDU-1",
         parameter='numOfDrbsReservForEmergency'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='actEmergencyCall'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='actEmergencyCall'),
]

PARAMS_TO_MODIFY_8847_2426_C311 = [
    dict(value='20', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='20', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value=[dict(csiReportPeriodicity='slots320')], dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='periodicCsiAcquisition'),
    dict(value=[dict(csiReportPeriodicity='slots320')], dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='periodicCsiAcquisition'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='srPeriodicity'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='srPeriodicity'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='actAdaptiveSr'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='actAdaptiveSr'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='preferredVoNrSrPeriod'),
    dict(value='1', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='2', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRDU-1",
         parameter='numOfDrbsReservForEmergency'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='actEmergencyCall'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='actEmergencyCall'),
]

PARAMS_TO_MODIFY_1116_0_A2 = {
    'update': [
        dict(value='7_5_CLOUD402T857 1116_0_A2', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='tddFrameStructure',
             value=dict(frameStructureType='tdLte', guardPeriodLength='4Symbols', lteToNrFrameShift='0ms',
                        tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='2/8')),
        dict(value='10', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0CoresetConfigurationIndex'),
        dict(value='5', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0SearchSpaceConfigurationIndex'),
        dict(value='90', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='true', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEnhancedPDSCHSchSplSlot'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-7', cellBwpId='0',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-70', cellBwpId='1',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='tddFrameStructure',
             value=dict(frameStructureType='tdLte', guardPeriodLength='4Symbols', lteToNrFrameShift='0ms',
                        tdLteUlDlConfig='tdLteConfig2', ulDlDataSlotRatio='2/8')),
        dict(value='10', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0CoresetConfigurationIndex'),
        dict(value='5', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0SearchSpaceConfigurationIndex'),
        dict(value='90', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='true', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEnhancedPDSCHSchSplSlot'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-7', cellBwpId='0',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-70', cellBwpId='1',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
    ]
}

PARAMS_TO_MODIFY_1116_0_C2 = {
    'update': [
        dict(value='7_5_CLOUD402T857 1116_0_C2 from 1116_0_A2', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='194', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='194', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
    ]
}

PARAMS_TO_MODIFY_1116_0_B4 = {
    'update': [
        dict(value='7_5_CLOUD402T857 1116_0_B4 from 1116_0_A2', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='156', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='156', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
    ]
}

PARAMS_TO_MODIFY_1116_0_0 = {
    'update': [
        dict(value='7_5_CLOUD402T857 1116_0_0 from 1116_0_A2', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='9', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='9', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
    ]
}

PARAMS_TO_MODIFY_1208 = {
    'update': [
        dict(value='7_5_CLOUD402T857 1208', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='tddFrameStructure',
             value=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols', ulDlDataSlotRatio='1/4')),
        dict(value='10', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0CoresetConfigurationIndex'),
        dict(value='4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0SearchSpaceConfigurationIndex'),
        dict(value='98', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='false', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEnhancedPDSCHSchSplSlot'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-5', cellBwpId='0',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-50', cellBwpId='1',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='tddFrameStructure',
             value=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols', ulDlDataSlotRatio='1/4')),
        dict(value='10', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0CoresetConfigurationIndex'),
        dict(value='4', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='type0SearchSpaceConfigurationIndex'),
        dict(value='98', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='prachConfigurationIndex'),
        dict(value='false', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='actEnhancedPDSCHSchSplSlot'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-5', cellBwpId='0',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-50', cellBwpId='1',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
    ]
}

PARAMS_TO_MODIFY_1070 = {
    'update': [
        dict(value='7_5_CLOUD402T857 1070 from 1208', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='tddFrameStructure',
             value=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols', ulDlDataSlotRatio='3/7')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-6', cellBwpId='0',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-60', cellBwpId='1',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='tddFrameStructure',
             value=dict(frameStructureType='semiStatic', guardPeriodLength='2Symbols', ulDlDataSlotRatio='3/7')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-6', cellBwpId='0',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             list_name='cellBwpList',
             value=dict(bwpDN='MRBTS-857/NRBTS-857/BWP_PROFILE-60', cellBwpId='1',
                        pdcchResourcePreference='peakRate', actPdcchCceFragmentControl='false',
                        actUpperThrAckNackFiltering='false', actUpperThrAckNackHrFiltering='false')),
    ]
}

PARAMS_TO_MODIFY_non_CA = {
    'update': [
        dict(value='7_5_CLOUD402T091 20+20+20 nonCA', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='0', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfCaUsersNRCell'),
        dict(value='0', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfSCellAlloc'),
        dict(value='0', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfCaUsersNRCell'),
        dict(value='0', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfSCellAlloc'),
        dict(value='0', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfCaUsersNRCell'),
        dict(value='0', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfSCellAlloc'),
        dict(value='BasicCAMode', dist_name='MRBTS-%s/NRBTS-%s/NRDU-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='flexibleCAMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRDU-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='carrierAggregationSupportList',
             value=['none']),
    ],
    'delete': [
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ]
}

PARAMS_TO_MODIFY_CA = {
    'update': [
        dict(value='7_5_CLOUD402T091 20+20+20 CA', dist_name='MRBTS-%s' % (GLOBAL_BTS_ID),
             parameter='btsName'),
        dict(value='250', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfCaUsersNRCell'),
        dict(value='250', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfSCellAlloc'),
        dict(value='250', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfCaUsersNRCell'),
        dict(value='250', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfSCellAlloc'),
        dict(value='250', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfCaUsersNRCell'),
        dict(value='250', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='maxNumOfSCellAlloc'),
        dict(value='ConfigurationIndependent', dist_name='MRBTS-%s/NRBTS-%s/NRDU-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='flexibleCAMode'),
        dict(dist_name='MRBTS-%s/NRBTS-%s/NRDU-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='carrierAggregationSupportList',
             value=['ca_Fdd_Fdd']),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlOnly', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlOnly', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-1/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlOnly', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlOnly', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-2/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlOnly', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-1' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
        dict(value='blind', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellAdditionMethod'),
        dict(value='dlOnly', dist_name='MRBTS-%s/NRBTS-%s/NRCELL-3/NRREL-2' % (GLOBAL_BTS_ID, MRBTS_ID),
             parameter='sCellOperationalMode'),
    ],
}

DICT__L3CALL_Set = {
    'AWHHF': {
        '1116_0_A2': {
            'ue_index': '3',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '285',
            'peak_tp_ul': '37.5',
            'duration': '60'
        },
        '1116_0_C2': {
            'ue_index': '3',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '285',
            'peak_tp_ul': '37.5',
            'duration': '60'
        },
        '1116_0_B4': {
            'ue_index': '3',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '285',
            'peak_tp_ul': '35',
            'duration': '60'
        },
        '1116_0_0': {
            'ue_index': '3',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '285',
            'peak_tp_ul': '35',
            'duration': '60'
        },
        '1208': {
            'ue_index': '3',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '283',
            'peak_tp_ul': '37.5',
            'duration': '60'
        },
        '1070': {
            'ue_index': '3',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '243',
            'peak_tp_ul': '57.5',
            'duration': '60'
        }
    },
    'AHFB': {
        'single_20M_mtk': {
            'ue_index': '0',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '415',
            'peak_tp_ul': '109',
            'duration': '60'
        },
        'CA_3_20M_mtk': {
            'ue_index': '0',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '1215',
            'peak_tp_ul': '109',
            'duration': '60'
        },
        'CA_3_20M_mtk_nopeak': {
            'ue_index': '0',
            'dl_tp_ratio': '0.3',
            'ul_tp_ratio': '0.1',
            'peak_tp_dl': '1215',
            'peak_tp_ul': '109',
            'duration': '60'
        },
        'single_30M_mtk': {
            'ue_index': '0',
            'dl_tp_ratio': '0.9',
            'ul_tp_ratio': '0.9',
            'peak_tp_dl': '435',
            'peak_tp_ul': '104',
            'duration': '60'
        }
    }
}

LIST_CB007114_UE = [0, 1, 2]
LIST_CB009469_CA_CELLS = [1, 2, 3]
LIST_CB009469_nonCA_CELLS = ['3']
DICT__CB009469_PrbValue = {'1': '79.5', '2': '106', '3': '79.5'}
CB009469_Prb_rangevalue = 4
