*** Settings ***
Documentation    Suite description
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008152/resources/CB008152.py    WITH NAME    CB008152
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot


*** Keywords ***
Set attenuation 8152_B4_13_11_SA_FDD_35MHz_DFT-OFDM_UL_ABIP
    [Arguments]  ${att_value_503_504}=0
    ${att_ports_503_504}=  Create List  1  2  3  4
    ${att_value_not_used}=  Set Variable  90
    ${att_ports_not_used}=  Create List
    ...  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24
    Set attenuation and check  lines=@{att_ports_503_504}    value=${att_value_503_504}
    Set attenuation and check  lines=@{att_ports_not_used}    value=${att_value_not_used}

Set attenuation 8152_B4_B4_05_02_SA_2UEs_FDD_35MHz_PeakTput_UL_DL_ABIQ
    [Arguments]  ${att_value_505_506}=0
    ${att_ports_505_506}=  Create List  21  22  23  24
    ${att_value_not_used}=  Set Variable  90
    ${att_ports_not_used}=  Create List
    ...  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18  19  20
    Set attenuation and check  lines=@{att_ports_505_506}    value=${att_value_505_506}
    Set attenuation and check  lines=@{att_ports_not_used}    value=${att_value_not_used}

Set attenuation CB008152-B5_20_03_SA_FDD_35MHz_CB008532_4CC_DL_CA_1T+3F
    [Arguments]  ${att_value_100_107}=0  ${att_value_505_506}=0
    ${att_ports_100_107}=  Create List  17  18  19  20
    ${att_ports_505_506}=  Create List  21  22  23  24
    ${att_value_not_used}=  Set Variable  90
    ${att_ports_not_used}=  Create List
    ...  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16
    Set attenuation and check  lines=@{att_ports_100_107}    value=${att_value_100_107}
    Set attenuation and check  lines=@{att_ports_505_506}    value=${att_value_505_506}
    Set attenuation and check  lines=@{att_ports_not_used}    value=${att_value_not_used}

Verify DFT OFDM
    [Arguments]  ${value}  ${log_path}
    ${result}=  CB008152.check_DFT_OFDM_value  ${value}  ${log_path}
    Log to console  Check RRC Reconfiguration message if DFT OFDM ${value}
    Should be True  ${result}  Expected transformPrecoder value equal to ${value} not found in DCAP logs ${log_path}

Check tput on UEs
    [Documentation]  Check if overall tput meets expected tresholds
    [Arguments]    ${avg_tput_DL_UE_1}  ${avg_tput_UL_UE_1}  ${avg_tput_DL_UE_2}  ${avg_tput_UL_UE_2}
    ...  ${expected_tput_DL}  ${expected_tput_UL_UE}
    Should Be True  ${avg_tput_DL_UE_1}+${avg_tput_DL_UE_2} > ${expected_tput_DL}  Sum of DL UEs tput must be above ${expected_tput_DL}
    Should Be True  ${avg_tput_UL_UE_1}+${avg_tput_UL_UE_2} > ${expected_tput_UL_UE}  Sum of UL UEs tput must be above ${expected_tput_UL_UE}

Verify CA configured
    [Arguments]  ${log_path}
    ${result}=  CB008152.verify_ca_configured  ${log_path}
    Log to console  Check CA configured with scells 100 and 506
    Should be True  ${result}  CA configuration with scells 100 and 506 not found in DCAP logs ${log_path}

Get counters value For M55309C12001
    ${counters_values}=   Create List
    Collect Counters   n_last=15
    @{counters}   Create list  M55309C12001
    FOR    ${counter}    IN      @{counters}
        ${value}    Get sum of n last counter values   3  ${counter}
        Append To List      ${counters_values}      ${value}
    END
    [Return]        ${counters_values}

Verify Tput with counter M55309C12001
    [Arguments]  ${expected_tputdl_100}  ${expected_tputdl_177}  ${expected_tputdl_506}
    log to console              Waiting for BTS Counters update 300s
    sleep   300s
    ${counters}                 Get counters value For M55309C12001
    Log to console  ${counters}
    ${tputdl_100}                    get_counter_value_from_single_cell   ${counters}  100    M55309C12001
    ${tputdl_177}                    get_counter_value_from_single_cell   ${counters}  177    M55309C12001
    ${tputdl_506}                    get_counter_value_from_single_cell   ${counters}  506    M55309C12001

    Should Be True  ${tputdl_100}>=${expected_tputdl_100}  DL tpult on cell 100 is lower than expected ${expected_tputdl_100}
    Should Be True  ${tputdl_177}>=${expected_tputdl_177}  DL tpult on cell 177 is lower than expected ${expected_tputdl_177}
    Should Be True  ${tputdl_506}>=${expected_tputdl_506}  DL tpult on cell 506 is lower than expected ${expected_tputdl_506}
