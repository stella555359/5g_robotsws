*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
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

*** Variables ***
${resource_path_2640-AC}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot
${tput_deviation}           10%

*** Keywords ***
[1][1.0] 5GC002640-AC_03_#B2 [F+F+T] A1 based Scell Addition, Intra-gNB inter-freq HO
    [Documentation]  This user scenario describes the gNB behavior, when for a UE, for which an intra- or inter-gNB
    ...    handover is being performed to a new FDD PCell, A1 threshold criteria for SCell Addition is checked based on
    ...    measurement results of the target FDD Pcell. If criteria is fulfilled, SCell Addition is performed
    ...    immediately upon HO completion similar to blind SCell Addition. This scenario describes the case when
    ...    2 SCells are added for a 3CC CA based on SCell weight and load factors. The band combination and SCell
    ...    selection procedures are same as in previous sub-feature 5GC002640-AB for blind addition.
    ...    If criteria is not fulfilled, UE is configured with A1 measurement on PCell to trigger SCell Addition.
    ...    PCell: FDD PCI 102, SCells: TDD PCI 104 and FDD PCI 107.
    Load scf for NR    ${resource_path_2640-AC}    SCFs    scf_2640.xml
    Set attenuation for 2640-AC_03
    Set test variable  ${test_name}  5GC002640-AC_03
    Attach UE    UE_1
    Sleep  5s
    Start ULDL UDP NSA    600Mbits/sec   50MBits/sec  200s
    Start New L1L2 Logs
    Start syslog collection
    Perform inter-frequency handover from Scell to PCell+CA
    @{lines_gNB_410_AHLOA_2640}   Create List    5
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2640}    value=90
    Sleep  10s
    Stop syslog collection
    Stop Data Transfer           DT_DL_NSA
    Stop Data Transfer           DT_UL_NSA
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_DL_NSA    tput_min=110Mbits/sec    omit=100
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_UL_NSA    tput_min=40Mbits/sec    omit=100
    Stop New L1L2 Logs And Download PCAP
    Verify registration to FDD PCell
    Log to Console    >Registration to FDD PCell successful.<
    Verify TDD SCell activation
    Log to Console    >Activation of TDD SCell successful.<
    Verify DT DL Flows through all cells
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<

[1]5GC002640-AC_06_#B3.1 [F+F+T] A2-SCell triggered SCell realese. Different thresholds
    [Documentation]  This user scenario describes the gNB behavior, when a UE in 3CC FR1 mixed mode carrier aggregation
    ...    with FDD PCell and two SCells moves towards the cell edge and as one of the SCell degrades UE sends
    ...    measurement report for A2 (associated with SCell) to trigger SCell release.
    Load scf for NR    ${resource_path_2640-AC}    SCFs    scf_2640.xml
    Setup attenuators
    Perform inter-frequency handover from Scell to PCell+CA  #setting attenuation for the case, not to double keywords
    @{lines_gNB_410_AHLOA_2640}   Create List    5
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_2640}    value=90
    Set test variable  ${test_name}  5GC002640-AC_06
    Start syslog collection
    Attach UE    UE_1
    Sleep  5s
    Start ULDL UDP NSA    600Mbits/sec   50MBits/sec  200s
    Stop syslog collection
    Start New L1L2 Logs
    Release SCell TDD for 2640-AC_06
    Sleep  5s
    Stop Data Transfer           DT_DL_NSA
    Stop Data Transfer           DT_UL_NSA
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_DL_NSA    tput_min=110Mbits/sec
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_UL_NSA    tput_min=40Mbits/sec
    Stop New L1L2 Logs And Download PCAP
    Verify registration to FDD PCell
    Log to Console    >Registration to FDD PCell successful.<
    Verify TDD SCell activation    #Verified before release
    Log to Console    >Activation of TDD SCell successful.<
    Verify DT DL Flows through all cells  cells=${subcells_release}
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<
