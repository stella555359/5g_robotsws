*** Settings ***
Documentation
...  author: Chen Yin 4
...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com

Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh    WITH NAME    csn
Resource    ./COAM.robot
Resource    ../../common/taf_coam.robot
Resource    ../../common/qc_tag.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables   ../../libraries/global_vars.py
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

Resource    ../CaseResource/001_Upgrade_to_Target_build_and_check_default_value.robot
Resource    ../CaseResource/002_Feature_flag_is_enable_password_change_to_default.robot
Resource    ../CaseResource/003_Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_default.robot
Resource    ../CaseResource/004_Feature_flag_is_enable_alarm_is_raised_update_alarm_by_password_change_to_non_default.robot
Resource    ../CaseResource/005_Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_password_change_to_non_default.robot
Resource    ../CaseResource/006_Feature_flag_is_enable_alarm_is_raised_Clear_alarm_by_disable_feature_flag.robot
Resource    ../CaseResource/007_Feature_flag_is_disable_with_default_password_enable_flag.robot
Resource    ../CaseResource/008_Feature_flag_is_enable_ssh_is_enable_change_Local_Nokia_Service_account_password_to_default.robot
Resource    ../CaseResource/ASOE_Test_Models_For_5G.robot
Resource    ../CaseResource/Beamforming_Grid_Selection_Modification_via_WEBEM_Requires_Object_Locking.robot

*** Variables ***
${TEST_MODE}   no
${Nemuadmin_passwd}   ${WEBUI_PASSWORD}
${toor4nsn_passwd}   ${oam_password}
${dcuser_passwd}   nE&e3Q*ptK8
${serviceuser_passwd}   Pl(FzaYj5~c5;q
${non_default_passwd}   nemu_Arthur08

*** Keyword ***
Common Setup
    Log To Console   ${EMPTY}
    Set Suite Variable    ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable    ${MO_NAME}    MRBTS-${BTS_ID}
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    COAM Login
#    Set QC Instance ID Test Tag
    Run Keyword And Ignore Error   COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1/LUAC-1
    ...   parameter=btsMaxFailedLoginAttempts
    ...   value=0
    ${prod_var}   COAM Get Parameter Value
    ...   dist_name=${MO_NAME}/MNL-1
    ...   parameter=productVariantPlanned
    Set Suite Variable   ${PROD_VAR}
    SSH To GNB And Backup Password File

Common Teardown
    Wait Until Keyword Succeeds   3x   1m   Change ALL Password To Default And Wait

    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir
    ${status}   Run Keyword And Return Status   Check Fault 4459 All Users Listed In Detail
    Run Keyword And Ignore Error   Run Keyword If   '${PROD_VAR}'=='sBTS' and not ${status}
    ...   Change dcuser Password To Default Without Delete dcuser Json
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/AMGR-1
    ...   parameter=enableDefaultPasswdAlarm
    ...   value=false
    COAM Update Parameter
    ...   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1
    ...   parameter=actServiceAccountSsh
    ...   value=true
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1m   10s   Check Fault 4459 Cleared
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   csn.Reset Cache
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown
    Run Keyword And Ignore Error   csn.Reset Cache

Change ALL Password To Default And Wait
    Run Keyword And Ignore Error   COAM Logout
    ${status}   Run Keyword And Return Status   COAM Login   password=${Nemuadmin_passwd}
    run keyword if  not ${status}   COAM Login   password=${non_default_passwd}

    Change All Password To Default
    COAM Reset Site   wait_for_reconnection=${False}
    Sleep   5m
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   10m   1m   COAM Login   password=${Nemuadmin_passwd}

SSH To GNB And Backup Password File
    Run Keyword And Ignore Error   csn.Reset Cache
    csn.Connect To   hostname=${asik_addr}   username=toor4nsn   password=${toor4nsn_passwd}   alias=ASIK
    csn.Download File   remote_path=/ffs/run/config/users.json   local_path=${OUTPUT_DIR}/users.json   connection=ASIK
    csn.Download File   remote_path=/etc/shadow   local_path=${OUTPUT_DIR}/shadow   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Download File   remote_path=/ffs/run/config/dcusers.json
    ...   local_path=${OUTPUT_DIR}/dcusers.json   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Execute   command=cat /ffs/run/config/dcusers.json   connection=ASIK
    Run Keyword If   '${PROD_VAR}'=='sBTS'   csn.Execute   command=ls -la /ffs/run/config/*.json   connection=ASIK
    [Teardown]   csn.Disconnect   connection=ASIK

Set QC Instance ID Test Tag
    Run Keyword And Ignore Error   csn.Reset Cache
    ${qc_def}   Get Common Tags Info By SMOD and Release   file_path=${CURDIR}/qc_id_def.csv
    Set Case Common Tags By Test Aggregate   qc_def=${qc_def}
