*** Settings ***
Documentation   author: Heng Liangliang
   ...   test cases for CB007732

Resource   Resource/Common.robot
Library   Telnet

Suite Setup   Common Suite Setup for 7732
Suite Teardown   Common Teardown for 7732

*** Variables ***
${abil_index}      1


*** Test Cases ***
[1]CB007732-5G-A-01_Activation_of_the_Subscriber_Trace_Content_via_Feature_Flag
#      [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=8000
      [Setup]   robot_common_operations.Common Case Setup   allowed_faults_ids=8000
      AlarmWatchdog.add_allow_alarms    fault_id=7305
      AlarmWatchdog.add_allow_alarms    fault_id=7304
      ${release}   Get gnb release   host=${WEBUI_ADDR}
      ${all_subscriber_trace}   Set Variable If   '${release}'<='SBTS24R1'  ${add_all_subscriber_trace}   ${add_all_subscriber_trace_new}
      ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
      Restart WTS on UTE VM
      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
      Log to console    COAM Remove All Trace Object
      COAM Remove All Trace Object
      Log to console    COAM Ensure Existence of Basic Trace Object
      COAM Ensure Existence of Basic Trace Object
      Log to console     COAM Add Trace Related Object
      COAM Add Trace Related Object    add_trace_para=${all_subscriber_trace}
      Log to console     COAM Update Trace Related Flag
      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
      FOR   ${index}    IN RANGE    1   3
          UE precondition   ue_index=0
          sleep  20s
          Log to console    power_ue.UE Attach
          power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
          Telnet.Open Connection   host=127.0.0.1    port=20000    alias=EGATE
          UE Status Checking
          Trace Start
          sleep   10s
          power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
          sleep   10s
      END
      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
      ${target_file}   Get Test Json File
      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
      [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
      ...   AND   Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed

[1]CB007732-5G-B-01_Deactivation_of_the_Subscriber_Trace_Content_via_Feature_Flag
#      [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=8000
      [Setup]   robot_common_operations.Common Case Setup   allowed_faults_ids=8000
      AlarmWatchdog.add_allow_alarms    fault_id=7305
      AlarmWatchdog.add_allow_alarms    fault_id=7304
      ${release}   Get gnb release   host=${WEBUI_ADDR}
      ${all_subscriber_trace}   Set Variable If   '${release}'<='SBTS24R1'  ${add_all_subscriber_trace}   ${add_all_subscriber_trace_new}
#      Recover WTS If Issue Occurred
      Restart WTS on UTE VM
      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
      COAM Remove All Trace Object
      COAM Ensure Existence of Basic Trace Object
      COAM Add Trace Related Object     add_trace_para=${all_subscriber_trace}
      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
      UE precondition   ue_index=0
      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
      Trace Start
      sleep  20s
      #Wait Until Keyword Succeeds   10m   1m   Check Session Setup   setup=${true}
      COAM Update Trace Related Flag     flag=false    trace_type=actSubscriberTraceReport
      sleep  5s
      #Wait Until Keyword Succeeds   10m   1m    Check Session Setup   setup=${false}
      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
      ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
      COAM Update Trace Related Flag     flag=true   trace_type=actSubscriberTraceReport
      Restart WTS on UTE VM
      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
      UE precondition   ue_index=0
      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
      Trace Start
      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
      ${target_file}   Get Test Json File
      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
      [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
      ...   AND   Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed

[1]CB007732-5G-A-16_Activation_of_the_Subscriber_Trace_Content_via_Feature_Flag_by_Initial_Context_Setup
#      [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=8000
      [Setup]   robot_common_operations.Common Case Setup   allowed_faults_ids=8000
      AlarmWatchdog.add_allow_alarms    fault_id=7305
      AlarmWatchdog.add_allow_alarms    fault_id=7304
      ${release}   Get gnb release   host=${WEBUI_ADDR}
      ${all_subscriber_trace}   Set Variable If   '${release}'<='SBTS24R1'  ${add_all_subscriber_trace}   ${add_all_subscriber_trace_new}
#      Recover WTS If Issue Occurred
      Restart WTS on UTE VM
      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
      COAM Remove All Trace Object
      COAM Ensure Existence of Basic Trace Object
      COAM Add Trace Related Object     add_trace_para=${all_subscriber_trace}
      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
      UE precondition   ue_index=0
      Initial Context Setp Request
      FOR   ${index}   IN RANGE   ${3}
            Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
            power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
            #Attach UE and Detach   ue_index=0
            #Attach UE BETA   ue_index=0
            sleep  20s
            #Wait Until Keyword Succeeds   10m   1m   Check Session Setup   setup=${true}
            #Detach UE BETA   ue_index=0
            #power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
            #sleep  10s
            power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
      END
      Stop Subscriber trace for ICS
      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
      ${target_file}   Get Test Json File
      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
      [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown
      ...   AND   Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed

#[1]CB007732-5G-C-02_Deactivation_of_TLS_Support_for_Subscriber_Trace_Content
#      [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#      AlarmWatchdog.add_allow_alarms    fault_id=7304
#      AlarmWatchdog.add_allow_alarms    fault_id=7305
#      ${release}   Get gnb release   host=${WEBUI_ADDR}
#      ${all_subscriber_trace}   Set Variable If   '${release}'<='SBTS24R1'  ${add_all_subscriber_trace}   ${add_all_subscriber_trace_new}
#      ${all_subscriber_trace_tls}   Set Variable If   '${release}'<='SBTS24R1'  ${add_all_subscriber_trace_tls}   ${add_all_subscriber_trace_tls_new}
#      Config TLS on DCAP    flag=enable
#      Recover WTS If Issue Occurred
##      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
##      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
##      AlarmWatchdog.remove_allow_alarms    fault_id=7304
##      AlarmWatchdog.remove_allow_alarms    fault_id=7305
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${all_subscriber_trace_tls}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      #COAM Update TLS Flag for Subscriber Trace    flag=true
#      UE precondition   ue_index=0
#      Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      sleep  20s
#      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      UE Status Checking
#      #Detach UE BETA
#      Sleep  20s
#      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${all_subscriber_trace}
#      #Wait Until Keyword Succeeds   5m   1m   Check Session Setup   setup=${false}
#      Config TLS on DCAP    flag=disable
#      Log to console    start egate again......
#      Connet to WTS VM
#      Kill egate and edaemon
#      Start WTS on UTE     WTS_CFG=${WTS_CFG}
#      Check NG link Up
#      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
#      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
##      AlarmWatchdog.remove_allow_alarms    fault_id=7304
##      AlarmWatchdog.remove_allow_alarms    fault_id=7305
#      UE precondition   ue_index=0
#      sleep  20s
#      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      UE Status Checking
#      #Wait Until Keyword Succeeds   5m   1m   Check Session Setup   setup=${true}
#      #Detach UE BETA
#      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#      [Teardown]   Run Keywords   Run Keyword And Ignore Error   Config TLS on DCAP    flag=disable
#      ...   AND   robot_common_operations.Common Case Teardown
#      ...   AND   Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed


#[1]CB007732-5G-Cell_Trace_and_PCMD_CU_DU_TCE_Migration_From_One_Dcap_to_Other_One_Exploratory_Test
#      [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#      AlarmWatchdog.add_allow_alarms    fault_id=7304
#      AlarmWatchdog.add_allow_alarms    fault_id=7305
#      COAM Reset Site
#      Wait Until Keyword Succeeds   10m   1m   COAM Check BTS OnAir
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      FOR   ${retry}    IN RANGE    ${10}
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add PCMD CU DU and Cell Trace   tce_id=1
#      COAM Remove PCMD CU DU and Cell Trace
#      #Wait Until Keyword Succeeds   3x   30s   Check Session Setup for EDA   setup=${false}   tce_id=1
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add PCMD CU DU and Cell Trace   tce_id=2
#      COAM Remove PCMD CU DU and Cell Trace
#      #Wait Until Keyword Succeeds   3x   30s   Check Session Setup for EDA   setup=${false}   tce_id=2
#      END
#      [Teardown]   robot_common_operations.Common Case Teardown


#[1]CB007732-5G-B-02_Deactivation_of_the_Subscriber_Trace_Recording_Session_via_NG-C_interface
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=false    trace_type=actSubscriberTraceReport
#      ${emil_last_file}   Get Latest Trace File Name By BTSID
##      Call Setup and check tput   duration=60   tput=100   tput_expect=10   4G_check=false
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      Trace Start
#      sleep  5s
#      Trace Stop
#      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      Check Session Setup   setup=${false}
#      ${emil_last_file}   Get Latest Trace File Name By BTSID
#      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      Trace Start
#      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}

#[1]CB007732-5G-A-03_Activation_of_the_Subscriber_Trace_Content_with_Default_TCE_Defined
#      ${emil_last_file}   Get Latest Trace File Name By BTSID     default_tce=${true}
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${add_default_tce_para}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
#      Initial Context Setp Request    tce_ip=0.0.0.0
#      Attach UE and Detach   ue_index=0
#      UE Status Checking
#      Stop Subscriber trace for ICS
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}     default_tce=${true}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
##
#[1]CB007732-5G-A-04_Activation_of_the_Subscriber_Trace_Content_with_Default_TCE_Applied_for_AllSessions
#      ${emil_last_file}   Get Latest Trace File Name By BTSID     default_tce=${true}
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${add_default_tce_para_for_allsession}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start   tce_ip=0.0.0.0
#      UE Status Checking
#      Detach UE BETA
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}     default_tce=${true}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      Check Session Setup   setup=${false}


#[1]CB007732-5G-A-05_Failed_Activation_of_the_Subscriber_Trace_Content_without_Valid_Ipaddr_no_Default_TCE
#      ${emil_last_file}   Get Latest Trace File Name By BTSID     default_tce=false
#      ${emil_last_file_default}   Get Latest Trace File Name By BTSID     default_tce=true
#      COAM Remove All Trace Object
#      COAM Add Subscriber Trace Object
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Trace Start    tce_ip=0.0.0.0
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}     default_tce=false
#      ${txt_file_default}   Get Txt File from Emil    emil_last_file=${emil_last_file_defult}     default_tce=true
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#      check_target_message_all_matched   source_file=${txt_file_default}    target_file=${target_file}
#
#[1]CB007732-5G-A-06_No_New_Trace_Session_Activation_of_the_Subscriber_Trace_Content_for_Same_Trace_Reference_for_Same_UE
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      UE Status Checking
#      Trace Start
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      Detach UE BETA
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}


#[1]CB007732-5G-A-07_No_New_Trace_Session_Activation_of_the_Subscriber_Trace_Content_for_Same_Trace_Reference_for_the_other_UE
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
#      UE precondition   ue_index=1
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Wait Until Keyword Succeeds   3x   20s   Attach UE BETA   ue_index=0
#      Wait Until Keyword Succeeds   3x   20s   Attach UE BETA   ue_index=1
#      Trace Start
#      Start then Stop Android UE L3 Call with core-sim without Attach   ue_index=0   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Start   id=2
#      Start then Stop Android UE L3 Call with core-sim without Attach   ue_index=1   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      Detach UE BETA    ue_index=0
#      Detach UE BETA    ue_index=1
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}


#[1]CB007732-5G-A-08_Alarm_Checking_In_Case_Of_TCP_link_loss_with_TCE
#      [Setup]   robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#      AlarmWatchdog.add_allow_alarms    fault_id=7304
#      AlarmWatchdog.add_allow_alarms    fault_id=7305
#      ${release}   Get gnb release   host=${WEBUI_ADDR}
#      ${all_subscriber_trace_tls}   Set Variable If   '${release}'<='SBTS24R1'  ${add_all_subscriber_trace_tls}   ${add_all_subscriber_trace_tls_new}
#      Config TLS on DCAP    flag=enable
#      COAM Update TLS Flag for Subscriber Trace    flag=true
#      Recover WTS If Issue Occurred
##      Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
##      Wait Until Keyword Succeeds   5m   1m   COAM Check BTS OnAir
##      AlarmWatchdog.remove_allow_alarms    fault_id=7304
##      AlarmWatchdog.remove_allow_alarms    fault_id=7305
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${all_subscriber_trace_tls}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
#      sleep  20s
#      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      UE Status Checking
#      #Detach UE BETA
#      #Wait Until Keyword Succeeds   5m   1m   Check Session Setup   setup=${true}
#      Tracer Connection Operation    action=stop
#      Wait Until Keyword Succeeds   5m   30s   COAM Check Fault 8000 Exists
#      Tracer Connection Operation    action=start
#      Wait Until Keyword Succeeds   5m   30s  COAM Check Fault 8000 Exists   should_exist=${false}
#      Config TLS on DCAP    flag=disable
#      Wait Until Keyword Succeeds   5m   30s   COAM Check Fault 8000 Exists
#      Config TLS on DCAP    flag=enable
#      Wait Until Keyword Succeeds   5m   30s  COAM Check Fault 8000 Exists   should_exist=${false}
#
#      [Teardown]  Run Keywords  Run Keyword And Ignore Error   power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ...    AND   Run Keyword And Ignore Error   Config TLS on DCAP    flag=disable
#      ...    AND   robot_common_operations.Common Case Teardown
#      ...   AND   Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed
#

#[1]CB007732-5G-A-09_Activation_of_the_Subscriber_Trace_Content_when_Cell_Trace_and_PCMD_activated
#      Log to Console    will check Subscriber trace and cell trace
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      COAM Add Trace Related Object     add_trace_para=${add_cell_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actCellTraceReport
#      COAM Update Trace Related Flag     flag=false    trace_type=actPCMDReport
#      Initial Context Setp Request
#      Call Setup and check tput   duration=60   tput=100   tput_expect=10   4G_check=false
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
##      sleep  10s
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#      Log to Console    will check Subscriber trace and PCMD
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      COAM Add Trace Related Object     add_trace_para=${add_pcmd}
#      COAM Update Trace Related Flag     flag=false    trace_type=actCellTraceReport
#      COAM Update Trace Related Flag     flag=true    trace_type=actPCMDReport
#      Initial Context Setp Request
#      Call Setup and check tput   duration=60   tput=100   tput_expect=10   4G_check=false
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
##      sleep  10s
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#      Log to Console    will check Subscriber trace and cell trace and PCMD
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Update Trace Related Flag     flag=true    trace_type=actCellTraceReport
#      COAM Update Trace Related Flag     flag=true    trace_type=actPCMDReport
#      COAM Add Trace Related Object     add_trace_para=${add_cell_trace_and_pcmd}
#      Initial Context Setp Request
#      Call Setup and check tput   duration=60   tput=100   tput_expect=10   4G_check=false
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
##      sleep  10s
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#
#[1]CB007732-5G-A-17_Activation_of_the_Subscriber_Trace_Content_AMF_Status_Indication
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
#      COAM Add Trace Related Object      add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      COAM Update Trace Related Flag     flag=true    trace_type=actAmfPlannedRemoval
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      AMF Status Indication
#      UE Tnla Binding Release Request
#      UE Status Checking
##      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      Detach UE BETA
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#      [Teardown]   Case Teardown for CB007732-5G-A-17
#
#
#[1]CB007732-5G-A-18_Activation_of_the_Subscriber_Trace_Content_Location_Report
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
#      COAM Add Trace Related Object      add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      COAM Update Trace Related Flag     flag=true    trace_type=actLocationReportingSA
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      Location Reporting Control
#      UE Status Checking
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      Detach UE BETA
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#[1]CB007732-5G-A-12_Add_Cell_and_Cellgrp_Online_after_Activation_of_Subscribe_Trace_Content_via_Feature_Flag
#
#
#[1]CB007732-5G-A-02_Activation_of_the_Subscriber_Trace_Content_via_Inter-gNB_Handover
#    COAM Remove All Trace Object
#    COAM Ensure Existence of Basic Trace Object
#    ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
#    COAM Add Trace Related Object      add_trace_para=${add_all_subscriber_trace}
#    Get HO Suite Variables
#    Trigger INTER gNB HO
#    ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#    ${target_file}   Get Test Json File
#    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#    [Teardown]   Case Teardown for CB007732-5G-A-02
#
#
#[1]CB007732-5G-A-13_Activation_of_the_Subscriber_Trace_Content_via_Intra-gNB_Handover
#    COAM Remove All Trace Object
#    COAM Ensure Existence of Basic Trace Object
#    ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
#    COAM Add Trace Related Object      add_trace_para=${add_all_subscriber_trace}
#    Get HO Suite Variables
#    Trigger INTRA gNB HO
#    ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#    ${target_file}   Get Test Json File
#    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#    [Teardown]   Case Teardown for CB007732-5G-A-13
#
#
#[1]CB007732-5G-A-15_Activation_of_the_Subscriber_Trace_Content_via_Inter-gNB_Handover_via NG-C
#    COAM Remove All Trace Object
#    COAM Ensure Existence of Basic Trace Object
#    ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
#    COAM Add Trace Related Object      add_trace_para=${add_all_subscriber_trace}
#    Get HO Suite Variables
#    COAM NG HO
#    Trigger INTER gNB HO NG
#    ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#    ${target_file}   Get Test Json File
#    check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#    [Teardown]   Case Teardown for CB007732-5G-A-15
#
#
#[1]CB007732-5G-A-14_Activation_of_the_Subscriber_Trace_Content_in_case_of_Multiple_Trace_Sessions    _not_debug
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
##      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      AMF Disp Trace Info   id=1
#      UE Status Checking
#      Trace Start   trace_ref_id=2
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      Detach UE BETA
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#
#[1]CB007732-5G-A-20_Activation_of_the_Subscriber_Trace_Content_Delete_NRSTRACE     _not_debug
#      ${emil_last_file}   Get Latest Trace File Name By BTSID    default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
#      UE Status Checking
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      COAM Remove NRSTRACE
#      Trace Start
#      UE Status Checking
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      Detach UE BETA
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#
#[1]CB007732-5G-A-19_Activation_of_the_Subscriber_Trace_Content_in_case_of_Multiple_Trace_Recording_Sessions     _not_debug
#      COAM Remove All Trace Object
#      COAM Ensure Existence of Basic Trace Object
#      ${emil_last_file}   Get Latest Trace File Name By BTSID      default_tce=${false}
#      COAM Add Trace Related Object     add_trace_para=${add_all_subscriber_trace}
#      COAM Update Trace Related Flag     flag=true    trace_type=actSubscriberTraceReport
#      UE precondition   ue_index=0
##      Attach and Retry if Failed   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}   4G_check=false
#      Attach UE and Detach   ue_index=0
#      Attach UE BETA   ue_index=0
#      sleep  20s
##      power_ue.UE Attach   ue_type=${ue_${ue_index}_type}    ue_index=${ue_index}    abil_index=${abil_index}
#      UE Status Checking
#      Trace Start
##      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      AMF Disp Trace Info   id=1
#      UE Status Checking
#      Trace Start   trace_rec_session_ref_id=2
#      Start then Stop Android UE L3 Call with core-sim without Attach   duration=60   tput=100   tput_expect=10   4G_check=false
#      Trace Stop
#      Detach UE BETA
##      power_ue.UE Detach   ue_type=${ue_${ue_index}_type}   ue_index=${ue_index}
#      ${txt_file}   Get Txt File from Emil    emil_last_file=${emil_last_file}   default_tce=${false}
#      ${target_file}   Get Test Json File
#      check_target_message_all_matched   source_file=${txt_file}    target_file=${target_file}
#
#
##[1]CB007732-5G-B-03_Deactivation_of_the_Subscriber_Trace_Recording_Session_via_NG-C_interface_with_HO
##[1]CB007732-5G-B-02_Deactivation_of_the_Subscriber_Trace_Recording_Session_via_NG-C_interface