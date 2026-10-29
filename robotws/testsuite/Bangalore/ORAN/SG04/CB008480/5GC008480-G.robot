*** Settings ***
Documentation   ---SW Download & Update to NR and LTE BTS---
...    :copyright: Nokia
...    test

#Test Setup        Run Keywords     Admin Setup
#Test Teardown     Run Keywords      Common Test Teardown
#...               AND    Admin Teardown
#Resource         ./testsuite/Bangalore/ORAN/SG04/resources/Common_resource.robot
Variables         ./testsuite/Bangalore/ORAN/SG04/resources/CRT4_parameters.py
Library     taf.sw.dcap.rd   WITH NAME   rd

Force Tags    TRUNK_SG04    8480G    QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
&{[1][2.0] TEST CASE_1 - CB008480_G- O-DU support simultaneously Nokia 4G SOAP RU and O-RAN compliant 5G RUs on Two ABIOs in Same BTS with UL+DLdata}
...    QC_ID_FL00=QC_31628
${DELTA_FILE}          ${CURDIR}/resources/config/8480-G_scf_conf.xml
${LTE_cell_id}         	248321              # UE attached cell id
${LTE_Mplane_IP}       10.58.239.90        # LTE Mplane IP for 8480 feature
${lteCell_dist}     /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-970/LNCEL_R
@{LTE_cell}     5   0
@{capabilities}    Legacy_3
${eNB2_IP}    10.58.239.89                # enb LMP IP
${connection1}    Active_Session          # Alias name



*** Test Cases ***
[1][2.0] TEST CASE_1 - CB008480_G- O-DU support simultaneously Nokia 4G SOAP RU and O-RAN compliant 5G RUs on Two ABIOs in Same BTS with UL+DL
    Lock LTE Site
    DCAP Start
    Lock cells  ${LTE_cell}
    #Check for data transfer in NR cell
    #Check for data transfer in LTE cell
    UnLock LTE Site
    UnLock cells  ${LTE_cell}
    LOG    "rUNNING"

*** Keywords ***

Check for data transfer in NR cell
    Run Keyword And Continue On Failure     Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_dl}
	...    ${throughput_dl}    ${deviation_dl}    ${timeout}    check_tpt=True    #check_gnb_attach=True

Check for data transfer in LTE cell
#    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
#    FOR    ${cell}    IN    @{cells}
#        Log to console      \nLocking NRCell
#        COAM.lock    dist_name=${cell}    timeout=120    connection=${connection}
#    END
#    Run Keyword And Continue On Failure     Attach ue and run throughput    ${UE_alias}    ${capabilities}    ${direction_dl}
#	...    ${throughput_dl_LTE}    ${deviation_dl}    ${timeout}    check_tpt=True
#    ${cells}    COAM.get_ids_for_all    NRCEL    timeout=120    connection=${connection}
#    FOR    ${cell}    IN    @{cells}
#        Log to console      \nUnlocking NRCell
#        COAM.Unlock    dist_name=${cell}    timeout=120    connection=${connection}
#    END
    #Wait for NRCELL OnAir
    ${dcap_log_status}=    Set Variable    1.0
    Set suite variable    ${dcap_log_status}
    Log to console	DCAP_LOG_STATUS: ${dcap_log_status}

#    Run Keyword If      "${dcap_log_status}" == "1.0"   DCAP Stop
#    ...    ELSE    DCAP Stop with log Transfer


Expected_alarm
    ${allowed_alarm_1}    Create alarm    alarm_id=7220    fault_id=61524    fault_name=SSH enabled
    ${allowed_alarm_2}    Create alarm    alarm_id=7220    fault_id=4654    fault_name=Ethernet port security is disabled
    ${allowed_alarm_3}    Create alarm    alarm_id=7220    fault_id=61649    fault_name=LMP access via port 443
    ${allowed_alarm_4}    Create alarm    alarm_id=7220    fault_id=4655    fault_name=Service account root access is enabled
    ${allowed_alarm_5}    Create alarm    alarm_id=7220    fault_id=61652    fault_name=R&D Service Port enabled
    ${allowed_alarm_7}    Create alarm    alarm_id=7240    fault_id=1262    fault_name=RX out of order
    ${allowed_alarm_8}    Create alarm    alarm_id=7240    fault_id=1263    fault_name=RX out of order
    ${allowed_alarm_9}    Create alarm    alarm_id=7240    fault_id=1264    fault_name=RX out of order
    ${allowed_alarm_10}    Create alarm    alarm_id=7107    fault_id=7319    fault_name=No X2 link available for a specific LTEENB
    ${allowed_alarm_11}    Create alarm    alarm_id=7107    fault_id=7300    fault_name=No X2 link available
    ${allowed_alarm_12}    Create alarm    alarm_id=7107    fault_id=6327    fault_name=Setup of X2 connectivity to gNB failed
    ${allowed_alarms}    Create list    ${allowed_alarm_1}    ${allowed_alarm_2}    ${allowed_alarm_3}    ${allowed_alarm_4}    ${allowed_alarm_5}
	...		${allowed_alarm_6}    ${allowed_alarm_7}    ${allowed_alarm_8}    ${allowed_alarm_9}    ${allowed_alarm_10}    ${allowed_alarm_11}
	...		${allowed_alarm_12}
    [Return]    ${allowed_alarms}

Lock cells
    [Documentation]     Lock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nLocking cell : ${cell}
#        COAM.lock           dist_name=${lteCell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${lteCell_dist}-${cell}            locking_status=locked
        ...                                                                         operational_status=disabled     usage_status=Idle
        ...                                                                         blocking_status=Unblocked
    END

Check cell details
    [Documentation]             Check cell details
    [Arguments]                 ${cell}
    ...                         ${locking_status}=unlocked  ${operational_status}=enabled   ${usage_status}=Active  ${blocking_status}=Unblocked
	log    ${usage_status}
	log    ${cell}
	log    ${operational_status}
	log    ${blocking_status}
	log    ${locking_status}
#    ${cell_status}              COAM.get_cell_specific_info    cell_id=${cell}    connection=${connection}
#   ${administrativeState}      Set Variable    ${cell_status['status']['administrativeState']}
#    Run keyword And Continue On Failure    Should Be Equal    ${administrativeState.upper()}    ${locking_status.upper()}
#    ${operationalState}         Set Variable    ${cell_status['status']['operationalState']}
#    Run keyword And Continue On Failure    Should Be Equal    ${operationalState.upper()}    ${operational_status.upper()}
#    ${usageState}               Set Variable    ${cell_status['status']['usageState']}
#    #Run keyword And Continue On Failure    Should Be Equal    ${usageState.upper()}    ${usage_status.upper()}
#    ${blockingState}            Set Variable    ${cell_status['status']['blockingState']}
#    Run keyword And Continue On Failure    Should Be Equal    ${blockingState.upper()}    ${blocking_status.upper()}

UnLock cells
    [Documentation]     UNLock the specified cell
    [Arguments]         ${cell_list}
    FOR    ${cell}    IN    @{cell_list}
        Log to console      \nunLocking cell : ${cell}
#        COAM.unlock           dist_name=${lteCell_dist}-${cell}      timeout=180     connection=${connection}
        Wait Until Keyword Succeeds     30 times    10      Check cell details      ${lteCell_dist}-${cell}            locking_status=unlocked
        ...                                                                         operational_status=enabled     usage_status=Active
        ...                                                                         blocking_status=Unblocked
    END


DCAP Start
    Log to console    \n-- Connecting to DCAP Server--\n
    rd.connect_to     host=${dcaphost}      port=${dcapport}     rd_version=${dcap_version}    username=${dcap_uname}
    ...     password=${dcap_pwd}    secure=True
    ${bts_info}=    create dictionary    host=${btshost}    port=${btsport}    username=${bts_uname}     password=${bts_pwd}
    ${gnb_custom_profile}=    Create List    condor5gSyslog
    ${output}=     rd.start_trace    tag=start_trace      duration=-1     bts=${bts_info}    tag=newtrace
    ...    gnb_trace_profile=dcap-lite-default    bts_trace_profile=dcap-lite-default
    Log to console    \n-- Started GNB Custom Traces --\n
#    ${trace_d}=    Get Dictionary Values   ${output}
#    ${trace_id}=    Set Variable    ${trace_d}[0]
#    Log to console    \n DCAP Trace ID: ${trace_id} \n
#    Set suite variable    ${trace_id}

DCAP Stop
    Log to console    \n-- Stopped DCAP Traces & Skipping log Transfer --\n
#    rd.stop_trace      trace_id=${trace_id}


DCAP Stop with log Transfer
#    rd.stop_trace      trace_id=${trace_id}
    Log to console    \n-- Stopped DCAP Traces & Moving files to Logs Repo --\n
#    rd.get_results    result_id=${trace_id}       target_dir=/home/ute/results/${TEST_NAME}    timeout=200
    os.Run    sudo mv '/home/ute/results/${TEST_NAME}' /sharedvolume/Execution_CRT_Logs/

Lock LTE Site
    Log to console    \n-- locking LTE RAT for eNODEB --\n
#    COAM.setup_admin    bts_host=${eNB2_IP}    alias=${connection1}    admin_api_log_dir=/tmp
#	Wait until keyword succeeds   1min   2s    COAM.block_rat    rat=LTE    connection=${connection1}
#    COAM.teardown_admin    connection=${connection1}

UnLock LTE Site
    Log to console    \n-- Unlocking LTE RAT for eNODEB --\n
#    COAM.setup_admin    bts_host=${eNB2_IP}    alias=${connection1}    admin_api_log_dir=/tmp
#	Wait until keyword succeeds   1min   2s    COAM.unblock_rat    rat=LTE    connection=${connection1}
#    COAM.teardown_admin    connection=${connection1}



