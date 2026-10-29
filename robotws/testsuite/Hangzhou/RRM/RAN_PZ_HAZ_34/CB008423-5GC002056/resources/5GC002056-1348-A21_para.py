# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NECELL1_DistName_GNB = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_BTS_NECELL2_DistName_GNB = MR_NR_BTS_NAME + '/NRCELL-2'
MR_NR_BTS1_NRCELL = 'MRBTS-' + str(tl.gnbs[1].instance_id) + '/NRBTS-' + str(tl.gnbs[1].global_bts_id) + '/NRCELL-1'

# GNB_MODIFY_Parameter_noPrachMultiplexing = [
#      dict(dist_name=MR_NR_BTS_NAME, parameter='actFdmScheduling', value='true'),
#      dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='actPrachMultiplexing', value='false'),
#      dict(dist_name=MR_NR_BTS_NECELL2_DistName_GNB, parameter='actPrachMultiplexing', value='false'),
#      dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='prachConfigurationIndex', value='89'),
#      dict(dist_name=MR_NR_BTS_NECELL2_DistName_GNB, parameter='prachConfigurationIndex', value='89'),
#      dict(dist_name=MR_NR_BTS_NAME, parameter='pfaTargetPRACH', value='0.0001'),
#      dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='msg1FrequencyStart', value='0'),
#      dict(dist_name=MR_NR_BTS_NECELL2_DistName_GNB, parameter='msg1FrequencyStart', value='0'),
#      dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='pucchModeSelect', value='shortPucch'),
#      dict(dist_name=MR_NR_BTS_NECELL2_DistName_GNB, parameter='pucchModeSelect', value='shortPucch')]

GNB_MODIFY_Parameter_noPrachMultiplexing = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='actPrachMultiplexing', value='false'),
     dict(dist_name=MR_NR_BTS_NECELL2_DistName_GNB, parameter='actPrachMultiplexing', value='false')]

GNB_MODIFY_Parameter_PrachMultiplexing = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='actPrachMultiplexing', value='true'),
     dict(dist_name=MR_NR_BTS_NECELL2_DistName_GNB, parameter='actPrachMultiplexing', value='true')]
