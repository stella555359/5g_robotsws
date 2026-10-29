*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    Resources/CB006896_common_keywords.robot
Resource    Resources/CB008562_AHPF_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007841_AQQK/Resources/CB007841_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    Resources/CB007125_common_keywords.robot
Resource    Resources/CNI-113644_common_keywords.robot

Documentation
...    author: Qingqing Wang
...    contact: qingqing.1.wang@nokia-sbell.com
...    squad group: SG_08
...    Feature: CB006896
...    Author:zhenzhen ren
...    contact:zhenzhen.ren@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009260_AHPF

Force Tags            RAN_5G    5G_RAN    RAN_5G_FDD    5G_RAN_FDD    SBTS00    CRT_UTE    CRT_22R3    CRT_22R4
...    PY36
...    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASKEY_SA_ASILL_ABIOB1_3xAHPF    CRT_23R1

*** Variables ***
@{band1}    30M
@{band2}    20M
${dist_name}    MRBTS-1142/EQM-1/HWTOP-1/CABLINK-2
@{sfp_list}    FOTB    AOZES
@{link_list}    'connected'
@{cell_id}    ${1}
*** Test Cases ***
[1]General_SiSo_RF_module_power_reset
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_RF_module_power_reset

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_RU_module_reset_from_GUI
   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
   General_SiSo_RF_module_reset_from_GUI

[1]General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_out-of-range_pmax
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Fault_4008_EFaultId_FrConfiguringFailed_PMAX

[1]General_SiSo_RF_alarms_with_recovery
   [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_RF_alarms_with_recovery

[1][1.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break
    [Tags]    CRT_TRUNK    CRT_23R1
    reboot_asky_or_cpe_ue
    General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_call_AHPF

[1]CB009260-SR_7_The_BTS_shall_support_NIDD_parameter_(EQM_APEQM-SFPOperatorMode)_to_enable_and_disable_SFP+_or_SFP28_compliance_validation
    [Tags]    CRT_TRUNK    CRT_23R2
    CB007841-5G-E_AQQK_01_The BTS shall support NIDD parameter (EQM APEQM-SFPOperatorMode)    sfp_list=${sfp_list}

[1]CB009260-SR_8_BTS_startup_Cooled_SFP+_or_SFP28_transceivers_support_for_interface
    [Tags]    CRT_TRUNK    CRT_23R2
    BTS startup Cooled SFP+ or SFP28 transceivers support for FH interface

[1]CB009260-SR_1_BTS_startup_SFP_power_level_1-2_compatibility_validation
    [Tags]    CRT_TRUNK    CRT_23R2
    BTS startup SFP power level compatibility validation    RF_port=RF2    power=PL2

[1]CB009260-SR_3_BTS_startup_SFP_power_level_3-4_compatibility_validation
    [Tags]    CRT_TRUNK    CRT_23R2
    BTS startup SFP power level compatibility validation    RF_port=RF1    power=PL3

[1]CB009260-SR_12_BTS_startup_rate_selection_for_[Q]SFP28_transceiver_module_on_System_Module_fronthaul
    [Tags]    CRT_TRUNK    CRT_23R2
    BTS_startup_rate_selection_for_[Q]SFP28_transceiver_module    dist_name=${dist_name}
    Check sfp information   link_list=${link_list}

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_ 4x4
    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
    Commission SCF With Specific Band If Needed    band=${band1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    reboot_asky_or_cpe_ue
    data_transfer_common    tput_self_define=${tput_define_4}    tput_from=self_define    cell_id=${cell_id}    loop_times=${2}    duration=${300}
    ...    target_avg_percent=0.98    min_percent=0.85

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_Max_MCS
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
#    Commission SCF With Specific Band If Needed    band=${band2}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    reboot_asky_or_cpe_ue
#    data_transfer_common    tput_self_define=${tput_define_Max_MCS}    cell_id=${cell_id}    loop_times=${1}    duration=${300}
#    ...    target_avg_percent=0.95    min_percent=0.85

[1]General_SiSo_Cell_lock_and_unlock
    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
    Commission SCF With Specific Band If Needed    band=${band1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    reboot_asky_or_cpe_ue
    #General_SiSo_Cell_lock_and_unlock_AHPF
    General_SiSo_Cell_lock_and_unlock_SG08    with_call=False    tput_self_define=${tput_define_4}
    data_transfer_common    tput_self_define=${tput_define_4}    tput_from=self_define    cell_id=${cell_id}    loop_times=${2}    duration=${300}
    ...    target_avg_percent=0.80    min_percent=0.20

[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
    Commission SCF With Specific Band If Needed    band=${band1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    reboot_asky_or_cpe_ue
    #General_SiSo_RU_lock_unlock_AHPF
    General_SiSo_RU_lock_unlock_SG08    with_call=False    tput_self_define=${tput_define_4}
    data_transfer_common    tput_self_define=${tput_define_4}    tput_from=self_define    cell_id=${cell_id}    loop_times=${2}    duration=${300}
    ...    target_avg_percent=0.80    min_percent=0.20

#[1]01_Cell_Setup_With_Configed_40MHz_BandWidth
#    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
#    ${SCF_APHP}    Replace String    ${Golden_SCF_Path}    .xml    _AHPH.xml
#    Commissioning SCF And Check On Air      scf_path=${SCF_APHP}
#    reboot_asky_or_cpe_ue
#    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]CNI-113644_1_Fault_251_EFaultId_BackplaneSwitchUnreachableAI in single unit
    [Tags]    CRT_TRUNK    CRT_24R2
    AlarmWatchdog.add_allow_alarms    fault_id=251
    CNI-113644_1_Fault_251_EFaultId_BackplaneSwitchUnreachableAI in single unit
    AlarmWatchdog.remove_allow_alarms    fault_id=251

#[1][1.0] General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_break for 24R1
#    [Tags]    CRT_TRUNK    CRT_23R1
#    General_SiSo_Auto_Antenna_Online_Monitoring_using_WebEM_with_call_AHPF for 24R1

[1]General_SiSo_BB_sub_unit_reset_loop_with_L3_call
    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
#    Commission SCF With Specific Band If Needed    band=${band1}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    FOR  ${i}  IN RANGE    1    10
        Log To Console    ${i}th BBOMD reset loop...
        BBMOD_reset_and_check_cell_status
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    data_transfer_common    tput_self_define=${tput_define_4}    tput_from=self_define    cell_id=${cell_id}    loop_times=${2}    duration=${300}
    ...    target_avg_percent=0.80    min_percent=0.20

[1]General_SiSo_NR__RAT_reset_loop_with_l3_call
    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
#    Commission SCF With Specific Band If Needed    band=${band1}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    FOR  ${i}  IN RANGE    1    10
        Log To Console    ${i}th RAT reset loop...
        coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
        Wait Until Keyword Succeeds    15 min    180 sec    Verify all cells should be onair
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    data_transfer_common    tput_self_define=${tput_define_4}    tput_from=self_define    cell_id=${cell_id}    loop_times=${2}    duration=${300}
    ...    target_avg_percent=0.80    min_percent=0.20

[1]General_SiSo_RMOD_reset_loop_with_l3_call
    [Tags]    CRT_21A    CRT_TRUNK    CRT_22R2    CRT_22R1
#    Commission SCF With Specific Band If Needed    band=${band1}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
    FOR  ${i}  IN RANGE    1    10
        RMOD_reset_and_check_cell_status
        ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
        should be true    ${alarm_status}
        ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
        ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
        should be true    ${history_alarm_status}
    END
    data_transfer_common    tput_self_define=${tput_define_4}    tput_from=self_define    cell_id=${cell_id}    loop_times=${2}    duration=${300}
    ...    target_avg_percent=0.80    min_percent=0.20
