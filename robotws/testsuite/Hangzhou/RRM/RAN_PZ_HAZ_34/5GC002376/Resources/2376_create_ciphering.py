from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)


def create_ciphering_data(nea0_value, nea1_value, nea2_value, nea3_value):
    ciphering_value = {MR_NR_BTS_NAME: {'cipherPrefL': [{'nea0': nea0_value,
                                                         'nea1_128': nea1_value,
                                                         'nea2_128': nea2_value,
                                                         'nea3_128': nea3_value}]}}
    return ciphering_value
