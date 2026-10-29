*** Settings ***
Suite Setup       SISO Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout      180 min

Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
#Resource     ${BASIC_PATH_5G}/General_SiSo_CPRI_link_configuration.robot
#Resource     ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
#Resource     ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
#Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
#Resource     ${BASIC_PATH_5G}/BTS/General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith.robot
#Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/5GC001340/Resource/5GC001340_Common_KW_cOAM.robot
#Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000470/Resource/5GC000470-E-5GC000348_common_KW.robot
#Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007807/Resource/CB007807_commonKW.robot
Resource     Resource/T057_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009218/resource//CB009218_Common_KW.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009394/resource/CB009394_Common_KW.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009394/resource/variables.py
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001278/TestData/variables.py
Variables    TestData/variables.py

Documentation
...    author: hu annie
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB in TRUNK program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all

*** Variables ***
${Alarm_name_CP}        BASE STATION CONNECTIVITY PROBLEM
${Severity_CP}          major
${x2link_dist_name}     MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/LTEENB-0
${LTEENB_ID}            0
${Param_abbr}           srb3SupportEnabled
${Param_filter}         SRB3 Support Enabled
@{band}    70M    30M


*** Test Cases ***
### part-1: 5GC000470 - 5 TCs ###
#[1][1.0] 5GC000470-E-5GC000348_HW Monitoring with Web EM_01_HW state monitoring
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    "Step1" Login gNB via WebUI
#    "Step2" Check HW led status
#    "Step3" Check HW components status
#    run keyword and ignore error    WEBUI Logout

#[1][1.0] 5GC000470-E-5GC000348_HW Monitoring with Web EM_04_EQM database build up
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    "Step1" Login gNB via WebUI
#    "Step2" Check EQM subTree display normal
#    run keyword and ignore error    WEBUI Logout

#[1][1.0] 5GC000470-E-5GC000372_5G Node B Web Element Manager_03_Session Idle Timeout
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    Step1: Login WebUI
#    Step2: Wait idle time
#    #Step3: Acquire login fail info
#    Step4: Logout WebUI

#[1][1.0] 5GC000470-M-5GC001340-A_01_7300_EFaultId_NoX2LinkAvailableAl
#    [Tags]    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    Run Keywords    Recovery Env    SISO Coam Test Teardown
#    Step1: Check gNB is onAir
#    Step2: Trigger fault 7300 on WebEM
#    Step3: Check fault 7300 display on WebEM

#[1][1.0] 5GC000470-M-5GC001340-A_02_7308_EFaultId_X2SctpEndpointBrokenAl
#    [Tags]    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    Run Keywords    Recovery fault 7308    SISO Coam Test Teardown
#    Step1: Check gNB is onAir
#    Step2: Trigger fault 7308
#    Step3: Check fault 7308 display on WebEM

### part-2: 5GC001278 - 4 TCs ###
#[1][1.0] 5GC001278_001_AWHQG_General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

#[1][1.0] 5GC001278_019_AWHQG_General_SiSo_RF_module_addition_in_BIM_and_WebUI
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_RF_module_addition_in_BIM_and_WebUI

#[1][1.0] 5GC001278_006_AWHQG_General_SiSo_RF_module_power_reset
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    General_SiSo_RF_module_power_reset

#[1][1.0] 5GC001278_021_AWHQG_General_SiSo_CPRI_link_configuration
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#   General_SiSo_CPRI_link_configuration

### part-3: 5GC002090 - 1 TCs ###
#[1][1.0] 5GC002090-W_001_Verify UE CONTEXT MODIFICATION Message
#    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    Run Keywords
#    ...     Change Parameter via webUI
#    ...     expected_val=${Orig_val}
#    ...     dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
#    ...     filter_param=${Param_filter}
#    ...     p_name=${Param_abbr}                            AND
#    ...     case teardown                                   AND
#    ...     SISO Coam Test Teardown
#    "Step1" Login WebEM and check gNB onair
#    "Step2" Change Parameter via webUI
#    #"Step3" Check UEContextModificationRequest via wireshak

##Golden SCF: 2*AWHQV (1S-2CC-2D2U_60-30M); AWHTA (1S-2CC-2D2U_100-50M); with 2 fibers as customer config required
#Config: AWHQV (1S-2CC-4D4U_20-20M); AWHTA (2S-2CC-4D4U_50-50M)
[1]CB009394-SR-B-08_2CC_cell_block_unblock
    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE    CRT_TRUNK    CRT_25R2    CRT_25R1
    [Setup]    SISO Coam Test Setup
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown
    ${cell_list}    create list    ${1}  ${2}  ${5}  ${6}
    ${band_list}    create list    ${20}  ${20}  ${50}  ${50}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    General_SiSo_Cell_block_and_unblock   with_call=${False}

[1]CB009394-SR-B-03_2CC_4DL_256QAM_4UL_64QAM_50MHz_30Mhz_with_L3Call_mcs27
    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    [Teardown]    SISO Coam Test Teardown
    ${cell_list}    create list    ${1}  ${2}  ${6}
    ${band_list}    create list    ${50}  ${30}  ${50}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}

#Config: AWHQV (1S-2CC-4D4U_40-20M); AWHTA (2S-2CC-4D4U_100-100M)
[1]CB009394-SR-D-08_2CC_cell_lock_unlock
    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    Run Keywords    add fault to allowed history fault list    faultId=${49}   AND
    ...    SISO Coam Test Teardown
    ${cell_list}    create list    ${1}  ${2}  ${5}  ${6}
#    ${band_list}    create list    ${40}  ${20}  ${100}  ${100}
#AWHTA:100+100M needs 3 fibers and current 2 fibers connected as customer config requres, so change to 40+50M
    ${band_list}    create list    ${40}  ${20}  ${40}  ${50}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    General_SiSo_Cell_lock_and_unlock   with_call=${False}

[1]CB009394-SR-D-04_2CC_4DL_256QAM_4UL_64QAM_100MHz_40Mhz_with_L3Call_mcs27
    [Tags]    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    ${cell_list}    create list    ${6}
    ${band_list}    create list    ${40}
    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}
#
#[1]AWHQV_1Sector_2CC_DualCarrier_4DL_256QAM_4UL_64QAM_FR1_20MHz_60MHz_A7_General_SiSo_Cell_block_and_unblock
#    #[Tags]    1S-2CC-4D4U_A7_20-60M_F0-9_3CPRI    CRT_TRUNK    CRT_22R4
#    [Tags]     CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    ${cell_list}    create list    ${1}  ${2}
#    ${band_list}    create list    ${20}  ${60}
#    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
#    ${frame_info}    Get framestructinfo   framelistname=${frame_structure_list__20MHz_60MHz}   frameindex=${0}
##    run keyword and ignore error  Modify_Band_Frame_Structure_multi_cc_with_different_bandwith
##    ...    frames_info=${frame_info}   cell_id=${None}   enable_2197=${False}
#    ${status}  run keyword and ignore error  Modify_Band_Frame_Structure_And_Test_Throughput_multi_cc_with_different_bandwith
#    ...    frames_info=${frame_info}    ue_num_each_call=0   random_access=${False}
#    ...    cell_id=${None}   duration=${300}    4G_check=${False}
#    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    run keyword if  '${status[0]}'=='FAIL'  fail   not all frame structure pass
##    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith   ${bandlist}
##    ...    ue_num_each_call=0    enable_2197=${False}    4G_check=${False}
#    E2E_SiSo_Cell_block_and_unblock_gNB    with_call=${False}
#
#[1]AWHQV_1Sector_2CC_DualCarrier_4DL_256QAM_4UL_64QAM_FR1_20MHz_60MHz_A8_iqc_General_SiSo_RU_lock_unlock
#    #[Tags]    1S-2CC-4D4U_A8_20-60M_F0-9_2CPRI_iqc    CRT_TRUNK   CRT_22R4
#    [Tags]     CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    SISO Coam Test Teardown
#    ${cell_list}    create list    ${1}  ${2}  ${3}  ${4}
#    ${band_list}    create list    ${20}  ${60}  ${20}  ${60}
#    Modify bandwidth for multi cells   ${cell_list}   ${band_list}
#    ${bandlist}    create list    ${20}    ${60}
#
#    ${sub}=  Get From List  ${frame_structure_list__20MHz_60MHz}  0
#    ${frame}=    Get From Dictionary    ${sub}    frame
#    Set List Value   ${frame}   0   1116_0ms_GP1_A8
#    Set To Dictionary    ${sub}    frame    ${frame}
#    Set List Value   ${frame_structure_list__20MHz_60MHz}   0   ${sub}
#
#    ${sub}=  Get From List  ${frame_structure_list__20MHz_60MHz}  1
#    ${frame}=    Get From Dictionary    ${sub}    frame
#    Set List Value   ${frame}   0   1116_0ms_GP1_A8
#    Set To Dictionary    ${sub}    frame    ${frame}
#    Set List Value   ${frame_structure_list__20MHz_60MHz}   1   ${sub}
#    #log to console   ${frame_structure_list__20MHz_60MHz}
#
#    ${frame_info}    Get framestructinfo   framelistname=${frame_structure_list__20MHz_60MHz}   frameindex=${0}
##    run keyword and ignore error  Modify_Band_Frame_Structure_multi_cc_with_different_bandwith
##    ...    frames_info=${frame_info}   cell_id=${None}   enable_2197=${False}
#    ${status}  run keyword and ignore error  Modify_Band_Frame_Structure_And_Test_Throughput_multi_cc_with_different_bandwith
#    ...    frames_info=${frame_info}    ue_num_each_call=0   random_access=${False}
#    ...    cell_id=${None}   duration=${300}    4G_check=${False}
#    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    run keyword if  '${status[0]}'=='FAIL'  fail   not all frame structure pass
##    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith   ${bandlist}
##    ...    ue_num_each_call=0    enable_2197=${False}    4G_check=${False}
#    E2E_SiSo_RU_lock_and_unlock_gNB    with_call=${False}
#
#[1]CB007807-A_01_02_MicroDTX_activate_on_mRRH_ScRMTDr6.1_4T4R_Radio
#    [Tags]     CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE
#    [Setup]    SISO Coam Test Setup
#    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
#    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
#    ...    AND    SISO Coam Test Teardown
#    #General_Feature_Micro-DTX_activate_microDtxEnabled_true
#    log to console   \n disable then enable Power Saving mode when cell on air
#    @{split_version}    string.split string    ${Active_SW_version}    separator=_
#    ${stream}    set variable     ${split_version}[0]
#    run keyword if  '${stream}'<'SBTS25R1'   Modify RMOD Power Parameter    power_status=false
#    sleep  120
#    selenium login and disable screen lock
#    ${rmod_power_meassure_1}    Get RMOD Power Measurement via Webem    interval=1min
#    #${smod_power_meassure_1}    Get SMOD Power Measurement via Webem    interval=1min
#    General_Feature_Micro-DTX_activate_microDtxEnabled_true
#    selenium login and disable screen lock
#    ${rmod_power_meassure_2}    Get RMOD Power Measurement via Webem    interval=1min
#    #${smod_power_meassure_2}    Get SMOD Power Measurement via Webem    interval=1min
#    ${rmod_p_value}    Evaluate
#    ...    "%.2f" % ((${rmod_power_meassure_1}-${rmod_power_meassure_2})/${rmod_power_meassure_1})
#     ${rmod_per_value}    Evaluate    ${rmod_p_value}*100
#     log to console   \n RMOD Power Saving Percent when cell on air:${rmod_per_value}%
#     should be true      ${rmod_per_value} > 20

[1]CB009007_SR_A_01_Activation_and_Deactivation_Enhanced_PDSCH_Scheduling_on_Speical_slot_for_Frame_Structure_8406
    [Tags]    3S-1CC-4D-2U-9007    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_AWHQG_ENB    CRT_UTE    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    [Teardown]    SISO Coam Test Teardown
    Activation_and_Deactivation_Enhanced_PDSCH_Scheduling_on_Speical_slot_for_Frame_Structure_8406
