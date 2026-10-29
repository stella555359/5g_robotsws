from robot.libraries.BuiltIn import BuiltIn
import logging

tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')

MR_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'

TPUT_RATIO_2DRB = ['8', '4']

TPUT_RATIO_4DRB_before_attach = ['8', '4', '8', '1']

TPUT_RATIO_4DRB_after_attach = ['5', '10', '5', '20']

ONLINE_MODIFY_schedulWeight_DEFAULT = [
    dict(
        value='4',
        dist_name=NR_NAME + '/NRDRB-1',
        parameter='schedulWeight'
    ),
    dict(
        value='8',
        dist_name=NR_NAME + '/NRDRB-2',
        parameter='schedulWeight'
    ),
    dict(
        value='1',
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='schedulWeight'
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB_QCI-1',
        parameter='qciValueList',
        value=['6', '8']
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB_QCI-3',
        parameter='qciValueList',
        value=['79']
    )
]

ONLINE_MODIFY_schedulWeight_A02 = [
    dict(
        dist_name=NR_NAME + '/NRDRB-2',
        parameter='schedulWeight',
        value='5'
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB-5',
        parameter='schedulWeight',
        value='20'
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB-4',
        parameter='schedulWeight',
        value='10'
     )

]

ONLINE_DELETE_QCI_PROFILE_3 = [
    dict(dist_name=NR_NAME + '/NRDRB_QCI-3')
]

QCI_PROFILE_7 = [
    dict(
        dist_name=NR_NAME + '/NRDRB_QCI-7',
        parameter='nrDrbDN',
        value=MR_NAME + '/' + NR_NAME + '/NRDRB-4'
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB_QCI-7',
        parameter='nrDrbQciId',
        value='7'
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB_QCI-7',
        parameter='qciValueList',
        value=['7']
    ),
    dict(
        dist_name=NR_NAME + '/NRDRB_QCI-7',
        parameter='nrPlmnDN',
        value=MR_NAME + '/' + NR_NAME + '/NRPLMN-1'
    )
]
