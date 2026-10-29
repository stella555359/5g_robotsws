# robocop: off
*** Settings ***
Documentation  Suite description
...  Author:  izabela.wencel@nokia.com
...  Maintainer:  izabela.wencel@nokia.com

Resource  ../tc_scenarios.robot
Resource  ../hran_ta/resources/ca_Recovery_link_break.robot
Resource  ./link_break_resources.robot
Resource  ./fh_reset.robot

*** Variables ***
# Due to automatic choice of the synchronization link, the user should provide the data for both FH1 and FH2:
&{OS_ALT_CONF_FHS_SYNC_FH1}=  &{EMPTY}    # The user (tester) should provide the data for the test in the format FHS_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x
                                          # where FHS_SN means serial number of the tested FHS, OS_IP means optical switch ip
                                          # and 1-x,2-x,3-x,4-x,5-x,6-x stands for optical switch setting (bank-port_out)
&{OS_ALT_CONF_FHS_SYNC_FH2}=  &{EMPTY}    # The user (tester) should provide the data for the test in the format FHS_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x
                                          # where FHS_SN means serial number of the tested FHS, OS_IP means optical switch ip
                                          # and 1-x,2-x,3-x,4-x,5-x,6-x stands for optical switch setting (bank-port_out)

*** Keywords ***
FHS Sync Link Hot Remove Insert
    [Documentation]
    ...  [CASE LINK]: https://jiradc
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test verifies behavior of the BTS while FHS synchronization link is removed and inserted (using optical switch).
    ...
    ...  Test baseline:
    ...  - there might be up to 4 links between the tested FHS and the BTS,
    ...  - links from FH1 and FH2 may be synchronization links, FH3 and FH4 - only data links or may connect to RMODs,
    ...  - optical switch MUST be connected on both links, which might be synchronization links (ports FH1 and FH2),
    ...  - test Case requires setting syncSigTxMode for shared cells to TxDiv for 4003 to be raised,
    ...  - there are two variables provided by the author of the test case:
    ...
    ...  *Input Parameters*
    ...  +---------------------------------------------------------------------------------+
    ...  | Parameter                   | Mandatory | Description                           |
    ...  +=============================+===========+=======================================+
    ...  | OS_ALT_CONF_FHS_SYNC_FH1    | Yes       | FHS_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x  |
    ...  +-----------------------------+-----------+---------------------------------------+
    ...  | OS_ALT_CONF_FHS_SYNC_FH2    | Yes       | FHS_SN=OS_IP:1-x,2-x,3-x,4-x,5-x,6-x  |
    ...  +-----------------------------+-----------+---------------------------------------+
    ...  meaning serial number of the tested FHS (one), IP and setting of the optical switch.
    ...  The names correspond with the ports in this FHS.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  2024-12-06  Updates for robotws - izabela.wencel@nokia.com
    Logging With Timestamp
    ...  message=FHS Sync Link Hot Remove Insert: @{CFG.active_bts_list} will be executed
    ...  style=ONGOING
    Common Test Setup
    Execute FHS Sync Link Hot Remove Insert On Every Node
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    ...  AND  Common Test Teardown

Execute FHS Sync Link Hot Remove Insert On Every Node
    Step 1. Precondition For FHS Sync Link Hot Remove Insert
    Step 2. Hot Remove Sync Link
    Step 3. Automatic Sync Link Reconfiguration
    Step 4. Hot Insert Of Disconnected Link

Step 1. Precondition For FHS Sync Link Hot Remove Insert
    Logging With Timestamp
    ...  message=Step 1. Precondition For FHS Sync Link Hot Remove Insert
    ...  style=STEP
    ...  frame=${TRUE}
    ${os_status}=  Run Keyword And Return Status  Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    Run Keyword If
    ...  ${os_status}==False
    ...  Fail
    ...  Optical switch connection not established. Chceck configuration files and OS state.
    Get Variables With FHS SN And OS Settings
    Logging With Timestamp
    ...  message=Check if SN of tested FHS set by user is available on BTS.
    ...  style=ONGOING
    Verify If SN Of Tested FHS Set By User Is Available On BTS
    Logging With Timestamp
    ...  message=Get FHS distName and information about all its connections.
    ...  style=ONGOING
    &{sfp_links}=  admin.Get SFP Links  connection=${BTS_ID}
    ${fhs_links_in}  ${fhs_links_out}  ${fhs_cablinks_in_dns}  ${fhs_cablinks_out_dns}  ${number_of_fhs_links_out}=
    ...  Get Variables With FHS DN And FHS connections  ${sfp_links}
    ${rmod_affected_chain}=  Get Variables With RMODs DNs And RMODs Connections  ${fhs_links_in}  ${sfp_links}
    @{bbmods_under_test_dns}=  Get Dictionary Values  ${fhs_links_out}
    @{all_bbmods_list}=  admin.Get IDs For All  BBMOD  connection=${BTS_ID}
    Get Variables With Information About Cells
    ...  ${rmod_affected_chain}
    Logging With Timestamp
    ...  message=Checking if RMOD is connected only via tested FHS.
    ...  style=ONGOING
    Get RMODs Links  ${ALL_RMODS_UNDER_TEST}  ${sfp_links}
    @{all_rmods}=  admin.Get IDs For All  RMOD  timeout=30  connection=${BTS_ID}
    Set Test Variable  ${ALL_RMODS}  ${all_rmods}
    ${rmods_out_connections}=  Get RMODs Out Connections  ${sfp_links}  ${ALL_RMODS_UNDER_TEST}
    Set Test Variable  ${RMODS_OUT_CONNECTIONS}  ${rmods_out_connections}
    Decide Whether RMOD With FID 10  ${ALL_RMODS_UNDER_TEST}
    Preconditions For CNI-127210
    ${release}  admin.Get Sw Release Name  connection=${bts_id}
    ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS24R3_ENB_0000_000779_000000  alias=${bts_id}
    ...  ELSE IF  "${release}"=="SBTS25R1" and ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS25R1_ENB_0000_000130_000000  alias=${bts_id}
    ...  ELSE IF  ${PRECOND_FOR_CNI}
    ...  Check If Current Build Is Newer Than  SBTS25R2_ENB_9999_241203_000015  alias=${bts_id}
    Run keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False
    Logging With Timestamp
    ...  message=Prepare for 4003.
    ...  style=ONGOING
    Verify Whether Cells Shared And Set Allowed Alarming Objects  ${CELLS_ON_AFFECTED_RMODS_DNS}
    ${alarm_4003_status}=  Run Keyword And Return Status  Should Not Be Empty  ${AFFECTED_CELLS_IDS}
    Set Test Variable  ${ALARM_4003_STATUS}  ${alarm_4003_status}
    Run Keyword If
    ...  ${alarm_4003_status}==True
    ...  Log
    ...  FID 4003 expected and will be verified during the test.
    ...  console=True
    ...  ELSE
    ...  Log
    ...  FID 4003 NOT expected and will be verified during the test.
    ...  console=True

Step 2. Hot Remove Sync Link
    Logging With Timestamp
    ...  message=Step 2. Hot Remove Sync Link
    ...  style=STEP
    ...  frame=${TRUE}
    Log  ----- Checking the type of both FHS links${\n}  console=True
    ${fh1_before_break_status}=  Run Keyword And Return Status  Check Linkmode Of Chosen FHS Cablink
    ...  ${all_cablinks_before_break}  ${FH1_DN}  Primary
    Set Test Variable  ${FH1_BEFORE_BREAK_STATUS}  ${fh1_before_break_status}
    ${fh2_before_break_status}=  Run Keyword And Return Status  Check Linkmode Of Chosen FHS Cablink
    ...  ${all_cablinks_before_break}  ${FH2_DN}  Primary
    Set Test Variable  ${FH2_BEFORE_BREAK_STATUS}  ${fh2_before_break_status}
    Log  ----- Setting optical switch to disconnect synchronization link from FHS${\n}  console=True
    Disconnect Synchronization Link From FHS
    Check Cablink After Break States
    ...  ${broken_cablink}
    ...  (?i)Disabled
    ...  (?i)Not installed
    ...  ${second_cablink}
    ...  (?i)Disabled
    ...  (?i)Not installed
    Log  ----- Check if faultId 10 is visible on FHS and connected RMODS${\n}  console=True
    Verify FHS and RU Link Remove Check FID10  True
    Log  ----- Check if FHS and RMODS have expected states${\n}  console=True
    Verify FHS Link Remove Check States  ${fhs_under_test_dn}  disabled  not installed  ${BTS_ID}
    FOR  ${rmod_under_test_dn}  IN  @{ALL_RMODS_UNDER_TEST}
      ${rmod}=  Extract RMOD Number  ${rmod_under_test_dn}
      Run Keyword If  ${number_of_fhs_links_out}==1 and ${DESTINATIONS_${rmod}}==1
      ...  Verify States Of RMODs With 10
      Run Keyword If  ${DESTINATIONS_${rmod}}>1
      ...  Verify States Of RMODs Without 10
    END
    Log  ----- Check whether 4003 appears on some tls  console=True
    ${fid_4003_appears_true}=  Run Keyword And Return Status
    ...  Run Keyword If
    ...  ${ALARM_4003_STATUS}
    ...  Verify Assert Alarm 4003
    Run Keyword If  ${fid_4003_appears_true}  Log  Expected FID 4003 appeared on the test line.

Step 3. Automatic Sync Link Reconfiguration
    Logging With Timestamp
    ...  message=Step 3. Automatic Sync Link Reconfiguration
    ...  style=STEP
    ...  frame=${TRUE}
    Log  ----- Wait (define timeout) until second link to FHS (data link) becomes synclink${\n}  console=True
    Set Start Timestamp In IMS For CNI-127210
    Wait Until Keyword Succeeds  20x  30s  Verify FHS Sync Link Resynchronization
    Check Cablink After Break States
    ...  ${broken_cablink}
    ...  (?i)Disabled
    ...  (?i)Not installed
    ...  ${second_cablink}
    ...  (?i)Enabled
    ...  On Air
    Log  ----- FID 10 is cleared.${\n}  console=True
    admin.Add Allowed Alarm
    ...  faultId=10, severity=Minor, alarmingObjectIds[0].internal=${fhs_under_test_dn}
    ...  connection=${BTS_ID}
    FOR  ${rmod}  IN  ${RMODS_WITH_10}
      admin.Add Allowed Alarm  faultId=10, severity=Critical, alarmingObjectIds[0].internal=${rmod}  connection=${BTS_ID}
    END
    admin.Assert No Unexpected Active Alarms  connection=${BTS_ID}
    Log  ----- Wait until FHS and RMODs are detected.${\n}  console=True
    FOR  ${rmod_under_test_dn}  IN  @{RMODS_UNDER_TEST_DNS}
      Wait Until Keyword Succeeds
      ...  5x
      ...  10s
      ...  Verify RU Power Remove Insert State
      ...  ${BTS_ID}
      ...  ${rmod_under_test_dn}
      ...  Insert
      ...  10 sec
    END
    Log  ----- Waiting for 2002 to appear......${\n}  console=True
    ${fid_2002_pass}  ${alarm_active_dictionary}=  Run Keyword And Ignore Error  admin.Assert Alarm Active
    ...  faultId=2002  timeout=500  connection=${BTS_ID}
    ${lane}  ${fid_2002_severity}  ${fid_2002_faultName}=  Get Current AlarmingResource For FID 2002
    ...  ${alarm_active_dictionary}
    Run Keyword If  '${fid_2002_pass}'=='PASS'  Run Keywords
    ...  Log  FID 2002 Appeared. Continue Verification.
    ...  AND  Add Allowed Alarm  faultId=2002, severity=${fid_2002_severity[0]}, alarmingObjectIds[0].internal=${lane}  connection=${BTS_ID}
    ...  AND  Add Allowed 1868
    ...  ELSE IF  '${fid_2002_pass}'=='FAIL' and ${PRECOND_FOR_CNI}  Run Keywords
    ...  Log  FID 2002 Appeared. Continue Verification.
    ...  AND  Add Allowed Alarm  faultId=2002, severity=Minor  connection=${BTS_ID}
    ...  AND  Log  2002 Minor - 1868 may appear, adding 1868 to allowed alarms for the affected cells.  console=True
    ...  AND  Add Allowed 1868
    ...  ELSE  Fail  FID 2002 did not appear. Start analysis.

    Log  ----- Check cells......${\n}  console=True
    Verify Cells States  ${CELLS_NOT_AFFECTED}  enabled  On Air  ${BTS_ID}
    Log  ----- Check Fault ID 1868......${\n}  console=True
    Run Keyword If  '${fid_2002_pass}'=='PASS'  Run Keyword And Continue On Failure
    ...  Checking Historical Alarm After Sync Link Break
    ${availability_status}  ${operational_state}=  Verify FHS Link Remove Check States
    ...  ${fhs_under_test_dn}  enabled  not installed  ${BTS_ID}

Step 4. Hot Insert Of Disconnected Link
    Logging With Timestamp
    ...  message=Step 4. Hot Insert Of Disconnected Link
    ...  style=STEP
    ...  frame=${TRUE}
    Log
    ...  ----- Restore disconnected link from step2 & Wait until second link to FHS (data link) becomes synclink${\n}
    ...  console=True
    Reconnect Synchronization Link From FHS
    Log  ----- Check faults & Check HW states & Check cells states${\n}  console=True
    Verify Multi BTS State
    Verify Alarms On All Nodes

Get Variables With FHS SN And OS Settings
    @{fhs_sn_link_down}=  Get Dictionary Keys  ${OS_ALT_CONF_FHS_SYNC_FH1}
    Set Test Variable  ${FHS_SN_LINK_DOWN}  ${fhs_sn_link_down}
    @{fhs_alt_conf_list_fh1}=  Get Dictionary Values  ${OS_ALT_CONF_FHS_SYNC_FH1}
    @{fhs_alt_conf_list_fh2}=  Get Dictionary Values  ${OS_ALT_CONF_FHS_SYNC_FH2}
    Set Test Variable  ${FHS_ALT_CONF_LIST_FH1}  ${fhs_alt_conf_list_fh1}
    Set Test Variable  ${FHS_ALT_CONF_LIST_FH2}  ${fhs_alt_conf_list_fh2}

Verify If SN Of Tested FHS Set By User Is Available On BTS
    FOR  ${bts_node}  IN  @{cfg.NODES}
      ${status_fhs_in_tl}=  Run Keyword And Return Status
      ...  List Should Contain Sub List  ${cfg.NODES['${bts_node}']['scf_hw_fhs_list']}  ${FHS_SN_LINK_DOWN}
      Run Keyword If  ${status_fhs_in_tl}  Run Keywords
      ...  Set Test Variable  ${BTS_ID}  ${bts_node}
      ...  AND  Log  FHS set by the tester ${FHS_SN_LINK_DOWN} is connected to BTS with ID ${BTS_ID}.${\n}  console=True
      ...  ELSE  Fail  FHS set by the tester ${FHS_SN_LINK_DOWN} is NOT present in the test line. Check Variables.${\n}
    END

Get Variables With FHS DN And FHS connections
    [Arguments]  ${sfp_links}
    Get FHS distName  ${sfp_links}  ${FHS_SN_LINK_DOWN[0]}
    &{all_cablinks_before_break}=  Create Cablinks Dictionary With Distnames And LinkMode
    Set Test Variable  ${ALL_CABLINKS_BEFORE_BREAK}  ${all_cablinks_before_break}
    ${fhs_links_in}
    ...  ${fhs_links_out}
    ...  ${fhs_cablinks_in_dns}
    ...  ${fhs_cablinks_out_dns}=
    ...  Get FHS Links And Set Cablink Variables
    ...  ${fhs_under_test_dn}
    ...  ${sfp_links}
    ${number_of_fhs_links_out}=  Get Length  ${fhs_links_out}
    Set Test Variable  ${NUMBER_OF_FHS_LINKS_OUT}  ${number_of_fhs_links_out}
    Run Keyword If  ${number_of_fhs_links_out}>4  Fail  Too many cablinks out of FHS found. Please investigate further.
    [Return]  ${fhs_links_in}  ${fhs_links_out}  &{fhs_cablinks_in_dns}  ${fhs_cablinks_out_dns}  ${number_of_fhs_links_out}

Get FHS distName
    [Arguments]  ${sfp_links}  ${fhs_sn_link_down}
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${fhs_sn_link_down}'!='${link['parent']['source']['parameters']['serialNumber']}'
      Set Test Variable  ${FHS_UNDER_TEST_DN}  ${link['parent']['source']['distName']}
      Exit For Loop
    END
    Variable Should Exist  ${fhs_under_test_dn}  msg=Please check SN!!!

Get FHS Links And Set Cablink Variables
    [Arguments]  ${fhs_under_test_dn}  ${sfp_links}
    &{fhs_links_in}=  Create Dictionary
    &{fhs_links_out}=  Create Dictionary
    &{fhs_cablinks_in_dns}=  Create Dictionary
    &{fhs_cablinks_out_dns}=  Create Dictionary
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${fhs_under_test_dn}'!='${link['parent']['source']['distName']}'
      Set To Dictionary
      ...  ${fhs_links_out}
      ...  ${link['parent']['source']['physicalPort']}=${link['parent']['destination']['distName']}
      Set To Dictionary  ${fhs_cablinks_out_dns}  ${link['parent']['source']['physicalPort']}=${link['link']['distName']}
      ${fh1_found}=  Run Keyword and Return Status
      ...  Should Match Regexp
      ...  ${link['parent']['source']['physicalPort']}
      ...  .*FH1
      ${fh2_found}=  Run Keyword and Return Status
      ...  Should Match Regexp
      ...  ${link['parent']['source']['physicalPort']}
      ...  .*FH2
      Run Keyword If  ${fh1_found}==True  Set Test Variable  ${FH1_DN}  ${link['link']['distName']}
      Run Keyword If  ${fh2_found}==True  Set Test Variable  ${FH2_DN}  ${link['link']['distName']}
    END
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${fhs_under_test_dn}'!='${link['parent']['destination']['distName']}'
      Set To Dictionary
      ...  ${fhs_links_in}
      ...  ${link['parent']['destination']['physicalPort']}=${link['parent']['source']['distName']}
      Set To Dictionary  ${fhs_cablinks_in_dns}  ${link['parent']['source']['physicalPort']}=${link['link']['distName']}
    END
    Log  All connections to the tested FHS: ${fhs_links_in}  console=True
    Log  All connections out of the tested FHS: ${fhs_links_out}  console=True
    Log  All cablinks to the tested FHS: ${fhs_cablinks_in_dns}  console=True
    Log  All cablinks out of the tested FHS: ${fhs_cablinks_out_dns}  console=True
    [Return]  ${fhs_links_in}  ${fhs_links_out}  &{fhs_cablinks_in_dns}  ${fhs_cablinks_out_dns}

Get Variables With RMODs DNs And RMODs Connections
    [Arguments]  ${fhs_links_in}  ${sfp_links}
    ${rmods_under_test_dns}=  Get Dictionary Values  ${fhs_links_in}
    Set Test Variable  ${RMODS_UNDER_TEST_DNS}  ${rmods_under_test_dns}
    Find RMOD Relations  ${sfp_links}  ${FHS_SN_LINK_DOWN[0]}
    ${rmod_affected_chain}=  Prepare List of Affected Chain RMODs  ${cfg}  ${RMOD_AFFECTED_DN_SN}
    @{all_rmods_under_test}=  Combine Lists  ${rmods_under_test_dns}  ${rmod_affected_chain}
    Set Test Variable  ${ALL_RMODS_UNDER_TEST}  ${all_rmods_under_test}
    [Return]  ${rmod_affected_chain}

Get Variables With Information About Cells
    [Arguments]  ${rmod_affected_chain}
    ${cells_nr}=  admin.Get IDs For All  NRCEL  connection=${BTS_ID}
    ${cells_lte}=  admin.Get IDs For All  LNCEL  search_for_iot_cells=${True}  connection=${BTS_ID}
    ${cells_wcdma}=  admin.Get IDs For All  WNCEL  connection=${BTS_ID}
    ${cells_gsm}=  admin.Get IDs For All  GNCEL  connection=${BTS_ID}
    ${all_cells_on_tl}=  Combine Lists  ${cells_nr}  ${cells_lte}  ${cells_wcdma}  ${cells_gsm}
    Set Test Variable  ${ALL_CELLS_ON_TL}  ${all_cells_on_tl}
    ${cells_on_affected_chains_dns}=  Find Cells Relations For Units  ${rmod_affected_chain}
    Set Test Variable  ${CELLS_ON_AFFECTED_CHAINS_DNS}  ${cells_on_affected_chains_dns}
    ${cells_on_affected_rmods_dns}=  Find Cells Relations For Units  ${ALL_RMODS_UNDER_TEST}
    ${cells_on_affected_rmods_dns}=  Remove Duplicates  ${cells_on_affected_rmods_dns}
    Set Test Variable  ${CELLS_ON_AFFECTED_RMODS_DNS}  ${cells_on_affected_rmods_dns}
    ${cell_rmod_dictionary}=  Create Cell Unit Dictionary  ${ALL_RMODS_UNDER_TEST}
    Set Test Variable  ${CELL_RMOD_DICTIONARY}  ${cell_rmod_dictionary}
    @{temp_list_cells}=  Create List  ${CELLS_ON_AFFECTED_RMODS_DNS}
    FOR  ${cell_on_affected_chains_dns}  IN  @{CELLS_ON_AFFECTED_CHAINS_DNS}
      Remove Values From List  ${temp_list_cells}  ${cell_on_affected_chains_dns}
    END
    ${all_cells_on_tl_to_compare}  Set Variable  ${all_cells_on_tl}
    FOR  ${value}  IN  @{CELLS_ON_AFFECTED_RMODS_DNS}
      Remove Values From List  ${all_cells_on_tl_to_compare}  ${value}
    END
    Set Test Variable  ${CELLS_NOT_AFFECTED}  ${all_cells_on_tl_to_compare}

Find Cells Relations For Units
    [Arguments]  ${units_under_test_dns}
    ${cells_affected_dn}=  Create List
    FOR  ${unit}  IN  @{units_under_test_dns}
      ${cells_affected}=  admin.Get Cell Mapping By Module ID  ${unit}  timeout=60  connection=${BTS_ID}
      ${cells_affected_dn}=  Combine Lists  ${cells_affected_dn}  ${cells_affected}
    END
    ${cells_affected_dn_rm}=  Remove Duplicates  ${cells_affected_dn}
    [Return]  ${cells_affected_dn_rm}

Get RMODs Links
    [Arguments]  ${RMODS_UNDER_TEST_DNS}  ${sfp_links}
    FOR  ${rmod_under_test_dn}  IN  @{RMODS_UNDER_TEST_DNS}
      Get Links For Each RMOD  ${rmod_under_test_dn}  ${sfp_links}
    END

Get Links For Each RMOD
    [Arguments]  ${rmod_under_test_dn}  ${sfp_links}
    ${rmod}=  Extract RMOD Number  ${rmod_under_test_dn}
    &{rmod_links_in}=  Create Dictionary
    &{rmod_links_out}=  Create Dictionary
    &{rmod_links_in_dns}=  Create Dictionary
    &{rmod_links_out_dns}=  Create Dictionary
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${rmod_under_test_dn}'!='${link['parent']['source']['distName']}'
      Set To Dictionary
      ...  ${rmod_links_out}
      ...  ${link['parent']['source']['physicalPort']}=${link['parent']['destination']['distName']}
      Set Test Variable  ${RMOD_LINKS_OUT_${rmod}}  ${rmod_links_out}
      Set To Dictionary  ${rmod_links_out_dns}  ${link['parent']['source']['physicalPort']}=${link['link']['distName']}
      Set Test Variable  ${RMOD_LINKS_OUT_DNS_${rmod}}  ${rmod_links_out_dns}
    END
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${rmod_under_test_dn}'!='${link['parent']['destination']['distName']}'
      Set To Dictionary
      ...  ${rmod_links_in}
      ...  ${link['parent']['destination']['physicalPort']}=${link['parent']['source']['distName']}
      Set Test Variable  ${RMOD_LINKS_IN_${rmod}}  ${rmod_links_in}
      Set To Dictionary  ${rmod_links_in_dns}  ${link['parent']['source']['physicalPort']}=${link['link']['distName']}
      Set Test Variable  ${RMOD_LINKS_IN_DNS_${rmod}}  ${rmod_links_in_dns}
    END
    ${rmod_links_out_rem_duplicates}=  Remove Duplicates  ${RMOD_LINKS_OUT_${rmod}}
    ${rmod_diff_connections}=  Get Length  ${rmod_links_out_rem_duplicates}
    Set Test Variable  ${DESTINATIONS_${rmod}}  ${rmod_diff_connections}

Extract RMOD Number
    [Arguments]  ${rmod_under_test_dn}
    ${rmod_r_no}=  Fetch From Right  string=${rmod_under_test_dn}  marker=/
    ${rmod_no}=  Fetch From Right  string=${rmod_under_test_dn}  marker=-
    ${rmod}=  Replace String Using Regexp  string=${rmod_r_no}  pattern=.*R-\\d  replace_with=RMOD_${rmod_no}
    [Return]  ${rmod}

Get RMODs Out Connections
    [Arguments]  ${sfp_links}  ${tested_rmods}
    &{rmods_out_connections}=  Create Dictionary
    FOR  ${rmod_under_test_dn}  IN  @{tested_rmods}
      ${rmods_out_connections}=  Find RMOD Connections  ${rmod_under_test_dn}  ${SFP_LINKS}  ${rmods_out_connections}
    END
    Log  RMODs connections ${rmods_out_connections}  console=True
    [Return]  ${rmods_out_connections}

Find RMOD Connections
    [Arguments]  ${rmod_under_test_dn}  ${SFP_LINKS}  ${rmods_out_connections}
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${rmod_under_test_dn}'!='${link['parent']['source']['distName']}'
      Set To Dictionary  ${rmods_out_connections}  ${rmod_under_test_dn}=${link['parent']['destination']['distName']}
    END
    [Return]  ${rmods_out_connections}

Decide Whether RMOD With FID 10
    [Arguments]  ${rmods_under_test_dns}
    &{rmods_and_links_dict}=  Create Dictionary
    FOR  ${rmod_under_test_dn}  IN  @{rmods_under_test_dns}
      ${rmod}=  Extract RMOD Number  ${rmod_under_test_dn}
      Set To Dictionary  ${rmods_and_links_dict}  ${rmod_under_test_dn}=${DESTINATIONS_${rmod}}
    END
    @{rmods_with_10}=  Create List
    Set Test Variable  ${RMODS_WITH_10}  ${rmods_with_10}
    @{rmods_possibly_without_10}=  Create List
    Set Test Variable  ${RMODS_POSSIBLY_WITHOUT_10}  ${rmods_possibly_without_10}
    FOR  ${rmod_and_link}  IN  @{rmods_and_links_dict}
      ${number_of_links}=  Get Dictionary Values  ${rmods_and_links_dict}
      Run Keyword If  ${number_of_links[0]}==1
      ...  Append To List  ${rmods_with_10}  ${rmod_and_link}
      ...  ELSE  Append To List  ${rmods_possibly_without_10}  ${rmod_and_link}
    END
    FOR  ${rmod_possibly_without_10}  IN  @{rmods_possibly_without_10}
      ${rmod}=  Extract RMOD Number  ${rmod_possibly_without_10}
      ${cablinks}=  Get Dictionary Values  ${RMOD_LINKS_OUT_DNS_${rmod}}
      Check Cablink Mode  ${cablinks}  ${rmod_possibly_without_10}
    END

Check Cablink Mode
    [Arguments]  ${cablinks}  ${rmod_possibly_without_10}
    @{rmods_without_10}=  Create List
    Set Test Variable  ${RMODS_WITHOUT_10}  ${rmods_without_10}
    FOR  ${cablink}  IN  @{cablinks}
      @{cablink_list}=  Create List  ${cablink}
      ${status}=  Run Keyword And Return Status
      ...  Check Linkmode Of Chosen Cablink
      ...  ${ALL_CABLINKS_BEFORE_BREAK}
      ...  ${cablink_list}
      ...  Primary
      ${cablink_destination}=  Run Keyword If
      ...  ${status}==True
      ...  admin.Get Parameters For
      ...  CABLINK
      ...  ${cablink}
      ...  connection=${BTS_ID}
      ${second_link_not_fhs}=  Run Keyword And Return Status
      ...  Should Not Be Equal
      ...  ${cablink_destination['firstEndpointDN']}
      ...  ${FHS_UNDER_TEST_DN}
      Run Keyword If  ${second_link_not_fhs}==True  Run Keywords
      ...  Append To List  ${RMODS_WITHOUT_10}  ${rmod_possibly_without_10}
      ...  AND  Log  This RMOD ${rmod_possibly_without_10} should NOT raise FID 10  console=True
    END

Verify Whether Cells Shared And Set Allowed Alarming Objects
    [Arguments]  ${cells_on_affected_rmods_dns}
    @{affected_cells_ids}=  Create List
    Set Test Variable  ${AFFECTED_CELLS_IDS}  ${affected_cells_ids}
    FOR  ${cell}  IN  @{cells_on_affected_rmods_dns}
      ${cell_id}=  Fetch From Right  ${cell}  marker=-
      ${cell_info}=  Fetch From Right  ${cell}  marker=/
      ${cell_tech}=  Fetch From Left  ${cell_info}  marker=_
      ${cell_tech_lower}=  Convert To Lower Case  ${cell_tech}
      ${cell_tech}=  Get Substring  ${cell_tech}  0  5
      ${cell_is_shared}=  Check Affected Cells Sharing Status Modified  ${BTS_ID}  ${cell_id}  ${cell_tech}
      Run Keyword If  ${cell_is_shared}
      ...  Append To List  ${AFFECTED_CELLS_IDS}  ${cell}
    END
    ${AFFECTED_CELLS_IDS}=  Remove Duplicates  ${AFFECTED_CELLS_IDS}
    FOR  ${rmod}  IN  @{CELL_RMOD_DICTIONARY}
      ${cells_on_the_rmod}=  Set Variable  ${CELL_RMOD_DICTIONARY['${rmod}']}
      Check If Cell On This RMOD And Add Allowed 10 Major  ${rmod}  ${cells_on_the_rmod}
    END

Check If Cell On This RMOD And Add Allowed 10 Major
    [Arguments]  ${rmod}  ${cells_on_the_rmod}
    FOR  ${alarm_4003_cell}  IN  @{AFFECTED_CELLS_IDS}
      ${cell_and_tech}=  Fetch From Right  ${alarm_4003_cell[0]}  marker=/
      ${cell}=  Fetch From Left  ${cell_and_tech}  marker=-
      ${status}=  Run Keyword And Return Status  Should Contain Match  ${cells_on_the_rmod}  regexp=.*${cell}
      Run Keyword If
      ...  ${status}
      ...  admin.Add Allowed Alarm
      ...  faultId=10, severity=Major, alarmingObjectIds[0].internal=${rmod}
      ...  connection=${BTS_ID}
      ...  ELSE
      ...  Continue For Loop
    END

Check Linkmode Of Chosen FHS Cablink
    [Arguments]  ${all_cablinks_before_break}  ${cablink_dn}  ${linkmode}
    ${cablink_linkmode_expected}=  Set Variable  ${FALSE}
    FOR  ${cablink_before_break}  IN  @{all_cablinks_before_break}
      Continue For Loop If  '${cablink_dn}'!='${all_cablinks_before_break['${cablink_before_break}']['internal']}'
      ${cablink_linkmode}=  Run Keyword and Return Status  Should Be Equal
      ...  '${linkmode}'  '${all_cablinks_before_break['${cablink_before_break}']['linkmode']}'
      ${cablink_linkmode_expected}=  Set Variable If  ${cablink_linkmode}==True  ${TRUE}
      Run Keyword If  ${cablink_linkmode_expected}==True  Exit For Loop
    END
    Run Keyword If  ${cablink_linkmode_expected}  Log to Console  Cablink ${cablink_dn} with ${linkmode} linkmode
    ...  ELSE  Run Keywords  Log To Console  Cablink ${cablink_dn} without ${linkmode} linkmode.
    ...  AND  Fail  Unexpected linkmode.

Disconnect Synchronization Link From FHS
    @{broken_cablink}=  Create List
    Set Test Variable  ${BROKEN_CABLINK}  ${broken_cablink}
    @{second_cablink}=  Create List
    Set Test Variable  ${SECOND_CABLINK}  ${second_cablink}
    Run Keyword If  ${FH1_BEFORE_BREAK_STATUS}==True and ${FH2_BEFORE_BREAK_STATUS}==False  Run Keywords
    ...  Optical Switch Set Configuration Remove  ${FHS_ALT_CONF_LIST_FH1}
    ...  AND  Log  Disconnecting link from FH1  console=True
    ...  AND  Append To List  ${broken_cablink}  ${FH1_DN}
    ...  AND  Append To List  ${second_cablink}  ${FH2_DN}
    Run Keyword If  ${FH1_BEFORE_BREAK_STATUS}==False and ${FH2_BEFORE_BREAK_STATUS}==True  Run Keywords
    ...  Optical Switch Set Configuration Remove  ${FHS_ALT_CONF_LIST_FH2}
    ...  AND  Log  Disconnecting link from FH2  console=True
    ...  AND  Append To List  ${broken_cablink}  ${FH2_DN}
    ...  AND  Append To List  ${second_cablink}  ${FH1_DN}
    Run Keyword If  ${FH1_BEFORE_BREAK_STATUS}==${FH2_BEFORE_BREAK_STATUS}
    ...  Fail  msg=No synchro link or both are seen as synchro. Check the provided test data.

Check Cablink After Break States
    [Arguments]
    ...  ${broken_cablink}
    ...  ${oper_state_1}
    ...  ${avail_status_1}
    ...  ${second_cablink}
    ...  ${oper_state_2}
    ...  ${avail_status_2}
    ${prim_disabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${broken_cablink}  ${oper_state_1}  ${avail_status_1}  ${BTS_ID}
    Run Keyword If  ${prim_disabled}  Log To Console  Primary Cablink ${broken_cablink} Disabled  ELSE
    ...  Fail  Primary cabling ${broken_cablink} NOT disabled. Check optical switch configuration
    ${second_disabled}=  Run Keyword and Return Status  Wait Until Keyword Succeeds  120  30
    ...  Check Cablink State  ${second_cablink}  ${oper_state_2}  ${avail_status_2}  ${BTS_ID}
    Run Keyword If  ${second_disabled}  Log To Console  Secondary Cablink ${second_cablink} Disabled  ELSE
    ...  Fail  Secondary cabling ${second_cablink} NOT disabled. Check optical switch configuration

Verify FHS and RU Link Remove Check FID10
    [Arguments]  ${alarm_list_not_empty}
    ${fid_10_pass_01}  ${alarm_active_10_dictionary_01}=  Run Keyword And Ignore Error  admin.Assert Alarm Active
    ...  faultId=10  timeout=40  connection=${BTS_ID}
    ${fid_10_pass_02}  ${alarm_active_10_dictionary_02}=  Run Keyword And Ignore Error  admin.Assert Alarm Active
    ...  faultId=10  timeout=40  connection=${BTS_ID}
    ${fid_10_pass_03}  ${alarm_active_10_dictionary_03}=  Run Keyword And Ignore Error  admin.Assert Alarm Active
    ...  faultId=10  timeout=40  connection=${BTS_ID}
    @{alarm_active_10_dictionary}=  Create List
    ${alarm_active_10_dictionary}=  Run Keyword If
    ...  '${fid_10_pass_01}'=='PASS'
    ...  Combine Lists
    ...  ${alarm_active_10_dictionary}
    ...  ${alarm_active_10_dictionary_01}
    ${alarm_active_10_dictionary}=  Run Keyword If
    ...  '${fid_10_pass_02}'=='PASS'
    ...  Combine Lists
    ...  ${alarm_active_10_dictionary}
    ...  ${alarm_active_10_dictionary_02}
    ${alarm_active_10_dictionary}=  Run Keyword If
    ...  '${fid_10_pass_03}'=='PASS'
    ...  Combine Lists
    ...  ${alarm_active_10_dictionary}
    ...  ${alarm_active_10_dictionary_03}
    ${fid_10_found}=  Run Keyword And Return Status  Should Not Be Empty  ${alarm_active_10_dictionary}
    ${fid_10_expected}=  Run Keyword And Return Status  Should Be Equal  '${fid_10_found}'  '${alarm_list_not_empty}'
    &{alarming_resources_fid10}=  Run Keyword If  ${fid_10_expected}==True
    ...  Get Current AlarmingResources And Severity For FID 10  ${alarm_active_10_dictionary}
    ...  ELSE  Return From Keyword
    @{fhs_rmod_affected}=  Create List
    Append To List  ${fhs_rmod_affected}  ${FHS_UNDER_TEST_DN}
    @{fhs_rmod_affected}=  Combine Lists  ${fhs_rmod_affected}  ${RMODS_WITH_10}
    Sort List  ${fhs_rmod_affected}
    ${alarming_resources_fid10_fhs}=  Get Dictionary Keys  ${alarming_resources_fid10}
    Sort List  ${alarming_resources_fid10_fhs}
    ${fid10_lists_equal}=  Run Keyword And Return Status
    ...  Lists Should Be Equal
    ...  ${fhs_rmod_affected}
    ...  ${alarming_resources_fid10_fhs}
    Run Keyword If
    ...  ${fid10_lists_equal}==True
    ...  Log
    ...  Only expected items raised FID 10. Proceeding to the next step.
    ...  console=True
    ...  ELSE
    ...  Fail
    ...  Lists of items expecting FID 10 not equal. Analysis required.

Get Current AlarmingResources And Severity For FID 10
    [Arguments]  ${alarmlist}
    &{alarming_resources_fid10}=  Create Dictionary
    FOR  ${alarm}  IN  @{alarmlist}
      Run Keyword If  '${alarm['faultId']}'=='10'
      ...  Set To Dictionary  ${alarming_resources_fid10}  ${alarm['alarmingResource']}=${alarm['severity']}
    END
    [Return]  ${alarming_resources_fid10}

Verify FHS Link Remove Check States
    [Arguments]  ${fhs_under_test_dn}  ${oper_state}  ${avail_status}  ${alias}
    ${hw_states}=  admin.Get Parameters For  FHS  id_num=${fhs_under_test_dn}  connection=${alias}
    Run Keyword And Continue On Failure  Should Be Equal  ${hw_states['operationalState']}  ${oper_state}
    ${avail_status_exists}=  Run Keyword And Return Status  Should Not Be Empty  '${hw_states['availabilityStatus']}'
    Run Keyword If  ${avail_status_exists}  Should Match Regexp  ${hw_states['availabilityStatus']}  ${avail_status}
    Run Keyword If  ${avail_status_exists}==False  Log To Console  availabilityStatus of the FHS On Air (-)

Verify States Of RMODs With 10
    FOR  ${rmod_under_test_temp}  IN  @{RMODS_WITH_10}
      Wait Until Keyword Succeeds
      ...  10x
      ...  20s
      ...  Verify RU Power Remove Insert State
      ...  ${BTS_ID}
      ...  ${rmod_under_test_temp}
      ...  Remove
      ...  20 sec
    END

Verify States Of RMODs Without 10
    FOR  ${rmod_under_test_temp}  IN  @{RMODS_POSSIBLY_WITHOUT_10}
      Wait Until Keyword Succeeds
      ...  10x
      ...  20s
      ...  Verify RU Power Remove Insert State
      ...  ${BTS_ID}
      ...  ${rmod_under_test_temp}
      ...  Insert
      ...  20 sec
    END

Verify FHS Sync Link Resynchronization
    &{all_cablinks_after_break}=  Create Cablinks Dictionary With Distnames And LinkMode
    ${fh1_after_break_status}=  Run Keyword And Return Status
    ...  Check Linkmode Of Chosen FHS Cablink
    ...  ${all_cablinks_after_break}
    ...  ${FH1_DN}
    ...  Primary
    Set Test Variable  ${FH1_AFTER_BREAK_STATUS}  ${fh1_after_break_status}
    ${fh2_after_break_status}=  Run Keyword And Return Status
    ...  Check Linkmode Of Chosen FHS Cablink
    ...  ${all_cablinks_after_break}
    ...  ${FH2_DN}
    ...  Primary
    Set Test Variable  ${FH2_AFTER_BREAK_STATUS}  ${fh2_after_break_status}
    ${cells_n_af_on_air}=  Run Keyword And Return Status
    ...  Verify Cells States
    ...  ${CELLS_NOT_AFFECTED}
    ...  enabled
    ...  On Air
    ...  ${BTS_ID}
    ${condition_1}=  Set Variable  ${cells_n_af_on_air}==True
    ${condition_2}=  Set Variable  ${FH1_BEFORE_BREAK_STATUS}!=${FH1_AFTER_BREAK_STATUS}
    ${condition_3}=  Set Variable  ${FH2_BEFORE_BREAK_STATUS}!=${FH2_AFTER_BREAK_STATUS}
    Run Keyword If
    ...  ${condition_1} and ${condition_2} and ${condition_3}
    ...  Log
    ...  Resync suceeded
    ...  console=True
    Run Keyword If  ${cells_n_af_on_air}==True and ${FH1_AFTER_BREAK_STATUS}==${FH2_AFTER_BREAK_STATUS}
    ...  Fail  msg=No synchro link or both are seen as synchro. Check the provided test data.
    Run Keyword If  ${cells_n_af_on_air}==False  Run Keywords
    ...  Log  Unexpected state of not affected cells. Test failed.
    ...  AND  Return From Keyword

Get Current AlarmingResource For FID 2002
    [Arguments]  ${alarmlist}
    @{fid_2002_lane}=  Create List
    @{fid_2002_severity}=  Create List
    @{fid_2002_faultName}=  Create List
    FOR  ${alarm}  IN  @{alarmlist}
      Run Keyword If  '${alarm['faultId']}'=='2002'  Run Keywords
      ...  Set Test Variable  ${FID_2002_LANE}  ${alarm['alarmingObjectIds'][0]['internal']}
      ...  AND  Append To List  ${fid_2002_severity}  ${alarm['severity']}
      ...  AND  Append To List  ${fid_2002_faultName}  ${alarm['faultName']}
    END
    [Return]  ${fid_2002_lane}  ${fid_2002_severity}  ${fid_2002_faultName}

Add Allowed 1868
    FOR  ${cell_dn}  IN  @{CELLS_ON_AFFECTED_RMODS_DNS}
      admin.Add Allowed Alarm
      ...  faultId=1868, severity=Critical, alarmingObjectIds[0].internal=${cell_dn}
      ...  connection=${BTS_ID}
    END

Extract Cell Numbers
    [Arguments]  ${cells_on_affected_units_dns}
    @{cells_on_affected_units_numbers}=  Create List
    FOR  ${cell_on_affected_unit_dn}  IN  @{cells_on_affected_units_dns}
      ${cell_no}=  Fetch From Right  string=${cell_on_affected_unit_dn}  marker=-
      Append To List  ${cells_on_affected_units_numbers}  ${cell_no}
    END
    [Return]  ${cells_on_affected_units_numbers}

Checking Historical Alarm After Sync Link Break
    ${alarm_unexpected_status}  Run Keyword And Return Status
    ...  admin.Assert No Unexpected Historical Alarms
    ...  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=True
    Run Keyword If  not ${alarm_unexpected_status}  Run Keywords
    ...  Log To Console  ${GLO_ADMIN_ALLOWED_ALARMS}
    ...  AND  Fail  Unexpected Historical Alarms Visible

Reconnect Synchronization Link From FHS
    Optical Reconfiguration Tested Configuration   ${cfg.configuration_name}
    &{all_cablinks_after_reconnection}=  Create Cablinks Dictionary With Distnames And LinkMode
    ${fh1_after_reconnection_status}=  Run Keyword And Return Status  Check Linkmode Of Chosen FHS Cablink
    ...  ${all_cablinks_after_reconnection}  ${FH1_DN}  Primary
    Set Test Variable  ${FH1_AFTER_RECONNECION_STATUS}  ${fh1_after_reconnection_status}
    ${fh2_after_reconnection_status}=  Run Keyword And Return Status  Check Linkmode Of Chosen FHS Cablink
    ...  ${all_cablinks_after_reconnection}  ${FH2_DN}  Primary
    Set Test Variable  ${FH2_AFTER_RECONNECION_STATUS}  ${fh2_after_reconnection_status}
    Run Keyword If  ${fh1_after_reconnection_status}==True and ${fh2_after_reconnection_status}==False
    ...  Log  FH1 is a synclink  console=True
    Run Keyword If  ${fh1_after_reconnection_status}==False and ${fh2_after_reconnection_status}==True
    ...  Log  FH2 is a synclink  console=True
    Run Keyword If  ${fh1_after_reconnection_status}==${fh2_after_reconnection_status}
    ...  Fail  msg=No synchro link or both are seen as synchro. Check the provided test data.
    Check Cablink After Break States  ${broken_cablink}  (?i)Enabled  On Air  ${second_cablink}  (?i)Enabled  On Air

Add 4003 Alarming Objects
    [Arguments]  ${all_shared_cells}
    FOR  ${shared_cell}  IN  ${all_shared_cells}
      admin.Add Allowed Alarm
      ...  faultId=4003, severity=Minor, alarmingObjectIds[0].internal=${shared_cell}
      ...  connection=${BTS_ID}
    END

Check Affected Cells Sharing Status Modified
    [Arguments]  ${ru_bts_id}  ${cell_ru_sn_list}  ${cell_type}
    ${share_type}=  Set Variable  scf_cell_ru_shared
    ${cell_ru_sn_list}=  Convert Item To Single Element List  ${cell_ru_sn_list}
    ${cell_ru_sn_list}=  Remove Duplicates  ${cell_ru_sn_list}
    FOR  ${cell_id}  IN  @{cell_ru_sn_list}
      ${cell_is_shared}=  Get From Dictionary  ${cfg.NODES['${ru_bts_id}']['${cell_type}']['${cell_id}']}  ${share_type}
      Exit For Loop If  ${cell_is_shared}
    END
    [Return]  ${cell_is_shared}

Verify Cells States
    [Arguments]  ${cells_on_affected_rmods_dns}  ${oper_state}  ${avail_status}  ${alias}
    FOR  ${cell_on_affected_rmod_dn}  IN  @{cells_on_affected_rmods_dns}
      ${cell}=  Fetch From Right  string=${cell_on_affected_rmod_dn}  marker=/
      ${cell_tech}=  Fetch From Left  string=${cell}  marker=_
      ${cell_tech}=  Get Substring  ${cell_tech}  0  5
      ${hw_states}=  admin.Get Parameters For  ${cell_tech}  id_num=${cell_on_affected_rmod_dn}  connection=${alias}
      Should Be Equal
      ...  ${hw_states['operationalState']}
      ...  ${oper_state}
      ...  msg=Cell ${cell} does not have expected operationalState.
      ${avail_status_exists}=  Run Keyword And Return Status  Should Not Be Empty  '${hw_states['availabilityStatus']}'
      ${avail_status_equal}=  Run Keyword And Return Status  Run Keyword If  ${avail_status_exists}
      ...  Should Match Regexp  ${hw_states['availabilityStatus']}  ${avail_status}
      ${avail_status_on_air}=  Run Keyword And Return Status
      ...  Run Keyword If
      ...  ${avail_status_exists}==False
      ...  Should Be Equal
      ...  ${avail_status}
      ...  On Air
      Run Keyword If  '${hw_states['operationalState']}'=='enabled' and ${avail_status_on_air}==True
      ...  Log  Cell ${cell} is On Air
      Run Keyword If  ${avail_status_equal}==True
      ...  Log  Cell ${cell} has expected operationalState and availabilityStatus
      ...  ELSE  Fail  Cell ${cell} has unexpected operationalState and availabilityStatus
    END

Verify Assert Alarm 4003
    FOR  ${affected_cell}  IN  @{AFFECTED_CELLS_IDS}
      ${fid_4003_pass}  ${alarm_active_dictionary_4003}=  Run Keyword And Ignore Error  admin.Assert Alarm Active
      ...  faultId=4003, alarmingObjectIds[0].internal=${affected_cell}  timeout=120  connection=${BTS_ID}
      Run Keyword If
      ...  '${fid_4003_pass}'=='PASS'
      ...  admin.Add Allowed Alarm
      ...  faultId=4003, severity=Minor, alarmingObjectIds[0].internal=${affected_cell}
      ...  connection=${BTS_ID}
    END
