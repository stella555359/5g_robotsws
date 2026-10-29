*** Settings ***
Documentation
...   author: Xiang Liang
...   contact: liang.xiang@nokia-sbell.com
...   this is a robot case about 5GC000526.

Resource          ../../Resources/Classical/RRM_Common_Resource.robot

Force Tags        SBTS22R1     5G_RAN       CLOUD_5G_CLASSICAL_ANDROID_ASIBR_ABILB1_AHEGB_FRGQ_ENB       QCD_MN_RAN      QCP_RAN_ST
Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM
Test Setup        Common Test Setup For RRM
Test Teardown     Common Test Teardown For RRM

*** Variables ***
${DST_FOR_BTS}    MRBTS-${MRBTS_ID}/NRBTS-10065
${DST_FOR_FRM}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELL-0
${DST_FOR_GROUP}    MRBTS-${MRBTS_ID}/NRBTS-10065/NRCELLGRP-0
${DST_FOR_PMCADM}    MRBTS-${MRBTS_ID}/MNL-1/PMCADM-1
${ue_index}           ${tl.ues[0]}
${scf_file_path}         /home/ute/MN/UTE/robotws/commissionings/RRM/SRAN_5G/10_5_UTESRAN201T4812/10_5_UTESRAN201T4812_5GC000526.xml
${bip_log_name}         bip.pcap
*** Test Cases ***
prepare NSA testline
    [Tags]     QCD_MN_RAN      QCP_RAN_ST
	[Setup]    prepare testline setup
	run keyword and ignore error    COAM_Admin.Login
    ReplaceSwconfig    local_path=/home/ute/MN/UTE/robotws/commissionings/RRM/SRAN_5G/10_5_UTESRAN201T4812/swconfig.txt
    COAM Commission with scf file      ${scf_file_path}
    Sleep    800s

	${new_sw_version}     ${branch}    Get SW VER From SBTS and Convert Trunk or Branch
    ${cmd}=  Catenate  wget http://files.ute.nsn-rdnet.net/builds/enb/base/${new_sw_version}/${new_sw_version}_release_BTSSM_downloadable.zip
    OperatingSystem.Run    ${cmd}

    run keyword and ignore error    COAM_Admin.Login
    coam.update_software   sw_package=/home/ute/MN/UTE/robotws/${new_sw_version}_release_BTSSM_downloadable.zip
	...                    should_activate=${True}
	...                    timeout=${3600}
	...                    connection=COAM
    Log To Console   Software Update Finished, Waiting For Resetting...
	Sleep    200s
	run keyword and ignore error    COAM_Admin.Login

	Wait until keyword succeeds    10min    20 sec    Verify bts and all cell status should be onair
    COAM_Admin.Logout

	${cell_status}    Run Keyword And Return Status    Verify bts and all cell status should be onair
	Run Keyword If    ${cell_status}==${False}  reset site and wait cell onair
	[Teardown]    prepare testline setup

[1]5GC000526_AA_Generating_artificial_load_on_SSB_beams_SU_MIMO_SingleBeamIndex_NoUEConnected_Messages_flow_and_content_Check
    [Tags]    QC_441686       QCD_MN_RAN      QCP_RAN_ST
    ###COAM_Admin.set parameter value    ${DST_FOR_FRM}    actCDrx    false
#    log    start tcp log    console=yes
    ###Start tcpdump log
    Set Parameter for GNB
    Attach UE0 And Start DL TPUT
    Start BIP trace
    sleep    1s
    Stop bip log
    Check Mcshark BIP Log
    Precondition counter
    #Check Artifitial MCS
    Log to console    check counter
   sleep   240
   ${pi_list}=  Create List    M55308C00007
    ${expect_value}    Set Variable    0
   ${counter_id_value_list}    Check counter value    counter_ID=${pi_list[0]}    expect_value=${expect_value}
    Detach UE0
#    :FOR   ${value}   IN    @{mcs}
#    \    exit for loop if    ${value} == 0x00000000
#    \      ${is_pass}  set variable if  ${value} == 0x00000012  ${True}  ${False}
#    \      set test variable  ${is_pass}
#    \      exit for loop if  ${is_pass}
#    should be true  ${is_pass}==${True}

#    log    check aasyslog    console=yes
#    Check Aasyslog
#    log    stop tcpdump    console=yes
    ###Stop tcpdump log
#    Start TTI log for full rack
#    sleep    20
#    Stop TTI trace log capturing    connection_for_abil=ABIL
#    Convert TTI trace to CVS and download csv logs to test pc    connection_for_abil=ABIL
#    log    check tcp log    console=yes
#    Check tcpdump log
*** Keywords ***
prepare testline setup
    Log to console    prepare testline setup

Set Parameter for GNB
   COAM_Admin.set parameter value    ${DST_FOR_FRM}    mcsIndexForArtificialLoad    9
   COAM_Admin.set parameter value    ${DST_FOR_FRM}    targetTotalLoad    100

Recover Parameter for GNB
   COAM_Admin.set parameter value    ${DST_FOR_FRM}    mcsIndexForArtificialLoad    0
   COAM_Admin.set parameter value    ${DST_FOR_FRM}    targetTotalLoad    0

Check Aasyslog
    ${Aasyslog_prints1}=    Create list
   ...    drx-longCycle=40
   ...    drx-onDurationTimerLen=10
   ${Aasyslog_prints}=    Create list
   ...    DrxOnDurationTimer.*?MS10
   ...    DrxInactivityTimer.*?MS20
   ...    DrxLongCycle.*?MS40
    FOR  ${print}  IN  @{Aasyslog_prints}
      Analysis Aasyslog    log_name=5Grach.txt    filter=drx    expected_message=${print}
    END
    FOR  ${print}  IN  @{Aasyslog_prints1}
      Analysis Aasyslog    log_name=5Grach.txt    filter=drx    expected_message=${print}
    END

Start tcpdump log
    ${tcpdump_log_name}=    Start tcpdump in SBTS
    Set Suite Variable    ${tcpdump_log_name}
Stop tcpdump log
    ${capture_file_path}    ${input_file}=    Stop Tcpdump in SBTS
Check tcpdump log
    ${filter} =    Set Variable    X2AP
    ${filter_expression} =    Set Variable    nr-rrc.bandNR == 1 && nr-rrc.pusch_TransCoherence == 0
    ${xpath} =    Set Variable    .//nr-rrc.pusch_TransCoherence
    ${value_list} =    Parse Pcap by expression       input_file=${SUITE_LOG_PATH}/${tcpdump_log_name}/${tcpdump_log_name}.pcap
   ...                                            filter=${filter}
   ...                                            filter_expression=${filter_expression}
make call with DL
    Log to console    make call
   Start traffic    ${ue_type}    direction=dl    throughput=1024M    duration=15
   sleep    10
Precondition counter
   Wait For New Measurement Period
   Delete before PM counter file
Check counter
   ${pi_list}=  Create List    M55308C11001    M55308C11002
    ${expect_value}    Set Variable    0
   ${counter_values_list_M55308C11001}    Check counter value    counter_ID=${pi_list[0]}
   ...                                                           expect_value=${expect_value}
   ${counter_values_list_M55308C11002}    Check counter value    counter_ID=${pi_list[1]}
   ...                                                           expect_value=${expect_value}
   ${counter_values_list_M55308C11001[0]}    Convert to number    ${counter_values_list_M55308C11001[0]}
   ${counter_values_list_M55308C11002[0]}    Convert to number    ${counter_values_list_M55308C11002[0]}
   ${counter_values}    Evaluate    ${counter_values_list_M55308C11001[0]}/${counter_values_list_M55308C11002[0]}
   should be true    ${counter_values} > 0.25

Check Artifitial MCS
    Start BIP trace with full rack
    sleep    10s
    Stop BIP trace with full rack
    ${filtered_packets}    ${mcs}    Parse Pcap by name with luashark
    ...    ${list_log_path_local[0]}
#    ...    input_file=/home/ute/test_results/SBTS21B_ENB_9999_201222_000006/TS_5GC000526_TC01_20201224083018/tcpdumpL2L1.pcap
    ...    filter_expression=DlData_PdschSendReq.grants_item_15.mcs
    ...    field_name=DlData_PdschSendReq.grants_item_15.mcs
    FOR   ${value}   IN    @{mcs}
        exit for loop if    ${value} == 0x00000000
          ${is_pass}  set variable if  ${value} == 0x00000012  ${True}  ${False}
          set test variable  ${is_pass}
          exit for loop if  ${is_pass}
    END
    should be true  ${is_pass}==${True}

Start BIP trace
    log to console    start bip log
    ${connection_ASIB}    Start Bip Capture with gnbMirroring scripts and MCShark    file_size_mbytes=200
    ...                                                                  number_of_files=1
    ...                                                                  mirror_abil_1=true
    ...                                                                  mirror_abil_2=false
   set test variable    ${connection_ASIB}

Stop bip log
    Log To Console    Stop McShark BIP Log
    ${bip_log_path}    Stop BIP trace    local_log_name=${bip_log_name}     connection_ASIB=${connection_ASIB}
    Set Test Variable    ${bip_log_path}


Check BIP trace
   ${PdcchOLPrecodingOption4X4}    set variable    1
    ${UlData_PuschReceiveRespPs_filter}=    catenate
   ...    DlData_PdschSendReq.grants_item_0.mcs == 0x10
   Parse Pcap by expression with luashark   input_file=${list_log_path_local[0]}
   ...                                 display_filter=${UlData_PuschReceiveRespPs_filter}

Check BIP log for MSC
    Log to console    artif mcs
    ${DlData_PdschSendReq_filter}=    catenate    DlData_PdschSendReq.grants_item_15.mcs ==0x10
    ${xpath} =    Set Variable    .//DlData_PdschSendReq.grants_item_15.mcs
   ${values} =    Parse Pcap by xpath with luashark    input_file=${list_log_path_local[0]}
   ...                display_filter=${DlData_PdschSendReq_filter}
   ...                xpath=${xpath}
    FOR    ${value}    IN    @{values}
       exit for loop if    ${value} = 0
    END
    run keyword if      ${value} != 16    FAIL

Case Teardown
#    Run Keyword And Ignore Error    Stop BIP trace
#    Run Keyword And Ignore Error    ute_ue.Detach UE

##########    UE related    ##########
Prepare UE0
    ${ue0_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
	set test variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}
Prepare UE1
    ${ue1_type}    ue.translate_power_ue_type_from_testline    ue_index=${1}
	set test variable    ${ue1_type}
    Prepare UE    ${ue1_type}    ue_index=${1}
Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}
#	Sleep    60s
Attach UE1
    UE Attach    ${ue1_type}    ue_index=${1}
#	Sleep    60s
Start DL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=110M    duration=600
Start UL TPUT for UE0
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
	...              throughput=100M    duration=300
Start DL TPUT for UE1
    Start traffic    ue_type=${ue1_type}    ue_index=${1}    direction=dl    dt_index=${1}
	...              throughput=110M    duration=600
Start UL TPUT for UE1
    Start traffic    ue_type=${ue1_type}    ue_index=${1}    direction=ul    dt_index=${1}
	...              throughput=100M    duration=300
Stop DL THPUT And Detach UE0
    Stop DL THPUT for UE0
    Detach UE0
Stop Both DL AND UL THPUT And Detach UE0
    Stop DL THPUT for UE0
    Stop UL THPUT for UE0
    Detach UE0
Stop DL THPUT And Detach UE1
    Stop DL THPUT for UE1
    Detach UE1
Stop UL THPUT And Detach UE0
    Stop UL THPUT for UE0
    Detach UE0
Stop UL THPUT And Detach UE1
    Stop UL THPUT for UE1
    Detach UE1

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}
Detach UE1
    UE Detach    ${ue1_type}    ue_index=${1}

Stop DL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=dl
Stop UL THPUT for UE0
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul
Stop DL THPUT for UE1
    Stop traffic    ${ue1_type}    ue_index=${1}    direction=dl
Stop UL THPUT for UE1
    Stop traffic    ${ue1_type}    ue_index=${1}    direction=ul

Attach UE0 And Start Both DL And UL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start DL TPUT for UE0
    Start UL TPUT for UE0
    sleep    10s

Attach UE0 And Start DL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start DL TPUT for UE0
    sleep    10s

Attach UE0 And Start UL TPUT
    Prepare UE0
    Attach UE0
    sleep    60s
    Start UL TPUT for UE0
    sleep    10s

Attach UE1 And Start DL TPUT
    Prepare UE1
    Attach UE1
    sleep    60s
    Start DL TPUT for UE1
    sleep    10s

Attach UE1 And Start UL TPUT
    Prepare UE1
    Attach UE1
    sleep    60s
    Start UL TPUT for UE1
    sleep    10s

Check Mcshark BIP Log
    Log To Console    Check McShark BIP Log
    ${filter}=    Catenate        DlData_PdschGrant.mcs
    @{csv_title_list}=    Create List    DlData_PdschGrant.mcs
    ${csvname}=    Set Variable    ${TEST_LOG_DIRECTORY}/csv_2535_BIP.csv
    Convert BIP To CSV By MCShark    ${bip_log_name}    ${csvname}    ${filter}    ${csv_title_list}
    ${csv_matrix}=    Read Csv File Into Matrix    file_path=${csvname}
    ${column_list_dmrs}=    Get Column From Matrix    matrix=${csv_matrix}    column_nubmer=${1}
    ${column_list_mcs}=    Get Column From Matrix    matrix=${csv_matrix}    column_nubmer=${3}
    Remove From List    ${column_list_dmrs}    0
    Remove From List    ${column_list_mcs}    0
    ${len_dmrs}=    get length    ${column_list_dmrs}
    ${len_mcs}=    get length    ${column_list_mcs}
    Should Be Equal    ${len_dmrs}  ${len_mcs}
    Should Be True    ${len_dmrs}>0
    FOR    ${index}    IN RANGE    ${len_dmrs}
        Continue For Loop If    ${column_list_dmrs[${index}]} == 0x01
        ${is_pass}    Set Variable If    ${column_list_mcs[${index}]} == 0x00000009     ${True}    ${False}
        Set Test Variable  ${is_pass}
        Exit For Loop If  ${is_pass}
    END
    Should Be True  ${is_pass}==${True}
