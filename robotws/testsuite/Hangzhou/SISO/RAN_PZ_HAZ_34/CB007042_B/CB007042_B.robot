*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Troubleshooting/General_SiSo_Running_the_troubleshooting_scripts.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB007042 in 5G23R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***
@{CELLS_VIA_WEBEM}            NRCELL-1    NRCELL-2
@{RMODS_VIA_WEBEM}            RMOD-1/RMOD_R-1 (AEQE)
@{CELLS_VIA_ADMIN_CLI}        MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
@{RMODS_VIA_ADMIN_CLI}        MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1

*** Test Cases ***
[1]CB007042-5G-B_L1low_dump_capture_via_WebEM
    [Tags]   CRT_TRUNK    1S-2CC-4D-4U   CLOUD_5G_CLASSICAL_SA_ASILL_ABIOB1_AEQE    CRT_UTE
    Troubleshooting Scripts for Radio module   script=RU_Common_capture_L1low_data

[1]CB007042-5G-B_Register_dump_capture_via_WebEM
    [Tags]    CRT_TRUNK    1S-2CC-4D-4U
    Troubleshooting Scripts for Radio module   script=RU_Common_capture_register_dump

[1]CB007042-5G-B_RF_IQ_data_capture_via_WebEM
    [Tags]    CRT_TRUNK    1S-2CC-4D-4U
    [Setup]    SISO Coam Test Setup
    Troubleshooting Scripts for Radio module   script=RU_Common_capture_IQ_data

*** Keywords ***
Troubleshooting Scripts for Radio module
    [Arguments]    ${script}    ${iq_data_file_num}=${8}
    log    ${script}
    ${ret}    coam.launch_troubleshooting_script    script_name=${script}
    ...    output_file_name=${TS_CASE_LOG_PATH}/script_result_011_${script}.zip
    ...    cell_list=${CELLS_VIA_ADMIN_CLI}    rmod_list=${RMODS_VIA_ADMIN_CLI}
    ...    free_parameters=${EMPTY}    timeout=900    connection=GNB_OAM
    Should Be Equal    ${ret}    Launching succeeded. Snapshot has been successfully created.
    File Should Exist    ${TS_CASE_LOG_PATH}/script_result_011_${script}.zip
    check troubleshooting scripts log    script_name=${script}    BASE_PATH=${TS_CASE_LOG_PATH}
    ...    iq_data_file_num=${iq_data_file_num}

check troubleshooting scripts log
    [Arguments]  ${script_name}    ${BASE_PATH}=${TS_CASE_LOG_PATH}    ${iq_data_file_num}=${4}
    ${BASE_PATH}    Get Substring    ${BASE_PATH}    0    -1
    run keyword if    '${script_name}'=='RU_Common_capture_IQ_data'    check RU Common capture IQ data log
    ...    BASE_PATH=${BASE_PATH}    file_num=${4}   iq_data_file_num=${iq_data_file_num}
    ...    ELSE IF    '${script_name}'=='RU_Common_capture_register_dump'    check RU Common capture register dump log
    ...    BASE_PATH=${BASE_PATH}
    ...    ELSE IF    '${script_name}'=='RU_Common_capture_L1low_data'    check RU Common capture L1low data log
    ...    BASE_PATH=${BASE_PATH}

check RU Common capture IQ data log
    [Arguments]  ${BASE_PATH}=${TS_CASE_LOG_PATH}    ${file_num}=${4}    ${iq_data_file_num}=${4}
    log to console    \n check RU Common capture IQ data log
    ${check_file}    set variable     script_result_011_RU_Common_capture_IQ_data
    Extract Zip File    ${BASE_PATH}/${check_file}.zip
    ...                 ${BASE_PATH}/${check_file}
    ${trblshoot_flag_1}    Check Trblshoot in IQ Data    path=${BASE_PATH}/${check_file}
    ${BTS_part1_Exist}    run keyword and return status    File Should Exist     ${BASE_PATH}/${check_file}/BTS_part1.zip
    run keyword if  ${BTS_part1_Exist}   Extract Zip File    ${BASE_PATH}/${check_file}/BTS_part1.zip
    ...    ${BASE_PATH}/${check_file}/BTS_part1
    ${trblshoot_flag_2}    run keyword if    ${BTS_part1_Exist}    Check Trblshoot in IQ Data    path=${BASE_PATH}/${check_file}/BTS_part1
    ...    ELSE    set variable    ${False}
    should be true    ${trblshoot_flag_1} or ${trblshoot_flag_2}    msg=sm0 is not exsit!
    ${all_file_dict}    create dictionary
    Check Cap File in IQ Data    path=${BASE_PATH}/${check_file}    all_file_dict=${all_file_dict}
    Check Cap File in BTS part    path=${BASE_PATH}/${check_file}    all_file_dict=${all_file_dict}
    Check All Files Cap Num Dict Local    all_file_dict=${all_file_dict}    num=${file_num}
    ${keys}    get dictionary keys    ${all_file_dict}
    ${num}    get length    ${keys}
    should be equal as numbers    ${num}    ${iq_data_file_num}

Check All Files Cap Num Dict Local
    [Arguments]  ${all_file_dict}    ${num}
    FOR    ${cap_dict}    IN    @{all_file_dict.values()}
        Check Cap Num Dict Local    cap_dict=${cap_dict}    num=${num}
    END

Check Cap Num Dict Local
    [Arguments]  ${cap_dict}    ${num}
    FOR    ${cap_name}    IN    @{cap_dict.keys()}
        should be true   ${cap_dict}[${cap_name}]>=${num}
    END
