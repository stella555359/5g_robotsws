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


MODIFY_GNB_CU_COUNTER = [
    dict(
        value='5min',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1',
        p_name='miNrX2CB'),
    dict(
        value='5min',
        dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1',
        p_name='miNrX2CC'),
    dict(
        value='5min',
        dist_name=MR_NR_BTS_NAME + '/NRPMRNL-1',
        p_name='miNrX2UInterface')
]
