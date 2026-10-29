*** Settings ***
Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200


*** Keywords ***
TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-22272
    ...  ******************
    ...  Author: Justyna Durak
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-11-26 - TAT-22272 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2021-12-23 - TAT-22173 - move states check to resource ca_pm_logs_general
    ...  - 2022-01-04 - TAT-22173-2  - Check All Modules And Cells State KW moved to resources -> Check All Modules And All Cells Working States
    ...  - 2022-06-14 - TAT-23289 - Ip Capture File move from ute_admin to taf.sbts.oam.coam.admin
    ...  - 2022-07-12 - TAT-23405 - fix bytes-like object is required not str - error
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 2023-02-27 - TAT-24825 - KW Set Snapshot Destination to NetAct added to TC Preconditions, KW moved to ca_pm_logs_general resource
    ...  - 2023-03-10 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 2023-01-03 - change NetAct integration KW and variables
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered when fault 6450 is detected.
    ...  This TC covers HW configurations: FSMF, ASIA, ASIB, FSMF+FSMF, ASIA+ASIA, ASIA+FSMF
    ...  Test case created as corrective action for EDA 01874301
    ...  *******************
    ...  Test case flowchart:
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.png
    ...


    Set Tags    CA-LOGS    OWNER-justyna.durak@nokia.com    AUTHOR-justyna.durak@nokia.com
    ...    MAINTAINER-justyna.durak@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS22

    Step 0: Preconditions
    Step 1: Perform Dsp Crash
    Step 2: Check If Snapshot Is Collected
    Step 3: Check If Snapshot Is Uploaded To Netact

Step 0: Preconditions
    [Documentation]  To perfrom this test such paramteres have to be set with specific values:
    ...  diagSnapDestination = netact and snapshotUploadDelayForFault6450 = 0
    ...  Reset site is added to avoid situation, when 5 snapshots was already sent to NetAct
    ...  before this TC and 6th won't be send - reset site will also reset this counter.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    Set Snapshot Destination To  NetAct
    ${trblcadm_conf}  Query Infomodel  query=get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/MNL_CONF_M-*/MNLENT_CONF_M-*/TRBLCADM_CONF_M-*
    Run Keyword Unless  '${trblcadm_conf['snapshotUploadDelayForFault6450']}'=='0'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=snapshotUploadDelayForFault6450
    ...  operation=update  value=0  skip_parameter_relation_errors=True  timeout=1200
    ...  AND  Log  Parameter snapshotUploadDelayForFault6450 set to 0h  console=true
    Log  Reset Site and wait up to 15min for BTS to become on air     console=${True}
    coam.Reset Site
    Wait Until Keyword Succeeds  15m  30s  pm_logs_general.Check All Modules And All Cells Working States
    ${bts_connection}=  coam.connect_to
    ${enb_release}  coam.get sw release name
    Set Test Variable  ${enb_release}
    Check if NetAct is deintegrated
    Integrate BTS with NetAct Lab    ${NETACT_LAB.cmwas}    ${enb_release}
    Log  Start Ip Capture File  console=true
    coam.Start Ip Capture File  measurement_point=Transport_Interface  uplane_capturing=true  timeout=600

Step 1: Perform Dsp Crash
    [Documentation]  In this step such actions are performed: pick DSP id from all available on BTS,
    ...  log to SMOD via ssh and run command, which will perform crash of picked DSP,
    ...  wait for FID 6450, which is expected after crash and also ignore FID 6707 rasied
    ...  due to autonomous recovery after DSP crash.
    ...  This step covers HW configurations: FSMF, ASIA, ASIB, FSMF+FSMF, ASIA+ASIA, ASIA+FSMF

    Log  \nStep 1: Perform Dsp Crash  console=${True}
    ${sm_variant}=  pm_logs_general.Get SMOD variant
    ${DSP_ID}=  Run Keyword if   '${sm_variant[0]}'=='ASIA' and '${sm_variant[1]}'=='FSMF'    Return Core Id With Highest Number
    ...         ELSE   Return Core Id With Lowest Number
    Set Test Variable  ${DSP_ID}
    Log  Trigger crash of DSP ${DSP_ID}  console=${True}
    Log  Run 'rioboot -c read -a 0x10800000 -n 0x1000000 ${DSP_ID}'  console=${True}
    ${SMOD_IP_with_tested_DSP}=    Return SMOD IP With Tested DSP
    ssh_utils.Perform Dsp Crash    ${DSP_ID}    ${SMOD_IP_with_tested_DSP}
    Log  Wait up to 15 min in order to check if alarm 6450 raised.  console=${True}
    ${expected_fault}=  Create Dictionary  faultId=6450
    ${expected_fault}=  Create List  ${expected_fault}
    ${ignored_fault}=  Create Dictionary  faultId=6707
    ${ignored_fault}=  Create List  ${ignored_fault}
    ${status}=  Run keyword and return status  Wait Until Keyword Succeeds  15 min  30 sec
    ...  bts_states.Check Active Alarms  print_alarms=${False}  expected_patterns=${expected_fault}  ignored_patterns=${ignored_fault}
    Run keyword unless  ${status}  Fail  Fault 6450 was not received.
    Log  Fault 6450 is reported  console=${True}

Step 2: Check If Snapshot Is Collected
    [Documentation]  In this test step it is checked if snapshot is triggered by fault 6450 and collection is finished.

    Log  \nStep 2: Check If Snapshot Is Collected  console=${True}
    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
    ${snapshot_triggering_object}  Query Infomodel  query=get object /MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-*
    Should Contain  ${snapshot_triggering_object['reason']}  6450:On fault detection  msg=Snapshot was not triggered by fault

    Log  Wait up to ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel
    ...  none //MRBTS-*/RAT-*/ASM-*/TECHREP_L-*/SNAPSHOT-* is [originator=Internal,reason=regex"6450:On fault detection"]
    ...  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=true
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}

Step 3: Check If Snapshot Is Uploaded To Netact
    [Documentation]    Check If Snapshot Is Uploaded To Netact in few steps:
    ...  Setup parametrs for ssh connection to netact,
    ...  run command to find snapshot by name and look only for files created in last 15 min,
    ...  run command to check first line of file BTS_xxxx_metadata.txt in order to read
    ...  snapshot trigger type.

    Log  \nStep 3: Check If Snapshot Is Uploaded To Netacts  console=${True}
    Sleep  180s
    ${NA_OMC_PASS}  Set Variable  Medsql!_1893
    ${NA_OMC_LOGIN}  Set Variable  omc
    ${snapshot_name}  Set Variable  Snapshot_MRBTS-${BTS_ID}*${active SW version}*
    ${cmd}  Set Variable  find /d/oss/global/diagsnap/ne3sws -name ${snapshot_name} -cmin -15 2>/dev/null
    ssh_utils.Set Connection Parameters  ${NETACT_LAB.sn_node}  ${NA_OMC_LOGIN}  ${NA_OMC_PASS}
    ${output}  ssh_utils.Run Command  ${cmd}
    ${output}  Convert To String  ${output}
    ${snap_dest_on_netact}  Set Variable  ${output.replace("\r\n", " ")}
    ${isEmpty}  Get length  ${snap_dest_on_netact}
    Run Keyword If  ${isEmpty}==0
    ...   verdicts.Set Test Failed  Snapshot NOT found on NetAct.  ${TRUE}
    ...   ELSE   Log   Snapshot found on NetAct   console=true
    ${cmd_2}  Set Variable  unzip -p ${snap_dest_on_netact} *metadata.txt | head -1
    ssh_utils.Set Connection Parameters  ${NETACT_LAB.sn_node}  ${NA_OMC_LOGIN}  ${NA_OMC_PASS}
    ${output_2}  ssh_utils.Run Command  ${cmd_2}
    ${output_2}  Convert To String  ${output_2}
    Should Contain  ${output_2}  TriggerType: 6450 - On fault detection
    ...  msg=Snapshot was not triggered on fault detection

Return Core Id With Lowest Number
    ${all_core_ids_objects}=  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
      ${core_id_in_hex}=  Evaluate  hex(${core_id.nodeId})
      Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}
    [Return]  ${all_core_ids[0]}

Return Core Id With Highest Number
    ${all_core_ids_objects}=  Query Infomodel  get list //CORE_L-* is [type=DSP]
    ${all_core_ids}  Create List
    FOR  ${core_id}  IN  @{all_core_ids_objects}
      ${core_id_in_hex}=  Evaluate  hex(${core_id.nodeId})
      Append To List  ${all_core_ids}  ${core_id_in_hex}
    END
    Sort List  ${all_core_ids}
    [Return]  ${all_core_ids[-1]}

Return SMOD IP With Tested DSP
    ${smods_obj}=  Query Infomodel  get list //SMOD_L-*
    Return From Keyword If  len(${smods_obj}) == 1
    ...  ${SMOD1['IP']}
    Log  ${smods_obj}
    Log  ${smods_obj[0]}
    Log  ${SMOD1}
    FOR  ${obj}  IN  @{smods_obj}
        ${smod_ip}=  Return Ip Sysmod With Tested DSP For Dual Core  ${obj}
        Return From Keyword If  ${obj.nodeIdMaster} != ${obj.nodeIdOwn}
        ...  ${smod_ip}
    END

Return Ip Sysmod With Tested DSP For Dual Core
    [Arguments]  ${obj}
    ${hex_map}=  Decode Hex  ${obj.nodeIdMaster}  ${obj.nodeIdOwn}
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.extension[2]}  192.168.255.7
    Return From Keyword If  ${DSP_ID[2]} == ${hex_map.master[2]}  ${SMOD1['IP']}

Decode Hex
    [Arguments]    ${master}    ${extension}
    ${m_hex}=  Evaluate  hex(${master})
    ${e_hex}=  Evaluate  hex(${extension})
    ${hex_map}=  Create Dictionary  master=${m_hex}  extension=${e_hex}
    [Return]  ${hex_map}

Custom Test Teardown
    coam.Stop Ip Capture File
    coam.Generate Ip Capture File
    coam.Download Ip Capture File   target_file_name=${BTS Files}/ip_capture_file.pcap
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown
