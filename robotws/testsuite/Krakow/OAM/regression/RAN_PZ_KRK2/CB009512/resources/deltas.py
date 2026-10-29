from robot.libraries.BuiltIn import BuiltIn

bts_id = BuiltIn().get_variable_value("${bts_id}")

tls_1_3 = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actEnableTLSv13',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'tls12Enabled',
            'value': 'false'},
    ]}]


tls_1_2 = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actEnableTLSv13',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'tls12Enabled',
            'value': 'true'},
    ]}]

tls_1_1 = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'tls11Enabled',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'tls11EnabledStatus',
            'value': 'true'},
    ]}]

cmp = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/CERTH-1/CMP-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'caSubjectName',
            'value': 'DC=div_krk, DC=net, CN=EMSSIM_SG2'},
        {
            'operation': 'update',
            'parameterName': 'serverHost',
            'value': '10.83.180.65'},
        {
            'operation': 'update',
            'parameterName': 'serverPath',
            'value': 'pkix'},
        {
            'operation': 'update',
            'parameterName': 'serverPort',
            'value': '8080'},
    ]}]


oamtls_on = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'oamTls',
            'value': 'forced'},
    ]}]

oamtls_off = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'oamTls',
            'value': 'off'},
    ]}]

tls_1_2_cipher_off = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'tls12CbcCipherDisabled',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'tls12RsaKExDisabled',
            'value': 'true'},
    ]}]

tls_1_2_cipher_on = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'tls12CbcCipherDisabled',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'tls12RsaKExDisabled',
            'value': 'false'},
    ]}]

tls_1_2_cbc_off = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'tls12CbcCipherDisabled',
            'value': 'true'},
    ]}]

tls_1_2_rsa_off = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/MPLANENW-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'tls12RsaKExDisabled',
            'value': 'true'},
    ]}]

actlogincredpartitionsync_true = [{
    'distName': f'MRBTS-{bts_id}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actLoginCredPartitionSync',
            'value': 'true'},
    ]}]

enabledefaultpasswdalarm_false = [{
    'distName': 'ASI-1',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'enableDefaultPasswdAlarm',
            'value': 'false'},
    ]}]
