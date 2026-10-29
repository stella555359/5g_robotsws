*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=0x580692=1    scf_file=${SCFC_FILE}
...               AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    Owner_y7li
...               SBTS00    SBTS23R2    CN1_SQ6    CB009169    RAN_5G    RAN_5G_TDD    CRT
Resource          Resources/CB009169_Common.robot
Resource          ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
@{LOG_NAME_LIST}            snapshot
${SCF_PATH}                 ${CURDIR}/Config
${SCFC_FILE}                CB009169_BB606_scfc.xml
${WTS_LOCAL}                ${CURDIR}/Resources/wts
${WTS_CFG}                  CB009169_BB_006.cfg
${2CC_UL_DATA}              40
${2CC_DL_DATA}              300
&{COUNTER_1}                counter_id=M55167C00001    counter_path=CELLS/NRCELL-3/NCADC    min_value=295    max_value=301
&{COUNTER_2}                counter_id=M55167C00002    counter_path=CELLS/NRCELL-3/NCADC    min_value=895    max_value=901
&{COUNTER_3}                counter_id=M55167C00003    counter_path=CELLS/NRCELL-3/NCADC    min_value=295    max_value=301
&{COUNTER_4}                counter_id=M55139C04001    counter_path=CELLS/NRCELL-3/RSADU    min_value=2    max_value=4
&{COUNTER_5}                counter_id=M55139C04002    counter_path=CELLS/NRCELL-3/RSADU    min_value=0    max_value=2
&{COUNTER_6}                counter_id=M55308C28003    counter_path=CELLS/NRCELL-1/NCELA    min_value=0
&{COUNTER_7}                counter_id=M55308C28004    counter_path=CELLS/NRCELL-1/NCELA    min_value=2    max_value=4
&{COUNTER_8}                counter_id=M55308C28007    counter_path=CELLS/NRCELL-1/NCELA    min_value=0
&{COUNTER_9}                counter_id=M55308C28008    counter_path=CELLS/NRCELL-1/NCELA    min_value=0    max_value=2
@{COUNTER_ID_LIST_1}        ${COUNTER_4}    ${COUNTER_5}        
@{COUNTER_ID_LIST_2}        ${COUNTER_1}    ${COUNTER_2}    ${COUNTER_3} 
@{COUNTER_ID_LIST_3}        ${COUNTER_6}    ${COUNTER_7}    ${COUNTER_8}    ${COUNTER_9}   
@{3CC_UE_LIST}              1    2    5    6
@{3CC_PCELL_ID_LIST}        52    52    52    52
@{SCELL_PHYSICALID_1}       50    53
@{SCELL_PHYSICALID_2}       50    53
@{SCELL_PHYSICALID_3}       50    53
@{SCELL_PHYSICALID_4}       50    53
@{SCELL_PHYSICALID_LIST}    ${SCELL_PHYSICALID_1}    ${SCELL_PHYSICALID_2}    ${SCELL_PHYSICALID_3}    ${SCELL_PHYSICALID_4}
@{3CC_EXP_DL_TPUT_LIST}     5    5    1
@{2CC_EXP_UL_TPUT_LIST}     3    3

*** Test Cases ***
CB009169_ET_BB606_Verify_Single_UE_T_F_UL_CA_IWK_With_BWP_Use_Optimized_F3_ActEnhMultipleDedicatedBWPs_Enable_DL_Large_And_UL_Small_BWP_Supported
    Wait Until PM Counter Update
    SA Multi UE Attach With Scell Blind Addition    ${3CC_UE_LIST}    ${SCELL_PHYSICALID_LIST}    3
    SA Multi UE Start DL Traffic    ${3CC_UE_LIST}    600
    SA Multi UE Start UL Traffic    ${3CC_UE_LIST}    100
    Sleep    10s    reason=wait DL/UL traffic is stable
    Check Multi UE DLCA And 2CCULCA L1 Cell Tput    ${3CC_UE_LIST}    ${2CC_EXP_UL_TPUT_LIST}    ${3CC_EXP_DL_TPUT_LIST}    3
#    Wait Until PM Counter Update    5min    0
    Wait Until Keyword Succeeds     10min    3min     Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST_1}
	Wait Until Keyword Succeeds     10min    3min     Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST_3}
    Wait Until PM Counter Update    5min    2
    Check Multi PM Counters Latest Value From Admin    ${COUNTER_ID_LIST_2}
    Save Egate Log    ${TEST_LOG_DIRECTORY}/egate/
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB009169_BB${/}CB009169_BB006_2.ini    u
    ...    save_log_directory=${TEST_LOG_DIRECTORY}/egate/
