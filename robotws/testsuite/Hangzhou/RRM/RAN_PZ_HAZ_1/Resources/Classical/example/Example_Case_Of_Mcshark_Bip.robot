*** Settings ***
Documentation
...    Author: Du Ning
...    Contact: ning.du@nokia-sbell.com
...    This is an example case to catch and check bip log by Mcshark.
Resource                ../RRM_Common_Resource.robot
Suite Setup             Common Suite Setup For RRM
Suite Teardown          Common Suite Teardown For RRM
Test Setup              Common Test Setup For RRM    scf_file_path=${default_scf}    ALLOWED_FAULT=@{MY_ALLOWED_FAULT}
Test Teardown           Common Test Teardown For RRM
Force Tags              RAN_5G
...                     CLOUD_5G_CLASSICAL_1xMIFI_ASIBL_ABIAB1_ABIOB2_FRGU_AHEGB
...                     SBTS00    SBTS22R1    SBTS21B
...                     STATE_SW_UPLOADED
...                     RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG01_ST_RRM
...                     TA_LEVEL_22
Test Timeout            120 minutes

*** Variables ***
${DST_FOR_BTS}          MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
${DST_FOR_FRM}          MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
${DST_FOR_GROUP}        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
${DST_FOR_PMCADM}       MRBTS-${MRBTS_ID}/MNL-1/PMCADM-1
${ue_index}             ${tl.ues[0]}
${default_scf_path}     ${CURDIR}/../../../../../../../commissionings/RRM/SRAN_5G/10_5_UTESRAN001T${MRBTS_ID}
${default_scf_trunk}    ${default_scf_path}/10_5_UTESRAN001T${MRBTS_ID}_NSA_2DL_2UL.xml
${default_scf_22R1}     ${default_scf_path}/10_5_UTESRAN001T${MRBTS_ID}_NSA_2DL_2UL_SBTS22R1.xml
${default_scf_21B}      ${default_scf_path}/10_5_UTESRAN001T${MRBTS_ID}_NSA_2DL_2UL_SBTS21B.xml
${alarm23}              23
&{fault_4681}           faultId=${4681}
@{MY_ALLOWED_FAULT}     &{fault_61652}    &{fault_61524}    &{fault_61649}    &{fault_4654}    &{fault_6450}    &{fault_4592}    &{fault_4655}
...                     &{fault_7311}    &{fault_4681}
${bip_log_name}         bip_log.pcap

*** Test Cases ***
CB005882_5GC002535_A_019_L3Call_20Mhz_DLMax_FDM_PDSCH_DMRS_ON_StaticUE_Variable_RC
    [Tags]    Case2535
    [Setup]    Case Precondition 2535
    Get Attenuation Initial Values
    Init Attenuation Values    0
    Make Call With DL
    Start BIP Trace
    Stop Mcshark BIP Trace
    Check Mcshark BIP Log
    Run Keyword And Ignore Error    Stop DL THPUT
    [Teardown]    Case Postcondition

*** Keywords ***
Case Precondition 2535
    Log To Console    \nCommon test setup running...
    ${default_scf}=    Decide Scf    NSA_2DL_2UL
    Common Test Setup For RRM    scf_file_path=${default_scf}    ALLOWED_FAULT=@{MY_ALLOWED_FAULT}

Case Postcondition
    Common Test Teardown For RRM

Decide Scf
    [Arguments]    ${postfix}
    ${release}=    Get Release By Sw Version    sw=${EXPECT_SW_VERSION}
    ${required_scf}=    Set Variable If    "${release}" == "SBTS00"    ${default_scf_path}/10_5_UTESRAN001T${MRBTS_ID}_${postfix}.xml
    ...                                    "${release}" == "SBTS22R1"    ${default_scf_path}/10_5_UTESRAN001T${MRBTS_ID}_${postfix}_SBTS22R1.xml
    ...                                    "${release}" == "SBTS21B"    ${default_scf_path}/10_5_UTESRAN001T${MRBTS_ID}_${postfix}_SBTS21B.xml
    [Return]    ${required_scf}

Prepare MIFI
    log to console  Preparing UE...
    ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
    set test variable    ${ue_type}
    Prepare UE    ${ue_type}    ue_index=${0}

Attach MIFI
    log to console  Attaching UE...
    UE Attach    ${ue_type}    ue_index=${0}

Get Attenuation Initial Values
    Log to console    Get and store the init atten values
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=JFW    gnb_id=0
    set suite variable    ${initial_att_values}

Init Attenuation Values
    [Arguments]    ${init_value}=0
    Log to console    Initial the atten values
    ${attenuation_channels}     Get Attenuation port    RU_id=0    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=${init_value}   ${attenuation_channels[1]}=${init_value}
    ...    ${attenuation_channels[2]}=${init_value}   ${attenuation_channels[3]}=${init_value}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[4]}=${init_value}   ${attenuation_channels[5]}=${init_value}
    ...    ${attenuation_channels[6]}=${init_value}   ${attenuation_channels[7]}=${init_value}
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    gnb_id=0

#--2535 keywords--
Make Call With DL
    Prepare MIFI
    Attach MIFI
    Sleep  30s
    Start DL TPUT
    Sleep  3s

Start DL TPUT
    Log To Console  Starting DL TPUT...
    Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=dl    dt_index=${0}
    ...              throughput=400M    duration=300

Stop DL THPUT
    Log  Stoping DL TPUT...
    Stop traffic    ${ue_type}    ue_index=${0}    direction=dl

Start BIP Trace
    Log To Console    Start McShark BIP Log
    ${connection_ASIB}    Start Bip Capture with gnbMirroring scripts and MCShark    file_size_mbytes=200
    ...                                                                              number_of_files=1
    ...                                                                              mirror_abil_1=false
    ...                                                                              mirror_abil_2=true
    Set Test Variable    ${connection_ASIB}

Stop Mcshark BIP Trace
    Log To Console    Stop McShark BIP Log
    ${bip_log_path}    Stop BIP trace    local_log_name=${bip_log_name}    connection_ASIB=${connection_ASIB}
    Set Test Variable    ${bip_log_path}

Check Mcshark BIP Log
    Log To Console    Check McShark BIP Log
    ${filter}=    Catenate    DlData_PdschGrant.numOfDmrsCdmGroupWithoutData and DlData_PdschGrant.mcs
    @{csv_title_list}=    Create List    DlData_PdschGrant.numOfDmrsCdmGroupWithoutData    DlData_PdschGrant.mcs
    ${csvname}=    Set Variable    ${TEST_LOG_DIRECTORY}/csv_2535_BIP.csv
    Convert BIP To CSV By MCShark    ${bip_log_name}    ${csvname}    ${filter}    ${csv_title_list}
    ${csv_matrix}=    Read Csv File Into Matrix    file_path=${csvname}
    ${column_list_dmrs}=    Get Column From Matrix    matrix=${csv_matrix}    column_nubmer=${3}
    ${column_list_mcs}=    Get Column From Matrix    matrix=${csv_matrix}    column_nubmer=${4}
    Remove From List    ${column_list_dmrs}    0
    Remove From List    ${column_list_mcs}    0
    ${len_dmrs}=    get length    ${column_list_dmrs}
    ${len_mcs}=    get length    ${column_list_mcs}
    Should Be Equal    ${len_dmrs}  ${len_mcs}
    Should Be True    ${len_dmrs}>0
    FOR    ${index}    IN RANGE    ${len_dmrs}
        Continue For Loop If    ${column_list_dmrs[${index}]} != 0x01
        ${is_pass}    Set Variable If    ${column_list_mcs[${index}]} >= 0x14    ${True}    ${False}
        Set Test Variable  ${is_pass}
        Exit For Loop If  ${is_pass}
    END
    Should Be True  ${is_pass}==${True}
