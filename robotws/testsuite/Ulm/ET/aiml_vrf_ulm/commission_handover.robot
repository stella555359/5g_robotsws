*** Settings ***
Documentation   This Resource keeps all functionality to perform the commissioning
...             so a handover is possible between all cells of a gNodeB

Resource    ../../resources/Common/commissioning.robot
Library     scf_utils.py
Library     OperatingSystem


*** Variables ***
${NIDD_VERSION}     ${None}
${SCF_FILENAME}     SCF_for_commissioning_ho.xml

${AVAILABLE_CELL_IDS}   ${None}

*** Keywords ***
Set Object
    [Arguments]      ${class_name}   ${dist_name}   ${version}=${NIDD_VERSION}
    ${mo_exist}=              scf.Is Object In Scf      dist_name=${dist_name}
    IF            ${mo_exist}               scf.Remove Mo With Descendant Mos  dist_name=${dist_name}
    scf.Add Object To Scf     class_name=${class_name}  dist_name=${dist_name}             version=${version}

Set New List
    [Documentation]     if exists, otherwise add it
    [Arguments]      ${dist_name}   ${list_name}
    ${list_exist}=            scf.Is List In Object  dist_name=${dist_name}     list_name=${list_name}
    IF            ${list_exist}==True    scf.Remove List From Scf  dist_name=${dist_name}   list_name=${list_name}
    scf.Add List To Scf       dist_name=${dist_name}    list_name=${list_name}

Set Element
    [Documentation]    modify parameter if exists, otherwise add it
    [Arguments]      ${dist_name}   ${p_name}   ${value}
    ${element_exist}=         scf.Is Element In Object  dist_name=${dist_name}    p_name=${p_name}
    IF            ${element_exist}
    ...                       scf.Modify Scf Element    dist_name=${dist_name}    p_name=${p_name}     value=${value}
    ...         ELSE
    ...                       scf.Add Element To Scf    dist_name=${dist_name}    p_name=${p_name}     value=${value}

Get Cell IDs From SCF
    ${AVAILABLE_CELL_IDS}   Create List
    ${cells}   scf.Get All Dist Names By Pattern   MRBTS-1/NRBTS-1/NRCELL-\\d+$
    FOR    ${item}   IN    @{cells}
        ${item_ids}   Get Regexp Matches    ${item}   \\d+$
        Append To List   ${AVAILABLE_CELL_IDS}   ${item_ids}[0]
    END
    Set Suite Variable    ${AVAILABLE_CELL_IDS}

Perform Commissioning
    Store Current SCF From GNB

    Log To Console       SCF Downloaded from gNodeB: ${P_ORIG_SCF}
    ${NIDD_VERSION}      scf_utils.Extract NIDD Version   ${P_ORIG_SCF}
    Set Suite Variable   ${NIDD_VERSION}

    scf.load_scf         ${P_ORIG_SCF}
    ${cell_ids}   Get Cell IDs From SCF
    Log To Console    Cell IDs: ${cell_ids}

    Perform Additional Configuration To Match Cutomer Specific Config

    scf.save_scf                    ${SCF_FILENAME}
    Execute full commissioning      ${SCF_FILENAME}

    # ${delta_scf_json}     Set Variable     /tmp/delta_scf_for_handover.json

    # scf.Calculate Delta SCF   target_scf_path=${SCF_FILENAME}   actual_scf_path=${P_ORIG_SCF}   delta_scf_path=${delta_scf_json}

    # ${delta_size}   OperatingSystem.Get File Size   ${delta_scf_json}

    # IF   ${delta_size} <= 2    RETURN

    # ${admin_alias}     Setup OAM HTTP Session
    # admin.Perform Delta Recommissioning    connection=${admin_alias}
    # ...                                    delta_file=${delta_scf_json}
    # ...                                    scip_parameter_relation_errors=True
    # ...                                    should_activate=True



Add NREL MOC To NRCELL
    [Arguments]    ${cell_id}   ${moc_id}   ${lcrId}
    ${dist_name}=    Set Variable    MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRREL-${moc_id}
    Set Object    class_name=NRREL    dist_name=${dist_name}   version=${NIDD_VERSION}
    FOR   ${p_name}                            ${value}      IN
    ...   actA4ToA1BasedSCellFallbackNsa        false
    ...   cellIndividualSsbRsrpOffset           0dB
    ...   cellIndividualSsbRsrqOffset           0dB
    ...   gNbId                                 1
    ...   gNbIdLength                           22
    ...   handoverAllowedSA                     allowed
    ...   handoverAllowedSARedCap               forbidden
    ...   isRplCellForPSCell                    false
    ...   lcrId                                 ${lcrId}
    ...   nrDcAllowed                           false
    ...   removeNotAllowed                      false
        Set Element    dist_name=${dist_name}    p_name=${p_name}   value=${value}
    END
    Set New List                    dist_name=${dist_name}          list_name=gnbPlmn
    ${gnbPlmn_dict}                 Create dictionary               mcc                             311
    ...                                                             mnc                             489
    ...                                                             mncLength                       3
    scf.add_item_to_list            dist_name=${dist_name}          list_name=gnbPlmn               elements=${gnbPlmn_dict}



Perform Additional Configuration To Match Cutomer Specific Config
    [Arguments]
    FOR   ${dist_name}                                      ${p_name}                               ${value}                   IN
    ...   MRBTS-1/NRBTS-1                                   actInterFreqHoSA                        true
    ...   MRBTS-1/NRBTS-1                                   actIntraFreqHoSA                        true
    ...   MRBTS-1/NRBTS-1                                   timerXnDataFwdGuard                     250
    ...   MRBTS-1/NRBTS-1/NRPMRNL-1                         miNrRelReportCu                         5min
          Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END


    FOR  ${cell_id}   IN   @{AVAILABLE_CELL_IDS}
          FOR      ${p_name}                       ${value}   IN
          ...      a1MeashoEnabled                 rsrpCombined
          ...      a1MeashoEnabledSA               rsrpCombined
          ...      a2MeashoEnabled                 rsrp
          ...      a2MeashoEnabledSA               rsrp
          ...      a3MeasEnabled                   rsrpAndRsrq
          ...      a5MeasEnabled                   rsrqCombined
          ...      absThreshSsbRsrpConsolidation   0
          ...      absThreshSsbRsrqConsolidation   0
          ...      sMeasConfigSsbRsrp              87
              Set Element    dist_name=MRBTS-1/NRBTS-1/NRCELL-${cell_id}    p_name=${p_name}    value=${value}
          END
    END


    FOR  ${id}   IN   @{AVAILABLE_CELL_IDS}
        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrpSA
        ${a1MeashoSsbRsrp}          Create dictionary                           a1HysteresishoSsbRsrpSA                 0
        ...                                                                     a1ThresholdhoSsbRsrpSA                  60
        ...                                                                     a1TimeToTriggerhoSsbRsrpSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrpSA             elements=${a1MeashoSsbRsrp}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrqSA
        ${a1MeashoSsbRsrq}          Create dictionary                           a1HysteresishoSsbRsrqSA                 0
        ...                                                                     a1ThresholdhoSsbRsrqSA                  63
        ...                                                                     a1TimeToTriggerhoSsbRsrqSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a1MeashoSsbRsrqSA             elements=${a1MeashoSsbRsrq}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrpSA
        ${a2MeashoSsbRsrp}          Create dictionary                           a2HysteresishoSsbRsrpSA                 0
        ...                                                                     a2ThresholdhoSsbRsrpSA                  34
        ...                                                                     a2TimeToTriggerhoSsbRsrpSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrpSA             elements=${a2MeashoSsbRsrp}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrqSA
        ${a2MeashoSsbRsrq}          Create dictionary                           a2HysteresishoSsbRsrqSA                 0
        ...                                                                     a2ThresholdhoSsbRsrqSA                  34
        ...                                                                     a2TimeToTriggerhoSsbRsrqSA              ms480
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a2MeashoSsbRsrqSA             elements=${a2MeashoSsbRsrq}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrp
        ${a3MeasSsbRsrp}            Create dictionary                           a3HysteresisSsbRsrp                     0
        ...                                                                     a3OffsetSsbRsrp                         6
        ...                                                                     a3TimeToTriggerSsbRsrp                  ms320
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrp                 elements=${a3MeasSsbRsrp}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrq
        ${a3MeasSsbRsrq}            Create dictionary                           a3HysteresisSsbRsrq                     0
        ...                                                                     a3OffsetSsbRsrq                         6
        ...                                                                     a3TimeToTriggerSsbRsrq                  ms320
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a3MeasSsbRsrq                 elements=${a3MeasSsbRsrq}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrp
        ${a5MeasSsbRsrp}            Create dictionary                           a5HysteresisSsbRsrp                     0
        ...                                                                     a5Threshold1SsbRsrp                     52
        ...                                                                     a5Threshold2SsbRsrp                     54
        ...                                                                     a5TimeToTriggerSsbRsrp                  ms100
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrp                 elements=${a5MeasSsbRsrp}

        Set New List                dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrq
        ${a5MeasSsbRsrq}            Create dictionary                           a5HysteresisSsbRsrq                     0
        ...                                                                     a5Threshold1SsbRsrq                     52
        ...                                                                     a5Threshold2SsbRsrq                     54
        ...                                                                     a5TimeToTriggerSsbRsrq                  ms100
        scf.add_item_to_list        dist_name=MRBTS-1/NRBTS-1/NRCELL-${id}      list_name=a5MeasSsbRsrq                 elements=${a5MeasSsbRsrq}
    END

    FOR    ${cell_id}   IN      @{AVAILABLE_CELL_IDS}
        ${other_cell_ids}   Copy List   ${AVAILABLE_CELL_IDS}
        Remove Values From List    ${other_cell_ids}   ${cell_id}
        FOR   ${other_cell_id}   ${moc_id}   IN ENUMERATE   @{other_cell_ids}   start=1
            Log To Console    Add NREL-${moc_id} for cell ${cell_id} - other cell: ${other_cell_id}
            Add NREL MOC To NRCELL  cell_id=${cell_id}  moc_id=${moc_id}  lcrId=${other_cell_id}
        END
    END