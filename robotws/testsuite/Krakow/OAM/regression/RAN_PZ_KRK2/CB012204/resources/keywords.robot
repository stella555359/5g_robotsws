*** Settings ***
Documentation
...    Author: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com
...    Maintainer: Arkadiusz Gurgul, arkadiusz.gurgul@nokia.com

Library     taf.rfrl.bts.devices.asir.asir_operations.GnbAsirHubOperations    WITH NAME    AsirOp
Library     taf.nms.netact    WITH NAME    netact
Library     testsuite.Krakow.resources.RAN_PZ_KRK2.FR_CB009493_CB009055_CB009487.AsirSelenium    WITH NAME
...         AsirWebEM

Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   netacts.py

*** Variables ***
${NETACT}=                   srnclab2010
${WEB_URL}=                  https://${NETACT_NAME}/authentication/Login
${NETACT_NAME}=              ${netacts['${NETACT}']['URL']}
${GNB_ID}=                   ${tl.gnbs[0].global_bts_id}
${MO_MRBTS_ID}=              PLMN-PLMN/MRBTS-${GNB_ID}
${MO_ASI_ID}=                PLMN-PLMN/ASI-${GNB_ID}
${USERNAME}=                 omc
${PASSWORD}=                 Medsql!_1893
${NODE_IP}=                  ${netacts['${NETACT}']['IP']}
${MO_MRBTS_ADDR}=            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${RELEASE}=                  SBTS26R1
${SECURITY_MODE}=            no TLS
${VIRTUAL_DISPLAY}=          ${True}

*** Keywords ***
Set Allowed Alarms For ASiR Suite Setup
    Set Suite Variable    @{ASIR_ALLOWED_ALARMS}    ${4459}    ${61648}

Set Allowed Alarms For ASiR
    Set Test Variable    @{ASIR_ALLOWED_ALARMS}    ${4459}    ${61648}

Alarm Upload For ASI
    [Arguments]    ${user_alarm_active}    ${length}
    Upload Alarms    dist_name=${MO_ASI_ID}
    ${netact_alarms}=    netact.Get Alarms    dist_name=${MO_ASI_ID}
    ...                                       alias=${NETACT_NAME}
    ${fault_id}=    Set Variable    ${4459}
    ${fault_name}=    Set Variable    User Account has Default Password

    Run Keyword If    ${user_alarm_active} == ${True}    Wait Until Keyword Succeeds    1 min    15 sec
    ...                                                  AsirOp.Verify Alarm Is Active    ${fault_id}
    Run Keyword If    ${user_alarm_active} == ${True}    Length Should Be    ${netact_alarms}    ${length}    ${netact_alarms}
    Run Keyword If    ${user_alarm_active} == ${True}    Check Fault is exist    ${netact_alarms}    ${fault_id}
    Run Keyword If    ${user_alarm_active} == ${False}    Length Should Be    ${netact_alarms}    ${length}    ${netact_alarms}

Check Fault is exist
    [Arguments]    ${netact_alarms}    ${fault_id}
    ${search_fault}=    Set Variable    FaultId=${fault_id}
    ${alarm_found}=    Set Variable    ${FALSE}
    FOR    ${alarm}    IN    @{netact_alarms}
        ${additional_text3_value}=    Set Variable    ${alarm.additionalText3}
        IF    $additional_text3_value is not ${None}
            ${alarm_found}=    Run Keyword And Return Status    Should Contain    ${additional_text3_value}    ${search_fault}
            IF    ${alarm_found}
                BREAK
            END
        END
    END
    Should Be True    ${alarm_found}    Alarm with FaultId=${fault_id} not found

Add Node And Web Url
    [Arguments]    ${service_name}
    netact.Add Node    service_name=${service_name}
    ...                hostname=${NODE_IP}
    ...                username=${USERNAME}
    ...                password=${PASSWORD}
    ...                alias=${NETACT_NAME}
    netact.Add Web Url    web_url=${WEB_URL}
    ...                   username=${USERNAME}
    ...                   password=${password}
    ...                   alias=${NETACT_NAME}

Delete Node And Clean
    [Arguments]    ${service_name}
    netact.Delete Node    service_name=${service_name}
    ...                   alias=${NETACT_NAME}
    netact.Clean All    alias=${NETACT_NAME}

Integrate ASI With NetAct
    [Arguments]    ${mr}
    ${release}=    Replace String    ${RELEASE}    SBTS    ASI
    ${integration_output}=    netact.Integrate ASI With Netact    release=${release}
    ...                                                           mr=${mr}
    ...                                                           asi_address=${MO_MRBTS_ADDR}
    ...                                                           dist_name=${MO_ASI_ID}
    ...                                                           security_mode=${SECURITY_MODE}
    ...                                                           alias=${NETACT_NAME}

Deintegrate ASI With NetAct
    ${deintegration_output}=    netact.Deintegrate NE From Netact    dist_name=${MO_ASI_ID}
    ...                                                           alias=${NETACT_NAME}
Upload Alarms
    [Arguments]    ${dist_name}
    ${upload_output}=    netact.Upload Alarms    dist_name=${dist_name}
    ...                                          alias=${NETACT_NAME}
    Should Contain    ${upload_output}    Alarm Upload: SUCCESS

Prepare ASiR WebEM Browser
    AsirWebEM.clean_browser
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}
    AsirWebEM.login

Prepare ASiR WebEM Browser Correct Regex
    AsirWebEM.clean_browser
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}
    AsirWebEM.login_with_toor4nsn_password_change    toor4nsn_new_password=oZPS0POrRieRt#2
    ...                                              toor4nsn_correct_regex_password=oZPS0POrRieRt#2

Prepare ASiR WebEM Browser Incorrect Regex
    AsirWebEM.clean_browser
    AsirWebEM.set_virtual_enable    virtual_enable=${VIRTUAL_DISPLAY}
    AsirWebEM.login_with_password_handling    toor4nsn_new_password=oZPS0POrRieRt#22
    ...                                       toor4nsn_correct_regex_password=oZPS0POrRieRt#2

Logout ASiR WebEM
    AsirWebEM.logout

Change ASiR WebEM Password
    ${USERS}    Create Dictionary    wsuser=oZPS0P64rRieRt#
    AsirWebEM.change_accounts_password    account_type=NE3S User Account
    ...                                   user_passwd_dict=${USERS}
    ...                                   check_required=False

Reset ASiR WebEM Password
    AsirWebEM.reset_accounts_password_to_default    account_type=NE3S User Account
    ...                                             user=wsuser
    ...                                             check_required=False
    AsirWebEM.reset_accounts_password_to_default    account_type=Hub User Accounts    user=toor4nsn

Close ASiR WebEM Browser
    Run Keyword And Continue On Failure    AsirWebEM.logout
    Run Keyword And Continue On Failure    AsirWebEM.clean_browser

Change value of allowAsiDefaultPassword
    [Arguments]    ${value}
    Run Keyword If    ${value} == ${False}
    ...    AsirOp.perform asir recommissioning    delta=${allowASiLocalUserDefaultPasswordFalse}
    ...    ELSE IF    ${value} == ${True}
    ...    AsirOp.perform asir recommissioning    delta=${allowASiLocalUserDefaultPasswordTrue}

Custom Postconditions
    Close ASiR WebEM Browser
    Common Postconditions