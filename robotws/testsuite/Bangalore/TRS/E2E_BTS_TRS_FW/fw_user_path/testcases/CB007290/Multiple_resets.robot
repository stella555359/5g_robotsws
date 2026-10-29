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

TRS_CB007290_alarm_MacSec_connection_lost_alarm_verification_and_connection_multiple_resets

  Perform Commissioning       scf_file=${CB007290_basic_config_enabled}   verify_bts_status=${False}   timeout=900     alias=default
  Setup Ems  config_device=netact2005   alias=lab2005
  Cm Upload   config_device=netact2005     alias=lab2005
  Multiple BBMOD reset and check Macsec counters
  Multiple RMOD reset and check Macsec counters
  Muliple site resets
  Multiple rat reset and check Macsec counters
  [Teardown]  Teardown Ems  config_device=netact2005  alias=lab2005


***Keywords***

Check on-air status
    Verify Bts Status   should_be_onair=${True}

Multiple BBMOD reset and check Macsec counters
    Setup Remote Access    remote_device=bts     alias=session1
    FOR   ${i}   IN RANGE  2
         Pre-reset alarms
         Reset    operation=reset_unit   dist_name=${MRBTS}${bts_id}${BBMOD}    reset_type=Soft     timeout=300
         sleep   300
         Verify Bts Status
         sleep  300
         Post-reset alarms
         Verify alarms in list
        Verify_MacSec_counters   verify_macsec_integrity&confidentiality
    END
    Teardown Remote Access      alias=session1


Multiple RMOD reset and check Macsec counters
    Setup Remote Access   remote_device=bts     alias=session1
    FOR   ${i}   IN RANGE  2
            Pre-reset alarms
            Reset    operation=reset_unit   dist_name=${MRBTS}${bts_id}${RMOD}    reset_type=Soft     timeout=300
            Verify Bts Status
            sleep  300
            Post-reset alarms
            Verify alarms in list
           Verify_MacSec_counters   verify_macsec_integrity&confidentiality
   END
   Teardown Remote Access    alias=session1

Muliple site resets
    Setup Remote Access   remote_device=bts     alias=session1
    FOR   ${i}   IN RANGE  2
            Pre-reset alarms
            Reset_Bts       verify_bts=${True}     should_be_onair=${True}
            Post-reset alarms
            Verify alarms in list
            sleep   60
            Verify_MacSec_counters   verify_macsec_integrity&confidentiality
    END
    Teardown Remote Access         alias=session1

Multiple rat reset and check Macsec counters
    Setup Remote Access   remote_device=bts     alias=session1
    FOR   ${i}   IN RANGE   2
           Pre-reset alarms
           Reset   operation=reset_rat   rat=NR
           Verify Bts Status   req=nr      should_be_onair=${True}     wait_for=60     timeout=60      alias=default
           sleep  300
           Post-reset alarms
           Verify alarms in list
           Verify_MacSec_counters   verify_macsec_integrity&confidentiality
    END
    Teardown Remote Access         alias=session1

Verify_MacSec_counters
    [Arguments]     ${macSecProtectionMode}
    Start Netact Pm Counters    config_device=netact2005         alias=lab2005    pm_interval=5
    Sleep   90
   Verify Netact Pm Counters    config_device=netact2005        analysis=${macSecProtectionMode}    counter_analysis_file=${counter}
   ...  alias=lab2005    pm_interval=5



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

