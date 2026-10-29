*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library        taf.sw.reporting_portal
Resource       ../../../resources/ca_IWK.robot


*** Keywords ***
Change QRxLevMin
    [Arguments]  ${cell_id}  ${value}
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    ${_}  ${scf_gnb} =  Save And Parse SCF  SCF_gNB_changed  alias=gNB
    ${qrx_lev_min} =  Get Parameter Value From SCF  ${scf_gnb}  NRCELL  NRCELL-${cell_id}  /p[@name='qRxLevMin']
    ...  dist_name_substring=True
    Set Test Variable  ${ORIGINAL_QRX_VALUE}  ${qrx_lev_min}
    Perform Parameter Recommissioning  MRBTS-${nrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cell_id}
    ...  qRxLevMin  update  ${value}  alias=gNB
    Set Test Variable  ${QRXLEVMIN_CHANGED}  True
    Wait Until Keyword Succeeds  30s  5s  _verify bts states for iwk test helper  ${IGNORED_ALARMS}  alias=gNB


Create Alarm List
    [Arguments]  ${ignored_fault_ids}
    ${alarm_list} =  Create List
    FOR  ${fault_id}  IN  @{ignored_fault_ids}
        Append To List  ${alarm_list}  faultId=${fault_id}
    END
    Set Test Variable  ${IGNORED_ALARMS}  ${alarm_list}


Report Test Case
    [Arguments]  ${qc_id}  ${name}=${TEST_NAME}  ${ca}=VRF_WRO2  ${testline}=${HOSTNAME}  ${build}=${5G_TARGET_SW}
    ...  ${label}=${LABEL}  ${qc_domain}=${QC_DOMAIN}  ${qc_project}=${QC_PROJECT}  ${tool}=WebEM
    ${result} =  Set Variable If  '${TEST_STATUS}' == 'PASS'  passed  failed
    Check If Scout ID Was Set And Retry If Not
    Report To RP  name=${name}  result=${result}  ca=${ca}  testline=${testline}
    ...  build=${build}  qc_domain=${qc_domain}  qc_project=${qc_project}  qc_id=${qc_id}
    ...  label=${label}  tool=${tool}  tc_execution_id=${TC_EXEC_ID}


Check If Scout ID Was Set And Retry If Not
    ${scout_id_exists} =  Run Keyword And Return Status  Variable Should Exist  ${TC_EXEC_ID}
    IF  not ${scout_id_exists}  Add Configuration ID to Reporting Portal Report  scout_testline_name=${HOSTNAME}


Check If Baseline SCF Is Uploaded
    [Arguments]    ${scf_file}
    SCF Setup
    Log To Console  Check if baseline SCF is uploaded.
    IF  ${UPLOAD_BASELINE_SCF}
      Upload Scf and Verify On Air State  ${scf_file}
    ELSE
      Log To Console  Upload baseline SCF is not needed.
    END
    [Teardown]  SCF Teardown

SCF Setup
    Set Library Search Order  admin  Process
    Create Alarm List  ${CUSTOM_ALARMS}

    Extract Variables From Config File For gNB

    Create Log Directories  Upload_Baseline_SCF_After_SW_Upgrade
    Log Variables   level=DEBUG

    Run Keyword And Ignore Error  syslog.Teardown All Aliases For Syslog

    Setup Admin  bts_host=192.168.255.129  admin_api_log_dir=${LOG_PATH}/admin_api_logs  alias=gNB
    Log To Console  Connection to ADMIN on gNB side started.

    Setup Infomodel  address=192.168.255.129  port=443  use_ssl=True  admin_api_log_dir=${LOG_PATH}/admin_api_logs
    ...  alias=gNB
    Connect Infomodel  alias=gNB
    Log To Console  Connection to InfoModel on gNB side started.

    syslog.Start Syslog  log_dir=${LOG_PATH}/udp_logs  log_name=UDP_gNB  ip=192.168.255.126
    ...  alias=gNB
    Log To Console  Syslog on gNB side started.

    ${release_local} =  Get SW Release Name  connection=gNB
    Set Test Variable  ${RELEASE_LOCAL}  ${release_local}
    Log  Release local: ${RELEASE_LOCAL}  console=True

    Add Standard Allowed Alarms  alias=gNB

    _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB

    ${active_sw_version}=  Get SW Version  alias=gNB
    Log To Console  Active SW: ${active_sw_version}
    Set Tags  SBTS_SW-${active_sw_version}
    Log To Console  Expected SW: ${5G_TARGET_SW}
    IF  "${active_sw_version}" != "${5G_TARGET_SW}"
      Fatal Error  msg=Expected software on BTS is different than requested.
    END

    Log Variables   level=DEBUG


Upload Scf and Verify On Air State
    [Arguments]    ${scf_file}
    Log To Console  Upload baseline SCF is needed.
    Log To Console  Migrate scf.
    admin.Migrate Scf   input_scf_file=${scf_file}    output_scf_file=${LOG_PATH}/misc_logs/migrated_scf.xml  alias=gNB
    Log To Console  Perform scf commissioning.
    admin.Perform Commissioning   scf_file=${LOG_PATH}/misc_logs/migrated_scf.xml    timeout=600    alias=gNB
    Log To Console  Verify on air state.
    Wait Until Keyword Succeeds  6m  1m  _verify bts states for iwk test helper
    ...  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    Log To Console  Baseline SCF is uploaded.
    Set Suite Variable  ${UPLOAD_BASELINE_SCF}  False



SCF Teardown
    Log To Console  \n\n=== SCF Update Teardown ===
    Log Variables   level=DEBUG
    Save Infomodel Log  filename=${LOG_PATH}/infomodel_logs/InfoModel_log_gNB.ims2  alias=gNB
    Log To Console  InfoModel log from gNB saved.

    syslog.Collect Syslog Results  unzip=False  alias=gNB
    Log To Console  Syslog on gNB closed and saved.

    Collect swconfig and RawAlarmHistory From gNB
    Log to console  swconfigs and RawAlarmHistory saved.

    IF  '${KEYWORD STATUS}' == 'FAIL' or ${FIRST_SCF_ITERATION}
      Run Keywords  Create Directory  ${LOG_PATH}/snapshot
      ...  AND  Log To Console  Snapshot collection started.
      ...  AND  Collect Snapshot  ${LOG_PATH}/snapshot/gNB  alias=gNB
      ...  AND  Log To Console  Snapshot collected.
    END

    Create Directory  ${LOG_PATH}/admin_api_logs/
    Teardown All Aliases For Infomodel
    Log To Console  InfoModel connections closed.

    interface.Common Step Trigger

    Teardown All Aliases For Admin
    Log To Console  ADMIN connections closed.

    Run  mv ${LOG_PATH}/*.log* ${LOG_PATH}/misc_logs/

    IF  '${KEYWORD STATUS}' == 'PASS'
      IF  ${FIRST_SCF_ITERATION}
        Set Suite Variable  ${FIRST_SCF_ITERATION}  False
      ELSE
        OperatingSystem.Run  rm -rf ${LOG_PATH}
      END
    END

Temporarily Modify Node
    [Arguments]  ${node}  ${modifications_dict}
    ${node2} =  Create Dictionary  &{node}
    Set To Dictionary  ${node2}  &{modifications_dict}
    ${nodes2} =  Create List  ${node2}
    [Return]  ${node2}  ${nodes2}
    Log  Nodes are modified for ${TEST_NAME} test case.\n\nNode2: ${node2}\n\nNodes2: ${nodes2}


Check If Execution Is Run By Cloud Manager
    ${cm_execution_id}=    Get Environment Variable    CM_EXECUTION_ID    default=None
    ${use_scout_internal_id}=    Evaluate    "${cm_execution_id}" == "None"
    Set Suite Variable  ${USE_SCOUT_INTERNAL_ID}  ${use_scout_internal_id}


Set Source Software And Target Software
    ${5g_source_sw} =  Run Keyword If  '${5G_SOURCE_SW}' == '${None}'  utilities.Get Source SW
    ...   ELSE  Set Variable  ${5G_SOURCE_SW}
    Set Suite Variable  ${5G_SOURCE_SW}
    ${5g_target_sw} =  Run Keyword If  '${5G_TARGET_SW}' == '${None}'  utilities.Get Target SW
    ...   ELSE  Set Variable  ${5G_TARGET_SW}
    Set Suite Variable  ${5G_TARGET_SW}

    Set To Dictionary         ${NODE1}
    ...                       source_sw=${5g_source_sw}
    ...                       target_sw=${5g_target_sw}

    ${nodes} =  Create List  ${NODE1}
    Set Suite Variable  ${nodes}  ${NODES}


Set Expected Throughput For UE
    IF  '${ADDITIONAL_UE_CAPABILITY}' == 'REAL_IPHONE_UE' and '${TEST_NAME}' == 'Rjio_E2E_26_CA_Call'
        Set Test Variable  ${EXPECTED_UL_TPUT}  50
        Set Test Variable  ${EXPECTED_DL_TPUT}  550
    ELSE IF  '${TEST_NAME}' == 'Rjio_E2E_26_CA_Call'
        Set Test Variable  ${EXPECTED_UL_TPUT}  45
        Set Test Variable  ${EXPECTED_DL_TPUT}  550
    END
