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
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008954 CFAM
...
...      == HISTORY ==
...         [24.08.2023] - TC Create
...         [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893480)

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS24R2
    ...    CLOUD_5G_I_LO_AP_LO
    ...    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
    ...    PY36

Suite Setup     Run Setup

Resource    ./resources/CB008954_common_keywords.robot

*** Variables ***
${LUA_CFG}=   ${CURDIR}/config/egate_TDD_2cells_n78_n41.lua
${SCFC}=      ${CURDIR}/../../../../../custom-config/Krakow/CB008954/scfc_TDD_n78_n41.xml
${AP_XML}=    ${CURDIR}/../../../../../custom-config/Krakow/CB008954/iphy_AEQE_AEHC_2cells.xml
${SKIP_COUNTERS}=         ${FALSE}

&{NRCELL_1_BWP}=    ID=1    SMALL_BW=40    SECOND_BW=70    LARGE_BW=100
&{NRCELL_2_BWP}=    ID=2    SMALL_BW=20    LARGE_BW=30
@{NRCELL_BWP}=      &{NRCELL_1_BWP}    &{NRCELL_2_BWP}

${gnb2_cell_1_phycell_id}=  50
${gnb2_cell_2_phycell_id}=  51
${gnb3_cell_31_phycell_id}=  52

*** Test Cases ***
CB008954-C-B101 Initial Context Setup to TDD cell with 3 or 2 bottom aligned BWP Profiles
    [Tags]    C_B101
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify the Initial Context Setup procedure in TDD NRCELL with 3 or 2 bottom aligned
    ...     BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-1.actPRBBlanking = False
    ...  - NRCELL-2.actPRBBlanking = False
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQN radio module
    ...        NR_BAND: n78
    ...        SCS: 30kHz
    ...        large BWP3: 100MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        second BWP2: 70MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n189
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - TDD - simulated on AEHC radio module
    ...        NR_BAND: n41
    ...        SCS: 30kHz
    ...        large BWP2: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n51
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...    - UE1 supports BWP1, BWP2, BWP3 profiles from NRCELL-1:
    ...        channelBWs-DL = mhz40,70,100 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz40,70,100 on fr1 scs-30kHz entry for n78
    ...    - UE2 supports BWP1, BWP2 profiles from NRCELL-1:
    ...        channelBWs-DL = mhz40,70 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz40,70 on fr1 scs-30kHz entry for n78
    ...    - UE3 supports BWP1 profile from NRCELL-1:
    ...        channelBWs-DL = mhz40 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz40 on fr1 scs-30kHz entry for n78
    ...    - UE4 supports BWP1, BWP2 profiles from NRCELL-2:
    ...        channelBWs-DL = mhz20,30 on fr1 scs-30kHz entry for n41
    ...	       channelBWs-UL = mhz20,30 on fr1 scs-30kHz entry for n41
    ...    - UE5 supports BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz20 on fr1 scs-30kHz entry for n41
    ...	       channelBWs-UL = mhz20 on fr1 scs-30kHz entry for n41
    ...
    ...  == Postconditions ==
    ...   - UE1, UE2 and UE3 are connected to NRCELL-1
    ...   - UE4 and UE5 are connected to NRCELL-2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated radio modules (AEQN,AEHC)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21344;5G_RAN_USR_RRM_21346;5G_RAN_USR_RRM_21347;5G_RAN_USR_RRM_21354
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-59659 CB008954-C#B.1 Initial Context Setup UE configured with small BWP profile
    ...     -  CB008954-59660 CB008954-C#B.2 Initial Context Setup UE configured with second BWP profile
    ...     -  CB008954-49661 CB008954-C#B.3 Initial Context Setup UE configured with large BWP profile
    ...     -  CB008954-59668 CB008954-D#B.4 CB008954-C#10 Multiple UEs served with different dedicated BWPs
    ...
    ...  == HISTORY ==
    ...     [24.08.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893480)

    start_collecting_syslog  prefix=C_B101

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    Attach UE1 to NRCELL-1
    Verify that UE1 is configured with large BWP profile after ICS to NRCELL-1

    Attach UE4 to NRCELL-2
    Verify that UE4 is configured with large BWP profile after ICS to NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-2 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE2 to NRCELL-1
    Verify that UE2 is configured with second BWP profile after ICS to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Attach UE3 to NRCELL-1
    Verify that UE3 is configured with small BWP profile after ICS to NRCELL-1

    Attach UE5 to NRCELL-2
    Verify that UE5 is configured with small BWP profile after ICS to NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-2 in gNB2

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 5 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 5 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE3 PDU1 QFI1 and wait 5 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE4 PDU1 QFI1 and wait 5 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE3 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE4 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    [Teardown]    Basic cleanup

CB008954-C-B102 Handovers in TDD cell with 3 or 2 bottom aligned BWP Profiles
    [Tags]    C_B102
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify both intra-DU intra-gNB and inter-gNB handovers to TDD NRCELL configured with
    ...     3 or 2 bottom aligned BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRBTS.actIntraFreqHoSA = True
    ...  - NRBTS.actInterFreqHoSA = True
    ...  - NRCELL-1.actPRBBlanking = False
    ...  - NRCELL-2.actPRBBlanking = False
    ...  - NRCELL-1.a3MeasEnabled = rsrp
    ...  - NRCELL-2.a3MeasEnabled = rsrp
    ...  - NRCELL-1 and NRCELL-2 have NRCELL.NRREL objects, which indicates relation to all neighbor cells
    ...  - gNB3 simulated by AirPhone with NRCELL-31 TDD cell with same frequency as gNB2 NRCELL-1
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQN radio module
    ...        NR_BAND: n78
    ...        SCS: 30kHz
    ...        large BWP3: 100MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        second BWP2: 70MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n189
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - TDD - simulated on AEHC radio module
    ...        NR_BAND: n41
    ...        SCS: 30kHz
    ...        large BWP2: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n51
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...    - UE1 supports BWP1,BWP3 profiles from NRCELL-1 and BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz40,100 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz40,100 on fr1 scs-30kHz entry for n78
    ...        channelBWs-DL = mhz20 on fr1 scs-30kHz entry for n41
    ...	       channelBWs-UL = mhz20 on fr1 scs-30kHz entry for n41
    ...    - UE2 supports BWP2 profile from NRCELL-1 and BWP2 profile from NRCELL-2:
    ...        channelBWs-DL = mhz70 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz70 on fr1 scs-30kHz entry for n78
    ...        channelBWs-DL = mhz30 on fr1 scs-30kHz entry for n41
    ...	       channelBWs-UL = mhz30 on fr1 scs-30kHz entry for n41
    ...
    ...  == Postconditions ==
    ...   - UE1 and UE2 are connected to NRCELL-1
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated radio modules (AEQN,AEHC)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21348;5G_RAN_USR_RRM_21349
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-59662 CB008954-C#B.4 Successful Intra/Inter-frequency Intra-DU Intra-gNB handover
    ...     -  CB008954-59663 CB008954-C#B.5 Successful Intra/Inter-frequency Inter-gNB handover
    ...
    ...  == HISTORY ==
    ...     [24.08.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893480)

    start_collecting_syslog  prefix=C_B102

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    start_observing_measurements      UE_1       technology=5G
    start_observing_measurements      UE_2       technology=5G

    Attach UE1 to NRCELL-1
    Verify that UE1 is configured with large BWP profile after ICS to NRCELL-1
    Attach UE2 to NRCELL-2
    Verify that UE2 is configured with large BWP profile after ICS to NRCELL-2

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,1] in NRCELL-1 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,1] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,1] in NRCELL-1 in gNB2
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-2 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-2 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Perform intra-gNB inter-freq HO for UE1 to gNB2 NRCELL-2
    Verify that UE1 is configured with small BWP profile after HO to NRCELL-2
    Perform intra-gNB inter-freq HO for UE2 to gNB2 NRCELL-1
    Verify that UE2 is configured with second BWP profile after HO to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-1 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-1 in gNB2
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    Perform inter-gNB inter-freq HO for UE1 to gNB3 NRADJNRCELL-1
    Perform inter-gNB intra-freq HO for UE2 to gNB3 NRADJNRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...  Run keywords
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-1 in gNB2
    ...  Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,0] in NRCELL-2 in gNB2
    ...  Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    Deregister UE1 and kill if failed
    Deregister UE2 and kill if failed
    Activate UE1 on gNBSim and setup PDU session
    Activate UE2 on gNBSim and setup PDU session

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE1 PDU1 QFI1 and wait 0 seconds
    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE2 PDU1 QFI1 and wait 10 seconds

    Perform inter-gNB intra-freq HO for UE1 to gNB2 NRCELL-1

    Perform inter-gNB inter-freq HO for UE2 to gNB2 NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,0,1] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-2 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,0,0] in NRCELL-2 in gNB2

    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE1 PDU1 QFI1
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE2 PDU1 QFI1

    [Teardown]    Basic cleanup

CB008954-C-B103 RRC connection reestablishment in TDD cell with 3 or 2 bottom aligned BWP Profiles
    [Tags]    C_B103
    [Documentation]
    ...
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     Purpose of this test is to verify the NR RRC reestablishment procedure for UE in TDD NRCELL with 3 or 2 bottom
    ...     aligned BWP profiles.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ASIL + ABIO
    ...  - AMF1 simulated
    ...  - UEs - Airphone simulator configured for SA mode
    ...  - NRBTS.actMultipleDedicatedBWPs = True (CB007552)
    ...  - NRCELL-1.actPRBBlanking = False
    ...  - NRCELL-2.actPRBBlanking = False
    ...  - NRBTS.rrcReestabTypeSA = sameGNB
    ...
    ...  - NRCELL-1 - TDD - simulated on AEQN radio module
    ...        NR_BAND: n78
    ...        SCS: 30kHz
    ...        large BWP3: 100MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        second BWP2: 70MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n189
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 40MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n106
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...  - NRCELL-2 - TDD - simulated on AEHC radio module
    ...        NR_BAND: n41
    ...        SCS: 30kHz
    ...        large BWP2: 30MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = allRb
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...        small BWP1: 20MHz
    ...             NRBTS/BWP_PROFILE/bwpType = dedicated
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartDl = crb0
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeDl = n51
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbStartUl = sameAsDl
    ...             NRBTS/BWP_PROFILE/locationAndBandwidthDl.cRbSizeUl = sameAsDl
    ...
    ...    - UE4 does not support any profile from NRCELL-1 and supports BWP2 profile from NRCELL-2:
    ...        channelBWs-DL = mhz30 on fr1 scs-30kHz entry for n41
    ...	       channelBWs-UL = mhz30 on fr1 scs-30kHz entry for n41
    ...    - UE5 supports BWP2 profile from NRCELL-1 and BWP1 profile from NRCELL-2:
    ...        channelBWs-DL = mhz70 on fr1 scs-30kHz entry for n78
    ...	       channelBWs-UL = mhz70 on fr1 scs-30kHz entry for n78
    ...        channelBWs-DL = mhz20 on fr1 scs-30kHz entry for n41
    ...	       channelBWs-UL = mhz20 on fr1 scs-30kHz entry for n41
    ...
    ...  == Postconditions ==
    ...   - UE4 is connected to NRCELL-1
    ...   - UE5 is connected to NRCELL-2
    ...
    ...  == TESTING TOOLS ==
    ...    AirPhone, 5GCSim, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...   - gNB classicBTS in SA mode
    ...   - HARDWARE ID:  gNB(ASIL + ABIO) with two simulated radio modules (AEQN,AEHC)
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE: 5G_RAN_USR_RRM_21350
    ...
    ...  == REQUIRED LOGS ==
    ...    gNB syslog, Snapshot
    ...
    ...  == CONTACTS ==
    ...     - Malgorzata Konior <malgorzata.konior@nokia.com>
    ...
    ...  == REFERENCES ==
    ...     Related CFAM US:
    ...     -  CB008954-50664 CB008954-C#B.6 RRC connection re-establishment with servieng cell with valid UE context
    ...
    ...  == HISTORY ==
    ...     [24.08.2023] - TC Create
    ...     [22.09.2023] - Review closed (https://collab.ext.net.nokia.com/ui#review:id=893480)

    start_collecting_syslog  prefix=C_B103

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm before Test

    Attach UE5 to NRCELL-1
    Verify that UE5 is configured with second BWP profile after ICS to NRCELL-1

    Perform reestablishment for UE5 to gNB2 NRCELL-1
    Verify that UE5 is configured with second BWP profile after reestablishment to NRCELL-1

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,2,0] in NRCELL-1 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,2,0] in NRCELL-1 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,2,0] in NRCELL-1 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    Perform reestablishment for UE5 to gNB2 NRCELL-2
    Verify that UE5 is configured with small BWP profile after reestablishment to NRCELL-2

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [1,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [1,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [1,0,0] in NRCELL-2 in gNB2

    Omit when SKIP_COUNTERS present
    ...  RTPM clean

    CB008954_common_keywords.Run 10Mbps UL and DL traffic on UE5 PDU1 QFI1 and wait 10 seconds
    Run Keyword And Continue On Failure  Verify 10Mbps UL and DL traffic on UE5 PDU1 QFI1

    Attach UE4 to NRCELL-2
    Verify that UE4 is configured with large BWP profile after ICS to NRCELL-2

    Trigger reestablishment for UE4 to gNB2 NRCELL-1
    Verify that UE4 reestablishment in NRCELL-2 was rejected

    Omit when SKIP_COUNTERS present
    ...  Wait For Rtpm after Test

    Omit when SKIP_COUNTERS present
    ...    Run keywords
    ...    Verify that counters GNB_SA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,1,0] in NRCELL-2 in gNB2
    ...    Verify that counters SGNB_NSA_DU_ADM_SUCC_BWP[1,2,3] are equal [0,0,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RRC_RECONF_BWP[1,2,3]_SENT are equal [0,1,0] in NRCELL-2 in gNB2
    ...    Verify that counters NRRC_RCFG_CMP_BWP[1,2,3]_RCVD are equal [0,1,0] in NRCELL-2 in gNB2

    [Teardown]    Basic cleanup
