from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value("${bts_id}")


delta_mcc_404 = [{
    'distName': f"ASI-{bts_id}/BTS-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "mcc",
        'value': "404"},
        {
            'operation': "update",
            'parameterName': "mnc",
            'value': "10"}
    ]}]

param_dic = {
    'com.nokia.srbts.nrbts:NRBTS':
        {
            'mcc': "1"
        }
}

itsar_params = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "passwdHistoryLength",
        'value': "3"},
        {
            'operation': "update",
            'parameterName': "allowASiLocalUserDefaultPassword",
            'value': "false"},
        {
            'operation': "update",
            'parameterName': "localPasswdExpiryPeriod",
            'value': "30"},
        {
            'operation': "update",
            'parameterName': "webEMSessionLoginDelay",
            'value': "5"}]}]

passwdHistoryLength_itsar = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "passwdHistoryLength",
        'value': "3"}]}]

wrong_itsar_params = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "passwdHistoryLength",
        'value': "2"},
        {
            'operation': "update",
            'parameterName': "allowASiLocalUserDefaultPassword",
            'value': "true"},
        {
            'operation': "update",
            'parameterName': "localPasswdExpiryPeriod",
            'value': "0"},
        {
            'operation': "update",
            'parameterName': "webEMSessionLoginDelay",
            'value': "3"}]}]

webEMSessionLogoutTimer_create = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "create",
        'parameterName': "webEMSessionLogoutTimer",
        'value': "120"}]}]

webEMSessionLogoutTimer_update = [{
    'distName': f"ASI-{bts_id}/SECPRM-1",
    'parameters': [{
        'operation': "update",
        'parameterName': "webEMSessionLogoutTimer",
        'value': "180"}]}]
