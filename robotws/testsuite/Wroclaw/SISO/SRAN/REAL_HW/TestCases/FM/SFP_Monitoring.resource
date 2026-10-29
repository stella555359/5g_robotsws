*** Settings ***
Documentation    Maintainer: lukasz.wystup@nokia.com

*** Keywords ***

Step${step_number}: Preconditions For SFP Monitoring
    Logging With Timestamp
    ...  message=Step1: Preconditions For SFP Monitoring
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    IF  '${RMOD_SN}'=='${EMPTY}'  Fail  Variable RMOD_SN cannot be empty!
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    RM Verify Serial Number  serial_number=${RMOD_SN}  connection=${BTS_ID}
    Logging With Timestamp  RMOD with SN -> ${RMOD_SN} found in HW Configuration

    ${rmods_info}  admin.Get FRM  60  ${BTS_ID}
    FOR  ${rmod}  IN  @{rmods_info}
      Continue For Loop If  '${RMOD_SN}' not in '${rmod['serialNumber']}'
      Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END
    Set Test Variable  ${OBJECT_VARIABLE_ACTTRANSCEIVER}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${param_value_dict}  Get Value For ActTransceiverAlarmMonitoring Parameter  ${object_variable_acttransceiver}
    Set Test Variable   ${REFERENCE_DICT}  ${param_value_dict}
    IF  '${cfg.RF_INFO['${RMOD_SN}']['scf_release_code']}'=='RRH-ORAN'
      Set Test Variable  ${PRECOND_FOR_CNI}  False
    ELSE
      FM_Faults.FM Preconditions For CNI-127210
    END

Step${step_number}: Set actTransceiverAlarmMonitoring To Transceiver Alarms And Warnings
    Logging With Timestamp
    ...  message=Step2: Set actTransceiverAlarmMonitoring To Transceiver Alarms And Warnings
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    IF  '${REFERENCE_DICT['actTransceiverAlarmMonitoring'].lower()}' == 'transceiver alarms and warnings'
      Logging With Timestamp  Transceiver alarms and warnings monitoring feature is already activated!\n
    ELSE
      Logging With Timestamp  Transceiver alarms and warnings monitoring feature is not active, activating ongoing...\n
      admin.Perform Parameter Recommissioning
      ...  dist_name=${object_variable_acttransceiver}
      ...  parameter=actTransceiverAlarmMonitoring
      ...  operation=update
      ...  value=Transceiver alarms and warnings
      ...  connection=${BTS_ID}
      STATE Check If All Cells Are OnAir  ${BTS_ID}
    END

Step${step_number}: Set actTransceiverAlarmMonitoring To Off
    Logging With Timestamp
    ...  message=Step2: Set actTransceiverAlarmMonitoring To Off
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    IF  '${REFERENCE_DICT['actTransceiverAlarmMonitoring'].lower()}' == 'off'
      Logging With Timestamp  Transceiver alarms and warnings monitoring feature is already inactive!\n
    ELSE
      Logging With Timestamp  Transceiver alarms and warnings monitoring feature is active, deactivating ongoing...\n
      admin.Perform Parameter Recommissioning
      ...  dist_name=${object_variable_acttransceiver}
      ...  parameter=actTransceiverAlarmMonitoring
      ...  operation=update
      ...  value=Off
      ...  connection=${BTS_ID}
      STATE Check If All Cells Are OnAir  ${BTS_ID}
    END

Get SFP Links Type By Radio Module
    [Arguments]  ${rmod_sn}  ${cable_dn_type}=internal
    [Documentation]
    ...  Description:
    ...  Keyword sets the SFP link type (primary/secondary) for cables connected to a specific radio module.
    ...
    ...  Arguments:
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | Argument           | Man.  | Description                                                                                   |
    ...  +====================+=======+===============================================================================================+
    ...  | rmod_sn            | Yes   | Serial number of the radio module to be processed.                                            |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...  | cable_dn_type      | No    | Type of cable distinguished name to use ('internal' or 'external').                           |
    ...  +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  +------------------------------------------+------------------------------------------------------------------------------------------+
    ...  | Return Value                             | Description                                                                              |
    ...  +==========================================+==========================================================================================+
    ...  | sfp_linkmode_dict                        | Dictionary mapping cable endpoint IDs to link type (primary/secondary).                  |
    ...  +------------------------------------------+------------------------------------------------------------------------------------------+
    ...  | cablink_distname_to_sfp_linkmode_dict    | Dictionary mapping cable IDs to link type (primary/secondary).                           |
    ...  +------------------------------------------+------------------------------------------------------------------------------------------+
    ...
    ...  Usage:
    ...  Get SFP Links Type By Radio Module    rmod_sn=SN123456789
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    ${bts}  admin.Get BTS Info  alias=${BTS_ID}
    FOR  ${rmod}  IN  @{bts['radioModules']['rmod']}
      Continue For Loop If  '${rmod['serialNumber']}'!='${rmod_sn}'
      ${rmod_distname_id}  Set Variable  ${rmod['id']['internal']}
    END

    ${sfp_linkmode_dict}  Create Dictionary
    ${cablink_distname_to_sfp_linkmode_dict}  Create Dictionary
    FOR  ${cable}  IN  @{bts['cables']}
      Continue For Loop If  '${rmod_distname_id}' not in '${cable['secondEndPointId']['internal']}'
      IF  '${cable['linkMode']['synchronization']}'=='True'
        Set To Dictionary  ${sfp_linkmode_dict}  ${cable['secondEndPointId']['${cable_dn_type}'][-1]}  primary
        Set To Dictionary  ${cablink_distname_to_sfp_linkmode_dict}  ${cable['id']['${cable_dn_type}']}  primary
      ELSE
        Set To Dictionary  ${sfp_linkmode_dict}  ${cable['secondEndPointId']['${cable_dn_type}'][-1]}  secondary
        Set To Dictionary  ${cablink_distname_to_sfp_linkmode_dict}  ${cable['id']['${cable_dn_type}']}  secondary
      END
    END

    [Return]  ${sfp_linkmode_dict}  ${cablink_distname_to_sfp_linkmode_dict}

Get Value For ActTransceiverAlarmMonitoring Parameter
    [Arguments]  ${object_variable_transceiver}
    [Documentation]
    ...  Description:
    ...  Keyword retrieves the value of the `actTransceiverAlarmMonitoring` parameter from SCF configuration for a given transceiver object.
    ...
    ...  Arguments:
    ...  +----------------------------+-------+--------------------------------------------------------------------------------------------+
    ...  | Argument                   | Man.  | Description                                                                                |
    ...  +============================+=======+============================================================================================+
    ...  | object_variable_transceiver| Yes   | Distinguished name of the transceiver object to query.                                     |
    ...  +----------------------------+-------+--------------------------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  +----------------------------+--------------------------------------------------------------------------------------------+
    ...  | Return Value               | Description                                                                                |
    ...  +============================+============================================================================================+
    ...  | param_value_dict           | Dictionary containing the value of `actTransceiverAlarmMonitoring` parameter.              |
    ...  |                            | Example: {'actTransceiverAlarmMonitoring': 'true'}                                         |
    ...  +----------------------------+--------------------------------------------------------------------------------------------+
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    ${param_value_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${parameter}
    ${actTransceiverAlarmMonitoring_scf}  Evaluate Xpath  ${scfc_xml}
    ...  string(.//managedObject[@distName='${object_variable_transceiver}']/p[@name='actTransceiverAlarmMonitoring']/text())
    Set To Dictionary  ${param_value_dict}  actTransceiverAlarmMonitoring  ${actTransceiverAlarmMonitoring_scf}
    [Return]  ${param_value_dict}

Restore Reference Configuration
    [Arguments]  ${reference_dict}  ${object_variable_transceiver}
    [Documentation]
    ...  Description:
    ...  Keyword restores the `actTransceiverAlarmMonitoring` parameter of a transceiver object to its reference value if it differs
    ...  from the current configuration.
    ...
    ...  Arguments:
    ...  +----------------------------+-------+--------------------------------------------------------------------------------------------+
    ...  | Argument                   | Man.  | Description                                                                                |
    ...  +============================+=======+============================================================================================+
    ...  | reference_dict             | Yes   | Dictionary containing the reference value for `actTransceiverAlarmMonitoring`.             |
    ...  +----------------------------+-------+--------------------------------------------------------------------------------------------+
    ...  | object_variable_transceiver| Yes   | Transceiver object whose parameter is to be verified and potentially restored.             |
    ...  +----------------------------+-------+--------------------------------------------------------------------------------------------+
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    Logging With Timestamp  Restore Reference Configuration...\n

    ${actual_dict}  Get Value For ActTransceiverAlarmMonitoring Parameter  ${object_variable_transceiver}
    IF  '${reference_dict['actTransceiverAlarmMonitoring'].lower()}' != '${actual_dict['actTransceiverAlarmMonitoring'].lower()}'
      Logging With Timestamp  Transceiver alarms and warnings monitoring feature have to be restored to reference state, please wait!\n
      admin.Perform Parameter Recommissioning
      ...  dist_name=${object_variable_acttransceiver}
      ...  parameter=actTransceiverAlarmMonitoring
      ...  operation=update
      ...  value=${reference_dict['actTransceiverAlarmMonitoring']}
      ...  connection=${BTS_ID}
      Logging With Timestamp
      ...  Transceiver alarms and warnings monitoring feature restored to actPowerMeter -> ${reference_dict['actTransceiverAlarmMonitoring']}
    ELSE
      Logging With Timestamp  Transceiver alarms and warnings monitoring featurealready in reference state, no more actions needed!
    END
