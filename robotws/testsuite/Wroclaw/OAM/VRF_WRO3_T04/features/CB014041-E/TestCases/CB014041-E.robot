*** Settings ***
Documentation   The test case for CB014041 feature.

Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../../../common_resources/alarms/alarm.robot

Library         taf.sbts.oam.coam.admin  WITH NAME    coam_admin

*** Keywords ***
CB014041_Check_If_ActCertValidation_Parameter_Is_Frozen
    ${value_rsa}=     Check current parameter value     dist_name=MRBTS-${mrbts}/MNL-1/CERTH-1/CMP-1
    ...                                                 param_name=actCertValidation
    Should Contain    ${value_rsa}    true
    ${value_ecdsa}=   Check current parameter value     dist_name=MRBTS-${mrbts}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                                            param_name=actCertValidation
    Should Contain    ${value_ecdsa}  true
    No Faults Except Allowed Should Be Present On BTS
    Run Keyword And Expect Error        *               Change Parameter on BTS
    ...                                                 dist_name=MRBTS-${mrbts}/MNL-1/CERTH-1/CMP-1
    ...                                                 param_name=actCertValidation
    ...                                                 param_value=false
    Run Keyword And Expect Error        *               Change Parameter on BTS
    ...                                                 dist_name=MRBTS-${mrbts}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                                 param_name=actCertValidation
    ...                                                 param_value=false
    ${value_rsa}=      Check current parameter value    dist_name=MRBTS-${mrbts}/MNL-1/CERTH-1/CMP-1
    ...                                                 param_name=actCertValidation
    Should Contain     ${value_rsa}    true
    ${value_ecdsa}=    Check current parameter value    dist_name=MRBTS-${mrbts}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                                 param_name=actCertValidation
    Should Contain     ${value_ecdsa}  true
    No Faults Except Allowed Should Be Present On BTS
