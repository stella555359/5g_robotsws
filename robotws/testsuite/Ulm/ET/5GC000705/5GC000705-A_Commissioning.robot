*** Settings ***
Documentation
...    author: Ulm SQD 65
...    Team: 'MN RAN L3 SW ULM L3NRT SQD 65'
...    Email: 'I_MN_RAN_L3_SW_ULM_SQD_65@internal.nsn.com'
...    Description: Keywords for 5GC000705-A commissioning

Resource    ../resources/SQD65/sqd65_commissioning.robot

*** Variables ***

${5GC000705-A_SCF}               scfc_705-A.xml
${DELTA_5GC000705-A_SCF}         delta_scfc_705-A.json
${NIDD_VERSION}                  NRBTSCL22R2_2112_100
${CELL_TECHNOLOGY}               TDD
&{plmn}                          mcc=311  mnc=489  mncLength=3

*** Keywords ***


Commissioning
    scf.load_scf        ${P_ORIG_SCF}
    Update Parameters in NRCELL  cell_id=1
    Update Parameters in NRCELL  cell_id=2
    FOR   ${dist_name}                                              ${p_name}                       ${value}      IN
    ...   MRBTS-1/MNL-1/AMGR-1/LUAC-1                               webEMSessionLogoutTimer         7200
    ...   MRBTS-1/MNL-1/MNLENT-1/PMCADM-1                           reportingIntervalPm             5min
    ...   NRBTS-1                                                   tNgRelocExecDeltN               3000
    ...   NRBTS-1                                                   tNgRelocPrepN                   2000
    ...   NRBTS-1                                                   tNgRelocOverallN                2000
    ...   NRBTS-1                                                   tNgRelocCancelN                 2000
    ...   NRBTS-1/NRCELL-1                                          blockHoTimer                    5
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
	Get Value from SCF
    Add Emergencycall in Nrcell    cell_id=1
    Update Parameters in XNLINK
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-1    p_name=actVoNR    value=true
    ${ts_conf_dir}=          Get Test Suite Config Directory
    scf.save_scf             ${ts_conf_dir}/${5GC000705-A_SCF}
    Execute full commissioning    gnb_id=0    scf_path=${ts_conf_dir}/${5GC000705-A_SCF}

Get Value from SCF
    ${nrarfcn}=  IF           '${CELL_TECHNOLOGY}' == 'TDD'
    ...                     scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-1                p_name=nrarfcn
    ...          ELSE
    ...                     scf.get_value_from_scf         dist_name=NRBTS-1/NRCELL-1/NRCELL_FDD-1   p_name=nrarfcnDl
    Set Suite Variable       ${nrarfcn}

Add Emergencycall in Nrcell
    [Arguments]    ${cell_id}=1
    scf.modify_scf_element    dist_name=NRBTS-1/NRCELL-${cell_id}    p_name=actEmergencyCall    value=true
    ${list_exist}=             scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=emergencyCallRestrictions
    IF            ${list_exist}==True
    ...                       scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=emergencyCallRestrictions
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=emergencyCallRestrictions
    ${ec_restriction}=        Create dictionary         emergencyCallMrListIgnore           true
    ...                                                 emergencyCallPlmnHoAllowed          true
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=emergencyCallRestrictions   elements=${ec_restriction}

Update Parameters in NRCELL
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    ${mo_exist}=     scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}     RETURN

    scf.modify_scf_element    dist_name=${dist_name}    p_name=filterCoeffSsbRsrp     value=fc4
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=sMeasConfigSsbRsrp
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf        dist_name=${dist_name}    p_name=sMeasConfigSsbRsrp              value=0
    ${element_exist}=         scf.is_element_in_object  dist_name=${dist_name}        p_name=absThreshSsbRsrpConsolidation
    IF            not ${element_exist}
    ...                       scf.add_element_to_scf        dist_name=${dist_name}    p_name=absThreshSsbRsrpConsolidation   value=0

    Add A3Meas to Nrcell        ${cell_id}
    Add A5Meas to Nrcell        ${cell_id}

Add A3Meas to Nrcell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=a3MeasEnabled     value=rsrp
    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=a3MeasSsbRsrp
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a3MeasSsbRsrp
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=a3MeasSsbRsrp
    ${a3Meas_rsrp}=           Create dictionary         a3HysteresisSsbRsrp           0
    ...                                                 a3OffsetSsbRsrp               3
    ...                                                 a3TimeToTriggerSsbRsrp        ms64
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a3MeasSsbRsrp   elements=${a3Meas_rsrp}

Add A5Meas to Nrcell
    [Arguments]      ${cell_id}=1
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-${cell_id}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=a5MeasEnabled     value=rsrp
    ${list_exist}=            scf.is_list_in_object  dist_name=NRBTS-1/NRCELL-${cell_id}     list_name=a5MeasSsbRsrp
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a5MeasSsbRsrp
    scf.add_list_to_scf       dist_name=NRBTS-1/NRCELL-${cell_id}    list_name=a5MeasSsbRsrp
    ${a5Meas_rsrp}=           Create dictionary         a5HysteresisSsbRsrp           10
    ...                                                 a5Threshold1SsbRsrp           70
    ...                                                 a5Threshold2SsbRsrp           40
    ...                                                 a5TimeToTriggerSsbRsrp        ms5120
    scf.add_item_to_list      dist_name=NRBTS-1/NRCELL-${cell_id}   list_name=a5MeasSsbRsrp   elements=${a5Meas_rsrp}

Modify NRDRB15 in SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB-15
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}    Fail    NRDRB-15 missing
    FOR   ${p_name}                         ${value}      IN
    ...   actDddsReduction                  false
    ...   discardTimer                      1500ms
    ...   dlFlowControlAlgo                 none
    ...   dscp                              0
    ...   maxDddsPeriodCpuOvld              40
    ...   nrDrbMacDN                        MRBTS-1/NRBTS-1/NRDRB_MAC-3
    ...   nrDrbPdcpDN                       MRBTS-1/NRBTS-1/NRDRB_PDCP-3
    ...   nrDrbRlcUmDN                      MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
    ...   numSduDiscard                     1
    ...   queuingDelaySduDiscardThreshold   200
    ...   resType                           GBR
    ...   rlcMode                           RLC_UM
    ...   schedulWeight                     1
    ...   sduDiscardIntervalTmr             500
    ...   actLostPduFastRetx                false
    ...   maxRlcQueueingDelayGbr            20
    ...   maxTransferDelayGbr               20
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Modify NRDRB5QI6 in SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_5QI-6
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}    Fail    NRDRB_5QI-6 missing
    scf.remove_list_from_scf    dist_name=${dist_name}    list_name=fiveqiValueList
    ${param_list}=    Create List  1
    scf.add_list_to_scf    dist_name=${dist_name}    list_name=fiveqiValueList
    scf.add_elements_to_list  dist_name=${dist_name}  list_name=fiveqiValueList   elements=${param_list}
    scf.modify_scf_element    dist_name=${dist_name}    p_name=nrDrbDN    value=MRBTS-1/NRBTS-1/NRDRB-15

Modify NRDRBRMAC3 in SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_MAC-3
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}    Fail    NRDRB_MAC-3 missing
    FOR   ${p_name}                         ${value}      IN
    ...   lcgid                             4
    ...   schedulPrio                       12
    ...   prioritisedBitRate                16kBps
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRDRBPDCP3 to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_PDCP-3
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf    class_name=NRDRB_PDCP    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cuFlowControlProfId               1
    ...   maxCidAllowed                     4
    ...   pdcpBufDiscardEnabled             false
    ...   pdcpBufDiscardThreshold           20000
    ...   tReorderingDl                     ms300
    ...   tReorderingUl                     ms300
    ...   pdcpDelayThreshRetxMode           disabled
    ...   x2FlowControlProfIdForCu          1
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Modify NRDRBRLCUM1 in SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRDRB_RLC_UM-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    not ${mo_exist}    Fail    NRDRB_RLC_UM-1 missing
    FOR   ${p_name}                         ${value}      IN
    ...   dlTReassemblyUm                   ms40
    ...   rlcUMDrbSNLength                  rlcUm12bitSN
    ...   ulTReassemblyUm                   ms40
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRREL to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRCELL-1/NRREL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRREL          dist_name=${dist_name}                version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellIndividualSsbRsrpOffset       0dB
    ...   cellIndividualSsbRsrqOffset       0dB
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   handoverAllowedSA                 allowed
    ...   lcrId                             1
    ...   removeNotAllowed                  false
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn                     elements=${plmn}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=nrDcAllowed                    value=false
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=handoverAllowedSARedCap        value=forbidden
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=isRplCellForPSCell             value=false

Add NRADJGNB to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJGNB-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRADJGNB       dist_name=${dist_name}        version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   administrativeState               Unlocked
    ...   gNbIdLength                       22
    ...   gNodeBId                          3
    ...   xnLinkRef                         1
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn             elements=${plmn}
    IF    '${SW_BRANCH}' != 'SBTS22R3'
    ...    scf.add_element_to_scf    dist_name=${dist_name}        p_name=gNodeBIdCtrl   value=oamControlled

Add NRADJGNB to SCF NoXn
    ${dist_name}=    Set Variable    NRBTS-1/NRADJGNB-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRADJGNB       dist_name=${dist_name}        version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   administrativeState               Unlocked
    ...   gNbIdLength                       22
    ...   gNodeBId                          3
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn             elements=${plmn}
    IF    '${SW_BRANCH}' != 'SBTS22R3'
    ...    scf.add_element_to_scf    dist_name=${dist_name}        p_name=gNodeBIdCtrl   value=oamControlled

Add NRADJNRCELL to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRADJNRCELL-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRADJNRCELL    dist_name=${dist_name}    version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   cellDepType                       SA
    ...   fiveGsTac                         200
    ...   gNbId                             3
    ...   gNbIdLength                       22
    ...   lcrId                             1
    ...   nrarfcn                           ${nrarfcn}
    ...   physCellId                        48
    ...   cellReservedForOperatorUse        notReserved
    Set Element   ${dist_name}  ${p_name}  ${value}
    END
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gnbPlmn
    scf.add_item_to_list      dist_name=${dist_name}    list_name=gnbPlmn         elements=${plmn}


Add NRANR to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRANR-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRANR       dist_name=${dist_name}        version=${NIDD_VERSION}
    ${list_exist}=            scf.is_list_in_object  dist_name=${dist_name}     list_name=gNbIdLengthConfig
    IF            ${list_exist}==True    scf.remove_list_from_scf  dist_name=${dist_name}   list_name=gNbIdLengthConfig
    scf.add_list_to_scf       dist_name=${dist_name}    list_name=gNbIdLengthConfig
    ${gNbIdLengthConfig}    Create dictionary  gNbIdLength  22  nrPlmnDN  MRBTS-1/NRBTS-1/NRPLMN-1  priorityIndex  1
    scf.add_item_to_list      dist_name=${dist_name}   list_name=gNbIdLengthConfig   elements=${gNbIdLengthConfig}
    FOR   ${p_name}                         ${value}      IN
    ...   actAutoNrNbRemoval                false
    ...   consecHoFailThres                 3
    ...   actAutoEutraNbRemoval             false
    ...   consecHoFailThresEutra            3
    ...   autoRecheckAttempts               0
    ...   autoRecheckInterval               30
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Add NRANRPR to SCF
    ${dist_name}=    Set Variable    NRBTS-1/NRANRPR-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF    ${mo_exist}   RETURN
    scf.add_object_to_scf     class_name=NRANRPR       dist_name=${dist_name}        version=${NIDD_VERSION}
    FOR   ${p_name}                         ${value}      IN
    ...   anrThresRsrpNbCell                -90
    ...   anrThresRsrqNbCell                -12
    ...   anrThresholdSelector              RSRP
    ...   cellDepMode                       SA
    ...   consecRecheckForNrNbRemoval       5
    ...   idleTimeForNrNbRemoval            72
    ...   maxNumAnrNrrelAllowed             50
    Set Element   ${dist_name}  ${p_name}  ${value}
    END

Update Parameters in XNLINK
    ${dist_name}=    Set Variable    NRBTS-1/XNLINK-1
    Set Object    class_name=XNLINK    dist_name=${dist_name}    version=${NIDD_VERSION}
    scf.add_element_to_scf    dist_name=NRBTS-1/XNLINK-1    p_name=cPlaneIpAddr     value=${XNIP_simulated_gNB}
    scf.add_element_to_scf    dist_name=${dist_name}    p_name=cPlaneIpAddrCtrl  value=oamControlled

Delete Parameters in XNLINK
    ${dist_name}=    Set Variable    NRBTS-1/XNLINK-1
    ${mo_exist}=    scf.is_object_in_scf    dist_name=${dist_name}
    IF  ${mo_exist}  scf.remove_mo_with_descendant_mos     dist_name=${dist_name}

Activate connected DRX and Fix Relation Error by adding suppCnPartialAdNgHo to default value
    [Documentation]    Default value of NIDD Parameters 'actEnhanceIntraNrIntraFreqAnr' and 'actSaIntraFreqAnrDrxProf' changed to true and are frozen
    ...    from 25R1 release onwards. Hence, to execute this test case with parameters (actEnhanceIntraNrIntraFreqAnr and actSaIntraFreqAnrDrxProf)
     ...   value true, connected Drx has to be activated in SCF, and UE capability need to be modified to support short/long DRx cycle.
    FOR   ${dist_name}                          ${p_name}                   ${value}                   IN
    ...   MRBTS-1/NRBTS-1/NRCELL-1              actCDrx                     true
    ...   MRBTS-1/NRBTS-1/NRCELL-2              actCDrx                     true
    ...   MRBTS-1/NRBTS-1/NRCELL-3              actCDrx                     true
    ...   MRBTS-1/NRBTS-1/NRCELL-4              actCDrx                     true
    ...   MRBTS-1/NRBTS-1                       suppCnPartialAdNgHo         false
          Set Element    dist_name=${dist_name}    p_name=${p_name}    value=${value}
    END
