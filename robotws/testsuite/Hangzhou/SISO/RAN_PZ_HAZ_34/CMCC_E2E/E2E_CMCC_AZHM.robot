*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02
Force Tags        5G_SISO
...    PY36
Variables         Resources/E2E_CMCC_AZHM_variables.py
Resource          Resources/E2E_CMCC_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_61649}             faultId=${61649}    #LMP access via port 443
&{fault_4654}              faultId=${4654}     #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}     #Service account root access is enabled
&{fault_4592}              faultId=${4592}     # BTS booted due to Power On.
&{fault_4681}              faultId=${4681}     #Sanity Check Error

@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_61649}    &{fault_4654}
...                  &{fault_4655}    &{fault_4592}    &{fault_4681}


@{AHPF_nrCellIdentity}    32015649    32015650    32015651    32015652    32015653    32015654
@{AZHM_nrCellIdentity}    8195182593    8195182594    8195182595    8195182596    8195182597    8195182598
@{AZHM_lteCellIdentity}    250388    250389    250390
@{UE_INDEX}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}

${UL_THROUGHPUT}    250Mbits/sec
${DL_THROUGHPUT}    1500Mbits/sec

${DURATION}    6000
${UL_FDD_EXPECT_30M}    170
${DL_FDD_EXPECT_30M}    345

${UL_TDD_EXPECT_100M}    150
${DL_TDD_EXPECT_100M}    1200

${UL_TDD_EXPECT_LTE}    10
${DL_TDD_EXPECT_LTE}    90

${TS_LOG_PATH_BASE}      ${OUTPUT DIR}/Case_Logs

${apn1}    ${tl.core.pdns[0].apn}

${scf_dir}    ${EXECDIR}/robotws/commissionings/HGZ/7_5_UTE5G402T777

*** Test Cases ***
[2]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common E2E Test Case Setup
    @{ru_list}    Create List
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=GNB_OAM
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    ${list_length}    Get Length    ${ru_list}
    FOR    ${n}    IN RANGE    ${list_length}
        Reset Tested RU and Check all RU status    tested_ru_idx=${${n}%${list_length}+1}    ru_list=@{ru_list}
    END
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    Sleep    30s
#    Call case with huawei sigspark and record throughput info   ue_type=${ue_type}    duration_time=300   interval_time=10
#    ...    total_time=300    ul_exp_tput=${UL_TDD_EXPECT_100M}    dl_exp_tput=${DL_TDD_EXPECT_100M}
#    ...    tput_percentage=0.9    4G_check=False    apn_address=dxdata2
#    ${ue_index}    Create List    ${0}
#    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index}
    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}    cap_index=${2}
    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
    ...                            nrCellIdentity=${AZHM_nrCellIdentity}[0]    apn_address=dxdata2    ip_filter=172.
    [Teardown]    Test Case Teardown with UE for CMCC

[1][2.0] General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common E2E Test Case Setup
    Get SCF Path
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
#    Sleep    30s
#    Run Keyword And Continue On Failure    Call case with huawei sigspark and record throughput info
#    ...    ue_type=${ue_type}    duration_time=300   interval_time=10
#    ...    total_time=300    ul_exp_tput=${UL_TDD_EXPECT_100M}    dl_exp_tput=${DL_TDD_EXPECT_100M}
#    ...    tput_percentage=0.9    4G_check=False    apn_address=dxdata2
#    ${ue_index}    Create List    ${0}
#    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index}
#    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
#    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
#    ...                            nrCellIdentity=@{AZHM_nrCellIdentity}[0]    apn_address=dxdata1    #    ui_version=Mi12UI13.0.12
#    COAM commission scf and wait cell setup    scf_file_path=${concurrent_scf_path}
#    UE Attach to LTE Cell and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
#    ...                                        Expected_Throughput_DL=${DL_TDD_EXPECT_LTE}     Expected_Throughput_UL=${UL_TDD_EXPECT_LTE}
#    ...                                        nrCellIdentity=@{AZHM_lteCellIdentity}[0]    ue_index=${1}    apn_address=dxdata1
#    [Teardown]   Run Keywords    COAM commission scf and wait cell setup    scf_file_path=${original_scf_path}    AND
#    ...                          Test Case Teardown with UE for CMCC
    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}    cap_index=${2}
    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
    ...                            nrCellIdentity=${AZHM_nrCellIdentity}[0]    apn_address=dxdata2    ip_filter=172.
    [Teardown]    Test Case Teardown for CMCC

[1]CB006667_5G_HA_KPI_Cycle_Disable_Enable_actIncreasedFdmUsersPerSlot_online
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common E2E Test Case Setup
    ${nr_bts_id}    Set variable    ${tl.gnbs[${0}].global_bts_id}
    FOR    ${i}    IN RANGE    3
        Capture BTS log
        ${current_value}    5GC002029_A_common_keywords.Get parameter in SCF
        ...    para=actIncreasedFdmUsersPerSlot    dist_value=NRBTS-${nr_bts_id}/NRCELL-1
        ${update_value}    Run Keyword If    '${current_value}'=='true'    Set Variable    false
        ...    ELSE    Set Variable    true
        &{parameter}    Create Dictionary    actIncreasedFdmUsersPerSlot=${update_value}
        update parameter in SCF     update_value=${update_value}
        COAM Wait for gnb ready and cell setup    timeout=13 min
        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=GNB_OAM
        Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
        Stop BTS log
    END
    [Teardown]    Test Case Teardown for CMCC

[1]CB007731-B_3_01_DL_MU-MIMO_FDM_BF_On_CDRX_On_100MHz
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1    ABIO
    [Setup]    Common E2E Test Case Setup
#    Set Tag for Test Instance ID
#    ${cells}    Create list  @{AZHM_nrCellIdentity}[1]
#    Call case with Multi UE Dingli Pioneer and record throughput info    cells=${cells}
#    ...                                                                  apn_address=${apn1}
#    ...                                                                  ul_exp_tput=${UL_TDD_EXPECT_100M}
#    ...                                                                  dl_exp_tput=${DL_TDD_EXPECT_100M}
#    ...                                                                  ul_tput_percentage=0.85
    Get SCF Path
    ${ue_type}    Translate Power Ue Type From Testline    ue_index=${0}
    Set test variable    ${ue_type}
    UE Attach and Start Traffic    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}    cap_index=${2}
    ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
    ...                            nrCellIdentity=${AZHM_nrCellIdentity}[0]    apn_address=dxdata2    ip_filter=172.
    [Teardown]    Test Case Teardown for CMCC
