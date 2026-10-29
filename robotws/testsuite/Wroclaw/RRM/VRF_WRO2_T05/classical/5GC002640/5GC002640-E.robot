*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com
...  Description: This subfeature introduces Carrier Aggregation between FDD carrier as PCell and up to 2 SCells,
...               FR1 TDD or FDD carriers. CA mobility support.

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
${resource_path_2640-AC}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot
${tput_deviation}           10%

*** Keywords ***
[1]5GC002640-E_21_#B2.1 [F+F+T] UE call 3CC CA with intra-L2RT inter-core architecture, ABIL
    [Documentation]  This user scenario describes successful call setup with FDD
    ...   TDD FR1 DL CA up to 3 CC for the single UE with intra-L2RT inter-core architecture.
    ...   This is testing-only scenario for interworking with CB007736 feature.
    ...   PCell: FDD PCI 102, SCells: TDD PCI 104 and FDD PCI 107.
    Load scf for NR    ${resource_path_2640-AC}    SCFs    scf_2640-E.xml
    Set attenuation for 2640-E
    @{lines_gNB_410_AHLOA_2640}   Create List    5
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2640}    value=90
    Set test variable  ${test_name}  5GC002640-E
    Start syslog collection
    Attach UE    UE_1
    Sleep  5s
    Start ULDL UDP NSA    600Mbits/sec   100MBits/sec  300s
    Log to Console    Tput started
    Start New L1L2 Logs
    Log to Console   Veryfing tput
    Stop syslog collection
    Stop Data Transfer           DT_DL_NSA
    Stop Data Transfer           DT_UL_NSA
    Get Average Throughput                     DT_DL_NSA
    Get Average Throughput                     DT_UL_NSA
    Stop New L1L2 Logs And Download PCAP
    Verify registration to FDD PCell
    Log to Console    >Registration to FDD PCell successful.<
    Verify TDD SCell activation
    Log to Console    >Activation of TDD SCell successful.<
    Verify DT DL Flows through all cells
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<
