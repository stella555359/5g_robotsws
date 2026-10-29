# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MR_BTS2_NAME = 'MRBTS-' + str(tl.gnbs[1].instance_id)
MR_NR_BTS2_NAME = MR_BTS2_NAME + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)

ENB_MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
MR_NR_ENB_NAME = ENB_MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)

ENB2_MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[1].instance_id)
MR_NR_ENB2_NAME = ENB2_MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[1].global_bts_id)

GNB2_FMCADM = MR_BTS2_NAME + '/MNL-1/MNLENT-1/FMCADM-1'
TRBLCADM_1_NAME = MR_BTS2_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1'
FEATCADM_1_NAME = MR_BTS2_NAME + '/MNL-1/MNLENT-1/FEATCADM-1'
ENB1_NRCELL_1 = MR_NR_ENB_NAME + '/LNCEL-1'
ENB1_NRCELL_2 = MR_NR_ENB_NAME + '/LNCEL-2'
ENB2_NRCELL_1 = MR_NR_ENB2_NAME + '/LNCEL-1'
GNB1_NRCELL_1 = MR_NR_BTS_NAME + '/NRCELL-1'
GNB1_NRCELL_2 = MR_NR_BTS_NAME + '/NRCELL-2'
GNB1_NRCELL_3 = MR_NR_BTS_NAME + '/NRCELL-3'
GNB1_NRCELL_4 = MR_NR_BTS_NAME + '/NRCELL-4'
GNB1_NRCELL_5 = MR_NR_BTS_NAME + '/NRCELL-5'
GNB1_NRCELL_6 = MR_NR_BTS_NAME + '/NRCELL-6'
GNB1_NRCELL_7 = MR_NR_BTS_NAME + '/NRCELL-7'
GNB1_NRCELL_8 = MR_NR_BTS_NAME + '/NRCELL-8'
GNB1_NRCELL_11 = MR_NR_BTS_NAME + '/NRCELL-11'
GNB1_NRCELL_12 = MR_NR_BTS_NAME + '/NRCELL-12'
GNB1_NRCELL_13 = MR_NR_BTS_NAME + '/NRCELL-13'
GNB1_NRCELL_14 = MR_NR_BTS_NAME + '/NRCELL-14'
GNB1_NRCELL_21 = MR_NR_BTS_NAME + '/NRCELL-21'
GNB1_NRCELL_22 = MR_NR_BTS_NAME + '/NRCELL-22'
GNB1_NRCELL_23 = MR_NR_BTS_NAME + '/NRCELL-23'
GNB1_NRCELL_24 = MR_NR_BTS_NAME + '/NRCELL-24'
GNB2_NRCELL_1 = MR_NR_BTS2_NAME + '/NRCELL-1'
GNB2_NRCELL_2 = MR_NR_BTS2_NAME + '/NRCELL-2'
GNB2_NRCELL_3 = MR_NR_BTS2_NAME + '/NRCELL-3'
GNB2_NRCELL_4 = MR_NR_BTS2_NAME + '/NRCELL-4'
MiNrX2cc_para = MR_NR_BTS_NAME + '/NRPMRNL-1'
MiNrX2cc_para_GNB2 = MR_NR_BTS2_NAME + '/NRPMRNL-1'
a1MeashoEnabled_para_GNB1 = MR_NR_BTS_NAME + '/NRMOPR_NSA-2'
NRMEASCFG_para_GNB1 = MR_NR_BTS_NAME + '/NRMEASCFG_IF-1'
NRMEASCFG_para_GNB2 = MR_NR_BTS2_NAME + '/NRMEASCFG_IF-2'
NRHOIF_para_GNB2 = GNB2_NRCELL_1 + '/NRHOIF-1'
BBMOD_R_DN = MR_BTS_NAME + '/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1'
TRBLCADM = MR_BTS2_NAME + '/MNL-1/MNLENT-1/TRBLCADM-1'

GNB1_SETUP_Paramemeters = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actA1HoPrefNRLayer', value='none'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actHigherPrioFreqHo', value='none'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqIntraGnbMobilityNSA', value='false')]

GNB1_TEARDOWN_Paramemeters = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqIntraGnbMobilityNSA', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actHigherPrioFreqHo', value='NSA'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actA1HoPrefNRLayer', value='NSA')]

ENB_MODIFY_Parameter = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]

ENB_Reconver_Parameter = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='true')]

ENB_defaultLnRelGnbCellId_GNB1_cell_50 = [
     dict(dist_name=ENB1_NRCELL_1, parameter='defaultLnRelGnbCellId', value='0')]

ENB_defaultLnRelGnbCellId_GNB1_cell_60 = [
     dict(dist_name=ENB1_NRCELL_1, parameter='defaultLnRelGnbCellId', value='1')]

ENB_defaultLnRelGnbCellId_GNB1_cell_80 = [
     dict(dist_name=ENB1_NRCELL_1, parameter='defaultLnRelGnbCellId', value='3')]

ENB_defaultLnRelGnbCellId_GNB2_cell_70 = [
     dict(dist_name=ENB1_NRCELL_1, parameter='defaultLnRelGnbCellId', value='2')]

GNB2_Reconver_Parameter_2083 = [
     dict(dist_name=FEATCADM_1_NAME, parameter='actAutRachBasedSlCellDetRec', value='false')]

ENB1_MODIFY_Parameter_573 = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='true')]

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

GNB2_MODIFY_Parameter_573_005 = [
     dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfCaUsersNRCell', value='0'),
     dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfCaUsersNRCell', value='0'),
     dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfRrcSA', value='0'),
     dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfRrcSA', value='0'),
     dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfSCellAlloc', value='0'),
     dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfSCellAlloc', value='0'),
     dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfUsersPerCell', value='0'),
     dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfUsersPerCell', value='0')]

GNB1_Reconver_Parameter_573 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='false')]

GNB2_Reconver_Parameter_573 = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='false')]

GNB2_Reconver_Parameter_573_005 = [
    dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfCaUsersNRCell', value='275'),
    dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfCaUsersNRCell', value='275'),
    dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfRrcSA', value='275'),
    dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfRrcSA', value='275'),
    dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfSCellAlloc', value='275'),
    dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfSCellAlloc', value='275'),
    dict(dist_name=GNB2_NRCELL_1, parameter='maxNumOfUsersPerCell', value='275'),
    dict(dist_name=GNB2_NRCELL_2, parameter='maxNumOfUsersPerCell', value='275')]

ENB1_MODIFY_Parameter_574 = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actHoWoSnChg', value='intraEnbAndX2HoEnabled')]

ENB2_MODIFY_Parameter_574 = [
     dict(dist_name=MR_NR_ENB2_NAME, parameter='actHoWoSnChg', value='intraEnbAndX2HoEnabled')]

GNB1_MODIFY_Parameter_574 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actInterMeNBMobility', value='true')]

GNB1_Reconver_Parameter_574 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actInterMeNBMobility', value='false')]

ENB1_MODIFY_Parameter_575 = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actHoWoSnChg', value='intraEnbHoEnabled')]

GNB1_MODIFY_Parameter_575 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraMeNBMobility', value='true')]

GNB1_Reconver_Parameter_575 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraMeNBMobility', value='false')]

GNB_MODIFY_Parameter_1094 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqIntraGnbMobilityNSA', value='true'),
     dict(dist_name=GNB1_NRCELL_1, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=GNB1_NRCELL_1, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=GNB1_NRCELL_11, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=GNB1_NRCELL_11, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsDl', value='7'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUl', value='3')
]

GNB1_Reconver_Parameter_1094 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqIntraGnbMobilityNSA', value='false'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsDl', value='3'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='maxNumScellsUl', value='1')]

GNB1_Reconver_Parameter_1416 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqIntraGnbMobilityNSA', value='false'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='actMultiFrequencyBandIndicatorNRSupport', value='false')]

ENB1_MODIFY_Parameter_710 = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actEndcSpidFwd', value='true')]

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

GNB1_MODIFY_Parameter_710_014 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregation', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='caConfigurationSupport', value='none'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actMobilityProfile', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actSPID', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='true'),
    dict(dist_name=NRMEASCFG_para_GNB1, parameter='a3MeasEnabled', value='none'),
    dict(dist_name=NRMEASCFG_para_GNB1, parameter='a5MeasEnabled', value='rsrp')]

GNB2_MODIFY_Parameter_710_014 = [
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actCarrierAggregation', value='false'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='caConfigurationSupport', value='none'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actMobilityProfile', value='true'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actSPID', value='true'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='true'),
    dict(dist_name=NRMEASCFG_para_GNB2, parameter='a3MeasEnabled', value='none'),
    dict(dist_name=NRMEASCFG_para_GNB2, parameter='a5MeasEnabled', value='rsrp'),
    dict(dist_name=NRHOIF_para_GNB2,
         parameter='a5MeasSsbRsrp',
         value=[{"a5HysteresisSsbRsrp": '0',
                 "a5Threshold1SsbRsrp": '86',
                 "a5Threshold2SsbRsrp": '66',
                 "a5TimeToTriggerSsbRsrp": 'ms100'}])]

GNB1_Reconver_Parameter_710_014 = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actMobilityProfile', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actSPID', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='false'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregation', value='true'),
    dict(dist_name=MR_NR_BTS_NAME, parameter='caConfigurationSupport', value='4CCDL_2CCUL'),
    dict(dist_name=NRMEASCFG_para_GNB1, parameter='a3MeasEnabled', value='rsrp'),
    dict(dist_name=NRMEASCFG_para_GNB1, parameter='a5MeasEnabled', value='none')]

GNB2_Reconver_Parameter_710_014 = [
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actMobilityProfile', value='false'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actSPID', value='false'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='false'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='actCarrierAggregation', value='true'),
    dict(dist_name=MR_NR_BTS2_NAME, parameter='caConfigurationSupport', value='4CCDL_2CCUL'),
    dict(dist_name=NRMEASCFG_para_GNB2, parameter='a3MeasEnabled', value='rsrp'),
    dict(dist_name=NRMEASCFG_para_GNB2, parameter='a5MeasEnabled', value='none')]

attached_pci_50 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='1')]

attached_pci_60 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '60'}, n='1')]

attached_pci_70 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '70'}, n='1')]

attached_pci_80 = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '80'}, n='1')]

attached_pci_50_Modification = [
    dict(xpath='SgNBModificationRequestAcknowledge/rrcReconfiguration/' + 'spCellConfig/reconfigurationWithSync',
         expected_value={'physCellId': '50'}, n='1')]

attached_pci_50_ModificationRequired = [
    dict(xpath='SgNBModificationRequired/RRCReconfiguration/' + 'spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '50'}, n='1')]

attached_pci_60_ModificationRequired = [
    dict(xpath='SgNBModificationRequired/RRCReconfiguration/' + 'spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '60'}, n='1')]

attached_pci_60_AdditionRequestAcknowledge = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '60'}, n='1')]

attached_pci_70_AdditionRequestAcknowledge = [
    dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' + 'spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '70'}, n='1')]

attached_pci_80_ModificationRequired = [
    dict(xpath='SgNBModificationRequired/RRCReconfiguration/' + 'spCellConfig/spCellConfigCommon',
         expected_value={'physCellId': '80'}, n='1')]

sgnb_chg_ho_cause = [
    dict(xpath='SgNBChangeRequired',
         expected_value={'radioNetwork': 'action-desirable-for-radio-reasons (31)'}, n='1')]

sgnb_chg_ho_refuse = [
    dict(xpath='SgNBChangeRefuse',
         expected_value={'radioNetwork': 'no-radio-resources-available-in-target-cell (12)'}, n='1')]

attach_message_flow = \
    dict(order_list=['SgNBAdditionRequest',
                     'SgNBAdditionRequestAcknowledge',
                     'RRCReconfigurationComplete',
                     'drx-Config: setup (1)',
                     'rrcReconfigurationComplete'],
         should_not_include=['SgNBReleaseRequest', 'UEContextRelease', 'SgNBReleaseRequestAcknowledge'])

intra_freq_inter_gnb_ho_message_flow = dict(order_list=['measurementreport',
                                                        'SgNBChangeRequired',
                                                        'SgNBAdditionRequest',
                                                        'SgNBAdditionRequestAcknowledge',
                                                        'SgNBChangeConfirm',
                                                        'SgNBReconfigurationComplete',
                                                        'UEContextRelease'],
                                            should_not_include=['SgNBReleaseRequest',
                                                                'SgNBReleaseRequestAcknowledge'],
                                            not_order_list=['drx-Config: setup (1)'])

enb_message_flow_source = dict(order_list=['SgNBModificationRequest',
                                           'SgNBModificationRequestAcknowledge',
                                           'HandoverRequest',
                                           'HandoverRequestAcknowledge',
                                           'SgNBReleaseRequest',
                                           'SgNBReleaseRequestAcknowledge',
                                           'UEContextRelease',
                                           'UEContextRelease'])

enb_message_flow_target = dict(order_list=['HandoverRequest',
                                           'SgNBAdditionRequest',
                                           'SgNBAdditionRequestAcknowledge',
                                           'HandoverRequestAcknowledge',
                                           'SgNBReconfigurationComplete',
                                           'PathSwitchRequest',
                                           'PathSwitchRequestAcknowledge',
                                           'UEContextRelease'])

enb_message_flow_575 = dict(order_list=['SgNBModificationRequest',
                                        'SgNBModificationRequestAcknowledge',
                                        'SgNBReconfigurationComplete'])

enb_message_flow_573_005 = dict(order_list=['measurementReport',
                                            'SgNBChangeRequired',
                                            'SgNBAdditionRequest',
                                            'SgNBAdditionRequestReject',
                                            'SgNBChangeRefuse'],
                                should_not_include=['rrcReconfigurationComplete'])

enb_message_flow_1094 = dict(order_list=['measurementReport',
                                         'SgNBModificationRequired',
                                         'SgNBModificationConfirm',
                                         'SgNBModificationRequired',
                                         'SgNBModificationConfirm'])

enb_message_flow_710_001 = dict(order_list=['measurementReport',
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


enb_message_flow_710_014 = dict(order_list=['measurementReport',
                                            'SgNBModificationRequired',
                                            'SgNBModificationRequest',
                                            'SgNBModificationRequestAcknowledge',
                                            'SgNBModificationConfirm',
                                            'measurementReport',
                                            'SgNBChangeRequired',
                                            'SgNBAdditionRequest',
                                            'SgNBAdditionRequestAcknowledge',
                                            'SgNBChangeConfirm',
                                            'SgNBReconfigurationComplete',
                                            'SNStatusTransfer',
                                            'UEContextRelease'])


SgNBSecurityKey = [
    dict(xpath='SgNBAdditionRequest', expected_value={'SgNBSecurityKey': ''}, n='1')]

DL_GTP_TEIDatMCG = [
    dict(xpath='SgNBAdditionRequest/meNB-DL-GTP-TEIDatMCG', expected_value={'gTP-TEID': ''}, n='1')]

UL_GTP_TEIDatPDCP = [
    dict(xpath='SgNBAdditionRequestAcknowledge/sgNB-UL-GTP-TEIDatPDCP', expected_value={'gTP-TEID': ''}, n='1')]

enb1_ho_enb2_check_for_574 = [
    dict(xpath='HandoverRequestAcknowledge', expected_value={'targetPhysCellId': '102'}, n='1'),
    dict(xpath='SgNBReleaseRequest', expected_value={'radioNetwork': 'mCG-Mobility (46)'}, n='1')]

enb2_ho_enb1_check_for_574 = [
    dict(xpath='HandoverRequestAcknowledge', expected_value={'targetPhysCellId': '100'}, n='1'),
    dict(xpath='SgNBReleaseRequest', expected_value={'radioNetwork': 'mCG-Mobility (46)'}, n='1')]

enb1_check_for_575 = [
    dict(xpath='SgNBModificationRequest', expected_value={'radioNetwork': 'mCG-Mobility (46)'}, n='1')]

SgNBSecurityKey_Modification = [
    dict(xpath='SgNBModificationRequest', expected_value={'sgNB-SecurityKey': ''}, n='1')]

DL_GTP_TEIDatMCG_Modification = [
    dict(xpath='SgNBModificationRequest/meNB-DL-GTP-TEIDatMCG', expected_value={'gTP-TEID': ''}, n='1')]

UL_GTP_TEIDatPDCP_Modification = [
    dict(xpath='SgNBModificationRequestAcknowledge/sgNB-UL-GTP-TEIDatPDCP', expected_value={'gTP-TEID': ''}, n='1')]

spid_710 = [dict(xpath='SgNBAdditionRequest', expected_value={'SubscriberProfileIDforRFP': '12'}, n='1')]

measGap_710 = \
    [dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'measGapConfig': 'setup (1)'}, n='1'),
     dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'gapPurpose': 'perUE (0)'}, n='1'),
     dict(xpath='SgNBModificationRequest/measConfigMN', expected_value={'measGapConfig': 'release (0)'}, n='2')]

measGap_710_014 = \
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

Scell_list = ['2081755', '2073115', '2080027', '2078299', '2083483', '2076571', '2074843']

SCELL_ARFCN_LIST_FOR_2518 = [
    dict(xpath='nonCriticalExtension/scellFrequenciesSN-NR', expected_value={'ARFCN-ValueNR': Scell_list}, n='1'),
    dict(xpath='nonCriticalExtension/scellFrequenciesSN-NR', expected_value={'ARFCN-ValueNR': Scell_list}, n='2'),
    dict(xpath='nonCriticalExtension/scellFrequenciesSN-NR', expected_value={'ARFCN-ValueNR': Scell_list}, n='3')
]

GNB2_SYSLOG_Disable = [
     dict(dist_name=TRBLCADM, parameter='actRemoteSyslogTransmission', value='false')]

GNB2_SYSLOG_Enable = [
     dict(dist_name=TRBLCADM, parameter='actRemoteSyslogTransmission', value='true')]
