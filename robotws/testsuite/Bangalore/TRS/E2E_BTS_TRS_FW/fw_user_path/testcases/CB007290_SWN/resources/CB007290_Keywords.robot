*** Settings ***

Documentation

...        [Procedure]        "TRS_CB007290_alarm_MacSec_connection_lost_alarm_verification_and_connection_restablishment_and_counter_verification"
...        [Date]             "05-03-2024"
...        [Author]           "Harsimran"
...        [Feature_ID]       "CB007290"
...        [Maintenance]      "TRS I & V Tools Bangalore Team"
...        [Funtion_Hash_Tags] "MacSec"
...        [Validated_TestLine]     "IAV_BLR_2020"
...        [Config_Comments]         "MacSec establishment"
...        [Precondition]             "ENodeB should be integrated to Netact"

*** keywords ***

Preconditions
    Perform Commissioning       scf_file=${Master_SCF}      wait_for_bts_to_be_ready=400        verify_bts_status=True     alias=default
    sleep   200
    Setup Ems  config_device=netact2005   alias=lab2005
    Cm Upload   config_device=netact2005        alias=lab2005

Perform BBMOD Reset and verify BTS status
    Reset    operation=reset_unit   dist_name=${BBMOD}    reset_type=Warm     verify_bts=True     timeout=600
    sleep   90
    Verify MacSec Connection Lost alarm in history

Perform BTS site Reset and verify macsec status should be established
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Reset_Bts    verify_bts_status=${True}     should_be_onair=${True}
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS
    sleep   60


Verify actEcpriRuMPlaneSecurity paremeter should be enabled
    ${actEcpriRuMPlaneSecurity}    Get Parameter   param_path=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1:actEcpriRuMPlaneSecurity
    Should Be RuProtectEnabled    ${actEcpriRuMPlaneSecurity}

Verify actLbmOnFronthaul paremeter should be enabled
   ${actLbmOnFronthaul}    Get Parameter   param_path=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1:actLbmOnFronthaul
    Should Be true    ${actLbmOnFronthaul}


Verify FH IPSEC status for RuProtectEnabled
    Setup Remote Access   remote_device=mplane     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=${lxc}   alias=session
    ${stdout_2}          Execute Interactive Remote Command    command=ipsec status | grep 1M204902600   alias=session
    Should contain       ${stdout_2}        ESTABLISHED

    [Teardown]     Teardown remote Access         alias=session

Verify FH IPSEC status for RuProtectoptional
    Setup Remote Access   remote_device=mplane     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=${lxc}   alias=session
    ${stdout_3}          Execute Interactive Remote Command    command=ipsec status | grep 1M204902600   alias=session
    Should contain       ${stdout_3}        ESTABLISHED
    [Teardown]     Teardown remote Access         alias=session


Verify MacSec session is up
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Verify Bts Status   req_rat=nr  should_be_onair=${True}
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS

Enable MACSecWithPSKNoMPlane and Verify MacSec session is up
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Perform Recommissioning     type=delta      delta_file=${Enable_macsec_split-A}        skip_parameter_relation_errors=False     timeout=600
    sleep  500
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS
    Verify Bts Status   req_rat=nr  should_be_onair=${True}

Enable MACSecWithPSK and Verify MacSec session is success
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Perform Recommissioning         type=param          rat=5g          param_path=MNLENT-1/FEATCADM-1:actEcpriMacSecTraffic         operation=update
    ...    value=MACSecWithPSK      timeout=300
    sleep  500
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS
    Verify Bts Status   req_rat=nr  should_be_onair=${True}

Modify macSecProtectionMode to intigrity and verify macsec session is success
    Start Syslog        ${Syslog_path}      CB007290_syslog.txt      alias=default_1
    Perform Recommissioning     type=delta      delta_file=${protectmodeintegrity}        skip_parameter_relation_errors=False     timeout=900
    sleep   500
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS
    Verify Bts Status   req_rat=nr  should_be_onair=${True}

Configure Wrong cipher suite
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Perform Recommissioning     type=delta      delta_file=${wrongcipersuite}        skip_parameter_relation_errors=False     timeout=600
    sleep   500
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSETUP_FAILURE
    Verify Bts Status   req_rat=nr  should_be_onair=${True}

Revert cipersuite value
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Perform Recommissioning     type=delta      delta_file=${revert_wrongcipersuite}        skip_parameter_relation_errors=False     timeout=600
    sleep   500
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS
    Verify Bts Status   req_rat=nr  should_be_onair=${True}

Verify MacSec Connection Lost alarm in history
   ${output}=   Verify Alarm      alarm_type=history    fault_id=61668   should_exist=${True}   occurrences=1

Verify MacSec Connection Setup Failure alarm
   ${output}=   Verify Alarm      fault_id=61667        should_exist=${True}   occurrences=1

verify MacSec Connection Setup Failure alarm should not exist
    Verify Alarm      fault_id=61667      should_exist=${False}

verify No connection to unit alarm should exist
    Verify Alarm      fault_id=10      should_exist=${True}

Verify MacSec Connection lost alarm
   ${output}=   Verify Alarm      fault_id=61668        should_exist=${True}   occurrences=1

Poweroff_AEQE
	[Arguments]     ${RRB}	${port}
	Setup Remote Access		remote_device=${RRB}
	Remote Command Execute		command=gpio write ${port}s 0
	sleep	200
	[Teardown]	Teardown Remote Access

Poweron_AEQE
    sleep   200
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access     remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 1
    [Teardown]  Teardown Remote Access

Verify_MacSec_counters
    [Arguments]     ${macSecProtectionMode}
    Start Netact Pm Counters    config_device=netact2005         alias=lab2005    pm_interval=15
    Sleep   90
    Verify Netact Pm Counters    config_device=netact2005        analysis=${macSecProtectionMode}    counter_analysis_file=${macsec_counters}
    ...    alias=lab2005     pm_interval=15

Verify_MacSec_counters_integrity
    [Arguments]     ${macSecProtectionMode}
    Start Netact Pm Counters    config_device=netact2005         alias=lab2005    pm_interval=15
    Sleep   90
    Verify Netact Pm Counters    config_device=netact2005        analysis=${macSecProtectionMode}
    ...    counter_analysis_file=${macsec_counters_integrity}    alias=lab2005     pm_interval=15

Change actEcpriRuMPlaneSecurity as RuProtectOptional
    Perform Recommissioning     type=delta      delta_file=${RUOptional}        skip_parameter_relation_errors=False     timeout=600
    sleep   700
    Verify FH IPSEC status for RuProtectoptional
    Verify Bts Status   req_rat=nr  should_be_onair=${True}


Enable FH Firewall
    Perform Recommissioning     type=delta      delta_file=${FHFirewall}        skip_parameter_relation_errors=False     timeout=600
    sleep   700

Enable actLbmOnFronthaul
    Configuration Manage  config_device=netact1    config=${actLbmOnFronthaul}             plan_name=fw_plan       delete_plan=${True}
    ...        alias=lab1042   operation=edit
    sleep   900
    Enable MacSec and Verify MacSec session is up
    Verify Loopback msg and reply


Enable actEcpriMPlaneResilience and verify routes in FHNET and BBMOD
    Start Syslog        ${Syslog_path}       CB007290_syslog.txt      alias=default_1
    Perform Recommissioning     type=delta      delta_file=${actEcpriMPlaneResilience}        skip_parameter_relation_errors=False     timeout=600
    sleep   300
    Stop Syslog     alias=default_1
    ${output}=    Run       ${macsec}
    Should contain       ${output}        SMACSECCONNSTATUS_SETUPSUCCESS
    Verify FHNET Routes
    Verify BBMOD Routes


Verify Loopback msg and reply
     sleep  60
     Setup Remote Access   remote_device=bts     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=bsh 2:1   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_4}          Execute Interactive Remote Command    command=ifconfig   alias=session
     Log    ${stdout_4}
     ${stdout_3}          Execute Interactive Remote Command    command=timeout 20 tcpdump -i rfoe3 -XX -e -n | grep -i cfm    alias=session
     Should contain       ${stdout_3}   CFMv0 Loopback Message
     Should contain       ${stdout_3}   CFMv0 Loopback Reply
     ${stdout_5}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=exit   alias=session
     [Teardown]     Teardown remote Access         alias=session


Verify FHNET Routes
    Setup Remote Access   remote_device=bts     alias=session
    ${stdout_1}          Execute Interactive Remote Command    command=lxc-attach -n 0x1018   alias=session
    ${stdout_2}          Execute Interactive Remote Command    command=ip r s   alias=session
    Should contain       ${stdout_2}        15.1.1.1 via 172.21.0.9 dev rlan0.ecpri metric 1
    Should contain       ${stdout_2}        15.1.1.1 via 172.21.0.8 dev rlan0.ecpri metric 2
    Should contain       ${stdout_2}        100.100.100.0/30 via 172.21.0.8 dev rlan0.ecpri metric 1
    Should contain       ${stdout_2}        100.101.100.0/30 via 172.21.0.9 dev rlan0.ecpri metric 1
    [Teardown]     Teardown remote Access         alias=session


Verify BBMOD Routes
     Setup Remote Access   remote_device=bts     alias=session
     ${stdout_1}          Execute Interactive Remote Command    command=bsh 3:1   alias=session
     ${stdout_2}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_3}          Execute Interactive Remote Command    command=ip r s   alias=session
     Should contain       ${stdout_3}    15.1.1.1 via 100.100.100.2 dev rfoe1.200 metric 2
     ${stdout_4}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_5}          Execute Interactive Remote Command    command=exit   alias=session
     ${stdout_6}          Execute Interactive Remote Command    command=bsh 3:2   alias=session
     ${stdout_7}          Execute Interactive Remote Command    command=ip netns exec radions bash   alias=session
     ${stdout_8}          Execute Interactive Remote Command    command=ip r s   alias=session
     Should contain       ${stdout_8}    15.1.1.1 via 100.101.100.2 dev rfoe4.100 metric 1
    [Teardown]     Teardown remote Access         alias=session

Verify Macsec counters for confidentiality and integrity
    Pm Counters Start       analysis=verify_macsec_counters_integrity_confidentiality        counter_analysis_file=${integr_confid}
    ...        pm_interval=5
    sleep   100
    Verify Pm Counters       analysis=verify_macsec_counters_integrity_confidentiality        counter_analysis_file=${integr_confid}
    ...        pm_interval=5

Verify Macsec counters for interity only
    Pm Counters Start       analysis=verify_macsec_counters_integrity        counter_analysis_file=${integrity}        pm_interval=5
    sleep   100
    Verify Pm Counters       analysis=verify_macsec_counters_integrity        counter_analysis_file=${integrity}        pm_interval=5

Pre-reset alarms
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length  ${pre_reset_alarms}
    ${pre_alarm_faultids}=  Create List
    ${pre_alarm_faultids}=  Create fault id List    ${pre_reset_alarms}
    Set Suite Variable      ${pre_alarm_faultids}       ${pre_alarm_faultids}

Create fault id List
    [Arguments]     ${list}
    ${length}=  Get Length  ${list}
    ${list1}=   Create List
    FOR   ${i}    IN RANGE    ${length}
           Append To List  ${list1}    ${list[${i}]['faultId']}
    END
    [return]    ${list1}


Post-reset alarms
    ${post_reset_alarms}=   Verify Alarm    alarm_type=active
    ${post_reset_length}=   Get Length  ${post_reset_alarms}
    ${post_alarm_faultids}=  Create fault id List    ${post_reset_alarms}
    ${alarms_post_reset}=   Fault list after reset  ${pre_alarm_faultids}   ${post_alarm_faultids}
    Set Suite Variable      ${post_alarm_faultids}       ${post_alarm_faultids}
    Set Suite Variable      ${post_reset_length}        ${post_reset_length}

Fault list after reset
    [Arguments]     ${pre_alarm_faultids}   ${post_alarm_faultids}
    ${list}=    Create List
    FOR   ${i}    IN      @{post_alarm_faultids}
          Run Keyword If  ${i} in ${pre_alarm_faultids}   Continue For Loop
          Append To List  ${list} ${i}
    END
    [return]    ${list}

Verify alarms in list
    FOR   ${i}   IN RANGE   ${post_reset_length}
          Run Keyword If   ${post_alarm_faultids}[${i}] not in ${pre_alarm_faultids}   Fail   msg=Check Logs
    END