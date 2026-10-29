*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com

#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/keywords_11041.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/counters.robot
#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007516/resources/keywords_7516.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/resources/keywords_8225.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/resources/specific_keywords_8225.py
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/specific_keywords_11041.py    WITH NAME    pagstra
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils   WITH NAME    AdminUtils
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/resources/pagstra_pm_counters.py


*** Keywords ***
CB011041_A_B1_Successful_RAN_Paging_in_RRC_Inactive_State_DL_User_Plane_Data_from_UPF_with_Priority_RAN_Paging
    [Documentation]   This user scenario describes the gNB behavior for UE in RRC_INACTIVE state that is successfully transitioned
    ...               to RRC_CONNECTED state due to RAN Paging with priority triggered due to DL user plane data arrival
    ...               from UPF and aims to count the counters for the successful scenario.
    ...            TEST STEPS
    ...             1. Attach NR_PCI=410 -> wait for INACTIVE -> TPUT -> Resume to PCI=410 -> Verify Paging and Resume messages
    ...             2. Wait for INACTIVE -> Block PCI=410 -> TPUT -> Resume to PCI=400 -> Verify Paging and Resume messages
    ...             3. Wait for INACTIVE -> Remove ranac and unblock PCI=410 -> Block PCI=400 -> Wait for RRC Setup and next IDLE -> Verify messages
    # PRECONDITIONS
    pagstra.prepare_startup_values
    Get timers settings from BTS
    ${rus}   Create List   AHFII  AHLOB
    Set Attenuation on Radios   90dB  ${rus}
    Set Attenuation  15dB  ${ATTENUATOR['AEHC_${sector_no}']['ports']}  confirm=${TRUE}
    Set Test Variable   ${blocked_cell}  ${400}
    block_nr_cell   cell_id=${blocked_cell}
    Set Test Variable   ${serving_cell}   410
    Set Test Variable   ${ue}   ASUS

    wro4_pm.sync_to_next_reporting_interval   offset=1
    ${pm_start_time}   Get Time  epoch
    logs.Start Tracing On SMOD   smod slave=False

    Show Text on Console   STEP 1 - Resume UE from Inactive to Connected state due to RAN Paging (DL Tput)
    ...                    colour=${REDBG}
    ...                    show_timestamp=no

    Attach UE to Serving Cell   ${serving_cell}
    Wait Inactivity timer expired and UE moves to INACTIVE state
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    is_ue_in_inactive_state   pcap_file=${logs_path}  msg_occurrence=1
    pagstra.increase_counters
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    unblock_nr_cell   cell_id=${blocked_cell}
    # AdminUtils.wait_for_cell_availability   cell_number=${blocked_cell}
    BuiltIn.Sleep   20s    wait for cell onAir before paging
    Show Text on Console   [Start DL traffic and verify UE is in serving cell, pci:${serving_cell}]
    Start Downlink Traffic
    Check UE Attach   cell=${serving_cell}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO

    ${paging_occurrences}   check_paging_msg   pcap_file=${logs_path}   paging_priority=2   ue_identity=iRNTI
    ${paging_msg_step_1}   Set Variable   ${paging_occurrences}
    pagstra.increase_paging_counters_with_repetitions   ${paging_msg_step_1}
    pagstra.increase_counters
    ...    RAN_PAG_SENT_INITIAL
    ...    DELAY_PAG_RRC_INCT_CON_PAGSTRA
    pagstra.increase_counters
    ...    NF1CD_F1AP_PAGING_RECD
    ...    NF1CD_RAN_PAGING_SUCC_SENT
    ...    multiplier=${paging_msg_step_1}
    FOR  ${cell}  IN  @{cells}
        pagstra.increase_counters
        ...    NRPAG_RAN_PAGING_SUCC_SENT
        ...    cell=${cell}
        ...    multiplier=${paging_msg_step_1}
    END

    check_rrc_resume_msg_in_pcap_file   pcap_file=${logs_path}  direction=DL  msg_occurence=1
    pagstra.increase_counters
    ...    RRC_RESUME_REQUEST1_RANPAG
    ...    RRC_RESUME_REQUEST1_PAGSTRA
    ...    cell=${serving_cell}

    Wait Traffic Finish and Verify It


    Show Text on Console   STEP 2 - Block serving cell and resume UE to neighbour cell
    ...                    colour=${REDBG}
    ...                    show_timestamp=no

    Wait Inactivity timer expired and UE moves to INACTIVE state
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    is_ue_in_inactive_state   pcap_file=${logs_path}  msg_occurrence=2
    pagstra.increase_counters
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Set Test Variable   ${blocked_cell}  ${serving_cell}
    block_nr_cell   cell_id=${blocked_cell}
    Set Test Variable   ${serving_cell}   400
    Wait for MIB to Neighbour Cell   cell=${serving_cell}

    Show Text on Console   [Start DL traffic and verify UE is in serving cell, pci:${serving_cell}]
    Start Downlink Traffic
    Check UE Attach   cell=${serving_cell}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO

    ${paging_occurrences}   check_paging_msg   pcap_file=${logs_path}   paging_priority=2   ue_identity=iRNTI
    ${paging_msg_step_2}   Evaluate   ${paging_occurrences} - ${paging_msg_step_1}
    pagstra.increase_paging_counters_with_repetitions   ${paging_msg_step_2}
    pagstra.increase_counters
    ...    RAN_PAG_SENT_INITIAL
    ...    DELAY_PAG_RRC_INCT_CON_PAGSTRA
    pagstra.increase_counters
    ...    NF1CD_F1AP_PAGING_RECD
    ...    NF1CD_RAN_PAGING_SUCC_SENT
    ...    multiplier=${paging_msg_step_2}

    ${cells_to_paging}   Get Paging Cells without Blocked   ${blocked_cell}
    FOR  ${cell}  IN  @{cells_to_paging}
        pagstra.increase_counters
        ...    NRPAG_RAN_PAGING_SUCC_SENT
        ...    cell=${cell}
        ...    multiplier=${paging_msg_step_2}
    END

    check_rrc_resume_msg_in_pcap_file   pcap_file=${logs_path}  direction=DL  msg_occurence=2
    pagstra.increase_counters
    ...    RRC_RESUME_REQUEST1_RANPAG
    ...    RRC_RESUME_REQUEST1_PAGSTRA
    ...    cell=${serving_cell}

    Wait Traffic Finish and Verify It

    Show Text on Console   STEP 3 - Remove ranAC from neighbour cell (no Inactive), block serving cell and resume UE to neighbour - RRC Setup
    ...                    colour=${REDBG}
    ...                    show_timestamp=no

    Wait Inactivity timer expired and UE moves to INACTIVE state
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO
    is_ue_in_inactive_state   pcap_file=${logs_path}  msg_occurrence=3
    pagstra.increase_counters
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Set test Variable   ${blocked_cell}  ${serving_cell}
    Set Test Variable   ${serving_cell}   410

    change_ranac_for_serving_cell   action=delete  cell=${serving_cell}
    unblock_nr_cell   cell_id=${serving_cell}
    block_nr_cell   cell_id=${blocked_cell}
    pagstra.increase_counters
    ...    INACT_UE_CTXT_REL_AMF_INIT
    ...    cell=${blocked_cell}

    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO   offset=5s
    check_rna_update_msg   pcap_file=${logs_path}  message=rrcResumeRequest

    Wait for RRC Setup to Neighbour Cell   cell=${serving_cell}
    pagstra.increase_counters
    ...    NRRCC_RRC_RESUME_REQUEST
    ...    NRRCC_RRC_RESUME_FALLBACK_ATT
    ...    NRRCC_RRC_RESUME_FALLBACK_SUCC
    ...    cell=${serving_cell}

    Wait Inactivity timer expired and UE moves to IDLE state
    pagstra.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    Show Text on Console   [Start DL traffic and verify UE is in serving cell, pci:${serving_cell}]
    Start Downlink Traffic
    Check UE Attach   cell=${serving_cell}
    ${logs_path}   logs.Stop Tracing And Download Logs From SMOD   stop_tracing=NO

    ${paging_occurrences}   check_paging_msg   pcap_file=${logs_path}   paging_priority=2   ue_identity=fiveG-S-TMSI
    ${paging_msg_step_3}   Set Variable   ${paging_occurrences}
    pagstra.increase_counters
    ...    NF1CD_F1AP_PAGING_RECD
    ...    multiplier=${paging_msg_step_3}

    Wait Traffic Finish and Verify It

    Detach Ue   ${ue}
    pagstra.increase_counters
    ...    NRRCC_RRC_RELEASE_IMM_NR
    ...    NRRCC_RRC_RELEASE_SENT
    ...    cell=${serving_cell}

    wro4_pm.sync_to_next_reporting_interval
    ${pm_stop_time}   Get Time   epoch
    ${log_path}   logs.Stop Tracing And Download Logs From SMOD
    ${counter_values}   Collect Counters from Given Time    ${pm_start_time}  ${pm_stop_time}  PAGSTRA_PM_COUNTERS
    recalculate_time_delay_counter   ${counter_values}
    Verification PM Counters   ${counter_values}  PAGSTRA_PM_COUNTERS

    [Teardown]   Run Keywords
    ...         Stop Data Transfer   DT_DL_${ue}
    ...   AND   Detach Ue   ${ue}
    ...   AND   logs.Stop Tracing On SMOD
    ...   AND   Run Keyword And Ignore Error   unblock_nr_cell   cell_id=400
    ...   AND   Run Keyword And Ignore Error   unblock_nr_cell   cell_id=410
    ...   AND   change_ranac_for_serving_cell   action=update  cell=410
    ...   AND   Set Attenuation  0dB  ${ATTENUATOR['SECTOR_${sector_no}']['ports']}  confirm=${TRUE}



Check UE Attach
    [Arguments]   ${cell}   ${same_ip}=${True}
    ${pci}   Verify 5G SA Attach   ${ue}
    Should Be Equal As Strings   ${cell}  ${pci}   ${ue} changed serving cell to: ${pci}
    ${ip}   Get Ue Info   ${ue}   IP
    Log To Console   ${SPACE} with IP address: ${ip_addr} \n
    Run Keyword If  ${same_ip}   Should Be Equal As Strings   ${ip_addr}  ${ip}   ${ue} changed IP address, check logs


Wait for MIB to Neighbour Cell
    [Arguments]   ${cell}
    Wait Until Keyword Succeeds   1min  15s  Check UE Attach   cell=${cell}


Wait for RRC Setup to Neighbour Cell
    [Arguments]   ${cell}
    Wait Until Keyword Succeeds   1min  15s  Check UE Attach   cell=${cell}


Get Paging Cells without Blocked
    [Arguments]   ${blocked_cell}
    ${cells_to_paging}   Set Variable   ${cells}
    Remove Values From List   ${cells_to_paging}  ${blocked_cell}
    [Return]   ${cells_to_paging}
