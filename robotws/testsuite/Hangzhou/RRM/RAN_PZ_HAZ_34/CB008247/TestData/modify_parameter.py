from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liujia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTS1_name = 'MRBTS-'+_global_bts_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRCELL3_name = _NRBTS1_name+'/NRCELL-3'
_NRCELL4_name = _NRBTS1_name+'/NRCELL-4'

_NRCELL37401_name = _NRBTS1_name+'/NRCELL-37401'
_NRCELL37402_name = _NRBTS1_name+'/NRCELL-37402'
_NRCELL37403_name = _NRBTS1_name+'/NRCELL-37403'


_SERVEDAMF_1 = _NRBTS1_name+'/SERVEDAMF-1'
_bwpDN5 = _NRBTS1_name+'/BWP_PROFILE-5'
_bwpDN53 = _NRBTS1_name+'/BWP_PROFILE-53'
_bwpDN52 = _NRBTS1_name+'/BWP_PROFILE-52'
_bwpDN57 = _NRBTS1_name+'/BWP_PROFILE-57'
_bwpDN55 = _NRBTS1_name+'/BWP_PROFILE-55'
_bwpDN1005 = _NRBTS1_name+'/BWP_PROFILE-1005'
_bwpDN10052 = _NRBTS1_name+'/BWP_PROFILE-10052'
_NRPMRNL = _NRBTS1_name+'/NRPMRNL-1'

PATH_TO_SCF = ''

UNLOCK_GNB1_CELLs = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL3_name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL4_name,
        parameter='administrativeState')
]

UNLOCK_GNB1_CELL3 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL3_name,
        parameter='administrativeState')
]
# ------------ 10602_counter ------------ #
counter_dic_path_10602_cloud = [
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-2/NRBF'.format(_NRBTS1_name),
]

counter_dic_path_10602_Trunk = [
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
    'BTS/{}/NRCELL-37401/NRBF'.format(_NRBTS1_name),
]

counter_dic_path_10602_old = [
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
    'BTS/CELLS/NRCELL-1/NRBF',
]

counter_id_10602_Trunk = [
    'M55305C14011', 'M55305C14012', 'M55305C14013', 'M55305C14014', 'M55305C14015',
    'M55305C14016', 'M55305C14017', 'M55305C14018', 'M55305C14019', 'M55305C14020',
]

# ------------ A-changeTilt ------------ #
Lock_gnb1_AMF1 = [
    dict(value='Locked', dist_name=_SERVEDAMF_1, parameter='administrativeState'),
]

Unlock_gnb1_AMF1 = [
    dict(value='Unlocked', dist_name=_SERVEDAMF_1, parameter='administrativeState'),
]

CHANGE_MODIFY_PARA = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='-86',
        dist_name=_NRCELL1_name,
        p_name='p0NominalSrs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUeCsirsCoexistCellCsirs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actPdschBeamPowerBalance'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL1_name,
        p_name='beamPowerOffsetThreshold'
    )
]

CHANGE_MODIFY_PARA_cloud = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL2_name,
        p_name='dlMimoMode'),
]

CHANGE_MODIFY_PARA_22R3 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='-86',
        dist_name=_NRCELL1_name,
        p_name='p0NominalSrs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
]

CHANGE_PARA_DELETE = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet')
]

CHANGE_PARA_DELETE_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet')
]

CHANGE_ADD_LIST = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

CHANGE_ADD_LIST_cloud = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

CHANGE_MODIFY_LIST = [
    dict(dist_name=_NRCELL1_name, list_name='beamSet',
         elements=[dict(p_name='tiltOffset', value='3', index=0)])
]

CHANGE_MODIFY_LIST_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='beamSet',
         elements=[dict(p_name='tiltOffset', value='3', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsPowerThresholdForDlBm', value='-1200', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-96', index=0)]),
]

PARAMS_TO_MODIFY_TILTOFFSET_P0_PCI = [
    dict(
        value=[dict(tiltOffset='-3')],
        dist_name=_NRCELL1_name,
        parameter='beamSet'),
    dict(
        value=[dict(p0NominalSrs='-86')],
        dist_name=_NRCELL1_name,
        parameter='ulPowerControlCommon'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actPciBasedCsiImRandomization')
]

PARAMS_TO_MODIFY_TILTOFFSET_P0_PCI_cloud = [
    dict(
        value=[dict(tiltOffset='-3')],
        dist_name=_NRCELL2_name,
        parameter='beamSet'),
    dict(
        value=[dict(p0NominalSrs='-86')],
        dist_name=_NRCELL2_name,
        parameter='ulPowerControlCommon'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actPciBasedCsiImRandomization')
]

PARAMS_TO_MODIFY_DLUL_SRS = [
    dict(
        value='3',
        dist_name=_NRCELL1_name,
        p_name='tiltOffset'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm')
]

# ------------ A-BEAMSWITCH ------------ #

BEAMSWITCH_MODIFY_PARA = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='-86',
        dist_name=_NRCELL1_name,
        p_name='p0NominalSrs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUeCsirsCoexistCellCsirs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actPdschBeamPowerBalance'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL1_name,
        p_name='beamPowerOffsetThreshold'
    )
]

BEAMSWITCH_MODIFY_PARA_cloud = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='-86',
        dist_name=_NRCELL2_name,
        p_name='p0NominalSrs'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL2_name,
        p_name='dlMimoMode'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

BEAMSWITCH_MODIFY_PARA_22R3 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='-86',
        dist_name=_NRCELL1_name,
        p_name='p0NominalSrs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
]

BEAMSWITCH_PARA_DELETE = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet')
]

BEAMSWITCH_PARA_DELETE_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet')
]

BEAMSWITCH_ADD_LIST = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

BEAMSWITCH_ADD_LIST_cloud = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

BEAMSWITCH_Modify_List = [
    dict(dist_name=_NRCELL1_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsTypeAllocForDlBm', value='codebook', index=0)]),
]

BEAMSWITCH_Modify_List_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsTypeAllocForDlBm', value='codebook', index=0)]),
]

# ------------ A-T1R4 ------------ #
PARAMS_TO_MODIFY_TAS_reuse = [
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        p_name='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUeCsirsCoexistCellCsirs'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actPdschBeamPowerBalance'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL1_name,
        p_name='beamPowerOffsetThreshold'
    )
]

PARAMS_TO_MODIFY_TAS_reuse_cloud = [
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL2_name,
        p_name='dlMimoMode'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

PARAMS_TO_MODIFY_TAS_reuse_22R3 = [
    dict(
        value='Locked',
        dist_name=_SERVEDAMF_1,
        p_name='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
]

PARA_DELETE_T1R4 = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL1_name, list_name='csirsResourceSet')
]

PARA_DELETE_T1R4_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet')
]

ADD_LIST_T1R4 = [
    dict(
        dist_name=_NRCELL1_name,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

ADD_LIST_T1R4_cloud = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

Modify_List_T1R4_TRUNK = [
    dict(dist_name=_NRCELL1_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-86', index=0)]),
]

Modify_List_T1R4_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-86', index=0)])
]

Modify_List_T1R4_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-86', index=0)])
]

PARAMS_TO_MODIFY_NOTREUSE = [
    dict(
        value=[dict(srsUePeriodicity='slots80')],
        dist_name=_NRCELL1_name,
        parameter='srsForBeamMgmt'),
]

PARAMS_TO_MODIFY_NOTREUSE_cloud = [
    dict(
        value=[dict(srsUePeriodicity='slots80')],
        dist_name=_NRCELL2_name,
        parameter='srsForBeamMgmt'),
]

UNLOCK_SERVEDAMF = [
    dict(
        value='Unlocked',
        dist_name=_SERVEDAMF_1,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_POWER_CONTROL = [
    dict(
        value='15',
        dist_name=_NRCELL1_name,
        parameter='ssPbchBlockPower'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actCDrx')
]

# --------------- A-Power Control -------------#
PARAMS_TO_MODIFY_ULSRSBM = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL1_name,
        p_name='dlMimoMode'),
]

PARAMS_TO_MODIFY_ULSRSBM_cloud = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELL2_name,
        p_name='dlMimoMode'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

PARAMS_TO_MODIFY_DLSRSBM = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actCsirsMultiplexing')
]

PARAMS_TO_MODIFY_DLSRSBM_cloud = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actCsirsMultiplexing')
]

# ------------ B1-002 ------------ #
PARAMS_TO_MODIFY_B1002 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUeCsirsCoexistCellCsirs')
]

LIST_TO_MODIFY_B1002 = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

PARAMS_TO_MODIFY_B1002_23R2 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimoEnh'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUeCsirsCoexistCellCsirs')
]

LIST_TO_MODIFY_B1002_23R2 = [
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

ONLINE_MODIFY_B1002 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actDlMuMimo'),

]
# ------------ B3-001 ------------ #
PARAMS_TO_MODIFY_B3001 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actPdschBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL1_name,
        p_name='beamPowerOffsetThreshold'
    )
]

PARAMS_TO_MODIFY_B3001_cloud = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL3_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL4_name,
        p_name='administrativeState'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL2_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL2_name,
        p_name='maxNumPuschAllocationPerSlot'),
    # dict(
    #     value='false',
    #     dist_name=_NRBTS1_name,
    #     p_name='actBbPoolTddFr1'),
    # dict(
    #     value='false',
    #     dist_name=_NRBTS1_name,
    #     p_name='actBbPoolExtensionTddFr1'),
    # dict(
    #     value='false',
    #     dist_name=_NRBTS1_name,
    #     p_name='actBbPoolTddFr1AlgEnh'),
    #
    # dict(
    #     value='false',
    #     dist_name=_NRBTS1_name,
    #     p_name='actLargeBbPoolTddFr1'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

PARAMS_TO_MODIFY_B3001_22R3 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
]

List_TO_MODIFY_B3001 = [
    dict(dist_name=_NRCELL1_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-86', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsPowerThresholdForDlBm', value='-1000', index=0)]),
]

List_TO_MODIFY_B3001_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-86', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='4', index=0)]),
    # dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
    #      elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='4', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsPowerThresholdForDlBm', value='-1060', index=0)]),
]

List_TO_MODIFY_B3001_22R3 = [
    dict(dist_name=_NRCELL1_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-80', index=0),
                   dict(p_name='alphaSrs', value='alpha09', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsPowerThresholdForDlBm', value='-1100', index=0)])
]

Enable_EIRP_online_175 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEirpControl'),
    dict(
        value=['-50', '-50', '-50', '-50', '-50', '-50', '-50', '-50', '-50', '-50', '-50', '-50'],
        dist_name=_NRCELL1_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

Enable_EIRP_online_006 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEirpControl'),
    dict(
        value=['-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60'],
        dist_name=_NRCELL1_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

Enable_EIRP_online_cloud = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actEirpControl'),
    dict(
        value=['-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80'],
        dist_name=_NRCELL2_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

ONLINE_MODIFY_B3001_CLOUD_3 = [
    dict(
        value=[dict(csirsNumberWithinReportPeriod_Set1='3')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
]

ONLINE_MODIFY_B3001_CLOUD_2 = [
    dict(
        value=[dict(csirsNumberWithinReportPeriod_Set1='2')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
]

ONLINE_MODIFY_B3001_CLOUD_1 = [
    dict(
        value=[dict(csirsNumberWithinReportPeriod_Set1='1')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
]
# --------- B4_003 -------- #
ONLine_MODIFY_B4003_11006 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actUlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actCsirsMultiplexing'),
    dict(value='false', dist_name=_NRCELL1_name, parameter='actUeCsirsCoexistCellCsirs'),
    dict(value='false', dist_name=_NRCELL1_name, parameter='actCsirsBeamPowerBalance'),
]

Modify_sspbchpower_11006 = [
    dict(
        value=[dict(csirsPower='19')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='19',
        dist_name=_NRCELL1_name,
        parameter='ssPbchBlockPower'),
]

ONLine_Recovery_B4003_11006 = [
    dict(
        value=[dict(csirsPower='13')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='10',
        dist_name=_NRCELL1_name,
        parameter='ssPbchBlockPower'),
    dict(value='true', dist_name=_NRCELL1_name, parameter='actUeCsirsCoexistCellCsirs'),
    dict(value='true', dist_name=_NRCELL1_name, parameter='actCsirsBeamPowerBalance'),
]

PARAMS_TO_MODIFY_B4003_cloud = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL3_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL4_name,
        p_name='administrativeState'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

PARAMS_TO_MODIFY_CSIRS_PBCH_POWER = [
    dict(
        value=[dict(csirsPower='19')],
        dist_name=_NRCELL1_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='19',
        dist_name=_NRCELL1_name,
        parameter='ssPbchBlockPower'),
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actCDrx')
]

PARAMS_TO_MODIFY_CSIRS_PBCH_POWER_cloud = [
    dict(
        value=[dict(csirsPower='22')],
        dist_name=_NRCELL2_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='22',
        dist_name=_NRCELL2_name,
        parameter='ssPbchBlockPower'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actCDrx'),
    dict(
        value='disabled',
        dist_name=_NRCELL2_name,
        parameter='actTcpBoostPug'),
]

# -----------------------------D11-------------------
PARAMS_TO_MODIFY_D11 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actPowerSavingBWP'),
    dict(
        value='13',
        dist_name=_NRCELL1_name,
        p_name='msg1FrequencyStart')
]

List_TO_MODIFY_D11 = [
    dict(dist_name=_NRCELL1_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value='-110', index=0)]),
    dict(dist_name=_NRCELL1_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

PARAMS_TO_ADD_D11 = [
    dict(dist_name=_NRCELL1_name, list_name='cellBwpList',
         elements=[dict(bwpDN='MRBTS-10175/NRBTS-10175/BWP_PROFILE-71',
                        cellBwpId='3')]
         )
]

# ---- W06 ----#
PARAMS_TO_MODIFY_W06 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        p_name='csirsNumberWithinReportPeriod_Set1'
    ),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actPdschBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL1_name,
        p_name='beamPowerOffsetThreshold'
    )
]

PARAMS_TO_MODIFY_W06_cloud = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL3_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL4_name,
        p_name='administrativeState'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='1200',
        dist_name=_NRCELL2_name,
        p_name='tmpParam3'),
    dict(
        value='4',
        dist_name=_NRCELL2_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL2_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='2',
        dist_name=_NRCELL2_name,
        p_name='csirsNumberWithinReportPeriod_Set1'
    ),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

PARAMS_TO_MODIFY_W06_22R3 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL1_name,
        p_name='maxNumPuschAllocationPerSlot'),
    dict(
        value='2',
        dist_name=_NRCELL1_name,
        p_name='csirsNumberWithinReportPeriod_Set1'
    ),
]

ONLine_MODIFY_W06_3741199999 = [
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actCsirsMultiplexing'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actUeCsirsCoexistCellCsirs'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actCsirsBeamPowerBalance'),
    dict(
        value='4',
        dist_name=_NRCELL37401_name,
        parameter='maxNumPdschAllocationPerSlot'),
    dict(
        value='4',
        dist_name=_NRCELL37401_name,
        parameter='maxNumPuschAllocationPerSlot'),
    dict(
        value=[dict(csirsNumberWithinReportPeriod_Set1='2')],
        dist_name=_NRCELL37401_name,
        parameter='periodicCsiAcquisition'),
]

PARAMS_TO_Recovery_W06_3741199999 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL37402_name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL37403_name,
        parameter='administrativeState'),
    dict(
        value='1',
        dist_name=_NRCELL37401_name,
        parameter='csirsNumberWithinReportPeriod_Set1'
    ),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actUeCsirsCoexistCellCsirs'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actCsirsBeamPowerBalance'),
]

# ---- 10602_A_01 ----#
Lock_GNBCELL = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL37403_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL37402_name,
        p_name='administrativeState'),
]

ONLine_MODIFY_10602_3741199999 = [
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actCsirsMultiplexing'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actUeCsirsCoexistCellCsirs'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actPdschBeamPowerBalance'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actCsirsBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL37401_name,
        parameter='beamPowerOffsetThreshold'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actRat1Alloc'),
    dict(
        value='false',
        dist_name=_NRCELL37401_name,
        parameter='actDlDynSwitchAlloc'),
    dict(
        value='disabled',
        dist_name=_NRCELL37401_name,
        parameter='actExhaustiveScheduling'),
    dict(
        value='s80',
        dist_name=_NRBTS1_name + '/NRSYSINFO_PROFILE-256',
        parameter='siWindowLength'),
]

ONLine_Recovery_10602_3741199999 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL37402_name,
        parameter='administrativeState'),
    dict(
        value='Unlocked',
        dist_name=_NRCELL37403_name,
        parameter='administrativeState'),
    dict(
        value='10',
        dist_name=_NRCELL37401_name,
        parameter='ssPbchBlockPower'),
    dict(
        value=[dict(csirsPower='13')],
        dist_name=_NRCELL37401_name,
        parameter='periodicCsiAcquisition'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actRat1Alloc'),
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actDlDynSwitchAlloc'),
    dict(
        value='s40',
        dist_name=_NRBTS1_name + '/NRSYSINFO_PROFILE-256',
        parameter='siWindowLength'),
]

PARAMS_TO_MODIFY_A01_cloud = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL3_name,
        p_name='administrativeState'),
    dict(
        value='Locked',
        dist_name=_NRCELL4_name,
        p_name='administrativeState'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        p_name='actDlMuMimo'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actDlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsMultiplexing'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actUeCsirsCoexistCellCsirs'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actPdschBeamPowerBalance'),
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        p_name='actCsirsBeamPowerBalance'),
    dict(
        value='6',
        dist_name=_NRCELL2_name,
        p_name='beamPowerOffsetThreshold'
    ),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdV'),
    dict(
        value='15',
        dist_name=_NRCELL2_name,
        p_name='dftBeamDiffThresholdH'),
]

LIST_TO_MODIFY_A01_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='srsForBeamMgmt',
         elements=[dict(p_name='srsPowerThresholdForDlBm', value=-1200, index=0)]
         ),
    dict(dist_name=_NRCELL2_name, list_name='ulPowerControlCommon',
         elements=[dict(p_name='p0NominalSrs', value=-86, index=0),
                   dict(p_name='p0NominalPusch', value=-90, index=0)]
         ),
]

add_new_flags = [
    '0x580477=1',
    '0x580264=0x1F',
    '0x58057b=0x201',
]

# --------------------2200_C_007---------------- #
PARA_Modify_online_C007_10175 = [
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actEirpControl'),
    dict(
        value=['-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80'],
        dist_name=_NRCELL1_name,
        parameter='eirpControlPowerReductionFactorList')
]

PARA_Modify_online_C007_3741199999 = [
    dict(
        value='true',
        dist_name=_NRCELL37401_name,
        parameter='actEirpControl'),
    dict(
        value=['-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60', '-60'],
        dist_name=_NRCELL37401_name,
        parameter='eirpControlPowerReductionFactorList')
]


ParameterToDelete_C007_3741199999 = [
    dict(dist_name=_NRCELL37401_name, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL37401_name, list_name='cellBwpList'),
]

ListToAdd_C007_3741199999 = [
    dict(
        dist_name=_NRCELL37401_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-1006',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-65',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-10061',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')),
]

ParamterToModify_C007_3741199999 = [
    dict(value='202', dist_name=_NRCELL37401_name, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELL37401_name, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='false', dist_name=_NRCELL37401_name, p_name='actCsirsBeamPowerBalance'),
    dict(value='false', dist_name=_NRCELL37401_name, p_name='actIncUlPdcchCapacity'),
]

ParameterToDelete_Recovery_C007_3741199999 = [
    dict(dist_name=_NRCELL37401_name, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL37401_name, list_name='cellBwpList'),
]

ListToAdd_Recovery_C007_3741199999 = [
    dict(
        dist_name=_NRCELL37401_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='3ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-1008',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-85',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL37401_name,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='true',
            bwpDN=_NRBTS1_name + '/BWP_PROFILE-10081',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')),
]

PARA_Modify_Recovery_C007_3741199999 = [
    dict(value='false', dist_name=_NRCELL37401_name,  p_name='actEirpControl'),
    dict(value='157', dist_name=_NRCELL37401_name, p_name='prachConfigurationIndex'),
    dict(value='true', dist_name=_NRCELL37401_name, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='true', dist_name=_NRCELL37401_name, p_name='actCsirsBeamPowerBalance'),
]

counter_id_C007_1_3741199999 = [
    'M55324C00464', 'M55324C00400', 'M55324C00401', 'M55324C00402', 'M55324C00403', 'M55324C00404', 'M55324C00405'
]

counter_id_C007_0_3741199999 = [
    'M55324C004'
]

counter_dic_path_C007_3741199999 = [
    'BTS/{}/NRCELL-37401/NREIRP'.format(_NRBTS1_name)
]

PARA_TO_DELETE_C007 = [
    dict(dist_name=_NRCELL2_name, list_name='tddFrameStructure')
]

PARA_TO_DELETE_C007_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL3_name, list_name='tddFrameStructure'),
]

LIST_TO_ADD_C007 = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='1/4'))
]

LIST_TO_ADD_C007_cloud = [
    dict(
        dist_name=_NRCELL2_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=_NRCELL3_name,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='1/4')),
]

PARA_TO_MODIFY_C007 = [
    dict(dist_name=_NRCELL2_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRCELL2_name, p_name='actDlMuMimo', value='false'),
    dict(dist_name=_NRCELL3_name, p_name='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

PARA_TO_MODIFY_C007_cloud = [
    dict(dist_name=_NRCELL2_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRCELL3_name, p_name='prachConfigurationIndex', value='157'),
    dict(dist_name=_NRCELL2_name, p_name='actDlMuMimo', value='false'),
    dict(dist_name=_NRCELL3_name, p_name='actDlMuMimo', value='false'),
    dict(dist_name=_NRCELL3_name, p_name='administrativeState', value='Locked'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

LIST_TO_MODIFY_C007 = [
    dict(dist_name=_NRCELL2_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN5, index=0),
                   dict(p_name='bwpDN', value=_bwpDN57, index=1),
                   dict(p_name='bwpDN', value=_bwpDN52, index=2),
                   ])
]

LIST_TO_MODIFY_C007_cloud = [
    dict(dist_name=_NRCELL2_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN1005, index=0),
                   dict(p_name='bwpDN', value=_bwpDN57, index=1),
                   dict(p_name='bwpDN', value=_bwpDN10052, index=2),
                   ]),
    dict(dist_name=_NRCELL3_name, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=_bwpDN1005, index=0),
                   dict(p_name='bwpDN', value=_bwpDN55, index=1),
                   dict(p_name='bwpDN', value=_bwpDN10052, index=2),
                   ]),
]

PARA_Modify_online_C007 = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actEirpControl'),
    dict(
        value=['-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80', '-80'],
        dist_name=_NRCELL2_name,
        parameter='eirpControlPowerReductionFactorList',
    )
]

counter_id_C007_1 = [
    'M55324C00464', 'M55324C00400', 'M55324C00401', 'M55324C00402', 'M55324C00403', 'M55324C00404', 'M55324C00405'
]

counter_id_C007_0 = [
    'M55324C004'
]

counter_dic_path_C007_cloud = [
    'BTS/{}/NRCELL-2/NREIRP'.format(_NRBTS1_name)
]

counter_dic_path_C007 = [
    'BTS/CELLS/NRCELL-2/NREIRP'
]
# --------CNI74278-------#
PARA_TO_MODIFY_74278 = [
    dict(dist_name=_NRPMRNL, p_name='miNrCellUtilization', value='5min'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

LIST_TO_MODIFY_74278 = [
    dict(dist_name=_NRCELL2_name, list_name='csirsResourceSet',
         elements=[dict(p_name='csirsResourceSetConfig4CRI', value='2x2-2-2_5_5', index=0)])
]

# -------CNI70137---------- #
LIST_TO_MODIFY_70137 = [
    dict(dist_name=_NRCELL2_name, list_name='drxProfile1',
         elements=[dict(p_name='drxInactivityTimer', value='20ms', index=0),
                   dict(p_name='drxLongCycle', value='80ms', index=0),
                   dict(p_name='drxRetransTimerDl', value='16slot', index=0),
                   dict(p_name='drxRetransTimerUl', value='16slot', index=0)]),
    dict(dist_name=_NRCELL2_name, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='2', index=0)])
]

PARA_TO_MODIFY_70137 = [
    dict(dist_name=_NRCELL2_name, p_name='physCellId', value='362'),
    dict(dist_name=_NRCELL1_name, p_name='administrativeState', value='Locked')
]

DRX_onduration_CLOUD = [
    dict(
        value=[dict(drxOnDurationTimer='2ms')],
        dist_name=_NRCELL2_name,
        parameter='drxProfile1')
]
