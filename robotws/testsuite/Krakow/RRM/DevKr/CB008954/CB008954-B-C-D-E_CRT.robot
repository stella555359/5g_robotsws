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
...         [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=894392)

Resource    ./resources/CB008954_common_keywords.robot
Resource    ./resources/ute_report.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
Suite Setup     Run setup

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_TDD_2c_n78_n41_FDD_2c_n25_n66.lua
${SCFC}=                  scfc_TDD_2c_n78_n41_FDD_2c_n25_n66.xml
${AP_XML}=                ${CURDIR}/config/iphy_AEQE_AEHC_2_AHFII.xml
${SKIP_COUNTERS}=         ${FALSE}

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=20    SECOND_BW=40    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=20    SECOND_BW=40    LARGE_BW=100
&{NRCELL_3_BWP}=    ID=3    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
&{NRCELL_4_BWP}=    ID=4    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
@{NRCELL_BWP}=      &{NRCELL_1_BWP}    &{NRCELL_2_BWP}    &{NRCELL_3_BWP}    &{NRCELL_4_BWP}

*** Test Cases ***
CB008954-B-C-E_1 SA UE Attach-Reestablishment-HO with CA to cell with 3 BWP
    [Tags]    CB008954-B-C-E_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify UE connection to SA cell with 3 BWP configured.
    ...     Test aggregates Initial Context Setup, Reestablishment and intra-gNB HO for TDD and FDD.
    ...     After each procedure test verifies proper SCell. Test covers FDD-FDD, TDD-TDD, FDD-TDD, TDD-FDD CA cases.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-1,2,3,4.actEnhMultipleDedicatedBWPs = true (CB008541 feature flag)
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQE radio module
    ...        NR_BAND: n78
    ...        SCS: 30kHz
    ...        large BWP3:    100MHz, BWP_PROFILE-77
    ...        second BWP2:   40MHz, BWP_PROFILE-74
    ...        small BWP1:    20MHz, BWP_PROFILE-72
    ...        initial BWP:   20Mhz, BWP_PROFILE-17
    ...
    ...  - NRCELL-2 - TDD - simulated on AEHC radio module
    ...        NR_BAND: n41
    ...        SCS: 30kHz
    ...        large BWP3:    100MHz, BWP_PROFILE-77
    ...        second BWP2:   40MHz, BWP_PROFILE-74
    ...        small BWP1:    20MHz, BWP_PROFILE-72
    ...        initial BWP:   20Mhz, BWP_PROFILE-17
    ...
    ...  - NRCELL-3 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        large BWP3:    30MHz, BWP_PROFILE-35
    ...        second BWP2:   20MHz, BWP_PROFILE-37
    ...        small BWP1:    10MHz, BWP_PROFILE-33
    ...        initial BWP:   10Mhz, BWP_PROFILE-31
    ...
    ...  - NRCELL-4 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP3:    30MHz, BWP_PROFILE-35
    ...        second BWP2:   20MHz, BWP_PROFILE-37
    ...        small BWP1:    10MHz, BWP_PROFILE-33
    ...        initial BWP:   10Mhz, BWP_PROFILE-31
    ...
    ...        SA UE1 supports 3CC CA_n25A-n41A-n78A with maximum n25: 10Mhz, 41A: 40Mhz, n78: 20Mhz
    ...        SA UE2 supports 3CC CA_n25A-n41A-n78A with maximum n25: 20Mhz, 41A: 40Mhz, n78: 40Mhz
    ...        SA UE3 supports 3CC CA_n25A-n41A-n78A with maximum n25: 30Mhz, 41A: 40Mhz, n78: 100Mhz
    ...        SA UE4 supports 3CC CA_n25A-n66A-n78A with maximum n25: 30Mhz, 66A: 20Mhz, n78: 20Mhz
    ...        SA UE5 supports 3CC CA_n25A-n66A-n78A with maximum n25: 20Mhz, 66A: 20Mhz, n78: 40Mhz
    ...        SA UE6 supports 3CC CA_n25A-n66A-n78A with maximum n25: 30Mhz, 66A: 20Mhz, n78: 100Mhz
    ...        SA UE7 supports 3CC CA_n25A-n66A-n78A with maximum n25: 30Mhz, 66A: 20Mhz, n78: 100Mhz
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
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21318;5G_RAN_USR_RRM_21319;5G_RAN_USR_RRM_21321;5G_RAN_USR_RRM_21322;
    ...    5G_RAN_USR_RRM_21324;5G_RAN_USR_RRM_21334;5G_RAN_USR_RRM_21338;5G_RAN_USR_RRM_21343;5G_RAN_USR_RRM_21344;
    ...    5G_RAN_USR_RRM_21346;5G_RAN_USR_RRM_21347;5G_RAN_USR_RRM_21348;5G_RAN_USR_RRM_21350;5G_RAN_USR_RRM_21352;
    ...    5G_RAN_USR_RRM_21354;5G_RAN_USR_RRM_21386;5G_RAN_USR_RRM_21387;5G_PM_1299;5G_PM_1314
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     test aggregates main functionalities of TCs:
    ...     CB008954-B-B101_Initial_Context_Setup_to_FDD_cell_with_3_or_2_bottom_aligned_BWP_Profiles
    ...     CB008954-B-B102_handovers_in_FDD_cell_with_3_bottom_aligned_BWP_Profiles
    ...     CB008954-B-B103_RRC_connection_reestablishment_in_FDD_cell_with_3_bottom_aligned_BWP_Profiles
    ...     CB008954-B-B105_Initial_Context_Setup_to_low_bandwidth_BWP_in_FDD_cell
    ...     CB008954-C-B101 Initial Context Setup to TDD cell with 3 or 2 bottom aligned BWP Profiles
    ...     CB008954-C-B102 Handovers in TDD cell with 3 or 2 bottom aligned BWP Profiles
    ...     CB008954-C-B103 RRC connection reestablishment in TDD cell with 3 or 2 bottom aligned BWP Profiles
    ...     CB008954-C-B105 Initial Context Setup to low bandwidth BWP in TDD cell
    ...     CB008954-E-B101_1 SA TDD-TDD Carrier Aggregation - SCell configured with large BWP
    ...     CB008954-E-B101_2 SA FDD-FDD Carrier Aggregation - SCell configured with small or second BWP
    ...
    ...  == HISTORY ==
    ...     [11.012.2023] - TC Create
    ...     [22.09.2023] - Review closed for B, C, E items separately

    [Setup]  Prepare test environment CB008954-B-C-E_1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=B-C-E_1

    start_observing_measurements      UE_1       technology=5G
    start_observing_measurements      UE_2       technology=5G
    start_observing_measurements      UE_3       technology=5G
    start_observing_measurements      UE_4       technology=5G
    start_observing_measurements      UE_5       technology=5G
    start_observing_measurements      UE_6       technology=5G
    start_observing_measurements      UE_7       technology=5G

    Attach UE1 to PCell 1-small BWP with SCells 2-second, 3-small BWP
    Attach UE2 to PCell 1-second BWP with SCells 2-second, 3-second BWP
    Attach UE3 to PCell 1-large BWP with SCells 2-second, 3-large BWP
    Attach UE4 to PCell 3-small BWP with SCells 1-small, 4-second BWP
    Attach UE5 to PCell 3-second BWP with SCells 1-second, 4-second BWP
    Attach UE6 to PCell 3-large BWP with SCells 1-large, 4-second BWP
    Attach UE7 to PCell 4-second BWP with SCells 1-large, 3-large BWP

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [1,1,1], [0,0,0], [1,1,1], [0,1,0]
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT for NRCELLs [1,2,3,4] are equal [1,1,1], [0,0,0], [1,1,1], [0,1,0]
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD for NRCELLs [1,2,3,4] are equal [1,1,1], [0,0,0], [1,1,1], [0,1,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [1,1,2], [0,3,0], [1,1,2], [0,3,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [3,0], [0,0], [3,0], [0,1]
    ...    Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [0,0], [0,0], [0,0], [0,0]
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 20 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE6 PDU1 QFI1 and wait 5 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE7 PDU1 QFI1 and wait 5 seconds

    Reestablish UE1 to PCell 1-small BWP with SCells 2-second, 3-small BWP
    Reestablish UE2 to PCell 2-second BWP with SCells 1-second, 3-second BWP
    Reestablish UE3 to PCell 3-large BWP with SCells 1-large, 2-second BWP
    Reestablish UE4 to PCell 3-small BWP with SCells 1-small, 4-second BWP
    Reestablish UE5 to PCell 4-second BWP with SCells 1-second, 3-second BWP
    Reestablish UE6 to PCell 1-large BWP with SCells 3-large, 4-second BWP
    Reestablish UE7 to PCell 4-second BWP with SCells 1-large, 3-large BWP

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [1,0,1], [0,1,0], [1,0,1], [0,2,0]
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT for NRCELLs [1,2,3,4] are equal [1,0,1], [0,1,0], [1,0,1], [0,2,0]
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD for NRCELLs [1,2,3,4] are equal [1,0,1], [0,1,0], [1,0,1], [0,2,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [1,2,2], [0,2,0], [1,2,2], [0,2,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [2,0], [1,0], [2,0], [1,1]
    ...    Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [0,0], [0,0], [0,0], [0,0]
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Trigger UE1 HO to PCell 3-small BWP with SCells 1-small, 2-second BWP
    Trigger UE2 HO to PCell 3-second BWP with SCells 1-second, 2-second BWP
    Trigger UE3 HO to PCell 1-large BWP with SCells 2-second, 3-large BWP
    Trigger UE4 HO to PCell 1-small BWP with SCells 3-small, 4-second BWP
    Trigger UE5 HO to PCell 1-second BWP with SCells 3-second, 4-second BWP
    Trigger UE6 HO to PCell 3-large BWP with SCells 1-large, 4-second BWP

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [1,1,1], [0,0,0], [1,1,1], [0,0,0]
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT for NRCELLs [1,2,3,4] are equal [1,1,1], [0,0,0], [1,1,1], [0,0,0]
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD for NRCELLs [1,2,3,4] are equal [1,1,1], [0,0,0], [1,1,1], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [1,1,1], [0,3,0], [1,1,1], [0,3,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [3,0], [0,0], [3,0], [0,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [0,0], [0,0], [0,0], [0,0]
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [360,0] in NRCELL-1 in gNB2
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [0,0] in NRCELL-2 in gNB2
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [360,0] in NRCELL-3 in gNB2
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [0,120] in NRCELL-4 in gNB2

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE3 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE4 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE6 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE7 PDU1 QFI1

    [Teardown]    Run Keywords    Basic cleanup
    ...    AND                    Add Scout Data Info To Testcase

CB008954-D-E_1 NSA UE EN-DC setup with CA to cell with 3 BWP
    [Tags]    CB008954-D-E_1
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify NSA UE EN-DC connection cell with 3 BWP configured.
    ...     Test aggregates EN-DC setup and CA configuration.
    ...     Test covers TDD-TDD, FDD-TDD, TDD-FDD CA cases.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for NSA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-1,2,3,4.actEnhMultipleDedicatedBWPs = true (CB008541 feature flag)
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQE radio module
    ...        NR_BAND: n78
    ...        SCS: 30kHz
    ...        large BWP3:    100MHz, BWP_PROFILE-77
    ...        second BWP2:   40MHz, BWP_PROFILE-74
    ...        small BWP1:    20MHz, BWP_PROFILE-72
    ...        initial BWP:   20Mhz, BWP_PROFILE-17
    ...
    ...  - NRCELL-2 - TDD - simulated on AEHC radio module
    ...        NR_BAND: n41
    ...        SCS: 30kHz
    ...        large BWP3:    100MHz, BWP_PROFILE-77
    ...        second BWP2:   40MHz, BWP_PROFILE-74
    ...        small BWP1:    20MHz, BWP_PROFILE-72
    ...        initial BWP:   20Mhz, BWP_PROFILE-17
    ...
    ...  - NRCELL-3 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        large BWP3:    30MHz, BWP_PROFILE-35
    ...        second BWP2:   20MHz, BWP_PROFILE-37
    ...        small BWP1:    10MHz, BWP_PROFILE-33
    ...        initial BWP:   10Mhz, BWP_PROFILE-31
    ...
    ...  - NRCELL-4 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        large BWP3:    30MHz, BWP_PROFILE-35
    ...        second BWP2:   20MHz, BWP_PROFILE-37
    ...        small BWP1:    10MHz, BWP_PROFILE-33
    ...        initial BWP:   10Mhz, BWP_PROFILE-31
    ...
    ...        SA UE71 supports NSA 2CC CA_n41A-n78A with maximum n41: 30Mhz, n78: 30Mhz
    ...        SA UE72 supports NSA 2CC CA_n41A-n78A with maximum n41: 40Mhz, n78: 20Mhz
    ...        SA UE73 supports NSA 2CC CA_n25A-n41A with maximum n25: 30Mhz, n41: 20Mhz
    ...        SA UE74 supports NSA 2CC CA_n25A-n41A with maximum n25: 30Mhz, n41: 100Mhz
    ...        SA UE75 supports NSA 2CC CA_n25A-n78A with maximum n25: 20Mhz, n78: 40Mhz
    ...        SA UE76 supports NSA 2CC CA_n25A-n41A with maximum n41: 30Mhz, n41: 20Mhz
    ...
    ...  == Postconditions ==
    ...   - All UEs are in EN-DC with DL traffic ongoing
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA+NSA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with four simulated radio modules (AEQE,AEHC, AHFII, AHFII)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21382;5G_RAN_USR_RRM_21359;5G_RAN_USR_RRM_21360;5G_RAN_USR_RRM_21361;
    ...    5G_RAN_USR_RRM_21385;5G_RAN_USR_RRM_21388;5G_RAN_USR_RRM_21389;5G_PM_1300;5G_PM_1315
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog
    ...
    ...  == CONTACTS ==
    ...     - Paulina Jedras <paulina.jedras@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     test aggregates main functionalities of TCs:
    ...     CB008954-D-B101 EN-DC setup with NR cell with 3 bottom aligned BWP Profiles
    ...     CB008954-E-B102_1 NSA TDD-TDD Carrier Aggregation - SCell configured with large BWP
    ...     CB008954-E-B102_2 NSA Carrier Aggregation - SCell configured with small or second BWP
    ...
    ...  == HISTORY ==
    ...     [12.12.2023] - TC Create
    ...     [22.09.2023] - Review closed for B, C, E items separately

    [Setup]  Prepare test environment CB008954-D-E_1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_collecting_syslog  prefix=CB008954-D-E_1

    Attach UE71 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE71 with NRCELL_1 on gNB2
    Verify that UE71 is configured with PSCell NRCELL-1 small BWP profile after EN-DC setup with gNB2
    Verify that UE71 is configured with SCell NRCELL-2 small BWP profile after EN-DC setup with gNB2

    Attach UE72 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE72 with NRCELL_1 on gNB2
    Verify that UE72 is configured with PSCell NRCELL-1 small BWP profile after EN-DC setup with gNB2
    Verify that UE72 is configured with SCell NRCELL-2 second BWP profile after EN-DC setup with gNB2

    Attach UE73 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE73 with NRCELL_2 on gNB2
    Verify that UE73 is configured with PSCell NRCELL-2 small BWP profile after EN-DC setup with gNB2
    Verify that UE73 is configured with SCell NRCELL-3 large BWP profile after EN-DC setup with gNB2

    Attach UE74 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE74 with NRCELL_2 on gNB2
    Verify that UE74 is configured with PSCell NRCELL-2 large BWP profile after EN-DC setup with gNB2
    Verify that UE74 is configured with SCell NRCELL-3 large BWP profile after EN-DC setup with gNB2

    Attach UE75 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE75 with NRCELL_3 on gNB2
    Verify that UE75 is configured with PSCell NRCELL-3 second BWP profile after EN-DC setup with gNB2
    Verify that UE75 is configured with SCell NRCELL-1 second BWP profile after EN-DC setup with gNB2

    Attach UE76 to simulated eNB1 CELL-1
    Trigger SgnbAddition procedure for UE76 with NRCELL_3 on gNB2
    Verify that UE76 is configured with PSCell NRCELL-3 large BWP profile after EN-DC setup with gNB2
    Verify that UE76 is configured with SCell NRCELL-2 small BWP profile after EN-DC setup with gNB2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] for NRCELLs [1,2,3,4] are equal [2,0,0], [1,0,1], [0,1,1], [0,0,0]
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT for NRCELLs [1,2,3,4] are equal [2,0,0], [1,0,1], [0,1,1], [0,0,0]
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD for NRCELLs [1,2,3,4] are equal [2,0,0], [1,0,1], [0,1,1], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,0,0], [0,0,0], [0,0,0], [0,0,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_BWP[1,2,3]_SUCC for NRCELLs [1,2,3,4] are equal [0,1,0], [2,1,0], [0,0,2], [0,0,0]
    ...    Verify that counters GNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [0,0], [0,0], [0,0], [0,0]
    ...    Verify that counters SGNB_DU_SCELL_ADM_[S,L]_BWP_SUCC for NRCELLs [1,2,3,4] are equal [2,0], [0,2], [2,0], [0,0]
    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test
    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [240,0] in NRCELL-1 in gNB2
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [0,240] in NRCELL-2 in gNB2
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [240,0] in NRCELL-3 in gNB2
    ...    Verify that counters SUM_UE_SCELL_CONF_[S,L]_BWP are equal [0,0] in NRCELL-4 in gNB2

    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE71 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE72 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE73 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE74 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE75 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps DL traffic on split bearer for UE76 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps DL traffic on SCG split bearer for UE71
    Run Keyword And Continue On Failure  Verify 10Mbps DL traffic on SCG split bearer for UE72
    Run Keyword And Continue On Failure  Verify 10Mbps DL traffic on SCG split bearer for UE73
    Run Keyword And Continue On Failure  Verify 10Mbps DL traffic on SCG split bearer for UE74
    Run Keyword And Continue On Failure  Verify 10Mbps DL traffic on SCG split bearer for UE75
    Run Keyword And Continue On Failure  Verify 10Mbps DL traffic on SCG split bearer for UE76

    [Teardown]    Run Keywords    Basic cleanup
    ...    AND                    Add Scout Data Info To Testcase

*** Keywords ***
Attach UE${ue_id} to PCell ${pc_id}-${pc_type} BWP with SCells ${sc1_id}-${sc1_type}, ${sc2_id}-${sc2_type} BWP
    Attach UE${ue_id} to NRCELL-${pc_id}
    Verify that UE${ue_id} is configured with ${pc_type} BWP profile after ICS to NRCELL-${pc_id}
    Trigger UE${ue_id} to send A1 measurement and wait for UE RRC Reconfiguration
    Verify that UE${ue_id} is configured with SCell NRCELL-${sc1_id} ${sc1_type} BWP profile
    Verify that UE${ue_id} is configured with SCell NRCELL-${sc2_id} ${sc2_type} BWP profile

Reestablish UE${ue_id} to PCell ${pc_id}-${pc_type} BWP with SCells ${sc1_id}-${sc1_type}, ${sc2_id}-${sc2_type} BWP
    Perform reestablishment for UE${ue_id} to gNB2 NRCELL-${pc_id}
    Verify that UE${ue_id} is configured with ${pc_type} BWP profile after reestablishment to NRCELL-${pc_id}
    Trigger UE${ue_id} to send A1 measurement and wait for UE RRC Reconfiguration
    Verify that UE${ue_id} is configured with SCell NRCELL-${sc1_id} ${sc1_type} BWP profile
    Verify that UE${ue_id} is configured with SCell NRCELL-${sc2_id} ${sc2_type} BWP profile

Trigger UE${ue_id} HO to PCell ${pc_id}-${pc_type} BWP with SCells ${sc1_id}-${sc1_type}, ${sc2_id}-${sc2_type} BWP
    Perform intra-gNB inter-freq HO for UE${ue_id} to gNB2 NRCELL-${pc_id}
    Verify that UE${ue_id} is configured with ${pc_type} BWP profile after HO to NRCELL-${pc_id}
    Trigger UE${ue_id} to send A1 measurement and wait for UE RRC Reconfiguration
    Verify that UE${ue_id} is configured with SCell NRCELL-${sc1_id} ${sc1_type} BWP profile
    Verify that UE${ue_id} is configured with SCell NRCELL-${sc2_id} ${sc2_type} BWP profile

Verify that counters ${counters} for NRCELLs [1,2,3,4] are equal [${c1_val}], [${c2_val}], [${c3_val}], [${c4_val}]
    Verify that counters ${counters} are equal [${c1_val}] in NRCELL-1 in gNB2
    Verify that counters ${counters} are equal [${c2_val}] in NRCELL-2 in gNB2
    Verify that counters ${counters} are equal [${c3_val}] in NRCELL-3 in gNB2
    Verify that counters ${counters} are equal [${c4_val}] in NRCELL-4 in gNB2

