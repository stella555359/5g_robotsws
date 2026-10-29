*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This subfeature introduces Carrier Aggregation between FDD carrier as PCell and up to 2 SCells,
...               FR1 TDD or FDD carriers. DSS support.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

# Test Setup     Run keywords
# ...            Connect To Coam    AND
# ...            Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA_M80

# Test Teardown  Run keywords
# ...            Detach Ue  UE_2    AND
# ...            Disconnect coam

*** Variables ***
${resource_path_2640-F}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1][1.0] 5GC002640-F_26_#B1.3 [F+F+T] Single UE call 3CC CA interworking with DSSp3
    [Documentation]  This user scenario describes successful call setup with FDD – TDD FR1 DL CA and DSS enabled
    ...    in FDD PCell.
    Run Keyword and Ignore Error   Load scf for NR    ${resource_path_2640-F}    SCFs    scf_2640-F.xml
    Setup attenuators
    Perform inter-frequency handover from Scell to PCell+CA  #setting attenuation for the case, not to double keywords
    Set test variable  ${test_name}  5GC002640-F_26
    Start syslog collection
    Attach UE    UE_1
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=600Mbits/sec
    ...                    protocol=tcp
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=tcp
    Stop syslog collection
    Start New L1L2 Logs
    Sleep  3s
    Await Data Transfer Finish   DT_DL_SA
    Run Keyword and Ignore Error
    ...    Verify Average Throughput    DT_DL_SA    tput_min=110Mbits/sec    tput_collection_src=iperf
    Await Data Transfer Finish   DT_UL_SA
    Run Keyword and Ignore Error
    ...    Verify Average Throughput    DT_UL_SA    tput_min=40Mbits/sec     tput_collection_src=iperf
    Stop New L1L2 Logs And Download PCAP
    Verify registration to FDD PCell
    Log to Console    >Registration to FDD PCell successful.<
    Verify TDD SCell activation
    Log to Console    >Activation of TDD SCell successful.<
    Verify CQI Measurements  #kw verifies pucch format 3 (CSI reports) and subcellid for PCell
    Log to Console    >CSI reports flow with pucch format 3.<
    Verify slots on Pcell
    Log to Console    >The are no unwanted slots 0,5,9 in specific messages flowing over DSS Pcell as expected.<
    Verify DT DL Flows through all cells
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<
