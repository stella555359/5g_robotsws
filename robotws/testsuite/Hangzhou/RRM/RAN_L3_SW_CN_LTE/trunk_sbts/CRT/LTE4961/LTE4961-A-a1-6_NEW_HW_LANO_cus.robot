*** Settings ***
Documentation
...      INTRODUCTION:  This feature removes the concept of CA pool ID (by introducing a new CRNTI management algorithm)
...                    so that there is no need for CA pools planning by the Operator. This enhancement covers both downlink and uplink CA,
...                     keeping the applicability rules determined by existing features. It applies to intra-eNode B, inter-eNode B (SRIO based)
...                     and inter-site (X2-tunnel based) CA scenarios. New C-RNTI management is applicable to both CA and non-CA UEs.
...
...               TEST SET NAME: LTE4961-A-a1-6: Stepwise SCell addition and CRNTI check failure
...
...               TESTING SPLIT: LTE4961-A-a1-6: Stepwise SCell addition and CRNTI check failure
...               SAFe stories covered:
...               - RRM LTE4961 #02 C-RNTI handling during SCell addition (intra-C-RNTI pool case) for step-wise SCell addition only
...
...               *REQUIREMENTS COVERAGE:
...               *REQUIREMENTS IN SCOPE:
...               LTE_UP_16917
...               *REQUIREMENTS OUT OF SCOPE: NA
...               *NON-REQUIREMENTS-BASED TESTS: NA
...
...               *TEST ENVIRONMENT:
...               *ENVIRONMENT ELEMENTS: 1 x Airscale + WTS(FSMF based IPHY)
...               *TEST CONFIGURATIONS: AHFB, AHIB
...
...               *GENERIC NOTES FOR ALL THE TEST INSTANCES: BB Pooling enabled, LAA, CPRI, DL CA
...
...               *TEST INSTANCE SPECIFIC NOTES: NA
...
...               REFERENCES: CFAM LTE4961
...
...               *TERMS AND ABBREVIATIONS:
...               CA - Carrier Aggregation
...               CC - Compononet Carrier (PCell + Scells)
...               LAA - Licensed Assisted Access
...               IODT - Inter-operability Device Testing
...
...               HISTORY:
...               [22.04.2019] - Created TC
...               [23.04.2019] - Approved by (Stasielak Marek, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-2343)
...               [23.04.2019] - Review closed

Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LANO_CUS
...               owner-kang.xiang    team-SG4    FEATURE_LTE4961
Resource          ../../../resources/DevHZ5_resource.robot


*** Variables ***
#${TRromActFlexCaMgmt}=    0x001200E5=1
${TRromListCrntiCellMaxSize}    0x001200E7=2
${TRromCrntiPoolSize}    0x001200E9=2
${remove_hwf}     0x190030=0
@{PARAMS_IN_SWCONFIG}    ${remove_hwf}    ${TRromListCrntiCellMaxSize}   ${TRromCrntiPoolSize}


*** Test Cases ***
LTE4961-A-a1-6_Intra_eNB_HO_with_stepwise_scell_addition_and_crnti_conflict
    [Tags]
    [Documentation]    DESCRIPTION:    # limit number of CRNTIs randomly drawn for each Cell    # limit CRNTIs range for pool
    ...    == Description ==
    ...    The porpose of this test is to check C-RNTI assignment to the UE during
    ...    step-wise SCell addition for the inter-C-RNTI pool intra eNB case.
    ...
    ...    After UE_2 handover to Cell 11, C-RNTI pool is exhausted on Cell 11 and Cell 13
    ...    and addition of Cell 13 as SCell is rejected due to C-RNTI conflict.
    ...
    ...    To test raCrntiReuseT timer UE_2 detach is performed and reattach before timer expiration.
    ...    MAC layer should assign to UE_2 C-RNTI value from outside of C-RNTI pool limited by RnD flag.
    ...
    ...    Next step is to check stepwise SCell addition with exhaustion of the pool
    ...    on Cell 13 with Cell 13 rejection as SCell because of CRNTI conflict
    ...    and Cell 11 addition as SCell instead.
    ...
    ...    == Precondition ==
    ...    LTE4961 activated: TRromActFlexCaMgmt (R&D: 0x001200E5) = 1
    ...    LNBTS-1::raCrntiReuseT = 20s (in vendor file)
    ...
    ...    - LNBTS-1.actDLCAggr = true
    ...    - LNCEL-1.maxNumSCell = 1
    ...    - LNBTS.actAdvStepwiseScellAdd = off
    ...    - LNBTS_FDD.numTxWithHighNonGbr = 1
    ...    - LNBTS.sCellActivationMethod = nonGBRBufferBasedStepWise
    ...    - CAREL objects under LNCEL_11 to LNCEL [13] is created
    ...    - CAREL objects under LNCEL_12 to LNCEL [11] and LNCEL [13] is created
    ...    scellPrio prefer LNCEL_13 as SCell
    ...
    ...    == UE configuration: ==
    ...    UE_1, UE_2, UE_3 with 2CC capability
    ...
    ...    CRNTI pool restrictions:
    ...          TRromListCrntiCellMaxSize (R&D: 0x001200E7) = 2  # limit number of CRNTIs randomly drawn for each Cell
    ...          TRromCrntiPoolSize (R&D: 0x001200E9) = 2  # limit CRNTIs range for pool
    ...
    ...    == Postcondition ==
    ...    UE_1 is CA configured with Cell 13 as SCell
    ...    C-RNTI conflict is met for UE_2 after handover and Cell 13 is not added as Scell
    ...    C-RNTI conflict is met for UE_2 after reattach and Cell 11 is added as Scell instead of Cell 13
    ...
    ...    TESTING TOOLS: Real eNB + IPHY + EPC simulator, EMSSIM, UTE
    ...
    ...    TEST ENVIRONMENT:
    ...    HARDWARE ID: AHFB, AHIB
    ...
    ...    *REQUIREMENTS COVERAGE:
    ...    *REQUIREMENTS IN SCOPE: LTE_UP_16917
    ...    *BACKLOG ID:
    ...
    ...    REQUIRED LOGS: Snapshot, IM, syslog, EPC logs
    ...
    ...    CONTACTS: nelsandro.sampaio@nokia.com
    ...
    ...    REFERENCES: CFAM LTE4961
    ...
    ...    HISTORY:
    ...    [22.04.2019] - Created TC
    ...    [23.04.2019] - Approved by (Stasielak Marek, https://fisheye3.int.net.nokia.com/cru/ROBOTLTE-2343)
    ...    [23.04.2019] - Review closed

    CRNTIs on Cells should be assigned to CRNTI Pool    cell_id=11    crnti_pool_id=1
    CRNTIs on Cells should be assigned to CRNTI Pool    cell_id=12    crnti_pool_id=2
    CRNTIs on Cells should be assigned to CRNTI Pool    cell_id=13    crnti_pool_id=3
    Attach UE1 with 2CC capabilities on eNB-1 Cell_11
    UE1 is assigned CRNTI from CRNTI list for Cell_11
    Start DL traffic 150 Mbps on bearer with QCI9 for UE_1 and expect Cell 13 addition or rejection
    Verify that Cell 13 was added as SCell for UE_1
    # The pool on cell 13 will be exhausted after attach
    Attach UE3 with 2CC capabilities on eNB-1 Cell_13
    UE3 is assigned CRNTI from CRNTI list for Cell_13
    # The pool on cell 11 will be exhausted after handover
    Attach UE2 with 2CC capabilities on eNB-1 Cell_12
    UE2 is assigned CRNTI from CRNTI list for Cell_12
    eNB performs UE_2 intra eNB HO from Cell 12 to Cell 11
    UE2 is assigned CRNTI from CRNTI list for Cell_11
    Start DL traffic 150 Mbps on bearer with QCI9 for UE_2 and expect Cell 13 addition or rejection
    Verify that Cell 13 is rejected as SCell because of CRNTI conflict for UE1
    Detach UE_2
    #    CrntiReuseT for UE_2 CRNTI is started on Cell 11
    Verify that reattach of UE2 on Cell_11 assigns random C-RNTI out of list because of pool exhaustion
    Detach UE_1
    Detach UE_2
    Detach UE_3
    Wait untill raCrntiReuseT expires and allows to reuse CRNTI from pool list on Cells [11,12,13]
    Attach UE1 with 2CC capabilities on eNB-1 Cell_13
    Attach UE3 with 2CC capabilities on eNB-1 Cell_13
    Attach UE2 with 2CC capabilities on eNB-1 Cell_12
    Start DL traffic 150 Mbps on bearer with QCI9 for UE_2 and expect Cell 11 addition or rejection
    Verify that Cell 13 is rejected as SCell because of CRNTI conflict and Cell 11 is added as SCell for UE_2


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=AHFB_2_CELLS_AHIB_1_CELL_LANO
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on
    Execute Egate Command    trace_sim on mme=1 protocol=s1

CRNTIs on Cells should be assigned to CRNTI Pool
    [Arguments]    ${cell_id}    ${crnti_pool_id}
    ${pool_list}    Get Crnti In Cell    ${cell_id}
    ${pool_list}=    Evaluate    sorted(${pool_list})
    ${pool_set}=     Evaluate    set(${pool_list})
    ${pool_set}=     Evaluate    sorted(list(${pool_set}))
    Should Be True    ${pool_list} == ${pool_set}
    Set Test Variable    ${cell_${cell_id}_crnti_pool_id_${crnti_pool_id}}    ${pool_list}

Attach UE with 2CC capabilities on eNB-1 Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Uex Command    ue_param id=${ue_id} supported_bands=2,64 extended_supported_bands=64:66 ca_supported_bands=2:a:a|2:a:a+2::a|2:a:a+64::a
    Expect message flow
    ...    UE_${ue_id}:RRC_UECapabilityInformation
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=UE_ATTACH    overall_timeout=10
    Execute Uex Command    ue_attach id=${ue_id} cell=${cell_id}
    Flow occurred as expected    alias=UE_ATTACH

Attach UE1 with 2CC capabilities on eNB-1 Cell_11
    Attach UE with 2CC capabilities on eNB-1 Cell    ue_id=1    cell_id=11

Attach UE3 with 2CC capabilities on eNB-1 Cell_13
    Attach UE with 2CC capabilities on eNB-1 Cell    ue_id=3    cell_id=13

Attach UE2 with 2CC capabilities on eNB-1 Cell_12
    Attach UE with 2CC capabilities on eNB-1 Cell    ue_id=2    cell_id=12

Attach UE1 with 2CC capabilities on eNB-1 Cell_13
    Attach UE with 2CC capabilities on eNB-1 Cell    ue_id=1    cell_id=13

UE is assigned CRNTI from CRNTI list for Cell
    [Arguments]    ${ue_id}    ${cell_id}    ${crnti_pool_id}
    ${ue_info}    Execute UEx Command    get_ue_info id=${ue_id}
    ${crnti_id}=      Convert To String     ${ue_info["crnti"]}
    log to console    ${crnti_id}
    List Should Contain Value    ${cell_${cell_id}_crnti_pool_id_${crnti_pool_id}}    ${crnti_id}

UE1 is assigned CRNTI from CRNTI list for Cell_11
    UE is assigned CRNTI from CRNTI list for Cell    ue_id=1    cell_id=11    crnti_pool_id=1

UE3 is assigned CRNTI from CRNTI list for Cell_13
    UE is assigned CRNTI from CRNTI list for Cell    ue_id=3    cell_id=13    crnti_pool_id=3

UE2 is assigned CRNTI from CRNTI list for Cell_12
    UE is assigned CRNTI from CRNTI list for Cell    ue_id=2    cell_id=12    crnti_pool_id=2

UE2 is assigned CRNTI from CRNTI list for Cell_11
    UE is assigned CRNTI from CRNTI list for Cell    ue_id=2    cell_id=11    crnti_pool_id=1

Start DL traffic 150 Mbps on bearer with QCI9 for UE_${ue_id:\d+} and expect Cell ${cell_id:\d+} addition or rejection
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (sCellToAddModList-r10 contains (physCellId-r10 eq ${cell_id}))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=SCELL_ADDITION    overall_timeout=40
    Execute Uex Command    trf_data_start ue=${ue_id} qci=9 dir=dl Mbps=150 protocol=udp

Verify that Cell ${cell_id:\d+} was added as SCell for UE_${ue_id:\d+}
    Flow occurred as expected    alias=SCELL_ADDITION

eNB performs UE_${ue_id:\d+} intra eNB HO from Cell 12 to Cell ${cell_id:\d+}
    Expect message flow
    ...    UE_${ue_id}:RRC_MeasurementReport
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ((targetPhysCellId eq ${cell_id}) and (dl-CarrierFreq eq 800))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=UE_HANDOVER_COMPLETE    overall_timeout=10
    Execute Uex Command     ue_ho id=${ue_id} enb=1 cell=${cell_id}
    Flow occurred as expected    alias=UE_HANDOVER_COMPLETE

Verify that Cell 13 is rejected as SCell because of CRNTI conflict for UE1
    Flow Not Occurred For Message    alias=SCELL_ADDITION

Detach UE_${ue_id:\d+}
    Execute Uex Command  ue_detach id=${ue_id}

Verify that reattach of UE2 on Cell_11 assigns random C-RNTI out of list because of pool exhaustion
    Attach UE with 2CC capabilities on eNB-1 Cell    ue_id=2    cell_id=11
    UE2 is assigned Random CRNTI not assigned to any CRNTI list

UE2 is assigned Random CRNTI not assigned to any CRNTI list
    ${ue_info}    Execute UEx Command    get_ue_info id=2
    ${crnti_id}=      Convert To String     ${ue_info["crnti"]}
    log to console    ${crnti_id}
    List Should Not Contain Value    ${cell_11_crnti_pool_id_1}    ${crnti_id}
    List Should Not Contain Value    ${cell_12_crnti_pool_id_2}    ${crnti_id}
    List Should Not Contain Value    ${cell_13_crnti_pool_id_3}    ${crnti_id}

Wait untill raCrntiReuseT expires and allows to reuse CRNTI from pool list on Cells [${cells_id}]
    #    CrntiReuseT for UE_2 CRNTI ends on Cell 11
    Sleep    20

Verify that Cell 13 is rejected as SCell because of CRNTI conflict and Cell 11 is added as SCell for UE_2
    Verify that Cell 11 was added as SCell for UE_2

