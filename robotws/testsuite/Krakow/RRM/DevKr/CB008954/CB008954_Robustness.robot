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
...            initial BWP:   20Mhz, BWP_PROFILE-17
...            PS BWP:        20Mhz, BWP_PROFILE-71
...
...      - NRCELL-2 - TDD - simulated on AEHC radio module
...            NR_BAND: n41
...            SCS: 30kHz
...            large BWP3:    100MHz, BWP_PROFILE-77
...            second BWP2:   60MHz, BWP_PROFILE-74
...            small BWP1:    40MHz, BWP_PROFILE-72
...            initial BWP:   20Mhz, BWP_PROFILE-17
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
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008954 CFAM
...
...      == HISTORY ==
...         [15.12.2023] - TC Create
...         [19.01.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=895049)

Resource    ./resources/CB008954_common_keywords.robot
Resource    ./resources/ute_report.robot

Force Tags    CONFIGURED    CRT    PY39    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ

Suite Setup     Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_TDD_2c_n78_n41_FDD_2c_n25_n66.lua
${SCFC}=                  scfc_TDD_2c_n78_n41_FDD_2c_n25_n66_robustness.xml
${AP_XML}=                ${CURDIR}/config/iphy_AEQE_AEHC_2_AHFII.xml
${SKIP_COUNTERS}=         ${FALSE}

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=40    SECOND_BW=60    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=40    SECOND_BW=60    LARGE_BW=100
&{NRCELL_3_BWP}=    ID=3    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
&{NRCELL_4_BWP}=    ID=4    SMALL_BW_DL=10    SMALL_BW_UL=10    SECOND_BW_DL=20    SECOND_BW_UL=10    LARGE_BW_DL=30    LARGE_BW_UL=10
...                 ASYMMETRIC=${TRUE}
@{NRCELL_BWP}=      &{NRCELL_1_BWP}    &{NRCELL_2_BWP}    &{NRCELL_3_BWP}    &{NRCELL_4_BWP}

*** Test Cases ***
CB008954-Robustness_TC1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify failure scenarios including ICS, reestablishment and handover with UE configured
    ...  with second dedicated BWP profile
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL configuration is described at the top of this test suite
    ...  - AMF1 simulated
    ...
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRCELL/actPRBBlanking = false (in all cells)
    ...  - NRBTS/rrcReestabTypeSA = sameGNB
    ...  - NRBTS/actInterFreqHoSA = true
    ...  - NRBTS/actIntraFreqHoSA = true
    ...  - NRCELL-1/a2MeashoEnabledSA = rsrp
    ...  - NRCELL-1/NRREL pointing at NRCELL-3 configured
    ...  - NRCELL-1/NRHOIF configured with NRCELL-3 ssbfrequency and A5 measurements enabled
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE, AEHC,2xAHFII radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: N/A - robustness scenario
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US: N/A - robustness scenario
    ...
    ...  == HISTORY ==
    ...     [08.01.2024] - TC Create
    ...     [19.01.2024] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=895049)

    [Setup]    Prepare test environment Robust-TC1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_collecting_syslog  prefix=Robust-TC1

    Attach UE1 to NRCELL-1 and expect it to fail due to missing RRC Reconfiguration Complete message

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=1 reset

    Attach UE2 to NRCELL-1
    Trigger RRC Reestablishment for UE2 to NRCELL-1 and expect it to fail due to missing RRC Reconfiguration Complete message

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,2,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,2,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=2 reset

    Attach UE3 to NRCELL-1
    Trigger intra-gNB inter-freq HO for UE3 to gNB2 NRCELL-3 and expect it to fail due to missing RRC message

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...     Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,1,0], [0,0,0], [0,1,0], [0,0,0]
    ...     Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...     Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT for NRCELLs [1,2,3,4] are equal [0,1,0], [0,0,0], [0,1,0], [0,0,0]
    ...     Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD for NRCELLs [1,2,3,4] are equal [0,1,0], [0,0,0], [0,0,0], [0,0,0]

    [Teardown]    Run Keywords    Cleanup after test Robust-TC1
    ...    AND                    Add Scout Data Info To Testcase

CB008954-Robustness_TC2
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify step wise carrier aggregation configuration and ability to release SCells due
    ...  to poor radio link conditions for UE configured with second dedicated BWP profile
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL configuration is described at the top of this test suite
    ...  - AMF1 simulated
    ...
    ...
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRCELL/actPRBBlanking = false (in all cells)
    ...  - NRCELL-1/a2MeashoEnabledSA = none
    ...  - NRCELL-1/a2MeasSCellRelEnabled = rsrp
    ...  - NRCELL-1/a1MeasSCellAddEnabled = rsrp
    ...  - NRCELL-1/a1ThresholdSCellAddSsbRsrpFDD = 30
    ...  - NRCELL-1/a1ThresholdSCellAddSsbRsrpTDD = 60
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQE, AEHC, 2xAHFII radio modules
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: N/A - robustness scenario
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US: N/A - robustness scenario
    ...
    ...  == HISTORY ==
    ...     [11.09.2023] - TC Create
    ...     [20.11.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=894392)

    [Setup]    Prepare test environment Robust-TC2

    start_collecting_syslog  prefix=Robust-TC2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    Attach UE1 to NRCELL-1
    Verify that UE1 is configured with second BWP profile after ICS to NRCELL-1
    Trigger UE1 to send A1 measurement above FDD SCell addition threshold
    Verify that UE1 is configured with SCell NRCELL-3 small BWP profile

    Trigger UE1 to send A1 measurement above TDD SCell addition threshold
    Verify that UE1 is configured with SCell NRCELL-2 second BWP profile

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,1,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT for NRCELLs [1,2,3,4] are equal [0,1,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD for NRCELLs [1,2,3,4] are equal [0,1,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,0,0], [0,1,0], [1,0,0], [0,0,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [2,0], [0,0], [0,0], [0,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [0,0], [0,0], [0,0], [0,0]

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Trigger UE1 SCell release due to poor radio link conditions
    Verify that UE1 SCell was released

    [Teardown]    Run Keywords    Cleanup after test Robust-TC2
    ...    AND                    Add Scout Data Info To Testcase
