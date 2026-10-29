*** Settings ***
Resource  ../../../robotlte_legacy/hran_ta/resources/ca_delta_resource.robot
Resource  ../../../robotlte_legacy/bbpool_allocation.robot

*** Variables ***
${IGNORE_ERRORS}               ${FALSE}
${RECOMMISSIONING_TIMEOUT}     600
${STARTUP_TIMEOUT}             ${EMPTY}
${DELTA_CUSTOM_NAME}           ${EMPTY}
${COUNT_CELLS_OFF}             ${EMPTY}
${BTS_ID}                      ${EMPTY}
${DELTA_JSON_PATH}             ${EMPTY}
${BBMOD_PRODUCT_CODE}          ${EMPTY}
${BBMOD_SN}                    ${EMPTY}

*** Keywords ***
Cheking If Delta Json Files Exist
    [Documentation]
    ...  Description:
    ...  Checking if delta json files required to perform Delta Commissioning have been created.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

    ${files_json}=  Create List
    ${files_json}=  List Files In Directory  ${DELTA_JSON_PATH}
    ${count_files_json}=  Count Items In Directory  ${DELTA_JSON_PATH}
    Should Not Be Empty  ${files_json}
    ...  msg=Delta file not exist. Set correct path to delta.
    Should Be Equal As Integers  ${count_files_json}  3
    ...  msg=Test requires adding 3 delta json files.

Checking If BBPOOLALLOC-0 For Reconfigurations Cells Exists
    [Documentation]
    ...  Description:
    ...  Check if required objects BBPOOLALLOC-0 exist.
    ...  BBPOOLALLOC-0 should be created for reconfigured cells
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

    ${json}=  OperatingSystem.Get File  path=${DELTA_JSON_PATH}/delta_manual_mode_exceeding_Loki_capacity.json
    ${json}=  Evaluate  json.loads('''${json}''')  json
    ${scfc_file}  scf.load scf  ${cfg.NODES['${BTS_ID}']['scf_file_path']}
    Set Test Variable  ${scfc_file}  ${scfc_file}
    Set Test Variable  ${BBMOD_PRODUCT_CODE}  ${ABIO_product_code}
    ${bbmod_sn_cablinks}=  Check Hardware Connection Cell On ABIO  ${cfg.NODES['${BTS_ID}']['scf_file_path']}  ${BTS_ID}
    ${lncel_id_list}=  Get From Dictionary  ${bbmod_sn_cablinks['${BBMOD_SN}']}  lncel
    Set Test Variable  ${lncel_id_list}  ${lncel_id_list}
    ${cell_mode_dict}=  Create Dictionary
    ${cell_mode_list}=  Create List
    ${managedObject}  Set Variable  managedObject[@class='NOKLTE:BBPOOLALLOC'
    FOR  ${cell}  IN  @{lncel_id_list}
        ${distName}=  Get From Dictionary  ${cfg.NODES['${BTS_ID}']['LNCEL']['${cell}']}  scf_dist_name
        ${cell_mode}=  Run Keyword And Continue On Failure
        ...  Evaluate Xpath  ${cfg.NODES['${BTS_ID}']['scf_file_path']}
        ...  string(.//${managedObject} and contains (@distName, "${distName}/")]/p[@name="bbPoolAllocMode"])
        ${cell_mode}=
        ...  Set Variable If  '${cell_mode}'!='[]'  ${cell_mode}  ${EMPTY}
        Set To Dictionary  ${cell_mode_dict}  ${cell}=${cell_mode}
        Append To List  ${cell_mode_list}  ${cell_mode}
    END
    Should Not Be Empty  ${cell_mode_list}  BBPOOLALLOC not exist. Set correct object to scf.

Checking If ActBbPooling Is Set To 'True'
    [Documentation]
    ...  Description:
    ...  Check if required parameter ActBbPooling is set to 'True'.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

    ${parameter}=    Run Keyword And Continue On Failure
    ...  Evaluate Xpath  ${cfg.NODES['${BTS_ID}']['scf_file_path']}
    ...  string(.//*[@distName="MRBTS-${BTS_ID}/LNBTS-${BTS_ID}"]/child::*[@name="actBbPooling"]/text())
    Should Be Equal As Strings  ${parameter}  true  actBbpooling must be 'true'. Set correct value parameter.

Preparing Variables For Delta Json File
    [Documentation]
    ...  Description:
    ...  Preparing variables for configuration in Delta json file.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

   Set Test Variable    ${DELTA_JSON_PATH}     ${DELTA_JSON_PATH}/delta_manual_mode_exceeding_Loki_capacity.json
   ${json}=  OperatingSystem.Get File  path=${DELTA_JSON_PATH}
   ${delta_json_file}=  Evaluate  json.loads('''${json}''')  json
   Set Test Variable  ${DELTA_JSON_FILE}  ${delta_json_file}
   Set Test Variable  ${DELTA_FOR_RECOMM}  ${DELTA_JSON_PATH}

Validate SCF Exclude Delta Json File
    [Documentation]
    ...  Description:
    ...  KW 'Validate Delta Against SCF' cheking if configuration contain
    ...  in delta json file is exluded in current SCF before changing configuration.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

   ${SCF_XML}=  scf.load scf  ${cfg.NODES['${BTS_ID}']['scf_file_path']}
   Set Test Variable  ${SCF_XML}
   Validate Delta Against SCF  excluded

Validate SCF Included Delta Json File
    [Documentation]
    ...  Description:
    ...  KW 'Validate Delta Against SCF' cheking if configuration contain
    ...  in delta json file is included in current SCF after changing configuration.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

   ${SCF_XML}=  Get Current SCF File  ${cfg.test_logs_path}  SCF_recommissioning4.xml  connection=${BTS_ID}
   Set Test Variable  ${SCF_XML}
   Validate Delta Against SCF  included

Checking If Expected Fault Exists
    [Documentation]
    ...  Description:
    ...  Checking if expected faults occurred on cells.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com

   Create Variables For Json Parameters
   Create Variables For Current Scf Parameters
   Create Variables For Json Cells Distname
   Create Variables For Current Scf Cells Distname
   Checking If Expected Faults On Cells In Current Scf

Create Variables For Json Parameters
    [Documentation]
    ...    Description:
    ...    Preparing variables for parameters in Delta json file.
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com

   ${cell_parameters_json_list}=  Create List
   FOR  ${json_parameter}  IN  @{DELTA_JSON_FILE}
     ${json_parameter_targetId}=  Set Variable  ${json_parameter['parameters'][1]}
     Run Keyword If  "${json_parameter_targetId['value']}"!= "[]"
     ...    Append To List  ${cell_parameters_json_list}  ${json_parameter_targetId['value']}
   END
   ${count_vol_targid_json}=  Count Values In List  ${cell_parameters_json_list}  ${json_parameter_targetId['value']}
   Set Test Variable  ${count_vol_targid_json}  ${count_vol_targid_json}

Create Variables For Current Scf Parameters
    [Documentation]
    ...    Description:
    ...    Preparing variables for parameters in Current Scf.
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com

   ${cellTargetId_list}=  Create List
   ${cellnullTargetId_list}=  Create List
   FOR  ${cell_scf}  IN  @{lncel_id_list}
      ${distnameconf}  Set Variable  @name="bbPoolTargetId"]/text()
      ${cell_bbPoolTargetId_value}=  Evaluate Xpath   ${SCF_XML}
      ...  .//*[@distName="MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${cell_scf}/BBPOOLALLOC-0"]/child::*[@name="bbPoolTargetId"]/text()
      Run Keyword If  "${cell_bbPoolTargetId_value}"=="[]"  Run Keyword
      ...  Append To List  ${cellnullTargetId_list}  ${cell_bbPoolTargetId_value}
      ...  ELSE
      ...  Append To List  ${cellTargetId_list}  ${cell_bbPoolTargetId_value}
   END
   ${count_volues_nullparameters_targetid_scf}=  Get Length   ${cellnullTargetId_list}
   ${count_volues_parameters_targetid_scf}=  Count Values In List  ${cellTargetId_list}  ${cell_bbPoolTargetId_value}

   ${suma_targetId_scf_list}=  Combine Lists  ${cellTargetId_list}  ${cellnullTargetId_list}
   ${count_suma_targetId_scf_list}=  Combine Lists  ${suma_targetId_scf_list}  ${cell_bbPoolTargetId_value}
   ${COUNT_CELLS_OFF_int}=  Convert To Integer  ${COUNT_CELLS_OFF}
   Should Be Equal  ${COUNT_CELLS_OFF_int}  ${count_volues_nullparameters_targetid_scf}
   ...  msg= Number cells with fault 1868 is not equal ${COUNT_CELLS_OFF}

Create Variables For Json Cells Distname
    [Documentation]
    ...    Description:
    ...    Preparing variables for distname in Delta json file.
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com

    ${lncel_id_json_list}=  Create List
    ${cell_distname_json_list}=  Create List
    FOR  ${json_object}  IN  @{DELTA_JSON_FILE}
      ${lncel_id_json}=  Should Match Regexp  ${json_object['distName']}  LNCEL-(\\d+)
       Append To List  ${cell_distname_json_list}  ${json_object['distName']}
       Append To List  ${lncel_id_json_list}  ${lncel_id_json}[-1]
    END
    Set Test Variable  ${LNCEL_id_json_list}  ${lncel_id_json_list}

Create Variables For Current Scf Cells Distname
    [Documentation]
    ...    Description:
    ...    Preparing variables for distname in Current Scf.
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com

    ${lcr_id_list}=  Evaluate Xpath  ${SCF_XML}
    ...  .//managedObject[@class='LNCEL' or @class='NOKLTE:LNCEL']/p[@name='lcrId']/text()
    ${lncel_id_list}=  Create List
    ${lncel_dist_name_list}=  Create List
    FOR  ${lcr_id}  IN  @{lcr_id_list}
       ${lncel_dist_name}=  Evaluate Xpath  ${SCF_XML}
        ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='lcrId']='${lcr_id}']/@distName
       ${lncel_id}=  Should Match Regexp  @{lncel_dist_name}[0]  LNCEL-(\\d+)
       Append To List  ${lncel_id_list}  @{lncel_id}[1]
       Append To List  @{lncel_dist_name_list}  ${lncel_dist_name}
    END
    Set Test Variable  ${lncel_dist_name_list}  ${lncel_dist_name_list}
    List Should Contain Sub List  ${lncel_id_list}  ${LNCEL_id_json_list}

Checking If Expected Faults On Cells In Current Scf
    [Documentation]
    ...    Description:
    ...    Cheking if expected faults appeared on reconfiguration cells.
    ...    Expect fault 1868 will appear on cells in count indicated in variable ${COUNT_CELLS_OFF}
    ...
    ...    |  **Author:**      daria.wronska@nokia.com
    ...    |  **Maintainer:**  daria.wronska@nokia.com

   ${cells_dist_list}=  Create List
   FOR  ${cell}  IN  @{lncel_id_list}
        ${distname}=  Evaluate Xpath  ${SCF_XML}
        ...  .//managedObject[(@class='LNCEL' or @class='NOKLTE:LNCEL') and p[@name='lcrId']='${cell}']/@distName
        ${cell_bbPoolTargetId_value}=  Evaluate Xpath  ${SCF_XML}
        ...  .//*[@distName="${distname}/BBPOOLALLOC-0"]/child::*[@name="bbPoolTargetId"]/text()
        Run Keyword If  "${cell_bbPoolTargetId_value}"=="[]"  Run Keywords
        ...  Assert Alarm Active
        ...  parameters=faultId=1868, severity=Minor, alarmingObjectIds[0].configuration=${distname}  timeout=180  connection=${BTS_ID}
        ...  AND  Add Allowed Alarm
        ...  parameters=faultId=1868, severity=Minor, alarmingObjectIds[0].configuration=${distname}   connection=${BTS_ID}
   END

