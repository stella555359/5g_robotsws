*** Settings ***
Documentation
...    | Author:        | Michele, Ulm SQD64                          |
...    | Contact:       | I_PZ_ULM_SQD_64@internal.nsn.com            |
...    | Description:   | Verification Keywords for CB009267          |

Resource    ../../../resources/Common/pmcounters.robot


*** Keywords ***
Wait for PMcounters and Collect the PM files
    [Documentation]
    ...    | Arguments:    gNB_ID               |  ${gnb_id}=0                               |
    ...    | Data Transfer is already ongoing   | than we can wait for the PM....            |

    [Arguments]    ${gnb_id}=0

    Log To Console    ${\n}"PMcounters: Wait next Measurement Period Starts."
    pmcounters.Wait until the next Measurement Period starts    gnb_id=${gnb_id}

    Log To Console    ${\n}"PMcounters: Wait next Measurement Period Stops."
    pmcounters.Wait until the current Measurement Period stops    gnb_id=${gnb_id}

    ${PM_FILES}=    Collect PM Counter
    Set Test Variable    ${PM_FILES}


Verify CB009267-A TC04 PM Values per Cells
    [Documentation]
    ...    |  CB009267-A TC04 Performance Counters PM Values per cells.         |
    ...    |  the variables ${PCELL_UE_1_P2S} and ${S_CELL_UE_1_S2P} is set as test variables in the preconditions part

    ${CB009267-A_TC04_Values_per_Cells}   Create List
    ...  (NRCELL-${PCELL_UE_1_P2S})M55138C03512  ==  1   GNB_DL_SCELL_3_ADMI_REQ_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55138C03519  ==  1   GNB_DL_SCELL_3_ADMI_SUCC_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55139C05504  ==  1   GNB_DU_DL_SCELL_3_ADMI_REQ_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55139C05511  ==  1   GNB_DU_DL_SCELL_3_ADMI_SUCC_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11053  ==  1   GNB_DL_SCELL_3_CONFIG_REQ_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11063  ==  1   GNB_DL_SCELL_3_CONFIG_SUCC_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55139C05516  ==  1   GNB_DU_UL_SCELL_1_ADMI_REQ_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55139C05519  ==  1   GNB_DU_UL_SCELL_1_ADMI_SUCC_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55138C03524  ==  1   GNB_UL_SCELL_1_ADMI_REQ_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55138C03527  ==  1   GNB_UL_SCELL_1_ADMI_SUCC_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11058  ==  1   GNB_UL_SCELL_1_CONFIG_REQ_SA: Number of
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11068  ==  1   GNB_UL_SCELL_1_CONFIG_SUCC_SA: Number of

    ...  (NRCELL-${S_CELL_UE_1_S2P})M55138C03511  ==  1   GNB_DL_SCELL_2_ADMI_REQ_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55138C03518  ==  1   GNB_DL_SCELL_2_ADMI_SUCC_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55139C05503  ==  1   GNB_DU_DL_SCELL_2_ADMI_REQ_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55139C05510  ==  1   GNB_DU_DL_SCELL_2_ADMI_SUCC_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55118C11052  ==  1   GNB_DL_SCELL_2_CONFIG_REQ_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55118C11062  ==  1   GNB_DL_SCELL_2_CONFIG_SUCC_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55139C05516  ==  1   GNB_DU_UL_SCELL_1_ADMI_REQ_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55139C05519  ==  0   GNB_DU_UL_SCELL_1_ADMI_SUCC_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55138C03524  ==  1   GNB_UL_SCELL_1_ADMI_REQ_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55138C03527  ==  1   GNB_UL_SCELL_1_ADMI_SUCC_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55118C11058  ==  1   GNB_UL_SCELL_1_CONFIG_REQ_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55118C11068  ==  0   GNB_UL_SCELL_1_CONFIG_SUCC_SA
    ...  (NRCELL-${S_CELL_UE_1_S2P})M55138C03537  ==  0   GNB_UL_SCELL_1_ADMI_UNSUCC_SA

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${CB009267-A_TC04_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verify CB009267-A TC05 PM Values per Cells
    [Documentation]
    ...    |  CB009267-A TC05 Performance Counters PM Values per cells.         |

    ${M55118C110zz_Values_per_Cells}   Create List
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11071  ==  2  SCELLDL_INA_PRO_REL_SCELL_ATT_SA: N. of DL SCells to be rel. on PCell due to prol. inact. SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11072  ==  2  SCELLDL_INA_PRO_REL_SCELL_SUC_SA: N. of DL SCells rel. on PCell due to prolonged inact. SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11073  ==  0  SCELLUL_INA_PRO_REL_SCELL_ATT_SA: N. of UL SCells to be rel. on PCell due to prol. inact. SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11074  ==  0  SCELLUL_INA_PRO_REL_SCELL_SUC_SA: N. of UL SCells rel. on PCell due to prolonged inact. SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11075  ==  1  SCELLDL_BAD_RLQ_REL_SCELL_ATT_SA: N. of DL SCells to be rel. on PCell due to bad RL qual. SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11076  ==  1  SCELLDL_BAD_RLQ_REL_SCELL_SUC_SA: N. of DL SCells rel. on PCell due to bad RL quality SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11077  ==  1  SCELLUL_BAD_RLQ_REL_SCELL_ATT_SA: N. of UL SCells to be rel. on PCell due to bad RL qual. SA
    ...  (NRCELL-${PCELL_UE_1_P2S})M55118C11078  ==  1  SCELLUL_BAD_RLQ_REL_SCELL_SUC_SA: N. of UL SCells rel. on PCell due to bad RL quality SA

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55118C110zz_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verify CB009267-B TC11 PM Values per Cells
    [Documentation]
    ...    |  CB009267-B TC11 Performance Counters PM Values per cells.         |
    ...    |  the variable ${S_PCELL_UE_1} is set as test variable in the preconditions part

    ${M55118C110zz_Values_per_Cells}   Create List
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11033  ==  1  DL_INA_PRO_REL_SCELL_ATT_NSA: Num of DL SCells to be released on PSCell due prol. inact. NSA
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11034  ==  1  DL_INA_PRO_REL_SCELL_SUC_NSA: Num of DL SCells released on PSCell due to prol. inact. NSA
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11035  >=  1  SDL_BAD_RLQ_REL_SCELL_ATT_NSA: Num of DL SCells to be released on PSCell due bad RL qual NSA
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11036  >=  1  SDL_BAD_RLQ_REL_SCELL_SUC_NSA: Num of DL SCells released on PSCell due to bad RL qual NSA
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11043  >=  1  DL_RRC_FSCELL_REL_ATT_NSA: Num of DL full SCell release attempts on PSCell for NSA
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11044  >=  1  DL_RRC_FSCELL_REL_SUC_NSA: Num of successful DL full SCell release attempts on PSCell for NSA

    ...  (NRCELL-${S_PCELL_UE_1})M55118C11033 + (NRCELL-${S_PCELL_UE_1})M55118C11035  ==  (NRCELL-${S_PCELL_UE_1})M55118C11043  Sum of 33+35 == 43
    ...  (NRCELL-${S_PCELL_UE_1})M55118C11034 + (NRCELL-${S_PCELL_UE_1})M55118C11036  ==  (NRCELL-${S_PCELL_UE_1})M55118C11044  Sum of 34+36 == 44

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55118C110zz_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verify CB009267-C TC19 PM Values per Cells
    [Documentation]
    ...    | CB009267-C TC19 Performance Counters | PM Values per cells.         |

    Log To Console    Info: ${\n}CB009267-C TC19 PM Values per Cells
    ${PM_FILES}    Get Variable Value    ${PM_FILES}
    IF    '${PM_FILES}'=='None'
    ...    Wait for PMcounters and Collect the PM files

    ${M55316C150XX_Values_per_Cells}   Create List
    ...    (NRCELL-8)M55316C15016   >=  4   SCELL_SUSP_RECOV_SA
    ...    (NRCELL-4)M55316C15011   >=  0   SCELL_DL_SUSPEND_UEOVHT_SA
    ...    (NRCELL-9)M55316C15011   >=  1   SCELL_DL_SUSPEND_UEOVHT_SA
    ...    (NRCELL-13)M55316C15011  >=  1   SCELL_DL_SUSPEND_UEOVHT_SA
    ...    (NRCELL-9)M55316C15010   >=  0   SCELL_UL_SUSPEND_UEOVHT_SA

    Verify PM Counter Reference Table   reference_table=${M55316C150XX_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${1}

    ${M55316C150YY_Values_per_Cells}   Create List
    ...    (NRCELL-8)M55316C15033   >=  300   PCELL_UE_3_ACT_SCELL_DL_SA
    ...    (NRCELL-8)M55316C15039   >=  300   PCELL_UE_1_ACT_SCELL_UL_SA

    Verify PM Counter Reference Table   reference_table=${M55316C150YY_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verify CB009267-C TC19 PM Values per Cells TMO
    [Documentation]
    ...    | CB009267-C TC19 for TMO Performance Counters | PM Values per cells.         |
    ...    | On TMO TL126 different cells are used                                       |

    Log To Console    Info: ${\n}CB009267-C TC19 PM Values per Cells for TMO configuration
#    ${PM_FILES}    Get Variable Value    ${PM_FILES}
#    IF    '${PM_FILES}'=='None'
#    ...    Wait for PMcounters and Collect the PM files

    ${M55316C150XX_Values_per_Cells}   Create List
    ...    (NRCELL-${PCELL_UE_1_P2S})M55316C15016   >=  4   SCELL_SUSP_RECOV_SA
    ...    (NRCELL-${S_CELL_UE_1_S2P})M55316C15011   >=  1   SCELL_DL_SUSPEND_UEOVHT_SA
    ...    (NRCELL-${S_CELL_UE_1_SOURCE}[0])M55316C15011    >=  0   SCELL_DL_SUSPEND_UEOVHT_SA
    ...    (NRCELL-${S_CELL_UE_1_SOURCE}[1])M55316C15011    >=  0   SCELL_DL_SUSPEND_UEOVHT_SA
    ...    (NRCELL-${PCELL_UE_1_P2S})M55316C15010   >=  0   SCELL_UL_SUSPEND_UEOVHT_SA

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55316C150XX_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}

    ${M55316C150YY_Values_per_Cells}   Create List
    ...    (NRCELL-${PCELL_UE_1_P2S})M55316C15033   >=  300   PCELL_UE_3_ACT_SCELL_DL_SA
    ...    (NRCELL-${PCELL_UE_1_P2S})M55316C15039   >=  300   PCELL_UE_1_ACT_SCELL_UL_SA

    Run Keyword And Continue On Failure    pmcounters.Verify PM Counter Reference Table
    ...   reference_table=${M55316C150YY_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}


Verify CB009267-C TC24 PM Values per Cells
    [Documentation]
    ...    |  CB009267-C TC24 Performance Counters PM Values per cells.         |

    # NRCELL-8 is locked. So, the "-" is display in this case...
    ${M55316C150zz_Values_per_Cells}   Create List
    ...  (NRCELL-9)M55316C15052  >=  0  SCELL_SUSP_DEACT_REL_NSA: Number of NSA SCell UL or DL is deactivated or released from suspended state
    ...  (NRCELL-9)M55316C15054  >=  0  SCELL_DL_DEACT_DEACTMR_NSA:Number of NSA SCell DL deactivations based on SCell inactivity deactivation timer
    ...  (NRCELL-1)M55316C15052  >=  0  SCELL_SUSP_DEACT_REL_NSA: Number of NSA SCell UL or DL is deactivated or released from suspended state
    ...  (NRCELL-1)M55316C15054  >=  1  SCELL_DL_DEACT_DEACTMR_NSA:Number of NSA SCell DL deactivations based on SCell inactivity deactivation timer

    Verify PM Counter Reference Table   reference_table=${M55316C150zz_Values_per_Cells}    pm_dir=${PM_FILES}    meas_index=${0}
