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
[1]CB008717-5G-T#B4a_Verification_of_NRDC_preferred_path_selection_-_TCP_over_MCG_F1-U
    [Documentation]    The user scenario tests tput path with high bitrate
    Set test variable  ${test_name}  CB008717-5G-TB-4
    Setup attenuators
    @{lines_gNB_WPT_AEHC}   Create List    1   2   3   4
    Set attenuation and check    lines=${lines_gNB_WPT_AEHC}  value=15
    Prepare and start DCAP       dcap_host=10.42.54.132  bts_mpalne=10.45.173.40   nrCells=NRCELL_R-108
    ue.Attach UE  UE_1
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=60s    throughput=200Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=60s    throughput=20Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    Sleep    10s
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_DL_SA
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_UL_SA
    ue.Detach UE  UE_1
    Sleep    10s
    ue.Attach UE  UE_1
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=60s    throughput=2000Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=60s    throughput=200Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    Sleep    30s
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_DL_SA
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_UL_SA
    Stop DCAP trace and download logs
    Verify EMIL file from DCAP NRDC

[1]CB008717-5G-T#B1a_Verification_of_ENDC_preferred_path_selection_-_TCP_over_F1-U
    [Documentation]    The user scenario tests tput path with high bitrate
    Set test variable  ${test_name}  CB008717-5G-TB-1
    Setup attenuators
    @{lines_gNB_WPT_AEHC}   Create List    1   2   3   4
    Set attenuation and check    lines=${lines_gNB_WPT_AEHC}  value=15
    Prepare and start DCAP       dcap_host=10.42.54.132  bts_mpalne=10.45.173.40   nrCells=NRCELL_R-108
    ue.Attach UE  UE_1
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=60s    throughput=2000Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=60s    throughput=200Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    Sleep    15s
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_DL_SA
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_UL_SA
    ue.Detach UE  UE_1
    Sleep    10s
    taf.ue.Attach UE  UE_1
    taf.ue.Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=60s    throughput=200Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    taf.ue.Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=60s    throughput=20Mbits/sec
    ...                    protocol=tcp    packet_size=1400
    Sleep    30s
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_DL_SA
    Run keyword and ignore error    taf.ue.Stop Data Transfer   DT_UL_SA
    Stop DCAP trace and download logs
    Verify EMIL file from DCAP ENDC
