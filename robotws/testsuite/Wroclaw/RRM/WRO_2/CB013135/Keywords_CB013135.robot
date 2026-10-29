*** Settings ***
Documentation    :copyright: Nokia
...              :authors: I_L3_WRO_PSI_ET_GMS
...              :contact: I_L3_WRO_PSI_ET@nokia.com

*** Keywords ***
Expect SCell ToBeSetupMod And ToAddModList
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect Message Flow
    ...    gNB${gnb_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContModRequest
    ...    gNB${gnb_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContModResponse
    ...    alias=SCellAddition_UE${ue_id}   overall_timeout=60

Attach UE And Expect Establishing PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}

    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}

    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}

    Check If PDU Messages Flow Occurred     ue_id=${ue_id}

Verify ULTxSwitching
    [Arguments]    ${ue_id}    ${physcellid_to_verify}    ${num_of_reportConfigId}    ${pcell_type}
    Verify That Message Has Fields
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId}
    ...  uplinkTxSwitchingOption-r16 eq "switchedUL"
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    run keyword if
    ...  '${pcell_type}' == 'TDD'    Run TDD ULTxSwitching Verification    ${ue_id}    ${physcellid_to_verify}     ${num_of_reportConfigId}
    ...  ELSE IF    '${pcell_type}' == 'FDD'    Run FDD ULTxSwitching Verification    ${ue_id}    ${physcellid_to_verify}     ${num_of_reportConfigId}
    ...  ELSE    Fail    'pcell_type value should be TDD or FDD. Received value is: ${pcell_type}'

Run TDD ULTxSwitching Verification
    [Arguments]    ${ue_id}    ${physcellid_to_verify}    ${num_of_reportConfigId}
    Verify That Message Has Fields
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId}
    ...  uplinkConfig..uplinkTxSwitchingPeriodLocation-r16 eq "TRUE"
    ...  uplinkConfig..uplinkTxSwitchingCarrier-r16 eq "carrier1"
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    Verify That Message Fulfills Query
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId} and
    ...  sCellToAddModList contains
    ...  (
    ...    physCellId eq ${physcellid_to_verify} and
    ...    uplinkTxSwitchingPeriodLocation-r16 eq "FALSE" and
    ...    uplinkTxSwitchingCarrier-r16 eq "carrier2" and
    ...    maxRank eq 2 and
    ...    nrofSRS-Ports eq "ports2"
    ...  )
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Run FDD ULTxSwitching Verification
    [Arguments]    ${ue_id}    ${physcellid_to_verify}    ${num_of_reportConfigId}
    Verify That Message Has Fields
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId}
    ...  uplinkConfig..uplinkTxSwitchingPeriodLocation-r16 eq "FALSE"
    ...  uplinkConfig..uplinkTxSwitchingCarrier-r16 eq "carrier2"
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    Verify That Message Fulfills Query
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId} and
    ...  sCellToAddModList contains
    ...  (
    ...    physCellId eq ${physcellid_to_verify} and
    ...    uplinkTxSwitchingPeriodLocation-r16 eq "TRUE" and
    ...    uplinkTxSwitchingCarrier-r16 eq "carrier1" and
    ...    maxRank eq 1 and
    ...    nrofSRS-Ports eq "port1"
    ...  )
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify SCell Addition Messages For CC
    [Arguments]    ${ue_id}    ${cc_nr_cell_identitiy}    ${cc_scell_physcell_id}    ${num_of_reportConfigId}
    FOR    ${nr_cell_identity}    IN    @{cc_nr_cell_identitiy}
        Verify That Message Has Fields
        ...  SCell-ToBeSetupMod-List..nRCellIdentity eq ${nr_cell_identity}
        ...  message_alias=UEContModRequest
        ...  flow_alias=SCellAddition_UE${ue_id}
    END

    Verify That Message Has Fields
    ...  length(csi-ReportConfigToAddModList) eq ${num_of_reportConfigId}
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

    FOR    ${scell_physcell_id}    IN    @{cc_scell_physcell_id}
        Verify That Message Has Fields
        ...  sCellToAddModList..physCellId eq ${scell_physcell_id}
        ...  message_alias=UEContModResponse
        ...  flow_alias=SCellAddition_UE${ue_id}
    END

Trigger A1 Measurement
    [Arguments]    ${ue_id}    ${meas_id}    ${srsrp_nr}    ${srsrq_nr}    ${timeout}=60
    Execute Egate Command And Wait For Data
    ...    cmd=ue_meas_cfg_disp id\=${ue_id}
    Execute Egate Command And Wait For Data
    ...    cmd=ue_measurement_send_nr id\=${ue_id} meas_id\=${meas_id} event\=A1 srsrp_nr\=${srsrp_nr} srsrq_nr\=${srsrq_nr}
    ...    pass_regexp=message c1 : rrcReconfigurationComplete
    ...    timeout=${timeout}

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}

Verify UE Capability from egate console log
    [Arguments]    ${egate_console_log_filename}    &{PATTERNS}
    ${result} =    find structure    ${egate_console_log_filename}    ${PATTERNS}
    check if dictionary contains empty list    ${result}

Check if dictionary contains empty list
    [Arguments]    ${result}
    FOR    ${key}    IN    @{result.keys()}
        ${value}=    Get From Dictionary    ${result}    ${key}
        Run Keyword If    ${value} == []    Fail    No log occurrences found of ${key} in egate_console.log
        Log    Key: ${key}, Value: ${value}
    END

Verify Selected Band Combination
    [Arguments]    ${ue_id}
    Verify That Message Has Fields
    ...  iE-Extensions..SelectedBandCombinationIndex eq "0x0003"
    ...  message_alias=UEContModResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

