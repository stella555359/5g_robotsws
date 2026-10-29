*** Settings ***

Resource    resources/ca_BSRF_general.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  admin

*** Variables ***

${SFP_YAML_PATH}

*** Keywords ***
TC__SiSo_PM_BTS_Fronthaul_SFP_Static_Parameters_Monitoring
  [Documentation]
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Purpose of this test is to verify that SFP fronthaul static parameters are correctly reported in WebEM.
  ...  SFP parameters are predefined in sfp_fronthaul.yaml file
  ...  TC compares values from sfp_fronthaul.yaml and WebEM, values must be the same
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 22.11.2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-17268 - Initial creation

  Set Tags    OWNER-mateusz.kawka@nokia.com
  ...         AUTHOR-mateusz.kawka@nokia.com
  ...         MAINTAINER-mateusz.kawka@nokia.com
  ...         PHASE-CRT
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_PM_BTS_Fronthaul_SFP_Static_Parameters_Monitoring will be executed
  ...  style=ONGOING
  Step 1: Prepare SFP_FRONTHAUL parameters data
  Step 2: Check SFP_FRONTHAUL parameters
  [Teardown]    Common Test Teardown

Step 1: Prepare SFP_FRONTHAUL parameters data
    Log To Console  Step 1: Get config parameters
    ${file_exists}  Run Keyword And Return Status
    ...  OperatingSystem.file should exist  ${SFP_YAML_PATH}
    Run Keyword If  '${file_exists}'!='True'
    ...  Fail  SFP_fronthaul.yaml doesn't exists, please create file first !
    ...  ELSE
    ...  Log To Console  File SFP_fronthaul.yaml found in path:${\n}${SFP_YAML_PATH} !${\n}

    Import Variables  ${SFP_YAML_PATH}

    ${links}  admin.Get SFP Links  connection=${node}
    ${rf_links}  Set Variable  ${links['connected']}
    Set Test Variable  ${RF_LINKS}

Step 2: Check SFP_FRONTHAUL parameters

    Log To Console  Step 2: Check SFP parameters

    FOR  ${sfp_yaml_serial}  ${sfp_yaml_values}  IN ZIP  ${SFP_FRONTHAUL.keys()}  ${SFP_FRONTHAUL.values()}
        Log to Console  ${\n}Checking: ${sfp_yaml_serial}${\n}
        ${sfp_serial_yaml}  Get From Dictionary  ${sfp_yaml_values}  serialNumber
        ${sfp_direction_yaml}  Get From Dictionary  ${sfp_yaml_values}  physicalPort
        ${direction_details}  Set Variable If  'RF' in '${sfp_direction_yaml}'  destination  source
        ${direction_maxtrans}  Set Variable If  'RF' in '${sfp_direction_yaml}'  0  2
        ${details}  ${max_transmission_distance}  Prepare API Data For Specific SFP  ${sfp_serial_yaml}
        Check Details Parameters For SFP  ${sfp_yaml_values}  ${details}  ${direction_details}
        ${max_trans_yaml}  Get From Dictionary  ${sfp_yaml_values}  maxTransmissionDistanceList
        ${max_trans_yaml}  Evaluate  {k: v for d in ${max_trans_yaml} for k, v in d.items()}
        Check MaxTransmissionDictanceList Parameters For SFP
        ...  ${max_trans_yaml}  ${max_transmission_distance}  ${direction_maxtrans}
    END

Check Details Parameters For SFP
    [Arguments]  ${sfp_yaml_values_dict}  ${details}  ${direction}

    FOR  ${sfp_yaml_parameter}  ${sfp_yaml_value}  IN ZIP  ${sfp_yaml_values_dict.keys()}  ${sfp_yaml_values_dict.values()}
        Continue For Loop If  '${sfp_yaml_parameter}'=='maxTransmissionDistanceList'
        ${admin_value}  Get From Dictionary  ${details}  ${sfp_yaml_parameter}
        ${admin_value}  Get From Dictionary  ${admin_value}  ${direction}
        ${admin_value}  Evaluate  '${admin_value}'.strip()
        ${is_int}  Evaluate  isinstance($sfp_yaml_value, (int, float))
        ${status}  Run Keyword And Return Status  Run Keyword If  ${is_int}
        ...  Should Be Equal As Numbers  ${admin_value}  ${sfp_yaml_value}
        ...  ELSE
        ...  Should Be Equal As Strings  ${admin_value}  ${sfp_yaml_value}
        Run Keyword If  ${status}
        ...  Log To Console  ${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value} -> OK !
        ...  ELSE
        ...  Run Keywords
        ...  Log To Console  ${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value} -> NOK !
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${sfp_yaml_parameter} mismatch between SFP_FRONTHAUL_YAML and WebEM !
    END

Check MaxTransmissionDictanceList Parameters For SFP
    [Arguments]  ${max_trans_yaml}  ${max_transmission_distance}  ${direction}

    FOR  ${max_dict}  IN  @{max_transmission_distance}
        ${values}  Get Dictionary Values  ${max_dict}
        ${values}  Get Dictionary Values  ${values}[${direction}]
        ${yaml_length}  Get From Dictionary  ${max_trans_yaml}  ${values}[1]
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${values}[0]  ${yaml_length}
        Run Keyword If  ${status}
        ...  Log To Console  ${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> OK !
        ...  ELSE
        ...  Run Keywords
        ...  Log To Console  ${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> NOK !
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${values}[1] mismatch between SFP_FRONTHAUL_YAML and WebEM !
    END


Prepare API Data For Specific SFP
    [Arguments]  ${sfp_serial_yaml}

    FOR  ${sfp}  IN  @{RF_LINKS}
        @{sn_list}  Create List
        ...  ${sfp['details']['hardwareParameters']['serialNumber']['source']}
        ...  ${sfp['details']['hardwareParameters']['serialNumber']['destination']}
        Continue For Loop If  '${sfp_serial_yaml}' not in ${sn_list}
        ${details}  Set Variable  ${sfp['details']}
        ${details}  Get Dictionary Values  ${details}
        ${details}  Evaluate  {k: v for d in ${details} for k, v in d.items()}
        ${max_transmission_distance}  Set Variable  ${sfp['details']['staticParameters']['maxTransmissionDistanceList']}
    END

    [Return]  ${details}  ${max_transmission_distance}
#
#TC Setup
#    #Common Test Setup
#    admin.Setup Admin
#
#TC Teardown
#    admin.Teardown Admin
#    #Common Test Teardown


