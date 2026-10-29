*** Settings ***
Library     ta_uexgate
Library     ta_messaging
Library     ta_emss
Library     taf.ul.ue.sim.env_setup
Library     CNI144125_cell_trace.py
Resource    ../../resources/Keywords/configuration_id.robot
Resource    ../../resources/Keywords/tsharkPcapVerifyKeywords.robot


Resource   ta_messaging/flow.robot

Documentation
...              :authors: Divyanshi
...              :contact: divyanshi.gupta@nokia.com

*** Keywords ***
Prepare test environment for suite
    Add simulator            sim_type=cus    config=${cus_yaml}
    Add eNB configuration    scfc=${scfc}
    Configure environment
    Setup emss               enb_id=1
    RTPM activate
    Create aliases

Create aliases
    Create enb alias    alias=eNB_1     enb_id=1  id_type=wts
    Create MME alias    alias=MME_1    mme_id=1  id_type=wts
    Create MME alias    alias=MME_2    mme_id=2  id_type=wts
    Create MME alias    alias=MME_3    mme_id=3  id_type=wts

Prepare cell trace
    Cell trace activate     s  enb_id=1
    Cell trace format   dump_json=True
    Cell trace start

Trigger MME_${mme_id} to send WriteReplaceWarningRequest with MessageId ${msg_id} for ETWS for Emergency Area ${eaid}
    Run WTS command  mme_warn_request  enb=1 mme=${mme_id} msg_id=${msg_id} data_coding_scheme=1 concurrent=off
    ...              warn_msg_contents=xxx rep_period=80 number=7 eaid=00000${eaid}

Trigger MME_${mme_id} to send WriteReplaceWarningRequest with MessageId ${msg_id} for CMAS for Emergency Area ${eaid}
    Run wts command  mme_warn_request  enb=1 mme=${mme_id} msg_id=${msg_id} warn_msg_contents_length=320
    ...              rep_period=80 number=5 data_coding_scheme=1 eaid=00000${eaid}

Verify that WriteReplaceWarningResponse contained emergencyAreaId equal to ${eaid}
    ${flow_alias}=  Get flow name
    ...     procedure=writeReplaceWarning
    ...     device=MME_1

    Verify that message fulfills query
    ...    emergencyAreaID-Broadcast contains (emergencyAreaID eq '0x00000${eaid}')
    ...    message_alias=WriteReplaceWarningResponse
    ...    flow_alias=${flow_alias}

Verify that WriteReplaceWarningResponse contained completedCellinEAI with cells
    [Arguments]     @{cells}
    FOR  ${cell_id}  IN  @{cells}
        Verify that cell-${cell_id} was present in completedCellinEAI
    END
    Log to console    WRWR transmission started on cells @{cells}\n

Verify that cell-${cell_id} was present in completedCellinEAI
    ${flow_alias}=  Get flow name
    ...     procedure=writeReplaceWarning
    ...     device=MME_1
    ${cell_id_bin}=  Evaluate  format(${cell_id}, 'b').zfill(3)

    Verify that message fulfills query
    ...     completedCellinEAI contains (cell-ID eq '0b0000000000000000000100000${cell_id_bin}')
    ...     message_alias=WriteReplaceWarningResponse
    ...     flow_alias=${flow_alias}

Enable PWS Restart and Failure Indications (CB006495)
    Log to console    Enabling PWS Restart and Failure Indications (CB006495)\n
    Change eNB parameter value  LNBTS-1.actPwsRstrtFlrInd  true

Disable PWS Restart and Failure Indications (CB006495)
    Log to console    Disabling PWS Restart and Failure Indications (CB006495)\n
    Change eNB parameter value  LNBTS-1.actPwsRstrtFlrInd  false

Lock cell-${cell_id}
    Log to console    Locking cell-${cell_id}\n
    Change eNB parameter value    LNCEL-${cell_id}.administrativeState    locked

Unlock cell-${cell_id}
    Log to console    Unlocking cell-${cell_id}\n
    Change eNB parameter value    LNCEL-${cell_id}.administrativeState    unlocked

Lock cells 1 and 4
    Log to console    Locking cells 1 and 4\n
    Configure eNB    ${CURDIR}/../config/yaml/lock_cells_1_and_4.yaml

Add cell-2 to Emergency Area 1
    Log to console    Adding cell-2 to Emergency Area 1
    Configure eNB    ${CURDIR}/../config/yaml/emAreaId_cell_2_add.yaml

Add cell-4 to Emergency Area 1
    Log to console    Adding cell-4 to Emergency Area 1
    Configure eNB    ${CURDIR}/../config/yaml/emAreaId_add.yaml

Move cell-2 to Emergency Area 2 and cell-5 to Emergency Area 1
    Log to console    Moving cell-2 to Emergency Area 2 and cell-5 to Emergency Area 1\n
    Configure eNB    ${CURDIR}/../config/yaml/swap_cells_between_eas.yaml

Enable CMAS
    Log to console    Enabling CMAS\n
    Configure eNB    ${CURDIR}/../config/yaml/cmas_act.yaml

Enable ETWS
    Log to console    Enabling ETWS\n
    Configure eNB    ${CURDIR}/../config/yaml/etws_act.yaml

Configure MOCN
    Log to console    Configuring MOCN\n
    Configure eNB    ${CURDIR}/../config/yaml/furtherPlmn_act.yaml

Unlock cell-1, enable ETWS and remove cell-2 from Emergency Area 1
    Log to console    Unlocking cell-1, enabling ETWS and removing cell-2 from Emergency Area 1
    Configure eNB    ${CURDIR}/../config/yaml/2nd_part_prepare.yaml
    Wait for eNB on air      timeout=600

Unlock cell-1, enable ETWS and remove cell-4 from Emergency Area 1
    Log to console    Unlocking cell-1, enabling ETWS and removing cell-5 from Emergency Area 1
    Unlock cell-1
    Wait for eNB on air      timeout=600
    Configure eNB    ${CURDIR}/../config/yaml/2nd_part_prepare_fsmf.yaml
    Wait for eNB on air      timeout=600

Configure eNB for robustness test
    Log to console    Configuring eNB for robustness test
    Configure eNB    ${CURDIR}/../config/yaml/robustness_prep.yaml

Configure eNB for FSMF regression test
    Log to console    Configuring eNB for FSMF regression test
    Configure eNB    ${CURDIR}/../config/yaml/fsmf_regression_prep.yaml

Verify that PWS${message:Restart|Failure}Indication sent to MME_${mme_id} contained Global-ENB-ID and PLMNidentity equal to ${enb_id} and ${plmn}
    ${enb_id_bin}=    Evaluate    format(${enb_id}, 'b').zfill(3)
    ${flow_alias}=  Get flow name
    ...     procedure=pWS${message}Indication
    ...     device=MME_${mme_id}

    Verify that message fulfills query
    ...     Global-ENB-ID contains (
    ...     pLMNidentity eq "${plmn}"
    ...     and
    ...     eNB-ID contains (macroENB-ID eq "0b00000000000000000${enb_id_bin}"))
    ...     message_alias=PWS${message}Indication
    ...     flow_alias=${flow_alias}

Verify that PWSRestartIndication sent to MME_${mme_id} contained TAIListForRestart with ${tac} present
    ${tac_hex}=    Evaluate    format(${tac}, 'x').zfill(4).upper()
    ${flow_alias}=  Get flow name
    ...     procedure=pWSRestartIndication
    ...     device=MME_${mme_id}

    Verify that message fulfills query
    ...     TAIListForRestart contains (tAC eq "0x${tac_hex}")
    ...     message_alias=PWSRestartIndication
    ...     flow_alias=${flow_alias}

Verify that PWSRestartIndication sent to MME_${mme_id} contained ECGIListForRestart with data of cell-${cell_id} present
    ${cell_id_bin}=  Evaluate  format(${cell_id}, 'b').zfill(3)
    ${flow_alias}=  Get flow name
    ...     procedure=pWSRestartIndication
    ...     device=MME_${mme_id}

    Verify that message fulfills query
    ...     ECGIListForRestart contains (cell-ID eq '0b0000000000000000000100000${cell_id_bin}')
    ...     message_alias=PWSRestartIndication
    ...     flow_alias=${flow_alias}

    Log to console    PWSRestartIndication with data of cell-${cell_id} sent to MME_${mme_id}\n

Verify that PWSRestartIndication sent to MME_${mme_id} contained EmergencyAreaIDListForRestart with ${eaid} present
    ${flow_alias}=  Get flow name
    ...     procedure=pWSRestartIndication
    ...     device=MME_${mme_id}

    Verify that message fulfills query
    ...     EmergencyAreaIDListForRestart contains ("0x00000${eaid}")
    ...     message_alias=PWSRestartIndication
    ...     flow_alias=${flow_alias}

Verify that PWSFailureIndication sent to MME_${mme_id} contained PWSfailedECGIList with data of cell-${cell_id} present
    ${cell_id_bin}=  Evaluate  format(${cell_id}, 'b').zfill(3)
    ${flow_alias}=  Get flow name
    ...     procedure=pWSFailureIndication
    ...     device=MME_${mme_id}

    Verify that message fulfills query
    ...     PWSfailedECGIList contains (cell-ID eq '0b0000000000000000000100000${cell_id_bin}')
    ...     message_alias=PWSFailureIndication
    ...     flow_alias=${flow_alias}

    Log to console    PWSFailureIndication with data of cell-${cell_id} sent to MME_${mme_id}\n
