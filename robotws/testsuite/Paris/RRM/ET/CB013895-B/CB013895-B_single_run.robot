*** Settings ***
Documentation
...   author: Mansour Medini
...   contact: mansour.medini@nokia.com
...   description: Test suite for feature CB013895 - SR - VRF - RRM - ET
...   Requested topology : CLOUD_5G_O_E_AP_LOOO    SA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_RJIO_5_1

Resource            ./resources/robot/CB013895-Common-Keywords.robot

Force Tags      CA_VRF_RRM    QCD_MN_RAN    QCP_RAN_VRF   SBTS00

*** Variables ***

${SCF_FILE_PATH_1}                    /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-B/resources/config/scf_MRBTS-6Cells_100Mhz_1.xml
${IPHY_FILE_PATH_1}                   /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-B/resources/config/iphy.xml
${Script_ue_schedule_analysis}        /home/ute/MN/UTE/robotws/testsuite/Paris/RRM/ET/CB013895-B/resources/python/ue_schedule_analysis.py

${basic_setup_cfg_B1}               basic_setup_B1.cfg

*** Test Cases ***

[1][1.0] CB013895-O-B-1-Check_More_than_16Ues_UL_Scheduled_2cores-1cell_SRS_To_SSB_Fallback _tdLte_0ms
    [Setup]    CB013895-Common-Keywords.Test Setup
    [Documentation]
    ...    | Description | [1][1.0] CB013895-O-B-1-Check_More_than_16Ues_UL_Scheduled_2cores-1cell_SRS_To_SSB_Fallback _tdLte_0ms |
    ...    | . | .       |
    ...    | Test Steps  | 1. test preparation |
    ...    | Test Steps  | 2. Update bsr package BSR_AQQJ_4_H4 and BSR_AQQJ_6_H6 artifactory |
    ...    | Test Steps  | 3. Set CB013895 Rad Parameters |
    ...    | Test Steps  | 4. SCF commissioning |
    ...    | Test Steps  | 5. iphy commissioning |
    ...    | Test Steps  | 6. Configure UTE ETH3 |
    ...    | Test Steps  | 7. Set New basic_setup_cfg in WTS |
    ...    | Test Steps  | 8. Do UL and DL traffic SA |
    ...    | Test Steps  | 9. Collect Ttitrace Logs |
    ...    | Test Steps  | 10. Stop traffic |
    ...    | Test Steps  | 11. Stops Btslogs from Local machine |
    ...    | Test Steps  | 12. Test Setup CB013895-SR_B1 |
    ...    | Test Steps  | 13. CellSetup |
    ...    | Test Steps  | 14. Start Capture SosReport |
    ...    | Test Steps  | 15. Start traffic for all 35 UEs (Low_Load) |
    ...    | Test Steps  | 16. Collect Ttitrace Logs (Low_Load) |
    ...    | Test Steps  | 17. Start traffic for all 35 UEs (High_Load) |
    ...    | Test Steps  | 18. Collect Ttitrace Logs (High_Load) |
    ...    | Test Steps  | 19. Collect l1l2bip Logs |
    ...    | Test Steps  | 20. Start traffic for all 35 UEs (Low_Load_Ramp) |
    ...    | Test Steps  | 21. Collect Ttitrace Logs (Low_Load_Ramp) |
    ...    | Test Steps  | 22. Stop traffic for all 35 UEs |
    ...    | Test Steps  | 23. Stops Btslogs from Local machine |
    ...    | Test Steps  | 24. Stop Capture SosReport |
    ...    | Test Steps  | 25. TTI Conversion and CSV Generation |
    ...    | Test Steps  | 26. Verify that K2 |
    ...    | Test Steps  | 27. Check Slot Processing Duration Budget |
    ...    | Test Steps  | 28. Extract Data From File |
    ...    | Test Steps  | 29. Check Maximum scheduled UEs in UL |
    ...    | Test Steps  | 30. Check Counters M55308C18001, M55308C18002 |
    ...    | Test Steps  | 31. Test Teardown |

    ##########################################################################################
    #2. Update bsr package BSR_AQQJ_6_H6 artifactory
    ##########################################################################################
    Update bsr package BSR_AQQJ_6_H6 artifactory
    ##########################################################################################
    #3. Set CB013895 Rad Parameters
    ##########################################################################################
    Set CB013895 Rad Parameters
    Reset Site
    ${status_check_result}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1200    10   ADMIN Check Bts Status    status=Configured
    Run Keyword If    not ${status_check_result}    Reset Site
    Run Keyword If    not ${status_check_result}
    ...    Wait Until Keyword Succeeds    1200    60   ADMIN Check Bts Status    status=Configured
    BuiltIn.Sleep    30s
    ##########################################################################################
    #4. SCF commissioning
    ##########################################################################################
    Get vlanIdOAM parameter from Info Model
    Update VLAN ID For Specific VLANIF
    SCF commissioning    scf=${SCF_FILE_PATH_1}
    Wait Until Keyword Succeeds    1200    60   ADMIN Check Bts Status    status=Commissioned
    BuiltIn.Sleep    60s
    ##########################################################################################
    #5. iphy commissioning
    ##########################################################################################
    iphy commissioning    iphy=${IPHY_FILE_PATH_1}
    Reset Site
    ${status_check_result}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    1200    60   ADMIN Check Bts Status    status=Configured
    Run Keyword If    not ${status_check_result}    Reset Site
    Run Keyword If    not ${status_check_result}
    ...    Wait Until Keyword Succeeds    1200    60   ADMIN Check Bts Status    status=Configured
    BuiltIn.Sleep    30s
    ##########################################################################################
    #6. Configure UTE ETH3
    ##########################################################################################
    Run keyword and continue on failure    Configure UTE ETH3
    BuiltIn.Sleep    10s
    ##########################################################################################
    #7. Set New basic_setup_cfg in WTS
    ##########################################################################################
    Set New basic_setup_cfg in WTS    basic_setup_cfg=${basic_setup_cfg_B1}
    Setup Airphone Env for CellSetup    basic_setup_cfg=${basic_setup_cfg_B1}
    ##########################################################################################
    #8. Do UL and DL traffic SA
    ##########################################################################################
    Traffic_DL_UL_SA    ue=1
    Traffic_DL_UL_SA    ue=2
    ##########################################################################################
    #9. Collect Ttitrace Logs
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    1s
    Stop Ttitrace    log_dir=${out}
    ##########################################################################################
    #10. Stop traffic
    ##########################################################################################
    Traffic_DL_UL_SA_stop    ue=1
    Traffic_DL_UL_SA_stop    ue=2
    ##########################################################################################
    #11. Stops Btslogs from Local machine
    ##########################################################################################
    Run Keyword And Ignore Error    Stops Btslogs from Local machine
    ##########################################################################################
    #Test Teardown from CB013895-SR_Update_Files_Setup
    ##########################################################################################
    CB013895-Common-Keywords.Test Teardown
    ##########################################################################################
    #12. Test Setup CB013895-SR_B1
    ##########################################################################################
    CB013895-Common-Keywords.Test Setup
    Test Setup CB013895-SR_B1
    ##########################################################################################
    #13. CellSetup
    ##########################################################################################
    Wait Until Keyword Succeeds    1200    10   ADMIN Check Bts Status    status=OnAir
    BuiltIn.Sleep    30s
    ##########################################################################################
    #14. Start Capture SosReport
    ##########################################################################################
    #Run keyword and continue on failure    Start Capture SosReport
    ##########################################################################################
    #15. Start traffic for all 35 UEs (Low_Load)
    ##########################################################################################
    # UE IDs mapping: 35 UEs total (1-10, 21-30, 51-55, 61-70)
    @{ue_ids_group}=    Create List    1    2    3    4    5    6    7    8    9    10
    ...                                21    22    23    24    25    26    27    28    29    30
    ...                                51    52    53    54    55    61    62    63    64    65
    ...                                66    67    68    69    70

    FOR    ${ue_id}    IN    @{ue_ids_group}
        Traffic_DL_UL_SA Low_Load    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
    ##########################################################################################
    #16. Collect Ttitrace Logs (Low_Load)
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    2s
    OperatingSystem.create directory    ${out}/Low_Load/
    Stop Ttitrace    log_dir=${out}/Low_Load/
    ##########################################################################################
    #17. Start traffic for all 35 UEs (High_Load)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group}
        Traffic_DL_UL_SA High_Load    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
    ##########################################################################################
    #18. Collect Ttitrace Logs (High_Load)
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    20s
    OperatingSystem.create directory    ${out}/High_Load/
    Stop Ttitrace    log_dir=${out}/High_Load/
    ##########################################################################################
    #19. Collect l1l2bip Logs
    ##########################################################################################
    Start Collect interface mirroring with nr phy cell ids
    BuiltIn.Sleep    2s
    Stop Collect interface mirroring with nr phy cell ids
    ##########################################################################################
    #20. Start traffic for all 35 UEs (Low_Load_Ramp)
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group}
        Traffic_DL_UL_SA Low_Load_Ramp    ue=${ue_id}
    END
    BuiltIn.Sleep    120s
	##########################################################################################
    #21. Collect Ttitrace Logs (Low_Load_Ramp)
    ##########################################################################################
    Start Ttitrace With Streaming Mode For GNB
    BuiltIn.Sleep    2s
    OperatingSystem.create directory    ${out}/Low_Load_Ramp/
    Stop Ttitrace    log_dir=${out}/Low_Load_Ramp/
    ##########################################################################################
    #22. Stop traffic for all 35 UEs
    ##########################################################################################
    FOR    ${ue_id}    IN    @{ue_ids_group}
        Traffic_DL_UL_SA_stop    ue=${ue_id}
    END
    ##########################################################################################
    #23. Stops Btslogs from Local machine
    ##########################################################################################
    Run Keyword And Ignore Error    Stops Btslogs from Local machine
    ##########################################################################################
    #24. Stop Capture SosReport
    ##########################################################################################
    #Run keyword and continue on failure    Stop Capture SosReport
    ##########################################################################################
    #25. TTI Conversion and CSV Generation
    ##########################################################################################
    Run keyword and continue on failure    TTI Conversion and CSV Generation Low_Load
    Run keyword and continue on failure    TTI Conversion and CSV Generation High_Load
    Run keyword and continue on failure    TTI Conversion and CSV Generation Low_Load_Ramp
    ##########################################################################################
    #26. Verify that K2
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
    #27. Check Slot Processing Duration Budget
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
    #28. Extract Data From File
    ##########################################################################################
    Run keyword and continue on failure    Extract Data From File Low_Load
    Run keyword and continue on failure    Extract Data From File High_Load
    Run keyword and continue on failure    Extract Data From File Low_Load_Ramp
    ##########################################################################################
    #29. Check Maximum scheduled UEs in UL
    ##########################################################################################
    Run keyword and continue on failure    Check Maximum scheduled UEs in UL
    ##########################################################################################
    #30. Check Counters M55308C18001, M55308C18002
    ##########################################################################################
    BuiltIn.Sleep   360s    # Sleep 360 s = 6 min for a PM xml file creation in each 5 min
    Run keyword and continue on failure    Collect and Check Counter
    ##########################################################################################
    #31. TC Teardown Action
    ##########################################################################################
    [Teardown]    Run Keywords
    ...    CB013895-Common-Keywords.Test Teardown
    ...    AND    TC Teardown Action
