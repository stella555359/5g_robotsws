*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Resource   Common.robot

*** Variables ***


*** Keyword ***
Enable Default Password Alarm And Check Alarm
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=true
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 All Users Listed In Detail

Disable Default Password Alarm And Check No Alarm
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=false
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared
    Catch Snapshot And IMS2 File

Reset Site And Check Alarm Cleared
    COAM Reset Site
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir
    Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared

Check Fault 4459 Cleared
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    FOR   ${active_alarm}   IN   @{active_alarms}
       Should Not Be Equal As Strings   ${active_alarm['faultId']}   4459
    END

Check Fault 4459 Raised
    ${active_alarms}   taf_coam.COAM Get Active Alarms
    ${supplAlarmInfo}   Set Variable   NONE
    FOR   ${active_alarm}   IN   @{active_alarms}
       ${supplAlarmInfo}   Set Variable If
       ...   '${active_alarm['faultId']}'=='4459'   ${active_alarm['supplAlarmInfo']}
       ...   '${active_alarm['faultId']}'!='4459'   ${supplAlarmInfo}
       Exit For Loop If   '${active_alarm['faultId']}'=='4459'
    END
    Should Not Be Equal As Strings   ${supplAlarmInfo}   NONE
    [Return]   ${supplAlarmInfo}

Check Fault 4459 Default User Detail
    [Arguments]   ${contain_list}   ${not_contain_list}
    ${supplAlarmInfo}   Check Fault 4459 Raised
    ${supplAlarmInfo}   Remove String   ${supplAlarmInfo}   BTS user accounts that have default password:${SPACE}
    @{report_list}   Split String   ${supplAlarmInfo}   ,${SPACE}

    ${report_length}   Get Length   ${report_list}
    ${contain_length}   Get Length   ${contain_list}
    Should Be Equal   ${report_length}   ${contain_length}

    FOR   ${user}   IN   @{contain_list}
       List Should Contain Value   ${report_list}   ${user}
    END

    FOR   ${user}   IN   @{not_contain_list}
       List Should Not Contain Value   ${report_list}   ${user}
    END

Check Fault 4459 All Users Listed In Detail
    @{contain_list}   Create List
    ...   Bts Sys Admin (Nemuadmin)
    ...   Nokia Service User Non Root Account (serviceuser)
    ...   Nokia Service User Root Account (toor4nsn)
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Append To List   ${contain_list}   Dcc Account Access (dcuser)
    @{not_contain_list}   Create List
    Wait Until Keyword Succeeds   1m   10s
    ...   Check Fault 4459 Default User Detail   contain_list=${contain_list}   not_contain_list=${not_contain_list}

Change Nemuadmin Password To Non-Default
    COAM Change WEBEM Password   old_password=${Nemuadmin_passwd}   new_password=${non_default_passwd}

Change Nemuadmin Password To Default
    [Arguments]   ${hostname}=${asik_addr}
    Run Keyword And Ignore Error   csn.Reset Cache
    ${status}   Run Keyword And Return Status   csn.Connect To
    ...   hostname=${hostname}   username=toor4nsn   password=${toor4nsn_passwd}   alias=ASIK
    run keyword if  not ${status}   csn.Connect To
    ...   hostname=${hostname}   username=toor4nsn   password=${non_default_passwd}   alias=ASIK
    csn.Execute   command=rm -rf /ffs/run/config/users.json   connection=ASIK
    csn.Upload File   local_path=${OUTPUT_DIR}/users.json   remote_path=/ffs/run/config/users.json   connection=ASIK
    [Teardown]   csn.Disconnect   connection=ASIK

Change dcuser Password To Non-Default
    COAM Change WEBEM Password   old_username=dcuser   old_password=${EMPTY}   new_username=${EMPTY}   new_password=${non_default_passwd}

Change dcuser Password To Default Without Delete dcuser Json
    COAM Change WEBEM Password   old_username=dcuser   old_password=${EMPTY}   new_username=${EMPTY}   new_password=${dcuser_passwd}

Change toor4nsn Password To Non-Default
    COAM Change SSH Password   username=toor4nsn   old_password=${toor4nsn_passwd}   new_password=${non_default_passwd}

Change toor4nsn Password To Default
    [Arguments]   ${hostname}=${asik_addr}
    Run Keyword And Ignore Error   csn.Reset Cache
    ${status}   Run Keyword And Return Status   csn.Connect To
    ...   hostname=${hostname}   username=toor4nsn   password=${toor4nsn_passwd}   alias=ASIK
    run keyword if  not ${status}   csn.Connect To
    ...   hostname=${hostname}   username=toor4nsn   password=${non_default_passwd}   alias=ASIK
    ${output}   csn.Execute   command=cat /ffs/run/etc/p_shadow   connection=ASIK
    ${status}   Run Keyword And Return Status   Should Contain   ${output}   toor4nsn
    Run Keyword If   ${status}   csn.Execute   command=sed -i '/toor4nsn/d' /ffs/run/etc/p_shadow   connection=ASIK
    csn.Execute   command=rm -rf /etc/shadow   connection=ASIK
    csn.Upload File   local_path=${OUTPUT_DIR}/shadow   remote_path=/etc/shadow   connection=ASIK
    [Teardown]   csn.Disconnect   connection=ASIK

Change serviceuser Password To Non-Default
    COAM Change SSH Password   username=serviceuser   old_password=${serviceuser_passwd}   new_password=${non_default_passwd}

Change serviceuser Password To Default Without Delete shadow
    COAM Change SSH Password   username=serviceuser   old_password=${non_default_passwd}   new_password=${serviceuser_passwd}

Change All Password To Non-Default
    Change toor4nsn Password To Non-Default
    Change serviceuser Password To Non-Default
    Change Nemuadmin Password To Non-Default
    Run Keyword If   '${PROD_VAR}'=='sBTS'   Change dcuser Password To Non-Default

Change All Password To Default
    [Arguments]   ${hostname}=${asik_addr}
    Run Keyword And Ignore Error   csn.Reset Cache
    ${status}   Run Keyword And Return Status   csn.Connect To
    ...   hostname=${hostname}   username=toor4nsn   password=${toor4nsn_passwd}   alias=ASIK
    run keyword if  not ${status}   csn.Connect To
    ...   hostname=${hostname}   username=toor4nsn   password=${non_default_passwd}   alias=ASIK
    csn.Execute   command=rm -rf /ffs/run/etc/p_shadow   connection=ASIK
    csn.Execute   command=rm -rf /etc/shadow   connection=ASIK
    csn.Execute   command=rm -rf /ffs/run/config/users.json   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Execute   command=cat /ffs/run/config/dcusers.json   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Execute   command=rm -rf /ffs/run/config/dcusers.json   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Execute   command=ls -la /ffs/run/config/*.json   connection=ASIK
    csn.Upload File   local_path=${OUTPUT_DIR}/shadow   remote_path=/etc/shadow   connection=ASIK
    csn.Upload File   local_path=${OUTPUT_DIR}/users.json   remote_path=/ffs/run/config/users.json   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Upload File
    ...   local_path=${OUTPUT_DIR}/dcusers.json   remote_path=/ffs/run/config/dcusers.json   connection=ASIK
    [Teardown]   csn.Disconnect   connection=ASIK

Catch Snapshot And IMS2 File
    Run Keyword And Ignore Error   Run Keyword If   '${TEST_MODE}'=='yes'   Catch Snapshot COAM
    Run Keyword And Ignore Error   Run Keyword If   '${TEST_MODE}'=='yes'   Catch IMS2 Snapshot COAM

COAM Enable Local Account State And Change Password
    COAM Change Local Account State By Commission
    COAM Change WEBEM Password   old_username=BTSSecurity   old_password=${EMPTY}
    ...   new_username=alias1   new_password=${non_default_passwd}
    COAM Change WEBEM Password   old_username=BTSApplication   old_password=${EMPTY}
    ...   new_username=alias2   new_password=${non_default_passwd}
    COAM Change WEBEM Password   old_username=BTSRead   old_password=${EMPTY}
    ...   new_username=alias3   new_password=${non_default_passwd}

COAM Change Local Account State By Commission
    [Arguments]   ${enable}=true
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1/LUAC-1
    ...   parameter=readOnlyActivated
    ...   value=${enable}
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1/LUAC-1
    ...   parameter=appAdmActivated
    ...   value=${enable}
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1/LUAC-1
    ...   parameter=secAdmActivated
    ...   value=${enable}
