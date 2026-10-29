*** Settings ***

Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Commissioning for CB009059

#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Resource  ./CB009059_Keywords.robot

*** Keywords ***

Initial TL Setup for US A_B1 before Cells are on Air
    [Documentation]    Feature Flag to be disabled while bringing the cells on air for subfeature A-US#B1, and then the flag to be modified online.
    [Arguments]     ${test_instance}=A_B1
    ${scf_file}=                Load current SCF
    ${dist_name}=               Set Variable                        MRBTS-1/NRBTS-1
    Set New List                dist_name=${dist_name}              list_name=actDrbProfileForCellAggrLevel
    ${param_list}=              Create List                         disabled
    scf.add_elements_to_list    dist_name=${dist_name}              list_name=actDrbProfileForCellAggrLevel     elements=${param_list}
    FOR   ${p_name}             ${value}                       IN
    ...   resType               nonGBR
    ...   nrDrbMacDN            MRBTS-1/NRBTS-1/NRDRB_MAC-2
          Set Element    dist_name=${dist_name}/NRDRB-10    p_name=${p_name}   value=${value}
    END
    Apply Delta SCF             ${scf_file}  ${test_instance}_modified_scf
    Bring Airphone TL to on Air status
    Wait until the next Measurement Period starts
    Start F1AP capturing

Update DRB Profile for Cell Aggr Level in NRDRB
    [Documentation]    Updates the Cell Aggr Level in NRDRB with new DRB Profile
    [Arguments]    ${drb_profile_id}  ${new_drb_profile}
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRDRB-${drb_profile_id}
    Set New List              dist_name=${dist_name}      list_name=cellAggrLevel   #RLC Mode, resType Value
    ${param_list}=             Create List  ${new_drb_profile}
    scf.add_elements_to_list  dist_name=${dist_name}      list_name=cellAggrLevel  elements=${param_list}

Update feature flag
    [Documentation]    Updates the feature flag: DRB profile for Cell Aggr level in NRBTS
    [Arguments]    ${feature_flag}
    ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1
    Set New List              dist_name=${dist_name}      list_name=actDrbProfileForCellAggrLevel
    ${param_list}=            Create List  ${feature_flag}
    scf.add_elements_to_list  dist_name=${dist_name}      list_name=actDrbProfileForCellAggrLevel  elements=${param_list}

Update Maximum number of Secondary Cell Allocations in Cell 2 and 3
    [Documentation]    Updates the Maximum number of secondary cell allocations in a cell
    [Arguments]    ${new_value}
    FOR    ${cell_id}    IN RANGE    2  4
        Set Element      dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}     p_name=maxNumOfSCellAlloc      value=${new_value}
    END

Apply Config for A_B1
    [Arguments]    ${test_instance}
    Initial TL Setup for US A_B1 before Cells are on Air
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=11  new_drb_profile=Not FR1 CA eligible
    Update feature flag   feature_flag=FR1_SA
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_drb_profile

Apply Config for A_B2
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=14  new_drb_profile=FR1 CA incompatible
    Update feature flag   feature_flag=disabled
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_drb_profile_featureflag

Apply Config for A_B6
    [Documentation]
    [Arguments]     ${test_instance}
    ${scf_file}=          Load current SCF
    FOR   ${p_name}             ${value}                       IN
    ...   resType               nonGBR
    ...   nrDrbMacDN            MRBTS-1/NRBTS-1/NRDRB_MAC-2
          Set Element    dist_name=MRBTS-1/NRBTS-1/NRDRB-10    p_name=${p_name}   value=${value}
    END
    Apply Delta SCF       ${scf_file}  ${test_instance}_modified_scf

Apply Config for A_B10
    [Arguments]    ${test_instance}  ${action}
    ${scf_file}=       Load current SCF
    IF   '${action}' == '_SCell_Allocations_disabled'
    ...   Update Maximum number of Secondary Cell Allocations in Cell 2 and 3   new_value=0
    ...   ELSE IF   '${action}' == '_SCell_Allocations_enabled'
    ...   Update Maximum number of Secondary Cell Allocations in Cell 2 and 3   new_value=250
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_${action}

Updating Feature Activation flag
    [Arguments]    ${test_instance}  ${action}
    ${scf_file}=       Load current SCF
    IF   '${action}' == '_featureflag_disabled'
    ...   Update feature flag   feature_flag=disabled
    ...   ELSE IF   '${action}' == '_featureflag_enabled'
    ...   Update feature flag   feature_flag=FR1_SA
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_${action}

Delta Commissioning for AC_003_1
    [Documentation]     Update Network slice-2 DRB profile configuration for cell aggregation level
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    FOR   ${dist_name}                 ${p_name}            ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRDRB-17     resType              nonGBR
    ...   MRBTS-1/NRBTS-1/NRDRB-17     nrDrbMacDN           MRBTS-1/NRBTS-1/NRDRB_MAC-2
    ...   MRBTS-1/NRBTS-1/NRDRB-19     rlcMode              RLC_AM
    ...   MRBTS-1/NRBTS-1/NRDRB-19     dlFlowControlAlgo    3gppFlowControl
    ...   MRBTS-1/NRBTS-1/NRDRB-19     nrDrbRlcAmDN         MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.remove_element_from_scf     dist_name=MRBTS-1/NRBTS-1/NRDRB-19             p_name=nrDrbRlcUmDN
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Apply Config for AC_003_1
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=11  new_drb_profile=Not FR1 CA eligible
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=18  new_drb_profile=FR1 CA incompatible
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_drb_profile

Apply Config for AC_003_2
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=12  new_drb_profile=FR1 CA eligible
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_drb_profile

secondary cell allocations
    ${scf_file}=       Load current SCF
    ${dist_name}=      Set Variable                 MRBTS-1/NRBTS-1/NRCELL-2
    Set Element        dist_name=${dist_name}       p_name=maxNumOfSCellAlloc            value=0

Re-Configure the RLC mode for the DRBs
    [Documentation]    To reconfigure RLC mode for the NRDRB-11 and NRDRB-12 to RLC UM for Sub-feature C UPD0001
    FOR   ${dist_name}                 ${p_name}            ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRDRB-11     rlcMode              RLC_UM
    ...   MRBTS-1/NRBTS-1/NRDRB-11     nrDrbRlcUmDN         MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...   MRBTS-1/NRBTS-1/NRDRB-12     rlcMode              RLC_UM
    ...   MRBTS-1/NRBTS-1/NRDRB-12     nrDrbRlcUmDN         MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.remove_element_from_scf     dist_name=MRBTS-1/NRBTS-1/NRDRB-11     p_name=nrDrbRlcAmDN
    scf.remove_element_from_scf     dist_name=MRBTS-1/NRBTS-1/NRDRB-12     p_name=nrDrbRlcAmDN

Apply Config for C_B7
    [Documentation]    Activate A1 measurement based SCell Addition
    [Arguments]    ${test_instance}=C_B7
    ${scf_file}=        Load current SCF
    Re-Configure the RLC mode for the DRBs
    ${dist_name}=       Set Variable            MRBTS-1/NRBTS-1
    Set New List                    dist_name=${dist_name}               list_name=actMeasBasedSCellAdditionSa
    ${meas_based_scell}=            Create List                          A1-based
    scf.add_elements_to_list        dist_name=${dist_name}               list_name=actMeasBasedSCellAdditionSa       elements=${meas_based_scell}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1      sCellAdditionMethod             covBasedA1
    ...   MRBTS-1/NRBTS-1/NRCELL-3/NRREL-2      sCellAdditionMethod             covBasedA1
    ...   MRBTS-1/NRBTS-1/NRCELL-4              maxNumOfSCellAlloc              250
          Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    Apply Delta SCF    ${scf_file}  ${test_instance}_modified_scf

Commissioning for C_B8
    [Documentation]    Activate A1 measurement based SCell Addition
    [Arguments]     ${test_instance}=C_B8
    ${scf_file}=        Load current SCF
    Re-Configure the RLC mode for the DRBs
    ${dist_name}=       Set Variable            MRBTS-1/NRBTS-1
    Set New List                    dist_name=${dist_name}               list_name=actMeasBasedSCellAdditionSa
    ${meas_based_scell}=            Create List                          A1-based
    scf.add_elements_to_list        dist_name=${dist_name}               list_name=actMeasBasedSCellAdditionSa       elements=${meas_based_scell}
    FOR   ${dist_name}                          ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1      sCellAdditionMethod             covBasedA1
    ...   MRBTS-1/NRBTS-1/NRCELL-4/NRREL-2      sCellAdditionMethod             covBasedA1
    ...   MRBTS-1/NRBTS-1                       actSCellSwapFr1                 a6BasedSa
    ...   MRBTS-1/NRBTS-1/NRCELL-1              a6MeasSCellSwapEnabled          rsrpAndRsrq
    ...   MRBTS-1/NRBTS-1/NRCELL-2              a6MeasSCellSwapEnabled          rsrpAndRsrq
    ...   MRBTS-1/NRBTS-1/NRCELL-4              maxNumOfSCellAlloc              250
    ...   MRBTS-1/NRBTS-1/NRCELL-2              gscnOrSsPbchArfcn               6468
    ...   MRBTS-1/NRBTS-1/NRCELL-2              nrarfcn                         519000
          Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
    scf.remove_mo_with_descendant_mos        dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1
    Apply Delta SCF    ${scf_file}  ${test_instance}_modified_scf

Delta Commissioning for E_B1
    [Documentation]    Activate A1 measurement based SCell Addition
    [Arguments]     ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=       Set Variable            MRBTS-1/NRBTS-1
    # Configure A1 measurement based SCell Addition parameters for Cell-1
    Set New List                    dist_name=${dist_name}               list_name=actMeasBasedSCellAdditionSa
    ${meas_based_scell}=            Create List                          A1-based
    scf.add_elements_to_list        dist_name=${dist_name}               list_name=actMeasBasedSCellAdditionSa       elements=${meas_based_scell}
    FOR    ${rel_id}    IN RANGE    1  4
        Set Element             dist_name=${dist_name}/NRCELL-1/NRREL-${rel_id}      p_name=sCellAdditionMethod      value=covBasedA1
    END
    Set Element             dist_name=${dist_name}/NRCELL-1                  p_name=a1MeasSCellAddEnabled            value=rsrpAndRsrq
    Set New List            dist_name=${dist_name}/NRCELL-1                  list_name=a1MeasSCellAddSsbRsrp
    ${list_elements}=       Create dictionary                                a1HysteresisSCellAddSsbRsrp             0
    ...                                                                      a1ThresholdSCellAddSsbRsrpFDD           40
    ...                                                                      a1ThresholdSCellAddSsbRsrpTDD           40
    ...                                                                      a1TimeToTriggerSCellAddSsbRsrp          320ms
    scf.add_item_to_list    dist_name=${dist_name}/NRCELL-1                  list_name=a1MeasSCellAddSsbRsrp         elements=${list_elements}
    Set New List            dist_name=${dist_name}/NRCELL-1                  list_name=a1MeasSCellAddSsbRsrq
    ${list_elements}=       Create dictionary                                a1HysteresisSCellAddSsbRsrq             0
    ...                                                                      a1ThresholdSCellAddSsbRsrq              40
    ...                                                                      a1TimeToTriggerSCellAddSsbRsrq          320ms
    scf.add_item_to_list    dist_name=${dist_name}/NRCELL-1                  list_name=a1MeasSCellAddSsbRsrq         elements=${list_elements}
    #Configure A2 measurement based SCell release parameters for Cell-2 and Cell-3
    FOR    ${cell_id}    IN RANGE    2  4
        Set Element             dist_name=${dist_name}/NRCELL-${cell_id}     p_name=a2MeasSCellRelEnabled            value=rsrpAndRsrq
        Set New List            dist_name=${dist_name}/NRCELL-${cell_id}     list_name=a2MeasSCellRelSsbRsrp
        ${list_elements}=       Create dictionary                            a2HysteresisSCellRelSsbRsrp             0
        ...                                                                  a2ThresholdSCellRelSsbRsrp              34
        ...                                                                  a2TimeToTriggerSCellRelSsbRsrp          2560ms
        scf.add_item_to_list    dist_name=${dist_name}/NRCELL-${cell_id}     list_name=a2MeasSCellRelSsbRsrp         elements=${list_elements}
        Set New List            dist_name=${dist_name}/NRCELL-${cell_id}     list_name=a2MeasSCellRelSsbRsrq
        ${list_elements}=       Create dictionary                            a2HysteresisSCellRelSsbRsrq             0
        ...                                                                  a2ThresholdSCellRelSsbRsrq              49
        ...                                                                  a2TimeToTriggerSCellRelSsbRsrq          2560ms
        scf.add_item_to_list    dist_name=${dist_name}/NRCELL-${cell_id}     list_name=a2MeasSCellRelSsbRsrq         elements=${list_elements}
    END
    Apply Delta SCF    ${scf_file}  ${test_instance}_modified_scf

Delta Commissioning for E_B3
    [Documentation]     Activate buffer based based SCell Addition
    [Arguments]         ${test_instance}
    ${scf_file}=        Load current SCF
    ${dist_name}=       Set Variable                MRBTS-1/NRBTS-1
    Set Element         dist_name=${dist_name}      p_name=actBufferBasedSCellAddition                value=oneShot_Dl_Fr1
    Apply Delta SCF     ${scf_file}  ${test_instance}_modified_scf

Commissioning for BA
    [Documentation]    Activate A1 measurement based SCell addition
    ${config_dir}=    Get test suite config directory
    scf.load_scf    ${P_ORIG_SCF}
    FOR    ${cell_index}    IN RANGE    1    4
        ${dist_name}=               Set Variable                      MRBTS-1/NRBTS-1/NRCELL-1/NRREL-${cell_index}
        Set Element                 dist_name=${dist_name}            p_name=sCellAdditionMethod                      value=covBasedA1
    END
    FOR   ${dist_name}                  ${p_name}                       ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1      a1MeasSCellAddEnabled           rsrpCombined
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    ${dist_name}=                   Set Variable                      MRBTS-1/NRBTS-1/NRCELL-1
    Set New List                    dist_name=${dist_name}            list_name=a1MeasSCellAddSsbRsrp
    ${list_elements}=               Create dictionary                 a1HysteresisSCellAddSsbRsrp                     0
    ...                                                               a1ThresholdSCellAddSsbRsrpFDD                   50
    ...                                                               a1ThresholdSCellAddSsbRsrpTDD                   50
    ...                                                               a1TimeToTriggerSCellAddSsbRsrp                  320ms
    scf.add_item_to_list            dist_name=${dist_name}            list_name=a1MeasSCellAddSsbRsrp                 elements=${list_elements}
    Set New List                    dist_name=${dist_name}            list_name=a1MeasSCellAddSsbRsrq
    ${list_elements}=               Create dictionary                 a1HysteresisSCellAddSsbRsrq                     0
    ...                                                               a1ThresholdSCellAddSsbRsrq                      50
    ...                                                               a1TimeToTriggerSCellAddSsbRsrq                  320ms
    scf.add_item_to_list            dist_name=${dist_name}            list_name=a1MeasSCellAddSsbRsrq                 elements=${list_elements}
    Set New List                    dist_name=MRBTS-1/NRBTS-1         list_name=actMeasBasedSCellAdditionSa
    ${meas_based_scell}=            Create List                       A1-based
    scf.add_elements_to_list        dist_name=MRBTS-1/NRBTS-1         list_name=actMeasBasedSCellAdditionSa           elements=${meas_based_scell}
    scf.save_scf                    ${config_dir}/scf_9059-BA.xml
    Execute full commissioning      ${config_dir}/scf_9059-BA.xml

Apply Config for BA_B10
    [Documentation]    CA configuration backoff timer for UE overheating
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    ${dist_name}=       Set Variable            MRBTS-1/NRBTS-1
    FOR   ${p_name}                             ${value}                       IN
    ...   actBufferBasedSCellAddition           oneShot_Dl_Fr1
    ...   actSCellReleaseForInactiveSCell       timer_based_Fr1
    ...   actOverheatingAssistance              true
    ...   timerOverheatIndProhibit              1s
    ...   caBackoffTimerUeOh                    60
    ...   timerPostOverheating                  0
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    FOR    ${cell_index}    IN RANGE    1    5
        Set Element    dist_name=${dist_name}/NRCELL-${cell_index}       p_name=sCellInactivityReleaseTimer          value=10
    END
    Apply Additional Config for BA
    Apply Delta SCF    ${scf_file}  ${test_instance}_modified_scf

Apply Additional Config for BA
    FOR   ${dist_name}                 ${p_name}            ${value}                       IN
    ...   MRBTS-1/NRBTS-1/NRDRB-10     resType              nonGBR
    ...   MRBTS-1/NRBTS-1/NRDRB-10     nrDrbMacDN           MRBTS-1/NRBTS-1/NRDRB_MAC-2
    ...   MRBTS-1/NRBTS-1/NRDRB-19     rlcMode              RLC_AM
    ...   MRBTS-1/NRBTS-1/NRDRB-19     nrDrbRlcAmDN         MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
    ...   MRBTS-1/NRBTS-1/NRDRB-19     dlFlowControlAlgo    3gppFlowControl
          Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    scf.remove_element_from_scf                         dist_name=${dist_name}              p_name=nrDrbRlcUmDN
    Update DRB Profile for Cell Aggr Level in NRDRB     drb_profile_id=19                   new_drb_profile=FR1 CA incompatible

Apply Config for BA
    [Documentation]    A2 measurement based SCell release
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    FOR    ${cell_index}    IN RANGE    2    4
          ${dist_name}=             Set Variable              MRBTS-1/NRBTS-1/NRCELL-${cell_index}
          Set Element               dist_name=${dist_name}    p_name=a2MeasSCellRelEnabled              value=rsrpAndRsrq
          ${list_name}=             Set Variable              a2MeasSCellRelSsbRsrp
          Set New List              dist_name=${dist_name}    list_name=${list_name}
          ${list_elements}=         Create dictionary         a2HysteresisSCellRelSsbRsrp               0
          ...                                                 a2ThresholdSCellRelSsbRsrp                34
          ...                                                 a2TimeToTriggerSCellRelSsbRsrp            2560ms
          scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}                    elements=${list_elements}
          ${list_name}=             Set Variable              a2MeasSCellRelSsbRsrq
          Set New List              dist_name=${dist_name}    list_name=${list_name}
          ${list_elements}=         Create dictionary         a2HysteresisSCellRelSsbRsrq               0
          ...                                                 a2ThresholdSCellRelSsbRsrq                49
          ...                                                 a2TimeToTriggerSCellRelSsbRsrq            2560ms
          scf.add_item_to_list      dist_name=${dist_name}    list_name=${list_name}                    elements=${list_elements}
    END
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_A2_measurement

Apply Config for BA_B1
    [Documentation]    Activate downlink buffer based SCell addition
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    ${dist_name}=      Set Variable        MRBTS-1/NRBTS-1
    Set Element        dist_name=${dist_name}    p_name=actBufferBasedSCellAddition   value=oneShot_Dl_Fr1
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_activate_dl_buffer

Apply Config for BA_B2 or BA_B3
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Apply Additional Config for BA
    Apply Delta SCF    ${scf_file}  ${test_instance}_modified_scf

Apply Config for BA_B3
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    ${dist_name}=      Set Variable        MRBTS-1/NRBTS-1/NRCELL-1
    Set Element        dist_name=${dist_name}    p_name=maxNumOfNonGBRBearersSA          value=0
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_non_GBR_Bearer

Apply Config for BE_B2
    [Arguments]    ${test_instance}  ${drb_profile_id}  ${new_drb_profile}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=${drb_profile_id}  new_drb_profile=${new_drb_profile}
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_drb_profile

Apply UL CA Config for BE_B1
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    ${dist_name}=      Set Variable    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    Set Element        dist_name=${dist_name}    p_name=sCellOperationalMode    value=dlAndUl
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_sCellOperationalMode

Apply Delta Config for BE_B1
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=10  new_drb_profile=Not FR1 CA eligible
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=17  new_drb_profile=Not FR1 CA eligible
    Apply Delta SCF    ${scf_file}  ${test_instance}_update_drb_profile

Apply Delta Config for BE_B1 for UE_4
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=15  new_drb_profile=FR1 CA incompatible
    ${dist_name}=      Set Variable    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2
    Set Element        dist_name=${dist_name}    p_name=sCellOperationalMode    value=dlOnly
    Apply Delta SCF    ${scf_file}    ${test_instance}_update_drb_profile_and_sCellOperationalMode

Apply Config for BB_B4
    [Arguments]    ${test_instance}
    ${scf_file}=       Load current SCF
    Update DRB Profile for Cell Aggr Level in NRDRB  drb_profile_id=16  new_drb_profile=Not FR1 CA eligible
    ${dist_name}=      Set Variable     MRBTS-1/NRBTS-1/NRCELL-2
    Set Element        dist_name=${dist_name}     p_name=maxNumOfSCellAlloc     value=0
    Apply Delta SCF    ${scf_file}    ${test_instance}_update_drb_profile
