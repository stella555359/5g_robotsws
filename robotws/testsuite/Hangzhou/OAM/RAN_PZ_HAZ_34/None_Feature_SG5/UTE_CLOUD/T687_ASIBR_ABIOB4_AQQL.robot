*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout      90 minutes

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource     ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_FREERUN_state_handling.robot
Resource     ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource     ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource     ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/resource/resources_l3call.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-phaseA/resource/CB006277_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseE/Resources/CB006277_common_keywords.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000430_B_Master/Resource/5GC000430_B_Master_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
Resource     Resource/T687_KW.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008562_SG05/resource/CB008562_resource.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008952_SG05/resource/resource.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001340/Resource/5GC001340_Common_KW_cOAM.robot
#Resource     Resource/T057_KW.robot

Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseB/TestData/variables.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-80168_SG05/Variable/variable_CNI-80168.py
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CNI-80168_SG05/Resource/CNI-80168_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009077/resource/CB009077_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008941_AQQL_AEQE/resource/CB008941_Common_KW.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00       master_classicalbts_all

*** Variables ***
&{PARA_MODIFY}                 dist_name=MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1
...                            p_name=topDomainNumber    filter_param=ToP domain number    value=43
@{TOP_DOMAIN_NUMBER_MODIFY}    &{PARA_MODIFY}

${if_pdl_check}       False

*** Test Cases ***
### part-3: CB006277 peak cases - 5 TCs  ###
[1]CB006277_BB_02_AQQL_eCPRI_peak_Tput_with_chbw_20Mhz
    [Tags]   1S-1CC-8D4U_A8_20M_C2-195_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_UTE
    [Setup]    SISO Coam Test Setup
   # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_0ms_GP1_A8    prach_index=195
   # ...    band=20
   # sleep    5s
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}   with_peak=${True}
    ...    ELSE    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${300}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB006277_BG_02_AQQL_eCPRI_peak_Tput_with_chbw_40Mhz
    [Tags]    1S-1CC-8D4U_A6_40M_A2-98_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB   CRT_UTE
    [Setup]    SISO Coam Test Setup
   # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_3ms_GP2_A6    prach_index=98
   # ...    band=40
   # sleep    5s
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}   with_peak=${True}
    ...    ELSE    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${300}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB006277_BH_02_AQQL_eCPRI_peak_Tput_with_chbw_50Mhz
    [Tags]    1S-1CC-8D4U_A3_50M_F0-7_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    [Setup]    SISO Coam Test Setup
   # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1070_GP1_A3    prach_index=7
   # ...    band=50
   # sleep    5s
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2    cell_list=${cell_list}   with_peak=${True}
    ...    ELSE   Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${300}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB006277_BI_02_AQQL_eCPRI_peak_Tput_with_chbw_60Mhz
    [Tags]    1S-1CC-8D4U_A8_60M_B4-156_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    [Setup]    SISO Coam Test Setup
   # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_0ms_GP1_A8    prach_index=156
   # ...    band=60
   # sleep    5s
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2 for 687 60M    cell_list=${cell_list}   with_peak=${True}
    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB006277_AE_03_AQQL_eCPRI_peak_Tput_with_4x4MIMO
    [Tags]    1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    [Setup]    SISO Coam Test Setup
   # General_gnb_can_be_on_air_with_Given_Information    frame_structure=1116_3ms_GP1_A5    prach_index=191
   # ...    band=100
   # sleep    5s
    ${cell_list}    create list    ${1}
    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
    ...    ELSE    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${True}    duration=${300}
#    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

### part-6: CB007511 - 1 TCs  ###
#This TC move to CIT_TRUNK
[1]CB007511-5G-A_01 RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
    [Tags]    1S-2CC-8D4U    CIT_TRUNK
    [Setup]    SISO Coam Test Setup
    RU_entering_deep_sleep_mode_during_low_traffic_periods_with_5GC000431_enabled
    [Teardown]    Run Keywords    SISO Coam Test Teardown
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}

[1]CB007511-5G-A_03 RU returning from PowerSaving Mode to normal operation due to at least one carrier enabling on RU triggered by 5GC000431
    [Tags]    1S-2CC-8D-4U    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    [Setup]    SISO Coam Test Setup
    [Timeout]  180min
    RU_returning_from_PowerSaving_Mode_to_normal_operation_due_to_change_of_EnergySavingMode
    [Teardown]    Run Keywords    SISO Coam Test Teardown
    ...    AND    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}

### part-7: CB008562 - 1 TCs ###
[1]CB008562_SR_B_5G_AQQL_03_RSSI_online_Monitoring
    [Tags]    1S-2CC-8D-4U    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    ${ue_list}    create list    ${0}
    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_list}
    Antenna Line Online Monitoring
    [Teardown]    Run Keywords    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_list}    AND
    ...           SISO Coam Test Teardown

### part-9: CB009077 in SBTS24R3 program
[1]CB009077-SR-C-b_01_Configure_customer_LCS_parameters_manually_for_4G_AQQL
    [Tags]    1S-2CC-1D1U-LTE   CIT_TRUNK
    [Setup]    SBTS Test Setup
    Configure_customer_LCS_parameters_manually_for_4G_AQQL
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SBTS Test Teardown

[1]CB009077-SR-E-a_02_Storing_location_into_RU_NVM_5G_AQQL
    [Tags]    CRT_TRUNK
    [Setup]    SBTS Test Setup
    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    Set Suite Variable    ${gNb_CuType}    SA
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    Storing_location_into_RU_NVM_5G_AQQL
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SBTS Test Teardown

[1]CB009077-SR-E-a_01_Storing_location_into_RU_NVM_4G_AQQL
    [Tags]    1S-2CC-1D1U-LTE   CRT_TRUNK
    [Setup]    SBTS Test Setup
    Storing_location_into_RU_NVM_4G_AQQL
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SBTS Test Teardown

### part-10: CB008941
[1]CB008941-SR-C_2_L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF
    [Tags]    master_classicalbts_all    CRT_TRUNK    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    [Setup]    SISO Coam Test Setup
    COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}
    ###    sleep to wait gNB finish commission
    sleep    5min
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF
    [Teardown]    SISO Coam Test Teardown

### part-11:CNI136180
[1]CNI136180_07_tput_verify_with_concurrent_mode_64TRX
    [Tags]    1S-2CC_LTETDD-NRTDD_CNI-136180-AA    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

### Optimized TCs ###
#### part-1: CB006277 non-peak cases - 3 TCs ###
#[1]CB006277_AC_11_AQQL_eCPRI_FREERUN_state_handling
#    [Tags]    1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    5GC000399_eCPRI_FREERUN_state_handling
#    [Teardown]    SISO Coam Test Teardown

#[1]CB006277_EC_01_Energy_Consumption_Counter_Feature_Activate_via_WebUI
#    [Tags]    1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE    CDRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Timeout]  180min
#    Wait for New Interval BTS counters Generate    interval=15min
#    Disable Energy Consumption Measurement Collectection    interval=15min
#    Set Power meter    power_meter=true
#    [Teardown]    SISO Coam Test Teardown

#[1]CB006277_AE_04_AQQL_eCPRI_U-plane_Fast_C-plane_counters
#    [Tags]    1S-1CC-8D4U_A5_100M_C2-191_TA-3000_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    General_SiSo_U-plane_Fast_C-plane_counters_AQQL
#    [Teardown]    SISO Coam Test Teardown

#### part-2: CB008655 - 1 TCs  ###
[1]CB008655-5G-A_01_02_Enabling_microDTXAdvanced_on_Megatron_cMAAr6.2_64T64R_Radio
    [Tags]   1S-1CC-8D4U_A8_20M_C2-195_2089-41    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE    CDRT_UTE
    [Setup]   SISO Coam Test Setup
    General_Feature_Micro-DTX_activate_microDtxEnabled_true
    General_Feature_Micro-DTXAdvanced_activate_advancedMicroDtxEnabled_true
    [Teardown]   SISO Coam Test Teardown

### part-4: CB005750&5GC002056 - 5 TCs ###
#[1]CB005750-EDAM_data_traffic_peak_throughput_LAenabled_MIMO4x4_256QAM_chbw_40MHz
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
##    General_SiSo_Peak_with_Given_Information     band=40    frame_structure=1116_0ms_GP2_A7
#    General_gnb_can_be_on_air_with_Given_Information    band=40    frame_structure=1116_0ms_GP2_A7    prach_index=97
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

#[1]CB005750-EDAJ_data_traffic_peak_throughput_LAenabled_MIMO4x4_256QAM_chbw_60MHz
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
##    General_SiSo_Peak_with_Given_Information     band=60    frame_structure=1116_3ms_GP1_A5
#    General_gnb_can_be_on_air_with_Given_Information    band=60    frame_structure=1116_3ms_GP1_A5    prach_index=191
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2 for 687 60M
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

#[1]5GC002056_CFBG_04_AEQE_eCPRI_General_SiSo_RU_lock_and_unlock_with_L3call
#   [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE
#   [Setup]    SISO Coam Test Setup
#    General_SiSo_RU_lock_unlock    with_call=${False}
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${False}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${False}
#   [Teardown]    SISO Coam Test Teardown

#[1][1.0] 5GC002056_CFBG_017_NSA_UL_and_DL_traffic_peak_Tput_QAM256_4X4MIMO_with_frame_structure_1116_and_60MHz
#    [Documentation]
#    ...   Configuration: SA_4X4
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
##    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP1_A8
#    General_gnb_can_be_on_air_with_Given_Information    band=60    frame_structure=1116_0ms_GP1_A85    prach_index=156
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

#[1][1.0] 5GC002056_CFBG_019_NSA_UL_and_DL_mass_traffic_QAM256_4X4MIMO_with_frame_structure_1208_and_40MHz
#    [Documentation]
#    ...   Configuration: SA_4X4
#    [Tags]    CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE
#    [Setup]    SISO Coam Test Setup
##    General_SiSo_Peak_with_Given_Information     band=40    frame_structure=1208_GP1_A1
#    General_gnb_can_be_on_air_with_Given_Information    band=40    frame_structure=1208_GP1_A1   prach_index=192
#    ${cell_list}    create list    ${1}
#    ${if_cpe3.2}    Run Keyword And Return Status   Should Contain Any   ${tl.ues[0].version}   3.2   cpe3.2   ignore_case=true
#    Run Keyword If    ${if_cpe3.2}    Get UE From Init File and Make call with cpe 3_2
#    ...    cell_list=${cell_list}    with_peak=${True}   4G_check=${False}
#    ...    ELSE    Get UE info and do L3 Call    cell_list=${cell_list}    with_peak=${True}
#    [Teardown]    SISO Coam Test Teardown

#### part-5: CNI-80168 - 1 TCs ###
#[1]CNI-80168_AQQL_005_Alarm_Major_Antenna_Calibration_Error_TX2922_RX2923
#    [Tags]    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Timeout]    2 hours
#    Mute pipe on RU to trigger fault 2292
#    sleep    30min
#    ${severity}    Get alarm severity
#    Run Keyword If    '${severity}' != 'None'
#    ...    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=2922    severity=${severity}
#    Should Not Be Equal    ${severity}    None
#    Perform RU Reset
#    sleep    2min
#    Wait until keyword succeeds    10min    10 sec   verify all cells should be onair
#    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=2922
#    [Teardown]    SISO Coam Test Teardown      #selenium logout and close browser

#### part-8: 5GC000470-1340 - 2 TCs ###
#[1][1.0] 5GC000470-M-5GC001340-A_01_7300_EFaultId_NoX2LinkAvailableAl
#    [Tags]    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    Step1: Check gNB is onAir
#    Step2: Trigger fault 7300 on WebEM
#    Step3: Check fault 7300 display on WebEM
#    [Teardown]    Run Keywords    Recovery Env    SISO Coam Test Teardown

#[1][1.0] 5GC000470-M-5GC001340-A_02_7308_EFaultId_X2SctpEndpointBrokenAl
#    [Tags]    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    Step1: Check gNB is onAir
#    Step2: Trigger fault 7308
#    Step3: Check fault 7308 display on WebEM
#    [Teardown]    Run Keywords    Recovery fault 7308    SISO Coam Test Teardown
