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
...         CB008954-B-B101: Initial Context Setup to FDD cell
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
...       - Paulina Jedras <paulina.jedras@nokia.com>
...       - Malgorzata Konior <malgorzata.konior@nokia.com>
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == MAINTAINER ==
...       - Mateusz Matusik <mateusz.matusik@nokia.com>
...
...      == REFERENCES ==
...         CB008954 CFAM
...
...      == HISTORY ==
...         [05.09.2023] - Create Test Suite
...         [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893789)

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...    PY36

Suite Setup     Run Setup

Resource    ./resources/CB008954_common_keywords.robot

*** Variables ***
${LUA_CFG}=               ${CURDIR}/config/egate_FDD_2cells_n25_n66.lua
${SCFC}=                  ${CURDIR}/../../../../../custom-config/Krakow/CB008954/scfc_FDD_n25_n66.xml
${AP_XML}=                ${CURDIR}/../../../../../custom-config/Krakow/CB008954/iphy_AHFII_2cells.xml
${SKIP_COUNTERS}=         ${FALSE}


&{NRCELL_1_BWP}=    ID=1    SMALL_BW=10    SECOND_BW=20    LARGE_BW=30
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=10    LARGE_BW=15
@{NRCELL_BWP}=      &{NRCELL_1_BWP}    &{NRCELL_2_BWP}

${gnb2_cell_1_phycell_id}=  50
${gnb2_cell_2_phycell_id}=  51
${gnb3_cell_31_phycell_id}=  52

*** Test Cases ***
CB008954-B-B101_Initial_Context_Setup_to_FDD_cell_with_3_or_2_bottom_aligned_BWP_Profiles
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify the Initial Context Setup procedure in FDD NRCELL with 3 or 2
    ...  bottom aligned BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        BWP3: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP2: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        BWP2: 15MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - AMF1 simulated
    ...
    ...    - UE1 supports BWP3 NRCELL-1:
    ...        channelBWs-DL = mhz10,20,30 on fr1 scs-15kHz entry for n25
    ...	       channelBWs-UL = mhz10,20,30 on fr1 scs-15kHz entry for n25
    ...    - UE2 supports BWP2 profile from NRCELL-1:
    ...        channelBWs-DL = mhz10,20 on fr1 scs-15kHz entry for n25
    ...	       channelBWs-UL = mhz10,20 on fr1 scs-15kHz entry for n25
    ...    - UE3 supports BWP1 profile from NRCELL-1:
    ...        channelBWs-DL = mhz10 on fr1 scs-15kHz entry for n25
    ...	       channelBWs-UL = mhz10 on fr1 scs-15kHz entry for n25
    ...    - UE4 supports BWP2 profile from NRCELL-2:
    ...        channelBWs-DL = mhz10,15 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz10,15 on fr1 scs-15kHz entry for n66
    ...    - UE5 supports BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz10 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz10 on fr1 scs-15kHz entry for n66
    ...
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRCELL/actPRBBlanking = false (in both cells)
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AHFII radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_1299, 5G_RAN_USR_RRM_21319, 5G_RAN_USR_RRM_21321,
    ...                           5G_RAN_USR_RRM_21322, 5G_RAN_USR_RRM_21343
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-B-B.1 Initial Context Setup UE configured with small BWP profile
    ...     -  CB008954-B-B.2 Initial Context Setup UE configured with second BWP profile
    ...     -  CB008954-B-B.3 Initial Context Setup UE configured with large BWP profile
    ...     -  CB008954-B-B.10 Initial context setup when large BWP is 15MHz
    ...     -  CB008954-B-B.11 Multiple UEs served with different dedicated BWPs
    ...
    ...  == HISTORY ==
    ...     [05.09.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893789)

    [Tags]  B-B101

    start_collecting_syslog  prefix=B_B101

    Omit when SKIP_COUNTERS present
    ...  Collect RD counters

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    Attach UE1 to NRCELL-1
    Verify that UE1 is configured with large BWP profile after ICS to NRCELL-1
    Verify full additional fields for CB008954 requirements for UE1

    Attach UE2 to NRCELL-1
    Verify that UE2 is configured with second BWP profile after ICS to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,1] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,1] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,1] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE3 to NRCELL-1
    Verify that UE3 is configured with small BWP profile after ICS to NRCELL-1
    Verify basic additional fields for CB008954 requirements for UE3

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE4 to NRCELL-2
    Verify that UE4 is configured with large BWP profile after ICS to NRCELL-2
    Verify basic additional fields for CB008954 requirements for UE4

    Attach UE5 to NRCELL-2
    Verify that UE5 is configured with small BWP profile after ICS to NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,1,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,1,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,1,0] in NRCELL-2 in gNB2

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE3 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE3 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE4 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    [Teardown]    Run keywords
    ...        CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 5     AND
    ...        stop collecting syslog              AND
    ...        Sleep   10s

CB008954-B-B102_handovers_in_FDD_cell_with_3_bottom_aligned_BWP_Profiles
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify both intra-DU intra-gNB and inter-gNB handovers to FDD NRCELL configured
    ...  with 3 or 2 bottom aligned BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        BWP3: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP2: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        BWP2: 15MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - gNB3 simulated gNB by AirPhone
    ...  - NRCELL-31 simulated FDD cell with same frequency as gNB2 NRCELL-1
    ...  - AMF1 simulated
    ...
    ...    - UE1 supports BWP3 profile from NRCELL-1 and BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz10,30 on fr1 scs-15kHz entry for n25
    ...	       channelBWs-UL = mhz10,30 on fr1 scs-15kHz entry for n25
    ...        channelBWs-DL = mhz10 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz10 on fr1 scs-15kHz entry for n66
    ...    - UE2 supports BWP2 profile from NRCELL-1 and BWP2 profile from NRCELL-2:
    ...        channelBWs-DL = mhz10,20 on fr1 scs-15kHz entry for n25
    ...	       channelBWs-UL = mhz10,20 on fr1 scs-15kHz entry for n25
    ...        channelBWs-DL = mhz15 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz15 on fr1 scs-15kHz entry for n66
    ...
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRCELL/actPRBBlanking = false (in both cells)
    ...  - NRCELL/a3MeasEnabled is set to 'rsrp' for both cells
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
    ...  - NRBTS/actInterFreqHoSA is set to 'true'
    ...  - both cells have NRCELL/NRREL objects, which indicates relation to all neighbor cells
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AHFII radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_1299, 5G_RAN_USR_RRM_21324, 5G_RAN_USR_RRM_21325
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-B-B.4 Successful Intra/Inter-frequency Intra-DU Intra-gNB handover
    ...     -  CB008954-B-B.5 Successful Intra/Inter-frequency Inter-gNB handover
    ...
    ...  == HISTORY ==
    ...     [05.09.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893789)

    [Tags]  B-B102

    start_collecting_syslog  prefix=B_B102

    Omit when SKIP_COUNTERS present
    ...  Collect RD counters

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm Before Test

    start_observing_measurements      UE_1       technology=5G
    start_observing_measurements      UE_2       technology=5G

    Attach UE1 to NRCELL-2
    Verify that UE1 is configured with small BWP profile after ICS to NRCELL-2
    Attach UE2 to NRCELL-1
    Verify that UE2 is configured with second BWP profile after ICS to NRCELL-1

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Perform intra-gNB inter-freq HO for UE1 to gNB2 NRCELL-1
    Verify that UE1 is configured with large BWP profile after HO to NRCELL-1
    Verify full additional fields for CB008954 requirements for UE1
    Perform intra-gNB inter-freq HO for UE2 to gNB2 NRCELL-2
    Verify that UE2 is configured with large BWP profile after HO to NRCELL-2
    Verify basic additional fields for CB008954 requirements for UE2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,1] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,1] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,1] in NRCELL-1 in gNB2
    ...                 Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    Perform inter-gNB intra-freq HO for UE1 to gNB3 NRADJNRCELL-1
    Perform inter-gNB inter-freq HO for UE2 to gNB3 NRADJNRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Activate UE1 on gNBSim and setup PDU session
    Activate UE2 on gNBSim and setup PDU session

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 10 seconds

    Perform inter-gNB inter-freq HO for UE1 to gNB2 NRCELL-2

    Perform inter-gNB intra-freq HO for UE2 to gNB2 NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    [Teardown]    Run keywords
    ...        CB008954_setups_and_teardowns.Detach and kill UEs from 1 to 2     AND
    ...        stop collecting syslog              AND
    ...        Sleep   10s


CB008954-B-B103_RRC_connection_reestablishment_in_FDD_cell_with_3_bottom_aligned_BWP_Profiles
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify the NR RRC reestablishment procedure for UE in FDD NRCELL with 3 or 2
    ...  bottom aligned BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        BWP3: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP2: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        BWP2: 15MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - AMF1 simulated
    ...
    ...    - UE5 supports BWP2 profile from NRCELL-1 and BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz20 on fr1 scs-15kHz entry for n25
    ...	       channelBWs-UL = mhz20 on fr1 scs-15kHz entry for n25
    ...        channelBWs-DL = mhz10 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz10 on fr1 scs-15kHz entry for n66
    ...
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRCELL/actPRBBlanking = false (in both cells)
    ...  - NRBTS/rrcReestabTypeSA = sameGNB
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AHFII radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_1299, 5G_RAN_USR_RRM_21334
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-B-B.6 RRC connection re-establishment with serving cell with valid UE context
    ...
    ...  == HISTORY ==
    ...     [05.09.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893789)

    [Tags]  B-B103

    start_collecting_syslog  prefix=B_B103

    Omit when SKIP_COUNTERS present
    ...  Collect RD counters

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    Attach UE5 to NRCELL-1
    Verify that UE5 is configured with second BWP profile after ICS to NRCELL-1

    Perform reestablishment for UE5 to gNB2 NRCELL-1
    Verify that UE5 is configured with second BWP profile after reestablishment to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,2,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,2,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,2,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    Perform reestablishment for UE5 to gNB2 NRCELL-2
    Verify that UE5 is configured with small BWP profile after reestablishment to NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-1 in gNB2
    ...                 Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-2 in gNB2

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    [Teardown]    Run keywords
    ...        Detach and kill UE5     AND
    ...        stop collecting syslog              AND
    ...        Sleep   10s


CB008954-B-B105_Initial_Context_Setup_to_low_bandwidth_BWP_in_FDD_cell
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this test is to verify the Initial Context Setup procedure in FDD NRCELL with 2 bottom aligned
    ...  BWP profiles. BWP2 profile (large) is configured with 15MHz bandwidth
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - NRCELL-1 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n25
    ...        SCS: 15kHz
    ...        BWP3: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP2: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - FDD - simulated on AHFII radio module
    ...        NR_BAND: n66
    ...        SCS: 15kHz
    ...        BWP2: 15MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        BWP1: 10MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n52
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - AMF1 simulated
    ...
    ...    - UE4 supports BWP2 profile from NRCELL-2:
    ...        channelBWs-DL = mhz10,15 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz10,15 on fr1 scs-15kHz entry for n66
    ...    - UE5 supports BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz10 on fr1 scs-15kHz entry for n66
    ...	       channelBWs-UL = mhz10 on fr1 scs-15kHz entry for n66
    ...
    ...  - NRBTS/actMultipleDedicatedBWPs = true (CB007552 feature flag)
    ...  - NRCELL/actPRBBlanking = false (in both cells)
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AHFII radio module
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_PM_1299, 5G_RAN_USR_RRM_21339, 5G_RAN_USR_RRM_21343
    ...
    ...  == REQUIRED LOGS ==
    ...    NR-RRC, NGAP pcap, PM counter file
    ...
    ...  == CONTACTS ==
    ...  - Mateusz Matusik <mateusz.matusik@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-B-B.10 Initial context setup when large BWP is 15MHz
    ...     -  CB008954-B-B.11 Multiple UEs served with different dedicated BWPs
    ...
    ...  == HISTORY ==
    ...     [05.09.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893789)

    [Tags]  B-B105

    start_collecting_syslog  prefix=B_B105

    Omit when SKIP_COUNTERS present
    ...  Collect RD counters

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    Attach UE4 to NRCELL-2
    Verify that UE4 is configured with large BWP profile after ICS to NRCELL-2

    Attach UE5 to NRCELL-2
    Verify that UE5 is configured with small BWP profile after ICS to NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords   Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,1,0] in NRCELL-2 in gNB2
    ...                 Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,1,0] in NRCELL-2 in gNB2
    ...                 Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,1,0] in NRCELL-2 in gNB2

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE4 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE4 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    [Teardown]    Run keywords
    ...        CB008954_setups_and_teardowns.Detach and kill UEs from 4 to 5     AND
    ...        stop collecting syslog              AND
    ...        Sleep   10s
