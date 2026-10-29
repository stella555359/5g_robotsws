*** Settings ***

Documentation
...   author: Karol Palac
...   contact: karol.palac@nokia.com
...   Description: Test case verifies throughput on UE NSA with One Additional DMRS, 64QAM, bw: 20MHz.
...                PdschSendReq and PuschReceiveReq are filtered in order to verify DMRS params as well.
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001347/resources/resources.robot
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001347/resources/pm_counters.py

*** Variables ***
${resource_path_1347-B}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001347/resources

*** Keywords ***
[1]5GC001347_A;5GC001347_B_002_02_A-B_Activation_mUE_Attach-Traffic_ul-dl-DmrsAdditionalPosition_PTRS-OFF_GRC
    Commission with scf file    ${resource_path_1347-B}/SCF_basic.xml  is_pdl_checking_needed=${True}
    Wait until keyword succeeds    20 min    1 min    Verify all cells are onair with admin
    Wait until keyword succeeds    10 min    1 min      X2-C is available
    Attach UE NSA For test
    Log to console    >L1L2 logs collection and NSA throughput has begun.<
    Start ULDL UDP NSA   60Mbits/sec   60MBits/sec  150s
    Start L1L2 Logs    100    100
    Stop L1L2 Logs And Download PCAP    30    NSA   ASIK    dir=${OUTPUT DIR}/tcpdumpL2L1_filtering_on-1347.pcap
    Detach Ue     UE_1
    Log to Console    >Logs have been collected. UE is detached.<
    Verify DMRS Additional Position
