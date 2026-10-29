from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'kk'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'kk.wang@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTS1_name = 'MRBTS-'+_gnb_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_SERVEDAMF = _NRBTS1_name+'/SERVEDAMF-1'
_NRCELL2_NRHOIF1 = _NRCELL2_name+'/NRHOIF-1'
_bwpDN0 = _NRBTS1_name+'/BWP_PROFILE-0'
_bwpDN7 = _NRBTS1_name+'/BWP_PROFILE-7'
_bwpDN77 = _NRBTS1_name+'/BWP_PROFILE-77'
_bwpDN6 = _NRBTS1_name+'/BWP_PROFILE-6'
_bwpDN67 = _NRBTS1_name+'/BWP_PROFILE-67'
_bwpDN65 = _NRBTS1_name+'/BWP_PROFILE-65'
_bwpDN63 = _NRBTS1_name+'/BWP_PROFILE-63'
_bwpDN5 = _NRBTS1_name+'/BWP_PROFILE-5'
_bwpDN53 = _NRBTS1_name+'/BWP_PROFILE-53'
_bwpDN57 = _NRBTS1_name+'/BWP_PROFILE-57'
_NRPMRNL = _NRBTS1_name+'/NRPMRNL-1'

PATH_TO_SCF = ''

PARAM_enbale_2200 = [
    dict(new_value='8x4 Closed Loop Spatial Multiplexing', dist_name=_NRCELL1_name,
         filter_param='Downlink MIMO Mode', abbr='dlMimoMode'),
    dict(new_value='1', dist_name=_NRCELL1_name,
         filter_param='CSI-RS number for CSI-RS resource set1 within one report period',
         abbr='csirsNumberWithinReportPe'),
    dict(new_value='6', dist_name=_NRCELL1_name,
         filter_param='CSI-RS power', abbr='csirsPower'),
    dict(new_value='1', dist_name=_NRCELL1_name,
         filter_param='Maximum CSI-RS number', abbr='maxCsirsNumber'),
    dict(new_value='0', dist_name=_NRCELL1_name,
         filter_param='SS PBCH Block Power', abbr='ssPbchBlockPower'),
    dict(new_value='false', dist_name=_NRCELL1_name,
         filter_param='BTS Beam Refinement P2', abbr='nrBtsBeamRefinementP2'),
    dict(new_value='true', dist_name=_NRBTS1_name,
         filter_param='Activate custom beam set realization', abbr='actCustomBsr')
]

cri_counter_id = [
    'M55308C22001', 'M55308C22002', 'M55308C22003', 'M55308C22004', 'M55308C22005', 'M55308C22006', 'M55308C22007'
]

counter_dic_path = ['BTS/CELLS/NRCELL-1/NCELA']

PARAM_Change_tmpParam9 = [{'dist_name': _NRCELL2_name, 'parameter': 'tmpParam9', 'value': '2251'}]

PARAM_Change_tmpParam9_Cell1 = [{'dist_name': _NRCELL1_name, 'parameter': 'tmpParam9', 'value': '2251'}]

PARAM_Change_tmpParam9_A003 = [{'dist_name': _NRCELL1_name, 'parameter': 'tmpParam9', 'value': '2045'}]

PARAM_Change_tmpParam9_A003_T362 = [
    dict(dist_name=_NRCELL2_name, parameter='csirsResourceSet', value=[{'csirsResourceSetConfig1CRI': '4x1-1wT'}])
]

PARAM_Change_2CRI = [
    dict(dist_name=_NRCELL1_name, parameter='csirsResourceSet', value=[{'csirsResourceSetConfig2CRI': '4x1-1-1_1_5'}])
]

LOCK_GNB1_CELL2 = [
    dict(
        value='Locked',
        dist_name=_NRCELL2_name,
        parameter='administrativeState')
]

UNLOCK_GNB1_CELL2 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL2_name,
        parameter='administrativeState')
]

LOCK_GNB1_CELL1 = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState')
]

UNLOCK_GNB1_CELL1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState')
]

UNLOCK_GNB_AMF = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF,
        parameter='administrativeState')
]

LOCK_GNB_AMF = [
    dict(
        value='Locked',
        dist_name=_SERVEDAMF,
        parameter='administrativeState')
]

DRX_onduration_CELL2 = [
    dict(
        value=[dict(drxOnDurationTimer='2ms')],
        dist_name=_NRCELL2_name,
        parameter='drxProfile1')
]

DRX_onduration_CELL1 = [
    dict(
        value=[dict(drxOnDurationTimer='2ms')],
        dist_name=_NRCELL1_name,
        parameter='drxProfile1')
]

DRX_onduration_22R3 = [
    dict(
        value=[dict(drxOnDurationTimer='2ms')],
        dist_name=_NRCELL1_name,
        parameter='drxProfile1')
]

CNI70851_modify_list_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

CNI70851_modify_para_22R2 = [
    dict(dist_name=_NRCELL2_name, p_name='physCellId', value='51'),
    dict(dist_name=_NRBTS1_name, p_name='nsaInactivityTimer', value='600')
]

CNI70851_modify_para_Trunk = [
    dict(dist_name=_NRCELL1_name, p_name='physCellId', value='51')
]

CNI70851_modify_list_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='10ms', index=0),
                   dict(p_name='drxLongCycle', value='40ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='0slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='0slot', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

CNI74278_modify_list = [
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='2x2-2-2_5_5', index=0)])
]

CNI74278_modify_para = [
    dict(dist_name=_NRPMRNL, p_name='miNrCellUtilization', value='5min')
]

CNI74278_modify_para_22R2 = [
    dict(dist_name=_NRPMRNL, p_name='miNrCellUtilization', value='5min'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

CNI74278_modify_list_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='2x2-2-2_5_5', index=0)])
]

CNI74278_modify_list_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='2x2-2-2_5_5', index=0)])
]

CNI74278_modify_para_Trunk = [
    dict(dist_name=_NRPMRNL, p_name='miNrCellUtilization', value='5min')
]

B025_modify_para_22R2 = [
    dict(dist_name=_NRCELL1_name, p_name='a2MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='a1MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL2_name, p_name='a2MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL2_name,
         p_name='dlMimoMode',
         value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
]

B025_modify_list_22R2 = [
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='40ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='40ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='1', index=0),
                   dict(p_name='csiReportPeriodicity', value='slots160', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='a2MeashoSsbRsrp',
         elements=[dict(p_name='a2ThresholdhoSsbRsrp', value='80', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='a1MeashoSsbRsrp',
         elements=[dict(p_name='a1ThresholdhoSsbRsrp', value='82', index=0)])
]

B025_DeleteLIST_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet'),
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition')
]

B025_ADDLIST_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=dict(csiReportPeriodicity='slots160')
         )
]

B007_Modify_List_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN5, index=0),
                   dict(p_name='bwpDN', value=_bwpDN57, index=1)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='4x1-2-1-1wT_2_2_4', index=0)])
]

B007_Modify_Para_Trunk = [
    dict(dist_name=_NRCELL1_name, p_name='chbw', value='100M'),
    dict(dist_name=_NRCELL1_name, p_name='actPerCsiReportBundlingTddFr1', value='true'),
]

B007_Modify_Para_22R3 = [
    dict(dist_name=_NRCELL1_name, p_name='chbw', value='100M')
]

B007_Modify_Para_22R2 = [
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

B007_Modify_List_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='4x1-2-1-1wT_2_2_4', index=0)])
]

B007_Modify_List_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN7, index=0),
                   dict(p_name='bwpDN', value=_bwpDN77, index=1)]),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='4x1-2-1-1wT_2_2_4', index=0)])
]

A003_Modify_List_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='1', index=0),
                   dict(p_name='maxCsirsNumber', value='1', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig1CRI', value='4x1-1wT', index=0)])
]

A003_Modify_List_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='1', index=0),
                   dict(p_name='maxCsirsNumber', value='1', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig1CRI', value='4x1-1wT', index=0)])
]

B017_Para_Delete_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='tddFrameStructure')
]

B017_Para_Delete_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='tddFrameStructure')
]

B017_Add_List_22R3 = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

B017_Add_List_22R2 = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

B017_Modify_Para_22R3 = [
    dict(dist_name=_NRBTS1_name, p_name='nsaInactivityTimer', value='600'),
    dict(dist_name=_SERVEDAMF, p_name='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL1_name, p_name='a1MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='a2MeashoEnabled', value='rsrp')
]

B017_Modify_Para_22R2 = [
    dict(dist_name=_NRCELL2_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRBTS1_name, p_name='nsaInactivityTimer', value='600'),
    dict(dist_name=_NRCELL2_name, p_name='a1MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL2_name, p_name='a2MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL2_NRHOIF1, p_name='freqBandIndicatorNR', value='78'),
    dict(dist_name=_NRCELL2_NRHOIF1, p_name='ssbFrequency', value='649900'),
    dict(dist_name=_NRCELL2_name, p_name='physCellId', value='362'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked'),
    dict(dist_name=_SERVEDAMF, p_name='administrativeState', value='Locked')
]

B017_Modify_Para_Trunk = [
    dict(dist_name=_SERVEDAMF, p_name='administrativeState', value='Locked'),
    dict(dist_name=_NRBTS1_name, p_name='nsaInactivityTimer', value='600'),
    dict(dist_name=_NRCELL1_name, p_name='a1MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='a2MeashoEnabled', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='gapOffset', value='1'),
    dict(dist_name=_NRCELL1_name, p_name='actPerCsiReportBundlingTddFr1', value='true'),
    dict(dist_name=_NRCELL1_name, p_name='ifhoSsbSmtcOffset', value='1')
]

B017_Modify_List_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN65, index=1)]),
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxOnDurationTimer', value='20ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)])
]

B017_Modify_List_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN67, index=1)]),
    dict(dist_name=_NRCELL2_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxOnDurationTimer', value='20ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)])
]

B017_Modify_List_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='10ms', index=0),
                   dict(p_name='drxLongCycle', value='40ms', index=0)])
]

B018_Para_Delete = [
    dict(dist_name=_NRCELL1_name, list_name='tddFrameStructure')
]

B018_Para_Delete_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='tddFrameStructure')
]

B018_Add_List_22R3 = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

B018_Add_List_22R2 = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

B018_Add_List_Trunk = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='1/4'))
]

B018_Modify_Para_22R2 = [
    dict(dist_name=_NRCELL2_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRBTS1_name, p_name='srbInactivityTimerSA', value='10'),
    dict(dist_name=_NRBTS1_name, p_name='drbInactivityTimerSA', value='10'),
    dict(dist_name=_NRBTS1_name, p_name='inactivityTimerSA', value='10'),
    dict(dist_name=_NRCELL2_name, p_name='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRCELL2_name, p_name='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRCELL2_name, p_name='gapOffset', value='18'),
    dict(dist_name=_NRCELL2_name, p_name='ifhoSsbSmtcOffset', value='18'),
    dict(dist_name=_NRCELL2_name, p_name='physCellId', value='362'),
    dict(dist_name=_NRCELL2_NRHOIF1, p_name='freqBandIndicatorNR', value='78'),
    dict(dist_name=_NRCELL2_NRHOIF1, p_name='ssbFrequency', value='649900')
]

B018_Modify_Para_22R3 = [
    dict(dist_name=_NRBTS1_name, p_name='srbInactivityTimerSA', value='10'),
    dict(dist_name=_NRCELL1_name, p_name='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='gapOffset', value='18'),
    dict(dist_name=_NRCELL1_name, p_name='ifhoSsbSmtcOffset', value='18'),
    dict(dist_name=_NRBTS1_name, p_name='drbInactivityTimerSA', value='10'),
    dict(dist_name=_NRBTS1_name, p_name='inactivityTimerSA', value='10')
]

B018_Modify_Para_Trunk = [
    dict(dist_name=_NRCELL1_name, p_name='prachConfigurationIndex', value='98'),
    dict(dist_name=_NRBTS1_name, p_name='srbInactivityTimerSA', value='10'),
    dict(dist_name=_NRBTS1_name, p_name='drbInactivityTimerSA', value='10'),
    dict(dist_name=_NRBTS1_name, p_name='inactivityTimerSA', value='10'),
    dict(dist_name=_NRCELL1_name, p_name='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRCELL1_name, p_name='a2MeashoEnabledSA', value='rsrp')
]

B018_Modify_List_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN65, index=1)]),
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxOnDurationTimer', value='20ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)])
]

B018_Modify_List_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN67, index=1)]),
    dict(dist_name=_NRCELL2_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxOnDurationTimer', value='20ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)])
]

B018_Modify_List_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN5, index=0),
                   dict(p_name='bwpDN', value=_bwpDN53, index=1)]),
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='10ms', index=0),
                   dict(p_name='drxLongCycle', value='40ms', index=0)])
]

B008_Para_Delete_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='tddFrameStructure')
]

B008_Para_Delete = [
    dict(dist_name=_NRCELL1_name, list_name='tddFrameStructure')
]

B008_Add_List = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

B008_Add_List_22R2 = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

B008_Modify_List_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='maxCsirsNumber', value='2', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN67, index=1)]),
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig2CRI', value='4x1-2_0', index=0)])
]

B008_Modify_List_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='maxCsirsNumber', value='2', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig2CRI', value='4x1-2_0', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN65, index=1)])
]

B008_Modify_List_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='maxCsirsNumber', value='2', index=0),
                   dict(p_name='csirsNumberWithinReportPeriod_Set1',
                        value='2', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN6, index=0),
                   dict(p_name='bwpDN', value=_bwpDN63, index=1)]),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig2CRI', value='4x1-2_0', index=0)])
]

B008_Modify_Para_TRUNK = [
    dict(dist_name=_NRCELL1_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_SERVEDAMF, p_name='administrativeState', value='Locked'),
]

B008_Modify_Para_22R3 = [
    dict(dist_name=_SERVEDAMF, p_name='administrativeState', value='Locked')
]

B008_Modify_Para_22R2 = [
    dict(dist_name=_NRCELL2_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_SERVEDAMF, p_name='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked'),
]

CNI70137_Modify_List_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='1', index=0),
                   dict(p_name='csiReportPeriodicity', value='slots320', index=0)])
]

CNI70137_Modify_List_22R2 = [
    dict(dist_name=_NRCELL2_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

CNI70137_Modify_List_Trunk = [
    dict(dist_name=_NRCELL1_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

CNI70137_Modify_Para_Trunk = [
    dict(dist_name=_NRCELL1_name, p_name='physCellId', value='51')
]

CNI70137_Modify_Para_22R2 = [
    dict(dist_name=_NRCELL2_name, p_name='physCellId', value='362'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]
