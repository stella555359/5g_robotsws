*** Settings ***

*** Variables ***
${PHYS_CELL_ID_OFFSET}                49

*** Keywords ***
# HO - handover - mobility #
Create One Nr Relation For Cell
    [Documentation]
    ...     Conditions:     it is based on the arguments ${dist_name_cell} ${relationId} ${relMcc} ${relMnc} ${lcrId}
    ...     Actions:        it configures the parameters to initialize one NR relation for the cell
    ...     Checks:         it needs no checks
    ...     Verdict:        the parameters for the object are initialized
    [Arguments]             ${dist_name_cell}
    ...                     ${relationId}
    ...                     ${relMcc}
    ...                     ${relMnc}
    ...                     ${lcrId}

    ${dist_name_nrrel}            Set Variable                            ${dist_name_cell}/NRREL-${relationId}
    Dated log                     dist_nrcell_name is ${dist_name_nrrel}
    #manageObject=${dist_name_nrrel}
    SCF Add object                dist_name=${dist_name_nrrel}            class_name=com.nokia.srbts.nrbts:NRREL      version=${None}
    #cellIndividualSsbRsrpOffset / 0dB
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=cellIndividualSsbRsrpOffset    element_value=0dB
    #cellIndividualSsbRsrqOffset / 0dB
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=cellIndividualSsbRsrqOffset    element_value=0dB
    #gNbId / ${TMRBTS_ID[0]}
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=gNbId    element_value=${TMRBTS_ID[0]}
    #gNbIdLength / 22
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=gNbIdLength    element_value=22
    #handoverAllowedSA / allowed
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=handoverAllowedSA    element_value=allowed
    #handoverAllowedSARedCap / forbidden
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=handoverAllowedSARedCap    element_value=forbidden
    #lcrId
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=lcrId    element_value=${lcrId}
    #nrDcAllowed / false
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=nrDcAllowed    element_value=${False}
    #removeNotAllowed / false
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=removeNotAllowed    element_value=${False}
    #isRplCellForPSCell / false
    SCF Set element               dist_name=${dist_name_nrrel}            element_name=isRplCellForPSCell    element_value=${False}
    #list_name=gnbPlmn / add / mcc / ${relMcc} + mnc / ${relMnc} + mncLength / len(${relMnc})
    ${len_mnc}                    get length                              ${relMnc}
    ${list_gnbPlmn}               Create Dictionary    mcc=${relMcc}    mnc=${relMnc}    mncLength=${len_mnc}
    SCF Add list                  dist_name=${dist_name_nrrel}            list_name=gnbPlmn
    SCF Add items to list         dist_name=${dist_name_nrrel}            list_name=gnbPlmn    elements=${list_gnbPlmn}


Create All Nr Relations For Cell
    [Documentation]
    ...     Conditions:     it is based on the arguments ${nbOfCell} ${dist_name_cell} ${cellId} ${param}
    ...     Actions:        it configures the parameters to initialize all the NR relations for the cell
    ...     Checks:         it needs no checks
    ...     Verdict:        the parameters for the objects are initialized
    [Arguments]             ${nbOfCell}
    ...                     ${dist_name_cell}
    ...                     ${cellId}
    ...                     ${param}

    ${nrRelId}              Set Variable        1
    FOR    ${cell_id_bis}    IN RANGE    0    ${nbOfCell}
        Dated log          Check if Create One Nr Relation For Cell is possible for cellId=${cellId} compared current=${cell_id_bis}
        Run Keyword If     ${cellId} != ${cell_id_bis}    Create One Nr Relation For Cell    dist_name_cell=${dist_name_cell}
        ...                                               relationId=${nrRelId}    relMcc=311    relMnc=489
        ...                                               lcrId=${TNRCELL_ID_LIST[0]}[${cell_id_bis}]
        ${nrRelId}=         Run Keyword If     ${cellId} != ${cell_id_bis}    Evaluate    ${nrRelId} + 1
        ...                             ELSE                                  Evaluate    ${nrRelId} + 0
    END


Perform Full Commissioning With Intra Gnb Ho Configuration
    [Documentation]
    ...     Conditions:     it is based on the arguments ${param} ${nbCell}
    ...     Actions:        it performs the full commissioning to support the intra GNB HO
    ...     Checks:         it checks the real number of cells
    ...     Verdict:        the parameters for the objects are configured
    [Arguments]             ${param}=None
    ...                     ${nbCell}=2

    Dated log               The number of requested cells to configure is ${nbCell}
    ${nbNrCellId}           Set Variable        0
    ${len_nrCellIdList}     get length          ${TNRCELL_ID_LIST[0]}
    FOR    ${current_nrCellId}    IN RANGE      0    ${len_nrCellIdList}
        ${nbNrCellId}=      Run Keyword If      ${TNRCELL_ID_LIST[0]}[${current_nrCellId}] is not None    Evaluate    ${nbNrCellId} + 1
        ...                             ELSE                                                              Evaluate    ${nbNrCellId} + 0
    END
    ${nbCell_backup}        Set Variable        ${nbCell}
    ${nbCell}=              Run Keyword If     ${nbCell} > ${nbNrCellId}
    ...                                         Set Variable        ${nbNrCellId}
    ...                                  ELSE
    ...                                         Set Variable        ${nbCell_backup}
    Dated log               The number of cells to configure is ${nbCell}
    ${updated_scf}          String.Replace string    ${SCF_SETUP_PATH}    _Setup.xml    _For_HO.xml
    ${std_output}=          Run                 cp ${SCF_SETUP_PATH} ${updated_scf}
    SCF StartSession        scf_file=${updated_scf}
    #definition of the objects dist_name
    ${dist_name_mrbts}                Set Variable        MRBTS-${TMRBTS_ID[0]}
    Dated log                         dist_name_mrbts is ${dist_name_mrbts}
    ${dist_name_nrbts}                Set Variable        ${dist_name_mrbts}/NRBTS-${TNRBTS_ID[0]}
    Dated log                         dist_name_nrbts is ${dist_name_nrbts}
    ${dist_name_nrmopr_sa}            Set Variable        ${dist_name_nrbts}/NRMOPR_SA-1
    Dated log                         dist_name_nrmopr_sa is ${dist_name_nrmopr_sa}
    ${dist_name_nrpmrnl}              Set Variable        ${dist_name_nrbts}/NRPMRNL-1
    Dated log                         dist_name_nrpmrnl is ${dist_name_nrpmrnl}
    ### MRBTS
    #btsName / update / INTRA_GNB_HO
    SCF Set element                   dist_name=${dist_name_mrbts}            element_name=btsName    element_value=INTRA_GNB_HO
    ### NRBTS
    #actIntraFreqHoSA / update / true
    SCF Set element                   dist_name=${dist_name_nrbts}            element_name=actIntraFreqHoSA    element_value=${True}
    #timerXnDataFwdGuard / add / 250
    SCF Set element                   dist_name=${dist_name_nrbts}            element_name=timerXnDataFwdGuard    element_value=250
    ### NRMOPR_SA
    #a3MeasEnabled / add / rsrp
    SCF Set element                   dist_name=${dist_name_nrmopr_sa}        element_name=a3MeasEnabled    element_value=rsrp
    ### NRPMRNL
    #miNrRelReportCu / update / 5min
    SCF Set element                   dist_name=${dist_name_nrpmrnl}          element_name=miNrRelReportCu    element_value=5min
    ### NRCELL's
    FOR    ${cell_id}       IN RANGE    0    ${nbCell}
        ${dist_name_nrcell}           Set Variable    ${TNRCELL_DN_LIST[0]}[${cell_id}]
        Dated log                     dist_nrcell_name is ${dist_name_nrcell}
        #a3MeasEnabled / update / rsrp
        SCF Set element               dist_name=${dist_name_nrcell}           element_name=a3MeasEnabled    element_value=rsrp
        #absThreshSsbRsrpConsolidation / add / 10
        SCF Set element               dist_name=${dist_name_nrcell}           element_name=absThreshSsbRsrpConsolidation    element_value=10
        #sMeasConfigSsbRsrp / add / 10
        SCF Set element               dist_name=${dist_name_nrcell}           element_name=sMeasConfigSsbRsrp    element_value=10
        #list_name=a3MeasSsbRsrp / add / a3HysteresisSsbRsrp / 2 + a3OffsetSsbRsrp / 4 + a3TimeToTriggerSsbRsrp / ms40
        ${list_a3MeasSsbRsrp}         Create Dictionary    a3HysteresisSsbRsrp=2    a3OffsetSsbRsrp=4    a3TimeToTriggerSsbRsrp=ms40
        SCF Add list                  dist_name=${dist_name_nrcell}           list_name=a3MeasSsbRsrp
        SCF Add items to list         dist_name=${dist_name_nrcell}           list_name=a3MeasSsbRsrp    elements=${list_a3MeasSsbRsrp}
        Create All Nr Relations For Cell    nbOfCell=${nbCell}    dist_name_cell=${dist_name_nrcell}    cellId=${cell_id}    param=${param}
    END
    SCF StopSession         scf_file=${updated_scf}
    OAM Perform Full Commissioning    scf_file=${updated_scf}
    OAM wait available
    OAM Get SCF File        file=SCF_Updated_For_HO.xml
