*** Settings ***
Documentation
...    | Author:        | Michele, Ulm SQD64                          |
...    | Contact:       | I_PZ_ULM_SQD_64@internal.nsn.com            |
...    | Description:   | Verification Keywords for CB010636          |

Resource    ../../../resources/Common/pmcounters.robot
Resource    testsuite/Ulm/SyVe/CB009267/resources/CB009267_Verification.robot


*** Keywords ***
Verify CB010636-A_TC04_TMO PM Values per Cells
    [Documentation]
    ...    |  CNI 126924 derived from CB010636-A_TC04 Performance Counters PM Values per cells.         |
    ...    |  the variable ${S_PCELL_UE_1} is set as test variable in the preconditions part
    # 1. period: traffic only on pscell - no scell activated -> only counter 83 is pegged
    ${M55349_1_period_Values_per_Cells}   Create List
    ...  (NRCELL-${S_PCELL_UE_1})M55349C00083  >=  1  RLC_PDU_VOL_TX_CA_NOT_ACT_NSA: DL RLC PDU vol. trans to NSA DRBs that DON'T have SCell(s) act
    ...  (NRCELL-${S_PCELL_UE_1})M55349C00084  ==  0  RLC_PDU_VOL_TX_PRI_NSA_CA_ACT: DL RLC PDU vol. trans o. prim path to NSA DRBs t HAVE SCells act
    Run Keyword And Continue On Failure   pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55349_1_period_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${2}
    # 2. period: traffic on pscell and also scell is added to take traffic -> both counters 83 + 84 are pegged
    ${M55349_2_period_Values_per_Cells}   Create List
    ...  (NRCELL-${S_PCELL_UE_1})M55349C00083  >=  1  DL_INA_PRO_REL_SCELL_ATT_NSA: DL RLC PDU vol. trans to NSA DRBs that DON'T have SCell(s) act
    ...  (NRCELL-${S_PCELL_UE_1})M55349C00084  >=  1  DL_INA_PRO_REL_SCELL_SUC_NSA: DL RLC PDU vol. trans o. prim path to NSA DRBs t HAVE SCells act
    Run Keyword And Continue On Failure   pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55349_2_period_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${1}
    # 3. period: traffic on pscell and scell during the whole meas. period -> only counter 84 is pegged
    ${M55349_3_period_Values_per_Cells}   Create List
    ...  (NRCELL-${S_PCELL_UE_1})M55349C00083  ==  0  DL_INA_PRO_REL_SCELL_ATT_NSA: DL RLC PDU vol. trans to NSA DRBs that DON'T have SCell(s) act
    ...  (NRCELL-${S_PCELL_UE_1})M55349C00084  >=  1  DL_INA_PRO_REL_SCELL_SUC_NSA: DL RLC PDU vol. trans o. prim path to NSA DRBs t HAVE SCells act
    Run Keyword And Continue On Failure   pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55349_3_period_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verification of performance counters
    [Documentation]
    ...    | PCell_id          | Primary Cell ID.                            |
    ...    | 2CC_SCell_id      | First Secondary cell                        |
    ...    | 3CC_SCell_id      | 2nd Secondary cell                          |
    ...    | 4CC_SCell_id      | 3rd Secondary cell                          |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8    ${2CC_SCell_id}=4    ${3CC_SCell_id}=9    ${4CC_SCell_id}=13

    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${reference_table}   Create List
    ...    M55349C03001    !=  0    UL_RLC_VOL_UE_TPUT_TOT: ThpVolUl UL UE throughput volume at RLC PDU level Total (M55349C03001)
    ...    M55349C04001    !=  0    UL_RLC_TIME_UE_TPUT: ThpTimeUl UL UE throughput time at RLC PDU level (M55349C04001)
    ...    M55349C03002    !=  0    DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level (M55349C03002)
    ...    M55349C04002    !=  0    DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level (M55349C04002)

    Log To Console    ${\n}Verify PM counter Under NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${reference_table}  pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    # New Radio Performance Monitoring QCI ARP Profiles
    # MRBTS-403891/NRBTS-403891/NRPMRNL-1/NRPMQAP-1
    # NRCELL-9/PLMN-PLMN/NRPMQAP-1
    ${PCell_PMQAP_Counters}   Create List
    ...    M55353C00002    !=  0    DL_RLC_PDU_VOL_UE_TPUT_PMQAP: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level NRPMQAP (M55353C00002)
    ...    M55353C00003    !=  0    DL_RLC_PDU_TIME_UE_TPUT_PMQAP: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level NRPMQAP (M55353C00003)

    Log To Console    ${\n}Verify PM counter Under NRCELL-${PCell_id}/PLMN-PLMN/NRPMQAP-1
    Verify PM Counter Reference table    reference_table=${PCell_PMQAP_Counters}
    ...    pm_dir=${PM_FILES}
    ...    distname_suffix=NRCELL-${PCell_id}/PLMN-PLMN/NRPMQAP-1

    # PM incremented if second UE is present!
    ${SCells_incremented}   Create List
    ...    M55349C03001    >=  0    UL_RLC_VOL_UE_TPUT_TOT: ThpVolUl UL UE throughput volume at RLC PDU level Total (M55349C03001)
    ...    M55349C04001    >=  0    UL_RLC_TIME_UE_TPUT: ThpTimeUl UL UE throughput time at RLC PDU level (M55349C04001)
    ...    M55349C03002    >=  0    DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level (M55349C03002)
    ...    M55349C04002    >=  0    DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level (M55349C04002)

    Log To Console    ${\n}Verify PM counter check in NRCELL-${2CC_SCell_id}
    Verify PM Counter Reference table    reference_table=${SCells_incremented}  pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}

    Log To Console    ${\n}Verify PM counter check in NRCELL-${3CC_SCell_id}
    Verify PM Counter Reference table    reference_table=${SCells_incremented}  pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}

    Log To Console    ${\n}Verify PM counter check in NRCELL-${4CC_SCell_id}
    Verify PM Counter Reference table    reference_table=${SCells_incremented}  pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}

    Log To Console    Info: ${\n}Verify of PM Counter KW is completed.


Verification of Former Performance Counters
    [Documentation]
    ...    | Former performance counters | Verification.                            |
    ...    | PCell_id                    | Primary Cell ID.                         |
    ...    | 2CC_SCell_id                | First Secondary cell                     |
    ...    | 3CC_SCell_id                | 2nd Secondary cell                       |
    ...    | 4CC_SCell_id                | 3rd Secondary cell                       |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8    ${2CC_SCell_id}=4    ${3CC_SCell_id}=9    ${4CC_SCell_id}=13

    Log To Console    Info: ${\n}Verify of Former PM Counters...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    # Interesting Legacy counters:
    # M55349C03002    DL_RLC_PDU_VOL_UE_TPUT
    ${Former_PMC_table}   Create List
    ...  M55349C03002    >=  0    DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level (M55349C03002)
    ...  M55349C04002    >=  0    DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level (M55349C04002)
    ...  M55349C03001    >=  0    UL_RLC_VOL_UE_TPUT_TOT: ThpVolUl UL UE throughput volume at RLC PDU level Total (M55349C03001)
    ...  M55349C04001    >=  0    UL_RLC_TIME_UE_TPUT: ThpTimeUl UL UE throughput time at RLC PDU level (M55349C04001)

    ${Former_PMC_table_2}   Create List
    ...  M55353C00002    >=  0    DL_RLC_PDU_VOL_UE_TPUT_PMQAP: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level NRPMQAP (M55353C00002)
    ...  M55353C00003    >=  0    DL_RLC_PDU_TIME_UE_TPUT_PMQAP: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level NRPMQAP (M55353C00003)
    ...  M55353C01001    >=  0    UL_RLC_TIME_UE_TPUT_PMQAP: ThpTimeUl UL UE throughput time at RLC PDU level NRPMQAP (M55353C01001)
    ...  M55353C00001    >=  0    UL_RLC_VOL_UE_TPUT_PMQAP: ThpVolUl UL UE throughput volume at RLC PDU level Total NRPMQAP (M55353C00001)

    ${Group_09_PMC_table}   Create List
    ...  M55350C00009    >=  0    DL_PDCP_TIME_UE_TPUT_QOS_09: ThpTimeDl DL UE Throughput Time at PDCP SDU Level - QoS Group 09 (M55350C00009)
    ...  M55350C01009    >=  0    DL_PDCP_VOL_UE_TPUT_QOS_09: ThpVolDl DL UE Throughput Volume at PDCP SDU Level - QoS Group 09 (M55350C01009)
    ...  M55350C03009    >=  0    DL_PDCP_VOL_UE_TPUT_5G_QOS09: ThpVolDl DL UE Throughput Volume at PDCP SDU Level on 5G Leg - QoS Group 09
    ...  M55349C01009    >=  0    UL_RLC_VOL_UE_TPUT_QOS_09: ThpVolUl UL UE throughput volume at RLC PDU level - QoS Group 09 (M55349C01009)
    ...  M55349C00009    >=  0    UL_RLC_TIME_UE_TPUT_QOS_09: ThpTimeUl UL UE throughput time at RLC PDU level - QoS Group 9 (M55349C00009)

    ${Third_PMC_table}   Create List
    ...  M55310C20001    >=  0    NR_RLC_PDU_DL_VOL_CA_PCELL: P-Cell Data Volume CA (SA and NSA) (M55310C20001)
    ...  M55310C20000    >=  0    NR_RLC_PDU_DL_VOL_CA_SCELL: S-Cell Data Volume CA (SA and NSA) (M55310C20000)
    ...  M55350C02001    >=  0    MAX_DL_PDCP_BURST_TPUT: Max DL PDCP Data burst throughput transmitted for the cell (M55350C02001)
    ...  M55350C04001    >=  0    MAX_DL_PDCP_BURST_TPUT_5GLEG: Max DL PDCP Data burst throughput transmitted for the cell on 5G Leg (M55350C04001)
    ...  M55350C07001    >=  0    DL_PDCP_VOL_UE_TPUT_TOT: ThpVolDl DL UE Throughput Volume at PDCP SDU Level Total (M55350C07001)
    ...  M55350C08001    >=  0    DL_PDCP_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at PDCP SDU Level (M55350C08001)

    ${Fourth_PMC_table}   Create List
    ...  M55118C02000  >=  0  RRC_RECONF_1_SCELL_DL_ATT (NSA): RRC Reconfigurations attempts for 1 SCell Addition in DL for NSA mode
    ...  M55118C04001  >=  0  UE_PSCELL_1_CONF_SCELL_UL (NSA): Number of CA UEs in the current cell configured as a PSCell, which have 1 Scell in UL
    ...  M55118C04000  >=  0  UE_PSCELL_1_CONF_SCELL_DL (NSA): Number of CA UEs in the current cell configured as a PSCell, which have 1 Scell in DL
    ...  M55118C05004  >=  0  UE_SCELL_3_CONF_SCELL_DL (NSA): Number of CA UEs in the current cell configured as a SCell, which have 3 Scell in DL
    ...  M55316C03000  >=  0  PSCELL_UE_0_ACT_SCELL_DL (NSA): P(S)Cell UEs with 0 activated SCells in DL (M55316C03000)
    ...  M55316C03002  >=  0  PSCELL_UE_2_ACT_SCELL_DL (NSA): P(S)Cell UEs with 2 activated SCells in DL (M55316C03002)
    ...  M55316C03003  >=  0  PSCELL_UE_3_ACT_SCELL_DL (NSA): P(S)Cell UEs with 3 activated SCells in DL (M55316C03003)
    ...  M55316C04000  >=  0  PSCELL_UE_0_ACT_SCELL_UL (NSA): P(S)Cell UEs with 0 activated SCells in UL (M55316C04000)
    ...  M55316C04001  >=  0  PSCELL_UE_1_ACT_SCELL_UL (NSA): P(S)Cell UEs with 1 activated SCells in UL (M55316C04001)

    ${Fifth_PMC_table}   Create List
    ...  M55118C07001  >=  0  UE_PCELL_2_CONF_SCELL_DL_SA: Sum of CA UEs in the current cell configured as PCell with 2 configured SCells in DL
    ...  M55118C07002  >=  0  UE_SCELL_2_CONF_SCELL_DL_SA: Sum of CA UEs in the current cell configured as an SCell with 2 conf SCells in DL
    ...  M55118C10005  >=  0  UE_PCELL_1_CONF_SCELL_UL_SA: Sum of CA UEs in the current cell configured as a PCell, which have 1 conf SCells in UL
    ...  M55118C10006  >=  0  UE_SCELL_1_CONF_SCELL_UL_SA: Sum of CA UEs in the current cell configured as SCell that have 1 configured SCell in UL
    ...  M55118C07003  >=  0  RRC_RECONF_ADD2DLSCELL_SUCC_SA: Successful RRC reconfigurations attempts for 2 SCells addition in DL in SA mode
    ...  M55118C07004  >=  0  RRC_RECONF_ADD2DLSCELL_ATT_SA: RRC reconfigurations attempts for 2 SCells addition in DL in SA mode (M55118C07004)

    ${Sixth_PMC_table}   Create List
    ...  M55316C14004    >=  0    UL_RLC_PDU_RX_SEC_PATH: UL RLC PDUs received over secondary path (M55316C14004)
    ...  M55118C09502    >=  0    RRC_RECONF_ADD3DLSCELL_SUCC_SA: Successful RRC reconfiguration attempts for 3 SCells addition in DL in SA mode
    ...  M55118C09503    >=  0    RRC_RECONF_ADD3DLSCELL_ATT_SA: RRC reconfiguration attempts with 3 SCells in DL in SA mode (M55118C09503)
    ...  M55316C05003    >=  0    MAX_PSCELL_UE_3_ACT_SCELL_DL: Maximum number of P(S)Cell UEs with 3 activated SCells in DL (M55316C05003)
    ...  M55316C06000    >=  0    MAX_PSCELL_UE_0_ACT_SCELL_UL: Maximum amount of P(S)Cell UEs with 0 activated SCells in UL (M55316C06000)
    ...  M55316C09000    >=  0    SCELL_ACTIVATIONS (in SCell): The number of successful SCell activations (M55316C09000)
    ...  M55316C14001    >=  0    UL_RLC_PDU_VOL_RX_PRI_PATH: UL RLC PDU volume received over primary path (M55316C14001)
    ...  M55316C14002    >=  0    UL_RLC_PDU_VOL_RX_SEC_PATH: UL RLC PDU volume received over secondary path (M55316C14002)
    ...  M55316C14003    >=  0    UL_RLC_PDU_RX_PRI_PATH: UL RLC PDUs received over primary path (M55316C14003)

    Log to console    Verify PM counter check in NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${Former_PMC_table}  pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    Log to console    Verify PM counter check in NRCELL-${PCell_id}/PLMN-PLMN/NRPMQAP-1
    Verify PM Counter Reference table    reference_table=${Former_PMC_table_2}  pm_dir=${PM_FILES}
    ...    distname_suffix=NRCELL-${PCell_id}/PLMN-PLMN/NRPMQAP-1

    Log to console    Verify PM counter check in NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${Group_09_PMC_table}  pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    Log to console    Verify PM counter check in NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${Third_PMC_table}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    Log to console    Verify PM counter check in NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${Fourth_PMC_table}    pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    Log to console    Verify PM counter check in NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${Fifth_PMC_table}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    Log to console    Verify PM counter check in NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${Sixth_PMC_table}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    # S-Cell Data (SA and NSA)
    ${NR_RLC_PDU_DL_VOL_CA_SCELL}   Create List
    ...  M55310C20000    >=  0    NR_RLC_PDU_DL_VOL_CA_SCELL: S-Cell Data Volume CA (SA and NSA) (M55310C20000)

    Log to console    S-Cell Data Volume CA (SA and NSA) PM counter under NRCELL-${2CC_SCell_id}
    Verify PM Counter Reference table
    ...    reference_table=${NR_RLC_PDU_DL_VOL_CA_SCELL}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}

    Log to console    S-Cell Data Volume CA (SA and NSA) PM counter under NRCELL-${3CC_SCell_id}
    Verify PM Counter Reference table
    ...    reference_table=${NR_RLC_PDU_DL_VOL_CA_SCELL}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}

    Log to console    ${\n}S-Cell Data Volume CA (SA and NSA) PM counter under NRCELL-${4CC_SCell_id}
    Verify PM Counter Reference table
    ...    reference_table=${NR_RLC_PDU_DL_VOL_CA_SCELL}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}

    Log to console    ${\n}Info: ${\n}Verify of Former PM Counters KW is completed.


CB010636-A Performance Counters
    [Documentation]
    ...    | CB010636-A Performance Counters | Print out for manual check.          |
    ...    | PCell_id                    | Primary Cell ID. Default is Cell 8.        |
    ...    | 2CC_SCell_id                | First Secondary cell                     |
    ...    | 3CC_SCell_id                | 2nd Secondary cell                       |
    ...    | 4CC_SCell_id                | 3rd Secondary cell                       |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8    ${2CC_SCell_id}=None    ${3CC_SCell_id}=None    ${4CC_SCell_id}=None

    Log To Console    Info: ${\n}CB010636-A Performance Counters...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    # DL RLC PDU volume transmitted
    ${RLC_PDU_VOL_TX}   Create List
    ...    M55310C02021    >=  0    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    ...    M55310C02022    >=  0    RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...    M55310C02023    >=  0    RLC_PDU_VOL_TX_SEC_SA_CA_FR2: DL RLC PDU volume transmitted over secondary path for FR2 SA CA (M55310C02023)
    ...    M55310C02024    >=  0    RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...    M55310C02025    >=  0    RLC_PDU_VOL_TX_NON_CA_NSA: DL RLC PDU volume transmitted to non-CA NSA DRBs (M55310C02025)
    ...    M55310C02026    >=  0    RLC_PDU_VOL_TX_PRI_NSA_CA: DL RLC PDU volume transmitted over primary path for NSA CA (M55310C02026)
    ...    M55310C02027    >=  0    RLC_PDU_VOL_TX_SEC_NSA_CA_FR2: DL RLC PDU volume transmitted over secondary path for FR2 NSA CA (M55310C02027)
    ...    M55310C02028    >=  0    RLC_PDU_VOL_TX_SCELL_NSA_CA: DL RLC PDU volume transmitted through SCell for NSA CA (M55310C02028)

    Log to console    ${\n}DL RLC PDU volume transmitted (RLC_PDU_VOL_TX) PM counter Under NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${RLC_PDU_VOL_TX}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    # UL RLC PDU volume received
    ${RLC_PDU_VOL_RX}   Create List
    ...    M55310C02029    >=  0    RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...    M55310C02030    >=  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    M55310C02031    >=  0    RLC_PDU_VOL_RX_SEC_SA_CA_FR2: UL RLC PDU volume received over secondary path for FR2 SA CA (M55310C02031)
    ...    M55310C02032    >=  0    RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...    M55310C02033    >=  0    RLC_PDU_VOL_RX_NON_CA_NSA: UL RLC PDU volume received from non-CA NSA DRBs (M55310C02033)
    ...    M55310C02034    >=  0    RLC_PDU_VOL_RX_PRI_NSA_CA: UL RLC PDU volume received over primary path for NSA CA (M55310C02034)
    ...    M55310C02035    >=  0    RLC_PDU_VOL_RX_SEC_NSA_CA_FR2: UL RLC PDU volume received over secondary path for FR2 NSA CA (M55310C02035)
    ...    M55310C02036    >=  0    RLC_PDU_VOL_RX_SCELL_NSA_CA: UL RLC PDU volume received through SCell for NSA CA (M55310C02036)

    Log to console    ${\n}DL RLC PDU volume transmitted (RLC_PDU_VOL_TX) PM counter Under NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${RLC_PDU_VOL_RX}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    # UL/DL RLC PDU volume transmitted over secondary path
    ${RLC_PDU_VOL_TRX_SEC}   Create List
    ...    M55349C00022    >=  0    RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA (M55349C00022)
    ...    M55349C00023    >=  0    IGNB_RLC_PDU_VOL_TX_SEC: DL RLC PDU volume transmitted over secondary path for Inter-gNB CA. (M55349C00023)
    ...    M55349C00024    >=  0    RLC_PDU_VOL_TX_SEC_NSA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 NSA CA (M55349C00024)
    ...    M55349C00025    >=  0    RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)

    Log to console    UL/DL RLC PDU volume over secondary path (RLC_PDU_VOL_TRX_SEC) PM counter Under NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${RLC_PDU_VOL_TRX_SEC}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    # RLC PDU volume through SCell
    ${RLC_PDU_VOL_TRX_SCELL_SANSA}   Create List
    ...    M55310C02024    >=  0    RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...    M55310C02028    >=  0    RLC_PDU_VOL_TX_SCELL_NSA_CA: DL RLC PDU volume transmitted through SCell for NSA CA (M55310C02028)
    ...    M55310C02032    >=  0    RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...    M55310C02036    >=  0    RLC_PDU_VOL_RX_SCELL_NSA_CA: UL RLC PDU volume received through SCell for NSA CA (M55310C02036)

    IF    '${2CC_SCell_id}'!='None'
        Log to console  ${\n}UL/DL RLC PDU volume through SCell (RLC_PDU_VOL_TRX_SCELL_SANSA) PM counter Under NRCELL-${2CC_SCell_id} (2CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${RLC_PDU_VOL_TRX_SCELL_SANSA}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}
    END

    IF    '${3CC_SCell_id}'!='None'
      Log to console    ${\n}UL/DL RLC PDU volume through SCell (RLC_PDU_VOL_TRX_SCELL_SANSA) PM counter Under NRCELL-${3CC_SCell_id} (3CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${RLC_PDU_VOL_TRX_SCELL_SANSA}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}
    END

    IF    '${4CC_SCell_id}'!='None'
      Log to console    ${\n}UL/DL RLC PDU volume through SCell (RLC_PDU_VOL_TRX_SCELL_SANSA) PM counter Under NRCELL-${4CC_SCell_id} (4CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${RLC_PDU_VOL_TRX_SCELL_SANSA}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}
    END


CB010636-A TC01 Specific Performance Counters
    [Documentation]
    ...    | CB010636-A Performance Counters | Print out for manual check.          |
    ...    | PCell_id                    | Primary Cell ID.                         |
    ...    | 2CC_SCell_id                | First Secondary cell                     |
    ...    | 3CC_SCell_id                | 2nd Secondary cell                       |
    ...    | 4CC_SCell_id                | 3rd Secondary cell                       |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8    ${2CC_SCell_id}=None    ${3CC_SCell_id}=None    ${4CC_SCell_id}=None    ${M55310C02021}=0

    Log To Console    Info: ${\n}CB010636-A Performance Counters...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${TC01_Specific}   Create List
    ...    M55310C02021    >=  ${M55310C02021}    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    # ...    abs(M55310C02021 - 760000000)    <=  76000000    RLC_PDU_VOL_TX_NON_CA_SA #Not working if M55310C02021 = 0
    ...    M55310C02022    >=  0    RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...    M55349C00022    >=  0    RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA (M55349C00022)
    ...    M55310C02024    >=  0    RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...    M55310C02029    >=  0    RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...    M55310C02030    >=  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    M55349C00025    >=  0    RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)
    ...    M55310C02032    >=  0    RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)

    Log to console    ${\n}CB010636-A TC01 Specific PM counter Under NRCELL-${PCell_id} (PCell)
    Verify PM Counter Reference table
    ...    reference_table=${TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    IF    '${2CC_SCell_id}'!='None'
        Log to console    ${\n}CB010636-A TC01 Specific PM counter Under NRCELL-${2CC_SCell_id} (2CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}
    END

    IF    '${3CC_SCell_id}'!='None'
        Log to console    ${\n}CB010636-A TC01 Specific PM counter Under NRCELL-${3CC_SCell_id} (3CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}
    END

    IF    '${4CC_SCell_id}'!='None'
        Log to console    ${\n}CB010636-A TC01 Specific PM counter Under NRCELL-${4CC_SCell_id} (4CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}
    END

    ${Legacy_TC01_Specific}   Create List
    ...  M55310C20001    >=  0    NR_RLC_PDU_DL_VOL_CA_PCELL: P-Cell Data Volume CA (SA and NSA) (M55310C20001)
    ...  M55310C20000    >=  0    NR_RLC_PDU_DL_VOL_CA_SCELL: S-Cell Data Volume CA (SA and NSA) (M55310C20000)
    ...  M55316C14001    >=  0    UL_RLC_PDU_VOL_RX_PRI_PATH: UL RLC PDU volume received over primary path (M55316C14001)
    ...  M55316C14002    >=  0    UL_RLC_PDU_VOL_RX_SEC_PATH: UL RLC PDU volume received over secondary path (M55316C14002)

    Log to console    ${\n}Legacy TC01 Specific PM counter Under NRCELL-${PCell_id} (PCell)
    Verify PM Counter Reference table
    ...    reference_table=${Legacy_TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    IF    '${2CC_SCell_id}'!='None'
        Log to console    ${\n}Legacy TC01 Specific PM counter Under NRCELL-${2CC_SCell_id} (2CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${Legacy_TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}
    END

    IF    '${3CC_SCell_id}'!='None'
        Log to console    ${\n}Legacy TC01 Specific PM counter Under NRCELL-${3CC_SCell_id} (3CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${Legacy_TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}
    END

    IF    '${4CC_SCell_id}'!='None'
        Log to console    ${\n}Legacy TC01 Specific PM counter Under NRCELL-${4CC_SCell_id} (4CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${Legacy_TC01_Specific}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}
    END


CB010636-A TC01 Compare Former
    [Documentation]
    ...    | CB010636-A Performance Counters | Compare to Former.          |
    ...    | PCell_id                    | Primary Cell ID.                         |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8

    Log To Console    Info: ${\n}CB010636-A Performance Counters...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${Compare_Former}   Create List
    ...    M55310C02022  <=  M55310C20001    RLC_PDU_VOL_TX_PRI_SA_CA == NR_RLC_PDU_DL_VOL_CA_PCELL
    ...    M55310C02024  <=  M55310C20000    RLC_PDU_VOL_TX_SCELL_SA_CA == NR_RLC_PDU_DL_VOL_CA_SCELL
    ...    M55310C02030  ==  M55316C14001    RLC_PDU_VOL_RX_PRI_SA_CA == UL_RLC_PDU_VOL_RX_PRI_PATH
    ...    M55310C02032  ==  M55316C14002    RLC_PDU_VOL_RX_SCELL_SA_CA == UL_RLC_PDU_VOL_RX_SEC_PATH

    Log to console    ${\n}TC01 Compare Former PM for NRCELL-${PCell_id} (PCell)
    Verify PM Counter Reference table
    ...    reference_table=${Compare_Former}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}


CB010636-A TC01 PM Values per Cells
    [Documentation]
    ...    | CB010636-A Performance Counters | PM Values per cells.          |

    Log To Console    Info: ${\n}CB010636-A TC01 PM Values per Cells...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${M55310C02021_Values_per_Cells}   Create List
    ...    (NRCELL-8)M55310C02021    ==  0    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    ...    (NRCELL-9)M55310C02021    ==  0    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    ...    (NRCELL-7)M55310C02021    ==  0    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    ...    (NRCELL-13)M55310C02021    >=  692000000    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    ...    (NRCELL-4)M55310C02021    ==  0    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)
    ...    (NRCELL-6)M55310C02021    ==  0    RLC_PDU_VOL_TX_NON_CA_SA: DL RLC PDU volume transmitted to non-CA SA DRBs (M55310C02021)

    Verify PM Counter Reference table
    ...    reference_table=${M55310C02021_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02022_Values_per_Cells}   Create List
    ...  (NRCELL-8)M55310C02022 + (NRCELL-9)M55310C02022  >=  16900000000   RLC_PDU_VOL_TX_PRI_SA_CA: Sum of Cells values
    ...  (NRCELL-8)M55310C02022  >=  1010000000  RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...  (NRCELL-9)M55310C02022  >=  15100000000  RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...    (NRCELL-7)M55310C02022    ==  0    RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...    (NRCELL-13)M55310C02022    ==  0    RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...    (NRCELL-4)M55310C02022    ==  0    RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)
    ...    (NRCELL-6)M55310C02022    ==  0    RLC_PDU_VOL_TX_PRI_SA_CA: DL RLC PDU volume transmitted over primary path for SA CA (M55310C02022)

    Verify PM Counter Reference table
    ...    reference_table=${M55310C02022_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55349C00022_Values_per_Cells}   Create List
    ...  (NRCELL-8)M55349C00022 + (NRCELL-9)M55349C00022  >=  40222111000  RLC_PDU_VOL_TX_SEC_SA_CA_FR1
    ...  (NRCELL-8)M55349C00022  >=  3510111000  RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA
    ...  (NRCELL-9)M55349C00022  >=  7111222000  RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA
    ...  (NRCELL-7)M55349C00022  ==  0  RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA (M55349C00022)
    ...  (NRCELL-13)M55349C00022  ==  0  RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA (M55349C00022)
    ...  (NRCELL-4)M55349C00022  ==  0  RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA (M55349C00022)
    ...  (NRCELL-6)M55349C00022  ==  0  RLC_PDU_VOL_TX_SEC_SA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 SA CA (M55349C00022)

    Verify PM Counter Reference table
    ...    reference_table=${M55349C00022_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02024_Values_per_Cells}   Create List
    ...  (NRCELL-9)M55310C02024 + (NRCELL-13)M55310C02024 + (NRCELL-4)M55310C02024  >=  34111000134  RLC_PDU_VOL_TX_SCELL_SA_CA
    ...  (NRCELL-8)M55310C02024  ==  0  RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...  (NRCELL-9)M55310C02024  >=  13310111000  RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...  (NRCELL-7)M55310C02024  >=  1220000000  RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...  (NRCELL-13)M55310C02024  >=  4410111000  RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...  (NRCELL-4)M55310C02024  >=  10111222000  RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)
    ...  (NRCELL-6)M55310C02024  >=  5800000000  RLC_PDU_VOL_TX_SCELL_SA_CA: DL RLC PDU volume transmitted through SCell for SA CA (M55310C02024)

    Verify PM Counter Reference table
    ...    reference_table=${M55310C02024_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02029_Values_per_Cells}   Create List
    ...  (NRCELL-8)M55310C02029  ==  0  RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...  (NRCELL-9)M55310C02029  >=  230111000  RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...  (NRCELL-7)M55310C02029  ==  0  RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...  (NRCELL-13)M55310C02029  >=  230111000  RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...  (NRCELL-4)M55310C02029  ==  0  RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)
    ...  (NRCELL-6)M55310C02029  ==  0  RLC_PDU_VOL_RX_NON_CA_SA: UL RLC PDU volume received from non-CA SA DRBs (M55310C02029)

    Verify PM Counter Reference table
    ...    reference_table=${M55310C02029_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02030_Values_per_Cells}   Create List
    ...  (NRCELL-8)M55310C02030  >=  530111000  RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    (NRCELL-9)M55310C02030    ==  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    (NRCELL-7)M55310C02030    ==  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    (NRCELL-13)M55310C02030    ==  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    (NRCELL-4)M55310C02030    ==  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)
    ...    (NRCELL-6)M55310C02030    ==  0    RLC_PDU_VOL_RX_PRI_SA_CA: UL RLC PDU volume received over primary path for SA CA (M55310C02030)

    Verify PM Counter Reference table
    ...    reference_table=${M55310C02030_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55349C00025_Values_per_Cells}   Create List
    ...  (NRCELL-8)M55349C00025  >=  860111000  RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA
    ...  (NRCELL-9)M55349C00025  ==  0  RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)
    ...  (NRCELL-7)M55349C00025  ==  0  RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)
    ...  (NRCELL-13)M55349C00025  ==  0  RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)
    ...  (NRCELL-4)M55349C00025  ==  0  RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)
    ...  (NRCELL-6)M55349C00025  ==  0  RLC_PDU_VOL_RX_SEC_SA_CA_FR1:UL RLC PDU volume received over secondary path for FR1 SA CA (M55349C00025)

    Run Keyword And Warn On Failure    Verify PM Counter Reference table
    ...    reference_table=${M55349C00025_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02032_Values_per_Cells}   Create List
    ...  (NRCELL-8)M55310C02032  ==  0  RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...  (NRCELL-9)M55310C02032  >=  850111000  RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...  (NRCELL-7)M55310C02032  ==  0  RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...  (NRCELL-13)M55310C02032  ==  0  RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...  (NRCELL-4)M55310C02032  ==  0  RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)
    ...  (NRCELL-6)M55310C02032  ==  0  RLC_PDU_VOL_RX_SCELL_SA_CA: UL RLC PDU volume received through SCell for SA CA (M55310C02032)

    Verify PM Counter Reference table
    ...    reference_table=${M55310C02032_Values_per_Cells}     pm_dir=${PM_FILES}


CB010636-B Performance Counters
    [Documentation]
    ...    | CB010636-A Performance Counters | Print out for manual check.          |
    ...    | PCell_id                    | Primary Cell ID.                         |
    ...    | 2CC_SCell_id                | First Secondary cell                     |
    ...    | 3CC_SCell_id                | 2nd Secondary cell                       |
    ...    | 4CC_SCell_id                | 3rd Secondary cell                       |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8    ${2CC_SCell_id}=None    ${3CC_SCell_id}=None    ${4CC_SCell_id}=None

    Log To Console    Info: ${\n}CB010636-B Performance Counters...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${CB010636-B_PM}   Create List
    ...    M55349C03002    >=  0    DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR1 (M55349C03002)
    ...    M55349C04002    >=  0    DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR1 (M55349C04002)

    #/PLMN-PLMN/NRPMQAP-1
    ${CB010636-B_PMQAP}   Create List
    ...    M55353C00002    >=  0    DL_RLC_PDU_VOL_UE_TPUT_PMQAP: ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level NRPMQAP for FR1
    ...    M55353C00003    >=  0    DL_RLC_PDU_TIME_UE_TPUT_PMQAP: ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level NRPMQAP for FR1

    Log to console    ${\n}CB010636-B PM counter Under NRCELL-${PCell_id} (PCell)
    Verify PM Counter Reference table
    ...    reference_table=${CB010636-B_PM}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}
    Verify PM Counter Reference table
    ...    reference_table=${CB010636-B_PMQAP}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}/PLMN-PLMN/NRPMQAP-1

    IF    '${2CC_SCell_id}'!='None'
        Log to console    ${\n}CB010636-B PM counter Under NRCELL-${2CC_SCell_id} (2CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${CB010636-B_PM}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}
        Verify PM Counter Reference table
        ...    reference_table=${CB010636-B_PMQAP}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${2CC_SCell_id}/PLMN-PLMN/NRPMQAP-1
    END

    IF    '${3CC_SCell_id}'!='None'
        Log to console    ${\n}CB010636-B PM counter Under NRCELL-${3CC_SCell_id} (3CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${CB010636-B_PM}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}
        Verify PM Counter Reference table
        ...    reference_table=${CB010636-B_PMQAP}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${3CC_SCell_id}/PLMN-PLMN/NRPMQAP-1
    END

    IF    '${4CC_SCell_id}'!='None'
        Log to console    ${\n}CB010636-B PM counter Under NRCELL-${4CC_SCell_id} (4CC_SCell)
        Verify PM Counter Reference table
        ...    reference_table=${CB010636-B_PM}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}
        Verify PM Counter Reference table
        ...    reference_table=${CB010636-B_PMQAP}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${4CC_SCell_id}/PLMN-PLMN/NRPMQAP-1
    END


CB010636-C Performance Counters
    [Documentation]
    ...    | CB010636-C Performance Counters | Print out for manual check.          |
    ...    | PCell_id                    | Primary Cell ID.                         |
    ...    | 2CC_SCell_id                | First Secondary cell                     |
    ...    | 3CC_SCell_id                | 2nd Secondary cell                       |
    ...    | 4CC_SCell_id                | 3rd Secondary cell                       |
    ...
    ...    *Returns* none ...
    ...
    [Arguments]       ${PCell_id}=8    ${2CC_SCell_id}=4    ${3CC_SCell_id}=9    ${4CC_SCell_id}=13

    Log To Console    Info: ${\n}CB010636-C Performance Counters...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    # ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU)
    ${DL_RLC_VOL_UE_TPUT_FR1_SA}   Create List
    ...    M55349C00026    >=  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 1CC FR1 SA CA
    ...    M55349C00027    >=  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 2CC FR1 SA CA
    ...    M55349C00028    >=  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 3CC FR1 SA CA
    ...    M55349C00029    >=  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 4CC FR1 SA CA

    Log to console    ${\n}ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU [DL_RLC_VOL_UE_TPUT_FR1_SA] PM counter Under NRCELL-${PCell_id}
    Verify PM Counter Reference table    reference_table=${DL_RLC_VOL_UE_TPUT_FR1_SA}     pm_dir=${PM_FILES}  distname_suffix=NRCELL-${PCell_id}

    Log to console    ${\n}ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU [DL_RLC_VOL_UE_TPUT_FR1_SA] PM counter Under NRCELL-${2CC_SCell_id}

    Log to console    ${\n}ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU [DL_RLC_VOL_UE_TPUT_FR1_SA] PM counter Under NRCELL-${3CC_SCell_id}

    Log to console    ${\n}ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU [DL_RLC_VOL_UE_TPUT_FR1_SA] PM counter Under NRCELL-${4CC_SCell_id}


CB010636-C PCell Counters
    [Documentation]
    ...    | CB010636-C Performance Counters | PM Values for PCell.          |

    Log To Console    Info: ${\n}CB010636-C PM Values per Cells...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    # ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU)
    ${DL_RLC_VOL_UE_TPUT_FR1_SA}   Create List
    ...    (NRCELL-8)M55349C00026    >=  20111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 1CC FR1 SA CA
    ...    (NRCELL-8)M55349C00027    >=  60111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 2CC FR1 SA CA
    ...    (NRCELL-8)M55349C00028    >=  42111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 3CC FR1 SA CA
    ...    (NRCELL-8)M55349C00029    >=  7111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 4CC FR1 SA CA
    ...    (NRCELL-8)M55349C00030    ==  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 5CC FR1 SA CA
    ...    (NRCELL-9)M55349C00026    >=  23111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 1CC FR1 SA CA
    ...    (NRCELL-9)M55349C00027    >=  24111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 2CC FR1 SA CA
    ...    (NRCELL-9)M55349C00028    >=  10111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 3CC FR1 SA CA
    ...    (NRCELL-9)M55349C00029    ==  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 4CC FR1 SA CA
    ...    (NRCELL-13)M55349C00026    >=  3111000    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 1CC FR1 SA CA
    ...    (NRCELL-13)M55349C00027    ==  0    ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU) Level for UEs with 2CC FR1 SA CA

    #ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) level for UEs with 2CC FR1 SA CA (M55349C00033)
    #[Ulm_TL389_GMC_gNB1] MRBTS-403891/NRBTS-403891/NRCELL-8/NHRRC/DL_RLC_TIM_UE_TPUT_FR1_SA_1CC
    ${DL_RLC_TIM_UE_TPUT_FR1_SA}   Create List
    ...  (NRCELL-8)M55349C00032  >=  44000  DL_RLC_TIM_UE_TPUT_FR1_SA_1CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 1CC FR1 SA CA
    ...  (NRCELL-8)M55349C00033  >=  63000  DL_RLC_TIM_UE_TPUT_FR1_SA_2CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 2CC FR1 SA CA
    ...  (NRCELL-8)M55349C00034  >=  29000  DL_RLC_TIM_UE_TPUT_FR1_SA_3CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 3CC FR1 SA CA
    ...  (NRCELL-8)M55349C00035  >=  5000  DL_RLC_TIM_UE_TPUT_FR1_SA_4CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 4CC FR1 SA CA
    ...  (NRCELL-8)M55349C00036  ==  0  DL_RLC_TIM_UE_TPUT_FR1_SA_4CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 5CC FR1 SA CA
    ...  (NRCELL-9)M55349C00032  >=  99000  DL_RLC_TIM_UE_TPUT_FR1_SA_1CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 1CC FR1 SA CA
    ...  (NRCELL-9)M55349C00033  >=  99000  DL_RLC_TIM_UE_TPUT_FR1_SA_2CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 2CC FR1 SA CA
    ...  (NRCELL-9)M55349C00034  >=  30000  DL_RLC_TIM_UE_TPUT_FR1_SA_3CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 3CC FR1 SA CA
    ...  (NRCELL-9)M55349C00035  ==  0  DL_RLC_TIM_UE_TPUT_FR1_SA_4CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 4CC FR1 SA CA
    ...  (NRCELL-13)M55349C00032  >=  59000  DL_RLC_TIM_UE_TPUT_FR1_SA_1CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 1CC FR1 SA CA
    ...  (NRCELL-13)M55349C00033  ==  0  DL_RLC_TIM_UE_TPUT_FR1_SA_2CC:ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU) 2CC FR1 SA CA

    #ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR1 (M55349C03002) DL_RLC_PDU_VOL_UE_TPUT
    #ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR1 (M55349C04002) DL_RLC_PDU_TIME_UE_TPUT
    ${DL_RLC_PDU_TIME_and_VOL_UE_TPUT}   Create List
    ...  (NRCELL-8)M55349C04002  >=  0  DL_RLC_PDU_TIME_UE_TPUT:ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR1
    ...  (NRCELL-8)M55349C03002  >=  0  DL_RLC_PDU_VOL_UE_TPUT:ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR1
    ...  (NRCELL-9)M55349C04002  >=  0  DL_RLC_PDU_TIME_UE_TPUT:ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR1
    ...  (NRCELL-9)M55349C03002  >=  0  DL_RLC_PDU_VOL_UE_TPUT:ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR1
    ...  (NRCELL-13)M55349C04002  >=  0  DL_RLC_PDU_TIME_UE_TPUT:ThpTimeDl DL UE throughput time at RLC PDU (MAC SDU) level for FR1
    ...  (NRCELL-13)M55349C03002  >=  0  DL_RLC_PDU_VOL_UE_TPUT:ThpVolDl DL UE throughput volume at RLC PDU (MAC SDU) level for FR1
    ...  (NRCELL-13)M55349C04002  ==  (NRCELL-13)M55349C00032  DL_RLC_PDU_TIME_UE_TPUT==DL_RLC_TIM_UE_TPUT_FR1_SA_1CC

    Log to console    ${\n}ThpVolDl DL nonGBR UE Throughput Volume at RLC PDU (MAC SDU)
    Verify PM Counter Reference table    reference_table=${DL_RLC_VOL_UE_TPUT_FR1_SA}     pm_dir=${PM_FILES}

    Log to console    ${\n}ThpTimeDl DL nonGBR UE throughput time at RLC PDU (MAC SDU)
    Verify PM Counter Reference table    reference_table=${DL_RLC_TIM_UE_TPUT_FR1_SA}     pm_dir=${PM_FILES}

    Log to console    ${\n}ThpTimeDl DL UE throughput time AND volume at RLC PDU (MAC SDU) level for FR1
    Verify PM Counter Reference table    reference_table=${DL_RLC_PDU_TIME_and_VOL_UE_TPUT}     pm_dir=${PM_FILES}


Verify Pcell and Scell Addition
    [Arguments]    ${physCellId_pcell}  ${physCellId_scell}  ${tcp_file}

    Log to console    ${\n}Starting TC Verification
    Log to Console    ${\n}Verify TC checks on gNB1

    Check Pcell Addition   tcp_file=${tcp_file}  physCellId= ${physCellId_pcell}    packet_filter=x2ap.procedureCode == 27
    Check Scell Addition  tcp_file=${tcp_file}  physCellId=${physCellId_scell}    packet_filter=f1ap.procedureCode == 12


Check Pcell Addition
    [Documentation]
    ...    | From Feature CB007219                                                            |
    ...    | Checks Pcell addition                                                            |
    ...    | tcp_file                          | Wireshark of the corresponding UE            |
    ...    | physCellId                        | The physical cell ID of the Pcell            |
    ...    | packet_filter                     | Wireshark filter                             |
    ...
    ...    *Returns* none ...
    [Arguments]     ${physCellId}  ${tcp_file}  ${packet_filter}=f1ap.procedureCode ==12

    ${output}    ute_tshark.read pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${PcellAdd_elem}    Get elements    ${output}    .//field[@name='nr-rrc.spCellConfigCommon_element']//field[@name='nr-rrc.physCellId']
    Should not be empty  ${PcellAdd_elem}

    Log to Console   The PCell is:
    FOR  ${i}   IN   @{PcellAdd_elem}
         ${showname}     Get element attribute    ${i}    showname
         Log to Console   PCell ${showname}
         ${physCellId}=    Convert To String    ${physCellId}
         Should Contain Any  ${showname}  ${physCellId}  msg=Wrong physCellId
    END


Check Scell Addition
    [Documentation]
    ...    | From Feature CB007219             |                                              |
    ...    | Checks Scell addition             |                                              |
    ...    | tcp_file                          | Wireshark of the corresponding UE            |
    ...    | physCellId                        | List of the physical cell IDs of the Scells  |
    ...    | packet_filter                     | Wireshark filter                             |
    ...    *Returns* none ...
    [Arguments]    ${tcp_file}  ${physCellId}  ${packet_filter}=f1ap.procedureCode ==7

    ${found_scells}  Create List
    ${output}       ute_tshark.read pcap    packet_filter=${packet_filter}  output_type=pdml  pcap_file_path=${tcp_file}
    ${cell_type}    Evaluate     type($physCellId).__name__
    ${physCellId}   IF  "list" in "${cell_type}"  set variable  ${physCellId}
    ...             ELSE   split string  ${physCellId}  ,
    sort list  ${physCellId}
    Log to console  ${\n}arguments: phycellid: ${physCellId}
    ${length_scell}  Get Length  ${physCellId}
    ${ScellAdd}      Get Element count  ${output}    .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    should be true  ${ScellAdd} >= ${length_scell}
    ${ScellAdd_elem}   Get elements  ${output}  .//field[@name='nr-rrc.sCellToAddModList']//field[@name='nr-rrc.physCellId']
    ${is_empty}    Run Keyword And Return Status    Should Be Empty    ${physCellId}
    IF  ${is_empty}
    ...    Should Be Empty    ${ScellAdd_elem}
    ...    ELSE
    ...    Should Not Be Empty    ${ScellAdd_elem}
    Log to Console   Checking SCell addition
    FOR  ${i}   IN   @{ScellAdd_elem}
    ${value}    Get element attribute    ${i}    show
    Log to Console  found scell: ${value}
    ${value}=    Convert To Integer    ${value}
    append to list  ${found_scells}  ${value}
    END
    ${unique_list}  remove duplicates  ${found_scells}
    sort list  ${unique_list}
    Lists should be equal    ${physCellId}  ${unique_list}


CB010636-A TC04 PM Values per Cells
    [Documentation]
    ...    | CB010636-A Performance Counters | PM Values per cells.          |

    Log To Console    Info: ${\n}CB010636-A TC04 PM Values per Cells...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${M55310C02025_Values_per_Cells}   Create List
    ...    (NRCELL-9)M55310C02025   ==  0   RLC_PDU_VOL_TX_NON_CA_NSA: DL RLC PDU volume transmitted to non-CA NSA DRBs (M55310C02025)
    ...    (NRCELL-6)M55310C02025   >   75000000   RLC_PDU_VOL_TX_NON_CA_NSA: DL RLC PDU volume transmitted to non-CA NSA DRBs (M55310C02025)

    Verify PM Counter Reference table    reference_table=${M55310C02025_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02026_Values_per_Cells}   Create List
    ...    (NRCELL-9)M55310C02026   >=  38619680913   RLC_PDU_VOL_TX_PRI_NSA_CA: DL RLC PDU volume transmitted over primary path for NSA CA
    ...    (NRCELL-6)M55310C02026   ==  0             RLC_PDU_VOL_TX_PRI_NSA_CA: DL RLC PDU volume transmitted over primary path for NSA CA

    Verify PM Counter Reference table    reference_table=${M55310C02026_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02028_Values_per_Cells}   Create List
    ...    (NRCELL-1)M55310C02028   >=  10000111000   RLC_PDU_VOL_TX_SEC_NSA_CA_FR1: DL RLC PDU volume transmitted through SCell for NSA CA

    Verify PM Counter Reference table   reference_table=${M55310C02028_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02033_Values_per_Cells}   Create List
    ...    (NRCELL-9)M55310C02033   >=  1384961688   RLC_PDU_VOL_RX_NON_CA_NSA: UL RLC PDU volume received from non-CA NSA DRBs (M55310C02033)
    ...    (NRCELL-6)M55310C02033   >=  347618019    RLC_PDU_VOL_RX_NON_CA_NSA: UL RLC PDU volume received from non-CA NSA DRBs (M55310C02033)
    ...    (NRCELL-7)M55310C02033   ==  0            RLC_PDU_VOL_RX_NON_CA_NSA: UL RLC PDU volume received from non-CA NSA DRBs (M55310C02033)

    Verify PM Counter Reference table    reference_table=${M55310C02033_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02034_Values_per_Cells}   Create List
    ...    (NRCELL-9)M55310C02034   ==  0   RLC_PDU_VOL_RX_PRI_NSA_CA: UL RLC PDU volume received over primary path for NSA CA (M55310C02034)
    ...    (NRCELL-6)M55310C02034   ==  0   RLC_PDU_VOL_RX_PRI_NSA_CA: UL RLC PDU volume received over primary path for NSA CA (M55310C02034)

    Verify PM Counter Reference table    reference_table=${M55310C02034_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55310C02036_Values_per_Cells}   Create List
    ...    (NRCELL-9)M55310C02036   ==  0   RLC_PDU_VOL_RX_SCELL_NSA_CA: UL RLC PDU volume received through SCell for NSA CA (M55310C02036)
    ...    (NRCELL-6)M55310C02036   ==  0   RLC_PDU_VOL_RX_SCELL_NSA_CA: UL RLC PDU volume received through SCell for NSA CA (M55310C02036)

    Verify PM Counter Reference table    reference_table=${M55310C02036_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55349C00024_Values_per_Cells}   Create List
    ...  (NRCELL-9)M55349C00024   >=  10500000000    RLC_PDU_VOL_TX_SEC_NSA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 NSA CA
    ...  (NRCELL-6)M55349C00024   ==  0    RLC_PDU_VOL_TX_SEC_NSA_CA_FR1: DL RLC PDU volume transmitted over secondary path for FR1 NSA CA
    ...  (NRCELL-1)M55310C02028 - (NRCELL-9)M55349C00024  <=  10000000    RLC_PDU_VOL_TX_SEC_NSA_CA_FR1 minus RLC_PDU_VOL_TX_SEC_NSA_CA_FR1

    Verify PM Counter Reference table    reference_table=${M55349C00024_Values_per_Cells}     pm_dir=${PM_FILES}

    ${bts_release}=    Get gNB SW Branch    gnb_id=${0}
    Log To Console    ${\n}Info: installed SW is on branch: ${bts_release}
    Log To Console    ${\n}Info: CNI-126924 new counters M55349C00083 + M55349C00084 are implemented on trunk and >= 25R2

    IF   $bts_release not in ['SBTS25R1', 'SBTS24R3']
        Log To Console    ${\n}Info: ${\n}CB010636-A TC04 PM Values Cell-9 and Cell-6 --- CNI-126924 new counters M55349C00083 + M55349C00084 check
        Log To Console    Info: UE_1 attached to NRCELL-9 has SCell(s) activated
        Log To Console    Info: UE_3 attached to NRCELL-6 does NOT have SCell(s) activated{\n}

        ${M55349C00083_Values_per_Cells}   Create List
        ...    (NRCELL-9)M55349C00083   ==  0   RLC_PDU_VOL_TX_CA_NOT_ACT_NSA: DL RLC PDU vol. trans. to NSA DRBs that don't have SCell(s) act.
        ...    (NRCELL-6)M55349C00083   >   1   RLC_PDU_VOL_TX_CA_NOT_ACT_NSA: DL RLC PDU vol. trans. to NSA DRBs that don't have SCell(s) act.
        Verify PM Counter Reference table    reference_table=${M55349C00083_Values_per_Cells}     pm_dir=${PM_FILES}

        ${M55349C00084_Values_per_Cells}   Create List
        ...    (NRCELL-9)M55349C00084   >   1   RLC_PDU_VOL_TX_PRI_NSA_CA_ACT: DL RLC PDU vol. trans. over prim. path to NSA DRBs with SCell(s) act.
        ...    (NRCELL-6)M55349C00084   ==  0   RLC_PDU_VOL_TX_PRI_NSA_CA_ACT: DL RLC PDU vol. trans. over prim. path to NSA DRBs with SCell(s) act.
        Verify PM Counter Reference table    reference_table=${M55349C00084_Values_per_Cells}     pm_dir=${PM_FILES}
    END

CB010636-B TC12 PM Values per Cells
    [Documentation]
    ...    | CB010636-B Performance Counters | PM Values per cells.          |

    Log To Console    Info: ${\n}CB010636-B TC12 PM Values per Cells...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${M55349C0X00X_Values_per_Cells}   Create List
    ...    (NRCELL-6)M55349C03002   >=  10000  DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level (M55349C03002)
    ...    (NRCELL-6)M55349C04002   >=  1000   DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level (M55349C04002)

   Verify PM Counter Reference table    reference_table=${M55349C0X00X_Values_per_Cells}     pm_dir=${PM_FILES}

   Log to console    Verify PM counter check in NRCELL-9/PLMN-PLMN/NRPMQAP-1

    ${M55353C0000X_Values_per_Cells}   Create List
    ...  (NRCELL-9/PLMN-PLMN/NRPMQAP-1)M55353C00002  >=  0  DL_RLC_PDU_VOL_UE_TPUT_PMQAP:ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level
    ...  (NRCELL-9/PLMN-PLMN/NRPMQAP-1)M55353C00003  >=  0  DL_RLC_PDU_TIME_UE_TPUT_PMQAP: hpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level

    Verify PM Counter Reference table    reference_table=${M55353C0000X_Values_per_Cells}     pm_dir=${PM_FILES}

    ${M55309C0000X_Values_per_Cells}   Create List
    ...    (NRCELL-1)M55309C00002    >=  60000000   DL_MAC_SDU_VOL_UE_TPUT :ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level NRPMQAP
    ...    (NRCELL-1)M55309C00003    >=  200000   DL_MAC_SDU_TIME_UE_TPUT : hpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level NRPMQAP
    ...    (NRCELL-6)M55309C00002    >=  50300000   DL_MAC_SDU_VOL_UE_TPUT :ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level NRPMQAP
    ...    (NRCELL-6)M55309C00003    >=  20000   DL_MAC_SDU_TIME_UE_TPUT : hpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level NRPMQAP
    ...    (NRCELL-9)M55309C00002    >=  305700000   DL_MAC_SDU_VOL_UE_TPUT :ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level NRPMQAP
    ...    (NRCELL-9)M55309C00003    >=  20000   DL_MAC_SDU_TIME_UE_TPUT : hpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level NRPMQAP

   Verify PM Counter Reference table    reference_table=${M55309C0000X_Values_per_Cells}     pm_dir=${PM_FILES}


CB010636-D TC23 PM Values per Cells
    [Documentation]
    ...    | CB010636-D Performance Counters | PM Values per cells.         |

    Log To Console    Info: ${\n}CB010636-D TC23 PM Values per Cells...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${M55349C0X00X_Values_per_Cells}   Create List
    ...    (NRCELL-4)M55349C03002  >=  0   DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level (M55349C03002)
    ...    (NRCELL-4)M55349C04002  >=  0   DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level (M55349C04002)
    ...    (NRCELL-4)M55349C00046  >=  0   DL_RLC_PDU_UE_TPUT_DENOM_FR1: Denominator for calculation of DL RLC PDU (MAC SDU) level UE throughput
    ...    (NRCELL-4)M55349C03002 / (NRCELL-4)M55349C00046  >=  1    UE Throughput per Mhz BW
    ...    (NRCELL-4)M55349C03002 / (NRCELL-4)M55349C00046  <=  14    UE Throughput per Mhz BW

   Verify PM Counter Reference table    reference_table=${M55349C0X00X_Values_per_Cells}     pm_dir=${PM_FILES}


CB010636-D TC24 PM Values per Cells
    [Documentation]
    ...    | CB010636-D Performance Counters | PM Values per cells.         |

    Log To Console    Info: ${\n}CB010636-D TC24 PM Values per Cells...
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    CB009267_Verification.Wait for PMcounters and Collect the PM files

    ${M55349C0X00X_Values_per_Cells}   Create List
    ...    (NRCELL-9)M55349C03002  >=  0   DL_RLC_PDU_VOL_UE_TPUT: ThpVolDl DL UE Throughput Volume at RLC PDU (MAC SDU) Level (M55349C03002)
    ...    (NRCELL-9)M55349C04002  >=  0   DL_RLC_PDU_TIME_UE_TPUT: ThpTimeDl DL UE Throughput Time at RLC PDU (MAC SDU) Level (M55349C04002)
    ...    (NRCELL-9)M55349C00046  >=  0   DL_RLC_PDU_UE_TPUT_DENOM_FR1: Denominator for calculation of DL RLC PDU (MAC SDU) level UE throughput
    ...    (NRCELL-9)M55349C03002 / (NRCELL-9)M55349C00046  >=  1    UE Throughput per Mhz BW
    ...    (NRCELL-9)M55349C03002 / (NRCELL-9)M55349C00046  <=  16    UE Throughput per Mhz BW

   Verify PM Counter Reference table    reference_table=${M55349C0X00X_Values_per_Cells}     pm_dir=${PM_FILES}
