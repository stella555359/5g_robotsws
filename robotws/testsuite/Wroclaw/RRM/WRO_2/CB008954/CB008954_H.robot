*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008954: Up to 3 BWPs for UE with different bandwidth
...         The feature increases the number of BWP used to manage UE with different bandwidth capabilities
...         to 3. Minimal bandwidth of small BWP is 20% of the carrier bandwidth or 10 MHz. BWP are aligned
...         at the bottom of the carrier. Multiple dedicated BWPs are supported on cells that have bandwidth
...         at least 15 MHz.
...
...      == TEST SET NAME ==
...         CB008954 Up to 3 BWPs for UE with different bandwidth
...
...      == TESTING SPLIT ==
...         CB008954-A Feature activation
...         CB008954-B SA FDD with 3 dedicated BWPs and PRB blanking
...         CB008954-C SA TDD with 3 dedicated BWPs and PRB blanking
...         CB008954-D NSA: FDD or TDD with 3 dedicated BWPs
...         CB008954-E Interaction with CA
...         CB008954-H Other interactions
...
...      == PRECONDTIONS AND DEPENDENCIES ==
...      - NRCELL-1 - TDD - simulated on AEQE radio module
...            NR_BAND: n78
...            SCS: 30kHz
...            large BWP3:    100MHz, BWP_PROFILE-77
...            second BWP2:   60MHz, BWP_PROFILE-74
...            small BWP1:    40MHz, BWP_PROFILE-72
...            initial BWP:   40Mhz, BWP_PROFILE-17
...            PS BWP:        20Mhz, BWP_PROFILE-71
...
...      - NRCELL-2 - TDD - simulated on AEHC radio module
...            NR_BAND: n41
...            SCS: 30kHz
...            large BWP3:    100MHz, BWP_PROFILE-77
...            second BWP2:   60MHz, BWP_PROFILE-74
...            small BWP1:    40MHz, BWP_PROFILE-72
...            initial BWP:   40Mhz, BWP_PROFILE-17
...            PS BWP:        50Mhz, BWP_PROFILE-70
...
...      - NRCELL-3 - FDD - simulated on AHFII radio module
...            NR_BAND: n25
...            SCS: 15kHz
...            large BWP3:    30MHz, BWP_PROFILE-35
...            second BWP2:   20MHz, BWP_PROFILE-37
...            small BWP1:    10MHz, BWP_PROFILE-33
...            initial BWP:   10Mhz, BWP_PROFILE-31
...
...      - NRCELL-4 - FDD - simulated on AHFII radio module
...            NR_BAND: n66
...            SCS: 15kHz
...            Asymmetric cell
...            large BWP3:    30MHz/10Mhz, BWP_PROFILE-36
...            second BWP2:   20MHz/10Mhz, BWP_PROFILE-38
...            small BWP1:    10MHz/10Mhz, BWP_PROFILE-34
...            initial BWP:   10Mhz/10Mhz, BWP_PROFILE-31
...
...      == CONTACTS ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...       - Damian Rzeczkowski <damian.rzeczkowski@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008954 CFAM
...
...      == HISTORY ==
...         [11.09.2023] - TC Create
...         [20.11.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=894392)

Resource    ./resources/CB008954_common_keywords.robot
Resource    ./resources/ute_report.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

Suite Setup     Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_TDD_2c_n78_n41_FDD_2c_n25_n66.lua
${SCFC}=                  scfc_TDD_2c_n78_n41_FDD_2c_n25_n66_interactions.xml
${AP_XML}=                ${CURDIR}/config/iphy_AEQE_AEHC_2_AHFII.xml
${SKIP_COUNTERS}=         ${FALSE}

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=40    SECOND_BW=60    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=40    SECOND_BW=60    LARGE_BW=100
&{NRCELL_3_BWP}=    ID=3    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
&{NRCELL_4_BWP}=    ID=4    SMALL_BW_DL=10    SMALL_BW_UL=10    SECOND_BW_DL=20    SECOND_BW_UL=10    LARGE_BW_DL=30    LARGE_BW_UL=10
...                 ASYMMETRIC=${TRUE}
@{NRCELL_BWP}=      &{NRCELL_1_BWP}    &{NRCELL_2_BWP}    &{NRCELL_3_BWP}    &{NRCELL_4_BWP}

*** Test Cases ***
CB008954-H-IWK101 Power Saving BWP not configured along small BWP
    [Tags]    H-IWK101    NoResUsage
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Purpose of this test is to verify, that when selected dedicated BWP is smaller than or equal to Power Saving BWP, then
    ...    Power Saving BWP should not be configured for UE. If selected dedicated BWP is strictly higher than Power Saving BWP, then
    ...    Power Saving BWP is configured for UE.
    ...    Note: Power Saving BWP can be strictly larger than small BWP only.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-1.actPowerSavingBWP = True
    ...  - NRCELL-2.actPowerSavingBWP = True
    ...
    ...  - BWP configuration for each NRCELL is described in suite PRECONDTIONS AND DEPENDENCIES
    ...
    ...   SA UE1 support small BWP1 on NRCELL-1
    ...   SA UE2 support second BWP2 on NRCELL-1
    ...   SA UE3 support large BWP3 on NRCELL-1
    ...   SA UE4 support small BWP1 on NRCELL-2
    ...   SA UE5 support second BWP2 on NRCELL-2
    ...   SA UE6 support large BWP3 on NRCELL-2
    ...   All UEs are BWP DCI-switch capable
    ...
    ...  == Postconditions ==
    ...   - UEs 1-3 are active in NRCELL-1
    ...   - UEs 4-6 are active in NRCELL-2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules (AEQE,AEHC, AHFII, AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    5G_RAN_USR_RRM_21408;CB_FIM_39911
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    CFAM
    ...    User scenario CB008954-H#IWK.1 Power Saving BWP not configured along small BWP
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - https://collab.ext.net.nokia.com/ui#review:id=895049

    [Setup]    Prepare test environment H-IWK101

    start_collecting_syslog  prefix=H-IWK101

    Attach UE1 to gNB2 NRCELL-1 small dedicated BWP profile and verify that PS-BWP is configured
    Attach UE2 to gNB2 NRCELL-1 second dedicated BWP profile and verify that PS-BWP is configured
    Attach UE3 to gNB2 NRCELL-1 large dedicated BWP profile and verify that PS-BWP is configured

    Attach UE4 to gNB2 NRCELL-2 small dedicated BWP profile and verify that PS-BWP is NOT configured
    Attach UE5 to gNB2 NRCELL-2 second dedicated BWP profile and verify that PS-BWP is configured
    Attach UE6 to gNB2 NRCELL-2 large dedicated BWP profile and verify that PS-BWP is configured

    Verify, that UE1 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE2 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE3 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped

    Verify, that UE4 is NOT switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE5 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE6 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped

    CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 6
    Modify PS-BWP on NRCELL-1 to 40Mhz (size of small BWP1), on NRCELL-2 to 60Mhz (size of second BWP2)

    Attach UE1 to gNB2 NRCELL-1 small dedicated BWP profile and verify that PS-BWP is NOT configured
    Attach UE2 to gNB2 NRCELL-1 second dedicated BWP profile and verify that PS-BWP is configured
    Attach UE3 to gNB2 NRCELL-1 large dedicated BWP profile and verify that PS-BWP is configured

    Attach UE4 to gNB2 NRCELL-2 small dedicated BWP profile and verify that PS-BWP is NOT configured
    Attach UE5 to gNB2 NRCELL-2 second dedicated BWP profile and verify that PS-BWP is NOT configured
    Attach UE6 to gNB2 NRCELL-2 large dedicated BWP profile and verify that PS-BWP is configured

    Verify, that UE1 is NOT switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE2 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE3 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE4 is NOT switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE5 is NOT switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped
    Verify, that UE6 is switched: to dedicated BWP when traffic is started, to PS BWP when traffic is stopped

    [Teardown]    Run Keywords    Cleanup after test H-IWK101
    ...    AND                    Add Scout Data Info To Testcase

CB008954-H-IWK102_1 GBR admission control without preemption for large dedicated BWP
    [Tags]    H-IWK102_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Test verifies admission control on 3 BWP profiles. When DL resources for GBR traffic for UEs on large BWP
    ...    are exceeding maxGbrTrafficLimit, then it is not possible to attach more UEs on any BWP profile with GBR 5QI.
    ...    UEs with only nonGBR bearer can be still attached to each BWP.
    ...    Any feature related to resources preemption is not activated.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRBTS.actDrbPreemption = false
    ...  - NRBTS.actUserPreemption  = false
    ...  - NRCELL-1.actNonVoNRGbrService = true (CB008379 feature flag)
    ...  - NRCELL-1.actGBRAdmissionControl = GBRService
    ...  - NRCELL-1.maxGBRTrafficLimit = 15%
    ...
    ...  - BWP configuration for each NRCELL is described in suite PRECONDTIONS AND DEPENDENCIES
    ...
    ...   SA UEs 1-20, 41-50 support large BWP3 on NRCELL-1
    ...   SA UEs 21-30, 51-60 support second BWP2 on NRCELL-1
    ...   SA UEs 31-40, 61-70 support small BWP1 on NRCELL-1
    ...
    ...  == Postconditions ==
    ...   - All UEs are attached with DL & UL traffic ongoing
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules (AEQE,AEHC, AHFII, AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    5G_RAN_USR_RRM_21409; CB_FIM_39912; 5G_PM_1316
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    CFAM
    ...    USCB008954-H-PMO#1: This scenario aims to measure the GBR admission attempts and success counters related to
    ...                        the dedicated bandwidth part counters for SA
    ...    User scenario CB008954-H#IWK.2 GBR admision control for large dedicated BWP
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - https://collab.ext.net.nokia.com/ui#review:id=895049

    [Setup]    Prepare test environment H-IWK102

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=H-IWK102_1

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=1    ue_last=20    cell_id=1    bwp=large    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    Try to attach UE21 to NRCELL-1 second BWP with 5QI-2 bearer and verify that it is rejected due to admission control
    Try to attach UE31 to NRCELL-1 small BWP with 5QI-2 bearer and verify that it is rejected due to admission control

    # Verification, that UEs with nonGBR traffic can be still attached to small, second, and large BWP
    Attach UE41 to NRCELL-1
    Verify that UE41 is configured with large BWP profile after ICS to NRCELL-1
    Attach UE51 to NRCELL-1
    Verify that UE51 is configured with second BWP profile after ICS to NRCELL-1
    Attach UE61 to NRCELL-1
    Verify that UE61 is configured with small BWP profile after ICS to NRCELL-1
    CB008954_common_keywords.Run 15Mbps DL traffic on UE41 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 15Mbps DL traffic on UE51 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 15Mbps DL traffic on UE61 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE41 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE51 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE61 PDU1 QFI1
    ${last_ue_bwp3}=    Evaluate    0+${succ_ue_bwp3}
    Verify 15Mbps DL traffic on UEs[1-${last_ue_bwp3}] PDU1 QFI2

    ${max_ues_only_large_bwp}    set variable    ${succ_ue_bwp3}

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters SA_DU_ADM_ATT_GBR_BWP[1,2,3] are equal [1,1,${req_ue_bwp3}] in NRCELL-1 in gNB2
    ...  Verify that counters SA_DU_ADM_SUCC_GBR_BWP[1,2,3] are equal [0,0,${succ_ue_bwp3}] in NRCELL-1 in gNB2
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Execute egate command    cmd=trf_data_stop ue=1-31 dir=bi pdu=1 qfi=2
    CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 31
    sleep    10s    To be sure that all cell resources are free

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=31    ue_last=40    cell_id=1    bwp=small    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=21    ue_last=30    cell_id=1    bwp=second    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=1    ue_last=20    cell_id=1    bwp=large    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    ${last_ue_bwp1}=    Evaluate    30+${succ_ue_bwp1}
    ${last_ue_bwp2}=    Evaluate    20+${succ_ue_bwp2}
    ${last_ue_bwp3}=    Evaluate    0+${succ_ue_bwp3}
    Verify 15Mbps DL traffic on UEs[31-${last_ue_bwp1}] PDU1 QFI2
    Verify 15Mbps DL traffic on UEs[21-${last_ue_bwp2}] PDU1 QFI2
    Verify 15Mbps DL traffic on UEs[1-${last_ue_bwp3}] PDU1 QFI2
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE41 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE51 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE61 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters SA_DU_ADM_ATT_GBR_BWP[1,2,3] are equal [${req_ue_bwp1},${req_ue_bwp2},${req_ue_bwp3}] in NRCELL-1 in gNB2
    ...  Verify that counters SA_DU_ADM_SUCC_GBR_BWP[1,2,3] are equal [${succ_ue_bwp1},${succ_ue_bwp2},${succ_ue_bwp3}] in NRCELL-1 in gNB2

    ${max_ues_in_all_bwp}=   Evaluate    ${succ_ue_bwp1} + ${succ_ue_bwp2} + ${succ_ue_bwp3}
    Run keyword and ignore error
    ...    Should Be Equal    ${max_ues_only_large_bwp}    ${max_ues_in_all_bwp}

    [Teardown]    Run Keywords    Cleanup after test H-IWK102
    ...    AND                    Add Scout Data Info To Testcase


CB008954-H-IWK102_2 GBR admission control without preemption for small or second dedicated BWP
    [Tags]    H-IWK102_2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Test verifies admission control on 3 BWP profiles.
    ...    When DL resources for GBR traffic for UEs on second BWP are exceeding maxGbrTrafficLimit, then it is not possible
    ...    to attach more UEs on small BWP profile with GBR 5QI. It is still possible to attach UEs to large BWP.
    ...    When DL resources for GBR traffic for UEs on second BWP are exceeding maxGbrTrafficLimit,
    ...    then it is still possible to attach UEs on second dedicated or large BWP.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRBTS.actDrbPreemption = false
    ...  - NRBTS.actUserPreemption  = false
    ...  - NRCELL-1.actNonVoNRGbrService = true (CB008379 feature flag)
    ...  - NRCELL-1.actGBRAdmissionControl = GBRService
    ...  - NRCELL-1.maxGBRTrafficLimit = 15%
    ...
    ...  - BWP configuration for each NRCELL is described in suite PRECONDTIONS AND DEPENDENCIES
    ...
    ...   SA UEs 1-20, 41-50 support large BWP3 on NRCELL-1
    ...   SA UEs 21-30, 51-60 support second BWP2 on NRCELL-1
    ...   SA UEs 31-40, 61-70 support small BWP1 on NRCELL-1
    ...
    ...  == Postconditions ==
    ...   - All UEs are attached with DL & UL traffic ongoing
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules (AEQE,AEHC, AHFII, AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    5G_RAN_USR_RRM_21410; 5G_RAN_USR_RRM_21411;CB_FIM_39912; 5G_PM_1316
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    CFAM
    ...    USCB008954-H-PMO#1: This scenario aims to measure the GBR admission attempts and success counters related to
    ...                        the dedicated bandwidth part counters for SA
    ...    User scenario CB008954-H#IWK.3 GBR admision control for second dedicated BWP
    ...    User scenario CB008954-H#IWK.4 GBR admision control for small dedicated BWP
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - https://collab.ext.net.nokia.com/ui#review:id=895049

    [Setup]    Prepare test environment H-IWK102

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=H-IWK102_2

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=21    ue_last=30    cell_id=1    bwp=second    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    Try to attach UE31 to NRCELL-1 small BWP with 5QI-2 bearer and verify that it is rejected due to admission control

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=1    ue_last=20    cell_id=1    bwp=large    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    # Verification, that UEs with nonGBR traffic can be still attached to small, second, and large BWP
    Attach UE41 to NRCELL-1
    Verify that UE41 is configured with large BWP profile after ICS to NRCELL-1
    Attach UE51 to NRCELL-1
    Verify that UE51 is configured with second BWP profile after ICS to NRCELL-1
    Attach UE61 to NRCELL-1
    Verify that UE61 is configured with small BWP profile after ICS to NRCELL-1
    CB008954_common_keywords.Run 15Mbps DL traffic on UE41 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 15Mbps DL traffic on UE51 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 15Mbps DL traffic on UE61 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE41 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE51 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE61 PDU1 QFI1
    ${last_ue_bwp3}=    Evaluate    0+${succ_ue_bwp3}
    Verify 15Mbps DL traffic on UEs[1-${last_ue_bwp3}] PDU1 QFI2

    ${max_ues_in_second_large_bwp}    Evaluate    ${succ_ue_bwp2} + ${succ_ue_bwp3}

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters SA_DU_ADM_ATT_GBR_BWP[1,2,3] are equal [1,${req_ue_bwp2},${req_ue_bwp3}] in NRCELL-1 in gNB2
    ...  Verify that counters SA_DU_ADM_SUCC_GBR_BWP[1,2,3] are equal [0,${succ_ue_bwp2},${succ_ue_bwp3}] in NRCELL-1 in gNB2
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Execute egate command    cmd=trf_data_stop ue=1-31 dir=bi pdu=1 qfi=2
    CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 31
    BuiltIn.Sleep    10s    To be sure that all cell resources are free

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=31    ue_last=40    cell_id=1    bwp=small    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=21    ue_last=30    cell_id=1    bwp=second    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=1    ue_last=20    cell_id=1    bwp=large    5qi_id=2    traffic_dir=DL    gfbr_dl_rate=20    traffic_rate=15

    ${last_ue_bwp1}=    Evaluate    30+${succ_ue_bwp1}
    ${last_ue_bwp2}=    Evaluate    20+${succ_ue_bwp2}
    ${last_ue_bwp3}=    Evaluate    0+${succ_ue_bwp3}
    Verify 15Mbps DL traffic on UEs[31-${last_ue_bwp1}] PDU1 QFI2
    Verify 15Mbps DL traffic on UEs[21-${last_ue_bwp2}] PDU1 QFI2
    Verify 15Mbps DL traffic on UEs[1-${last_ue_bwp3}] PDU1 QFI2
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE41 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE51 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 15Mbps DL traffic on UE61 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters SA_DU_ADM_ATT_GBR_BWP[1,2,3] are equal [${req_ue_bwp1},${req_ue_bwp2},${req_ue_bwp3}] in NRCELL-1 in gNB2
    ...  Verify that counters SA_DU_ADM_SUCC_GBR_BWP[1,2,3] are equal [${succ_ue_bwp1},${succ_ue_bwp2},${succ_ue_bwp3}] in NRCELL-1 in gNB2

    ${max_ues_in_all_bwp}=   Evaluate    ${succ_ue_bwp1} + ${succ_ue_bwp2} + ${succ_ue_bwp3}
    Run keyword and ignore error
    ...    Should Be Equal    ${max_ues_in_second_large_bwp}    ${max_ues_in_all_bwp}

    [Teardown]    Run Keywords    Cleanup after test H-IWK102
    ...    AND                    Add Scout Data Info To Testcase


CB008954-H-IWK103 GBR admission control with preemption
    [Tags]    H-IWK103    NoResUsage
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify admission control with 3 BWP profiles with active preemption.
    ...  New GBR DRBs with lower ARP (higher priority) used for UL traffic preempts GBR DRBs with higher
    ...  ARP (lower priority). If released resources are not sufficient, non-GBR UL CG Type 2 traffic is
    ...  reduced.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL configuration is described at the top of this test suite
    ...  - AMF1 simulated
    ...
    ...    - UEs 1-20 supports BWP1,BWP2,BWP3 profile from NRCELL-2:
    ...        Ues are capable to setup UL Grant Type 2
    ...        channelBWs-DL = mhz40,60,100 on fr1 scs-30kHz entry for B41
    ...	       channelBWs-UL = mhz40,60,100 on fr1 scs-30kHz entry for B41
    ...    - UEs 21-30 supports BWP1,BWP2 profile from NRCELL-2:
    ...        Ues are not capable to setup UL Grant Type 2
    ...        channelBWs-DL = mhz40,60 on fr1 scs-15kHz entry for B41
    ...	       channelBWs-UL = mhz40,60 on fr1 scs-15kHz entry for B41
    ...    - UEs 31-40 supports BWP1,BWP2 profile from NRCELL-2:
    ...        Ues are not capable to setup UL Grant Type 2
    ...        channelBWs-DL = mhz40,60 on fr1 scs-15kHz entry for B41
    ...	       channelBWs-UL = mhz40,60 on fr1 scs-15kHz entry for B41
    ...    - UEs 41-50 supports BWP1 profile from NRCELL-2:
    ...        Ues are not capable to setup UL Grant Type 2
    ...        channelBWs-DL = mhz40 on fr1 scs-15kHz entry for B41
    ...	       channelBWs-UL = mhz40 on fr1 scs-15kHz entry for B41
    ...    - For all UEs with are configured with below 5QIs:
    ...      - 5QI2 can not trigger preemption and is preemptable
    ...      - 5QI3 can trigger preemption and is preemptable, it has higher ARP priority than 5QI2
    ...
    ...    - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...    - NRBTS/actDrbPreemption = true (CB008698 feature flag)
    ...    - NRCELL-2/actNonVoNRGbrService = true (CB008379 feature flag)
    ...    - NRCELL-2/actUlCgType2 = true
    ...    - NRCELL-2/actGBRAdmissionControl = GBRService
    ...    - NRCELL-2/maxGBRTrafficLimit = 40%
    ...    - NRCELL-2/ulConfiguredGrantType2/maxGBRAndCgType2 = 90%
    ...    - For 5QI2/3:
    ...      - NRDRB.maxDataRateGbrDl = 30Mbps
    ...      - NRDRB.maxDataRateGbrUl = 30Mbps
    ...    - GBR-QosInformation GFBR DL for 5QI2/3 in 5GC is set below NRDRB.maxDataRateGbrDl
    ...    - GBR-QosInformation GFBR UL for 5QI2/3 in 5GC is set below NRDRB.maxDataRateGbrUl
    ...    - NRCELL/actPRBBlanking = false (in all cells)
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE, AEHC,2xAHFII radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: CB_FIM_39912
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-H-IWK.2 GBR admision control for large dedicated BWP
    ...     -  CB008954-H-IWK.3 GBR admision control for second dedicated BWP
    ...     -  CB008954-H-IWK.4 GBR admision control for small dedicated BWP
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=894392)

    [Setup]    Prepare test environment H-IWK103

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_collecting_syslog  prefix=H-IWK103

    Attach UEs with non-GBR ULCG2 traffic until first UE is not configured with uplink configured grant
    ...    ue_first=1    ue_last=20    cell_id=2    bwp=large    traffic_rate=30

    Configure  [{'MOC': 'NRCELL', 'ID': '2', 'ulConfiguredGrantType2': [{'maxGBRAndCgType2TrafficLimit': '90'}]}]

    Verify UL traffic on UEs with uplink configured grant

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...                 Check RTPM counter: NRCELL-2 UL_CG_ACT_ATT (M55308C00020) is equal ${succ_ulcg2_ue_bwp3}
    ...                 Check RTPM counter: NRCELL-2 UL_CG_ACT_ATT_SUCC (M55308C00021) is equal ${succ_ulcg2_ue_bwp3}
    ...                 Check RTPM counter: NRCELL-2 PRB_ALLOC_CG_ACT_PUSCH (M55308C00032) is above 0
    ...                 Check RTPM counter: NRCELL-2 PRB_USED_PUSCH (M55308C10002) is above 0
    ...                 Check RTPM counter: NRCELL-2 PRB_AVAIL_PUSCH (M55308C10004) is above 0

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=21    ue_last=30    cell_id=2    bwp=second    5qi_id=2    traffic_dir=UL    gfbr_ul_rate=20   traffic_rate=10

    Save number of attached UEs for counters
    Verify UL traffic on UEs with uplink configured grant

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=41    ue_last=50    cell_id=2    bwp=small    5qi_id=3    traffic_dir=UL    gfbr_ul_rate=30    traffic_rate=15

    Verify UL traffic on UEs with uplink configured grant

    Attach UEs with traffic until first UE is rejected due to admission control
    ...    ue_first=31    ue_last=40    cell_id=2    bwp=second    5qi_id=3    traffic_dir=UL    gfbr_ul_rate=20    traffic_rate=10

    Verify UL traffic on UEs with uplink configured grant
    Verify UL traffic on UEs with GBR bearers

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...                 Check RTPM counter: NRCELL-2 SA_UE_CTX_REL_PREEM (M55125C11501) is equal ${preemptable_ues}
    ...                 Check RTPM counter: NRCELL-2 NG_FLOW_REL_GNB_PREEM (M55125C11504) is equal ${preemptable_ues_flows}

    [Teardown]    Run Keywords    Cleanup after test H-IWK103
    ...    AND                    Add Scout Data Info To Testcase


CB008954-H-IWK104 InitialDownlinkBWP interaction
    [Tags]    H-IWK104    NoResUsage
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Purpose of this test is to verify:
    ...    - Interaction with CNI-78446. UE is configured with dedicated config in initialDownlinkBWP during RRC Setup.
    ...    Initial BWP is replaced with large, second dedicated or small BWP via RRC Reconfiguration when UE capabilities are known.
    ...
    ...    - Interaction with CNI-81991. UE is configured with dedicated config in initialDownlinkBWP just after RRC Setup,
    ...    via RRC Reconfiguration. Initial BWP is replaced with large, second dedicated or small BWP via RRC Reconfiguration
    ...    when UE capabilities are known.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-3.UeConnectionEstablishmentMode = useInitialBwp
    ...  - NRCELL-3.actSmallestRRCSetup = false
    ...  - BWP configuration for each NRCELL is described in suite PRECONDTIONS AND DEPENDENCIES
    ...
    ...   SA UEs 1-3 support small BWP1 on NRCELL-3
    ...   SA UEs 4-6 support second BWP2 on NRCELL-3
    ...   SA UEs 7-9 support large BWP3 on NRCELL-3
    ...
    ...  == Postconditions ==
    ...   - All UEs are active in NRCELL-3 with DL & UL traffic ongoing
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules (AEQE,AEHC, AHFII, AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    5G_RAN_USR_RRM_21413; CB_FIM_39914
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    CFAM
    ...    User scenario CB008954-H#IWK.5 SA Inital RRC Setup with dedicated config in initialDownlinkBWP
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - https://collab.ext.net.nokia.com/ui#review:id=895049

    [Setup]    Prepare test environment H-IWK104

    start_collecting_syslog  prefix=H-IWK104

    start_observing_measurements      UE_1       technology=5G
    start_observing_measurements      UE_2       technology=5G
    start_observing_measurements      UE_3       technology=5G
    start_observing_measurements      UE_4       technology=5G
    start_observing_measurements      UE_5       technology=5G
    start_observing_measurements      UE_6       technology=5G
    start_observing_measurements      UE_7       technology=5G
    start_observing_measurements      UE_8       technology=5G
    start_observing_measurements      UE_9       technology=5G

    Attach UE1 to NRCELL-3 with small BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = False)
    Attach UE4 to NRCELL-3 with second BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = False)
    Attach UE7 to NRCELL-3 with large BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = False)

    Attach UE2 to NRCELL-4
    Attach UE5 to NRCELL-4
    Attach UE8 to NRCELL-4
    Perform reestablishment for UE2 to gNB2 NRCELL-3
    Verify that UE2 is configured with small BWP profile after reestablishment to NRCELL-3
    Perform reestablishment for UE5 to gNB2 NRCELL-3
    Verify that UE5 is configured with second BWP profile after reestablishment to NRCELL-3
    Perform reestablishment for UE8 to gNB2 NRCELL-3
    Verify that UE8 is configured with large BWP profile after reestablishment to NRCELL-3

    Attach UE3 to NRCELL-4
    Attach UE6 to NRCELL-4
    Attach UE9 to NRCELL-4
    Perform intra-gNB inter-freq HO for UE3 to gNB2 NRCELL-3
    Verify that UE3 is configured with small BWP profile after HO to NRCELL-3
    Perform intra-gNB inter-freq HO for UE6 to gNB2 NRCELL-3
    Verify that UE6 is configured with second BWP profile after HO to NRCELL-3
    Perform intra-gNB inter-freq HO for UE9 to gNB2 NRCELL-3
    Verify that UE9 is configured with large BWP profile after HO to NRCELL-3

    Run 10Mbps UL and DL traffic on UEs[1-9] PDU1 QFI1 and wait 10 seconds
    Verify 10Mbps UL and DL traffic on UEs[1-9] PDU1 QFI1

    CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 9
    clear_cached_measurements
    Configure  [{'MOC':'NRCELL', 'ID': '3', 'actSmallestRRCSetup': 'true'}]

    Attach UE1 to NRCELL-3 with small BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = True)
    Attach UE4 to NRCELL-3 with second BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = True)
    Attach UE7 to NRCELL-3 with large BWP (UeConnectionEstablishmentMode = useInitialBwp, actSmallestRRCSetup = True)

    Attach UE2 to NRCELL-4
    Attach UE5 to NRCELL-4
    Attach UE8 to NRCELL-4
    Perform reestablishment for UE2 to gNB2 NRCELL-3
    Verify that UE2 is configured with small BWP profile after reestablishment to NRCELL-3
    Perform reestablishment for UE5 to gNB2 NRCELL-3
    Verify that UE5 is configured with second BWP profile after reestablishment to NRCELL-3
    Perform reestablishment for UE8 to gNB2 NRCELL-3
    Verify that UE8 is configured with large BWP profile after reestablishment to NRCELL-3

    Attach UE3 to NRCELL-4
    Attach UE6 to NRCELL-4
    Attach UE9 to NRCELL-4
    Perform intra-gNB inter-freq HO for UE3 to gNB2 NRCELL-3
    Verify that UE3 is configured with small BWP profile after HO to NRCELL-3
    Perform intra-gNB inter-freq HO for UE6 to gNB2 NRCELL-3
    Verify that UE6 is configured with second BWP profile after HO to NRCELL-3
    Perform intra-gNB inter-freq HO for UE9 to gNB2 NRCELL-3
    Verify that UE9 is configured with large BWP profile after HO to NRCELL-3

    Run 10Mbps UL and DL traffic on UEs[1-9] PDU1 QFI1 and wait 10 seconds
    Verify 10Mbps UL and DL traffic on UEs[1-9] PDU1 QFI1

    [Teardown]    Run Keywords    Cleanup after test H-IWK104
    ...    AND                    Add Scout Data Info To Testcase

CB008954-H-IWK105 Three dedicated BWPs configured on asymmetric FDD cell
    [Tags]    H-IWK105
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...    Purpose of this test is to verify interaction with CB007813 - asymmetric cell FDD 30/10MHz.
    ...    Asymmetric cell is configured with 3 BWP profiles.
    ...    Test verifies Initial Context Setup, Reestablishment and handover to asymmetric cell, SCell addition of
    ...    asymmetric cell at small, second and large dedicated BWP.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - BWP configuration for each NRCELL is described in suite PRECONDTIONS AND DEPENDENCIES
    ...
    ...   SA UEs 1-2 support small BWP1 on NRCELL-3
    ...                      2CC CA_n25A-n66A with maximum n25: 10Mhz, n66: 10Mhz
    ...   SA UEs 3-4 support second BWP2 on NRCELL-3
    ...                      2CC CA_n25A-n66A with maximum n25: 20Mhz, n66: 20Mhz
    ...   SA UEs 5-6 support large BWP3 on NRCELL-3
    ...                      2CC CA_n25A-n66A with maximum n25: 30Mhz, n66: 30Mhz
    ...
    ...  == Postconditions ==
    ...   - All UEs are active in NRCELL-4 with DL & UL traffic ongoing
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules (AEQE,AEHC, AHFII, AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    5G_RAN_USR_RRM_21414
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...    CFAM
    ...    User scenario CB008954-H#IWK.6 Three dedicated BWPs configured on asymmetric FDD cell
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - https://collab.ext.net.nokia.com/ui#review:id=895049

    [Setup]    Prepare test environment H-IWK105

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_collecting_syslog  prefix=H-IWK105

    start_observing_measurements      UE_1       technology=5G
    start_observing_measurements      UE_2       technology=5G
    start_observing_measurements      UE_3       technology=5G
    start_observing_measurements      UE_4       technology=5G
    start_observing_measurements      UE_5       technology=5G
    start_observing_measurements      UE_6       technology=5G

    Attach UE1 to NRCELL-4
    Verify that UE1 is configured with small BWP profile after ICS to NRCELL-4
    Perform reestablishment for UE1 to gNB2 NRCELL-4
    Verify that UE1 is configured with small BWP profile after reestablishment to NRCELL-4

    Attach UE2 to NRCELL-3
    Trigger UE2 to send A1 measurement and wait for UE RRC Reconfiguration
    Verify that UE2 is configured with SCell NRCELL-4 small BWP profile
    Perform intra-gNB inter-freq HO for UE2 to gNB2 NRCELL-4
    Verify that UE2 is configured with small BWP profile after HO to NRCELL-4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [3,0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [3,0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [3,0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [1,0,0] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [1,0] in NRCELL-3 in gNB2
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE3 to NRCELL-4
    Verify that UE3 is configured with second BWP profile after ICS to NRCELL-4
    Perform reestablishment for UE3 to gNB2 NRCELL-4
    Verify that UE3 is configured with second BWP profile after reestablishment to NRCELL-4

    Attach UE4 to NRCELL-3
    Trigger UE4 to send A1 measurement and wait for UE RRC Reconfiguration
    Verify that UE4 is configured with SCell NRCELL-4 second BWP profile
    Perform intra-gNB inter-freq HO for UE4 to gNB2 NRCELL-4
    Verify that UE4 is configured with second BWP profile after HO to NRCELL-4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,3,0] in NRCELL-4 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,3,0] in NRCELL-4 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,3,0] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [0,1,0] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [1,0] in NRCELL-3 in gNB2
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE5 to NRCELL-4
    Verify that UE5 is configured with large BWP profile after ICS to NRCELL-4
    Perform reestablishment for UE5 to gNB2 NRCELL-4
    Verify that UE5 is configured with large BWP profile after reestablishment to NRCELL-4

    Attach UE6 to NRCELL-3
    Trigger UE6 to send A1 measurement and wait for UE RRC Reconfiguration
    Verify that UE6 is configured with SCell NRCELL-4 large BWP profile
    Perform intra-gNB inter-freq HO for UE6 to gNB2 NRCELL-4
    Verify that UE6 is configured with large BWP profile after HO to NRCELL-4

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,3] in NRCELL-4 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,3] in NRCELL-4 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,3] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC are equal [0,0,1] in NRCELL-4 in gNB2
    ...                 Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC are equal [0,1] in NRCELL-3 in gNB2
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Run 10Mbps UL and DL traffic on UEs[1-6] PDU1 QFI1 and wait 10 seconds
    Verify 10Mbps UL and DL traffic on UEs[1-6] PDU1 QFI1

    [Teardown]    Run Keywords    Basic cleanup
    ...    AND                    Add Scout Data Info To Testcase

