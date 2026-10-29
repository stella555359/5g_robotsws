*** Settings ***
Documentation
...    author:  Adam Kropiwnicki
...    contact: adam.kropiwnicki@nokia.com

Variables      resources/test_constants.py

Library        resources/test_specific_keywords.py
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/pm_counters.py
Resource       resources/test_specific_keywords.robot
Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

#Suite Setup      Common Suite Setup
#Suite Teardown   Common Suite Teardown

*** Test Cases ***
[1]5G22R4_7145_RRM_002_40_MHz_FDD_cell_UL_DL_throughput_test
#    [Setup]   Common Preconditions
    Deattenuate Attach Cell   ${tl.attenuators}
    ${reference_counters}=   Get Throughput Counters
    Require UE   ${UE_ALIAS}   capabilities=REAL_UE
    Attach UE With Bi Directional Data Transfer   ${TPUT_DURATION_7145}   ${UE_ALIAS}
    Await Bi Directional Data Transfer And Detach UE   ${UE_ALIAS}
    Check 5G21A_6761_RRM_009
    ${counters}=   Get Throughput Counters   ${reference_counters}
    Verify Throughput Counters   ${counters}
#    [Teardown]   Common Postconditions


[1]5G22R4_CB008930_OAM_001 Support full TX power in uplink transmission FR1 On-line feature activation - SA
    [Documentation]     The purpose of this TC is to check if UL traffic is still ongoing, can be received
    ...                 and no throughput degradation issue is seen on both UEs for both online activation
    ...                 and deactivation of the feature.
#    [Setup]   Common Preconditions
    Perform Commissioning 8930              false

    Deattenuate Attach Cell   ${tl.attenuators}   ${ATTACH_CELL_8930}
    Require UE   ${UE_ALIAS}   capabilities=REAL_UE
    Require UE   ${UE_ALIAS_2}   capabilities=REAL_UE
    Attach UE With Data Transfer   ${TPUT_DURATION_8930}   ${UE_ALIAS}   direction=UL
    Attach UE With Data Transfer   ${TPUT_DURATION_8930}   ${UE_ALIAS_2}   direction=UL
    Verify Average Throughput With Deviation  ${UE_ALIAS}_DT_UL  ${EXPECTED_TPUT_8930_UE_1}  ${TPUT_DEVIATION}
    Verify Average Throughput With Deviation  ${UE_ALIAS_2}_DT_UL  ${EXPECTED_TPUT_8930_UE_2}  ${TPUT_DEVIATION}

    Perform Commissioning 8930              true

    Verify Average Throughput With Deviation  ${UE_ALIAS}_DT_UL  ${EXPECTED_TPUT_8930_UE_1}  ${TPUT_DEVIATION}
    Verify Average Throughput With Deviation  ${UE_ALIAS_2}_DT_UL  ${EXPECTED_TPUT_8930_UE_2}  ${TPUT_DEVIATION}
    Await Data Transfer And Detach UE   ${UE_ALIAS}   UL
    Await Data Transfer And Detach UE   ${UE_ALIAS_2}   UL
    Attach UE With Data Transfer   ${TPUT_DURATION_8930}   ${UE_ALIAS}   direction=UL
    Attach UE With Data Transfer   ${TPUT_DURATION_8930}   ${UE_ALIAS_2}   direction=UL
    Verify Average Throughput With Deviation  ${UE_ALIAS}_DT_UL  ${EXPECTED_TPUT_8930_UE_1}  ${TPUT_DEVIATION}
    Verify Average Throughput With Deviation  ${UE_ALIAS_2}_DT_UL  ${EXPECTED_TPUT_8930_UE_2}  ${TPUT_DEVIATION}

    Perform Commissioning 8930              false

    Verify Average Throughput With Deviation  ${UE_ALIAS}_DT_UL  ${EXPECTED_TPUT_8930_UE_1}  ${TPUT_DEVIATION}
    Verify Average Throughput With Deviation  ${UE_ALIAS_2}_DT_UL  ${EXPECTED_TPUT_8930_UE_2}  ${TPUT_DEVIATION}
    Await Data Transfer And Detach UE   ${UE_ALIAS}   UL
    Await Data Transfer And Detach UE   ${UE_ALIAS_2}   UL
    Attach UE With Data Transfer   ${TPUT_DURATION_8930}   ${UE_ALIAS}   direction=UL
    Attach UE With Data Transfer   ${TPUT_DURATION_8930}   ${UE_ALIAS_2}   direction=UL
    Verify Average Throughput With Deviation  ${UE_ALIAS}_DT_UL  ${EXPECTED_TPUT_8930_UE_1}  ${TPUT_DEVIATION}
    Verify Average Throughput With Deviation  ${UE_ALIAS_2}_DT_UL  ${EXPECTED_TPUT_8930_UE_2}  ${TPUT_DEVIATION}
    Await Data Transfer And Detach UE   ${UE_ALIAS}   UL
    Await Data Transfer And Detach UE   ${UE_ALIAS_2}   UL
#    [Teardown]   Common Postconditions
#

[1]5G23R2_7402_OAM_001
#    [Setup]   Common Preconditions
    Backup ims2

    Change ims2 To Empty File
    Trigger Sanity Check And Expect Fault      ${INVALID_CONFIG_CHECKPOINT_NAME}
    Restore ims2
    Trigger Sanity Check And Expect Success    ${INVALID_CONFIG_CHECKPOINT_NAME}

    Remove Read Permissions From ims2
    Trigger Sanity Check And Expect Fault      ${INVALID_CONFIG_CHECKPOINT_NAME}
    Restore ims2
    Trigger Sanity Check And Expect Success    ${INVALID_CONFIG_CHECKPOINT_NAME}

    Change ims2 To Invalid File
    Trigger Sanity Check And Expect Fault      ${INVALID_CONFIG_CHECKPOINT_NAME}
    Restore ims2
    Trigger Sanity Check And Expect Success    ${INVALID_CONFIG_CHECKPOINT_NAME}

    Remove ims2
    Trigger Sanity Check And Expect Fault      ${MISSING_CONFIG_CHECKPOINT_NAME}
    Restore ims2
    Trigger Sanity Check And Expect Success    ${MISSING_CONFIG_CHECKPOINT_NAME}
    [Teardown]   Run Keywords
    ...          Restore ims2      #                   AND
#    ...          Common Postconditions


5G19B_0749_RRM_002       # Samsung in NSA/disable VoNR in nvitems (74233)
#    [Setup]   Common Preconditions
    Set Redirection Fallback
    AdminUtils.Lock Cells    ${CELLS_TO_LOCK}
    ${pi_dir}=    Collect Counters    log_name=fallback_counters_before    target_dir=${OUTPUT_DIR}
    ${outcome}    ${counters_before_test}    Run Keyword And Ignore Error
    ...    Get Relevant Pm Counters    ${pi_dir}    ${FALLBACK_COUNTERS}
    # Attenuate all
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_NSA   capabilities=NSA
    Require UE   UE_SA    capabilities=SA
    GnbCounter.Wait For Next Pm Period
    Log To Console    Attaching UEs
    Attach UE    ue_alias=UE_NSA
    Attach UE    ue_alias=UE_SA
    Log To Console    Waiting for idle
    Sleep    30s    Enter Idle
    Log To Console    Starting voice call
    Start Voice Call    vc_alias=VC_OUT   ue_alias=UE_NSA   to=UE_SA    duration=1min
    Await Incoming Voice Call   vc_alias=VC_OUT  ue_alias=UE_SA
    Sleep   20s
    Stop Voice Call   vc_alias=VC_OUT
    Await Voice Call Finish   vc_alias=VC_OUT
    Log To Console    Voice call finished
    Detach UE    ue_alias=UE_NSA
    Detach UE    ue_alias=UE_SA
    GnbCounter.Wait For Next Pm Period
    Log To Console    Verifying counters
    ${pi_dir_after}=    Collect Counters    log_name=fallback_counters_after    target_dir=${OUTPUT_DIR}
    ${counters_after_test}=    Get Relevant Pm Counters    ${pi_dir_after}    ${FALLBACK_COUNTERS}
    IF    "${outcome}" == "PASS"
        Log To Console    Counters were up before test started, filtering
        ${counters_after_test}=    Filter Old Counters    ${counters_before_test}    ${counters_after_test}
    END

    Check Last N Values Higher Than X    ${counters_after_test}    4    0    ${ATTACH_CELL}
    [Teardown]    Run Keywords
    ...           Detach UE    ue_alias=UE_NSA     AND
    ...           Detach_UE    ue_alias=UE_SA      AND
    ...           AdminUtils.Unlock All Cells      #AND
#    ...           Common Postconditions


5G19B_0749_RRM_005      # Samsung in NSA/disable VoNR in nvitems (74233)
#    [Setup]   Common Preconditions
    Set Redirection Fallback
    AdminUtils.Lock Cells    ${CELLS_TO_LOCK}
    ${pi_dir}=    Collect Counters    log_name=fallback_counters_before    target_dir=${OUTPUT_DIR}
    ${outcome}    ${counters_before_test}    Run Keyword And Ignore Error
    ...    Get Relevant Pm Counters    ${pi_dir}    ${FALLBACK_COUNTERS}
    Deattenuate Attach Cell   ${tl.attenuators}
    Require UE   UE_NSA   capabilities=NSA
    Require UE   UE_SA    capabilities=SA
    GnbCounter.Wait For Next Pm Period
    Log To Console    Attaching UEs
    Attach UE    ue_alias=UE_NSA
    Attach UE    ue_alias=UE_SA
    Log To Console    Starting voice call
    Start Voice Call    vc_alias=VC_OUT   ue_alias=UE_SA   to=UE_NSA    duration=1min
    Await Incoming Voice Call   vc_alias=VC_OUT   ue_alias=UE_NSA
    Sleep   20s
    Stop Voice Call   vc_alias=VC_OUT
    Await Voice Call Finish   vc_alias=VC_OUT
    Log To Console    Voice call finished
    Detach UE    ue_alias=UE_NSA
    Detach UE    ue_alias=UE_SA
    GnbCounter.Wait For Next Pm Period
    Log To Console    Verifying counters
    ${pi_dir_after}=    Collect Counters    log_name=fallback_counters_after    target_dir=${OUTPUT_DIR}
    ${counters_after_test}=    Get Relevant Pm Counters    ${pi_dir_after}    ${FALLBACK_COUNTERS}
    IF    "${outcome}" == "PASS"
        Log To Console    Counters were up before test started, filtering
        ${counters_after_test}=    Filter Old Counters    ${counters_before_test}    ${counters_after_test}
    END

    Check Last N Values Higher Than X    ${counters_after_test}    4    0    ${ATTACH_CELL}
    [Teardown]    Run Keywords
    ...           Detach UE    ue_alias=UE_NSA     AND
    ...           Detach_UE    ue_alias=UE_SA      AND
    ...           AdminUtils.Unlock All Cells      #AND
#    ...           Common Postconditions


22R3_8562_OAM_003
#    [Setup]   Common Preconditions
    ${number_of_cpri_rmods}=  Get Number Of CPRI RMODs
    Start Antl monitoring   ${OUTPUT_DIR}/selenium_logs
    Sleep  60s
    ${antl_file}=   Stop Antl monitoring
    Analyze Antl Monitoring File   ${number_of_cpri_rmods}   ${antl_file}
#    [Teardown]   Common Postconditions


22R1_5832_TRS_002
#    [Setup]   Common Preconditions
    Set CB005832 parameters
    Change SFP State   Locked
    Sleep  30s
    Assert FID 61009   ${True}
    Change SFP State   Unlocked
    Sleep  30s
    Assert FID 61009   ${False}
    Require UE   ${UE_ALIAS}   capabilities=REAL_UE
    Attach UE with Data Transfer   15s   ${UE_ALIAS}
    Sleep  15s
    Await Data Transfer And Detach UE   ${UE_ALIAS}
    [Teardown]    Change SFP State    Unlocked   #AND
#    ...          Common Postconditions

