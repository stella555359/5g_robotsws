*** Settings ***
Documentation  This suite contains general KWs used by TCs form LOGs dir and resources.

Library         taf.nms.netact
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         taf.transport.ssh    WITH NAME    ssh
Library         python/ModifyXML.py
Library         python/admin_utils.py
Resource        verdicts.robot
Resource        bts_states.robot
Resource        ssh_utils.robot
Resource        verdicts.robot
Resource        bts_states.robot
Resource        infomodel.robot

*** Variables ***
${BUILD_PATH}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
&{srnclab1015}   cmwas=10.41.146.134    sn_node=10.41.146.121
&{srnclab1019}   cmwas=10.41.147.19     sn_node=10.41.147.2
&{srnclab1027}   cmwas=10.41.148.99     sn_node=10.41.148.82
&{srnclab1028}   cmwas=10.41.148.139    sn_node=10.41.148.122
&{srnclab1044}   cmwas=10.43.48.76      sn_node=10.43.48.59
&{srnclab1046}   cmwas=10.43.48.160     sn_node=10.43.48.146
&{srnclab1052}   cmwas=10.63.2.159      sn_node=10.63.2.142
&{srnclab1054}   cmwas=10.63.2.215      sn_node=10.63.2.202
&{srnclab1057}   cmwas=10.68.122.63     sn_node=10.68.122.50
&{srnclab2002}   cmwas=10.82.47.15      sn_node=10.82.47.2
&{srnclab2003}   cmwas=10.82.47.46      sn_node=10.82.47.33
&{srnclab2007}   cmwas=10.82.44.57      sn_node=10.82.44.44
&{srnclab3006}   cmwas=10.99.127.156      sn_node=10.99.127.143
&{srnclab3007}   cmwas=10.99.127.179      sn_node=10.99.127.166
&{srnclab3008}   cmwas=10.99.127.210      sn_node=10.99.127.197
&{srnclab1047}   cmwas=10.43.48.192       sn_node=10.43.48.179


&{netact_labs}   srnclab_1046=${srnclab1046}   srnclab_1019=${srnclab1019}
...   srnclab_1027=${srnclab1027}   srnclab_1028=${srnclab1028}   srnclab_1052=${srnclab1052}   srnclab_3006=${srnclab3006}

${smod_working_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"
${rmod_working_states}=    administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"

${OnAir_LTE_cells_expected_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${OnAir_WCDMA_cells_expected_states}=  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${OnAir_GSM_cells_expected_states}=   administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled",
    ...                               blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${NRCELLs_expected_states}=          administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${DEGRADED_CELL_REGEX}=               availabilityStatus=regex"(?i)Degraded"

${lss_ip}=    10.5.20.200
${lss_username}=    coam
${lss_password}=    zO&n1W*ktp7!

*** Keywords ***
Modify Vendor File And Do Full Commissioning
    [Arguments]    ${scf_file}

    Log To Console    Set actEcpri72e on Ecpri72eULDL

    ${bts_id}    Get BTS Id
    COAM.get_current_scf_file    local_dir_path=${OUTPUT_DIR}  file_name=initial_SCF.xml  export_type=configurationAndRuntimeObjects  timeout=120s
#    ${vendor_path}    Set Variable    ${OUTPUT_DIR}/vendor_initial.xml
#    COAM.Download Vendor File    ${vendor_path}
    Sleep    1s
#    Modify Tag Value    ${vendor_path}    actEcpri72e    Ecpri72eULDL
#    COAM.Set Vendor File    ${vendor_path}
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${scf_file}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms

Revert Vendor File And Do Full Commissioning
    Log To Console    Set actEcpri72e back to disabled
    ${bts_id}    Get BTS Id
#    ${vendor_path}    Set Variable    ${OUTPUT_DIR}/vendor_modified.xml
#    COAM.Download Vendor File    ${vendor_path}
    Sleep    1s
#    Modify Tag Value    ${vendor_path}    actEcpri72e    disabled
#    COAM.Set Vendor File    ${vendor_path}
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${OUTPUT_DIR}/initial_SCF.xml
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=600
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All modules reached working state  console=yes
    bts_states.Check Active Alarms

Check All SMODs And RMODs States
    [Documentation]
    ...  This keyword checks that all SMODs and RMODs reached working status after site reset.
    ...
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...     Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m  pm_logs_general.Check All SMODs And RMODs States
    ...

#    coam.Reset Admin
    coam.Teardown Admin
    Setup Admin Connection
    Log  Checking that all SMODs are working after reset...  console=${True}
    coam.Assert Every    SMOD    ${smod_working_states}
    Log  Checking that all RMODs are working after reset...  console=${True}
    coam.Assert Every    RMOD    ${rmod_working_states}

#Check RMOD Availability Status
Check RMOD States
    [Documentation]
    ...  This keyword checks given RMOD states (rmod_id, administrativeState and operationalState are entry arguments).

    [Arguments]    ${rmod_id}    ${av_status}    ${oper_state}
    ${rmod_parameters}         coam.Get Parameters For    RMOD    ${rmod_id}
    ${administrative_State}    Get From Dictionary   ${rmod_parameters}    administrativeState
    ${operational_State}       Get From Dictionary   ${rmod_parameters}    operationalState
    Log  administrative_State is__${administrative_State}__  console=${True}
    Should Match Regexp     ${administrative_State}    ${av_status}
    Log  operational_State is__${operational_State}__  console=${True}
    Should Match Regexp     ${operational_State}    ${oper_state}


Check All Modules And All Cells Working States
    [Documentation]
    ...  This keyword checks that all SMODs and RMODs and cells (2G, 3G, 4G and 5G) reached working status after site reset.
    ...
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...     Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  20m  30s  pm_logs_general.Check All Modules And All Cells Working States
    ...
    Check All SMODs And RMODs States

    Run Keyword If    ${SCF_COUNT_LTE}   Run Keywords
    ...    coam.Assert Every    LNCEL    ${OnAir_LTE_cells_expected_states}
    ...    AND
    ...    coam.Assert No  LNCEL  ${DEGRADED_CELL_REGEX}
	...    AND
    ...    bts_states.Check Cells Number    LNCEL    ${SCF_COUNT_LTE}
    Run Keyword If    ${SCF_COUNT_GSM}   Run Keywords
    ...    coam.Assert Every    GNCEL    ${OnAir_GSM_cells_expected_states}
    ...    AND
    ...    coam.Assert No  GNCEL  ${DEGRADED_CELL_REGEX}
	...    AND
    ...    bts_states.Check Cells Number    GNCEL    ${SCF_COUNT_GSM}
    Run Keyword If    ${SCF_COUNT_WCDMA}   Run Keywords
    ...    coam.Assert Every    WNCEL    ${OnAir_WCDMA_cells_expected_states}
    ...    AND
    ...    coam.Assert No  WNCEL  ${DEGRADED_CELL_REGEX}
	...    AND
    ...    bts_states.Check Cells Number    WNCEL    ${SCF_COUNT_WCDMA}
    Run Keyword If    ${SCF_COUNT_NR}   Run Keywords
    ...    coam.Assert Every    NRCEL    ${NRCELLs_expected_states}
    ...    AND
    ...    coam.Assert No  NRCEL  ${DEGRADED_CELL_REGEX}
	...    AND
    ...    bts_states.Check Cells Number    NRCEL    ${SCF_COUNT_NR}


Get SMOD variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave.
    ...  KW moved from hran_infomodel.robot and modified to support newer SMOD types(ASIL)
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  Get SM variant with full name        ### hran_infomodel ###
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB|ASIL|ASOH|ASOG|ASIM)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant}


Check if connection with NetAct is active
    [Documentation]   Checks if BTS is connected with netact using infomodel. Firstly checks
    ...   'proceduralState' to check if NetAct is connected and secondly checks phrase 'srnclab' in 'managerId' parameter
    ...   to confirm, that integration with specified lab works correctly.
    ...
    ...  *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...  .. code-block: robotframework
    ...     pm_logs_general.Check if connection with NetAct is active   1200
    ...
    [Arguments]   ${NetAct_proceduralState_timeout}=120
    Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=UnsecureConnected]
    ...   timeout=${NetAct_proceduralState_timeout}   allow_negative_result=False

    ${NetAct_connection_status}  Query Infomodel  query=get object /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-*
    FOR   ${i}   IN   @{NetAct_connection_status['managerInfo']}
       ${connection_to_NetAct_lab}   Run Keyword And Return Status
       ...   Should Contain   ${i['managerId']}   srnclab
       Exit For Loop If   ${connection_to_NetAct_lab}
    END
    Should Be True   ${connection_to_NetAct_lab}   msg=BTS is not connected to NetAct

    [Return]  ${NetAct_connection_status}

Integrate BTS with NetAct Lab From Variable
    [Documentation]   This KW opens node to first avaiable NetAct Lab from a dictionary &{netact_labs},
    ...   which is declared in ***Variables*** section of this resource.
    ...   Then integrates to NetAct on release SBTS22R2
    ...   After integration, node is deleted.
    ...
    ...   *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...  Integrate BTS with NetAct Lab From Variable
    ...
    [Arguments]   ${enb_release}=SBTS22R2   ${username}=omc   ${password}=Medsql!_1893
    ${bts_id}  bts_states.Get BTS ID
    ${m-plane}  bts_states.Get BTS Mplane
    FOR   ${i}   IN    @{netact_labs.keys()}
        ${used_netact_lab}   Set Variable   ${i}
        ${node_status}   Run Keyword And Return Status
        ...    add_node   service_name=cmwas   hostname=${netact_labs['${i}']['cmwas']}
        ...    username=${username}   password=${password}    alias=default
        Exit For Loop If   ${node_status}
    END
    Run Keyword If  not ${node_status}
    ...    verdicts.Set Test Failed   There is no available NetAct node for integration   ${TRUE}

    Set Test Variable   ${used_netact_lab}
    Set Test Variable   ${enb_release}
    Detect Nodes
    ${web_url}   Detect WEB URL

    ${integration_status}   Run Keyword And Return Status   Integrate Mrbts With Netact   release=${enb_release}  mr=MRC-COMMON/MR-COMMON
    ...   mrbts_address=${m-plane}   dist_name=PLMN-PLMN/MRBTS-${bts_id}    security_mode=no TLS   alias=default

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=UnsecureConnected]
    ...   timeout=600   allow_negative_result=False
    Run Keyword If  not ${connection_to_NetAct}
    ...   verdicts.Set Test Failed   BTS is not connected to NetAct.   ${TRUE}

    ${NetAct_connection_status}  Query Infomodel  query=get object /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-*
    FOR   ${i}   IN   @{NetAct_connection_status['managerInfo']}
       ${connection_to_NetAct_lab}   Run Keyword And Return Status
       ...   Should Contain   ${i['managerId']}   srnclab
       Exit For Loop If   ${connection_to_NetAct_lab}
    END
    Run Keyword If  not ${connection_to_NetAct_lab}
    ...   verdicts.Set Test Failed   BTS is not connected to NetAct Lab.   ${TRUE}

    [Teardown]   delete_node    cmwas

Integrate BTS with NetAct Lab
    [Documentation]   This KW opens node to given NetAct Lab and integrate BTS to this lab.
    ...   After integration node is deleted. Please, be aware this is integration to specific lab
    ...   This KW also can be used if BTS was integrated, but lost communication with specific lab,
    ...   so proceduralState=UnsecureConnected, but there is no managerID object related to integrated lab.
    ...
    ...   *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...   Integrate BTS with NetAct Lab   ${NetAct_lab_IP}  ${enb_release}
    ...
    [Arguments]   ${NetAct_lab_IP}    ${enb_release}    ${username}=omc   ${password}=Medsql!_1893

    ${bts_id}  bts_states.Get BTS ID
    ${m-plane}  bts_states.Get BTS Mplane
    Log    add node service name: cmwas    console=${True}
    add_node   service_name=cmwas   hostname=${NetAct_lab_IP}   username=${username}   password=${password}    alias=default
    Log    Detect Nodes    console=${True}
    Detect Nodes
    ${web_url}   Detect WEB URL
    Log    Integrate Mrbts With Netact started, lab ip=${NetAct_lab_IP}   console=${True}
    ${integration_status}   Run Keyword And Return Status   Integrate Mrbts With Netact   release=${enb_release}  mr=MRC-COMMON/MR-COMMON
    ...   mrbts_address=${m-plane}   dist_name=PLMN-PLMN/MRBTS-${bts_id}    security_mode=no TLS    alias=default

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=UnsecureConnected]
    ...   timeout=600   allow_negative_result=False
    Run Keyword If  not ${connection_to_NetAct}
    ...   verdicts.Set Test Failed   BTS is not connected to NetAct.   ${TRUE}

    ${NetAct_connection_status}  Query Infomodel  query=get object /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-*
    FOR   ${i}   IN   @{NetAct_connection_status['managerInfo']}
       ${connection_to_NetAct_lab}   Run Keyword And Return Status
       ...   Should Contain   ${i['managerId']}   srnclab
       Exit For Loop If   ${connection_to_NetAct_lab}
    END
    Run Keyword If  not ${connection_to_NetAct_lab}
    ...   verdicts.Set Test Failed   BTS is not connected to NetAct Lab.   ${TRUE}
    Log    Integrate Mrbts With Netact done    console=${True}
    [Teardown]   delete_node    cmwas

Check NetAct connection and reintegrate if needed
    [Documentation]   This KW checks if connection with specific lab of NetAct is active
    ...  and integrates BTS with NetAct if not.
    ...
    ...   *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...  .. code-block: robotframework
    ...     Check NetAct connection and reintegrate if needed   ${NetAct_lab_IP}   1200
    ...
    ...   If KW Integrate BTS with NetAct Lab From Variable was used in test and succed, before this one,
    ...   then variable ${used_netact_lab} should be available. In such case it can be used with &{netact_labs}
    ...   declared in ***Variables*** section like this:
    ...     Check NetAct connection and reintegrate if needed   ${netact_labs['${used_netact_lab}']['cmwas']}   1200
    ...
    [Arguments]   ${NetAct_lab_IP}  ${enb_release}    ${NetAct_proceduralState_timeout}=120
    ${is_NetAct_connected}   Run Keyword And Return Status   Check if connection with NetAct is active   ${NetAct_proceduralState_timeout}
    Run Keyword If  not ${is_NetAct_connected}
    ...   Integrate BTS with NetAct Lab   ${NetAct_lab_IP}    ${enb_release}

Deintegrate BTS from NetAct Lab
    [Documentation]   This KW opens node to NetAct Lab and deintegrate BTS from this lab.
    ...   After integration node is deleted. Please, be aware this is deintegration from specific lab.
    ...
    ...   *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...  .. code-block: robotframework
    ...     Deintegrate BTS from NetAct Lab   ${NetAct_lab_IP}
    ...
    ...   If KW Integrate BTS with NetAct Lab From Variable was used in test and succed, before this one,
    ...   then variable ${used_netact_lab} should be available. In such case it can be used with &{netact_labs}
    ...   declared in ***Variables*** section like this:
    ...     Deintegrate BTS from NetAct Lab   ${netact_labs['${used_netact_lab}']['cmwas']}
    ...
    [Arguments]   ${NetAct_lab_IP}   ${enb_release}   ${username}=omc   ${password}=Medsql!_1893

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [managerInfo=empty]
    ...   timeout=60   allow_negative_result=False
    Run Keyword If   ${connection_to_NetAct}
    ...   verdicts.Set Test Failed
    ...   It was expected, that NetAct will be integrated to BTS at this point, check manually why it is not connected  ${TRUE}

    ${bts_id}  bts_states.Get BTS ID
    ${m-plane}  bts_states.Get BTS Mplane
    add_node   service_name=cmwas   hostname=${NetAct_lab_IP}   username=${username}   password=${password}    alias=default
    Detect Nodes
    ${web_url}   Detect WEB URL
    ${deintegration_status}   Run Keyword And Return Status
    ...    Deintegrate Mrbts From Netact    dist_name=PLMN-PLMN/MRBTS-${bts_id}   alias=default

    Run Keyword If  not ${deintegration_status}   Run Keywords
    ...   Integrate Mrbts With Netact   release=${enb_release}  mr=MRC-COMMON/MR-COMMON
    ...   mrbts_address=${m-plane}   dist_name=PLMN-PLMN/MRBTS-${bts_id}    security_mode=no TLS    alias=default
    ...   AND   Sleep   10s
    ...   AND   Deintegrate Mrbts From Netact    dist_name=PLMN-PLMN/MRBTS-${bts_id}   alias=default

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [managerInfo=empty]
    ...   timeout=60   allow_negative_result=False
    Run Keyword If  not ${connection_to_NetAct}
    ...   verdicts.Set Test Failed
    ...   It was expected, that NetAct will be deintegrated to BTS at this point, check manually why deintegration failed.   ${TRUE}

    Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=Disconnected]
    ...   timeout=60   allow_negative_result=False

    [Teardown]   delete_node    cmwas

Check if NetAct is deintegrated
    [Documentation]   Checks if NetAct is deintegrated
    ...
    ...  *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...  Check if NetAct is deintegrated
    ...
    ${NetAct_obj_IM}   Run Keyword And Return Status
    ...   Query Infomodel  none /MRBTS-*/RAT-*/NE3SADAPT-*   timeout=60   allow_negative_result=False
    Run Keyword If   ${NetAct_obj_IM}   Return From Keyword

    ${proceduralState_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [stateInfo.proceduralState=Disconnected]
    ...   timeout=60   allow_negative_result=False
    Run Keyword If  not ${proceduralState_NetAct}
    ...   verdicts.Set Test Failed
    ...   It was expected, that NetAct will be deintegrated to BTS at this point, check manually why deintegration failed.   ${TRUE}

    ${connection_to_NetAct}   Run Keyword And Return Status
    ...   Query Infomodel  query=check /MRBTS-*/RAT-*/NE3SADAPT-*/NE3S_SESSION-* is [managerInfo=empty]
    ...   timeout=60   allow_negative_result=False
    Run Keyword If  not ${connection_to_NetAct}
    ...   verdicts.Set Test Failed
    ...   It was expected, that NetAct will be deintegrated to BTS at this point, check manually why deintegration failed.   ${TRUE}

Check If There Are No Critical Alarms
    [Documentation]   Checks severity for all active alarms.
    ...  KW will fail if any critical alarm will be active.
    ...
    ...  *AUTHOR* justyna.durak@nokia.com
    ...  **Example of simple usage:**
    ...
    ...  .. code-block: robotframework
    ...     Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check If There Are No Critical Alarms
    ...
    ${active_alarms}  coam.Get Active Alarms  timeout=60
    ${severity_list}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
      ${severity}  Get From Dictionary  ${alarm}  severity
      Append To list  ${severity_list}  ${severity}
    END
    Log  ${severity_list}
    Should Not Contain  ${severity_list}  Critical  msg=Critical alarm occured

Check Unexpected Active And Historical Alarms
    [Documentation]
    ...  This keyword checks if unexpected alarms (active or historical) are raised on BTS.
    ...  Allowed alarms are defined inside KW (61524  61649  4654  4655  61652  4681  4592  61074)
    ...  KW fails if any unexpected active or historical alarm found.
    ...
    ...  +------------------+------+-----------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                               |
    ...  +==================+======+===========================================================+
    ...  | skip_fault       | No   | Additional allowed faults can be set with comma separator |
    ...  +------------------+------+-----------------------------------------------------------+
    ...  | connection       | No   | connection name                                           |
    ...  +------------------+------+-----------------------------------------------------------+
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    ...  **Example of simple usage:**
    ...  Check If Unexpected Alarms Are Raised  skip_fault=1900,4290
    ...
    ...
    [Arguments]  ${skip_fault}=${EMPTY}  ${connection}=default
    coam.Clear Allowed Alarms List  connection=${connection}
    @{allowed_faults}=  Create List  61524  61649  4654  4655  61652  4681  4592  4590  61074  4458
    ${skip_faults}=  Split String  ${skip_fault}  separator=,
    ${skip_faults_additional}=  Split String  ${ADDITIONAL_IGNORED_ALARMS}  separator=,
    @{ignore_faults}=  Run Keyword If  '${skip_fault}'!='${EMPTY}'  Combine Lists  ${allowed_faults}  ${skip_faults}
    ...  ELSE IF  '${skip_fault}'=='${EMPTY}'  Set Variable  ${allowed_faults}
    @{ignore_faults}=  Run Keyword If  '${ADDITIONAL_IGNORED_ALARMS}'!='${EMPTY}'  Combine Lists  ${ignore_faults}  ${skip_faults_additional}
    ...  ELSE IF  '${ADDITIONAL_IGNORED_ALARMS}'=='${EMPTY}'  Set Variable  ${ignore_faults}
    ${ignore_faults}=  Remove Duplicates  ${ignore_faults}
    FOR  ${fault}  IN  @{ignore_faults}
      coam.Add Allowed Alarm  faultId=${fault}  connection=${connection}
    END
    ${fault_mapping}=  Get Sorted Active Alarms  connection=${connection}
    ${historical_fault_mapping}=  Get Sorted Historical Alarms  connection=${connection}
    ${fault_mapping}  Combine Lists  ${fault_mapping}  ${historical_fault_mapping}
    ${unexpected_faults}=  Create List
    FOR  ${faultid}  IN  @{fault_mapping}
      ${fault}=  Convert To String  ${faultid}[faultId]
      ${verdict}  Run Keyword And Return Status  List Should Contain Value  ${ignore_faults}  ${fault}
      Run Keyword If  not ${verdict}  Append To List  ${unexpected_faults}  faultId:${faultid['faultId']} faultName:${faultid['faultName']}
    END
    ${status}  ${output}=  Run Keyword And Ignore Error  coam.Assert No Unexpected Active Alarms  connection=${connection}
    Run Keyword If  '${status}'=='PASS'
    ...  Log  There is no visible unexpected active alarms  console=${true}
    ...  ELSE
    ...  Fail  Unexpected active alarm(s) raised: ${unexpected_faults}
    ${status_hist}  ${output_hist}=  Run Keyword And Ignore Error  coam.Assert No Unexpected Historical Alarms  connection=${connection}
    Run Keyword If  '${status_hist}'=='PASS'
    ...  Log  There is no visible unexpected historical alarms  console=${true}
    ...  ELSE
    ...  Fail  Unexpected historical alarm(s) raised: ${unexpected_faults}
    coam.Clear Allowed Alarms List  connection=${connection}

Check Unexpected Alarms
    [Documentation]
    ...  Check if unexpected alarms are visible.
    ...  Allowed alarms are defined inside KW (61524  61649  4654  4655  61652  4681  4592  61074)
    ...  KW fails if any unexpected alarm found
    ...  +------------------+------+-----------------------------------------------------------+
    ...  | Parameter        | Man. | Description                                               |
    ...  +==================+======+===========================================================+
    ...  | skip_fault       | No   | Additional allowed faults can by set with comma separator |
    ...  +------------------+------+-----------------------------------------------------------+
    ...  | connection       | No   | connection name                                           |
    ...  +------------------+------+-----------------------------------------------------------+
    ...  **Example of simple usage:**
    ...  Check If Unexpected Alarms Are Raised  skip_fault=1900,4290
    ...
    ...
    [Arguments]  ${skip_fault}=${EMPTY}  ${connection}=default
    coam.Clear Allowed Alarms List  connection=${connection}
    @{allowed_faults}=  Create List  61524  61649  4654  4655  61652  4681  4592  4590  61074  4458  61675
    #61675 fault to be removed after solvong the wifi issue
    ${skip_faults}=  Split String  ${skip_fault}  separator=,
    ${skip_faults_additional}=  Split String  ${ADDITIONAL_IGNORED_ALARMS}  separator=,
    @{ignore_faults}=  Run Keyword If  '${skip_fault}'!='${EMPTY}'  Combine Lists  ${allowed_faults}  ${skip_faults}
    ...  ELSE IF  '${skip_fault}'=='${EMPTY}'  Set Variable  ${allowed_faults}
    @{ignore_faults}=  Run Keyword If  '${ADDITIONAL_IGNORED_ALARMS}'!='${EMPTY}'  Combine Lists  ${ignore_faults}  ${skip_faults_additional}
    ...  ELSE IF  '${ADDITIONAL_IGNORED_ALARMS}'=='${EMPTY}'  Set Variable  ${ignore_faults}
    ${ignore_faults}=  Remove Duplicates  ${ignore_faults}
    FOR  ${fault}  IN  @{ignore_faults}
      coam.Add Allowed Alarm  faultId=${fault}  connection=${connection}
    END
    ${fault_mapping}=  Get Sorted Active Alarms  connection=${connection}
    ${unexpected_faults}=  Create List
    FOR  ${faultid}  IN  @{fault_mapping}
      ${fault}=  Convert To String  ${faultid}[faultId]
      ${verdict}  Run Keyword And Return Status  List Should Contain Value  ${ignore_faults}  ${fault}
      Run Keyword If  not ${verdict}  Append To List  ${unexpected_faults}  faultId:${faultid['faultId']} faultName:${faultid['faultName']}
    END
    ${status}  ${output}=  Run Keyword And Ignore Error  coam.Assert No Unexpected Active Alarms  connection=${connection}
    Run Keyword If  '${status}'=='PASS'
    ...  Log  There is no visible unexpected alarms  console=${true}
    ...  ELSE
    ...  Fail  Unexpected alarm(s) raised: ${unexpected_faults}
    coam.Clear Allowed Alarms List  connection=${connection}

Get Sorted Active Alarms
    [Documentation]
    ...  Keyword returns sorted list of active faultId, faultName and severity of fault reported on BTS.
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    [Arguments]  ${connection}=default
    ${alarm_parameters}=  coam.Get Active Alarms  connection=${connection}
    ${fault_mapping}  Create List
    FOR  ${alarm}  IN  @{alarm_parameters}
        ${fault_info}=  Create Dictionary  faultId=${alarm['faultId']}  faultName=${alarm['faultName']}  severity=${alarm['severity']}
        Append To List  ${fault_mapping}  ${fault_info}
    END
    [Return]  ${fault_mapping}

Get Sorted Historical Alarms
    [Documentation]
    ...  Keyword returns sorted list of historical faultId, faultName and severity of fault reported on BTS.
    ...  *AUTHOR* iuliia.taupeka@nokia.com
    [Arguments]  ${connection}=default
    ${alarm_parameters}=  coam.Get Historic Alarms  connection=${connection}
    ${historic_fault_mapping}  Create List
    FOR  ${alarm}  IN  @{alarm_parameters}
        ${fault_info}=  Create Dictionary  faultId=${alarm['faultId']}  faultName=${alarm['faultName']}  severity=${alarm['severity']}
        Append To List  ${historic_fault_mapping}  ${fault_info}
    END
    [Return]  ${historic_fault_mapping}

Get SW Version From Active Partition
    [Documentation]    Returns Active SW Version
    ...
    ...  *AUTHOR* jakub.kokoszka@nokia.com
    ...  **Example of simple usage:**
    ...  Get SW Version From Active Partition
    ...
    ${sw_info}   coam.Get Software Info
    ${active_sw_version}   Get From Dictionary   ${sw_info}   Active SW version
    [Return]    ${active_sw_version}

Setup Scout And Send Configuration
    [Documentation]    Setup Scout And Send Configuration
    ...
    ...  *AUTHOR* jakub.kokoszka@nokia.com
    ...  **Example of simple usage:**
    ...  Setup Scout And Send Configuration
    ...
    ${CONFIGURATION_defined}    Run Keyword And Return Status    Variable Should Exist    ${CONFIGURATION}
    Run Keyword If  not ${CONFIGURATION_defined}    Set Variable    ${CONFIGURATION}    Wroclaw.UTE_NAME_NOT_KNOWN
    ${site}    ${ute_name}    Split String From Right    ${CONFIGURATION}    .
    Run Keyword And Ignore Error    scout.Setup Scout    ${ute_name}
    Run Keyword And Ignore Error    scout.Request Scf

Set Snapshot Destination To
    [Documentation]
    ...  KW sets diagSnapDestination parameter to value passed as parameter (Netact or LSS)
    ...  When LSS is choosen, "lssConfig" object is also configured.
    ...
    ...  *AUTHOR* damian.kotula@nokia.com
    ...  **Example of simple usage:**
    ...  Set Snapshot Destination to  NetAct
    [Arguments]  ${Destination}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    ${TRBL_MNLENT_DISTNAME}  Set Variable  MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    Set Test Variable  ${TRBL_MNLENT_DISTNAME}
    ${trblcadm}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*

    Run Keyword If  '${Destination}'=='NetAct' and '${trblcadm['diagSnapDestination']}'!='netact' and '${enb_release}'=='SBTS25R2'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${TRBL_MNLENT_DISTNAME}  parameter=diagSnapDestination
    ...  operation=update  value=netact  skip_parameter_relation_errors=True
    ...  AND  Log  Parameter diagSnapDestination set to netact  console=${True}
    ...  ELSE IF   '${enb_release}'!='SBTS25R2' and '${Destination}'=='NetAct'    Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${TRBL_MNLENT_DISTNAME}  parameter=diagSnapDestination
    ...  operation=update  value=nms  skip_parameter_relation_errors=True
    ...  AND  Log  Parameter diagSnapDestination set to nms  console=${True}
    Run Keyword If  '${Destination}'=='LSS'
    ...  coam.Configure LSS account  ${lss_username}  ${lss_password}
    Run Keyword If
    ...  '${Destination}'=='LSS' and ('${trblcadm['diagSnapDestination']}'!='lss' or '${trblcadm['lssConfig']['lssIPaddress']}'!='${lss_ip}')
    ...  Configure LSS

Configure LSS
    [Documentation]
    ...  KW sets diagSnapDestination to lss and configures "lssConfig" object.
    ${lss_delta}  Set Variable  lss_config
    coam.Create Delta  ${lss_delta}
    ${dict_lss_config}  Create Dictionary  list_name=lssConfig  lssIPaddress=${lss_ip}  lssPortNo=22
    coam.Append Parameter Update To Delta  ${TRBL_MNLENT_DISTNAME}  diagSnapDestination  lss  delta_id=${lss_delta}
    coam.Append Complex Item To Delta  ${TRBL_MNLENT_DISTNAME}  list_name=lssConfig  &{dict_lss_config}  delta_id=${lss_delta}
    coam.Get Delta  ${lss_delta}
    coam.Save Delta  ${BTS Files}/lss_config_delta.json  ${lss_delta}
    coam.Perform Delta Recommissioning  ${BTS Files}/lss_config_delta.json  skip_parameter_relation_errors=${True}
    Log  Parameter diagSnapDestination set to lss  console=${True}

#The 9xKWs needed for TAT-25054 (setting netboot=unknown before test and returning back after test)
Check if it is DualCore
    [Documentation]
    ...  This KW checking if the SBTS is Dualcore or not and set variable "Dual" to true or false (needed for TAT-25054)
    ${Dual}=  Run Keyword And Return Status  Variable Should Exist  ${SMOD2}
    Set Test Variable    ${Dual}

Check if MSM is FSMF
    [Documentation]
    ...  This KW checking if the MSM is FSMF (rel.3) and return true else false (needed for TAT-25054)
    ${sm_variant}=    pm_logs_general.Get SM variant for Sanity Checker
    Log    MSM: ${sm_variant[0]}    console=${True}
    Run keyword if    "${sm_variant[0]}"=="FSMF"
    ...    Set Test Variable    ${MSM_is_FSMF}    ${True}
    ...    ELSE
    ...    Set Test Variable    ${MSM_is_FSMF}    ${False}

Check if ESM is FSMF
    [Documentation]
    ...  This KW checking if the ESM is FSMF (rel.3) and return true else false (needed for TAT-25054)
    ${sm_variant}=    pm_logs_general.Get SM variant for Sanity Checker
    Log    ESM: ${sm_variant[1]}    console=${True}
    Run keyword if    "${sm_variant[1]}"=="FSMF"
    ...    Set Test Variable    ${ESM_is_FSMF}    ${True}
    ...    ELSE
    ...    Set Test Variable    ${ESM_is_FSMF}    ${False}

Set netboot to unknown on MSM
    [Documentation]
    ...  This KW is executing command: "uboot_env set netboot=unknown" on MSM (needed for TAT-25054)
    Log    TAT-25054: KW: Set netboot to unknown on MSM    console=${True}
    ssh_utils.Setup SMOD Connection
    ${cmd_set_output}    ssh_utils.Run Command    uboot_env set netboot=unknown
    Log    Comand output: ${cmd_set_output}    console=${True}
    Set Test Variable    ${netboot_change_MSM}    ${True}

Set netboot to unknown on ESM
    [Documentation]
    ...  This KW is executing command: "uboot_env set netboot=unknown" on ESM (needed for TAT-25054)
    Log   TAT-25054: KW: Set netboot to unknown on ESM    console=${True}
    ${VM_MSM_PASSWORD}    ${VM_ESM_PASSWORD}=    ssh_utils.Get VM passwords
    Log   ssh.Connect To: hostname=${PC_IP2}    console=${True}
    ssh.Connect To    hostname=${PC_IP2}    username=ute    password=${VM_ESM_PASSWORD}    alias=slave_vm
    ssh.Connect To    hostname=192.168.255.119    username=toor4nsn    password=oZPS0POrRieRtu    proxy=slave_vm
    ${cmd_set_ESM_output}  ssh_utils.Run Command  uboot_env set netboot=unknown
    Log    Comand output: ${cmd_set_ESM_output}    console=${True}
    Set Test Variable    ${netboot_change_ESM}    ${True}

Back netboot to netboot_first on MSM
    [Documentation]
    ...  This KW is setting back netboot on MSM (needed for TAT-25054)
    Log    TAT-25054: Set netboot on MSM to netboot_first    console=${True}
    ssh_utils.Setup SMOD Connection
    ${cmd_set2_output}    ssh_utils.Run Command    uboot_env set netboot=netboot_first
    Log    Comand output: ${cmd_set2_output}    console=${True}
    Set Test Variable    ${netboot_change_MSM}    ${False}

Back netboot to netboot_first on ESM
    [Documentation]
    ...  This KW is setting back netboot on ESM (needed for TAT-25054)
    Log    TAT-25054: Set netboot on ESM to netboot_first    console=${True}
    ${VM_MSM_PASSWORD}    ${VM_ESM_PASSWORD}=    ssh_utils.Get VM passwords
    Log   ssh.Connect To: hostname=${PC_IP2}    console=${True}
    ssh.Connect To    hostname=${PC_IP2}    username=ute    password=${VM_ESM_PASSWORD}    alias=slave_vm
    ssh.Connect To    hostname=192.168.255.119    username=toor4nsn    password=oZPS0POrRieRtu    proxy=slave_vm
    ${cmd_set2_ESM_output}  ssh_utils.Run Command  uboot_env set netboot=netboot_first
    Log    Comand output: ${cmd_set2_ESM_output}    console=${True}
    Set Test Variable    ${netboot_change_ESM}    ${False}

Perform netboot to unknown for DualCore
    [Documentation]
    ...  This KW checking if ESM is not FSMF and then execute KW Set netboot to unknown on ESM
    pm_logs_general.Check if ESM is FSMF
    Run Keyword If    ${ESM_is_FSMF}
    ...    Log    The ESM is FSMF in that case: "Set netboot to unknown on ESM" is not needed    console=${True}
    ...    ELSE
    ...    pm_logs_general.Set netboot to unknown on ESM

Get SM variant for Sanity Checker
 	[Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave
    ...
    ...  | **Author:** jaroslaw.piszczala@nokia.com
    ...  | **Maintainer:** jakub.kokoszka@nokia.com
    ...  | **Released with version:** -
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB|ASIL|ASIL AirScale Common)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant}

Setup Local user account
    [Documentation]       Perform setup Local User Account
    ...                   Account type:    BTSSecurity, BTSApplication, BTSRead
    [Arguments]           ${account_type}    ${new_password}    ${old_password}=${EMPTY}    ${connection}=default
#    ${connection}=        admin_utils.create connection if not exist
#    ...                   connection=${connection}
#    ...                   alias=${TEMP_ADMIN_CONN}
    Log  Setup ${account_type} account    console=true
    coam.set_user_account    old_username=${account_type}
    ...                       old_password=${old_password}
    ...                       new_password=${new_password}
    ...                       connection=${connection}
    ${account_type}       admin_utils.parse_local_user_name    ${account_type}
    coam.change_local_account_state     account_type=${account_type}
    ...                                  enable=true
    ...                                  timeout=300
    ...                                  connection=${connection}
