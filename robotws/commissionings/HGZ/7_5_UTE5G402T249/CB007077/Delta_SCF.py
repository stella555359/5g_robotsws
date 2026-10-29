from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRPLMN1 = MR_NR_BTS_NAME + '/NRPLMN-1'
NRPLMN2 = MR_NR_BTS_NAME + '/NRPLMN-2'

TL_PARAMS_TO_MODIFY_SA = [
    dict(dist_name=MR_NR_BTS_NAME, p_name='gNbCuType', value='SA+NSA'),
    dict(dist_name=MR_NR_BTS_NAME + '/SERVEDAMF-1', p_name='amfIPAddress',
         value='10.110.133.68'),
    dict(dist_name=NRPLMN1, p_name='mnc', value='03'),
    dict(dist_name=NRPLMN1, p_name='mcc', value='262'),
    dict(dist_name=NRPLMN1, p_name='mncLength', value='2'),
    dict(dist_name=MR_NR_BTS_NAME + '/SERVEDAMF-2', p_name='amfIPAddress',
         value='10.107.180.5'),
    dict(dist_name=NRPLMN2, p_name='mnc', value='02'),
    dict(dist_name=NRPLMN2, p_name='mcc', value='460'),
    dict(dist_name=NRPLMN2, p_name='mncLength', value='2')]
