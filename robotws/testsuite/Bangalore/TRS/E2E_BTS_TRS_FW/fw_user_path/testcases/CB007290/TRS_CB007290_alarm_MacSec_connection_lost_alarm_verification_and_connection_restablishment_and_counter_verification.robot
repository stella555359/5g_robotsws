

*** Settings ***



Documentation

...        [Procedure]        "TRS_CB007290_alarm_MacSec_connection_lost_alarm_verification_and_connection_restablishment_and_counter_verification"
...        [Date]             "05-03-2024"
...        [Author]           "Harsimran"
...        [Feature_ID]       "CB007290"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "MacSec"
...        [DELTA_FILE_DEPENDENCY]  ""
...        [Validated_TestLine]     "IAV_BLR_2020"
...        [Config_Comments]         "MacSec establishment"
...        [Precondition]             "ENodeB should be integrated to Netact"

variables      ta_e2e_bts_trs_fw
Resource       taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops

Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops




***Test Cases***

TRS_CB007290_alarm_MacSec_connection_lost_alarm_verification_and_connection_restablishment_and_counter_verification
  Perform Commissioning       scf_file=${CB007290_basic_config}     verify_bts_status=${True}     timeout=900     alias=default
  Setup Ems  config_device=netact2005   alias=lab2005
  Cm Upload   config_device=netact2005	alias=lab2005
  sleep  300
  Pre-reset alarms
  Verify MacSec session is up    A
  sleep  300
  Post-reset alarms
  Verify alarms in list
  Verify_MacSec_counters   verify_macsec_integrity&confidentiality
  Verify MacSec session is up    B
  Verify_MacSec_counters   verify_macsec_integrity&confidentiality
   Perform Commissioning       scf_file=${Configure_wrong_RU_port}     verify_bts_status=${False}     timeout=300     alias=default
   sleep  400
   Verify MacSec Connection Setup Failure alarm
   Perform Commissioning       scf_file=${CB007290_basic_config}     verify_bts_status=${True}     timeout=900     alias=default
   Verify MacSec session is up    B
   Poweroff_AVQL     AVHQB_RRB       5
   Verify MacSec Connection Lost alarm in history
   Poweron_AVQL      AVHQB_RRB       5
   Verify_MacSec_counters   verify_macsec_integrity&confidentiality
   sleep  400
   Pre-reset alarms
   Configuration Manage  config_device=netact2005    config=${Configure_macSecProtectionMode_Integrity}          delete_plan=${True}
   ...  alias=lab2005     operation=update
   sleep  300
   Post-reset alarms
   Verify alarms in list
   Verify Bts Status
  Verify_MacSec_counters   verify_macsec_integrity
  Change actEcpriRuMPlaneSecurity as RuProtectOptional
   Enable FH Firewall
  Enable actLbmOnFronthaul
  [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005





***Keywords***

Verify MacSec session is up
  [Arguments]     ${split}
  Start Syslog        /home/ute/fw_user_path/testcases/CB007290/Syslogs       CB007290_syslog_${split}.txt      alias=default_1
  Configuration Manage  config_device=netact2005    config=${Enable_macsec_split-${split}}          delete_plan=${True}
  ...   alias=lab2005     operation=update
  sleep  400
  Verify Bts Status   req_rat=nr  should_be_onair=${True}
  Stop Syslog     alias=default_1
  ${output}=    Run       cat Syslogs/CB007290_syslog_${split}.txt | grep -i smacsec | grep -i success
   Should contain       ${output}        SUCCESS


Verify MacSec Connection Lost alarm in history
   ${output}=   Verify Alarm      alarm_type=history    faultid=61668   should_exist=${True}   occurrences=2    load_history=True
   Log  ${output}
   ${len}=    Get Length      ${output}
   FOR   ${i}   IN RANGE   0   ${len}
        Run Keyword If    ${output}[${i}][faultId]==61668     Set Suite Variable         ${supp_info}     ${output}[${i}]
        ${supp_info}=     Exit For Loop If        ${output}[${i}][faultId]==61668
   END
   Log   ${supp_info}
   Should Contain       ${supp_info}[supplAlarmInfo]      ${61668_alarm_txt_as_per_NIDD}


Verify MacSec Connection Setup Failure alarm

    ${output}=   Verify Alarm      faultid=61667        should_exist=${True}   occurrences=1
   Log   ${output}
  ${len}=    Get Length      ${output}
   FOR   ${i}   IN RANGE   0   ${len}
        Run Keyword If    ${output}[${i}][faultId]==61667     Set Suite Variable         ${supp_info}     ${output}[${i}]
        ${supp_info}=     Exit For Loop If        ${output}[${i}][faultId]==61667
   END
   Log   ${supp_info}
   Should Contain       ${supp_info}[supplAlarmInfo]      ${61667_alarm_txt_as_per_NIDD}

Poweroff_AVQL
	[Arguments]     ${RRB}	${port}
	Setup Remote Access		remote_device=${RRB}
	Remote Command Execute		command=gpio write ${port}s 0
	sleep	120
	[Teardown]	Teardown Remote Access


Poweron_AVQL
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access     remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 1
   sleep   120
    [Teardown]  Teardown Remote Access

Verify_MacSec_counters
    [Arguments]     ${macSecProtectionMode}
    Start Netact Pm Counters    config_device=netact2005         alias=lab2005    pm_interval=5
    Sleep   90
   Verify Netact Pm Counters    config_device=netact2005        analysis=${macSecProtectionMode}    counter_analysis_file=${counter}
   ...  alias=lab2005     pm_interval=5




Change actEcpriRuMPlaneSecurity as RuProtectOptional
    Configuration Manage  config_device=netact2005    config=${RUOptional}             plan_name=fw_plan       delete_plan=${True}
    ...     alias=lab2005   operation=edit
    sleep   400
    Verify Bts Status    should_be_onair=${True}
    Verify_MacSec_counters   verify_macsec_integrity


Enable FH Firewall
    Configuration Manage  config_device=netact2005    config=${FHFirewall}                  plan_name=fw_plan       delete_plan=${True}
    ...     alias=lab2005   operation=edit
    sleep   400
    Verify Bts Status        should_be_onair=${True}
    Verify_MacSec_counters   verify_macsec_integrity

Enable actLbmOnFronthaul
    Configuration Manage  config_device=netact2005    config=${actLbmOnFronthaul}             plan_name=fw_plan       delete_plan=${True}
    ...     alias=lab2005   operation=edit
    sleep   400
    Verify Bts Status        should_be_onair=${True}
    Verify_MacSec_counters   verify_macsec_integrity



Pre-reset alarms
    ${pre_reset_alarms}=	Verify Alarm	alarm_type=active
    ${pre_reset_length}=	Get Length	${pre_reset_alarms}
    ${pre_alarm_faultids}=	Create List
    ${pre_alarm_faultids}=	Create fault id List	${pre_reset_alarms}
    Set Suite Variable      ${pre_alarm_faultids}       ${pre_alarm_faultids}

Post-reset alarms
    ${post_reset_alarms}=	Verify Alarm	alarm_type=active
    ${post_reset_length}=	Get Length	${post_reset_alarms}
    ${post_alarm_faultids}=	Create List
    ${post_alarm_faultids}=	Create fault id List	${post_reset_alarms}
    ${alarms_post_reset}=	Fault list after reset	${pre_alarm_faultids}	${post_alarm_faultids}
    Set Suite Variable      ${post_alarm_faultids}       ${post_alarm_faultids}
    Set Suite Variable      ${post_reset_length}        ${post_reset_length}

Verify alarms in list
    FOR   ${i}   IN RANGE   ${post_reset_length}
        Run Keyword If   ${post_alarm_faultids}[${i}] not in ${pre_alarm_faultids}   Fail   msg=Check Logs
    END


Create fault id List
	[Arguments]		${list}
	${length}=	Get Length	${list}
	${list1}=	Create List
	FOR	${i}	IN RANGE	${length}
		Append To List	${list1}	${list[${i}]['faultId']}
	END
	[return]	${list1}


Fault list after reset
	[Arguments]		${pre_alarm_faultids}	${post_alarm_faultids}
	${list}=	Create List
	FOR	${i}	IN		@{post_alarm_faultids}
		Run Keyword If	${i} in ${pre_alarm_faultids}	Continue For Loop
		Append To List	${list}	${i}
	END
	[return]	${list}
