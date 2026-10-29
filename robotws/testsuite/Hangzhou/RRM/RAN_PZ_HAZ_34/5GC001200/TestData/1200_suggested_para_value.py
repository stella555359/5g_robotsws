from robot.libraries.BuiltIn import BuiltIn
import logging
tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'

logging.warning(program)
if program == '19A':
    DIST_RLRESUMEBACKOFFTMR = NR_NAME
else:
    DIST_RLRESUMEBACKOFFTMR = NR_CELL_NAME

if program == '20B':
    db_unit = 'dB'
else:
    db_unit = ' (dB)'


#       PART1--this part are parameters to be modified via rest api.
#       <dist_name>: refers to the dist_name as the scf. Its value can be NR_NAME, 'NRCELL-1'
#       <parameter>: refers to the p_name as the scf file. if need to modify p_name involving in list_name,
#                     put list_name in <parameter>, then all other p_name which exist in this list_name and the
#                     value of related p_name should be put into <value>

MODIFY_NIDD_VIA_API_1200_A_401_RESTORE = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode')
]

#  used to restore NIDD parameters after case402, need to be aligned with MODIFY_SCF_1200_A_BASE
MODIFY_NIDD_VIA_API_1200_A_402_RESTORE = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        parameter='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        parameter='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        parameter='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        parameter='rloConsecDtxThreshold'),
    dict(
        value='160',
        dist_name=NR_CELL_NAME,
        parameter='rloPathLossThreshold'),
    dict(
        value='-200',
        dist_name=NR_CELL_NAME,
        parameter='rloSinrThreshold'),
    dict(
        value='300',
        dist_name=NR_CELL_NAME,
        parameter='rlResumeSinrThreshold'),
]

MODIFY_NIDD_VIA_API_1200_SRB3 = [
    dict(
        value='true',
        dist_name=NR_NAME,
        parameter='srb3SupportEnabled')
]

MODIFY_NIDD_VIA_API_1200_DISABLE_SRB3 = [
    dict(
        value='false',
        dist_name=NR_NAME,
        parameter='srb3SupportEnabled')
]

MODIFY_NIDD_VIA_API_1200_DTX_SAMPLES = [
    dict(
        value='5',
        dist_name=NR_CELL_NAME,
        parameter='pucchDataDtxNumOfSamples'),
    dict(
        value='5',
        dist_name=NR_CELL_NAME,
        parameter='puschDataDtxNumOfSamples')
]

MODIFY_ENB_VIA_API_ENABLE_MUL_DRB = [
    dict(
        value='true',
        dist_name=LTE_NAME,
        parameter='actMultBearers'),
    dict(
        value='true',
        dist_name=LTE_NAME,
        parameter='actMultiSCGSplit')
]

MODIFY_ENB_VIA_API_MODIFY_ATTACH_CELL = [
    dict(
        value='true',
        dist_name=LTE_CELL_NAME,
        parameter='defaultLnRelGnbCellId')
]


#       PART2--this part are parameters to be modified via WebUI or WebEM.
#       <dist_name>: refers to the dist_name as the scf. Its value can be NR_NAME, 'NRCELL-1'
#       <abbr>: refers to the p_name as the scf file. if need to modify p_name involving in list_name,
#                     put list_name in <parameter>, then all other p_name which exist in this list_name and the
#                     value of related p_name should be put into <value>

MODIFY_NIDD_VIA_WEBUI_1200_A_401 = [
    dict(
        new_value='false',
        dist_name=NR_CELL_NAME,
        abbr='actDynUlDataSplitMode',
        filter_param='Activate dynamic UL data split mode')
]

#       NOTE:THIS IS VERY IMPORTANT!!!!!!
#       1. the order in the parameter should be fixed
#       2. if need to add new parameter list, thou shall add after the existing parameter lists.

MODIFY_NIDD_VIA_WEBUI_1200_A_402 = [
    dict(
        new_value='60',
        dist_name=NR_CELL_NAME,
        abbr='pucchDataDtxNumOfSamples',
        filter_param='Number of PUCCH data samples for DTX detection'),
    dict(
        new_value='60',
        dist_name=NR_CELL_NAME,
        abbr='puschDataDtxNumOfSamples',
        filter_param='Number of PUSCH data samples for DTX detection'),
    dict(
        new_value='1',
        dist_name=NR_CELL_NAME,
        abbr='rloConsecDtxThreshold',
        filter_param='Radio link outage consecutive DTX threshold'),
    dict(
        new_value='159',
        dist_name=NR_CELL_NAME,
        abbr='rloPathLossThreshold',
        filter_param='Radio link outage path loss threshold',
        unit=db_unit),
    dict(
        new_value='-19.9',
        dist_name=NR_CELL_NAME,
        abbr='rloSinrThreshold',
        filter_param='Radio link outage SINR threshold',
        unit=db_unit),
    dict(
        new_value='29.9',
        dist_name=NR_CELL_NAME,
        abbr='rlResumeSinrThreshold',
        filter_param='Radio link resume SINR threshold',
        unit=db_unit)
]

#       [obsolete]
MODIFY_NIDD_VIA_WEBUI_1200_B_403 = [
    dict(
        new_value='81',
        dist_name=NR_CELL_NAME,
        abbr='rlResumePathLossThreshold',
        filter_param='Radio link resume path loss threshold',
        unit='dB'),
    dict(
        new_value='-2.4',
        dist_name=NR_CELL_NAME,
        abbr='rlResumeSinrThreshold',
        filter_param='Radio link resume SINR threshold',
        unit='dB'),
    dict(
        new_value='-4.4',
        dist_name=NR_CELL_NAME,
        abbr='rloSinrThreshold',
        filter_param='Radio link outage SINR threshold',
        unit='dB')
]

MODIFY_NIDD_VIA_WEBUI_1200_B_404 = [
    dict(
        new_value='6004',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        abbr='rlResumeBackOffTmr',
        filter_param='Radio link resume back-off timer',
        unit='ms')
]

#    PART3 this parametes are used for scf modify and directly commission
#    [obsolete]
MODIFY_SCF_1200_BASE = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='-45',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='100',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='80',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='0',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold')
]

#  1200-A 116 121 Radio Link Failure
#  actGnbInitRlf=true
#  actUeInitRlf=true
MODIFY_SCF_1200_A_116_121 = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='10',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='-45',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='2000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='80',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='0',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actGnbInitRlf'),
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actUeInitRlf')
]


MODIFY_SCF_1200_NR = [
    # ulDataPath(8)
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab5Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab69Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab6Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab70Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab79Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab7Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab8Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME,
        list_name='qciTab9Nsa3x',
        p_name='ulDataPath'),
    # ulDataSplitThreshold(8)
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab5Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab69Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab6Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab70Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab79Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab7Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab8Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='infinity',
        dist_name=NR_NAME,
        list_name='qciTab9Nsa3x',
        p_name='ulDataSplitThreshold')
]

MODIFY_SCF_1200_NRLTE = [
    # ulDataPath(8)
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab5Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab69Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab6Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab70Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab79Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab7Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab8Nsa3x',
        p_name='ulDataPath'),
    dict(
        value='ulOverLteNr',
        dist_name=NR_NAME,
        list_name='qciTab9Nsa3x',
        p_name='ulDataPath'),
    # ulDataSplitThreshold(8)
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab5Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab69Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab6Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab70Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab79Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab7Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab8Nsa3x',
        p_name='ulDataSplitThreshold'),
    dict(
        value='b0',
        dist_name=NR_NAME,
        list_name='qciTab9Nsa3x',
        p_name='ulDataSplitThreshold')
]

MODIFY_SCF_GNB_ENABLE_MUL_DRB = [
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actMultiDrbNSA'),
    dict(
        value='true',
        dist_name=NR_NAME,
        list_name='qciTab9Nsa3x',
        p_name='nsa3xBearerAllowed')
]

MODIFY_SCF_1200_B_210_211 = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='-45',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='17000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='80',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='0',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold')
]

MODIFY_SCF_1200_COUNTER_SRB1 = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='-45',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='2000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='80',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='0',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrRadBearer'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrCellUtilization'),
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm')
]

MODIFY_SCF_1200_COUNTER_SRB3 = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='-45',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='2000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='80',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='0',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrRadBearer'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrCellUtilization'),
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm')
]

MODIFY_SCF_1200_NR_106 = [
    dict(
        value='50',
        dist_name=NR_CELL_NAME,
        parameter='pucchDataDtxNumOfSamples'),
    dict(
        value='50',
        dist_name=NR_CELL_NAME,
        parameter='puschDataDtxNumOfSamples'),
]

MODIFY_NIDD_VIA_API_1200_QCI_NRLTE = [
    # ulDataPath(8)
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab5Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab69Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab6Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab70Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab79Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab7Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab8Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME,
        parameter='qciTab9Nsa3x',
        ),
]

MODIFY_NIDD_VIA_API_1200_QCI_NR = [
    # ulDataPath(8)
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab5Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab69Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab6Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab70Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab79Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab7Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab8Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab9Nsa3x',
        ),
]

MODIFY_NIDD_VIA_API_1200_QCI_LTE_AND_NRLTE = [
    # set qci7 to NR   set qci9 to NRLTE
    # ulDataPath
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab7Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLteNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab9Nsa3x',
        ),
]


MODIFY_NIDD_VIA_API_1200_QCI_LTE = [
    # ulDataPath(8)
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab5Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab69Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab6Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab70Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab79Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab7Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab8Nsa3x',
        ),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME,
        parameter='qciTab9Nsa3x',
        ),
]

# 2020/2/13 Ren Biyao: it is added because it is found 14 new dist named NRDRB has introduced in 0.836.1497 bts.
MODIFY_SCF_1200_NRLTE_ON_NRDRB = [
    dict(
        value='b0',
        dist_name=NR_NAME + '/NRDRB-4',
        list_name='nsaDrbParam',
        p_name='ulDataSplitThreshold'),
    dict(
        value='ulOverLteNr_PrimaryPathOverNr',
        dist_name=NR_NAME + '/NRDRB-4',
        list_name='nsaDrbParam',
        p_name='ulDataPath'),
    dict(
        value='b0',
        dist_name=NR_NAME + '/NRDRB-5',
        list_name='nsaDrbParam',
        p_name='ulDataSplitThreshold'),
    dict(
        value='ulOverLteNr_PrimaryPathOverNr',
        dist_name=NR_NAME + '/NRDRB-5',
        list_name='nsaDrbParam',
        p_name='ulDataPath')
]

MODIFY_SCF_1200_NR_ON_NRDRB = [
    dict(
        value='infinity',
        dist_name=NR_NAME + '/NRDRB-4',
        list_name='nsaDrbParam',
        p_name='ulDataSplitThreshold'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME + '/NRDRB-4',
        list_name='nsaDrbParam',
        p_name='ulDataPath'),
    dict(
        value='infinity',
        dist_name=NR_NAME + '/NRDRB-5',
        list_name='nsaDrbParam',
        p_name='ulDataSplitThreshold'),
    dict(
        value='ulOverNr',
        dist_name=NR_NAME + '/NRDRB-5',
        list_name='nsaDrbParam',
        p_name='ulDataPath')
]

MODIFY_SCF_GNB_ENABLE_MUL_ON_NRDRB = [
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actMultiDrbNSA'),
    dict(
        value='true',
        dist_name=NR_NAME + '/NRDRB-4',
        list_name='nsaDrbParam',
        p_name='nsa3xBearerAllowed'),
    dict(
        value='true',
        dist_name=NR_NAME + '/NRDRB-5',
        list_name='nsaDrbParam',
        p_name='nsa3xBearerAllowed')
]

MODIFY_NIDD_VIA_API_1200_QCI_LTE_ON_DRB = [
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverLte', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam')
]

MODIFY_NIDD_VIA_API_1200_QCI_NRLTE_ON_DRB = [
    dict(
        value=[dict(ulDataPath='ulOverLteNr_PrimaryPathOverNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverLteNr_PrimaryPathOverNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam')
]

MODIFY_NIDD_VIA_API_1200_QCI_NR_ON_DRB = [
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam')
]


# PART 4  new nidd value to adapt on trunk/20A
MODIFY_SCF_1200_A_BASE = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='50',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='20000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='81',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='150',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='al04',
        dist_name=NR_CELL_NAME,
        p_name='alpha'),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled')
]

MODIFY_SCF_1200_B_BASE = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='50',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='20000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='159',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='150',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='al04',
        dist_name=NR_CELL_NAME,
        p_name='alpha'),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled')
]

MODIFY_SCF_1200_B_210_211_214 = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='5',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='5',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='50',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='17000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='159',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='-190',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='al04',
        dist_name=NR_CELL_NAME,
        p_name='alpha'),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled')
]

MODIFY_SCF_1200_RLF = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='10',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='82',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='50',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='20000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='81',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='150',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actGnbInitRlf'),
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actUeInitRlf'),
    dict(
        value='al04',
        dist_name=NR_CELL_NAME,
        p_name='alpha'),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled')
]

MODIFY_SCF_PM_FILE = [
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrRadBearer'),
    dict(
        value='5min',
        dist_name=NR_NAME + '/NRPMRNL-1',
        p_name='miNrCellUtilization'),
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm')
]

MODIFY_SCF_SRB3 = [
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled')
]

# PART 5  special nidd value for 20A
MODIFY_SCF_ALPHA_20A = [
    dict(
        value='al08',
        dist_name=NR_CELL_NAME,
        p_name='alpha')
]

MODIFY_SCF_ALPHA_MASTER = [
    dict(
        value='al06',
        dist_name=NR_CELL_NAME,
        p_name='alpha')
]

if program == '20A':
    MODIFY_SCF_1200_A_BASE = MODIFY_SCF_1200_A_BASE + MODIFY_SCF_ALPHA_20A
    MODIFY_SCF_1200_B_BASE = MODIFY_SCF_1200_B_BASE + MODIFY_SCF_ALPHA_20A
    MODIFY_SCF_1200_B_210_211_214 = MODIFY_SCF_1200_B_210_211_214 + MODIFY_SCF_ALPHA_20A
    MODIFY_SCF_1200_RLF = MODIFY_SCF_1200_RLF + MODIFY_SCF_ALPHA_20A
elif program == 'master' or program == '21B':
    MODIFY_SCF_1200_A_BASE = MODIFY_SCF_1200_A_BASE + MODIFY_SCF_ALPHA_MASTER
    MODIFY_SCF_1200_B_BASE = MODIFY_SCF_1200_B_BASE + MODIFY_SCF_ALPHA_MASTER
    MODIFY_SCF_1200_B_210_211_214 = MODIFY_SCF_1200_B_210_211_214 + MODIFY_SCF_ALPHA_MASTER
    MODIFY_SCF_1200_RLF = MODIFY_SCF_1200_RLF + MODIFY_SCF_ALPHA_MASTER
else:
    pass

MODIFY_SCF_1200_NRLTE = MODIFY_SCF_1200_NRLTE_ON_NRDRB
MODIFY_SCF_1200_NR = MODIFY_SCF_1200_NR_ON_NRDRB
MODIFY_SCF_GNB_ENABLE_MUL_DRB = MODIFY_SCF_GNB_ENABLE_MUL_ON_NRDRB
MODIFY_NIDD_VIA_API_1200_QCI_LTE = MODIFY_NIDD_VIA_API_1200_QCI_LTE_ON_DRB
MODIFY_NIDD_VIA_API_1200_QCI_NRLTE = MODIFY_NIDD_VIA_API_1200_QCI_NRLTE_ON_DRB
MODIFY_NIDD_VIA_API_1200_QCI_NR = MODIFY_NIDD_VIA_API_1200_QCI_NR_ON_DRB

MODIFY_SCF_1200_COUNTER_SRB1 = MODIFY_SCF_1200_B_BASE + MODIFY_SCF_PM_FILE

MODIFY_SCF_1200_COUNTER_SRB3 = MODIFY_SCF_1200_B_BASE + MODIFY_SCF_PM_FILE + MODIFY_SCF_SRB3

MODIFY_SCF_DTX_SAMPLE = [
    dict(
        value='10',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='10',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples')
]


MODIFY_SCF_1200_A_B_E_BASE_SUB = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        p_name='actDynUlDataSplitMode'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        p_name='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        p_name='rloConsecDtxThreshold'),
    dict(
        value='160',
        dist_name=NR_CELL_NAME,
        p_name='rloPathLossThreshold'),
    dict(
        value='-200',
        dist_name=NR_CELL_NAME,
        p_name='rloSinrThreshold'),
    dict(
        value='20000',
        dist_name=DIST_RLRESUMEBACKOFFTMR,
        p_name='rlResumeBackOffTmr'),
    dict(
        value='80',
        dist_name=NR_CELL_NAME,
        p_name='rlResumePathLossThreshold'),
    dict(
        value='300',
        dist_name=NR_CELL_NAME,
        p_name='rlResumeSinrThreshold'),
    dict(
        value='false',
        dist_name=NR_NAME,
        p_name='srb3SupportEnabled')
]

MODIFY_SCF_1200_ALPHA_20B = [
    dict(
        value='al04',
        dist_name=NR_CELL_NAME,
        p_name='alpha')
]

MODIFY_SCF_1200_ALPHA_NOT_20B = [
    dict(
        value='al06',
        dist_name=NR_CELL_NAME,
        p_name='alpha')
]

if program == '20B':
    MODIFY_SCF_1200_A_B_E_BASE = MODIFY_SCF_1200_A_B_E_BASE_SUB + MODIFY_SCF_1200_ALPHA_20B
else:
    MODIFY_SCF_1200_A_B_E_BASE = MODIFY_SCF_1200_A_B_E_BASE_SUB + MODIFY_SCF_1200_ALPHA_NOT_20B

MODIFY_SCF_1200_NR_API_DEFAULT = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
    dict(
        value='false',
        dist_name=NR_NAME,
        parameter='srb3SupportEnabled'),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam'),
]

MODIFY_SCF_1200_NRLTE_API_DEFAULT = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
    dict(
        value='false',
        dist_name=NR_NAME,
        parameter='srb3SupportEnabled'),
    dict(
        value=[dict(ulDataPath='ulOverLteNr_PrimaryPathOverNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverLteNr_PrimaryPathOverNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam'),
]

MODIFY_SCF_1200_NR_SRB3_API_DEFAULT = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
    dict(
        value='true',
        dist_name=NR_NAME,
        parameter='srb3SupportEnabled'),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverNr', ulDataSplitThreshold='infinity')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam'),
]

MODIFY_SCF_1200_NRLTE_SRB3_API_DEFAULT = [
    dict(
        value='true',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
    dict(
        value='true',
        dist_name=NR_NAME,
        parameter='srb3SupportEnabled'),
    dict(
        value=[dict(ulDataPath='ulOverLteNr_PrimaryPathOverNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='nsaDrbParam'),
    dict(
        value=[dict(ulDataPath='ulOverLteNr_PrimaryPathOverNr', ulDataSplitThreshold='b0')],
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='nsaDrbParam'),
]

MODIFY_SCF_TRIGGER_RLO_RLM_API = [
    dict(
        value='81',
        dist_name=NR_CELL_NAME,
        parameter='rloPathLossThreshold'),
    dict(
        value='299',
        dist_name=NR_CELL_NAME,
        parameter='rloSinrThreshold'),
    dict(
        value='159',
        dist_name=NR_CELL_NAME,
        parameter='rlResumePathLossThreshold'),
    dict(
        value='-199',
        dist_name=NR_CELL_NAME,
        parameter='rlResumeSinrThreshold'),
]

MODIFY_NIDD_VIA_API_RESTORE_402 = [
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        parameter='pucchDataDtxNumOfSamples'),
    dict(
        value='30',
        dist_name=NR_CELL_NAME,
        parameter='puschDataDtxNumOfSamples'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        parameter='rloDtxRatioThreshold'),
    dict(
        value='1',
        dist_name=NR_CELL_NAME,
        parameter='rloConsecDtxThreshold'),
    dict(
        value='160',
        dist_name=NR_CELL_NAME,
        parameter='rloPathLossThreshold'),
    dict(
        value='-200',
        dist_name=NR_CELL_NAME,
        parameter='rloSinrThreshold'),
    dict(
        value='300',
        dist_name=NR_CELL_NAME,
        parameter='rlResumeSinrThreshold'),
]

MODIFY_NIDD_VIA_RESTAPI_1200_A_401 = [
    dict(
        value='false',
        dist_name=NR_CELL_NAME,
        parameter='actDynUlDataSplitMode'),
]

if program == '20A' or '19B':
    MODIFY_SCF_1200_COUNTER_SRB1 = MODIFY_SCF_1200_COUNTER_SRB1 + MODIFY_SCF_DTX_SAMPLE
    MODIFY_SCF_1200_COUNTER_SRB3 = MODIFY_SCF_1200_COUNTER_SRB3 + MODIFY_SCF_DTX_SAMPLE
