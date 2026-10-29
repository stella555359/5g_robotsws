*** Settings ***
Force Tags    PY36
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE    is_need_upload_swconfig_file=${False}
Suite Teardown    702 Suite TearDown For UTE
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010744_C/TestData/variables.py

*** Variables ***
@{rd16DLon6SPforAbipEnable}    0x420089=1    #rd16DLon6SPforAbip


*** Test Cases ***
[1]CB010744_C_04_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_1x16DL8UL_2x8DL4UL
    [Documentation]    CHBW:100_30_20MHz
    [Tags]    Classical    CRT_TRUNK    CRT_24R2    CRT_24R3    CRT_25R1    CRT_25R2
    [Timeout]    120m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_16D8U_${stream}
    CB010744_C_04_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_1x16DL8UL_2x8DL4UL
    ...                                                                                frames_info=${frame_structure_list_100MHz_40MHz_40MHz}
    ...                                                                                scf_file_name=Configuration_16D8U_${stream}
    [Teardown]   702 Case TearDown For UTE    is_recover_env=${True}

#[1]CB010889_SR_AB_01_3CC_8D8U_data_transfer_100+50+20_1116_0ms
#    [Documentation]    CHBW:100_30_20MHz
#    [Tags]    Classical    CRT_TRUNK
#    [Timeout]    120m
#    [Setup]  702 Case SetUp For UTE    scf_file_name=SCF_${stream}_1S_3CC_8D8U_8RX
#    CB010889_SR_AB_01_3CC_8D8U_data_transfer_100+50+20_1116_0ms
#    ...                                                                                frames_info=${frame_structure_list_100MHz_50MHz_20MHz}
#    [Teardown]   702 Case TearDown For UTE    is_recover_env=${True}
