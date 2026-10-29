*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***

*** Keywords ***
Monitor Alarm Manual Pages
    Step1 Open Monitor
    Step2 Open alarm list and alarm details
    Step3 Create alarm for NE
    Step4 Check alarm on Monitor and open alarm page of this alarm
    Step5 Clear alarm and check it on Monitor

Step1 Open Monitor
    ${REMOTE_PORT}   Open Monitor
    set test variable   ${REMOTE_PORT}

Step2 Open alarm list and alarm details
    swing.Select From Main Menu And Wait   menuPath=Tools|Monitoring Desktop|Alarm Details
    Select MO and Open Popup Menu in FM Monitor   mo_name=PLMN-PLMN|${MO_NAME}   popup_menu=Find In|Alarm List
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    30s    2s    swing.Component Should Exist   identifier=${ALARM_LIST_COMPONENT}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1 min    5 sec
    ...   My Swing Table Row Count Should Be Stable   tableId=${ALARM_LIST_COMPONENT}   sleepTimeSeconds=8 sec

Step3 Create alarm for NE
    # All Modify Configuration Values   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1   parameter=actServiceAccountSsh   value=true
    Run Keyword If   '${gnb_type}'=='classical' or '${gnb_type}'=='coamdu'
    ...   All Modify Configuration Values   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1   parameter=actServiceAccountSsh   value=true
    ...   ELSE IF    '${gnb_type}'=='cloud' or '${gnb_type}'=='coamcu'
    ...   Trigger fake alarm for BTS   NE_class=cloud   severity=Critical   status=raise   alarm_nbr=7108

Step4 Check alarm on Monitor and open alarm page of this alarm
    ${ALARM_INFO}   Run Keyword If   '${gnb_type}'=='classical' or '${gnb_type}'=='coamdu'   Create Dictionary   severity=Minor   alarmName=7220
    ...   senderDN=PLMN-PLMN/${MO_NAME}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...   ELSE IF    '${gnb_type}'=='cloud' or '${gnb_type}'=='coamcu'   Create Dictionary   severity=Critical   alarmName=7108

    Set Test Variable   ${ALARM_INFO}
    Wait Until Keyword Succeeds   2min   10s
    ...   Find Alarm for MO in FM Monitor   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${ALARM_INFO}   alarm_status=${true}
    Open Alarm Details Window and Check   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${ALARM_INFO}

Step5 Clear alarm and check it on Monitor
    # All Modify Configuration Values   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1   parameter=actServiceAccountSsh   value=false
    Run Keyword If   '${gnb_type}'=='classical' or '${gnb_type}'=='coamdu'
    ...   All Modify Configuration Values   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1   parameter=actServiceAccountSsh   value=false
    ...   ELSE IF    '${gnb_type}'=='cloud' or '${gnb_type}'=='coamcu'
    ...   Trigger fake alarm for BTS   NE_class=cloud   severity=Critical   status=clear   alarm_nbr=7108

    Wait Until Keyword Succeeds   2min   10s
    ...   Find Alarm for MO in FM Monitor   table_name=${ALARM_LIST_COMPONENT}   search_key_dict=${ALARM_INFO}   alarm_status=${false}

Case Setup: Monitor Alarm Manual Pages
    Run Keyword And Ignore Error   Common Case Setup
    
    set test variable  ${NE_type}   ${NE3SWS_IPversion}
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${true}

Case Teardown: Monitor Alarm Manual Pages
    # All Modify Configuration Values   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1   parameter=actServiceAccountSsh   value=false
    Run Keyword If   '${gnb_type}'=='classical' or '${gnb_type}'=='coamdu'
    ...   All Modify Configuration Values   dist_name=${MO_NAME}/MNL-1/MNLENT-1/SECADM-1   parameter=actServiceAccountSsh   value=true
    ...   ELSE IF    '${gnb_type}'=='cloud' or '${gnb_type}'=='coamcu'
    ...   Trigger fake alarm for BTS   NE_class=cloud   severity=Critical   status=clear   alarm_nbr=7108

    Run Keyword And Ignore Error   Close Monitor   Monitor
    Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${REMOTE_PORT}
    Run Keyword And Ignore Error   Common Case Teardown
    run keyword if test failed  run keyword and ignore error   Catch Logs from NetAct   node_ip=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   username=${SERVICE_USER}   password=${SERVICE_PASSWORD}   Log_Area=FM
    run keyword if test failed  run keyword and ignore error   Catch Logs from NetAct   node_ip=${HOST_IP['${JBI_COMMONMEDIATION_HOSTS[0]}']}
    ...   username=${SERVICE_USER}    password=${SERVICE_PASSWORD}   Log_Area=COMMON_MEDIATION
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout


