*** Settings ***
Documentation     author: Chandana
...               contact: chandana.m_s@nokia.com
Suite Setup       ReachOnAir
Suite Teardown    Suite teardown
Test Setup        TestSetup
Test Teardown     TestTeardown
Library           Collections
Library           ute_wtssim
Library           taf.analyzer.pdml     WITH NAME    taf_pdml_analyser
Library           ../../../Resources/Python/ScfHelper.py    WITH NAME    scf_helper
Library           ../../../Resources/Python/DeltaStore.py    WITH NAME    delta_store
Resource          ../../../Resources/robot/gnb.robot
Resource          ../../../Resources/robot/ute_setup.robot
Resource          ../../../Resources/robot/wts.robot
Resource          ../../../Resources/robot/log.robot
Resource          ../../../Resources/Variables/Common_Variables.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot

*** Variables ***
&{param_dict}         enDcSyncStatus=none
&{enDcSync_status_asynchronous}                endc_sync_status=asynchronous
...                             valueToCheck=0
&{enDcSync_status_synchronous}                endc_sync_status=synchronous
...                             valueToCheck=1
&{enDcSyncstatus_none}                endc_sync_status=none
...                             valueToCheck=2


*** Test Cases ***
Verify CellSetup with enDcSyncStatus set to Asynchronous
    [Tags]    CRT
    Edit enDcSyncStatus and verify in cell setup request    ${enDcSync_status_asynchronous.endc_sync_status}
    ...    ${enDcSync_status_asynchronous.valueToCheck}

Verify CellSetup with enDcSyncStatus set to feature1013MeasGapNotActivated
    [Tags]    CRT
    Edit enDcSyncStatus and verify in cell setup request    ${enDcSyncstatus_none.endc_sync_status}
    ...    ${enDcSyncstatus_none.valueToCheck}

Verify CellSetup with enDcSyncStatus set to Synchronous
    [Tags]    CRT
    Edit enDcSyncStatus and verify in cell setup request    ${enDcSync_status_synchronous.endc_sync_status}
    ...    ${enDcSync_status_synchronous.valueToCheck}


*** Keywords ***
ReachOnAir
    Suite Common Keywords    5GC001013
    Prepare Environment Based On Run Type
    Wait for gNB To Be Ready
    Get original params from gnB
    ${suite_folder}    log_store.Get Suite Log Folder
    ${lua_shark_path}    Download Luashark For GNB And Return Path    ${suite_folder}
    Set Suite Variable    ${lua_shark_path}

Edit enDcSyncStatus and verify in cell setup request
    [Arguments]   ${endc_sync_status}    ${valueToCheck}
    Edit endc_sync_status    ${endc_sync_status}
    Reboot for endc
    Wait for gNB To Be Ready
    Start tcpdump on gnb ASIK slave
    Set Test Variable    ${is_gnb_slave_pcap_collected}    False
    Start and configure WTS
    Ensure Egate state
    Establish X2 link And Wait For Cell Setup
    Verify endc sync status is updated in cell setup request     ${endc_sync_status}    ${valueToCheck}

Edit endc_sync_status
    [Arguments]    ${endc_sync_status}
    Delete Delta If Alread Present    name=endc
    admin.Create Delta    delta_id=endc
    admin.Append Parameter Update To Delta    delta_id=endc    dist_name=${NRCELL_DISTNAME}
    ...    parameter=enDcSyncStatus    value=${endc_sync_status}
    ${endc_delta}=    admin.Get Delta    delta_id=endc
    Recommission GNB With Delta    ${endc_delta}   timeout=600

Reboot for endc
    Reboot Airphone For Recovery

TestSetup
    Create Test Case Folder

TestTeardown
    ${gnb_pcap_collected}    log_store.get_is_gnb_pcap_collected
    run keyword if    "${is_gnb_slave_pcap_collected}" == "False"    Stop pcap collection in gNB ASIK slave
    Wait for gNB To Be Ready
    WTS Teardown Keywords

Verify endc sync status is updated in cell setup request
    [Arguments]    ${endc_Status_value}    ${endc_sync_status_to_be_checked}
    ${gnb_slave_pcap_file}    Stop pcap collection in gNB ASIK slave
    Set Test Variable    ${is_gnb_slave_pcap_collected}    True
    ${pdml_file}    Stop PCAP And Convert ICOM_5g to PDML   file_path_pattern=${gnb_slave_pcap_file}
    ...             lua_shark_file=${lua_shark_path}
    Set Test Variable    ${pdml_file}
    CellSetupRequest Should have endcSyncStatus in the capture    ${endc_Status_value}    ${endc_sync_status_to_be_checked}

CellSetupRequest Should have endcSyncStatus in the capture
    [Arguments]      ${endc_sync_status}    ${endc_sync_status_value}
    ${endc_sync_status}    Set Variable If    '${endc_sync_status}'=='none'    feature1013MeasGapNotActivated    ${endc_sync_status}
    @{release_message_list}    taf_pdml_analyser.get_pdml_entries    ${pdml_file}
    ...      field_name=itf_l2_ps_cell_CellSetupReq.CellSetupReq.enDcSyncStatus    attrib_name=show    attrib_value=${endc_sync_status_value}
    ${endc_sync_status}    ${endcSyncStatus_padding}    taf_pdml_analyser.get_attrib_value_from_pdml_entries    ${release_message_list}
    ...    field_name=itf_l2_ps_cell_CellSetupReq.CellSetupReq.enDcSyncStatus    attrib_name=showname
    Should Contain    ${endc_sync_status}    ${endc_sync_status_value}
    Should Contain    ${endc_sync_status}    ${endc_sync_status}

Get original params from gnB
    ${scf_path}    Download SCF file
    ${endc_sync_params}    scf_helper.get_feature_paramters_from_scf    ${scf_path}     ${param_dict}     ${NRCELL_DISTNAME}
    Set Suite Variable    ${endc_sync_params}
    Set Suite Variable    ${scf_path}

Suite teardown
    Common Suite Teardown Keywords

Stop PCAP And Convert ICOM_5g to PDML
   [Arguments]   ${file_path_pattern}    ${lua_shark_file}
   Log    ${lua_shark_file}
   ${pdml_file}=   Convert PCAP file to PDML    file_path_pattern=${file_path_pattern}    lua_shark_file=${lua_shark_path}
   ...    command_template={tshark_path} -Y "icom_5g" -r {input_file} -X lua_script:{luashark_path} -T pdml > {output_file}
   [Return]   ${pdml_file}
