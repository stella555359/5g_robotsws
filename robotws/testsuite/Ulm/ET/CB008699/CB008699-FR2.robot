*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008699-FR2 interworking CB008699 with CB008700
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../5GC000480/keywordbook-480.robot

Resource        CB008699-FR2-commissioning.robot
Resource        CB008699-wts.robot
Resource        CB008699-parameter-settings.robot
Resource        CB008699-keywords.robot
Resource        CB008699-keywords-egate.robot
Resource        CB008699-FR2-keywords-egate-verify.robot
Resource        CB008699-keywords-traffic.robot
Resource        CB008699-keywords-wireshark.robot

Resource        ../../resources/Common/commissioning.robot

Resource        ../resources/SQD60/keywords-tracing.robot


Suite Setup       Suite Setup CB008699-FR2
Suite Teardown    Suite Teardown CB008699

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB008699_Partial_admission_control_for_Xn_handover_with_full_RRC_configuration
    [Documentation]    This test case verifies Partial_admission_control_for_Xn_handover_with_full_RRC_configuration
    ...       :Autor: Sylvia Schneider
    [Tags]    t1   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699

    start wireshark trace
    activate SCF and bring tl onAir FR2
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    prepare counters and expected values FR2

    Run Keyword and Warn On Failure     prepare for dcap tracing
    Run Keyword and Warn On Failure     dcap tracing start
    start wireshark trace

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    set indexToRFSP
    register UE              ue_id=1
    start PDU session FR2    ue_id=1
    modify PDU session       ue_id=1     qosflows_to_add=2
    modify PDU session       ue_id=1     qosflows_to_add=3
    modify PDU session       ue_id=1     qosflows_to_add=4
    display measurements of UE   ue_id=1  log=_1
    trigger handover with A3 measurement to phycell_id 48

    register UE              ue_id=3
    start PDU session FR2    ue_id=3
    display measurements of UE   ue_id=3

    trigger handover with A3 measurement to phycell_id 50   check=HandoverPreparation is received. Handover canceled   log=1
    allow handoverset by setting actARPBasedAC to value handovers
    trigger handover with A3 measurement to phycell_id 50   check=Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed   log=2
    display measurements of UE   ue_id=1  log=_2

    UE Deregister            ue_id=1
    UE Deregister            ue_id=3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval


    Run Keyword and Warn On Failure     dcap tracing stop

    Run Keyword and Continue On Failure     verify counter CB008699 FR2
    Run Keyword and Continue On Failure     verify wireshark CB008699 FR2
    verify egate log FR2

    [Teardown]   Perform Postconditions of Test Scenario CB008699


