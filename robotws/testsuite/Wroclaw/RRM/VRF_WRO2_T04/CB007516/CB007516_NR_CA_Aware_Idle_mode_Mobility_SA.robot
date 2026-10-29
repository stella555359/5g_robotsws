*** Settings ***
Documentation
...  author: Pawel Zabawczuk
...  contact: pawel.k.zabawczuk@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ue_keywords.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/counters.py    WITH NAME    wro4_pm
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/resources/specific_keywords_8225.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007516/CB007516_python_functions.py    WITH NAME    idle
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007516/idle_mode_pm_counters.py

*** Variables ***
${ue}               UE_1
${idle_timer}       45s

*** Keywords ***
CB007516_A_NR_Aware_Idle_mode_mobility_SA
    [Documentation]   This TC describes the gNB behavior for Idle Mode Mobility steering with non CA aware algorithm without mobility profiles.
    ...               TEST STEPS
    ...               1. Attach NR_PCI=100 -> wait for IDLE -> TPUT -> NR_PCI=400 (cell resellection)
    ...               2. NR_PCI=400 -> wait for IDLE -> TPUT-> NR_PCI=700 (cell resellection)
    ...               3. NR_PCI=700 -> wait for IDLE -> LTE_PCI=10 (cell resellection)
    ...               4. LTE_PCI=10 -> wait for reconnection -> NR_PCI=400 (reconnect to 5G to strongest cell)
    ...               5. NR_PCI=400 -> wait for IDLE -> NR_PCI=700 (cell resellection),
    ...                  Attenuate NR_PCI=700 (first cell resellection) -> TPUT -> wait for IDLE -> NR_PCI=410 (second cell resellection)
    ...               6. NR_PCI=410 -> wait for IDLE -> TPUT-> NR_PCI=410 (first cell resellection for serving cell)
    ...               7. Detach UE, collect counters and vefiry them
    idle.prepare_startup_values
    block_nr_cell   cell_id=110
    Change APN   ue_name=SAMSUNG_S24_1   apn_name=5gsawro

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    logs.Start Tracing On SMOD   smod slave=False

    # STEP 1
    Set Test Variable   ${serving_cell}  100
    Set Test Variable   ${target_cell}   400

    Show Text on Console   [Decrease attenuation and block lte cell to attach UE to SERVING cell]
    ${rus}   Create List   AEHC  AHLOB
    Set Attenuation on Radios   90dB  ${rus}
    block_lte_cell   cell_id=10
    Attach UE to Serving Cell   serving_cell=${serving_cell}   change_bands=${True}
    Set Attenuation on Radios   0dB  ${rus}
    unblock_lte_cell   cell_id=10

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Show Text on Console   [Run traffic and verify attach to TARGET cell]
    Start Downlink Traffic
    Is UE in NR Target Cell   target_cell=${target_cell}
    Wait Traffic Finish and Verify It

    # STEP 2
    Set Test Variable   ${serving_cell}  400
    Set Test Variable   ${target_cell}   700

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Show Text on Console   [Run traffic and verify attach to TARGET cell]
    Start Downlink Traffic
    Is UE in NR Target Cell   target_cell=${target_cell}
    Wait Traffic Finish and Verify It

    # STEP 3
    Set Test Variable   ${serving_cell}  700
    Set Test Variable   ${target_cell}   10

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_LTE
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Wait For UE Reconnects from 5G to 4G Network
    Wait Until Keyword Succeeds   10s  2s  Is UE in LTE Target Cell   target_cell=${target_cell}

    # STEP 4
    Set Test Variable   ${serving_cell}  10
    Set Test Variable   ${target_cell}   400

    Wait UE Connects to 5G Network Again
    Wait Until Keyword Succeeds   120s  15s  Check UE Attach to Strongest Cell   cell=${target_cell}

    # STEP 5
    Set Test Variable   ${serving_cell}  400
    Set Test Variable   ${target_cell}   700

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Show Text on Console   [Verify attach to TARGET cell]
    Is UE in NR Target Cell   target_cell=${target_cell}  idle_offset=10s

    Set Test Variable   ${serving_cell}  700
    Set Test Variable   ${target_cell}   410

    Attenuate Cell To Choose Second Candidate from Reselection
    Show Text on Console   [Run and verify traffic]
    Start Downlink Traffic
    Wait Traffic Finish and Verify It

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Show Text on Console   [Verify attach to TARGET cell]
    Start Downlink Traffic
    Is UE in NR Target Cell   target_cell=${target_cell}
    Wait Traffic Finish and Verify It

    # STEP 6
    Set Test Variable   ${serving_cell}  410
    Set Test Variable   ${target_cell}   410

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Show Text on Console   [Run traffic and verify attach to TARGET cell]
    Start Downlink Traffic
    Is UE in NR Target Cell   target_cell=${target_cell}
    Wait Traffic Finish and Verify It

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    # STEP 7
    Detach Ue   ${ue}
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  IDLE_PM_COUNTERS
    Verification PM Counters   ${counter_values}  IDLE_PM_COUNTERS

    [Teardown]  Run Keywords
    ...   Stop Data Transfer   DT_DL_${ue}
    ...   AND   enable_band_config   ${ue}   NR_ONLY
    ...   AND   Change APN   ue_name=SAMSUNG_S24_1   apn_name=internet
    ...   AND   Run Keyword And Ignore Error   unblock_lte_cell   cell_id=10
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}
    ...   AND   unblock_nr_cell   cell_id=110


CB007516_B_NR_Aware_Idle_mode_mobility_SA
    [Documentation]   This TC describes the gNB behavior for Idle Mode Mobility steering with non CA aware algorithm with mobility profiles.
    ...               TEST STEPS
    ...               1. Attach UEs with PLMN: 310260 (mobility profile: 1)to NR_PCI=700 -> wait for IDLE -> TPUT -> NR_PCI=400 -> Detach
    ...               2. Attach UEs with PLMN: 24408 (mobility profile: 2)to NR_PCI=700 -> wait for IDLE -> TPUT -> NR_PCI=410 -> Detach
    ...               3. Collect counters and vefiry them
    idle.prepare_startup_values
    Change APN   ue_name=SAMSUNG_S24_1   apn_name=5gsawro
    Deactivate RRC Inactive feature
    Show Text on Console   [Activate Mobility Profiles]
    Update Parameter   param=actMobilityProfile   value=true

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    logs.Start Tracing On SMOD   smod slave=False

    # STEP 1
    Set Test Variable   ${ue}  SAMSUNG_1
    Set Test Variable   ${serving_cell}  700
    Set Test Variable   ${target_cell}   400

    Show Text on Console   [Decrease attenuation to attach UE to SERVING cell]
    ${rus}   Create List   AHFII  AEHC
    Set Attenuation on Radios   90dB  ${rus}
    Attach UE to Serving Cell   serving_cell=${serving_cell}
    Set Attenuation on Radios   0dB  ${rus}
    idle.increase_counters
    ...    NRMOP_SA_PROFILE_SELECTED_01
    ...    cell=${serving_cell}

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}
    idle.increase_counters
    ...    NRMOP_SA_PROFILE_SELECTED_01
    ...    cell=${target_cell}

    Show Text on Console   [Run traffic and verify attach to TARGET cell]
    Start Downlink Traffic
    Is UE in NR Target Cell   target_cell=${target_cell}
    Wait Traffic Finish and Verify It

    Detach Ue   ${ue}
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${target_cell}

    # STEP 2
    Set Test Variable   ${ue}  NOKIA
    Set Test Variable   ${serving_cell}  700
    Set Test Variable   ${target_cell}   410

    Show Text on Console   [Decrease attenuation to attach UE to SERVING cell]
    ${rus}   Create List   AHFII  AEHC
    Set Attenuation on Radios   90dB  ${rus}
    Attach UE to Serving Cell   serving_cell=${serving_cell}
    Set Attenuation on Radios   0dB  ${rus}
    idle.increase_counters
    ...    NRMOP_SA_PROFILE_SELECTED_02
    ...    cell=${serving_cell}

    Wait For UE Moves to IDLE Mode
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}
    idle.increase_counters
    ...    NRMOP_SA_PROFILE_SELECTED_02
    ...    cell=${target_cell}

    Show Text on Console   [Run traffic and verify attach to TARGET cell]
    Start Downlink Traffic
    Is UE in NR Target Cell   target_cell=${target_cell}
    Wait Traffic Finish and Verify It

    Detach Ue   ${ue}
    idle.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${target_cell}

    # STEP 3
    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  IDLE_PM_COUNTERS
    Verification PM Counters   ${counter_values}  IDLE_PM_COUNTERS

    [Teardown]  Run Keywords
    ...   Stop Data Transfer   DT_DL_${ue}
    ...   AND   Change APN   ue_name=SAMSUNG_S24_1   apn_name=internet
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   Activate RRC Inactive feature
    ...   AND   Update Parameter   param=actMobilityProfile   value=false
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}



Set Attenuation on Radios
    [Arguments]   ${attenuation}  ${rus}
    FOR  ${ru}  IN  @{rus}
        Set Attenuation  ${attenuation}  ${ATTENUATOR['${ru}_${sector_no}']['ports']}  confirm=${TRUE}
    END


Attach UE to Serving Cell
    [Arguments]   ${serving_cell}   ${change_bands}=${False}
    Require Ue   ${ue}  capabilities=${ue}
    Run Keyword If   ${change_bands}   enable_band_config   ${ue}   LTE_2_NR_ALL
    Attach Ue    ${ue}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${serving_cell}  ${pci}   ${ue} not attached to serving cell: ${serving_cell}
    ${ip_addr}   Get Ue Info   ${ue}   IP
    Log To Console   ${SPACE} with IP address: ${ip_addr}
    Set Test Variable   ${ip_addr}


Is UE in NR Target Cell
    [Arguments]   ${target_cell}   ${idle_offset}=0s
    BuiltIn.Sleep   ${idle_offset}   offset add to idle timer
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${target_cell}  ${pci}   ${ue} not attached to target cell: ${target_cell}
    ${ip}   Get Ue Info   ${ue}   IP
    Log To Console   ${SPACE} with IP address: ${ip_addr} \n
    Should Be Equal As Strings   ${ip_addr}  ${ip}   ${ue} changed IP address, check logs


Check UE Attach to Strongest Cell
    [Arguments]   ${cell}   ${is_network_changed}=${True}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${cell}  ${pci}   ${ue} not attached to expected cell: ${cell}
    ${ip}   Get Ue Info   ${ue}   IP
    Log To Console   ${SPACE} with IP address: ${ip}
    Run Keyword If   ${is_network_changed}
    ...      Set Test Variable   ${ip_addr}  ${ip}
    ...  ELSE
    ...      Should Be Equal As Strings   ${ip_addr}  ${ip}   ${ue} changed IP address, check logs


Is UE in LTE Target Cell
    [Arguments]   ${target_cell}
    ${pci}   Verify 4G Attach   ${ue}
    Should Be Equal As Strings   ${target_cell}  ${pci}   ${ue} not attached to target cell: ${target_cell}


Start Downlink Traffic
    [Arguments]   ${tput}=150 Mbits/sec   ${duration}=30s
    Start Data Transfer  dt_name=DT_DL_${ue}  ue_alias=${ue}  direction=DL  interface_name=5gsawro
    ...                  duration=${duration}  buffer=32M  protocol=udp  throughput=${tput}  packet_size=1400
    BuiltIn.Sleep   10s
    Check Data Transfer Is Alive   DT_DL_${ue}


Wait Traffic Finish and Verify It
    [Arguments]   ${tput}=150 Mbits/sec   ${tput_deviation}=10%   ${idle_offset}=10s
    Await Data Transfer Finish    DT_DL_${ue}
    Run Keyword And Continue On Failure
    ...    Verify Average Throughput With Deviation   DT_DL_${ue}  ${tput}  ${tput_deviation}

    ${avg_tput}   Get Average Throughput   dt_name=DT_DL_${ue}
    ${avg_tput}   Evaluate   ${avg_tput} / 1000
    ${avg_tput}   Evaluate   "%.2f" % ${avg_tput}
    Log To Console   DL TPUT measurements: \n\ Expected: ${tput}, \n\ Measured: ${avg_tput} Mbits/sec
    BuiltIn.Sleep   ${idle_offset}   offset add to idle timer


Wait For UE Reconnects from 5G to 4G Network
    Show Text on Console   Wait for 10s UE reconnects from NR to LTE    ${GREEN}
    #BuiltIn.Sleep   10


Wait UE Connects to 5G Network Again
    Show Text on Console   Wait until UE reconnects to NR network    ${GREEN}
    #BuiltIn.Sleep   30


Wait For UE Moves to IDLE Mode
    Show Text on Console   Wait for ${idle_timer} UE moves to IDLE mode    ${GREEN}
    BuiltIn.Sleep   ${idle_timer}


Attenuate Cell To Choose Second Candidate from Reselection
    Show Text on Console   [Attenuate cell to choose second candidate from reselection]
    Set Attenuation  90dB  ${ATTENUATOR['AHFII_${sector_no}']['ports']}  confirm=${TRUE}
