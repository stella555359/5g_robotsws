*** Settings ***
Documentation
...   author: Tomasz Mozola
...   contact: tomasz.mozola@nokia.com

Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC001167/resources/keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB010414/resources/keywords_CB010414.robot
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py    WITH NAME    l1l2_ver
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/bip_collection.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.tcpdump_aic.tcpdump_f1_aic
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/counters_aic.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/aic_ue.robot
Library    ute_ue

*** Variables ***
${AHFII_CELL_1}    20
${AHFII_CELL_3}    22
${AHLOB_CELL_1}    10
${AHLOB_CELL_2}    11

*** Keywords ***
TC04_CB005935_AA_B4_Single_UE_call_buffer_based_SCell_activation_deactivation
    Set Default Values On Attenuator
    counters.Wait For Pm Counters Interval    offset=30
    Show Text on Console    Attaching UE_5 to CELL 20    colour=${GREEN}  show_timestamp=no
    ${attach_pcap}    Attach UE Aic    UE_5    num_of_scells=3
    ...    scells_id=${AHLOB_CELL_1},${AHLOB_CELL_2},${AHFII_CELL_3}
    Start DL Traffic For Ue    UE_5    300Mbits/sec    duration=100s
    Start UL Traffic For Ue    UE_5    88Mbits/sec     duration=100s
    @{pcaps}    Collect Bip Log Aic
    ${l1l2_4cc}    Bip File Selector    ${pcaps}    l2rt

    counters.Wait For Pm Counters Interval    offset=120
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10001    cell_id=${AHFII_CELL_1}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10002    cell_id=${AHFII_CELL_1}
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10005    cell_id=${AHFII_CELL_1}    operator=>
    Run Keyword And Continue On Failure
    ...    Vcu Counter Incremented Successfully For Cell    M55118C10006    cell_id=${AHLOB_CELL_1}    operator=>
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C14001    cell_id=${AHFII_CELL_1}    operator=>
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C14002    cell_id=${AHLOB_CELL_1}    operator=>
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C14003    cell_id=${AHFII_CELL_1}    operator=>
    Run Keyword And Continue On Failure
    ...    Vdu Counter Incremented Successfully For Cell    M55316C14004    cell_id=${AHLOB_CELL_1}    operator=>

    Run Keyword And Continue On Failure    Dl Data Scheduled On Pcell And Scells      ${l1l2_4cc}
    ...    scells=${AHLOB_CELL_1},${AHLOB_CELL_2},${AHFII_CELL_3}    pcell_id=${AHFII_CELL_1}
    Run Keyword And Continue On Failure    Ul Data Scheduled On Pcell And Scells      ${l1l2_4cc}
    ...    scells=${AHLOB_CELL_1}    pcell_id=${AHFII_CELL_1}
    Verify DL Tput For Ue    UE_5
    Verify UL Tput For Ue    UE_5
    [Teardown]    Run Keywords    Detach Ue   UE_5    AND
    ...    Set Default Values On Attenuator
