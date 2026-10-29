*** Settings ***
Resource    Resources/CB012149_common_keyword.robot
Variables    Resources/CB012149_variable.py

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${TRUE}

*** Variables ***
${tl_scf_dir_path}     ${CURDIR}/../../../../../commissionings/HGZ/

${FDD_UNMUTE_SLOT}    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
${FDD_UNMUTE_SLOT_NORMAL_ULCA}    [0, 1, 3, 5, 6, 8]

${log_dir}    ${TS_CASE_LOG_PATH}/ttitrace_streaming
${FDD_file_path}    tti_packed/asp-5a-L2RTa0_ttiTrace/2730_TTI.bin.1.ul__all.csv

*** Test Cases ***
[1][1.0] CB012149_SR_W_06_C_singleUE_peak_Tput_TDD-100MHz-BF-1208_FDD-20MHz
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    CB012149 COAM update Parameters    parameters=${CB012149_legacy_ULCA}
    CB012149 UE prepare UE
    Qcom UE Attach and Get CP-IF log
    ${bip_log}    ${tti_file_path}    Qcom UE Start traffic and Get Bip log    need_TTI=${True}
    ...                                                                  ul_target_tdd=175    ul_target_fdd=142
    Check Slot For FDD    log_file=${tti_file_path}/tcpdump_ttitrace_ul.csv    pci=54    slotlist=${FDD_UNMUTE_SLOT_NORMAL_ULCA}
#    Check Slot For FDD    log_file=${gnb_log}/${FDD_file_path}    pci=54    slotlist=${FDD_UNMUTE_SLOT_NORMAL_ULCA}
    Check ulBler with BIP log    bip_log=${bip_log}
    CB012149 COAM update Parameters    parameters=${CB012149_enable_UlCaUeParallelTx}
    Qcom UE Attach and Get CP-IF log
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log    need_TTI=${True}
    ...                                                                  ul_target_tdd=175    ul_target_fdd=230
    Check Slot For FDD    log_file=${tti_file_path}/tcpdump_ttitrace_ul.csv    pci=54    slotlist=${FDD_UNMUTE_SLOT}
#    Check Slot For FDD    log_file=${gnb_log}/${FDD_file_path}    pci=54    slotlist=${FDD_UNMUTE_SLOT}
    Check ulBler with BIP log    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1]CB012149_SR_AB_16_R16 UL Tx Switching single UE peak throughput - PUSCH mapping type B_1116_3ms
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_typeB.xml
    Sleep    2min
    CB012149 UE prepare UE
    ${cpif_log}    Qcom UE Attach and Get CP-IF log
    Check ulTxSwitch Related Info during Attach Procedure    cpif_log=${cpif_log}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log    ul_target_tdd=176    ul_target_fdd=174
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1]CB008709_J_19_B1_02_Slice_aware_uplink_scheduler_interacts_with_FR1_UL_FT_2CC_CA_Pcell_Scell_Different_RG
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_8709.xml
    Sleep    2min
    Qcom UE attach and start traffic
    Run Keyword And Continue On Failure    COAM Get all BTS Counters and check values    counter=${COUNTERS_CB008709_FDD}
    ...                                                                                  min_dl=${45}
    ...                                                                                  max_dl=${55}
    ...                                                                                  min_ul=${45}
    ...                                                                                  max_ul=${55}
    Run Keyword And Continue On Failure    COAM Get all BTS Counters and check values    counter=${COUNTERS_CB008709_TDD}
    ...                                                                                  min_dl=${95}
    ...                                                                                  max_dl=${100}
    ...                                                                                  min_ul=${80}
    ...                                                                                  max_ul=${100}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}

[1]CB012149_SR_AC_32_R16 UL Tx Switching single UE peak throughput - interworking with FDD A-SRS_1116-0ms_TypeA
    [Setup]    SG2_Common_setup_teardown.Common Case setup    need_Btslog=${True}
    COAM commission scf and wait cell setup    scf_file_path=${tl_scf_dir_path}/${testline_name}/${ENB_BRANCH}_ASRS.xml
    Sleep    2min
    CB012149 UE prepare UE
    ${cpif_log}    Qcom UE Attach and Get CP-IF log
    Check ulTxSwitch Related Info during Attach Procedure    cpif_log=${cpif_log}
    ${bip_log}    ${gnb_log}    Qcom UE Start traffic and Get Bip log    ul_target_tdd=206    ul_target_fdd=39    asrs_flag=${True}
    Check ulTxSwitch Related Info during Traffic Procedure    bip_log=${bip_log}
    Check if A-SRS is triggered during Traffic Procedure    bip_log=${bip_log}
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}
