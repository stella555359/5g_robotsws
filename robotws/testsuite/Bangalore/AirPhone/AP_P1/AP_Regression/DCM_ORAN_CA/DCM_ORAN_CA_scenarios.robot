*** Settings ***

Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description: This feature tests ORAN Carrier Aggregation scenarios with DCM.

Resource        ./DCM_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=DCM_ORAN_CA

*** Variables ***
${dl_tput}               5
${ul_tput}               5
@{SA_UE_List}            1
@{FDD_UE_List}           1    2
#${timer}                           5400
${capability_file}                 capability.cfg
${commands_file}                   commands.lua
${multi_ue_file}                   multi_ue_sa_script_new
${sansa_file}                      sansa.lua

${TDD_UL_2CC_CA_peak_TP_cfg}       ${CURDIR}/Config_Files/TDD_UL_2CC_CA_peak_TP
&{TC1}    Cell_Count=1    NO_OF_CELLS=1    DIR=None       AMF_PAIR=1,1
   ...    AMF_COUNT=1    NO_REG=True    timer=1170
   ...    UEC_COUNT=6    LOOP_TIMES=1
   ...    SIB_WAIT_TIME=60    test_entry=TC15_ORAN_TDD_UL_2CC_CA_peak_TP

${TDD_DL_3CC_CA_peak_TP_cfg}       ${CURDIR}/Config_Files/TDD_DL_3CC_CA_peak_TP
&{TC2}    Cell_Count=1    NO_OF_CELLS=1    DIR=DL
   ...    AMF_COUNT=5    NO_REG=True    timer=1170
   ...    UEC_COUNT=6    LOOP_TIMES=1    END_UE=1    OVERALL_DL=1600
   ...    SIB_WAIT_TIME=60    test_entry=TC16_ORAN_TDD_100MHz_FR1_3CC_CA    timeout=120

${pdu_id}                          1
@{SA_Scell_Index}                  0    1

*** Test Cases ***
TC1_TDD_UL_2CC_CA_peak_TP
    [Tags]    AP_REG    TDD_UL_2CC_CA_peak_TP
    [Setup]    Test Setup for DCM    TC_dictionary=&{TC1}
    ...        feature=TDD_UL_2CC_CA_peak_TP        custom_config=True
    ...    custom_config_folder=${TDD_UL_2CC_CA_peak_TP_cfg}
    Initiate UE Register And Traffic
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate throughput from UE stats for all UEs    ue_list=${SA_UE_List}    expected_dl_tput=0
    ...    expected_ul_tput=200    scell=${SA_Scell_Index}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    [Teardown]    Simple Test Teardown    ${SA_UE_List}

TC2_TDD_DL_3CC_CA_peak_TP
    [Tags]    AP_REG    TDD_DL_3CC_CA_peak_TP
    [Setup]    Test Setup for DCM    TC_dictionary=&{TC2}
    ...        feature=TDD_DL_3CC_CA_peak_TP        custom_config=True
    ...    custom_config_folder=${TDD_DL_3CC_CA_peak_TP_cfg}
    Initiate UE Register And Traffic
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    3min    30s
    ...    Validate throughput from UE stats for all UEs    ue_list=${SA_UE_List}    expected_dl_tput=0
    ...    expected_ul_tput=0    scell=${SA_Scell_Index}
    Sleep    30s
    Run Keyword And Continue On Failure    Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}    pdu=${pdu_id}
    ...    pass_regexp_for_pdu_release=Successfully released PDU Session
    [Teardown]    Simple Test Teardown    ${SA_UE_List}
