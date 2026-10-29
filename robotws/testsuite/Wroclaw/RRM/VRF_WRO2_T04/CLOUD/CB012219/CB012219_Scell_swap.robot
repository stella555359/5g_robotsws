*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  CB012219_MFBI_A6 test automation

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/keywords_CB010414.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py    WITH NAME    l1l2_ver
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/bip_collection.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.tcpdump_aic.tcpdump_f1_aic
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/pcap_verifiers_5934.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/counters_aic.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB012219/resources/keywords.robot
Library    ute_ue

*** Variables ***
${AHFII_CELL_1}    20
${AHFII_CELL_3}    22
${AQQQA_CELL_1}    30


*** Keywords ***
CB012219_Scell_swap
    Set Default Values On Attenuator for TDD Scell Swap
    counters.Wait For Pm Counters Interval    offset=10
    Attach UE Aic    UE_5
    Start DL Traffic For Ue    UE_5    dl_tput=200Mbits/sec    duration=100s    protocol=udp
    Start F1c And Ngc Tcpdump    filename=scell_swap.pcap
    Perform Scell Swap    src_cell_id=${AHFII_CELL_1}    dst_cell_id=${AHFII_CELL_3}    att_value=60dB
    Sleep    5
    ${scell_swap}=    Stop F1c And Ngc Tcpdump
    Scell Swap Performed    ${scell_swap}    scell_added_id=21    scell_added_index=2    scell_released_index=1
    Verify DL Tput For Ue    UE_5
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55138C00501    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55138C00502    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C10501    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C10501    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00097    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00098    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00099    ${AQQQA_CELL_1}    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55203C00001    ${AQQQA_CELL_1}    operator=>=
    ...    profile=CABMCCP-1
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55203C00002    ${AQQQA_CELL_1}    operator=>=
    ...    profile=CABMCCP-1
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55204C00001    ${AQQQA_CELL_1}    operator=>=
    ...    profile=CABMCCP-1
    Run Keyword And Continue On Failure    Vdu Counter Incremented Successfully For Cell    M55316C00033    ${AQQQA_CELL_1}    operator=>=
    [Teardown]    Run Keywords
    ...    Detach Ue   UE_5    AND
    ...    Set Default Values On Attenuator
