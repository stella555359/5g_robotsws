from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

TL_PARAMS_TO_ADD_5GC000955 = [
    dict(class_name='com.nokia.srbts.eqm:SFP', dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1',
         version='TNL5GC21A_2012_002'),
    dict(dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1', version='TNL5GC21A_2012_002',
         p_name='hwPortId', value='S_RF1'),
    dict(class_name='com.nokia.srbts.eqm:LANE',
         dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1', version='TNL5GC21A_2012_002'),
    dict(dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1', p_name='administrativeState',
         value='Unlocked')
]
