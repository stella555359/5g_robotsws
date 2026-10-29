from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

PARAMS_TO_DELETE_TC622 = [
    # NRCELL
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-6'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-7'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELL-8'),
    # cellmapping
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-7'),
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-8'),
    # nrcell group
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
    dict(dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0', list_name='nrCellList', index='-1'),
]

PARAMS_TO_MODIFY_TC622 = [
    dict(value='blind', dist_name=MR_NR_BTS_NAME, p_name='sCellActivationMethod'),
    dict(value='4', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsDl'),
    dict(value='0', dist_name=MR_NR_BTS_NAME, p_name='maxNumScellsUl'),
]
