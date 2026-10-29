*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           
Test Teardown        
Test Timeout         60 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_gnb_can_be_on_air_with_Given_Information.robot
#Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
#Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG5/robot/UUF4ALL/Resource/SW_Upgrade_WebUI_common_KW.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature "CB007425 ASIM legacy features support up to 22R1" in SBTS23R2 program

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY36    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB007425-5G-AA61-5GC001987-04_cell_lock_unlock_with_CHBW_70Mhz
    [Tags]    1S-1CC-4D4U-TDD    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_gnb_can_be_on_air_with_Given_Information    band=70    frame_structure=1070_GP1_A3
    ...    prach_index=157    beamset=2 beams    basicBeamSet=beamSet_2
    General_SiSo_Cell_lock_and_unlock   with_call=${True}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

[1]CB007425-5G-AA17-5GC001076-03_L3call_verification_with_CHBW_50Mhz
    [Tags]    1S-1CC-4D4U-TDD    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
#    General_SiSo_Peak_with_Given_Information    use_case_variable=${True}
#    ...    suite_name=${SUITE NAME}    test_name=${TEST NAME}
#    ...    ue_num_each_call=1

    General_gnb_can_be_on_air_with_Given_Information    band=50    frame_structure=1116_0ms_GP1_A8
    ...    prach_index=198    beamset=2 beams    basicBeamSet=beamSet_2
    ${cell_list}     create list    ${1}
    Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${False}
    ...    duration=${60}    ue_num_each_call=1
    [Teardown]    SISO Coam Test Teardown

[1]CB007425-5G-AC55-02_SWM_supports_SW_activation_via_WebEM
    [Tags]    2S-1CC-TDD-FDD-Mixed    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${swUpdate_Status}    Run Keyword And Return Status    SWM supports provision SW build package via WebUI
    Sleep    50s
    Run Keyword If    '${swUpdate_Status}'=='True'    Classical gNB Software Rollback successfully via WebUI
    [Teardown]    SISO Coam Test Teardown

[1]CB007425-5G-AD30-CB007262-A1-02_General_SiSo_Cell_block_and_unblock
    [Tags]    2S-1CC-TDD-FDD-Mixed    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_block_and_unblock    with_call=${True}    with_peak=${False}
    ##${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=0
    #Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${4681}
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown
#Minor fault 4681 here is expected according to the requirement of CB010239 as RMOD-2 is uncommission before this TC executed.
#Refer to PR725805.

*** Keywords ***
