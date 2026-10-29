*** Settings ***
Documentation
...  The purpose of this test case is to verify if required files are included in snapshot.

Library     taf.transport.ssh  WITH NAME  tafssh
Library     ../../../../../../resources/xml_operations.py
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***
${RMOD_SN}            # serial numbers of tested RMOD(s) with separated by comma
${node}  default

*** Keywords ***
TC__SiSo_SWM_RU_Logs_Snapshot_Collection
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to verify if required files are included in snapshot.
    ...  Based on the collected RU snapshot (option: All log files) the correct values for the request and response are checked:
    ...  techLogFileReq: coverage=Full, first=True
    ...  techLogFileResp: status=OK, protocol=FTP, filename=file_name_with_extension_.gz.
    ...  For options: All log files and Most important log files there are collected snapshot from WebEM
    ...  and check if required logs from Radio Unit are included in Snapshot.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  30.09.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-8026 - Initial creation


    Set Tags  CA-BS-RF  OWNER-malgorzata.piecyk-celuch@nokia.com  AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...  MAINTAINER-malgorzata.piecyk-celuch@nokia.com   PHASE-CRT  SW-SBTS25  SWM
    ...  CNI-113323

    step1: Test Case Preconditions
    step2: Collect Snapshot With All Log Files And Verify Logs
    step3: Collect Snapshot With Most Important Log Files And Verify Logs


step1: Test Case Preconditions
    Log  ${\n}Step 1: Test Case Preconditions  console=True
    Log       -------------------------------${\n}  console=True

    Log  Get RMOD(s) info  console=True
    ${radios_sn}  Split String  ${RMOD_SN}  ,
    &{rmod_sn_name}  Create Dictionary
    FOR  ${rmod_sn}  IN  @{RADIOS_SN}
      ${rmod_name}  Get RU Name  ${rmod_sn}  alias=${node}
      Set To Dictionary  ${RMOD_SN_NAME}  ${RMOD_SN}  ${RMOD_NAME}
    END
    Set Test Variable  ${RMOD_SN_NAME}

step2: Collect Snapshot With All Log Files And Verify Logs
    Log  ${\n}Step2: Collect Snapshot With All Log Files And Verify Logs  console=True
    Log       ----------------------------------------------------------  console=True

    FOR  ${RMOD_SN}  ${RMOD_NAME}  IN ZIP  ${RMOD_SN_NAME.keys()}  ${RMOD_SN_NAME.values()}
      Log  ${\n}=== Collect Snapshot from ${RMOD_NAME} and move it to VM ===   console=True
      ${RU_Log_Full}  Collect Snapshot From RMOD  snapshot_coverage=Full  tested_rmod_sn=${RMOD_SN}

      Log  ${\n}--- Check request and response of technical logs for ${RMOD_NAME} ---${\n}  console=True
      ${target_xml_list}  Unzip Snapshot  collected_snapshot_path=${Test_Files}/${RU_Log_Full}
      ...  extracted_files=${Test_Files}/Extracted_AllLogFiles_${RMOD_SN}  tested_rmod_sn=${RMOD_SN}
      Check Request And Response Of Technical Logs  ${target_xml_list}  extracted_files=${Test_Files}/Extracted_AllLogFiles_${RMOD_SN}

      Log  ${\n}--- Check if required logs from ${RMOD_NAME} are included in WebEM snapshot ---  console=True
      ${file_name}  Collect Snapshot From WebEM  snapshot_coverage=Full  file_name=snapshot_all_log_files_webem.zip
      Check Content Of RMOD Logs In Snapshot  ${file_name}  ${RU_Log_Full}  tested_rmod_sn=${RMOD_SN}
    END

step3: Collect Snapshot With Most Important Log Files And Verify Logs
    Log  ${\n}Step3: Collect Snapshot With Most Important Log Files And Verify Logs  console=True
    Log       ---------------------------------------------------------------------  console=True

    FOR  ${RMOD_SN}  ${RMOD_NAME}  IN ZIP  ${RMOD_SN_NAME.keys()}  ${RMOD_SN_NAME.values()}
      Log  ${\n}=== Collect Snapshot from ${RMOD_NAME} and move it to VM ===   console=True
      ${RU_Logs_Minor}  Collect Snapshot From RMOD  snapshot_coverage=Minor  tested_rmod_sn=${RMOD_SN}

      Log  ${\n}--- Check if required logs from ${RMOD_NAME} are included in WebEM snapshot ---  console=True
      ${file_name}  Collect Snapshot From WebEM  snapshot_coverage=Minor  file_name=snapshot_most_important_log_files.zip
      Check Content Of RMOD Logs In Snapshot  ${file_name}  ${RU_Logs_Minor}  tested_rmod_sn=${RMOD_SN}
    END

Get RU Name
    [Arguments]  ${rmod_sn}  ${alias}=default
    ${all_ru_params}  admin.Get Parameters For All  RMOD  alias=${alias}
    FOR  ${rmod}  IN  @{all_ru_params}
      Continue For Loop If  '${rmod_sn}'!='${rmod['serialNumber']}'
      ${rmod_name}  Set Variable  ${rmod['productName']}
    END
    [Return]  ${rmod_name}

Collect Snapshot From WebEM
    [Arguments]  ${snapshot_coverage}  ${file_name}
    ${results}  admin.Collect Snapshot
    ...  target_file_name=${Test_Files}/${file_name}
    ...  coverage=${snapshot_coverage}
    ...  timeout=600
    ...  connection=${node}
    [Return]  ${file_name}

Collect Snapshot From RMOD
    [Arguments]  ${snapshot_coverage}  ${tested_rmod_sn}
    ${radio_logs_name}  radio.Collect Radio Module Snapshot
    ...  ru_serial_number=${tested_rmod_sn}
    ...  coverage=${snapshot_coverage}

    radio.Send File Via SCP
    ...  ru_serial_number=${tested_rmod_sn}
    ...  direction=to_smod
    ...  file_path=/ram/${radio_logs_name}
    ...  destination_directory=/ffs

    ${smod}  Get SMOD IP For Connected RMOD  ${tested_rmod_sn}
    Run Keyword If  '${smod}'=='192.168.255.1'  tafssh.Connect To  ${smod}  toor4nsn  oZPS0POrRieRtu  alias=primary
    ...  ELSE  Run Keywords
    ...  tafssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu  alias=primary
    ...  AND  tafssh.Connect To  fct-4a  toor4nsn  oZPS0POrRieRtu  proxy=primary  alias=secondary
    tafssh.Download File  /ffs/${radio_logs_name}  ${Test_Files}/${radio_logs_name}  connection=primary
    [Return]  ${radio_logs_name}

Check Content Of RMOD Logs In Snapshot
    [Arguments]  ${file_name}  ${radio_logs_name}  ${tested_rmod_sn}
    Log  ${\n}Compare Radio Module And WebEM Snapshots:  console=True
    ${compare_status}  Run Keyword And Return Status  radio.Compare Radio Module And WebEM Snapshots
    ...  ru_serial_number=${tested_rmod_sn}
    ...  webem_snapshot_path=${Test_Files}/${file_name}
    ...  ru_snapshot_path=${Test_Files}/${radio_logs_name}
    Run Keyword If  ${compare_status}  Log  WebEM snapshot contains all files from radio module${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Number of files in radio module snapshot is NOT equal number of files for radio module${\n}  console=True
    ...  AND  Fail  Number of files in radio module snapshot is NOT equal number of files for radio module${\n}

Unzip Snapshot
    [Arguments]  ${collected_snapshot_path}  ${extracted_files}  ${tested_rmod_sn}
    Log  Unzip Snapshot  console=True
    ${output}  OperatingSystem.Run  unzip "${collected_snapshot_path}" -d "${extracted_files}"
    ${files}  OperatingSystem.List Files In Directory  ${extracted_files}

    Log  Unzip SOAP logs  console=True
    ${SOAP_file}  Evaluate  [f for f in ${files} if f.endswith('.zip') and 'SOAP' in f]
    Length Should Be  ${SOAP_file}  1  No zip file containing 'SOAP' found!
    ${SOAP_file_zip}  Set Variable  ${extracted_files}/${SOAP_file[0]}
    Log  Found SOAP zip file: ${SOAP_file_zip}

    Log  Unzip LBTS_OM logs  console=True
    ${output}  OperatingSystem.Run  unzip "${SOAP_file_zip}" -d "${extracted_files}"
    ${files}  OperatingSystem.List Files In Directory  ${extracted_files}
    ${LBTS_OM_file}  Evaluate  [f for f in ${files} if f.endswith('.zip') and 'LBTS_OM' in f]
    Length Should Be  ${LBTS_OM_file}  1  No zip file containing 'LBTS_OM_${tested_rmod_sn}' found!
    ${LBTS_OM_file_zip}  Set Variable  ${extracted_files}/${LBTS_OM_file[0]}
    Log  Found LBTS_OM zip file: ${LBTS_OM_file_zip}

    Log  ${\n}Find correct .xml(s) with needed value: 'techLogFile':  console=True
    ${output}  OperatingSystem.Run  unzip "${LBTS_OM_file_zip}" -d "${extracted_files}"
    ${files}  OperatingSystem.List Files In Directory  ${extracted_files}
    ${xmlgz_files}  Evaluate  [f for f in ${files} if (('SOAP' in f or 'LBTS_OM' in f) and f.endswith('.xml.gz'))]
    ${xmlgz_count}  Evaluate  len(${xmlgz_files})
    Should Be True  ${xmlgz_count} > 0  Expected at least 1 file with 'SOAP' or 'LBTS_OM' and '.xml.gz' extension!
    FOR  ${gz_file}  IN  @{xmlgz_files}
      ${gz_path}  Set Variable  ${extracted_files}/${gz_file}
      ${output}  OperatingSystem.Run  gunzip "${gz_path}"
      Log  Uncompressed: ${gz_file} to ${gz_file[:-3]}
    END
    ${xml_files}  Evaluate  [f[:-3] for f in ${xmlgz_files}]
    Log  ${xml_files}   #wylistowanie bez .gz
    @{target_xml_list}  Create List
    FOR  ${xml_file}  IN  @{xml_files}
      ${content_xml}  OperatingSystem.Get File  ${extracted_files}/${xml_file}
      ${techLogFile_found}  Evaluate  'techLogFile' in '''${content_xml}'''
      Run Keyword If  '${techLogFile_found}'=='True'  Run Keywords  Log  'techLogFile' found in ${xml_file}  console=True
      ...  AND  Append To List  ${target_xml_list}  ${xml_file}
      ...  ELSE  Log  There is no 'techLogFile' in ${xml_file}  console=True
    END
    [Return]  ${target_xml_list}

Check Request And Response Of Technical Logs
    [Arguments]  ${target_xml_list}  ${extracted_files}
    Log  ${\n}Check values of request and response of technical logs - 'techLogFileReq', 'techLogFileResp'  console=True

    FOR  ${xml_file}  IN  @{target_xml_list}
      Should Match  ${xml_file}  *.xml
      ${file_content}  OperatingSystem.Get File  ${extracted_files}/${xml_file}

      ${coverage_value}  Extract Target Values  ${file_content}  <techLogFileReq><coverage>(.*?)</coverage>.*?</techLogFileReq>
      ${coverage_verdict}  Run Keyword And Return Status  Should Be Equal  ${coverage_value}  Full

      ${first_value}  Extract Target Values  ${file_content}  <techLogFileReq>.*?<first>(.*?)</first></techLogFileReq>
      ${first_verdict}  Run Keyword And Return Status  Should Be Equal  ${first_value}  True

      ${filename_value}  Extract Target Values  ${file_content}  <techLogFileResp>.*?<fileName>(.*?)</fileName>.*?</techLogFileResp>
      ${filename_verdict}  Run Keyword And Return Status  Should Be Equal  ${filename_value}  .gz

      ${status_value}  Extract Target Values  ${file_content}  <techLogFileResp>.*?<status>(.*?)</status>.*?</techLogFileResp>
      ${status_verdict}  Run Keyword And Return Status  Should Be Equal  ${status_value}  OK

      ${protocol_value}  Extract Target Values  ${file_content}  <techLogFileResp>.*?<transferProtocol>(.*?)</transferProtocol>.*?</techLogFileResp>
      ${protocol_verdict}  Run Keyword And Return Status  Should Be Equal  ${protocol_value}  FTP
    END

    Run Keyword If  ${coverage_verdict} or ${first_verdict} or ${filename_verdict} or ${status_verdict} or ${protocol_verdict}
    ...  Log  Values of 'techLogFileReq' and 'techLogFileResp' are correct  console=True
    ...  ELSE  Run Keywords  Log  Values of 'techLogFileReq' and 'techLogFileResp' are not correct, check logs  console=True
    ...  AND  Fail  Values of 'techLogFileReq' and 'techLogFileResp' are not correct, check logs


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
