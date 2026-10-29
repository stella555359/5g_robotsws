# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MR_BTS2_NAME = 'MRBTS-' + str(tl.gnbs[1].instance_id)
MR_NR_BTS2_NAME = MR_BTS2_NAME + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)

ENB_MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
MR_NR_ENB_NAME = ENB_MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)

ENB2_MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[1].instance_id)
MR_NR_ENB2_NAME = ENB2_MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[1].global_bts_id)
MR_NR_ENB2_LNCEL = MR_NR_ENB2_NAME + '/LNCEL-1'
MR_NR_ENB_ENDCMEASCONFIG = MR_NR_ENB_NAME + '/NRDCDPR-0/ENDCDMEASCONF-1'

DefaultLnRelGnbCellId_enb = MR_NR_ENB_NAME + '/LNCEL-2'
DefaultLnRelGnbCellId_enb_7403 = MR_NR_ENB_NAME + '/LNCEL-1'

GNB1_NRCELL_1 = MR_NR_BTS_NAME + '/NRCELL-1'
GNB1_NRCELL_2 = MR_NR_BTS_NAME + '/NRCELL-2'
GNB1_NRCELL_3 = MR_NR_BTS_NAME + '/NRCELL-3'
GNB1_NRCELL_4 = MR_NR_BTS_NAME + '/NRCELL-4'
GNB1_NRCELL_11 = MR_NR_BTS_NAME + '/NRCELL-11'
GNB1_NRCELL_12 = MR_NR_BTS_NAME + '/NRCELL-12'
GNB1_NRCELL_13 = MR_NR_BTS_NAME + '/NRCELL-13'
GNB1_NRCELL_14 = MR_NR_BTS_NAME + '/NRCELL-14'
GNB2_NRCELL_1 = MR_NR_BTS2_NAME + '/NRCELL-1'
GNB2_NRCELL_2 = MR_NR_BTS2_NAME + '/NRCELL-2'
GNB2_NRCELL_3 = MR_NR_BTS2_NAME + '/NRCELL-3'
GNB2_NRCELL_4 = MR_NR_BTS2_NAME + '/NRCELL-4'
GNB2_NRCELL_11 = MR_NR_BTS2_NAME + '/NRCELL-11'
MiNrX2cc_para = MR_NR_BTS_NAME + '/NRPMRNL-1'
MiNrX2cc_para_GNB2 = MR_NR_BTS2_NAME + '/NRPMRNL-1'
a1MeashoEnabled_para_GNB1 = MR_NR_BTS_NAME + '/NRMOPR_NSA-2'
ENB_control_GNB1 = MR_NR_ENB_NAME + '/LNADJGNB-2'
GNB1_FMCADM = MR_BTS_NAME + '/MNL-1/MNLENT-1/FMCADM-1'
NRPMRNL_1 = MR_NR_BTS_NAME + '/NRPMRNL-1'
FEATCADM_1_NAME = MR_BTS_NAME + '/MNL-1/MNLENT-1/FEATCADM-1'
TRBLCADM_1_NAME = MR_BTS_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1'
BBMOD_R_DN = MR_BTS_NAME + '/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1'
NRCELL_1_NRHOIF_1 = GNB1_NRCELL_1 + '/NRHOIF-1'
GNB2_NRCELL_1_NRHOIF_2 = GNB2_NRCELL_1 + '/NRHOIF-2'
GNB2_NRCELL_11_NRHOIF_1 = GNB2_NRCELL_11 + '/NRHOIF-1'

faultSnapshotTriggers_1 = {"faultNumber": '4547', "triggerType": 'onFaultDetection'}

ENB_MODIFY_Parameter_573 = [dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='true')]

ENB_control_GNB1_lock = [dict(dist_name=ENB_control_GNB1, parameter='administrativeState', value='locked')]
ENB_control_GNB1_unlock = [dict(dist_name=ENB_control_GNB1, parameter='administrativeState', value='unlocked')]

GNB1_MODIFY_Parameter_573 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='true'),
     dict(dist_name=GNB1_NRCELL_1, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=GNB1_NRCELL_1, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=MiNrX2cc_para, parameter='miNrX2CC', value='5min')]

GNB2_MODIFY_Parameter_573 = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='true'),
     dict(dist_name=GNB2_NRCELL_1, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=GNB2_NRCELL_1, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=MiNrX2cc_para_GNB2, parameter='miNrX2CC', value='5min')]

GNB1_Reconver_Parameter_573 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='false')]

GNB2_Reconver_Parameter_573 = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='false')]

ENB_MODIFY_Parameter_710 = [dict(dist_name=MR_NR_ENB_NAME, parameter='actEndcSpidFwd', value='true')]

GNB1_MODIFY_Parameter_710 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregation', value='false'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='caConfigurationSupport', value='none'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='actMobilityProfile', value='true'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='actSPID', value='true'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqIntraGnbMobilityNSA', value='true'),
     dict(dist_name=a1MeashoEnabled_para_GNB1, parameter='a1MeashoEnabled', value='rsrp')]

GNB1_Reconver_Parameter_710 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actMobilityProfile', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actSPID', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqIntraGnbMobilityNSA', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregation', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='caConfigurationSupport', value='4CCDL_2CCUL')]

GNB1_MODIFY_Parameter_710_008 = [
     dict(dist_name=NRCELL_1_NRHOIF_1, parameter='a3MeasSsbRsrp',
          value=[{'a3HysteresisSsbRsrp': '15', 'a3OffsetSsbRsrp': '30', 'a3TimeToTriggerSsbRsrp': 'ms100'}])]

GNB1_MODIFY_Parameter_710_008_recovery = [
     dict(dist_name=NRCELL_1_NRHOIF_1, parameter='a3MeasSsbRsrp',
          value=[{'a3HysteresisSsbRsrp': '0', 'a3OffsetSsbRsrp': '20', 'a3TimeToTriggerSsbRsrp': 'ms100'}])]

GNB1_MODIFY_Parameter_1094 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqIntraGnbMobilityNSA', value='true'),
     dict(dist_name=GNB1_NRCELL_1, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=GNB1_NRCELL_1, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=GNB1_NRCELL_1, parameter='pciBlackList',
          value=[{'pciRangeValidity': 'NSA', 'physCellId': '60', 'range': 'n8'}])]

GNB1_Reconver_Parameter_1094 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqIntraGnbMobilityNSA', value='false')]

GNB1_Reconver_Parameter_1416 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actMultiFrequencyBandIndicatorNRSupport', value='false'),
     dict(dist_name=GNB1_NRCELL_1, parameter='freqBandIndicatorNR', value='261')]

GNB1_MODIFY_Parameter_7564_CFRA = [
     dict(dist_name=GNB1_NRCELL_1, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_2, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_3, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_4, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_11, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_12, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_13, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB1_NRCELL_14, parameter='cbraPreamblesPerSsb', value='n48')]

GNB2_MODIFY_Parameter_7564_CFRA = [
     dict(dist_name=GNB2_NRCELL_1, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB2_NRCELL_2, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB2_NRCELL_3, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB2_NRCELL_4, parameter='cbraPreamblesPerSsb', value='n48'),
     dict(dist_name=GNB2_NRCELL_11, parameter='cbraPreamblesPerSsb', value='n48')]

GNB1_MODIFY_Parameter_7564_CBRA = [
     dict(dist_name=GNB1_NRCELL_1, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_2, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_3, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_4, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_11, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_12, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_13, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB1_NRCELL_14, parameter='cbraPreamblesPerSsb', value='n64')]

GNB2_MODIFY_Parameter_7564_CBRA = [
     dict(dist_name=GNB2_NRCELL_1, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB2_NRCELL_2, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB2_NRCELL_3, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB2_NRCELL_4, parameter='cbraPreamblesPerSsb', value='n64'),
     dict(dist_name=GNB2_NRCELL_11, parameter='cbraPreamblesPerSsb', value='n64')]

ENB_actB1Ext_Parameter_7564 = [
    dict(dist_name=MR_NR_ENB_NAME, parameter='actB1ExtMeasNR', value='true')]

ENB_Reconver_Parameter_7564 = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actB1ExtMeasNR', value='false')]


# check parameter dictionary
attached_pci_50 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='1')]

attached_pci_80 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '80'}, n='1')]

attached_pci_100 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '100'}, n='1')]

sgnb_chg_ho_cause = [
    dict(xpath='SgNBChangeRequired',
         expected_value={'radioNetwork': 'action-desirable-for-radio-reasons (31)'}, n='1')]

sgnb_attach_cause_2083_001 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='1'),
    dict(xpath='uplink/cfra', expected_value={'ra-PreambleIndex': '48'}, n='1'),
    dict(xpath='spCellConfig', expected_value={'newUE-Identity': ''}, n='1')]

sgnb_attach_cause_2083_002 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='1'),
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '80'}, n='2'),
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='3'),
    dict(xpath='uplink/cfra', expected_value={'ra-PreambleIndex': '48'}, n='1'),
    dict(xpath='spCellConfig', expected_value={'newUE-Identity': ''}, n='1')]

sgnb_attach_cause_2083_004 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='1'),
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '80'}, n='2'),
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='3')]

blackCellsToAddModList = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'measConfig/PCI-RangeElement',
         expected_value={'pci-RangeIndex': '1'}, n='1'),
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'measConfig/PCI-RangeElement',
         expected_value={'range': 'n8 (1)'}, n='1'),
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'measConfig/PCI-RangeElement',
         expected_value={'start': '60'}, n='1')]

nrRestrictionInEPS = [
    dict(xpath='InitialContextSetupRequest/HandoverRestrictionList',
         expected_value={'NRrestrictioninEPSasSecondaryRAT': 'nRrestrictedinEPSasSecondaryRAT (0)'}, n='1')]

# check message by or or not parameters    order_list/not_order_list/should_not_include
attach_message_flow = \
    dict(order_list=['SgNBAdditionRequest', 'SgNBAdditionRequestAcknowledge', 'RRCReconfigurationComplete'],
         should_not_include=['SgNBReleaseRequest', 'UEContextRelease', 'SgNBReleaseRequestAcknowledge'])

only_attach_lte = \
    dict(order_list=['initiatingMessage', 'InitialContextSetupRequest', 'DownlinkNASTransport'],
         should_not_include=['SgNBAdditionRequest', 'SgNBAdditionRequestAcknowledge'])

intra_freq_inter_gnb_ho_message_flow = dict(order_list=['measurementreport',
                                                        'SgNBChangeRequired',
                                                        'SgNBAdditionRequest',
                                                        'SgNBAdditionRequestAcknowledge',
                                                        'SgNBChangeConfirm',
                                                        'SgNBReconfigurationComplete',
                                                        'UEContextRelease'],
                                            should_not_include=['SgNBReleaseRequest',
                                                                'SgNBReleaseRequestAcknowledge'])

attach_and_intra_freq_inter_gnb_ho = dict(order_list=['SgNBAdditionRequest',
                                                      'SgNBAdditionRequestAcknowledge',
                                                      'RRCReconfigurationComplete',
                                                      'measurementreport',
                                                      'SgNBChangeRequired',
                                                      'SgNBAdditionRequest',
                                                      'SgNBAdditionRequestAcknowledge',
                                                      'SgNBChangeConfirm',
                                                      'SgNBReconfigurationComplete',
                                                      'UEContextRelease'],
                                          should_not_include=['SgNBReleaseRequest',
                                                              'SgNBReleaseRequestAcknowledge'])

inter_freq_a2_a1_message_flow = dict(order_list=['measurementreport',
                                                 'SgNBModificationRequired',
                                                 'SgNBModificationRequest',
                                                 'SgNBModificationRequestAcknowledge',
                                                 'SgNBModificationConfirm',
                                                 'measurementreport',
                                                 'SgNBModificationRequired',
                                                 'SgNBModificationRequest',
                                                 'SgNBModificationRequestAcknowledge',
                                                 'SgNBModificationConfirm'],
                                     should_not_include=['SgNBReleaseRequest',
                                                         'UEContextRelease',
                                                         'SgNBReleaseRequestAcknowledge'])

inter_freq_a2_message_flow = dict(order_list=['measurementreport',
                                              'SgNBModificationRequired',
                                              'SgNBModificationRequest',
                                              'SgNBModificationRequestAcknowledge',
                                              'SgNBModificationConfirm'],
                                  should_not_include=['SgNBReleaseRequest',
                                                      'UEContextRelease',
                                                      'SgNBReleaseRequestAcknowledge'])

inter_freq_intra_gnb_message_flow = dict(order_list=['measurementReport',
                                                     'SgNBModificationRequired',
                                                     'SgNBModificationRequest',
                                                     'SgNBModificationRequestAcknowledge',
                                                     'SgNBModificationConfirm',
                                                     'measurementReport',
                                                     'SgNBModificationRequired',
                                                     'SgNBModificationConfirm',
                                                     'SgNBModificationRequired',
                                                     'SgNBModificationRequest',
                                                     'SgNBModificationRequestAcknowledge',
                                                     'SgNBModificationConfirm'])

HO_attached_pci_100 = [dict(xpath='SgNBModificationRequired/rrcReconfiguration/spCellConfig/reconfigurationWithSync',
                            expected_value={'physCellId': '100'}, n='1')]

HO_attached_pci_80 = [dict(xpath='SgNBModificationRequired/rrcReconfiguration/spCellConfig/reconfigurationWithSync',
                           expected_value={'physCellId': '80'}, n='1')]

HO_NOT_attached_pci_100 = [dict(xpath='SgNBModificationRequired/spCellConfig/reconfigurationWithSync',
                                expected_value={'physCellId': '100'}, n='1', result_reverse=True)]

spid = [dict(xpath='SgNBAdditionRequest', expected_value={'SubscriberProfileIDforRFP': '12'}, n='1')]

measGap = [dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'measGapConfig': 'setup (1)'}, n='1'),
           dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'gapPurpose': 'perUE (0)'}, n='1'),
           dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'measGapConfig': 'release (0)'}, n='2')]

measGap_011 = \
    [dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'measGapConfig': 'setup (1)'}, n='1'),
     dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'gapPurpose': 'perUE (0)'}, n='1')]

ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 4657},
    {'faultId': 4298},
    {'faultId': 6203},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 4592},
]

ENB_MODIFY_Parameter = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]

ENB_Reconver_Parameter = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='true')]

ENB_defaultLnRelGnbCellId_GNB1 = [
     dict(dist_name=DefaultLnRelGnbCellId_enb_7403, parameter='defaultLnRelGnbCellId', value='1')]

ENB_defaultLnRelGnbCellId_GNB2 = [
     dict(dist_name=DefaultLnRelGnbCellId_enb_7403, parameter='defaultLnRelGnbCellId', value='3')]

ENB_4088_enable = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]

ENB_4193_enable = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='true')]

ENB_default_FR2 = [
     dict(dist_name=DefaultLnRelGnbCellId_enb_7403, parameter='defaultLnRelGnbCellId', value='3')]

ENB_default_FR1 = [
     dict(dist_name=DefaultLnRelGnbCellId_enb_7403, parameter='defaultLnRelGnbCellId', value='4')]

ENB_CNI107623_enable = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='nrRestrictionOverride', value='FR1 and FR2')]

ENB_CNI107623_only_FR2_enable = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='nrRestrictionOverride', value='FR2')]

ENB_CNI107623_disable = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='nrRestrictionOverride', value='disabled')]

freq_2071387_nrCarPrio_8 = [
     dict(dist_name=MR_NR_ENB_ENDCMEASCONFIG, parameter='nrCarPrio', value='8')]

freq_2071387_nrCarPrio_1 = [
     dict(dist_name=MR_NR_ENB_ENDCMEASCONFIG, parameter='nrCarPrio', value='1')]

GNB2_CNI107623_HO_precondition = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actCarrierAggregation', value='false'),
     dict(dist_name=MR_NR_BTS2_NAME, parameter='caConfigurationSupport', value='none'),
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actInterFreqIntraGnbMobilityNSA', value='true'),
     dict(dist_name=GNB2_NRCELL_1, parameter='a2MeashoSsbRsrp',
          value=[{'a2HysteresishoSsbRsrp': '10', 'a2ThresholdhoSsbRsrp': '86', 'a2TimeToTriggerhoSsbRsrp': 'ms100'}]),
     dict(dist_name=GNB2_NRCELL_1_NRHOIF_2, parameter='a3MeasSsbRsrp',
          value=[{'a3HysteresisSsbRsrp': '0', 'a3OffsetSsbRsrp': '10', 'a3TimeToTriggerSsbRsrp': 'ms100'}]),
     dict(dist_name=GNB2_NRCELL_11, parameter='a2MeashoSsbRsrp',
          value=[{'a2HysteresishoSsbRsrp': '0', 'a2ThresholdhoSsbRsrp': '86', 'a2TimeToTriggerhoSsbRsrp': 'ms100'}]),
     dict(dist_name=GNB2_NRCELL_11_NRHOIF_1, parameter='a3MeasEnabled', value='none'),
     dict(dist_name=GNB2_NRCELL_11_NRHOIF_1, parameter='a5MeasEnabled', value='rsrp'),
     dict(dist_name=GNB2_NRCELL_11_NRHOIF_1, parameter='a5MeasSsbRsrp',
          value=[{'a5HysteresisSsbRsrp': '0',
                  'a5Threshold1SsbRsrp': '86',
                  'a5Threshold2SsbRsrp': '56',
                  'a5TimeToTriggerSsbRsrp': 'ms100'}])]
