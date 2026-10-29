*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
# Test Setup           SISO Coam Test Setup
# Test Teardown        SISO Coam Test Teardown
Test Timeout         3h

Resource      ./resource/CB011159_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB011159 in SBTS25R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Test Cases ***
[1]CB011159_SR_A_11_Verify_Tput_With_1UE_Different_Parameters_mMIMO
    [Tags]    1S-1CC-8D8U   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Verify_Tput_With_1UE_Different_Parameters_mMIMO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB011159_SR_B_2_Verify_Tput_With_1UE_50+50_mMIMO
    [Tags]    1S-2CC-4D4U   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    Verify_Tput_With_1UE_50+50_mMIMO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB011159_SR_C_1_Verify_CellSetup_With_NR-1cc-8d8u+LTE-1cc-8D8U-SBTS_mode
    [Tags]    1S-1CC-8D8U-NR-LTE-SBTS   CRT_TRUNK
    [Setup]    SISO Coam Test Setup
#    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}       gnb_index=0
#    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=nr
#    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}       gnb_index=1
#    Wait until keyword succeeds    10min    30s    Verify all cells should be onair    cell_type=${cell_type}
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}    4G_check=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB011159_SR_C_2_Verify_Tput_With_1UE
    [Tags]    1S-1CC-8D8U-NR-LTE-SBTS    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${cell_list}    create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}  with_peak=${False}    4G_check=${False}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

[1]CB011159_SR_D_1_Verify_CellSetup_With_NR_1cc+1cc_8D8U_split_mode_64TRX
    [Tags]    1S-2CC-4D4U   CRT_TRUNK
    [Setup]   SISO Coam Test Setup
    Configure NRCELL to 2CC Split Mode
    Verify_Tput_With_1UE_50+50_mMIMO
    [Teardown]    Run Keywords    Run Keyword And Ignore Error   Connect to gnb coam via ssl
    ...    AND    Commissioning SCF And Check On Air    scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
