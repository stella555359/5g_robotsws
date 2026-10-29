initial_asir_params = [{
                'para_abbr': 'enableDefaultPasswdAlarm',
                'para_mo': 'ASI-1',
                'value': 'false'},
            {
                'para_abbr': 'actNe3sOperationLogging',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'false'},
            {
                'para_abbr': 'administrativeState',
                'para_mo': 'ASI-1/HUBMOD-1/LMTPORT-1',
                'value': 'unlocked'},
            {
                'para_abbr': 'appLoginBannerText',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'Text initial'},
            {
                'para_abbr': 'minNonAlphaNumInPassword',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': '5'},
            {
                'para_abbr': 'asiName',
                'para_mo': 'ASI-1',
                'value': 'Name initial'},
            {
                'para_abbr': 'pRrhPowerOffDelay',
                'para_mo': 'ASI-1/HUBMOD-1',
                'value': '300'}]


tc14_params_allowed_sys_adm = [{
                'para_abbr': 'enableDefaultPasswdAlarm',
                'para_mo': 'ASI-1',
                'value': 'true'},
            {
                'para_abbr': 'actNe3sOperationLogging',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'true'},
            {
                'para_abbr': 'administrativeState',
                'para_mo': 'ASI-1/HUBMOD-1/LMTPORT-1',
                'value': 'locked'},
            {
                'para_abbr': 'appLoginBannerText',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'Text set by System Admin'},
            {
                'para_abbr': 'minNonAlphaNumInPassword',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': '1'},
            {
                'para_abbr': 'asiName',
                'para_mo': 'ASI-1',
                'value': 'Name set by System Admin'},
            {
                'para_abbr': 'pRrhPowerOffDelay',
                'para_mo': 'ASI-1/HUBMOD-1',
                'value': '301'}]

tc14_params_allowed_sec_adm = [{
                'para_abbr': 'enableDefaultPasswdAlarm',
                'para_mo': 'ASI-1',
                'value': 'false'},
            {
                'para_abbr': 'actNe3sOperationLogging',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'false'},
            {
                'para_abbr': 'administrativeState',
                'para_mo': 'ASI-1/HUBMOD-1/LMTPORT-1',
                'value': 'unlocked'},
            {
                'para_abbr': 'appLoginBannerText',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'Text set by Security Admin'},
            {
                'para_abbr': 'minNonAlphaNumInPassword',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': '2'}]

tc14_params_forbidden_sec_adm = [
            {
                'para_abbr': 'asiName',
                'para_mo': 'ASI-1',
                'value': 'Name set by SECURITY Admin'},
            {
                'para_abbr': 'pRrhPowerOffDelay',
                'para_mo': 'ASI-1/HUBMOD-1',
                'value': '302'}]

tc14_params_allowed_app_adm = [
            {
                'para_abbr': 'asiName',
                'para_mo': 'ASI-1',
                'value': 'Name set by APPLICATION Admin'},
            {
                'para_abbr': 'pRrhPowerOffDelay',
                'para_mo': 'ASI-1/HUBMOD-1',
                'value': '303'}]

tc14_params_forbidden_app_adm = [{
                'para_abbr': 'enableDefaultPasswdAlarm',
                'para_mo': 'ASI-1',
                'value': 'true'},
            {
                'para_abbr': 'actNe3sOperationLogging',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'true'},
            {
                'para_abbr': 'administrativeState',
                'para_mo': 'ASI-1/HUBMOD-1/LMTPORT-1',
                'value': 'locked'},
            {
                'para_abbr': 'appLoginBannerText',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'Text set by APPLICATION Admin'},
            {
                'para_abbr': 'minNonAlphaNumInPassword',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': '3'}]

tc14_params_forbidden_read_only = [{
                'para_abbr': 'enableDefaultPasswdAlarm',
                'para_mo': 'ASI-1',
                'value': 'true'},
            {
                'para_abbr': 'actNe3sOperationLogging',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'true'},
            {
                'para_abbr': 'administrativeState',
                'para_mo': 'ASI-1/HUBMOD-1/LMTPORT-1',
                'value': 'locked'},
            {
                'para_abbr': 'appLoginBannerText',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': 'Text set by Read-Only User'},
            {
                'para_abbr': 'minNonAlphaNumInPassword',
                'para_mo': 'ASI-1/SECPRM-1',
                'value': '4'},
            {
                'para_abbr': 'asiName',
                'para_mo': 'ASI-1',
                'value': 'Name set by Read-only user'},
            {
                'para_abbr': 'pRrhPowerOffDelay',
                'para_mo': 'ASI-1/HUBMOD-1',
                'value': '304'}]
