*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ../5GC001167/resources/keywords.robot
Resource   ./resources/keywords_mtk.robot
Resource        ../regression/regression_keywords.robot
Library    ../5GC001167/resources/pcap_verifiers.py
Library    ../5GC001167/resources/bufferbased.py
Library    ../5GC001167/resources/keywords_1167.py    WITH NAME   python_1167
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py
Library    ./resources/beamforming.py
Library    ./resources/scell_management.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py

*** Keywords ***
5GC002640-AB_TC13_B7_SCell_deactivation_3CC_DL_CA_BufferBased
    Set Preferred Cell     100
    Set Initial Attenuation For A1 measurement
    Enable FFT Configuration
    Activate Buffer Based Configuration    bufferBased    cell_ids=100,101,103

    counters.Wait For Pm Counters Interval    offset=0
    Attach UE To Pcell And Scell    ${CA_UE}    num_of_scells=0     vonr=${TRUE}
    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=scell_addition_ab13.pcap
    Trigger Scell Addition Based On A1
    Stop Listening Tcpdump From Smod
    Scells Added    ${pcap_file}    num_of_scells=2    scells_id=${FFT_SCELLS}

    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=smod_ab13.pcap
    Start DL Traffic For Ue    ${CA_UE}    50Mbits/sec    duration=600s    dt=start
    Start UL Traffic For Ue    ${CA_UE}    50Mbits/sec     duration=600s
    Start DL Traffic For Ue    ${CA_UE}    230Mbits/sec    duration=600s    dt=b
    Start Voice Call    vc_alias=call1    ue_alias=${CA_UE}    to=0105    duration=400s

    Start Multiple Throughputs For Ca Ue    num=5
    Start L1L2 Collection   l1l2_full.pcap    1   cell_ids=100,101,103
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_full}=    Stop L1L2 Collection

    Stop Multiple Throughputs For Ca Ue    num=5

    BuiltIn.Sleep    2    Stopping data transfer..
    Log To Console    One scell should be deactivated!
    Start L1L2 Collection   l1l2_1scell_L1L2.pcap    1   cell_ids=100,101,103
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_1scell}=    Stop L1L2 Collection

    Stop Single Data Transfer    id=b
    BuiltIn.Sleep    2    Stopping data transfer..

    Log To Console    Both scells should be deactivated!
    Start L1L2 Collection   l1l2_no_scells.pcap    1   cell_ids=100,101,103
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_no_scells}=    Stop L1L2 Collection
    &{counters_values}=     Get Scell Add Counter Values    ${counter_list}
    Await Voice Call Finish    vc_alias=call1
    BuiltIn.Sleep     10
    Stop Listening Tcpdump From Smod

    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_full}    num_of_scells=2
    ...    possible_scells=101,103
    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_1scell}    num_of_scells=1
    ...    possible_scells=101,103
    Run Keyword And Continue On Failure    Dl Data Is Not Scheduled On Scells    ${l1l2_no_scells}    scells=101,103
    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Pcell    pcap_file=${l1l2_no_scells}    pcell_id=100
    Run Keyword And Continue On Failure    Ul Data Is Scheduled On Pcell    pcap_file=${l1l2_no_scells}    pcell_id=100
    Run Keyword And Continue On Failure    Assert Vonr Call Started With Qos 1    ${pcap_file}    occurrence=1
    Counter Incremented Successfully    M55316C09001    cell_id=101    counter_dict=counters_values    operator=>=
    Counter Incremented Successfully    M55316C09001    cell_id=103    counter_dict=counters_values    operator=>=

    [Teardown]    Run Keywords    Stop Listening Tcpdump From Smod    AND
    ...    Deactivate Buffer Based Configuration    bufferBased    cell_ids=100,101,103    AND
    ...    Detach Ue    ${CA_UE}
