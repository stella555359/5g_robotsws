from robot.libraries.BuiltIn import BuiltIn
PCELL_ID_1 = BuiltIn().get_variable_value('${PCELL_ID_1}')
PCELL_ID_2 = BuiltIn().get_variable_value('${PCELL_ID_2}')
tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

if program != '21A':
    sCellDeactivationBadRlqCount_Pname = 'sCellDeactivationBadRlqCount'
else:
    sCellDeactivationBadRlqCount_Pname = 'sCellReleaseNumRLQReport'

sCellDeactivationBadRlqCount = '1'
sCellDeactivationBadRlqCount_more = '80'
sCellChannelEstimationPeriod = '2000'

add_sCellAct_bufferbased_PCELL_1 = [] if PCELL_ID_1 < 0 else [
    dict(
        value='ms1280',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_1),
        parameter='sCellDeactivationTimerGNB'),
]

add_sCellAct_Bufferbased_PCELL_2 = [] if PCELL_ID_2 < 0 else [
    dict(
        value='ms1280',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_2),
        parameter='sCellDeactivationTimerGNB')
]

add_sCellActivationMethod_bufferbased = [
    dict(
        value='bufferBased',
        dist_name=MR_NR_BTS_NAME,
        parameter='sCellActivationMethod'),
    dict(
        value='ms1280',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        parameter='sCellDeactivationTimerGNB'),
    dict(
        value='ms1280',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        parameter='sCellDeactivationTimerGNB'),
] + add_sCellAct_bufferbased_PCELL_1 + add_sCellAct_Bufferbased_PCELL_2


add_sCellAct_qualitybased_PSCELL_1 = [] if PCELL_ID_1 < 0 else [
    dict(
        value='16',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_1),
        parameter='sCellGoodChannelQualityThreshold'),
    dict(
        value='15',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_1),
        parameter='sCellBadChannelQualityThreshold'),
    dict(
        value=sCellChannelEstimationPeriod,
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_1),
        parameter='sCellChannelEstimationPeriod')
]

add_sCellAct_qualitybased_PSCELL_2 = [] if PCELL_ID_2 < 0 else [
    dict(
        value='16',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_2),
        parameter='sCellGoodChannelQualityThreshold'),
    dict(
        value='15',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_2),
        parameter='sCellBadChannelQualityThreshold'),
    dict(
        value=sCellChannelEstimationPeriod,
        dist_name=MR_NR_BTS_NAME + '/NRCELL-' + str(PCELL_ID_2),
        parameter='sCellChannelEstimationPeriod')
]

add_sCellActivationMethod_qualitybased = [
    dict(
        value='bufferAndRLQualityBased',
        dist_name=MR_NR_BTS_NAME,
        parameter='sCellActivationMethod'),
    dict(
        value='16',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        parameter='sCellGoodChannelQualityThreshold'),
    dict(
        value='16',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        parameter='sCellGoodChannelQualityThreshold'),
    dict(
        value='15',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        parameter='sCellBadChannelQualityThreshold'),
    dict(
        value='15',
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        parameter='sCellBadChannelQualityThreshold'),
    dict(
        value=sCellChannelEstimationPeriod,
        dist_name=MR_NR_BTS_NAME + '/NRCELL-1',
        parameter='sCellChannelEstimationPeriod'),
    dict(
        value=sCellChannelEstimationPeriod,
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        parameter='sCellChannelEstimationPeriod'),
] + add_sCellAct_qualitybased_PSCELL_1 + add_sCellAct_qualitybased_PSCELL_2

SCF_DISABLE_CIPHER = [
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='cipherPrefL',
        value=[dict(nea0='9')]),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='cipherPrefL',
        value=[dict(nea1_128='0')]),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='cipherPrefL',
        value=[dict(nea2_128='0')]),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='cipherPrefL',
        value=[dict(nea3_128='0')])
]

sCellDeactivationBadRlqCount_1 = [
    dict(
        value=sCellDeactivationBadRlqCount,
        dist_name=MR_NR_BTS_NAME,
        parameter=sCellDeactivationBadRlqCount_Pname)
]

sCellDeactivationBadRlqCount_5 = [
    dict(
        value=sCellDeactivationBadRlqCount_more,
        dist_name=MR_NR_BTS_NAME,
        parameter=sCellDeactivationBadRlqCount_Pname)
]

deactive_always = add_sCellActivationMethod_qualitybased + sCellDeactivationBadRlqCount_1

deactive_always_not = add_sCellActivationMethod_qualitybased + sCellDeactivationBadRlqCount_5
