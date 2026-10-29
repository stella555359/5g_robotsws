# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id)

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME1,
                                       parameter='nsaInactivityTimer', value='150')]

keywords_list1 = ['NRCELL_A-1']
