*** Settings ***
Documentation
...  author: Marta Fraszczak
...  contact: marta.fraszczak@nokia.com
...  CMAS Part D and C

Resource   ./resources/keywords.robot
Library    ./resources/test_specific_keywords.py    WITH NAME   python_2645_CD
Resource    ../5GC000747/resources/keywords_747.robot
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils

*** Keywords ***
5GC002645_D_cancel_all_CMAS_broadcast_on_cells_listed_in_Broadcast-To-Be-Cancelled-List_IE_with_ignored_NotificationInformation_IE
    Activate CMAS
    Set Preferred Cell     ${UE_1_CELL}
    Set Initial Attenuation For Test
    All Preconditions To Test
    ${message_id}    ${alert_title}    Random Alarm Number And Name
    counters.Wait For Pm Counters Interval
    Tcpdump.Start Tcpdump On Smod
    Attach Ue To Selected Cell    UE_1
    Send Write-Replace And Cancel Script    cells=${UE_1_CELL}    alarm_id=${message_id}
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    NNGCB_PWS_CAN_RESP_SENT counter incremented successfully    expected_value=1
    NNGCB_PWS_CAN_REQ_RECD counter incremented successfully    expected_value=1    wait_for_interval=${FALSE}
    Check If All Cells And Parameters From CBC Are Visible    ${pcap_file}    alarm_id=${message_id}
    [Teardown]    Run Keywords    All Postconditions To Test    AND
    ...    Tcpdump.Teardown Tcpdump On Smod    AND
    ...    Deactivate CMAS    AND
    ...    Block Target Cell   cell=${UE_1_CELL}    AND
    ...    Unblock Target Cell    cell=${UE_1_CELL}

5GC002645_C_PWS_Restart_Ind_add_new_cell
    Activate CMAS
    Activate PWS Restart Indication
    Set Preferred Cell     ${UE_1_CELL}
    Set Initial Attenuation For Test
    All Preconditions To Test
    ${message_id}    ${alert_title}    Random Alarm Number And Name
    counters.Wait For Pm Counters Interval  offset=0
    Remove Cell    cell_id=${UE_1_CELL}    group=100
    Tcpdump.Start Tcpdump On Smod
    Send Write Replace Script   cells=${UE_1_CELL}    alarm_id=${message_id}
    Add Cell    cell_id=${UE_1_CELL}
    Attach Ue To Selected Cell    UE_1
    Send Write Replace Script    cells=${UE_1_CELL}    alarm_id=${message_id}
    ${pcap_file}=    Tcpdump.Stop Tcpdump and download logs from SMOD
    Run Keyword And Continue On Failure    NNGCB_PWS_REST_IND_SENT counter incremented successfully    expected_value=3
    Run Keyword And Continue On Failure    Check Messages In Pcap File    ${pcap_file}    ${message_id}
    Run Keyword And Continue On Failure    AdminUtils.Wait For All Cells On Air State
    Run Keyword And Continue On Failure    UE_1.Is_alert_visible_on_the_screen    ${alert_title}
    [Teardown]    Run Keywords    All Postconditions To Test    AND
    ...    Tcpdump.Teardown Tcpdump On Smod    AND
    ...    Restore Cell If Needed    ${UE_1_CELL}   AND
    ...    Deactivate PWS Restart Indication   AND
    ...    Deactivate CMAS    AND
    ...    Block Target Cell   cell=${UE_1_CELL}    AND
    ...    Unblock Target Cell    cell=${UE_1_CELL}


