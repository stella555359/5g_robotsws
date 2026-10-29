*** Settings ***
Documentation     Author: Chen Yin
...               Email: yin.1.chen@nokia-sbell.com
...               Squad group: SG_02
Force Tags        5G_SISO
...    PY36
Variables         Resources/E2E_CMCC_AZHM_variables.py
Resource          Resources/E2E_CMCC_common_keyword.robot

*** Variables ***
&{fault_61524}             faultId=${61524}    #SSH enabled
&{fault_61652}             faultId=${61652}    #R&D Service Port enabled
&{fault_4654}              faultId=${4654}    #Ethernet port security is disabled
&{fault_4655}              faultId=${4655}    #Service account root access is enabled
&{fault_61649}             faultId=${61649}   #LMP access via port 443
@{allowed_faults}    &{fault_61524}    &{fault_61652}    &{fault_4654}    &{fault_4655}    &{fault_61649}
@{nrCellIdentity}    3960833    3960834    3960835    3960836    3960837    3960838
${UL_THROUGHPUT}    200M
${DL_THROUGHPUT}    2000M
${DURATION}    1200
${UL_TDD_EXPECT_100M}    50
${DL_TDD_EXPECT_100M}    500
${UL_TDD_EXPECT_30M}    5
${DL_TDD_EXPECT_30M}    50
${cur_relative_dir}     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CMCC_E2E

*** Test Cases ***
[1][1.1] General_SiSo_E2E_system_setup_with_data_transfer_OTA
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
    [Setup]    Common E2E Test Case Setup
    FOR      ${i}      IN RANGE        0      1      2
            Update PA value       attenuator=${tl.attenuator[0]}      value=${0}      ru_num=${${i}}
            UE Attach and Start Traffic    ui_version=Mi12UI13.0.12    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
            ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
            ...                            nrCellIdentity=${nrCellIdentity}[${i}]    apn_address=dxdata2    cap_index=${2}
            Update PA value       attenuator=${tl.attenuator[0]}      value=${127}      ru_num=${${i}}
    END
    FOR      ${i}      IN      3      4      5
        ${attend_num}      evaluate      int(${i}/4)
        Update PA value       attenuator=${tl.attenuator[${attend_num}]}      value=${0}      ru_num=${${i}}
        UE Attach and Start Traffic    ui_version=Mi11UI13    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
        ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_30M}     Expected_Throughput_UL=${UL_TDD_EXPECT_30M}
        ...                            nrCellIdentity=${nrCellIdentity}[${i}]    ue_index=1      apn_address=dxdata2    cap_index=${2}
        Update PA value       attenuator=${tl.attenuator[${attend_num}]}      value=${127}      ru_num=${${i}}
    END
    [Teardown]    Test Case Teardown with UE for CMCC

[1][1.0] 5GC001784_SF_20_DL_AddDMRS_3S_4x4_256QAM_On_NSAL3Call
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
    [Setup]    Common E2E Test Case Setup
    Connect to gnb coam via ssl
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    commissionings
    Commissioning with Template Commission      scf_file=${scf_base_path}/HGZ/7_5_UTE5G402T967/NR_Only.xml
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    connection=GNB_OAM
    FOR      ${i}      IN RANGE        0      1      2
        Update PA value       attenuator=${tl.attenuator[0]}      value=${0}      ru_num=${${i}}
        UE Attach and Start Traffic    ui_version=Mi12UI13.0.12    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
        ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
        ...                            nrCellIdentity=${nrCellIdentity}[${i}]    apn_address=dxdata2    cap_index=${2}
        Update PA value       attenuator=${tl.attenuator[0]}      value=${127}      ru_num=${${i}}
    END
    FOR      ${i}      IN      3      4      5
        ${attend_num}      evaluate      int(${i}/4)
        Update PA value       attenuator=${tl.attenuator[${attend_num}]}      value=${0}      ru_num=${${i}}
        UE Attach and Start Traffic    ui_version=Mi11UI13    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
        ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_30M}     Expected_Throughput_UL=${UL_TDD_EXPECT_30M}
        ...                            nrCellIdentity=${nrCellIdentity}[${i}]    ue_index=1      apn_address=dxdata2    cap_index=${2}
        Update PA value       attenuator=${tl.attenuator[${attend_num}]}      value=${127}      ru_num=${${i}}
    END
    [Teardown]    E2E_CMCC_common_keyword.Recover ENV

[1]CB006667_5G_HA_KPI_Cycle_Disable_Enable_actIncreasedFdmUsersPerSlot_online
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
    [Setup]    Common E2E Test Case Setup
    ${nr_bts_id}    Set variable    ${tl.gnbs[${0}].global_bts_id}
    FOR    ${i}    IN RANGE    3
        ${current_value}    5GC002029_A_common_keywords.Get parameter in SCF
        ...    para=actIncreasedFdmUsersPerSlot    dist_value=NRBTS-${nr_bts_id}/NRCELL-1
        ${update_value}    Run Keyword If    '${current_value}'=='true'    Set Variable    false
        ...    ELSE    Set Variable    true
        &{parameter}    Create Dictionary    actIncreasedFdmUsersPerSlot=${update_value}
        update parameter in SCF     update_value=${update_value}
        COAM Wait for gnb ready and cell setup    timeout=13 min
        Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    END
    [Teardown]    Test Case Teardown for CMCC


[1]OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
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
    FOR      ${i}      IN RANGE        0      1      2
        Update PA value       attenuator=${tl.attenuator[0]}      value=${0}      ru_num=${${i}}
        UE Attach and Start Traffic    ui_version=Mi12UI13.0.12    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
        ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_100M}     Expected_Throughput_UL=${UL_TDD_EXPECT_100M}
        ...                            nrCellIdentity=${nrCellIdentity}[${i}]    apn_address=dxdata2    cap_index=${2}
        Update PA value       attenuator=${tl.attenuator[0]}      value=${127}      ru_num=${${i}}
    END
    FOR      ${i}      IN      3      4      5
        ${attend_num}      evaluate      int(${i}/4)
        Update PA value       attenuator=${tl.attenuator[${attend_num}]}      value=${0}      ru_num=${${i}}
        UE Attach and Start Traffic    ui_version=Mi11UI13    data_transfer_dl=${DL_THROUGHPUT}    data_transfer_ul=${UL_THROUGHPUT}
        ...                            Expected_Throughput_DL=${DL_TDD_EXPECT_30M}     Expected_Throughput_UL=${UL_TDD_EXPECT_30M}
        ...                            nrCellIdentity=${nrCellIdentity}[${i}]    ue_index=1      apn_address=dxdata2    cap_index=${2}
        Update PA value       attenuator=${tl.attenuator[${attend_num}]}      value=${127}      ru_num=${${i}}
    END
    [Teardown]    Test Case Teardown with UE for CMCC
