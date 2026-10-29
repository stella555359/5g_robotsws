*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in aashell.robot.


Resource   ../aashell.robot
Library    Collections

*** Test Cases ***

test_aashell_resource_usage
    [TAGS]              AASHELL
    aashell.Setup Aashell Session  node_id=0
    ${resource_usage_1}  aashell.Get Resource Usage From Node  node_id=0
    ${resource_usage_2}  Collections.Copy Dictionary  ${resource_usage_1}  deepcopy=${True}
    aashell.Compare Resource Usage   ${resource_usage_1}  ${resource_usage_2}
    aashell.Store Resource Usage Output  resourcefile_1.json  ${resource_usage_1}
    aashell.Store Deepdiff Result  ${resource_usage_1}  ${resource_usage_2}
    Collections.Set To Dictionary  ${resource_usage_2}  maxNumOfBearerGroups  5
    Run Keyword And Expect Error  *should be true.  aashell.Compare Resource Usage
    ...   ${resource_usage_1}  ${resource_usage_2}  ignore=${False}
    aashell.Store Deepdiff Result  ${resource_usage_1}  ${resource_usage_2}
    aashell.Teardown Aashell Session  node_id=0

test_rad_parameter_change_domain_88
    [TAGS]              AASHELL
    ${org_rad_value}   aashell.Get Rad Value Using Aashell   rad_param=0x580116
    aashell.Set Rad Parameter Using Aashell                  rad_param=0x580116
    ...   rad_param_value=0xF0F0F0F0
    ${rad_value}       aashell.Get Rad Value Using Aashell   rad_param=0x580116
    Should Be Equal   ${rad_value}[0]   0xF0F0F0F0
    [Teardown]   aashell.Set Rad Parameter Using Aashell     rad_param=0x580116
    ...   rad_param_value=${org_rad_value}[0]

test_rad_parameter_change_domain_152
    [TAGS]              AASHELL
    # 0x890001=1  CP-NB log level (default = 2, 0 = trace, 1 = debug, 2 = info, 3 = warning, 4 = error, 5 = vip, 6 = disable)

    ${org_rad_value}   aashell.Get Rad Value Using Aashell   rad_param=0x980001
    aashell.Set Rad Parameter Using Aashell                  rad_param=0x980001
    ...   rad_param_value=0x1
    ${rad_value}    aashell.Get Rad Value Using Aashell      rad_param=0x980001
    Should Be Equal   ${rad_value}[0]   0x1
    aashell.Set Rad Parameter Using Aashell                  rad_param=0x980001
    ...   rad_param_value=0x2
    ${rad_value}    aashell.Get Rad Value Using Aashell      rad_param=0x980001
    Should Be Equal   ${rad_value}[0]   0x2
    [Teardown]   aashell.Set Rad Parameter Using Aashell     rad_param=0x980001
    ...   rad_param_value=${org_rad_value}[0]
