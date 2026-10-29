*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.palac@nokia.com

Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources/keywords.py


*** Variables ***
${resource_path_9262}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009262/resources


*** Keywords ***
[1]CB009262-SR-F_5GC000501_Graceful_Cell_Shutdown_with_AVHA_RU
    [Documentation]    This test verifies gracefull cell shutdown on cell (AVHA PCI:400) with successfull handover
    ...                to neighbour cell (AVHA PCI:401).
#    Load scf for NR    ${resource_path_9262}    SCFs    scf_9262-F.xml
    Set test variable  ${test_name}  CB009262-F
    Setup attenuators
    @{lines_gNB_T215_AVHA}   Create List    9   10   11   12
    Set attenuation and check    lines=${lines_gNB_T215_AVHA}  value=12
    coam.perform parameter recommissioning    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-410
    ...    parameter=administrativeState  operation=update    value=Locked   timeout=120    connection=cOAM
    Log to Console    Cell 410 has been locked.
    Attach Ue     UE_2
    Sleep         5s
    ${PCI_UE1}=       ute_ue.Get Ue Info    UE_2   PCI
    Log to Console    UE attached PCI now: ${PCI_UE1}
    coam.perform parameter recommissioning    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-410
    ...    parameter=administrativeState  operation=update    value=Unlocked   timeout=120    connection=cOAM
    Log to Console     Cell 410 has been unlocked.
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=300s    throughput=2000Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=300s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    10s
    ${DL_tput}         Get Average Throughput       DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    ${UL_tput}=    Run keyword and ignore error         Get Average Throughput       DT_UL_SA
    Run keyword and ignore error    Log to Console     UL Throughput: ${UL_tput}
    Prepare and start new DCAP       dcap_host=10.44.180.37  bts_mplane=10.44.137.26   nrCells=NRCELL_R-400 NRCELL_R-410
    coam.perform parameter recommissioning    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-400  parameter=administrativeState
    ...    operation=update    value=Shutting Down   timeout=120    connection=cOAM
    Log to Console   Graceful cell shutdown started
    Sleep    10s
    coam.perform parameter recommissioning    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-410  parameter=actDrxRetransTimerSupport
    ...    operation=update    value=true   timeout=120    connection=cOAM
    Sleep    30s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Detach Ue     UE_2
    Check NRCELL shutdown
    coam.perform parameter recommissioning   dist_name=MRBTS-50714/NRBTS-50714/NRCELL-400
    ...    parameter=administrativeState  operation=update    value=Unlocked   timeout=120    connection=cOAM
    coam.perform parameter recommissioning    dist_name=MRBTS-50714/NRBTS-50714/NRCELL-410
    ...    parameter=cellBarred  operation=update    value=barred   timeout=120    connection=cOAM
    Sleep    10s
    Attach Ue     UE_2
    Sleep         5s
    ${PCI_UE1}=       ute_ue.Get Ue Info    UE_2   PCI
    Log to Console    UE attached PCI now: ${PCI_UE1}
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_2    direction=dl    duration=300s    throughput=2000Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_2    direction=ul    duration=300s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep    20s
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify PM Counter 9262-F
    Verify JSON file from DCAP  expected_messages=${messages_9262_F}
    [Teardown]    Run keyword and ignore error    coam.perform parameter recommissioning   dist_name=MRBTS-50714/NRBTS-50714/NRCELL-400
    ...    parameter=administrativeState  operation=update    value=Unlocked   timeout=120    connection=cOAM
