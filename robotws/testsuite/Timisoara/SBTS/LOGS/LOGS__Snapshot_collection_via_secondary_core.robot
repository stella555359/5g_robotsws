*** Settings ***
Library    OperatingSystem
Library    taf.ul.verify_snapshot  WITH NAME  snapshot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.transport.ssh    WITH NAME    ssh
Resource    ../resources/bts_states.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/pdu.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${STARTUP_TIMEOUT}          20
${SNAPSHOT_TIMEOUT}         1200
${MSM_IP}                   192.168.255.129
${ESM_IP}                   192.168.255.119
${SSHusername}              toor4nsn
${SSHpassword}              oZPS0POrRieRtu
${flag}                     0x10041
${flag_with_desired_value}  0x10041 = 2
${MSM_OFF}                  ${False}
${actDefaultFaultSnapTriggers_changed}  ${False}

*** Keywords ***
TC__LOGS__Snapshot_collection_via_secondary_core
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-22570
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify if snapshot can be succesfully collected from secondary core after disconnecting primary system module.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.02.2023 - Damian Kotula - Initial Creation
    ...  - 13.07.2023 - Damian Kotula - Refactoring for robotws
    ...  *******************
    ...  Test case flowchart
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/raw/master/testsuite/SBTS/LOGS__Snapshot_collection_via_secondary_core.png
    ...  *******************

    Set Tags    CA-LOGS    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R3    FEATURE-RP000936_3_F1

    Step 0: Preconditions
    Step 1: Break Connection Between Master and Extension
    Step 2: Collect Snapshot from ESM
    Step 3: Check Snapshot Content And Turn ON MSM

Step 0: Preconditions
    [Documentation]
    ...  In this step parameter actDefaultFaultSnapTriggers is set to false,
    ...  so it doesn't trigger snapshot after connection between cores will be broken.
    ...  Flag 0x10041 is set to value '2' on MSM and ESM

    Log  \nStep 0: Preconditions  console=${True}
    Disable actDefaultFaultSnapTriggers
    Prepare SWconfig

Step 1: Break Connection Between Master and Extension
    [Documentation]
    ...  In this step primary core is powered off from EPC. Admin connection to ESM is established after it becomes pingable.

    Log  \nStep 1: Break connection between Master and Extension  console=${True}
    Turn off MSM
    Set Test Variable  ${MSM_OFF}  ${True}
    Sleep  1m
    ${is_ESM_pingable}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  10 min  10 sec  Check ping on ESM
    Run Keyword If  ${is_ESM_pingable}
    ...  log  ESM is pingable, waiting additional 5 min for ESM to fully recover before collecting snapshot  console=${True}
    Sleep  5m
    Setup Admin on ESM
    Log  \nSecondary core is back online  console=${True}

Step 2: Collect Snapshot from ESM
    [Documentation]
    ...  This keyword collects snapshot from ESM. If first attempt to collect fails, snapshot collection is repeated,
    ...  due to Note 1 in OAM_REQ_TEST_219. Max attemps=2

    Log  \nStep 2: Collect Snapshot from ESM  console=${True}
    @{time}=  Get Time  year month day hour min
    FOR  ${i}  IN RANGE  2
      ${snapshot_status}  Run Keyword And Return Status
      ...  coam.Collect_Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
      ...  connection=${ESM_Admin_connection}  timeout=${SNAPSHOT_TIMEOUT}
      Run Keyword If  ${snapshot_status}  Run Keywords
      ...  Log  Collecting snapshot succeeded  console=${True}
      ...  AND  Set Test Variable  ${path_to_snapshot}  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
      ...  AND  Exit For Loop
      ...  ELSE  log  \nAttempt numer: ${i} to collect Snapshot from ESM has failed. Only two attemps are allowed by OAM_REQ_TEST_219.
      ...  console=${True}
    END
    Run Keyword If  '${snapshot_status}'=='${False}'  verdicts.Set Test Failed  Collecting snapshot from ESM has failed  ${True}

Step 3: Check Snapshot Content And Turn ON MSM
    [Documentation]
    ...  In this step snapshot content is verified and connection between cores is restored.

    Log  \nStep 3: Check Snapshot Content  console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Check If Folders From ESM Are Present
    Turn ON MSM And Wait For OnAir

Disable actDefaultFaultSnapTriggers
    [Documentation]
    ...  This KW checks if actDefaultFaultSnapTriggers = false, if not, sets it to false.
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${TRBLCADM_CONF}=  Query Infomodel
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/TRBLCADM_A-*
    Run Keyword If  '${TRBLCADM_CONF.actDefaultFaultSnapTriggers}' == '${True}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
    ...  operation=update  value=false  skip_parameter_relation_errors=True
    ...  AND  Set Test Variable  ${actDefaultFaultSnapTriggers_changed}  ${True}
    ...  AND  Log  Parameter actDefaultFaultSnapTriggers changed from true to false  console=${True}

Prepare SWconfig
    [Documentation]
    ...  This KW is checking if ${flag} exist in SWconfig on both MSM and ESM. If yes, it is changed to ${flag_with_desired_value} value.
    ...  If ${flag} doesn't exist in SWconfig, it is being added.
    ${VM_MSM_PASSWORD}  ${VM_ESM_PASSWORD}  ssh_utils.Get VM passwords
    Set Test Variable  ${VM_ESM_PASSWORD}
    Establish SSH Connections
    #Prepare SWconfig file for MSM
    ${swconfig_MSM}=  ssh.Execute  grep ${flag} /ffs/run/swconfig.txt  connection=${MSM_connection}
    ${swconfig_MSM}=  Strip String  ${swconfig_MSM}
    ${flag_exist}=  Evaluate  "${flag}" in """${swconfig_MSM}"""
    Run Keyword If  ${flag_exist}  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}
    ...  AND  Change Flag  ${MSM_connection}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}  ""
    ...  AND  Add Flag  ${MSM_connection}

    #Prepare SWconfig file for ESM
    ${swconfig_ESM}=  ssh.Execute  grep ${flag} /ffs/run/swconfig.txt  connection=${ESM_connection}
    ${swconfig_ESM}=  Strip String  ${swconfig_ESM}
    ${flag_exist}=  Evaluate  "${flag}" in """${swconfig_ESM}"""
    Run Keyword If  ${flag_exist}  Run Keywords
    ...  Set Test Variable  ${swconfig_ESM}
    ...  AND  Change Flag  ${ESM_connection}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${swconfig_ESM}  ""
    ...  AND  Add Flag  ${ESM_connection}
    log  Reset ongoing in order to apply changes made in SWconfig  console=${True}
    coam.Reset_site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States
    ssh.Disconnect  ${MSM_connection}
    ssh.Disconnect  ${VME_connection}
    ssh.Disconnect  ${ESM_connection}

Establish SSH Connections
   [Documentation]
   ...  This KW creates SSH connections to MSM, ESM and ESM VM.
    ${MSM_connection}=  ssh.Connect_To  hostname=${MSM_IP}  username=${SSHusername}  password=${SSHpassword}
    ${VME_connection}=  ssh.Connect_To  hostname=${PC_IP2}  username=${VM_username}  password=${VM_ESM_PASSWORD}
    ${ESM_connection}=  ssh.Connect_To  hostname=${ESM_IP}  username=${SSHusername}  password=${SSHpassword}   proxy=${VME_connection}
    Set Test Variable  ${MSM_connection}
    Set Test Variable  ${VME_connection}
    Set Test Variable  ${ESM_connection}

Turn off MSM
    [Documentation]
    ...  This KW turns off MSM from PDU
    ${primary_smod_obj}=  Query Infomodel  get object //SMOD_R-* is [activeRole="Primary"]
    ${INTERFACE_PRIMARY_MODULE}=  Set Variable  SMOD_${primary_smod_obj.serialNumber}
    Set Test Variable  ${INTERFACE_PRIMARY_MODULE}
    pdu.Pdu BTS Interface Off  ${INTERFACE_PRIMARY_MODULE}
    Log  \nPrimary system module powered off  console=${True}

Check ping on ESM
    log  Waiting for ping on ESM  console=${true}
    ${VME_ping_connection}=  ssh.Connect_To  hostname=${PC_IP2}  username=${VM_username}  password=${VM_ESM_PASSWORD}
    ${ping_output}  ssh.Execute  command=ping -c 1 -W 10 ${ESM_IP}  connection=${VME_ping_connection}
    Should contain  ${ping_output}  1 packets transmitted, 1 received

Setup Admin on ESM
    ${ESM_Admin_connection}=  coam.Setup_Admin  bts_host=${ESM_IP}  remote_host=${PC_IP2}  remote_host_username=${VM_username}
    ...  remote_host_password=${VM_ESM_PASSWORD}  alias=ESM
    Set Test Variable  ${ESM_Admin_connection}

Check If Folders From ESM Are Present
    [Documentation]
    ...  This KW checks if snapshot contains folders from ESM and BBMods connected to ESM
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${BTS Files}/extracted
    @{SMOD_files}=  OperatingSystem.List Files In Directory  ${BTS Files}/extracted  pattern=BTS_2011_part_*
    @{BBMOD_files}=  OperatingSystem.List Files In Directory  ${BTS Files}/extracted  pattern=BTS_2??D_part_*
    Should Not Be Empty  ${SMOD_files}
    Should Not Be Empty  ${BBMOD_files}

Turn ON MSM And Wait For OnAir
    [Documentation]
    ...  This keyword turns on MSM from PDU. It also checks if bts will synchronize succesfully and reach OnAir.

    Log  \nPrimary system module powered on  console=${True}
    pdu.Pdu BTS Interface On  ${INTERFACE_PRIMARY_MODULE}
    Set Test Variable  ${MSM_OFF}  ${False}
    sleep   60
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States

Change Flag
    [Documentation]
    ...  This KW is checking on which line is ${flag} in SWconfig and replaces that line with ${flag_with_desired_value}
    [Arguments]  ${SMOD_Connection}
    ${flag_line_nr}=  ssh.Execute  grep -n '${flag}' /ffs/run/swconfig.txt | awk -F: '{print $1}'  connection=${SMOD_Connection}
    ${flag_line_nr}=  Strip String  ${flag_line_nr}
    ssh.Execute  command=sed -i '${flag_line_nr}s/.*/${flag_with_desired_value}/' /ffs/run/swconfig.txt  connection=${SMOD_Connection}

Add Flag
    [Documentation]
    ...  This KW is adding ${flag_with_desired_value} to SWconfig file
    [Arguments]  ${SMOD_Connection}
    ssh.Execute  command=echo ${flag_with_desired_value} >> /ffs/run/swconfig.txt  connection=${SMOD_Connection}

Change Back SWconfig
    [Documentation]
    ...  This KW is checking on which line is ${flag} in SWconfig and replaces that line with initial value, before changes.
    Establish SSH Connections
    #Change back SWconfig on MSM
    ${flag_line_nrMSM}=  ssh.Execute  command=grep -n '${flag}' /ffs/run/swconfig.txt | awk -F: '{print $1}'  connection=${MSM_connection}
    ${flag_line_nrMSM}=  Strip String  ${flag_line_nrMSM}
    ssh.Execute  command=sed -i '${flag_line_nrMSM}s/.*/${swconfig_MSM}/' /ffs/run/swconfig.txt  connection=${MSM_connection}
    #Change back SWconfig on ESM
    ${flag_line_nrESM}=  ssh.Execute  command=grep -n '${flag}' /ffs/run/swconfig.txt | awk -F: '{print $1}'  connection=${ESM_connection}
    ${flag_line_nrESM}=  Strip String  ${flag_line_nrESM}
    ssh.Execute  command=sed -i '${flag_line_nrESM}s/.*/${swconfig_ESM}/' /ffs/run/swconfig.txt  connection=${ESM_connection}
    log  \nSite reset will be performed in order to apply changes in SWconfig (back to initial values).  console=${True}

TC Setup
    Common Test Setup

Custom Test Teardown
    Run Keyword If  ${MSM_OFF}
    ...  Turn ON MSM and wait for OnAir
    Run Keyword If  ${actDefaultFaultSnapTriggers_changed}
    ...  coam.Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1  parameter=actDefaultFaultSnapTriggers
    ...  operation=update  value=true  skip_parameter_relation_errors=true
    Run Keywords
    ...  Change Back SWconfig
    ...  AND  coam.Reset_site
    ...  AND  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Custom Test Teardown
    ...  AND  Common Test Teardown
