*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces Carrier Aggregation between FDD carrier as PCell and up to 2 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

# Test Setup     Run keywords
# ...            Connect To Coam    AND
# ...            Set global variable bts id    AND
# ...            Get number of cells and set ID   AND
# ...            Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA_M80

# Test Teardown  Run keywords
# ...            Detach Ue  UE_2    AND
# ...            Disconnect coam

*** Variables ***
${resource_path_2640-AA}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
# [1]5GC002640-AA_01_#B1 Feature activation of 3CC DL CA
#    Set global variable bts id
#    @{empty_list}   Create List
#    Check if 5GC002640 is disabled
#    sleep  1s
#    Check if feature 5GC002640 is successfully activated


[1]5GC002640-AA_09_#B4.A3.2 UE call 3CC[F+T+T] CA blind addition, beamforming, no beam refinement, pCSI reporting
    [Documentation]  This sub feature is for F+T+T configuration with enabled beamforing, 15MHz PCell, 1x50MHz + 1x20MHz Scells.
    ...              Veryfing CA Scells addition, CSI-RS for Channel Acquistion, CQI measurements, PM counters, DT ULDL.
    Load scf for NR    ${resource_path_2640-AA}    SCFs    scf_2640.xml
#    coam.lock_cell    dist_name=/MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-101    connection=cOAM
#    Log to Console    >Cell FDD PCI 101 has been locked.<
#    Setup attenuators
    Perform inter-frequency handover from Scell to PCell+CA  #setting attenuation for the case, not to double keywords
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}    value=90
    Set test variable  ${test_name}  5GC002640-AA_09
    Start syslog collection
    Attach UE    UE_1
    Sleep  5s
    Start ULDL UDP NSA    600Mbits/sec   50MBits/sec  200s
    Start L1L2 Logs  100  100
    Stop syslog collection
    Run Keyword and Ignore Error   Verify ULDL UDP NSA     600Mbits/sec   50Mbits/sec
    Stop L1L2 Logs And Download PCAP    dir=${OUTPUT DIR}/PCAPs/tcpdump_L2L1_filtering_on-${test_name}.pcap
    Verify registration to FDD PCell
    Log to Console    >Registration to FDD PCell successful.<
    Verify TDD SCell activation
    Log to Console    >Activation of TDD SCell successful.<
    Verify CSI-RS for Channel Acquisition
    Log to Console    >CSI-RS Chanel Acquisition successful.<
    Verify CQI Measurements
    Log to Console    >CQI Measurements detected successfully.<
    Verify PM Counters 2640-AA
    Log to Console    >PM Counters gotten successfully.<
    Verify DT DL Flows through all cells
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<
