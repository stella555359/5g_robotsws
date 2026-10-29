*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         60 min

Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource             ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009410-A SFP validation enhancements for BH interfaces in SBTS24R2 program
...    Feature CB009410-B SFP validation enhancements for FH interfaces in SBTS24R2 program
...    HW: SFP/SFP+ 10GE

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB009410-B_FH_05_BTS_shall_support_NIDD_parameter_SFPOperatorMode_to_enable_and_disable_other_BG_BU_transceivers_compliance_validation
    [Documentation]  CB009410 regression would dedicated on TL461
    ...    with BH:
    ...    EIF1: 3HE09328AA SFP+10GE which is in whitelist and connect to Switch - No unexpected alarms
    ...    EIF2: 3AL82059AA 10G Bidirectional-U SFP+ Tx 1270nm which is in whitelist but kept idle (not connect to switch) - FID:61029
    ...    EIF3: 3CC50388AA 10GB/s SFP which is NOT in whitelist and kept idle (not connect to switch) - FID:4657 & FID:61029
    ...    with FH:
    ...    TBD (would combined with BH/FH after 24R2 BO)

    [Tags]    2S-1CC-TDD-FDD-Mixed_CB009410    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    4657    61029    4681
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    log to console   \nCheck and modify sfpOperatorMode to false On WebEM
    Connect to gnb coam via ssl    connection=sfp    gnb_index=0
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.get_sfp_data    connection=sfp
    Run Keyword And Ignore Error    taf.sbts.oam.coam.admin.get_sfp_links   connection=sfp
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1
    ...    filter_param=SFP Operator Mode    abbr=sfpOperatorMode    new_value=false
    log to console   \nCheck fault 4657 Appear On WebEM
    Wait until keyword succeeds    5min    30s    Expect Fault Should Present    faultId=4657
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1
    ...    filter_param=SFP Operator Mode    abbr=sfpOperatorMode    new_value=true
    log to console    \nCheck fault 4657 Absent On WebEM\n
    Wait until keyword succeeds    5min    30s    Expect Fault Should Absent    faultId=4657
    [Teardown]    Run Keywords    add fault to the allowed fault list    faultId=${61029}
    ...    AND    add fault to the allowed fault list    faultId=${4657}
    ...    AND    append fault to the allowed history fault list    faultId=${4657}
    ...    AND    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
    ...    AND    SISO Coam Test Teardown

*** Keywords ***
append fault to the allowed history fault list
    [Arguments]    ${faultId}
    ${ALLOWED_HISTORY_FAULT_TEMP}    Copy List    ${ALLOWED_HISTORY_FAULT}
    ${fault_dic}    Create Dictionary    faultId=${faultId}
    Append To List     ${ALLOWED_HISTORY_FAULT_TEMP}    ${fault_dic}
    Set suite Variable    ${ALLOWED_HISTORY_FAULT}    ${ALLOWED_HISTORY_FAULT_TEMP}
