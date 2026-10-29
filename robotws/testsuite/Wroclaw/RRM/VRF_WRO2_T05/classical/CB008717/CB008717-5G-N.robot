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
[1]CB008717-5G-N#B4-2_[T+T+F]_Deconfiguration_of_FR1_SCells_upon_NR-DC_Setup_-_Measurement_based_SCell_Addition
    [Documentation]    This test case is to verify that reception of Measurement Report for NR-DC A4 event from a UE
    ...                operating in FR1 CA will trigger a deconfiguration of FR1 SCells and NR-DC setup afterward.
    ...                It will also activate A1 measurement for SCell Addition as part of this complete SCell Release.
    ...                Also, the relevant CA specific measurements will be deactivated in the UE (SCell Change/Swap/Release).
    Set test variable  ${test_name}  CB008717-5G-NB4-2
    Setup attenuators
    @{lines_gNB_WPT_AEHC}   Create List    1   2   3   4
    Set attenuation and check    lines=${lines_gNB_WPT_AEHC}  value=15
    Prepare Orbis files
    Set positioner    azimuth=70    tilt=180
    Prepare and start DCAP       dcap_host=10.42.54.132  bts_mpalne=10.45.173.40   nrCells=NRCELL_R-108
    ue.Attach UE  UE_1
    Sleep             5s
    ${PCI_UE1}=       ue.Get Ue Info    UE_1   PCI
    Log to Console    UE1: ${PCI_UE1}
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=200s    throughput=2000Mbits/sec
    ...                    protocol=udp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=200s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Set positioner    azimuth=0    tilt=180
    Sleep    10s
    Stop new DCAP trace and download logs json
    taf.ue.Stop Data Transfer   DT_DL_SA
    taf.ue.Stop Data Transfer   DT_UL_SA
    Verify JSON file from DCAP
    [Teardown]    Set positioner  azimuth=60    tilt=180

[1]CB008717-5G-N#B6A1_[T+F]_Activation_of_FR1_SCell_Addition_A1_measurement_upon_NR-DC_Release_-_oneShot_Dl_Fr1
    [Documentation]    This test case is to verify that A1 measurement based FR1 SCell Addition procedure is triggered
    ...                upon NR-DC release. The test case will verify that the UE will receive the A1 measurement report
    ...                and the gNB will add 2 SCells. PCell: 108, SCells: 100, 118.
    Set test variable  ${test_name}  CB008717-5G-NB6-1
    Setup attenuators
    @{lines_gNB_WPT_AEHC}   Create List    1   2   3   4
    Set attenuation and check    lines=${lines_gNB_WPT_AEHC}  value=15
    Set positioner    azimuth=0    tilt=-180
    Prepare and start DCAP       dcap_host=10.42.54.132  bts_mpalne=10.45.173.40   nrCells=NRCELL_R-108
    ue.Attach UE  UE_1
    Sleep             7s
#    Set positioner    azimuth=120    tilt=-180
    ${PCI_UE1}=       ue.Get Ue Info    UE_1   PCI
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=200s    throughput=2000Mbits/sec
    ...                    protocol=udp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=200s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
#    coam.lock    dist_name=MRBTS-50894/NRBTS-50894/NRCELL-109    timeout=60    connection=cOAM    detailed_output=True
    Sleep    110s
    Stop new DCAP trace and download logs json
    taf.ue.Stop Data Transfer   DT_DL_SA
    taf.ue.Stop Data Transfer   DT_UL_SA
    Verify JSON file from DCAP  expected_messages=${messages_8717_NB6}
#    [Teardown]    coam.unlock    dist_name=MRBTS-50894/NRBTS-50894/NRCELL-109    timeout=60    connection=cOAM
