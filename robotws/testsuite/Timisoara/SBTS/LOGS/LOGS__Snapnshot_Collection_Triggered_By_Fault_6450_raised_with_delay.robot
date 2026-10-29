*** Settings ***
Documentation  TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_with_delay
Library     XML    use_lxml=${TRUE}
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


Library     SSHLibrary
*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200

${HOST}=    192.168.255.129
${USERNAME}=     toor4nsn
${PASSWORD}=    oZPS0POrRieRtu
${FSP_ID_ABIP}=      fsp-1-1b
${FSP_ID_ASOGH}=    fct-1-0b

*** Keywords ***
TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_with_delay
    [Documentation]

    ...  ******************
    ...  Author: Dan Moldovan
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2021-11-26 - TAT-22272 - Initial Creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso

    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Test case to check if snapshot is automatically triggered after 1h when fault 6450 is detected
    ...  This TC covers HW configurations: FSMF, ASIA, ASIB, FSMF+FSMF, ASIA+ASIA, ASIA+FSMF, ASOG, ASOH
    ...  Test case created as corrective action for EDA 01874301
    ...  *******************
    ...  Test case flowchart:
    ...  *******************
    ...


    Set Tags    CA-LOGS    OWNER-justyna.durak@nokia.com    AUTHOR-justyna.durak@nokia.com
    ...    MAINTAINER-justyna.durak@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS22

    Step 0: Preconditions
    Step 1: Trigger 6450 and check snapshot is not collected
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
    Run Keyword If  '${TEST NAME}'!='[1]CB009514_KA_CB006483_5G_C_Parameter_snapshotUploadDelayForFault6450'    Run Keywords
    ...    Log    Start Ip Capture File  console=true
    ...    AND    coam.Start Ip Capture File  measurement_point=Transport_Interface  uplane_capturing=true  timeout=600
    Update snapshotUploadDelayForFault6450    1

Step 1: Trigger 6450 and check snapshot is not collected
    [Documentation]  In this step such actions are performed: pick DSP id from all available on BTS,
    ...  log to SMOD via ssh and run command, which will perform crash of picked DSP,
    ...  wait for FID 6450, which is expected
    Log  \nStep 1: Trigger 6450  console=${True}
    Crash to trigger 6450
   Log   Whitin 1h (every 15min)snapshot is not generated  console=${True}

    FOR  ${i}  IN RANGE  1  5
        ${output}    run keyword and return status    Step 2: Check If Snapshot Is Collected
        Should not be true    ${output}
        log to console    ${i}Waiting 15min to check snapshot is not generated
        Sleep  900s

    END

Step 2: Check If Snapshot Is Collected
    [Documentation]  In this test step it is checked if after 1h snapshot is triggered by fault 6450 and collection is finished.

    Log  \nStep 2: Check If Snapshot Is Collected  console=${True}
#    Check NetAct connection and reintegrate if needed   ${NETACT_LAB.cmwas}   ${enb_release}   1200
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

    Log  \nStep 3: Check If Snapshot Is Uploaded To Netact  console=${True}
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
    Run Keyword If  '${TEST NAME}'!='[1]CB009514_KA_CB006483_5G_C_Parameter_snapshotUploadDelayForFault6450'    Run Keywords
    ...    coam.Stop Ip Capture File
    ...    AND    coam.Generate Ip Capture File   timeout=600
    ...    AND    coam.Download Ip Capture File   target_file_name=${BTS Files}/ip_capture_file.pcap
    Deintegrate BTS from NetAct Lab   ${NETACT_LAB.cmwas}    ${enb_release}

TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...    interface.Common step trigger
#    ...    AND    Setup Scout And Send Configuration
    ...    AND    Custom Test Teardown
    ...    AND    Common Test Teardown

Update snapshotUploadDelayForFault6450
	[Documentation]
	...  Set snapshotUploadDelayForFault6450

    [Arguments]    ${value}

    coam.Perform Parameter Recommissioning
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=snapshotUploadDelayForFault6450
        ...    operation=update
        ...    value=${value}
        ...    skip_parameter_relation_errors=skip

Crash to trigger 6450
    SSHLibrary.Open connection         ${HOST}
    SSHLibrary.Login                   ${USERNAME}         ${PASSWORD}
    Run Keyword If  '${TEST NAME}'=='[1]CB009514_KA_CB006483_5G_C_Parameter_snapshotUploadDelayForFault6450'
    ...  Crash ABIP to trigger 6450
    ...  ELSE    Crash ASOGH to trigger 6450
    wait until keyword succeeds   20m   2   Wait For Fault with Alarm to appear   6450    7115
    [Teardown]  Close Connection

Wait For Fault with Alarm to appear
    [Arguments]  ${FaultID}     ${AlarmID}    ${Fault_name}=None  #'RAT autonomous reset as recovery action
    Fault Should Be Present   ${FaultID}  ${Fault_name}
    Alarm Should Be Present   ${AlarmID}

Fault Should Be Present
    [Arguments]    ${fault_id}  ${Fault_name}
    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    ${fault_name_list}  Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
        Append To List    ${alarm_id_list}    ${tmp_id}
        ${fault_name_list}=  Run Keyword If  '${Fault_name}'!='None'  Get From Dictionary  ${active_alarms[${i}]}  faultName
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain    ${list}    ${fault_id}
    Run Keyword If  '${Fault_name}'!='None'  Should Be Equal As Strings  ${fault_name_list}  ${Fault_name}

Alarm Should Be Present
    [Arguments]    ${alarm_id}
    Log To Console    KW - Alarm Should Be Present alarm_id=${alarm_id}
    ${active_alarms}    coam.get_active_alarms    timeout=60
    ${len}    Get Length    ${active_alarms}
    ${alarm_id_list}    Create List
    FOR    ${i}    IN RANGE    ${len}
        ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
        Append To List    ${alarm_id_list}    ${tmp_id}
    END
    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
    ${list}     convert to string  ${alarm_id_list}
    Should Contain    ${list}    ${alarm_id}

Crash ASOGH to trigger 6450
    Log    trigger 6450
    SSHLibrary.Open Connection    ${HOST}
    SSHLibrary.Login             ${USERNAME}         ${PASSWORD}
    Sleep                        2s
    SSHLibrary.Write    rm -f .ssh/known_hosts
# Start SSH to FSP-id
   SSHLibrary.Write    ssh -tt ${USERNAME}@${FSP_ID_ASOGH}

    ${output}=    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""    Write    yes

    SSHLibrary.Read Until         password:
    SSHLibrary.Write              ${PASSWORD}

    SSHLibrary.Write  ps ax | grep l1_application_nrt | grep -v grep | awk '{print $1}'
    ${out}    SSHLibrary.Read              delay=1s
    log to console    tot:${out}
    ${out1}    Fetch From Right    ${out}    $1}'\r\n
    log to console    stg:${out1}
    ${pid}    Fetch From Left    ${out1}    \r\nasc-0b
    log to console    dr:${pid}
    SSHLibrary.Write  kill -11 ${pid}

Crash ABIP to trigger 6450
    Log    trigger 6450
    SSHLibrary.Open Connection    ${HOST}
    SSHLibrary.Login             ${USERNAME}         ${PASSWORD}
    Sleep                        2s
    SSHLibrary.Write    rm -f .ssh/known_hosts
# Start SSH to FSP-id
   SSHLibrary.Write    ssh -tt ${USERNAME}@${FSP_ID_ABIP}

    ${output}=    SSHLibrary.Read Until    (yes/no/[fingerprint])?
    Run Keyword If    "Are you sure you want to continue connecting" in """${output}"""    Write    yes

    SSHLibrary.Read Until         password:
    SSHLibrary.Write              ${PASSWORD}

    SSHLibrary.Write  ps ax | grep l1_application_nrt | grep -v grep | awk '{print $1}'
    ${out}    SSHLibrary.Read              delay=1s
    log to console    tot:${out}
    ${out1}    Fetch From Right    ${out}    $1}'\r\n
    log to console    stg:${out1}
    ${pid}    Fetch From Left    ${out1}    \r\nasp-1b
    log to console    dr:${pid}
    SSHLibrary.Write  kill -11 ${pid}

