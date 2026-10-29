from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)


MODIFY_CU = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRDRB-2',
        p_name='nsa3xBearerAllowed'),
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        p_name='actMultiDrbNSA')
]

MODIFY_DU = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id),
        p_name='actMultiDrbNSA')
]

MODIFY_ENB = [
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id),
        parameter='actMultBearers'),
    dict(
        value='true',
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id),
        parameter='actMultiSCGSplit')
]
