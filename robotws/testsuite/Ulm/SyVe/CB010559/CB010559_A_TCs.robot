*** Settings ***
Documentation
...    | [5G26R2]      | CB010559 RRC Connection Re-establishment under an Unprepared gNB (SA)  |
...    | Test case:    | CB010559_A                                                             |
...    | UEs:          | Using QUALCOMM SDXxy                                                   |
...    | Author:       | Frank                                                                  |
...    | Team:         | MI MN RAN RD VRF ULM                                                   |
...    | Contact:      | OU_MI_MN_RAN_RD_VRF_ULM_4_53245007_GMS                                  |
...    | Description:  | TCs for CB010559_A                                                     |
# ----------------------------------------------------------------------------------------------------------------------------------[150 characters]

Library                         taf.ue

Resource                        ../resources/attenuator.robot

Resource                        CB010559_keywords.robot
Resource                        CB010559_Verification.robot
Resource                        CB010559_Commissioning.robot


Suite Setup                     CB010559_keywords.Prepare TL For Testing
Suite Teardown                  CB010559_keywords.Save All Logs And Teardown TL

*** Variables ***
&{TRAFFIC}                      DL_THROUGHPUT=100 Mbits/sec
...                             UL_THROUGHPUT=20 Mbits/sec
...                             TPUT_DEVIATION=10%
...                             DURATION=6000s
...                             PROTOCOL=udp
${WITH_PM_COUNTER_CHECK}        ${true}
${WITH_TC_COMMISSIONING}        ${true}
${BLOCK_ENB}                    ${true}
${BLOCK_GNB_ADJACENT_CELLS}     ${false}
${INITIAL_SCF_FILE_ACTIVATION}  ${false}
${UE_ALIAS_1}                   UE_1
${GNB_ID_0}                     ${0}
${GNB_ID_1}                     ${1}
${ENB_ID_0}                     ${0}

*** Test Cases ***
CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO
    [Documentation]
    ...   | CB010559_A_RE_TC01_B1    |
    ...   | The purpose of test case is to verify the successful RRC RRE to an unprepared gNB  |
    [Tags]    QCD_MN_RAN
    ...   CB010559_A_RE_TC01_B1
    [Setup]    CB010559_keywords.Setup Test For CB010559

    Log To Console    ${\n}This is testcase
    Log To Console    CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO
    Set Test Variable     ${TC_NUMBER}   A_RE_TC01_B1

    #  1. get IDs of used testline and set parameters for running the testcase accordingly
    CB010559_keywords.Select Testline
    CB010559_keywords.Perform Preconditions Of Test Scenario
    ...   gnb_id_0=${GNB_ID_0}   gnb_id_1=${GNB_ID_1}   enb_id=${ENB_ID_0}
    ...   capabilities=${capabilities}

    #  2. Run the testcase senacrio with Tcp logging, fetch PM counters and start/stop traffic
    CB010559_keywords.RRE With TcpLog PMcount And Traffic

    #   3. Do verification of PM counters
    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Verify PM Counters
       CB010559_Verification.Verify PmCounter CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO
    END

    #   4. Do verification of RRC signaling, in detail RRE messages
    CB010559_Verification.Verify RrcRreMsg CB010559_A_RE_TC01_B1_Successful_RRE_unpreparedgNB_no_HO

    [Teardown]    Run Keywords
    ...   CB010559_keywords.Perform Postconditions Of Test Scenario
          ...   gnb_id_0=${GNB_ID_0}  gnb_id_1=${GNB_ID_1}  enb_id=${ENB_ID_0}
    ...   AND
    ...   syve_testline.CCRT Test Cases Teardown


CB010559_A_RE_TC06_EC5_ALT2_Fallback_RRC_Setup_XnAP_RetrieveUeContextFailure
    [Documentation]
    ...   | CB010559_A_RE_TC06_EC5_ALT2    |
    ...   | The purpose of test case is to verify the failure and fallback case of a RRC RRE to an unprepared gNB,  |
    ...   | because the parameter in the NRCELL-X/NRREL-Y objects of both gNBs:  |
    ...   | handoverAllowedSA is set to the value XnHoNotAllowed  |
    [Tags]    QCD_MN_RAN
    ...   CB010559_A_RE_TC06_EC5_ALT2
    [Setup]    CB010559_keywords.Setup Test For CB010559

    Log To Console    ${\n}This is testcase
    Log To Console    CB010559_A_RE_TC06_EC5_ALT2_Fallback_RRC_Setup_XnAP_RetrieveUeContextFailure using the SDX75.
    Set Test Variable     ${TC_NUMBER}   A_RE_TC06_EC5_ALT2

    #  1. get IDs of used testline and set parameters for running the testcase accordingly
    CB010559_keywords.Select Testline
    CB010559_keywords.Perform Preconditions Of Test Scenario
    ...   gnb_id_0=${GNB_ID_0}   gnb_id_1=${GNB_ID_1}   enb_id=${ENB_ID_0}
    ...   capabilities=${capabilities}

    #  2. Run the testcase senacrio with Tcp logging, fetch PM counters and start/stop traffic
    CB010559_keywords.RRE With TcpLog PMcount And Traffic

    #   3. Do verification of PM counters
    IF   $WITH_PM_COUNTER_CHECK
       Log To Console    ${\n}PMcounters: Verify PM Counters
       CB010559_Verification.Verify PmCounter CB010559_A_TC04_EC5_Fallback_RRC_Setup
    END

    #   4. Do verification of RRC signaling, in detail RRE messages
    CB010559_Verification.Verify RrcRreMsg CB010559_A_TC04_EC5_Fallback_RRC_Setup

    [Teardown]    Run Keywords
    ...   CB010559_keywords.Perform Postconditions Of Test Scenario
          ...   gnb_id_0=${GNB_ID_0}  gnb_id_1=${GNB_ID_1}  enb_id=${ENB_ID_0}
    ...   AND
    ...   syve_testline.CCRT Test Cases Teardown
