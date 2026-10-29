*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ../5GC001167/resources/keywords.robot
Resource   ../5GC002640/resources/keywords_mtk.robot
Resource        ../regression/regression_keywords.robot
Resource   ./resources/keywords_8533.robot
Library    ../5GC001167/resources/keywords_1167.py    WITH NAME    python_1167
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py
Library    ../5GC002640/resources/scell_management.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/utilities.py

*** Variables ***
@{counters_8533}    M55118C06501    M55118C06502    M55118C00032

*** Keywords ***
CB008533-A_B9_Interworking_with_DRX_when_UE_has_VoNR_call_running_SCell_Change_from_4CC_CA_with_Measurement_based_SCell_Addition_to_3CC_CA
    Set Preferred Cell     100
    Activate 4CC
    Set Initial Attenuation For A1 measurement
    Attach UE To Pcell And Scell    ${CA_UE}    num_of_scells=0    vonr=${TRUE}
    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=scell_addition.pcap
    Trigger Scell Addition Based On A1
    Check Cell And Signal Strength For Ue    ${CA_UE}
    Stop Listening Tcpdump From Smod

    Scells Added    ${pcap_file}    num_of_scells=3    scells_id=101,103,104

    Start DL Traffic For Ue    ${CA_UE}    2000Mbits/sec    duration=240s
    Start UL Traffic For Ue    ${CA_UE}    75Mbits/sec     duration=240s

    Start Voice Call    vc_alias=call1    ue_alias=${CA_UE}    to=0105    duration=200s

    ${scell_rel_101}=   Start Listening Tcpdump From Smod   filepath=release_101.pcap
    Trigger Scell Release    cell_id=101
    Stop Listening Tcpdump From Smod
    Run Keyword And Continue On Failure    Scell Released    ${scell_rel_101}    1
    Start L1L2 Collection   l1l2_3cc.pcap    1   cell_ids=100,101,103,104
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_3cc}=    Stop L1L2 Collection
    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_3cc}    num_of_scells=2
    ...    possible_scells=101,103,104

    ${scell_rel_103_104}=   Start Listening Tcpdump From Smod   filepath=release_103_104.pcap
    Trigger Scell Release    cell_id=103
    Trigger Scell Release    cell_id=104
    BuiltIn.Sleep    20s    Waiting for release
    Stop Listening Tcpdump From Smod


    Run Keyword And Continue On Failure    Scell Released    ${scell_rel_103_104}    2
    Run Keyword And Continue On Failure    Scell Released    ${scell_rel_103_104}    3

    Start L1L2 Collection   no_scells.pcap    1   cell_ids=100,101,103,104
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_no_scells}=    Stop L1L2 Collection
#    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_no_scells}    num_of_scells=0
#    ...    possible_scells=101,103,104
    [Teardown]    Run Keywords
    ...    Detach Ue    ${CA_UE}    AND
    ...    Stop Pcap Collection    AND
    ...    Deactivate 4CC  AND
    ...    Set Initial Attenuation For A1 measurement

CB008533-A#_B11-2_Single_UE_Call_SCell_Release_based_on_A2-SCell_measurement_from_4CC_2F+2T_CA_to_3CC_2F+T_CA
    Set Preferred Cell     100
    Activate 4CC
    Set Initial Attenuation For A1 measurement
    counters.Wait For Pm Counters Interval
    Attach UE To Pcell And Scell    ${CA_UE}    num_of_scells=0
    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=scell_addition_b11.pcap
    Trigger Scell Addition Based On A1
    Stop Listening Tcpdump From Smod
    Scells Added    ${pcap_file}    num_of_scells=3    scells_id=101,103,104

    Start DL Traffic For Ue    ${CA_UE}    2500Mbits/sec    duration=600s
    Start UL Traffic For Ue    ${CA_UE}    75Mbits/sec     duration=600s

    Start L1L2 Collection   l1l2_4cc.pcap    1   cell_ids=100,101,103,104
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_3scells}=    Stop L1L2 Collection

    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=scell_release_104.pcap
    Trigger Scell Release    cell_id=104
    BuiltIn.Sleep    5
    Stop Listening Tcpdump From Smod

    Start L1L2 Collection   l1l2_3cc.pcap    1   cell_ids=100,101,103,104
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_2scells}=    Stop L1L2 Collection
    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_3scells}    num_of_scells=3
    ...    possible_scells=101,103,104
    Run Keyword And Continue On Failure    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_2scells}    num_of_scells=2
    ...    possible_scells=101,103,104

    &{counters_values}=     Get Scell Add Counter Values    ${counters_8533}      wait_for_interval=${TRUE}
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C06501    cell_id=100    counter_dict=counters_values    operator===
    Run Keyword And Continue On Failure
    ...    Counter Incremented Successfully    M55118C06502    cell_id=100    counter_dict=counters_values    operator===
    ${is_release_24R3_or_higher}    utilities.is_release_higher    24R3
    Run Keyword If    ${is_release_24R3_or_higher}
    ...    Counter Incremented Successfully    M55118C00032    cell_id=100    counter_dict=counters_values    operator=>=
    ...    value=3

    [Teardown]    Run Keywords
    ...    Stop Data Transfer    DT_UE_1_default      AND
    ...    Stop Data Transfer    DT_UE_1_defaultul      AND
    ...    Detach Ue    ${CA_UE}    AND
    ...    Stop Pcap Collection    AND
    ...    Deactivate 4CC

CB008533-A_B12_Single_UE_mobility_Intra-DU_handover_support(PCell change)_4CC_CA_FDD_2F2T_FR1_configured_for_SA_call
    Set Preferred Cell     100
    Activate 4CC
    Activate A1 Pcell Switch    100    11
    Set Initial Attenuation For A1 measurement
    Set Attenuation  25  ${ATTENUATOR['NRCELL_101']['ports']}  confirm=${TRUE}
    Attach UE To Pcell And Scell    ${CA_UE}    num_of_scells=0
    ${pcap_file}=   Start Listening Tcpdump From Smod   filepath=scell_addition_b12.pcap
    Trigger Scell Addition Based On A1    pcell_id=100
    Stop Listening Tcpdump From Smod
    Scells Added    ${pcap_file}    num_of_scells=3    scells_id=101,103,104

    Start DL Traffic For Ue    ${CA_UE}    1000Mbits/sec    duration=600s
    Start UL Traffic For Ue    ${CA_UE}    75Mbits/sec     duration=600s
    Start L1L2 Collection   l1l2_4cc.pcap    1   cell_ids=100,101,103,104
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_3scells}=    Stop L1L2 Collection

    ${handover}=   Start Listening Tcpdump From Smod   filepath=HO.pcap
    Clear Attenuation On Cell    101
    Stop Listening Tcpdump From Smod

    Ue Handovered  ${handover}    target_cell=101

    Scells Added    ${handover}    num_of_scells=3    scells_id=100,103,104
    Start L1L2 Collection   l1l2_4cc_after_ho.pcap    1   cell_ids=100,101,103,104
    ...   mirroring_filter=SpecificL1L2Messages
    ...   specific_message_ids=${BIP_CA_MESSAGES_FILTER}
    ...   wait=${TRUE}
    ${l1l2_3scells_after_ho}=    Stop L1L2 Collection

    Run Keyword And Continue On Failure
    ...    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_3scells}    num_of_scells=3    possible_scells=101,103,104
    Run Keyword And Continue On Failure
    ...    Dl Data Is Scheduled On Exact Number Of Scells    ${l1l2_3scells_after_ho}    num_of_scells=3    possible_scells=100,103,104
    Run Keyword And Continue On Failure
    ...    Ul Data Is Scheduled On Pcell    pcap_file=${l1l2_3scells_after_ho}    pcell_id=101
    Verify DL Tput For Ue    ${CA_UE}
    [Teardown]    Run Keywords
    ...    Detach Ue    ${CA_UE}    AND
    ...    Stop Pcap Collection    AND
    ...    Deactivate A1 Pcell Switch    100    11    AND
    ...    Deactivate 4CC
