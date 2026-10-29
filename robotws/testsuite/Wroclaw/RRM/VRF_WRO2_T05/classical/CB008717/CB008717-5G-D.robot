*** Settings ***
Documentation
...  author:  Karol Palac
...  contact: karol.palac@nokia.com

Library     taf.ue
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
#Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.py


*** Keywords ***
[1]CB008717-5G-D#B2_UL_data_transfer_over_MCGSCG
    [Documentation]    The user scenario tests the uplink data transfer when UL data path is set to
    ...                ulOverLteNr_PrimaryPathOverNr. TDD PCI to attach: 108.
    Set test variable  ${test_name}  CB008717-5G-D
    Setup attenuators
    @{lines_gNB_WPT_AEHC}   Create List    1   2   3   4
    Set attenuation and check    lines=${lines_gNB_WPT_AEHC}  value=15
    Prepare and start DCAP       dcap_host=10.42.54.132  bts_mpalne=10.45.173.40   nrCells=NRCELL_R-108
    #Start syslog collection
    ue.Attach UE  UE_1
    Sleep             7s
    ${PCI_UE1}=       ue.Get Ue Info    UE_1   PCI
    Log to Console    UE1: ${PCI_UE1}
    Sleep             10s
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=2000Mbits/sec
    ...                    protocol=udp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    30s
    taf.ue.Stop Data Transfer   DT_DL_SA
    taf.ue.Stop Data Transfer   DT_UL_SA
    Stop DCAP trace and download logs
    #Stop syslog collection
    Verify EMIL file from DCAP
    Verify EMIL file from DCAP PSCell
#    Verify PM Counters 8717-D    # Commented off until trunk becomes 25R3

#[1][1.0] CB008717-5G-D#B1_Successful_PSCell addition_[fallbackGroup]
#    [Documentation]    The user scenario tests the uplink data transfer when UL data path is set to
#    ...                ulOverLteNr_PrimaryPathOverNr.
#    Set test variable  ${test_name}  CB008717-5G-D
#    Setup attenuators
#    @{lines_gNB_WPT_AEHC}   Create List    1   2   3   4
#    Set attenuation and check    lines=${lines_gNB_WPT_AEHC}  value=15
#    Prepare and start DCAP       dcap_host=10.45.176.183  bts_mpalne=10.45.173.40   nrCells=NRCELL_R-108
#    #Start syslog collection
#    ue.Attach UE  UE_1
#    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=2000Mbits/sec
#    ...                    protocol=udp    packet_size=1400
#    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=200Mbits/sec
#    ...                    protocol=udp    packet_size=1400
#    Sleep    30s
#    taf.ue.Await Data Transfer Finish   DT_DL_SA
#    Stop DCAP trace and download logs
    #Stop syslog collection
#    Verify EMIL file from DCAP PSCell
