*** Settings ***
Force Tags    PY36
Documentation      Author: xiangyue.zhou@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE    scf_file_name=Configuration_CB009464_Concurrent_${stream}
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_variables.py

*** Variables ***
${cellid}    ${1}
${PA_value}    50

*** Test Cases ***
#[2][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    [Documentation]    CHBW:10MHz
#    ...                Feature_ID:CB009464_A
#    [Timeout]    60m
#    [Tags]    CRT_TRUNK    CRT_23R4    CRT_24R1
#    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_CB009464_NR_Only_${stream}
#    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=0
#    Update UE Attach Cell Index on SA Mode    attach_cell_index=1
#    Sleep    3min
#    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
#    Start L3 Call And Verify Throughput    ul_data_transfer=8M
#    ...                                    dl_data_transfer=150M
#    ...                                    expect_ul_tput=4.6
#    ...                                    expect_dl_tput=119
#    ...                                    4G_check=${False}
#    ...                                    reset_sol=${reset_sol}
#    ...                                    cellid=${cellid}
#    ...                                    target_avg_percent=0.95
#    [Teardown]   702 Case TearDown For UTE

[3][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Documentation]    CHBW:20MHz
    ...                Feature_ID:CB009464_B
    [Timeout]    60m
    [Tags]    CRT_TRUNK    CRT_24R2    CRT_24R3    CRT_25R1    CRT_25R2
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_CB009464_Concurrent_${stream}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=0
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=20M
    ...                                    dl_data_transfer=400M
    ...                                    expect_ul_tput=10
    ...                                    expect_dl_tput=260
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cellid}
    ...                                    target_avg_percent=0.95
    [Teardown]    run keywords    Run Keyword And Ignore Error    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                                                 scf_file_name=SCF_${stream}
    ...                                                                                                is_pdl_checking_needed=${False}    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api
    ...                                                                                                is_x2_check_from_gnb_needed=${False}    AND
    ...                                                           702 Case TearDown For UTE

[1][1.1] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Documentation]    CHBW:20MHz
    ...                Feature_ID:CB009464_B
    [Timeout]    60m
    [Tags]    CRT_24R2
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_CB009464_Concurrent_${stream}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=0
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=20M
    ...                                    dl_data_transfer=400M
    ...                                    expect_ul_tput=10
    ...                                    expect_dl_tput=260
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cellid}
    ...                                    target_avg_percent=0.95
    [Teardown]    run keywords    Run Keyword And Ignore Error    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                                                 scf_file_name=SCF_${stream}
    ...                                                                                                is_pdl_checking_needed=${False}    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api
    ...                                                                                                is_x2_check_from_gnb_needed=${False}    AND
    ...                                                           702 Case TearDown For UTE

[1][2.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Documentation]    CHBW:20MHz
    ...                Feature_ID:CB009464_B
    [Timeout]    60m
    [Tags]    CRT_TRUNK
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_CB009464_Concurrent_${stream}
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=0
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=20M
    ...                                    dl_data_transfer=400M
    ...                                    expect_ul_tput=10
    ...                                    expect_dl_tput=260
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cellid}
    ...                                    target_avg_percent=0.95
    [Teardown]    run keywords    Run Keyword And Ignore Error    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                                                 scf_file_name=SCF_${stream}
    ...                                                                                                is_pdl_checking_needed=${False}    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api
    ...                                                                                                is_x2_check_from_gnb_needed=${False}    AND
    ...                                                           702 Case TearDown For UTE

