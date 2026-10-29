*** Settings ***

Resource    resources/ca_BSRF_general.robot

Library  taf.sbts.oam.coam.admin    WITH NAME    admin

*** Variables ***

${SFP_YAML_PATH}

*** Keywords ***
TC__SiSo_PM_BTS_Backhaul_SFP_Static_Parameters_Monitoring
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10510
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test is to verify that SFP backhaul static parameters are correctly reported in WebEM.
    ...  SFP parameters are predefined in sfp_backhaul.yaml file
    ...  TC compares values from sfp_backhaul.yaml and WebEM, values must be the same
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.11.2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-16204 - Initial creation

    Set Tags    OWNER-mateusz.kawka@nokia.com
    ...         AUTHOR-mateusz.kawka@nokia.com
    ...         MAINTAINER-mateusz.kawka@nokia.com
    ...         PHASE-CRT
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_PM_BTS_Backhaul_SFP_Static_Parameters_Monitoring will be executed
  ...  style=ONGOING
    Step 1: Prepare SFP_BACKHAUL parameters data
    Step 2: Check SFP_BACKHAUL parameters
  [Teardown]    Common Test Teardown



Step 1: Prepare SFP_BACKHAUL parameters data
    Log To Console  Step 1: Get config parameters
    ${file_exists}  Run Keyword And Return Status
    ...  OperatingSystem.file should exist  ${SFP_YAML_PATH}
    Run Keyword If  '${file_exists}'!='True'
    ...  Fail  SFP_backhaul.yaml doesn't exists, please create file first !
    ...  ELSE
    ...  Log To Console  File SFP_backhaul.yaml found in path:${\n}${SFP_YAML_PATH} !${\n}

    Import Variables  ${SFP_YAML_PATH}
    ${sfp_yaml_sn}  Set Variable  ${SFP_BACKHAUL['serialNumber']}

    ${links}  admin.Get SFP Links  connection=${node}
    ${eifs}  Set Variable  ${links['notConnected']}
    FOR  ${eif}  IN  @{eifs}
        ${sfp_sn}  Set Variable  ${eif['details']['hardwareParameters']['serialNumber']['source']}
        Run Keyword If  '${sfp_sn}'=='${sfp_yaml_sn}'  Run Keywords
        ...  Set Test Variable  ${SFP56}  ${eif}
        ...  AND  Exit For Loop
    END


Step 2: Check SFP_BACKHAUL parameters

    Log To Console  Step 2: Check SFP parameters${\n}

    ${details}  Set Variable  ${SFP56['details']}
    ${details}  Get Dictionary Values  ${details}
    ${details}  Evaluate  {k: v for d in ${details} for k, v in d.items()}
    ${max_transmission_distance}  Set Variable  ${SFP56['details']['staticParameters']['maxTransmissionDistanceList']}

    FOR  ${sfp_yaml_parameter}  ${sfp_yaml_value}  IN ZIP  ${SFP_BACKHAUL.keys()}  ${SFP_BACKHAUL.values()}
        Continue For Loop If  '${sfp_yaml_parameter}'=='maxTransmissionDistanceList'
        ${admin_value}  Get From Dictionary  ${details}  ${sfp_yaml_parameter}
        ${admin_value}  Get Dictionary Values  ${admin_value}
        ${is_int}  Evaluate  isinstance($sfp_yaml_value, (int, float))
        ${status}  Run Keyword And Return Status  Run Keyword If  ${is_int}
        ...  Should Be Equal As Numbers  ${admin_value}[0]  ${sfp_yaml_value}
        ...  ELSE
        ...  Should Be Equal As Strings  ${admin_value}[0]  ${sfp_yaml_value}
        Run Keyword If  ${status}
        ...  Log To Console  ${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value}[0] -> OK !
        ...  ELSE
        ...  Run Keywords
        ...  Log To Console  ${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value}[0] -> NOK !
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${sfp_yaml_parameter} mismatch between SFP_BACKHAUL_YAML and WebEM !
    END

    Log to console  ${\n}Checking Maximum Transmission Distance !${\n}

    ${maxTransmissionDistance_yaml}  Get From Dictionary  ${SFP_BACKHAUL}  maxTransmissionDistanceList
    ${maxTransmissionDistance_yaml}  Evaluate  {k: v for d in ${maxTransmissionDistance_yaml} for k, v in d.items()}
    FOR  ${max_dict}  IN  @{max_transmission_distance}
        ${values}  Get Dictionary Values  ${max_dict}
        ${values}  Get Dictionary Values  ${values}[1]
        ${yaml_length}  Get From Dictionary  ${maxTransmissionDistance_yaml}  ${values}[1]
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${values}[0]  ${yaml_length}
        Run Keyword If  ${status}
        ...  Log To Console  ${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> OK !
        ...  ELSE
        ...  Run Keywords
        ...  Log To Console  ${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> NOK !
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${values}[1] mismatch between SFP_BACKHAUL_YAML and WebEM !
    END

#TC Setup
#    Common Test Setup
#    Setup TAF Admin
#
#TC Teardown
#    Common Test Teardown
#    admin.Teardown Admin
