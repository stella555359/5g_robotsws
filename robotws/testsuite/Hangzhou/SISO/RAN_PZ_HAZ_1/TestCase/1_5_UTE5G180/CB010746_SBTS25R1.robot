*** Settings ***
#Force Tags
Documentation    Suite description
...    Author:        wei.ren@nokia-sbell.com
...    Maintainer:    weren

Library     Telnet
Library    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/kpiReporter.py
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/oam_kpi_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/reportportal.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/common_setup.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/test_fv.robot
Variables    ./env.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition

Force Tags    CA_RAN_PZ_HAZ_1    SBTS25R1    RAN_5G    CRT    STATE_SW_UPLOADED

*** Variables ***
${peak1}    "660":[120,20],"661":[120,20],"662":[120,20],"663":[120,20],"675":[120,20],"665":[120,20]
${peak2}    "666":[120,20],"667":[120,20],"668":[120,20],"669":[120,20],"670":[120,20],"671":[120,20]
${peak3}    "676":[120,20],"690":[120,20],"610":[120,20]
${peak4}    "170":[140,20],"171":[140,20],"172":[140,20],"173":[140,20],"174":[140,20],"175":[140,20]
${peak5}    "186":[70,20],"187":[70,20],"188":[70,20],"179":[140,20],"180":[140,20],"181":[140,20]
${peak6}    "182":[70,20],"183":[70,20],"184":[70,20],"185":[70,20]
&{CB010746_B2}    HW_ID=ABIP   site_mode=5G    ONAIR_TIME=20 min
...	  peak_rate_config={${peak1},${peak2},${peak3},${peak4},${peak5},${peak6}}

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
${INIT_CONFIG_ID}     CB010746_B2
@{ADDITIONAL_ADMIN_ALLOWED_ALARMS}    NgGnbInitPartialReset    NgGnbInitFullReset    No module fan detected

${online_commissioning}    [['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['dlChBw','10 MHz']],
...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1/LNCEL_FDD-0',['ulChBw','10 MHz']],
...                         ['MRBTS-37039/LNBTS-37039/LNCEL-1',['actDownSampling','false']]]

${prach_parameters}    [['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFdd','true']],
...                     ['MRBTS-37039/NRBTS-37039',['actAutoPrachConfigIndexFddEnh','true']],
...                     ['MRBTS-37039/NRBTS-37039/NRDU-1',['crntiAllocationOption','max72cellsEnh']]]
${GLO_PERFORM_SAVE_LOG}    FAIL
${INIT_SW_VERSION}    {'37039': 'SBTS24R1_ENB_0000_000009_000000'}
${TARGET_SW_VERSION}    {'37039': 'SBTS00_ENB_9999_231013_000009'}
${RB_TO_TARGET}    YES
${YAFT}    YES
${TDD_OR_FDD}    FDD
${SPECIFIC_BRANCH}     Yes
${TOP50}                             True
${RU}    3AREA+2FRPA+3AHEGC+2AHHB
${SA_OR_NSA}
${HW_ID}    1ASIM+1ABIP+3AREA+2FRPA+3AHEGC+2AHHB
*** Test Cases ***
#CB010746
[1] Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock
    [Tags]    QC_132757    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock    config_id=CB010746_B2
    [Timeout]    72h
    Common_SiSo_State Management_RF Lock_Then_resetBBMOD_Then_RF unlock    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell block_Then_RF reset_Then_Cell unblock
    [Tags]    QC_132759    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=CB010746_B2
    Cell Block And Unblock All with rfreset    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1][1.0] Common_SiSo_State Management_Cell Block&unblock_Then_RF Lock&Unlock
    [Tags]    QC_132758    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=L3call    config_id=CB010746_B2
    Cell Block And Unblock All    required_cells=665
    Append To List    ${GLO_ADMIN_ALLOWED_ALARM}    Cell blocked
    Ru lock And Unlock All    required_cells=665
    [Teardown]    Testcase Basic Postcondition

[1] Manual_SiSo_SM_LTE_RAT_reset_for_concurrent
   [Tags]    QC_132760    QCD_MN_RAN    QCP_RAN_VRF
   [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB010746_B2
   RAT reset from WebEm For LTE testline        required_cells=665
   [Teardown]    Testcase Basic Postcondition

[1] Manual_SiSo_SM_NR_RAT_reset_for_concurrent
    [Tags]    QC_132761    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Testcase Basic Precondition    case_name=RAT_reset_from_WebEm    config_id=CB010746_B2
    RAT reset from WebEm For NR testline       required_cells=665
    [Teardown]    Testcase Basic Postcondition
