*** Settings ***
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    ../resources/unpacking.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot


*** Variables ***
${STARTUP_TIMEOUT}     20
${SNAPSHOT_TIMEOUT}    600
${ESM_OFF}             False
*** Keywords ***
TC__LOGS__Technical_logs_are_failed_to_be_collected_from_the_secondary_cores_when_communication_between_two_cores_are_broken
    [Documentation]
    ...  [CASE LINK]:
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-24293
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify if snapshot collected from dual core, after disconnecting secondary core,
    ...  doesn't contain logs from secondary core.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 06.12.2022 - Damian Kotula - Test rewritten based on BOAM ET test:
    ...    OAM_LTE2866-A-n_Technical logs are failed to be collected from the secondary cores when communication between two cores are broken
    ...  - 03.10.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame due to migration to robotws
    ...
    ...  *******************
    ...  Test case flowchart  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/SBTS/
    ...  LOGS__Technical_logs_are_failed_to_be_collected_from_the_seconda.png
    ...  *******************
    ...

    Set Tags    CA-LOGS    OWNER-iuliia.taupeka@nokia.com    AUTHOR-damian.kotula@nokia.com    MAINTAINER-damian.kotula@nokia.com
    ...   GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CRT    SW-SBTS23R1    FEATURE-CB007425

    Step 0: Preconditions
    Step 1: Break Connection Between Master and Extension
    Step 2: Collect Snapshot
    Step 3: Check Snapshot Content
    Step 4: Restore Connection Between Master And Extension


Step 0: Preconditions
    [Documentation]
    ...  In this step parameter actDefaultFaultSnapTriggers is set to false,
    ...  so it doesn't trigger snapshot after connection between cores will be broken.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${TRBLCADM_CONF}=    Query Infomodel
    ...  query=get object /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-${BTS_ID}/MNL_A-*/MNLENT_A-*/TRBLCADM_A-*
    Run Keyword If    '${TRBLCADM_CONF.actDefaultFaultSnapTriggers}' == '${True}'
    ...  Run Keywords
    ...  coam.Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1    parameter=actDefaultFaultSnapTriggers
    ...  operation=update    value=false    skip_parameter_relation_errors=True
    ...  AND  Log    Parameter actDefaultFaultSnapTriggers changed from true to false    console=true

Step 1: Break Connection Between Master and Extension
    [Documentation]
    ...  In this step secondary core is powered off from EPC.

    Log  \nStep 1: Break connecion between Master and Extension  console=${True}
    ${secondary_smod_obj}=  Query Infomodel  get object //SMOD_R-* is [activeRole="Secondary"]
    ${INTERFACE_SECONDARY_MODULE}=  Set Variable  SMOD_${secondary_smod_obj.serialNumber}
    Set Test Variable  ${INTERFACE_SECONDARY_MODULE}
    pdu.Pdu BTS Interface Off  ${INTERFACE_SECONDARY_MODULE}
    Set Test Variable  ${ESM_OFF}  ${True}
    Sleep  30s
    Query infomodel  query=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/IM_SYNC_L-1 is [connectionList[0].connectionStatus=Disconnected]
    Log  \nSecondary System Module powered off  console=${True}

Step 2: Collect Snapshot
    [Documentation]
    ...  In this step snapshot is collected.

    Log  \nStep 2: Collect Snapshot  console=${True}
    @{time}=  Get Time  year month day hour min
    ${snapshot_status}  Run Keyword And Return Status
    ...  coam.Collect Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  ${snapshot_status}
    ...  Collecting Snapshot Succeeded  ${time}
    ...  ELSE
    ...  verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.

Step 3: Check Snapshot Content
    [Documentation]
    ...  In this step snapshot content is verified.

    Log  \nStep 3: Check Snapshot Content  console=${True}
    ${Found_file_dict}    snapshot.Get Data From Snapshot    ${path_to_snapshot}
    ${path_to_xml_spec_file}  join path  ${CURDIR}  tc_variables  snapshot_spec.xml
    snapshot.Validate Snapshot    ${Found_file_dict}    ${path_to_xml_spec_file}
    Check If Files From ESM Are Not Present

Step 4: Restore Connection Between Master And Extension
    [Documentation]
    ...  In this step secondary core is powered on.

    Log  \nStep 4: Restore Connection Between Master And Extension  console=${True}
    pdu.Pdu BTS Interface On  ${INTERFACE_SECONDARY_MODULE}
    Set Test Variable  ${ESM_OFF}  ${False}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And All Cells Working States

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=yes
    Set Test Variable    ${path_to_snapshot}    ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Check If Files From ESM Are Not Present
    [Documentation]
    ...  This KW checks if snapshot doesn't contain folders generated by ESM and BBMods connected to ESM
    unpacking.Unpack Archive Content To Directory  ${path_to_snapshot}  ${BTS Files}/extracted
    Run Keywords
    ...  OperatingSystem.File Should Not Exist  ${BTS Files}/extracted/*_2011_*
    ...  AND  OperatingSystem.File Should Not Exist  ${BTS Files}/extracted/*_2??D_*

TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If  ${ESM_OFF}  pdu.Pdu BTS Interface On  ${INTERFACE_SECONDARY_MODULE}
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
