*** Settings ***
Library     OperatingSystem
Library     ta_attenuator
Library     taf.ue
Library     taf.sbts.oam.coam.admin   WITH NAME   taf.admin
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.qxdm_log_collector.QxdmLogCollector  WITH NAME  QXDM
Library     ./test_specific_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/bts_log.py
Library     testsuite/Wroclaw/RRM/resources/scout_report.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/DeltaStore.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/dcap/webemil_parser.py
Library     testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/qualcomm/qpm_lk.py
Resource    testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot

Documentation  Set of keywords for feature CB006733 execution

*** Keywords ***
CB006733 Suite Setup
    Check Branch
    Wait Until Keyword Succeeds   2x   10sec   Get QXDM License
    Setup Dcap
    Wait Until Keyword Succeeds   2x   10sec   QXDM.Setup
    QXDM.Set Logging Filter   C:/auto/sebkowa.dmc
    Prepare Ue
    Set Initial Attenuation

Get QXDM License
    Get 5g QXDM And Qcat License
    ...  username=tomasz.sobania@nokia.com
    ...  password=Tsob123,.
    ...  ue_id=${0}

Check Branch
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${sw}=  taf.admin.Get Sw Version  connection=${admin_alias}
    ${is_sw_newer_than_25R1}=    Check If Newer Than 25R1  ${sw}
    Set Global Variable  ${IS_SW_NEWER_THAN_25R1}  ${is_sw_newer_than_25R1}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

CB006733 Suite Teardown
    Release 5g QXDM And Qcat License  ue_id=${0}
    Dcap Teardown

A_B4_TC04_Setup
    Set Testname Without Spaces
    Deactivate 6733 Feature
    Start Bts Log  btslog

Prepare Ue
    taf.ue.Require UE    UE_1    capabilities=REAL_ANDROID_UE
    taf.ue.Detach UE     UE_1
    Sleep    5s

Attach
    [Arguments]    ${attenuation}    ${cell}
    Set Attenuation   ${cell}   ${attenuation}db
    taf.ue.Attach UE    UE_1
    sleep    5s
    Log to Console    \nUE Attached!


Set Initial Attenuation
    ${cell_list}=   Create list   ${CELL_190}    ${CELL_196}    ${CELL_193}    ${CELL_197}    ${CELL_999}
    Set global variable   ${gnb_cells}   ${cell_list}
    Load Attenuation Config    ${ABSTRACT_LIB_CONFIG}
    Require Attenuator Setup Of    ${gnb_cells}
    FOR    ${cell}    IN    ${cell_list}
      Set Attenuation    ${cell}    90dB
    END
    Sleep  2s

Attach Ue And Start Ping
    [Arguments]    ${attenuation}    ${cell}=${CELL_190}    ${ping_time}=1500
    Attach    ${attenuation}    ${cell}
    @{args}=    Create List     IP
    ${ip}=    taf.ue.get ue info    UE_1     infos_list=@{args}
    ${appserver}=    ssh.connect_to    hostname=10.45.168.53    username=5g    password=2019H@slo
    Set Global Variable  ${APPSERVER}  ${appserver}
    ssh.Execute    command=ping ${ip} -t ${ping_time}    connection=${APPSERVER}

CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry
    Activate 6733 Feature    15    6
    Log To Console    Waiting for counter period start
    Wait Until Counter Collection Time
#    Step 1: Feature activated with a4measmaxnumber 15
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    attenuation=10    cell=${CELL_190}    ping_time=1800
    Sleep     155s
    QXDM.Stop Log Collecting
    ${first_tput_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/first_tput
    ${first_tput_logs_txt}=    Set Variable    ${first_tput_logs}[0]
    Log To Console    Waiting for counter collection to verify counter M55118C00030
    Verify M55118C00030 Counter  expected_counter_value=15    cell=190
    ${qxdm_first_tput_results}    ${qxdm_first_tput_timestamps}=
    ...    Find A4 Parameters    ${first_tput_logs_txt}[0]
    ${qxdm_first_tput_adds_results}    ${qxdm_first_tput_adds_timestamps}=
    ...    Find Meas Id Adds    ${first_tput_logs_txt}[0]
    ${qxdm_first_tput_removes_results}    ${qxdm_first_tput_removes_timestamps}=
    ...    Find Meas Id Removes    ${first_tput_logs_txt}[0]
    Check Ssb Frequencies    ${first_tput_logs_txt}[0]    1
    Check Measurement Values    measurement_vals_1    ${qxdm_first_tput_results}
    Check Adds And Removes    ${qxdm_first_tput_adds_results}    ${qxdm_first_tput_adds_timestamps}
    ...                       ${qxdm_first_tput_removes_results}    ${qxdm_first_tput_removes_timestamps}    6    15
    ...                       True    15
    Check Timings    ${qxdm_first_tput_adds_timestamps}    ${qxdm_first_tput_removes_timestamps}
#    Step 2: Feature activated with a4measmaxnumber 20
    QXDM.Start Log Collecting
    Change A4measmaxnumber    20
    Sleep    55s
    QXDM.Stop Log Collecting
    ${a4meas_20_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/a4meas_20
    ${a4measmax_logs}=    Set Variable    ${a4meas_20_logs}[0]
    Log To Console    Waiting for counter collection to verify counter M55118C00030
    Verify M55118C00030 Counter  expected_counter_value=5    cell=190
    ${qxdm_a4measmax_adds_results}    ${qxdm_a4measmax_adds_timestamps}=
    ...    Find Meas Id Adds    ${a4measmax_logs}[0]
    ${qxdm_a4measmax_removes_results}    ${qxdm_a4measmax_removes_timestamps}=
    ...    Find Meas Id Removes    ${a4measmax_logs}[0]
    Check Adds And Removes    ${qxdm_a4measmax_adds_results}    ${qxdm_a4measmax_adds_timestamps}
    ...                       ${qxdm_a4measmax_removes_results}    ${qxdm_a4measmax_removes_timestamps}    6    5
    ...                       True    5
#    Step 3: Feature deactivated on 2 NRHOIFs
    QXDM.Start Log Collecting
    First Reconfiguration
    Log To Console    first reconfig done
    Sleep    75s
    QXDM.Stop Log Collecting
    ${first_recommission_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/first_recommission
    ${first_recommission_logs}=    Set Variable    ${first_recommission_logs}[0]
    ${qxdm_first_recommission_adds_results}    ${qxdm_first_recommission_adds_timestamps}=
    ...    Find Meas Id Adds    ${first_recommission_logs}[0]
    ${qxdm_first_recommission_removes_results}    ${qxdm_first_recommission_removes_timestamps}=
    ...    Find Meas Id Removes    ${first_recommission_logs}[0]
    check_adds_and_removes    ${qxdm_first_recommission_adds_results}    ${qxdm_first_recommission_adds_timestamps}
    ...    ${qxdm_first_recommission_removes_results}    ${qxdm_first_recommission_removes_timestamps}    4    6
    Check Timings    ${qxdm_first_recommission_adds_timestamps}    ${qxdm_first_recommission_removes_timestamps}
#    Step 4: Changed feature thresholds
    QXDM.Start Log Collecting
    Second Reconfiguration
    Log To Console    second reconfig done
    Sleep    75s
    QXDM.Stop Log Collecting
    ${second_recommission_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/second_recommission
    ${second_recommission_logs}=    Set Variable    ${second_recommission_logs}[0]
    ${qxdm_second_recommission_results}    ${qxdm_second_recommission_timestamps}=
    ...    Find A4 Parameters    ${second_recommission_logs}[0]
    ${qxdm_second_recommission_adds_results}    ${qxdm_second_recommission_adds_timestamps}=
    ...    Find Meas Id Adds    ${second_recommission_logs}[0]
    ${qxdm_second_recommission_removes_results}    ${qxdm_second_recommission_removes_timestamps}=
    ...    Find Meas Id Removes    ${second_recommission_logs}[0]
    Check Ssb Frequencies    ${second_recommission_logs}[0]    2
    Check Measurement Values    measurement_vals_2    ${qxdm_second_recommission_results}
    check_adds_and_removes    ${qxdm_second_recommission_adds_results}    ${qxdm_second_recommission_adds_timestamps}
    ...    ${qxdm_second_recommission_removes_results}    ${qxdm_second_recommission_removes_timestamps}    4    6
    Check Timings    ${qxdm_second_recommission_adds_timestamps}    ${qxdm_second_recommission_removes_timestamps}
#    Step 5: feature deactivated on all NRHOIFs
    Feature Deactivation
    Sleep    15s
    QXDM.Start Log Collecting
    Log To Console    feature deactivated
    Sleep    40s
    QXDM.Stop Log Collecting
    ${feature_deactivated_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/feature_deactivated
    ${feature_deactivated_logs}=    Set Variable    ${feature_deactivated_logs}[0]
    ${qxdm_feature_deactivated_adds_results}    ${qxdm_sfeature_deactivated_adds_timestamps}=
    ...    Find Meas Id Adds    ${feature_deactivated_logs}[0]
    Should Be Empty    ${qxdm_feature_deactivated_adds_results}

Common Test Teardown
    Stop And Collect Btslog  btslog  ${LOG_PATH}/${test_name}
    taf.ue.Detach UE    UE_1
    Add Scout Scf Id To Test Data
    Run Keyword If Test Passed  Find Suspicious Prints In Passed Test
    Make Snapshot In Case Of Error

A_B4_TC04 Teardown
    Common Test Teardown
    ssh.disconnect    connection=${APPSERVER}
    Activate 6733 Feature
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_196}    90dB
    Set Attenuation    ${CELL_193}    90dB

A_B6_TC32_Setup
    Set Testname Without Spaces
    Start Bts Log  btslog
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195

CB006733_A_B6_TC32 A4-based SCell Candidate PCI not included in A4 MR
    ${dcap_id}=    Dcap Start New Trace
    ${phase_1_start}=    test_specific_keywords.Get Time
    Start Tcpdump On CU    filename=${test_name}_CELL_196.pcap
    QXDM.Start Log Collecting
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    Log To Console    Expecting Measurement Reports from cell 196 now
    Set Attenuation    ${CELL_196}    0dB
    Sleep    35s
    ${phase_1_stop}=    test_specific_keywords.Get Time
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_CELL_196.pcap
    QXDM.Stop Log Collecting
    ${cell_196_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/CELL_196
    ${cell_196_logs_txt}=    Set Variable    ${cell_196_logs}[0]
    Log To Console    Expecting Measurement Reports from both cell 193 and 196 now
    Set Attenuation    ${CELL_193}    0dB
    Sleep    5s
    ${phase_2_start}=    test_specific_keywords.Get Time
    Start Tcpdump On CU    filename=${test_name}_CELLS_196_193.pcap
    QXDM.Start Log Collecting
    Sleep    40s
    ${phase_2_stop}=    test_specific_keywords.Get Time
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_CELLS_196_193.pcap
    QXDM.Stop Log Collecting
    ${cells_196_193_logs}=    QXDM.Download Log    filepath=${LOG_PATH}/CELLS_196_193
    ${cells_196_193_logs_txt}=    Set Variable    ${cells_196_193_logs}[0]
    Dcap Stop Trace And Download Logs    ${dcap_id}    ${LOG_PATH}/${test_name}_UTF_logs
    Prepare Emil Logs As Json    ${LOG_PATH}/${test_name}_UTF_logs

    Analyze TC32 Logs    ${cell_196_logs_txt}    ${cells_196_193_logs_txt}
    ...    ${phase_1_start}    ${phase_1_stop}    ${phase_2_start}    ${phase_2_stop}

Analyze TC32 Logs
    [Arguments]    ${phase_1_ue_logs}    ${phase_2_ue_logs}
    ...    ${phase_1_start}    ${phase_1_stop}    ${phase_2_start}    ${phase_2_stop}
    @{emil_msgs}=    Return Merged Jsons As Msg List    ${LOG_PATH}/${test_name}_UTF_logs
    ${phase_1_emil_msgs}=    Return Emil Msgs From Certain Period    ${emil_msgs}    ${phase_1_start}    ${phase_1_stop}
    ${phase_2_emil_msgs}=    Return Emil Msgs From Certain Period    ${emil_msgs}    ${phase_2_start}    ${phase_2_stop}
    Check Proper Cells In Meas Reports    ${phase_1_ue_logs}[0]    1
    Verify F1ap Messages And Assert Timing With Ue Logs    ${phase_1_emil_msgs}
    ...                                                    packets_expected=${FALSE}
    Check Proper Cells In Meas Reports    ${phase_2_ue_logs}[0]    2
    Verify F1ap Messages And Assert Timing With Ue Logs    ${phase_2_emil_msgs}
    ...                                                    packets_expected=${TRUE}

A_B6_TC32 Teardown
    Log To Console    all done
    Common Test Teardown
    ssh.disconnect    connection=${APPSERVER}
    Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_196}    90dB
    Set Attenuation    ${CELL_193}    90dB

TC11 Setup
    Set Testname Without Spaces
    TC11 Setup Recommissioning
    Block Cells Before TC    NRBTS-50819/NRCELL-194
    Start Bts Log  btslog

CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO
    IF  ${CHECK_COUNTER}  Wait Until Counter Collection Time
    Start Tcpdump On CU    filename=${test_name}_TC11_HO.pcap
    QXDM.Start Log Collecting
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    Sleep    40s
    Log To Console    Performing Handover to Cell 193
    Set Attenuation    ${CELL_193}     0dB
    FOR    ${attenuation}    IN RANGE    0    50    2
        Set Attenuation    ${CELL_190}     ${attenuation}dB
    END
    Sleep    30s
    Log To Console    Performing Handover back to Cell 190
    FOR    ${attenuation}    IN RANGE    50    0    -2
        Set Attenuation    ${CELL_190}     ${attenuation}dB
    END
    FOR    ${attenuation}    IN RANGE    0    54    2
        Set Attenuation    ${CELL_193}     ${attenuation}dB
    END
    Sleep    35s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_TC11_HO.pcap
    QXDM.Stop Log Collecting
    ${TC11_HO}=    QXDM.Download Log    filepath=${LOG_PATH}/TC11_HO
    ${TC11_HO}=    Set Variable    ${TC11_HO}[0]
    Log To Console    Analyzing Logs
    Analyze Tc11 Logs    ${LOG_PATH}/${test_name}_TC11_HO.pcap
    IF  ${CHECK_COUNTER}  Log To Console    Waiting for counter collection to verify counter M55118C00030
    IF  ${CHECK_COUNTER}  Verify M55118C00030 Counter  expected_counter_value=17    cell=190

Analyze Tc11 Logs
    [Arguments]    ${pcap_log}
    ${rrc_reconfig_msgs}=  Find Attach And Rrcreconfig Messages    ${pcap_log}
    ${rrc_reconfigs_timestamps}=  Find Pcap Messages Timestamps    ${rrc_reconfig_msgs}
    ${handover_msgs}=    Find Tc11 Handover Messages    ${pcap_log}
    ${handover_msgs_timestamps}=  Find Pcap Messages Timestamps    ${handover_msgs}

    Assert No Rrc Reconfigs After Handover To Cell 193    ${rrc_reconfigs_timestamps}    ${handover_msgs_timestamps}
    ${meas_object_ids_adds}    ${meas_object_ids_removes}    ${report_config_ids_adds}    ${report_config_ids_removes}=
    ...    Find Meas And Reportconfig Ids    ${rrc_reconfig_msgs}    ${handover_msgs}
    Analyze Meas Ids And Report Config Ids Adds And Removes    ${meas_object_ids_adds}    ${meas_object_ids_removes}
    ...                                                        ${report_config_ids_adds}    ${report_config_ids_removes}

TC11 Teardown
    Common Test Teardown
    ssh.disconnect    connection=${APPSERVER}
    Run Keyword And Ignore Error    Tshark Teardown
    Unblock Cells After TC    NRBTS-50819/NRCELL-194
    TC11 Teardown Recommissioning
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_193}    90dB


B_B4_TC21 Setup
    Set Testname Without Spaces
    Log To Console    Changing UE Network Mode to NR/LTE
    Change Network Mode    UE_1    NR/LTE    network_mode_switch_method=secretcode    network_mode_validation=${FALSE}
    Block Cells Before TC    NRBTS-50819/NRCELL-191    NRBTS-50819/NRCELL-195    NRBTS-50819/NRCELL-196
    ...  LNBTS-40819/LNCEL-11    LNBTS-40819/LNCEL-12    LNBTS-40819/LNCEL-52    LNBTS-40819/LNCEL-53
    TC21 Setup Recommissioning
    Start Bts Log  btslog

CB006733_B_B4_TC21 Activate A4 measurements for FR1 CA SCell Addition after inter-RAT HO with DRX
    Perform InterRAT Handover
    Log To Console    Analyzing Logs
    Analyze Tc21 Logs    ${LOG_PATH}/${test_name}_TC21_HO.pcap

Perform InterRAT Handover
    Start Tcpdump On CU    filename=${test_name}_TC21_HO.pcap
    Log To Console    \nAttaching UE to LNCELL 51
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_196}
    sleep    20s
    Log To Console    \nPerforming Handover to Cell 190
    Set Attenuation    ${CELL_190}     0dB
    FOR    ${attenuation}    IN RANGE    10    70    3
        Set Attenuation    ${CELL_196}     ${attenuation}dB
        Sleep    1s
    END
    SLeep    25s
    [Teardown]    Stop Tcpdump On CU And Download Logs    filename=${test_name}_TC21_HO.pcap

Analyze Tc21 Logs
    [Arguments]    ${pcap_log}
    Find And Verify Tc21 Handover Messages    ${pcap_log}
    ${rrc_reconfig_msgs}=    Find Attach And Rrcreconfig Messages    ${pcap_log}
    ${rrc_reconfig_timestamps}=    Find Pcap Messages Timestamps    ${rrc_reconfig_msgs}
    ${drx_reconfig_msgs}=    Find Drx Reconfig Messages    ${pcap_log}
    ${drx_reconfigs_timestamps}=    Find Pcap Messages Timestamps    ${drx_reconfig_msgs}
    ${successful_ho_msg_timestamp}=    Find Successful Handover Message And Return Timestamp    ${pcap_log}
    ${drx_setup_msgs}    ${drx_release_msgs}=    Find Drx Setups And Releases    ${pcap_log}
    ${drx_setup_timestamps}=    Find Pcap Messages Timestamps    ${drx_setup_msgs}
    ${drx_release_timestamps}=    Find Pcap Messages Timestamps    ${drx_release_msgs}
    Assert A4 Timer And Drx Setups Proper Procedure    ${rrc_reconfig_timestamps}
    ...                                                ${drx_reconfigs_timestamps}
    ...                                                ${drx_setup_timestamps}
    ...                                                ${drx_release_timestamps}

B_B4_TC21 Teardown
    Common Test Teardown
    Run Keyword And Ignore Error    Tshark Teardown
    Set Attenuation    ${CELL_190}     90dB
    Set Attenuation    ${CELL_196}     90dB
    Log To Console    Changing UE Network Mode to NR only
    Change Network Mode    UE_1    NR only    network_mode_switch_method=secretcode    network_mode_validation=${FALSE}
    ssh.disconnect    connection=${APPSERVER}
    Unblock Cells After TC    NRBTS-50819/NRCELL-191    NRBTS-50819/NRCELL-195    NRBTS-50819/NRCELL-196
    ...                 LNBTS-40819/LNCEL-11    LNBTS-40819/LNCEL-12    LNBTS-40819/LNCEL-52    LNBTS-40819/LNCEL-53
    TC21 Teardown Recommissioning

B_32_TC30 Setup
    Set Testname Without Spaces
    TC30 Setup Recommissioning
    Block Cells Before TC    NRBTS-50819/NRCELL-193
    Start Bts Log  btslog

CB006733_B_B32_TC30 Activate A4 measurements for FR1 CA SCell Addition after intra-gNB intra-DU HO with MFBI
    IF  ${CHECK_COUNTER}  Wait Until Counter Collection Time    start_minutes_before=2
    Start Tcpdump On CU    filename=${test_name}_TC30_HO.pcap
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    Sleep    15s
    Log To Console    Performing Handover to Cell 194
    Set Attenuation    ${CELL_193}     0dB
    FOR    ${attenuation}    IN RANGE    0    80    2
        Set Attenuation    ${CELL_190}     ${attenuation}dB
    END
    Sleep    30s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_TC30_HO.pcap
    IF  ${CHECK_COUNTER}  Log To Console    Waiting for counter collection to verify counter M55118C00030
    IF  ${CHECK_COUNTER}  Verify M55118C00030 Counter  expected_counter_value=5   cell=194
    Log To Console    Analyzing Logs
    Analyze Tc30 Logs      ${LOG_PATH}/${test_name}_TC30_HO.pcap

Analyze Tc30 Logs
    [Arguments]    ${pcap_log}
    ${rrc_reconfig_msgs}=    Find Attach And Rrcreconfig Messages    ${pcap_log}
    ${rrc_reconfig_timestamps}=    Find Pcap Messages Timestamps    ${rrc_reconfig_msgs}
    ${handover_timestamp}=    Check Handover Cell Bands And Return Handover Timestamp    ${pcap_log}
    Assert All A4 Rrcreconfigs Are After Handover    ${handover_timestamp}    ${rrc_reconfig_timestamps}

B_32_TC30 Teardown
    Common Test Teardown
    ssh.disconnect    connection=${APPSERVER}
    Run Keyword And Ignore Error    Tshark Teardown
    Unblock Cells After TC    NRBTS-50819/NRCELL-193
    TC30 Teardown Recommissioning
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_193}    90dB

TC34 Setup
    Set Testname Without Spaces
    TC34 Setup Recommissioning
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-196
    Start Bts Log  btslog

CB006733_B_B13_TC34 CB008290 interaction - prefer SCell Candidate with better radio conditions during FR1 CA SCell
    Start Tcpdump On CU    filename=${test_name}_TC34_CA_1.pcap
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_190}
    ${attenuation_1}=    test_specific_keywords.Get Time
    Log To Console    De-attenuating cells 193 and 195, measurement reports expected
    FOR    ${attenuation}    IN RANGE    80    0    -10
        Set Attenuation    ${CELL_193}     ${attenuation}dB
        Set Attenuation    ${CELL_196}     ${attenuation}dB
    END
    Set Attenuation    ${CELL_193}     0dB
    Set Attenuation    ${CELL_196}     0dB
    Sleep    8s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_TC34_CA_1.pcap
    Start Tcpdump On CU    filename=${test_name}_TC34_CA_2.pcap
    ${attenuation_2}=    test_specific_keywords.Get Time
    Log To Console    Attenuating cell 193 to cross eventA6 threshold
    FOR    ${attenuation}    IN RANGE    4    40    4
        Set Attenuation    ${CELL_193}     ${attenuation}dB
        sleep    1s
    END
    Log to console    Starting DL transfer
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=140s
        ...     throughput=700Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    45s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_TC34_CA_2.pcap
    Start Tcpdump On CU    filename=${test_name}_TC34_CA_3.pcap
    Log To Console    Attenuating cell 195 to cross eventA6 threshold
    FOR    ${attenuation}    IN RANGE    8    68    2
        Set Attenuation    ${CELL_196}     ${attenuation}dB
        Sleep    1s
    END
    Sleep    30s
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_TC34_CA_3.pcap
    Log To Console    \nAnalyzing Logs
    Analyze TC34 Logs    ${LOG_PATH}/${test_name}_TC34_CA_1.pcap
    ...                  ${LOG_PATH}/${test_name}_TC34_CA_2.pcap
    ...                  ${LOG_PATH}/${test_name}_TC34_CA_3.pcap
    ...                  ${attenuation_1}
    ...                  ${attenuation_2}

Analyze TC34 Logs
    [Arguments]    ${phase_1_pcap}    ${phase_2_pcap}    ${phase_3_pcap}    ${attenuation_1}    ${attenuation_2}
    Assert 6 EventA4s In RrcReconfig    ${phase_1_pcap}
    Assert Both Cells In MeasReport And Proper Time   ${phase_1_pcap}    ${attenuation_1}    ${attenuation_2}
    ${measid}=    Assert Proper Cell Measurement Reports and Buffer Messages    ${phase_2_pcap}
    Assert Measurement Report Containing Both Cells    ${phase_3_pcap}
    Check rrcReconfig message with cell 193 eventA6 addition and Assert no rrcReconfig and MeasReport After    ${phase_3_pcap}    ${measid}

TC34 Teardown
    Common Test Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Run Keyword And Ignore Error    Tshark Teardown
    Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-196
    TC34 Teardown Recommissioning
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_193}    90dB
    Set Attenuation    ${CELL_196}    90dB

B17_TC26 Setup
    Set Testname Without Spaces
    TC26 Setup Recommissioning
    Block Cells Before TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    IF  ${CHECK_COUNTER}  Wait Until Counter Collection Time
    Start Bts Log  btslog

CB006733_B_B17_TC26 Activation of A1 for SCell Change upon A2 SCell Release of A4-based SCell
    QXDM.Start Log Collecting
    Start Tcpdump On CU    filename=${test_name}_attach.pcap
    Log To Console    \nAttaching UE to Cell 190
    Attach Ue And Start Ping    attenuation=42    cell=${CELL_190}
    Sleep    3s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_attach.pcap
    ${timer_start_timestamp}=    Find First Rrcreconfig Timestamp    ${LOG_PATH}/${test_name}_attach.pcap
    Log To Console    \nDe-attenuating cell 190 to cross a1ThresholdSCellAddSsbRsrpFdd
    Start Tcpdump On CU    filename=${test_name}_tput_196_193_CA.pcap
    FOR    ${attenuation}    IN RANGE    42    30    -2
        Set Attenuation    ${CELL_190}     ${attenuation}dB
        Sleep    1s
    END
    Log To Console    \nDe-attenuating cell 196 to cross a4ThresholdSCellAddSsbRsrp/Rsrq
    FOR    ${attenuation}    IN RANGE    50    0    -5
        Set Attenuation    ${CELL_196}     ${attenuation}dB
    END
    Log To Console    \nDe-attenuating cell 193
    FOR    ${attenuation}    IN RANGE    40    0    -5
        Set Attenuation    ${CELL_193}     ${attenuation}dB
    END
    Set Attenuation    ${CELL_193}     0dB
    Wait Until New Timer Starts    ${timer_start_timestamp}
    Log to console    \nStarting DL transfer
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=320s
        ...     throughput=1500Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    20s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_tput_196_193_CA.pcap
    Start Tcpdump On CU    filename=${test_name}_tput_193_CA.pcap
    Log To Console    \nAttenuating cell 196 to remove it from CA
    FOR    ${attenuation}    IN RANGE    10    80    5
        Set Attenuation    ${CELL_196}     ${attenuation}dB
        Sleep    1s
    END
    Sleep    25s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_tput_193_CA.pcap
    Start Tcpdump On CU    filename=${test_name}_tput_999_CA.pcap
    Log To Console    \nDe-attenuating cell 999
    FOR    ${attenuation}    IN RANGE    50    0    -2
        Set Attenuation    ${CELL_999}     ${attenuation}dB
        Sleep    1s
    END
    Set Attenuation    ${CELL_999}     0dB
    Log To Console    \nDe-attenuating cell 190
    FOR    ${attenuation}    IN RANGE    30    0    -2
        Set Attenuation    ${CELL_190}     ${attenuation}dB
        Sleep    1s
    END
    Set Attenuation    ${CELL_190}     0dB
    sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_tput_999_CA.pcap
    IF  ${CHECK_COUNTER}  Log To Console    Waiting for counter collection to verify counter M55118C00030
    IF  ${CHECK_COUNTER}  Verify M55118C00030 Counter    expected_counter_value=6    cell=190
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    QXDM.Stop Log Collecting
    QXDM.Download Log    filepath=${LOG_PATH}/ue_logs_tc26
    taf.ue.Detach UE    UE_1
    Log To Console    Analyzing Logs
    Analyze TC26 Logs    ${LOG_PATH}/${test_name}_attach.pcap    ${LOG_PATH}/${test_name}_tput_196_193_CA.pcap
    ...    ${LOG_PATH}/${test_name}_tput_193_CA.pcap    ${LOG_PATH}/${test_name}_tput_999_CA.pcap

Analyze TC26 Logs
    [Arguments]    ${attach_pcap}    ${193_196_CA_pcap}    ${193_CA_pcap}    ${999_CA_pcap}
    Check No 193 and 999 Arfcnssbs Reported In Attach    ${attach_pcap}
    Check BufferMonitoring Messages    ${193_196_CA_pcap}
    Verify Rsrp Reported By Deattenuated Cell    ${193_196_CA_pcap}
    Find BufferCriterion Message and Scells For Carrier Aggregation    ${193_196_CA_pcap}
    ${meas_id}=    Find cell 196 CA removal message    ${193_CA_pcap}
    Assert No PrivateMessages In The Last Phase    ${999_CA_pcap}
    Assert Cell 193 Switched With Cell 999 In CA    ${999_CA_pcap}    ${meas_id}

B17_TC26 Teardown
    Common Test Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Run Keyword And Ignore Error    Tshark Teardown
    Unblock Cells After TC    NRBTS-50819/NRCELL-194    NRBTS-50819/NRCELL-195
    TC26 Teardown Recommissioning
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_196}    90dB
    Set Attenuation    ${CELL_193}    90dB
    Set Attenuation    ${CELL_999}    90dB

Unblock Cells After TC
    [Arguments]    @{cells}
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    FOR    ${cell}    IN    @{cells}
        taf.admin.Unblock Cell  dist_name=MRBTS-50819/${cell}    connection=${admin_alias}
    END
    Sleep    25s
    [Teardown]    taf.admin.Teardown Admin    alias=${admin_alias}

Block Cells Before TC
    [Arguments]    @{cells}
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    FOR    ${cell}    IN    @{cells}
        taf.admin.Block Cell  dist_name=MRBTS-50819/${cell}    connection=${admin_alias}
    END
    [Teardown]    taf.admin.Teardown Admin    connection=admin_gnb

B_19_TC29 Setup
    Set Testname Without Spaces
    TC29 Setup Recommissioning
    Block Cells Before TC    NRBTS-50819/NRCELL-195
    Start Bts Log  btslog

CB006733_B_B19_TC29 All SCell Candidates are A4-based in target HO cell
    Start Tcpdump On CU    filename=${test_name}_attach.pcap
    Log To Console    \nAttaching UE to Cell 196
    Attach Ue And Start Ping    attenuation=0    cell=${CELL_196}
    Sleep    3s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_attach.pcap
    ${timer_start_timestamp}=    Find First Rrcreconfig Timestamp    ${LOG_PATH}/${test_name}_attach.pcap
    Log To Console    \nDe-attenuating cell 190 to CA conditions
    Start Tcpdump On CU    filename=${test_name}_tput_190_999_CA.pcap
    FOR    ${attenuation}    IN RANGE    40    10    -5
        Set Attenuation    ${CELL_190}     ${attenuation}dB
        Sleep    1s
    END
    Log To Console    \nDe-attenuating cell 999 to CA condition
    FOR    ${attenuation}    IN RANGE    80    15    -5
        Set Attenuation    ${CELL_999}    ${attenuation}dB
    END
    Wait Until New Timer Starts    ${timer_start_timestamp}
    Log to console    \nStarting DL transfer
    taf.ue.Start Data Transfer
        ...     dt_name=DT_DL
        ...     ue_alias=UE_1
        ...     direction=dl
        ...     duration=150s
        ...     throughput=900Mbits/sec
        ...     protocol=udp
        ...     packet_size=1400
    Sleep    25s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_tput_190_999_CA.pcap
    Start Tcpdump On CU    filename=${test_name}_999_HO.pcap
    Log To Console    \nDe-attenuating cell 999 to trigger handover
    FOR    ${attenuation}    IN RANGE    20    0    -2
        Set Attenuation    ${CELL_999}     ${attenuation}dB
    END
    Set Attenuation    ${CELL_999}     0dB
    Log To Console    \nAttenuating cell 196 to trigger handover
    FOR    ${attenuation}    IN RANGE    0    62    2
        Set Attenuation    ${CELL_196}     ${attenuation}dB
        Sleep    1s
    END
    Set Attenuation    ${CELL_196}    14dB
    Sleep    10s
    Stop Tcpdump On CU And Download Logs    filename=${test_name}_999_HO.pcap
    taf.ue.Stop Data Transfer    dt_name=DT_DL
    Log To Console    Analyzing Logs
    Analyze TC29 Logs    ${LOG_PATH}/${test_name}_tput_190_999_CA.pcap    ${LOG_PATH}/${test_name}_999_HO.pcap

Analyze TC29 Logs
    [Arguments]    ${3cc_pcap}    ${handover_pcap}
    Confirm 3cc Carrier Aggregation    ${3cc_pcap}
    Find Handover Message And Assert No Measurement Reports After Handover    ${handover_pcap}

B_19_TC29 Teardown
    Common Test Teardown
    ssh.Disconnect    connection=${APPSERVER}
    Run Keyword And Ignore Error    Tshark Teardown
    Unblock Cells After TC    NRBTS-50819/NRCELL-195
    TC29 Teardown Recommissioning
    Set Attenuation    ${CELL_190}    90dB
    Set Attenuation    ${CELL_196}    90dB
    Set Attenuation    ${CELL_999}    90dB

######    RECOMMISSIONINGS    ######
Deactivate 6733 Feature
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    actNrDualConnectivity=disabled
    ...                           actCDrx=false
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=blind
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=blind
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=blind
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=blind
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=blind
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellOperationalMode
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasSCellAddEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    param_name=a4MeasSCellAddSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    param_name=a4MeasSCellAddSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    param_name=a4MeasSCellAddSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    param_name=a4MeasSCellAddSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    param_name=a4MeasSCellAddSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    param_name=a4MeasSCellAddSsbRsrp
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    param_name=a4MeasSCellAddSsbRsrq
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   param_name=a4MeasSCellAddSsbRsrq
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.TeardownAdmin    connection=admin_gnb

Activate 6733 Feature
    [Arguments]    ${a4measmaxnumber}=0    ${a4retrytimer}=10
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Delete Delta If Already Present                    name=default
    Initialise Delta Store

    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...                           a2MeashoEnabledSA=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-3    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-5    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA4
    ...                           sCellOperationalMode=dlOnly
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1
    ...                           list_name=a4MeasSCellAddSsbRsrp    a4HysteresisSCellAddSsbRsrp=0
    ...                           a4ThresholdSCellAddSsbRsrp=60    a4TimeToTriggerSCellAddSsbRsrp=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrq
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12
    ...                           list_name=a4MeasSCellAddSsbRsrq    a4HysteresisSCellAddSsbRsrq=0
    ...                           a4ThresholdSCellAddSsbRsrq=55    a4TimeToTriggerSCellAddSsbRsrq=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3
    ...                           a4MeasSCellAddEnabled=rsrpAndRsrq
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3
    ...                           list_name=a4MeasSCellAddSsbRsrp    a4HysteresisSCellAddSsbRsrp=0
    ...                           a4ThresholdSCellAddSsbRsrp=61    a4TimeToTriggerSCellAddSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3
    ...                           list_name=a4MeasSCellAddSsbRsrq    a4HysteresisSCellAddSsbRsrq=0
    ...                           a4ThresholdSCellAddSsbRsrq=66    a4TimeToTriggerSCellAddSsbRsrq=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4
    ...                           a4MeasSCellAddEnabled=rsrpCombined
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4
    ...                           list_name=a4MeasSCellAddSsbRsrp    a4HysteresisSCellAddSsbRsrp=0
    ...                           a4ThresholdSCellAddSsbRsrp=62    a4TimeToTriggerSCellAddSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4
    ...                           list_name=a4MeasSCellAddSsbRsrq    a4HysteresisSCellAddSsbRsrq=0
    ...                           a4ThresholdSCellAddSsbRsrq=67    a4TimeToTriggerSCellAddSsbRsrq=ms40
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5
    ...                           a4MeasSCellAddEnabled=rsrqCombined
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5
    ...                           list_name=a4MeasSCellAddSsbRsrp    a4HysteresisSCellAddSsbRsrp=0
    ...                           a4ThresholdSCellAddSsbRsrp=63    a4TimeToTriggerSCellAddSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5
    ...                           list_name=a4MeasSCellAddSsbRsrq    a4HysteresisSCellAddSsbRsrq=0
    ...                           a4ThresholdSCellAddSsbRsrq=68    a4TimeToTriggerSCellAddSsbRsrq=ms40
    IF    ${IS_SW_NEWER_THAN_25R1}    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=${a4retrytimer}
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=${a4measmaxnumber}    a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    ...    ELSE       Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=${a4retrytimer}
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=${a4measmaxnumber}    a4Fr2SupervisionTimer=6000
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

Change A4measmaxnumber
    [Arguments]    ${a4measmaxnumber}
    Delete Delta If Already Present                    name=default
    Initialise Delta Store
    IF    ${IS_SW_NEWER_THAN_25R1}    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=6    a4RetryTimerMultCa=5
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=${a4measmaxnumber}    a4Fr2SupervisionTimer=6000
    ...    ELSE       Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=6
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=${a4measmaxnumber}    a4Fr2SupervisionTimer=6000
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

First Reconfiguration
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1     a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=none
    IF    ${IS_SW_NEWER_THAN_25R1}    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=6
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=0    a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    ...    ELSE       Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=6
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=0    a4Fr2SupervisionTimer=6000
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb


Second Reconfiguration
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrpCombined
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4
    ...                           list_name=a4MeasSCellAddSsbRsrp    a4HysteresisSCellAddSsbRsrp=0
    ...                           a4ThresholdSCellAddSsbRsrp=102    a4TimeToTriggerSCellAddSsbRsrp=ms40
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5
    ...                           list_name=a4MeasSCellAddSsbRsrp    a4HysteresisSCellAddSsbRsrp=1
    ...                           a4ThresholdSCellAddSsbRsrp=113    a4TimeToTriggerSCellAddSsbRsrp=ms64
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb


Feature Deactivation
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=none
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=none
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC11 Setup Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...                      a2MeashoEnabledSA=rsrp    a2MeasRedirectEnabled=rsrp
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC11 Teardown Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...                      a2MeashoEnabledSA=none    a2MeasRedirectEnabled=none
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC21 Setup Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    actCDrx=true
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    actDrbDrx=true
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC21 Teardown Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190    actCDrx=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    actDrbDrx=false
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC30 Setup Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasSCellAddEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  a2MeashoEnabledSA=rsrp  a2MeasRedirectEnabled=rsrp
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC30 Teardown Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-1    a4MeasSCellAddEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12   a4MeasSCellAddEnabled=rsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-3    a4MeasSCellAddEnabled=rsrpAndRsrq
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-4    a4MeasSCellAddEnabled=rsrpCombined
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-5    a4MeasSCellAddEnabled=rsrqCombined
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190  a2MeashoEnabledSA=none  a2MeasRedirectEnabled=none
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC34 Setup Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    actSCellSwapFr1=a6BasedSa
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    a6MeasSCellSwapEnabled=rsrp
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195  list_name=a6MeasSCellSwapSsbRsrp
    ...    a6HysteresisSCellSwapSsbRsrp=0    a6OffsetSCellSwapSsbRsrp=3    a6TimeToTrigSCellSwapSsbRsrp=ms480
    ...    useAllowedCellListRsrp=false
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6  sCellAdditionMethod=covBasedA4
    ...                      sCellOperationalMode=dlOnly
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellOperationalMode
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC34 Teardown Recommissioning
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819    actSCellSwapFr1=disabled
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    a6MeasSCellSwapEnabled=none
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-6    param_name=sCellOperationalMode
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-195    param_name=a6MeasSCellSwapSsbRsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA4    sCellOperationalMode=dlOnly
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC26 Setup Recommissioning
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based    A1-based
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA1
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA1
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellAdditionMethod
    Add Param Delete To Delta     dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    param_name=sCellOperationalMode
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    a2MeasSCellRelEnabled=rsrp
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=196
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrp
    IF    ${IS_SW_NEWER_THAN_25R1}    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=10000    a4RetryTimer=3
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=0    a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    ...    ELSE       Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=10000    a4RetryTimer=3
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=0    a4Fr2SupervisionTimer=6000
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC26 Teardown Recommissioning
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-1    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-4    sCellAdditionMethod=covBasedA4
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-7    sCellAdditionMethod=covBasedA4    sCellOperationalMode=dlOnly
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196    a2MeasSCellRelEnabled=none
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRREL-2    lcrId=194
    Add Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190/NRHOIF-12    a4MeasSCellAddEnabled=rsrq
    IF    ${IS_SW_NEWER_THAN_25R1}    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=0    a4Fr2SupervisionTimer=6000    a4RetryTimerMultCa=5
    ...    ELSE       Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-190
    ...               list_name=a4PeriodicMeasControlSA  a4Fr1SupervisionTimer=4000    a4RetryTimer=10
    ...               a4MeasActBlockTimer=00  a4MeasMaxNumber=0    a4Fr2SupervisionTimer=6000
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    ${delta_store}=  Collect Delta Store
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC29 Setup Recommissioning
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based    A1-based
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actHoOptimizationCa=true
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-2    sCellAdditionMethod=covBasedA1
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196
    ...                           list_name=a2MeashoSsbRsrpSA    a2HysteresishoSsbRsrpSA=0    a2ThresholdhoSsbRsrpSA=56
    ...                           a2TimeToTriggerhoSsbRsrpSA=ms480
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb

TC29 Teardown Recommissioning
    @{actMeasBasedSCellAdditionSa}=    Create List    A4-based
    Delete Delta If Already Present                        name=default
    Initialise Delta Store
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819
    ...                           actMeasBasedSCellAdditionSa=@{actMeasBasedSCellAdditionSa}
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819    actHoOptimizationCa=false
    Add Parameters To Delta       dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196/NRREL-2    sCellAdditionMethod=covBasedA4
    Add List Parameters To Delta  dist_name=MRBTS-50819/NRBTS-50819/NRCELL-196
    ...                           list_name=a2MeashoSsbRsrpSA    a2HysteresishoSsbRsrpSA=0    a2ThresholdhoSsbRsrpSA=60
    ...                           a2TimeToTriggerhoSsbRsrpSA=ms480
    ${delta_store}=  Collect Delta Store
    ${admin_alias}=    taf.admin.Setup Admin    alias=admin_gnb
    taf.admin.Perform Delta Recommissioning  delta_file=${delta_store}  skip_parameter_relation_errors=False
    ...                                      should_activate=True  timeout=300s  connection=${admin_alias}
    [Teardown]  taf.admin.Teardown Admin    connection=admin_gnb
