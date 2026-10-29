from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MODIFY_ENB_ADMINISTRATIVESTATE_LOCK_VIA_API = [
    dict(
        value='locked',
        dist_name='LNBTS-' + str(tl.gnbs[0].instance_id) + '/LNADJGNB-1',
        parameter='administrativeState')
]

MODIFY_ENB_ADMINISTRATIVESTATE_UNLOCK_VIA_API = [
    dict(
        value='unlocked',
        dist_name='LNBTS-' + str(tl.gnbs[0].instance_id) + '/LNADJGNB-1',
        parameter='administrativeState')
]

MODIFY_ENB_ACTSECRATREP_TRUE_API = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.gnbs[0].instance_id),
        parameter='actSecRatRep')
]

MODIFY_ENB_ACTSECRATREP_API = [
    dict(
        value='false',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.gnbs[0].instance_id),
        parameter='actSecRatRep')
]

MODIFY_ENB_ACTEVTSECRATREP_API = [
    dict(
        value='false',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.gnbs[0].instance_id),
        parameter='actEvtSecRatRep')
]

MODIFY_ENB_ACTEVTSECRATREPTRUE_API = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.gnbs[0].instance_id),
        parameter='actEvtSecRatRep')
]

MODIFY_GNB_DU_ACTGNBINITRLF_API = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id),
        parameter='actGnbInitRlf')
]


MODIFY_GNB_CU_API = [
    dict(
        value='10',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id),
        p_name='periodicalDataUsageReportTimer'),
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id),
        p_name='actSecDataUsageRep'
    ),
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id),
        p_name='actUeInitRlf'
    ),
    dict(
        value='500',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id),
        p_name='tWaitingRlRecover')
]
