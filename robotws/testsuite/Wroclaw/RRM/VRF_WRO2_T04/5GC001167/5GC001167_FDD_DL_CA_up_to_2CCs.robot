*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Resource   ./resources/keywords.robot
Library    ./resources/keywords_1167.py    WITH NAME   python_1167
Library    ./resources/pcap_verifiers.py
Library    ./resources/delta_keywords.py
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils

*** Keywords ***
5GC001167-H_ SCell Addition 2CC and UE Configuration_M55139C01001_counter
    Set Preferred Cell     ${PCELL_106}
    Attach Ue and Collect Counters    scells_id=${SCELL_100}
    Scell Add Counter Incremented Successfully For    ${SCELL_100}    M55139C01001
    Scell Add Counter Incremented Successfully For    ${PCELL_106}    M55139C01004
    Scell Add Counter Incremented Successfully For    ${PCELL_106}    M55139C01003
    Scell Add Counter Incremented Successfully For    ${SCELL_100}    M55139C01002
    Scell Add Counter Incremented Successfully For    ${PCELL_106}    M55138C01502
    Scell Add Counter Incremented Successfully For    ${PCELL_106}    M55138C01501
    Scell Add Counter Incremented Successfully For    ${PCELL_106}    M55118C05506
    Scell Add Counter Incremented Successfully For    ${PCELL_106}    M55118C05505
    [Teardown]    Run Keywords    Detach Ue    ${CA_UE}    AND
    ...    Restore Second Scell If Needed

5GC001167-H_B4_CA_relation_update_within_NRREL_object_with_a_need_to_change_cell_mapping
    Set Preferred Cell     ${PCELL_106}
    Set Initial Attenuation For Test
    Remove Scell Addition Method    ${PCELL_106}    ${SCELL_101}
    Change Cell Mapping To 2x2    cell_id=${SCELL_100}
    AdminUtils.Wait For All Cells On Air State
    Attach UE To Pcell And Scell    ${CA_UE}
    Start DL Traffic For Ue    ${CA_UE}    600Mbits/sec    duration=60s
    L1L2.Start GnbMirroring    capturing_time_seconds=2    new_l1l2=${TRUE}
    BuiltIn.Sleep    2    Log Collecting
    ${l1l2}=    L1L2.stop_gnbmirroring_and_download_logs
    Verify DL Tput For Ue
    Dl Data Scheduled On Pcell And Scells    ${l1l2}    scells=${SCELL_100}    pcell_id=${PCELL_106}
    [Teardown]    Run Keywords
    ...    Detach Ue    ${CA_UE}    AND
    ...    Add Scell Addition Method    ${PCELL_106}    ${SCELL_101}    AND
    ...    Restore Cell Mapping To 4x4    cell_id=${SCELL_100}    AND
    ...    AdminUtils.Wait For All Cells On Air State
