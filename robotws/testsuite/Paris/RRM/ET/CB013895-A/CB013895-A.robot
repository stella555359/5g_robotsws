*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com
...   description: Test suite for feature CB013895 - SR - VRF - RRM - ET
...   Requested topology : CLOUD_5G_O_E_AP_LOOO    SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1

Resource            ./resources/robot/CB013895-Common-Keywords.robot

*** Variables ***

${SCF_FILE_PATH_1}                    /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-A/resources/config/scf_MRBTS-6Cells_130Mhz_1.xml
${IPHY_FILE_PATH_1}                   /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-A/resources/config/iphy.xml
${Script_ue_schedule_analysis}        /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-A/resources/python/ue_schedule_analysis.py

${basic_setup_cfg_B1}               basic_setup_B1.cfg

*** Test Cases ***

[1][1.0] CB013895-O-A-1-Check_More_than_16Ues_UL_Scheduled_2cores-2cells_SRS_To_SSB_Fallback _tdLte_0ms
    [Setup]    Run Keywords    CB013895-Common-Keywords.Test Setup
	...                         AND
	...                        Test Setup CB013895-SR_B1
    [Documentation]
    ...    | Description | [1][1.0] CB013895-O-A-1-Check_More_than_16Ues_UL_Scheduled_2cores-2cells_SRS_To_SSB_Fallback _tdLte_0ms |
    ...    | . | .       |
    ...    | Test Steps  | 1. test preparation |
    ...    | Test Steps  | 2. CellSetup |
    ...    | Test Steps  | 3. Start Capture SosReport |
    ...    | Test Steps  | 4. Start traffic for first 30 UEs (Low_Load) |
    ...    | Test Steps  | 5. Collect Ttitrace Logs (Low_Load) |
    ...    | Test Steps  | 6. Continue with remaining 50 UEs (Low_Load) |
    ...    | Test Steps  | 7. Start traffic for all 80 UEs (High_Load) |
    ...    | Test Steps  | 8. Collect Ttitrace Logs (High_Load) |
    ...    | Test Steps  | 9. Collect l1l2bip Logs |
    ...    | Test Steps  | 10. Start traffic for all 80 UEs (Low_Load_Ramp) |
    ...    | Test Steps  | 11. Stop traffic for 50 UEs (group2) |
    ...    | Test Steps  | 12. Collect Ttitrace Logs (Low_Load_Ramp) |
    ...    | Test Steps  | 13. Stop traffic for 30 UEs (group1) |
    ...    | Test Steps  | 14. Stops Btslogs from Local machine |
    ...    | Test Steps  | 15. Stop Capture SosReport |
    ...    | Test Steps  | 16. TTI Conversion and CSV Generation |
    ...    | Test Steps  | 17. Verify that K2 |
    ...    | Test Steps  | 18. Check Slot Processing Duration Budget |
    ...    | Test Steps  | 19. Extract Data From File |
    ...    | Test Steps  | 20. Check Maximum scheduled UEs in UL |
    ...    | Test Steps  | 21. Check Counters M55308C18001, M55308C18002 |
    ...    | Test Steps  | 22. Test Teardown |

    ##########################################################################################
    #2. CellSetup
    ##########################################################################################
    Wait Until Keyword Succeeds    1200    10   ADMIN Check Bts Status    status=OnAir
    BuiltIn.Sleep    30s
    ##########################################################################################
    #3. Start Capture SosReport
    ##########################################################################################
    #Run keyword and continue on failure    Start Capture SosReport
    ##########################################################################################
    #4. Start traffic for first 30 UEs (Low_Load)
    ##########################################################################################
    # UE IDs mapping: 80 UEs total - Split into two groups (1-30, 31-80)
    @{ue_ids_group1}=    Create List    1    2    3    4    5    6    7    8    9    10
    ...                                 11    12    13    14    15    16    17    18    19    20
    ...                                 21    22    23    24    25    26    27    28    29    30

    @{ue_ids_group2}=    Create List    31    32    33    34    35    36    37    38    39    40
    ...                                 41    42    43    44    45    46    47    48    49    50
    ...                                 51    52    53    54    55    56    57    58    59    60
    ...                                 61    62    63    64    65    66    67    68    69    70
    ...                                 71    72    73    74    75    76    77    78    79    80

    # Start traffic for first 30 UEs
    FOR    ${ue_id}    IN    @{ue_ids_group1}
        Traffic_DL_UL_SA Low_Load    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
    ##########################################################################################
    #5. Collect Ttitrace Logs (Low_Load)
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    2s
    OperatingSystem.create directory    ${out}/Low_Load/
    Stop Ttitrace    log_dir=${out}/Low_Load/
    ##########################################################################################
    #6. Continue with remaining 50 UEs (Low_Load)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group2}
        Traffic_DL_UL_SA Low_Load    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
    ##########################################################################################
    #7. Start traffic for all 80 UEs (High_Load)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group1}
        Traffic_DL_UL_SA High_Load    ue=${ue_id}
    END
    FOR    ${ue_id}    IN    @{ue_ids_group2}
        Traffic_DL_UL_SA High_Load    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
    ##########################################################################################
    #8. Collect Ttitrace Logs (High_Load)
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    20s
    OperatingSystem.create directory    ${out}/High_Load/
    Stop Ttitrace    log_dir=${out}/High_Load/
    ##########################################################################################
    #9. Collect l1l2bip Logs
    ##########################################################################################
    Start Collect interface mirroring with nr phy cell ids
    BuiltIn.Sleep    2s
    Stop Collect interface mirroring with nr phy cell ids
    ##########################################################################################
    #10. Start traffic for all 80 UEs (Low_Load_Ramp)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group1}
        Traffic_DL_UL_SA Low_Load_Ramp    ue=${ue_id}
    END
    FOR    ${ue_id}    IN    @{ue_ids_group2}
        Traffic_DL_UL_SA Low_Load_Ramp    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
    ##########################################################################################
    #11. Stop traffic for 50 UEs (group2)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group2}
        Traffic_DL_UL_SA_stop    ue=${ue_id}
    END
	##########################################################################################
    #12. Collect Ttitrace Logs (Low_Load_Ramp)
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    2s
    OperatingSystem.create directory    ${out}/Low_Load_Ramp/
    Stop Ttitrace    log_dir=${out}/Low_Load_Ramp/
    ##########################################################################################
    #13. Stop traffic for 30 UEs (group1)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group1}
        Traffic_DL_UL_SA_stop    ue=${ue_id}
    END
    ##########################################################################################
    #14. Stops Btslogs from Local machine
    ##########################################################################################
    # Run Keyword And Ignore Error    Stops Btslogs from Local machine
    ##########################################################################################
    #15. Stop Capture SosReport
    ##########################################################################################
    #Run keyword and continue on failure    Stop Capture SosReport
    ##########################################################################################
    #16. TTI Conversion and CSV Generation
    ##########################################################################################
    Run keyword and continue on failure    TTI Conversion and CSV Generation Low_Load
    Run keyword and continue on failure    TTI Conversion and CSV Generation High_Load
    Run keyword and continue on failure    TTI Conversion and CSV Generation Low_Load_Ramp
    ##########################################################################################
    #17. Verify that K2
    ##########################################################################################
    Log    ==> PHASE: K2 Verification <==    console=yes

    # Low Load K2 Check
    ${k2_low_result}=    Run Keyword And Return Status    Check K2 Occurrences Low_Load K2 In 2
    Run Keyword If    ${k2_low_result}
    ...    Log    PASS: Low Load K2 = [2] - All occurrences valid    console=yes
    ...    ELSE
    ...    Run Keywords
    ...    Log    FAIL: Low Load K2 = [2] - Check failed    console=yes
    ...    AND    Run Keyword And Continue On Failure    Fail    Low Load K2 = [2] - Check failed

    # High Load K2 Check
    ${k2_high_result}=    Run Keyword And Return Status    Check K2 Occurrences High_Load K2 In 2 3 4
    Run Keyword If    ${k2_high_result}
    ...    Log    PASS: High Load K2 = [2,3,4] - All occurrences valid    console=yes
    ...    ELSE
    ...    Run Keywords
    ...    Log    FAIL: High Load K2 = [2,3,4] - Check failed    console=yes
    ...    AND    Run Keyword And Continue On Failure    Fail    High Load K2 = [2,3,4] - Check failed

    # Ramp K2 Check (try both options)
    ${k2_ramp_option1}=    Run Keyword And Return Status    Check K2 Occurrences Low_Load_Ramp K2 In 2
    ${k2_ramp_option2}=    Run Keyword And Return Status    Check K2 Occurrences Low_Load_Ramp K2 In 2 3 4
    Run Keyword If    ${k2_ramp_option1}
    ...    Log    PASS: Ramp K2 = [2] - All occurrences valid    console=yes
    ...    ELSE IF    ${k2_ramp_option2}
    ...    Log    PASS: Ramp K2 = [2,3,4] - All occurrences valid    console=yes
    ...    ELSE
    ...    Run Keywords
    ...    Log    FAIL: Ramp K2 - Neither [2] nor [2,3,4] options passed    console=yes
    ...    AND    Run Keyword And Continue On Failure    Fail    Ramp K2 - Neither [2] nor [2,3,4] options passed

    ##########################################################################################
    #18. Check Slot Processing Duration Budget
    ##########################################################################################
    Log    ==> PHASE: Slot Processing Duration Verification <==    console=yes

    # Low Load Slot Processing Check (500 µs)
    ${slot_low_result}=    Run Keyword And Return Status    Check Slot Processing Duration Budget Low_Load    500
    Run Keyword If    ${slot_low_result}
    ...    Log    PASS: Low Load Slot Processing = 500µs - All occurrences valid    console=yes
    ...    ELSE
    ...    Run Keywords
    ...    Log    FAIL: Low Load Slot Processing = 500µs - Check failed    console=yes
    ...    AND    Run Keyword And Continue On Failure    Fail    Low Load Slot Processing = 500µs - Check failed

    # High Load Slot Processing Check (750 µs or 500+750 µs)
    ${slot_high_750}=    Run Keyword And Return Status    Check Slot Processing Duration Budget High_Load    750
    ${slot_high_switch}=    Run Keyword And Return Status    Check Slot Processing Duration Budget switch High_Load    500    750
    Run Keyword If    ${slot_high_750}
    ...    Log    PASS: High Load Slot Processing = 750µs - All occurrences valid    console=yes
    ...    ELSE IF    ${slot_high_switch}
    ...    Log    PASS: High Load Slot Processing = 500+750µs - All occurrences valid    console=yes
    ...    ELSE
    ...    Run Keywords
    ...    Log    FAIL: High Load Slot Processing - Neither 750µs nor 500+750µs options passed    console=yes
    ...    AND    Run Keyword And Continue On Failure    Fail    High Load Slot Processing - Neither 750µs nor 500+750µs options passed

    # Ramp Slot Processing Check (500 µs or 500+750 µs)
    ${slot_ramp_500}=    Run Keyword And Return Status    Check Slot Processing Duration Budget Low_Load_Ramp    500
    ${slot_ramp_switch}=    Run Keyword And Return Status    Check Slot Processing Duration Budget switch Low_Load_Ramp    500    750
    Run Keyword If    ${slot_ramp_500}
    ...    Log    PASS: Ramp Slot Processing = 500µs - All occurrences valid    console=yes
    ...    ELSE IF    ${slot_ramp_switch}
    ...    Log    PASS: Ramp Slot Processing = 500+750µs - All occurrences valid    console=yes
    ...    ELSE
    ...    Run Keywords
    ...    Log    FAIL: Ramp Slot Processing - Neither 500µs nor 500+750µs options passed    console=yes
    ...    AND    Run Keyword And Continue On Failure    Fail    Ramp Slot Processing - Neither 500µs nor 500+750µs options passed

    Log    ==> END OF VERIFICATION PHASES <==    console=yes
    ##########################################################################################
    #19. Extract Data From File
    ##########################################################################################
    Run keyword and continue on failure    Extract Data From File Low_Load
    Run keyword and continue on failure    Extract Data From File High_Load
    Run keyword and continue on failure    Extract Data From File Low_Load_Ramp
    ##########################################################################################
    #20. Check Maximum scheduled UEs in UL
    ##########################################################################################
    Run keyword and continue on failure    Check Maximum scheduled UEs in UL
    ##########################################################################################
    #21. Check Counters M55308C18001, M55308C18002
    ##########################################################################################
    BuiltIn.Sleep   360s    # Sleep 360 s = 6 min for a PM xml file creation in each 5 min
    Run keyword and continue on failure    Collect and Check Counter
    ##########################################################################################
    #22. Test Teardown
    ##########################################################################################
    [Teardown]    CB013895-Common-Keywords.Test Teardown