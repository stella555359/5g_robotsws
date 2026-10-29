*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  [1]TC3_CB011081_C_IWK4_FDD+TDD_FR1_DL_6CC_CA_and_F+F_UL_2CC_CA test automation

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/keywords_CB010414.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/pcap_verifiers.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py    WITH NAME    l1l2_ver
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/bip_collection.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.tcpdump_aic.tcpdump_f1_aic
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/pcap_verifiers_5934.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/counters_aic.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB012219/resources/keywords.robot
Library    ute_ue

*** Variables ***
${AHFII_CELL_1}    20
${AHFII_CELL_2}    21
${AQQQA_CELL_1}    30
${AEHC_CELL_1}    40
${AEHC_CELL_2}    41



*** Keywords ***
[1]TC3_CB011081_C_IWK4_FDD+TDD_FR1_DL_6CC_CA_and_F+F_UL_2CC_CA test automation
    Set Default Values On Attenuator for TDD
    counters.Wait For Pm Counters Interval    offset=10
    Show Text on Console    Attaching UE_4 to CELL 10    colour=${GREEN}  show_timestamp=no
    Attach UE Aic    UE_4    num_of_scells=0    vonr=${FALSE}
    Start F1c And Ngc Tcpdump    filename=6cc.pcap
    Start DL Traffic For Ue    UE_4    dl_tput=1000Mbits/sec    duration=100s    protocol=udp
    Start UL Traffic For Ue    UE_4    ul_tput=80Mbits/sec    duration=100s    protocol=udp
    Sleep    5
    ${6cc}=    Stop F1c And Ngc Tcpdump
    Scells Added    ${6cc}    num_of_scells=5    scells_id=${AHFII_CELL_1},${AHFII_CELL_2},${AQQQA_CELL_1},${AEHC_CELL_1},${AEHC_CELL_2}
    Verify DL Tput For Ue    UE_4
    Verify UL Tput For Ue    UE_4
    counters.Wait For Pm Counters Interval    offset=100
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00004    10    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55138C03504    10    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55118C00001    10    operator=>=
    Run Keyword And Continue On Failure    Vcu Counter Incremented Successfully For Cell    M55138C03507    10    operator=>=
    Run Keyword And Continue On Failure    Vdu Counter Incremented Successfully For Cell    M55316C06001    10    operator=>=
    Run Keyword And Continue On Failure    Vdu Counter Incremented Successfully For Cell    M55316C04001    10    operator=>=

    [Teardown]    Run Keywords
    ...    Detach Ue   UE_4    AND
    ...    Set Default Values On Attenuator
