*** Settings ***
Documentation
...  Author:        Maciej Cupial, Adam Tokarski
...  Contact:       maciej.cupial@nokia.com, adam.tokarski@nokia.com
...  Feature owner: Karol Malutkiewicz, Witold Galka
...  Description:   Power Saving feature for 5G site
...                 Feature Corner:     https://feature-corner.nsn-net.net/materials/clbkj7uvc2084464wkzdj046wlm

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_8951.resource
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.PmUtils    WITH NAME    pu
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/multi_UE.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/cplane_collector.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot


*** Variables ***
@{UE}              UE_1


*** Keywords ***
[1]CB008951_A#B1_A#B2
    [Documentation]
    ...  LTE params: actLteNrDualConnectivity = true, actCoordinated4g5gPowersaving = cellDeactivation

    [Arguments]
    ...    ${pcap_file_path}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/cplane_collector/cplane_collector
    Perform Commissioning 8951 LTE
    ${global_cell_ids}    ${nr_cell_ids}    Get Cells Info
    Perform Commissioning 8951 5G    ${global_cell_ids}    actCoordinated4g5gPowerSaving=disabled
    Setup Cplane Tcpdump Collector
    Start Cplane Logs
    Activate 8951
    Wait Until Cells Status      ${global_cell_ids}[0]    power_saving_status=on
    Stop Cplane Logs
    Log To Console                  __Convert pcap to pdml
    Convert pcap to pdml    ${pcap_file_path}.pcap
    Verify If nRcellIdentifier Is Equal To Power Saving Nr Cell Id    ${pcap_file_path}.pdml    ${nr_cell_ids}[0]
    Verify If nrDeactivationIndication Is Deactivated    ${pcap_file_path}.pdml
    Set Suite Variable         ${A#B1_activation}   'TRUE'
    Deactivate 8951
    Wait Until Cells Status    ${global_cell_ids}    power_saving_status=off
    Set Suite Variable         ${A#B2_dectivation}  'TRUE'
