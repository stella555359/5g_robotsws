secprm_delta = [
    {
        'distName': 'ASI-1/SECPRM-1',
        'parameters': [
            {'parameterName': 'actParallelUserSessions', 'value': 'true', 'operation': 'create'},
            {'parameterName': 'appLoginBannerText', 'value': '1', 'operation': 'create'},
            {'parameterName': 'emAccessPriorityLogoutTimer', 'value': '10', 'operation': 'create'},
            {'parameterName': 'maxParallelUserSessions', 'value': '1', 'operation': 'create'},
            {'parameterName': 'minNonAlphaNumInPassword', 'value': '1', 'operation': 'create'},
            {'parameterName': 'minPasswordLength', 'value': '8', 'operation': 'create'},
            {'parameterName': 'webEMSessionLoginDelay', 'value': '1', 'operation': 'create'},
            {'parameterName': 'webEMSessionLogoutTimer', 'value': '600', 'operation': 'create'},
            {'parameterName': 'actEMAccessPriority', 'value': 'true', 'operation': 'update'},
            {'parameterName': 'localPasswdExpiryPeriod', 'value': '29', 'operation': 'update'},
            {'parameterName': 'localPasswdWarningPeriod', 'value': '1', 'operation': 'update'},
            {'parameterName': 'userEventTempBufOverwriting', 'value': 'false', 'operation': 'update'},
            {'parameterName': 'userEventTempBufThreshold', 'value': '50', 'operation': 'update'},
            {'parameterName': 'passwdHistoryLength', 'value': '1', 'operation': 'update'},
        ]
    },
    {
        'distName': 'ASI-1',
        'parameters': [
            {'parameterName': 'enableDefaultPasswdAlarm', 'value': 'false', 'operation': 'create'},
        ]
    },
]

passwdHistoryLength_delta = [
    {
        'distName': 'ASI-1/SECPRM-1',
        'parameters': [
            {'parameterName': 'passwdHistoryLength', 'value': '0', 'operation': 'update'},
        ]
    },
]
