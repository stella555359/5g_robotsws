*** Settings ***
Documentation
...    Author: Shuangfeng.f.sun
...    Contact: Shuangfeng.f.sun@nokia-sbell.com
...    this file is collect some Common KWs of AIC,you can use it in your case directly.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown    Common Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot
Resource          ../../../../resources/RAN_PZ_HAZ_1/Module/Module.robot
*** Test Cases ***

CB010414_CB008737_A_01_Service_Account_Management_on_FDD_CPRI_RU_through_FHGW
    [Tags]     CRT    CB010414_CB008737_A_01
    [Documentation]
    ...    shuangfeng.f.sun@nokia-sbell.com,draft
    ...    history change: <date>,<who>,<what and how>
    [Setup]      Case Precondition
#    ${mo_dn}    Set Variable    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-7
    @{para_list}          Create List    actSshToRU
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    @{value_list_true}    Create List    true
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu
#    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRU    value=true    mo_dn=${mo_dn}
    Set New Password For RU On Webem    username=serviceuser    new_password=Nokia@1234
    Config SSH Tunnel    operation=Enable    dist_name=${dist_name}
    ${conn}    Connect Ru Or Rannic Via SSH Tunnel Port   ssh_mode_dist_name=${dist_name}
    ...                                                   password=Nokia@1234
    Check SSH Connection Status    conn=${conn}
    basic.master_close    alias=${conn}
    Set New Password For RU On Webem    username=serviceuser    new_password=Nokia@12345
    ${conn}    Connect Ru Or Rannic Via SSH Tunnel Port    ssh_mode_dist_name=${dist_name}    password=Nokia@12345
    Check SSH Connection Status    conn=${conn}
    basic.master_close    alias=${conn}
    Config SSH Tunnel    operation=Disable    dist_name=${dist_name}
    Check SSH Rort Status    expected_status=Deactivated    dist_name=${dist_name}
    Config SSH Tunnel    operation=Enable    dist_name=${dist_name}
    ${conn}    Connect Ru Or Rannic Via SSH Tunnel Port    ssh_mode_dist_name=${dist_name}    password=Nokia@12345
    Reset RU With Check Cell On Air
    Check SSH Rort Status    dist_name=${dist_name}
    [Teardown]      CB008737_A Postcondition

*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${vdu_hostname_dict}    ${vdu_username_dict}    ${vdu_password_dict}    ${vdu_ns_dict}
    ...                                               Get SSH Connection Infor For Multiple vDU With Different vCU
    Set Test Variable    ${vdu_hostname_dict}
    Set Test Variable    ${vdu_username_dict}
    Set Test Variable    ${vdu_password_dict}
    Set Test Variable    ${vdu_ns_dict}
    ${vcu_hostname_list}  ${vcu_username_list}  ${vcu_password_list}  ${vcu_ns_list}
    ...                                               Get SSH Connection Infor For Multiple vCU K8s Master
    Set Test Variable    ${vcu_hostname_list}
    Set Test Variable    ${vcu_username_list}
    Set Test Variable    ${vcu_password_list}
    Set Test Variable    ${vcu_ns_list}
    ${NEW_PLAN_NAME}     Get Test Case Name
    Set Test Variable    ${NEW_PLAN_NAME}

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRU    value=false
    ...                                mo_dn=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    run keyword and ignore error    basic.master_close    alias=${conn}
#    run keyword and ignore error  Detach UE    ue_index=0

CB008737_A Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    ${dist_name}    Set Variable    MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-7
    @{para_list}          Create List    actSshToRU
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    @{value_list_true}    Create List    false
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=vdu

CB008737_B Postcondition
    log to console    Case Postcondition
    Common Test Teardown For AIC
    Modify Parameters By Delta Plan    ne=vDU    parameter=actSshToRanNic    value=false
    ...                                mo_dn=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    run keyword and ignore error    basic.master_close    alias=${conn}

Modify Parameters By Delta Plan
    [Arguments]   ${ne}=vDU    ${parameter}=actCDrx    ${value}=true
    ...           ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-71
    Run Keyword If    '${ne}'=='vDU'    Modify Parameters By Delta Plan In vDU    parameter=${parameter}
    ...                                                                           value=${value}
    ...                                                                           mo_dn=${mo_dn}
    ...            ELSE IF   '${ne}'=='vCU'    Modify Parameters By Delta Plan In vCU    parameter=${parameter}
    ...                                                                                  value=${value}
    ...                                                                                  mo_dn=${mo_dn}
    ...            ELSE IF   '${ne}'=='all'    Modify Parameters By Delta Plan In vCU And vDU    parameter=${parameter}
    ...                                                                                   value=${value}
    ...                                                                                   mo_dn=${mo_dn}

Modify Parameters By Delta Plan In vDU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-71
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If    &{parameter_dict1} != &{Empty}    VDU Online Modify Parameters By Delta Plan REST
    ...                                          mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest
    [Teardown]    Run Keyword And Ignore error    vDU Logout By Rest

Modify Parameters By Delta Plan In vCU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-71
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
    ...                                                                         value=${value}
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}

Modify Parameters By Delta Plan In vCU And vDU
    [Arguments]   ${parameter}=actCDrx    ${value}=true    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-71
#    ${mo_dn}   Set Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    &{vcu_param}    create dictionary    operation_type=replace    parameter_path=/${parameter}
    ...                                                                         value=${value}
    @{updated_vcu_param}    Create List    ${vcu_param}
    vCU Online modify Simple Parameters Via Rest With Compare    parameter_name=${parameter}
    ...                                                   updated_paras_dict=${updated_vcu_param}
    ...                                                   compare_value=${value}
    ...                                                   mo_dn=${mo_dn}
    &{parameter_dict}    Create Dictionary   ${parameter}=${value}
    &{parameter_dict1}    Judge Whether The Parameter Needs To Be Modified    mo_dn=${mo_dn}
    ...                                                                      mo_parameter_dict=&{parameter_dict}
    vDU Login By Rest
    Run Keyword If  &{parameter_dict1} != &{Empty}
    ...             VDU Online Modify Parameters By Delta Plan REST    mo_dn=${mo_dn}
    ...                                          updated_paras_list=${parameter_dict}
    ...                                          operation=replace
    ...                                          activate=${True}
    ...                                          force_reset=${False}
    ...                                          auto_lock_cells=${False}
    ...                                          wait_vdu_up=${False}
    vDU Logout By Rest

Prepare UE as M80
    [Arguments]    ${ue_index}=${1}
    Log to Console    \n***Prepare M80***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=default
    Log to Console    \n***UE Prepared...***
    [Return]     ${ue_${ue_index}_type}

Attach UE as M80
    [Arguments]    ${ue_index}=${1}
    Log to Console    \n***M80 attach***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    Log to Console    \n***UE Attached...***

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=default
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Set New Password For RU On Webem
   [Arguments]    ${username}=serviceuser    ${new_password}=Qwer@12345
   Log To Console    \n***Set New Password For RU On Webem***
   ${serviceuser_info}    Update Service Account Passwd In vDU By Rest Api    username=${username}
   ...                    new_password=${new_password}

Set Default Password For RU On Webem
   [Arguments]    ${username}=serviceuser    ${new_password}=Pl(FzaYj5~c5;q
   Log To Console    \n***Set New Password For RU On Webem***
   ${expected_error}    Set Variable    Password validation failed, set pwd back to default not allowed
   ${serviceuser_info}    Update Service Account Passwd In vDU By Rest Api    new_password=${new_password}
   ...                    username=${username}
   Should Contain  ${serviceuser_info}    ${expected_error}

Try To Connect Ru with New Password
    [Arguments]     ${password}=Qwer@12345
    Log To Console    \n***Try To Connect Ru with Default Password***
    ${expected_error}    Set Variable    No match found*
    Run Keyword And Expect Error    ${expected_error}    SSH Ru By VDU Container    ru_password=${password}

Try To Connect Ru with Default Password
    [Arguments]     ${password}=Pl(FzaYj5~c5;q
    Log To Console    \n***Try To Connect Ru with Default Password***
    ${expected_error}    Set Variable    ConnectFailedError*
    Run Keyword And Expect Error    ${expected_error}    Connect Ru Or Rannic Via SSH Tunnel Port
    ...                             password=${password}

Check SSH Rort Status
    [Arguments]    ${ssh_mode_type}=RMOD    ${expected_status}=Deactivated
    ...            ${dist_name}=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-7
    Log To Console    \*** Check SSH Rort Status
    ${port_status}    Get SSH Tunnel Status    ssh_mode_type=${ssh_mode_type}    dist_name=${dist_name}
    Should Be Equal    ${port_status}    ${expected_status}    The port status is not the expected status

Check SSH Connection Status
    [Arguments]  ${conn}
    Log To Console    \*** Check ssh connection status
    ${cmd}=    Catenate    lslogins -u
    tafssh.Execute    command=${cmd}    connection=${conn}

Check Account Ssh Sync in Log
    [Arguments]    ${oamfh_log}
    Log To Console    \n*** Check account ssh sync in log***
    ${sync_filter}    Set Variable    syscomSshSyncMsgHandler
    ${cmd}    Catenate    cat ${oamfh_log} | grep -a "${sync_filter}"
    ${result}    OperatingSystem.Run    ${cmd}
    Should Contain    ${result}    receive account ssh sync request