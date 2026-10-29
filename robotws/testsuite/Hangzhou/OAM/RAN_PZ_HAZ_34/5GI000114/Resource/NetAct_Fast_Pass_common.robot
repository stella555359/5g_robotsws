*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library           DateTime
Library           XML    True
Library           Collections
Library           OperatingSystem
Library           Telnet    prompt=(> |# )    prompt_is_regexp=yes
Library           taf.transport.ssh    WITH NAME    csn
Library           NetAct_Utils.py
Library           feedback_collector.py
Variables         common_vars.py
Variables         ../../libraries/global_vars.py
Variables         ../../libraries/selenium_utils.py
Variables         NetAct_Fast_pass_qc_id.py
Resource          FM_common.robot
Resource          CM_common.robot
Resource          Software_Asset_Monitoring.robot
Resource          Software_Manager.robot
Resource          NetAct_common.robot
Resource          common_all.robot
Resource          common_coam.robot
Resource          common_cu.robot
Resource          common_megazone.robot
Resource          ../../common/taf_megazone.robot
Resource          ../../common/taf_coam.robot
Resource          ../../common/taf_coam_cu.robot
Resource          ../../common/NetAct_selenium.robot
Resource          ../../common/NetAct_swing.robot
Resource          ../../common/NetAct_ssh.robot
Resource          ../CaseResource/Integrating_NE_to_NetAct.robot
Resource          ../CaseResource/Integrating_With_DNS.robot
Resource          ../CaseResource/CM_Check_OIB_Functionality_and_Content.robot
Resource          ../CaseResource/FM_Check_OIB_Functionality_and_Content.robot
Resource          ../CaseResource/PM_Check_OIB_Functionality_and_Content.robot
Resource          ../CaseResource/EMLaunch_Basic.robot
Resource          ../CaseResource/EMLaunch_Basic_DNS.robot
Resource          ../CaseResource/EMLaunch_Lock_and_unlock.robot
Resource          ../CaseResource/EMLaunch_Slice_Lock_and_unlock.robot
Resource          ../CaseResource/CM_Activating_configuration_changes_with_Send_To_Network.robot
Resource          ../CaseResource/CM_Creating_and_activating_a_plan.robot
Resource          ../CaseResource/CM_Uploading_actual_configuration_from_NE.robot
Resource          ../CaseResource/CM_Verification_of_workflow_engine-workflows.robot
Resource          ../CaseResource/FM_Monitor_Alarm_Manual_Pages.robot
Resource          ../CaseResource/FM_Monitor_alarm_upload.robot
Resource          ../CaseResource/FM_Monitor_Online_Alarm_Flow.robot
Resource          ../CaseResource/SWM_Software_provision_rollback_upload.robot
Resource          ../CaseResource/SWAM_NetAct_TM_Radio_module.robot
Resource          ../CaseResource/SWAM_CM_module_creation.robot
Resource          ../CaseResource/CNUM_Centralized_NE_User_Management.robot
Resource          ../CaseResource/PM_Verify_PM_pipe.robot

*** Variables ***
${REINTEGRATION}   ${True}
${Commissioning}   ${True}
${targetVersion}   0.800.2536
${old_remoteswing}   \\/opt\\/ute\\/remoteswinglibrary\\/remoteswinglibrary.*.jar
${new_remoteswing}   \\/opt\\/ute\\/remoteswinglibrary\\/remoteswinglibrary.jar
${remoteswing_env_file}   /home/ute/.uterc/remoteswing_env.sh
${taf_swing}   /home/ute/test_repo/lib/python2.7/site-packages/taf/ul/swing/core/remoteswinglibrary-2.2.3.jar
#${taf_swing}   /home/ute/test_repo/lib/python2.7/site-packages/taf/ul/swing/core/remoteswinglibrary-2.2.3.jar

*** Keyword ***
Common Setup
    [Arguments]    ${lab_name}=CLAB204    ${dns_flag}=${False}
    Run Keyword And Ignore Error    selenium_netact.enable_virtual_display
    Run Keyword And Ignore Error    Close All Java Application Forced
    Set Global Lab Information    ${lab_name}

    Set Suite Variable    ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable    ${MO_NAME}    MRBTS-${BTS_ID}
    Set Suite Variable    ${NO_NAME}    NRBTS-${BTS_ID}
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}

    All Get All Suite Variables
    
    Run Keyword If   '${SOFTWARE_VERSION}'!='default'   All Get All Suite Variables NetAct Only
    ...   ELSE   Fail   Please Input Correct targetVersion.

    Log To Console   Output All Suite Variables:
    Log To Console   NetAct HOST IP: ${HOST_IP}
    Log To Console   NetAct Start Page: ${START_PAGE}
    Log To Console   GNB_TYPE: ${GNB_TYPE}
    Log To Console   SYSTEM_MODULE: ${SYSTEM_MODULE}
    Log To Console   BTS_ID: ${BTS_ID}
    Log To Console   MO_NAME: ${MO_NAME}
    Log To Console   NO_NAME: ${NO_NAME}
    Log To Console   DN: ${DN}
    Log To Console   Release: ${RELEASE}
    Log To Console   Software_version: ${SOFTWARE_VERSION}
    Log To Console   NE3SWS_mode: ${NE3SWS_mode}
    Log To Console   NE3SWS_IPversion: ${NE3SWS_IPversion}
    
    Get Swm Archive Version List
		Get Swm Description And Error Details
		Get Swm Execution
		Get Swm General Data
		Get Swm Progress Messages
		Get Swm Time Constraints
		Get Total Number From Total Text
    
    COAM Restore Vendor Certificate
    COAM GNB Certificate Installation   ${lab_name}

    Run Keyword If   ${REINTEGRATION} and ${dns_flag}   Integrating_With_DNS
    ...   ELSE   Integrating NE to NetAct
    #...   ELSE   Log To Console   Skip ReIntegrate Operation.

Common Setup For UTE
    [Arguments]    ${lab_name}=${NETACT}    ${dns_flag}=${false}   ${fp_filename}=${FP_PACKAGE_NAME}
    Send Feedback Keyword    fp_filename=${fp_package_name}    stage=CRT_5G    lab=${lab_name}    status=started
    Run Keyword And Ignore Error    selenium_netact.enable_virtual_display    1920    1080
    Run Keyword And Ignore Error    Close All Java Application Forced
    
    UTE Preparation
    
    Set Global Lab Information    ${lab_name}

    Set Suite Variable    ${BTS_ID}   ${tl.gnbs[0].instance_id}
    Set Suite Variable    ${MO_NAME}    MRBTS-${BTS_ID}
    Set Suite Variable    ${NO_NAME}    NRBTS-${BTS_ID}
    Set Suite Variable    ${DN}    PLMN-PLMN/${MO_NAME}

    COAM commissioning if not onair
    All Get All Suite Variables    
    All Get All Suite Variables NetAct Only

    #COAM Restore Vendor Certificate
    #COAM GNB Certificate Installation   ${lab_name}

    Log To Console   Output All Suite Variables:
    Log To Console   NetAct HOST IP: ${HOST_IP}
    Log To Console   NetAct Start Page: ${START_PAGE}
    Log To Console   GNB_TYPE: ${GNB_TYPE}
    Log To Console   SYSTEM_MODULE: ${SYSTEM_MODULE}
    Log To Console   BTS_ID: ${BTS_ID}
    Log To Console   MO_NAME: ${MO_NAME}
    Log To Console   NO_NAME: ${NO_NAME}
    Log To Console   DN: ${DN}
    Log To Console   Release: ${RELEASE}
    Log To Console   Software_version: ${SOFTWARE_VERSION}
    Log To Console   NE3SWS_mode: ${NE3SWS_mode}
    Log To Console   NE3SWS_IPversion: ${NE3SWS_IPversion}

    Run Keyword If   ${REINTEGRATION} and ${dns_flag}   Integrating_With_DNS
    ...   ELSE   Integrating NE to NetAct

UTE Preparation
    OperatingSystem.Run   sudo rm -rf /usr/bin/firefox
    OperatingSystem.Run   sudo ln -s /usr/lib/firefox-esr/firefox-esr /usr/bin/firefox
    OperatingSystem.Run   sudo rm -rf /home/ute/.java/
    OperatingSystem.Run   mkdir -p /home/ute/.java/deployment/security/
    OperatingSystem.Run   touch /home/ute/.java/deployment/security/exception.sites
    OperatingSystem.Run   echo 'https://srnclab33lbwas.srnblr.nsn-rdnet.net/'>>/home/ute/.java/deployment/security/exception.sites
    OperatingSystem.Run   echo 'https://srnclab1002lbwas.srnblr.nsn-rdnet.net/'>>/home/ute/.java/deployment/security/exception.sites
    OperatingSystem.Run   echo 'https://srnclab1019lbwas.srnblr.nsn-rdnet.net/'>>/home/ute/.java/deployment/security/exception.sites
    OperatingSystem.Run   echo 'https://srnclab1028lbwas.srnblr.nsn-rdnet.net/'>>/home/ute/.java/deployment/security/exception.sites
    OperatingSystem.Run   echo 'https://srnclab1013lbwas.srnblr.nsn-rdnet.net/'>>/home/ute/.java/deployment/security/exception.sites
    OperatingSystem.Run   echo 'https://srnclab1060lbwas.srnblr.nsn-rdnet.net/'>>/home/ute/.java/deployment/security/exception.sites

Common Teardown
    [Arguments]    ${lab_name}=${NETACT}    ${fp_filename}=${FP_PACKAGE_NAME}
    Run Keyword And Ignore Error    COAM Logout
    Run Keyword And Ignore Error    selenium_coam.Logout
    Run Keyword And Ignore Error    selenium_netact.Logout
    Run Keyword And Ignore Error    selenium_netact.disable_virtual_display
    Run Keyword And Ignore Error    Close All Java Application Forced
    Run Keyword And Ignore Error    selenium_coam.close_browser
    Send feedback keyword   fp_filename=${fp_filename}   stage=CRT_5G   lab=${lab_name}   status=success
    #AND    Run Keyword If Any Tests Failed   Send feedback keyword   fp_filename=${fp_filename}
    #...   stage=CRT_5G_ongoing   lab=${lab_name}   status=failed

NetAct Only Common Setup
    [Arguments]    ${lab_name}=CLAB737
    Run Keyword And Ignore Error   selenium_netact.enable_virtual_display
    Set Global Lab Information   ${lab_name}
    Run Keyword If   '${targetVersion}'!='default'   All Get All Suite Variables NetAct Only
    ...   ELSE   Fail   Please Input Correct targetVersion.

    Log To Console   Output All Suite Variables:
    Log To Console   NetAct HOST IP: ${HOST_IP}
    Log To Console   NetAct Start Page: ${START_PAGE}
    Log To Console   Target Version: ${targetVersion}
    Log To Console   NIDD_RELEASE: ${NIDD_RELEASE}
    Log To Console   ProductName: ${ProductName}
    Log To Console   ProductRelName: ${ProductRelName}
    Log To Console   PackageName: ${PackageName}
    Log To Console   DomainName: ${DomainName}

NetAct Only Common Teardown
    Run Keyword And Ignore Error   selenium_netact.disable_virtual_display

Common Case Setup
    All Wait GNB Startup
    Set Test Variable    ${SETUP_PASS}    ${true}
    # All Check Active Alarms
    # Check no Alarm on NetAct Backend

Common Case Teardown
    # Check no Alarm on NetAct Backend
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error    selenium_coam.close_browser

