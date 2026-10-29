*** Settings ***
Documentation
...   author: Marcin Wolczynski
...   contact: marcin.wolczynski@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB013152



*** Keywords ***

Load Expected Cplane Config
    ${json}=     Get File    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/expected_pucch_config.json
    ${expected}=    Evaluate    json.loads('''${json}''')    modules=json

    RETURN    ${expected}


Load Expected Cplane Config for BWP
    ${json}=     Get File    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/expected_pucch_config_bwp.json
    ${expected}=    Evaluate    json.loads('''${json}''')    modules=json

    RETURN    ${expected}
