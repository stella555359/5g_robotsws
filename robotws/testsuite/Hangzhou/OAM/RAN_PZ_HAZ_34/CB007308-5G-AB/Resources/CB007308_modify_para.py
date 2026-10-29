from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


GNB_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME1 = GNB_BTS_NAME1 + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_NRCELL_NAME0 = GNB_NR_BTS_NAME1 + '/NRCELL-0'
GNB_NRCELL_NAME1 = GNB_NR_BTS_NAME1 + '/NRCELL-1'
GNB_NRCELLGRP_NAME0 = GNB_NR_BTS_NAME1 + '/NRCELLGRP-0'
GNB_NRCELLGRP_NAME1 = GNB_NR_BTS_NAME1 + '/NRCELLGRP-1'
GNB_LCELNR_NAME1 = GNB_BTS_NAME1 + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'
GNB_LCELNR_NAME2 = GNB_BTS_NAME1 + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'
GNB_NRDU_NAME1 = GNB_NR_BTS_NAME1 + '/NRDU-1'

gnb_add_object = [dict(source_dist_name=GNB_NRCELL_NAME0, target_dist_name=GNB_NRCELL_NAME1),
                  dict(source_dist_name=GNB_NRCELLGRP_NAME0, target_dist_name=GNB_NRCELLGRP_NAME1),
                  dict(source_dist_name=GNB_LCELNR_NAME1, target_dist_name=GNB_LCELNR_NAME2)]

gnb_add_element_to_list = [dict(dist_name=GNB_NRDU_NAME1, list_name='refNrCellGroup', elements=['1'])]


gnb_modify_para = [dict(dist_name=GNB_NRCELL_NAME1, p_name='physCellId', value='480', list_name=None),
                   dict(dist_name=GNB_NRCELL_NAME1, p_name='lcrId', value='2', list_name=None),
                   dict(dist_name=GNB_NRCELL_NAME1, p_name='nrarfcn', value='645000', list_name=None),
                   dict(dist_name=GNB_NRCELLGRP_NAME1, p_name=None, value='1', list_name='nrCellList')]
