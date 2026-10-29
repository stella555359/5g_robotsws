*** Settings ***
Documentation
...  The purpose of this test case is to verify functionalities and recovery actions of BTS during breaking link
...  between Radio Module and System Module (BBMOD).

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../../Resources/SiSo_L3_call.robot
Resource    ../../../../resources/ca_BSSM_WDM_link_breaker.robot    #commands to operate the calient switch

*** Variables ***
${PING_RMOD_TIMEOUT}     180       # Timeout to restore ping to rmod, default 180s
${CELLS_ONLINE_TIMEOUT}  240       # Timeout for cell to go online before fail
${RMOD_SN} 			               # list of serial numbers RMODs eg. F7183736276K9180831175 - fill by tester
${SWITCH_IP_PORT_A}                # Switch IP address and its port (e.g. 10.42.201.18_211) corresponding to OPT_IF1 on webem - fill by tester
${SWITCH_IP_PORT_B}                # Switch IP address (it can be different) and its second port (e.g. 10.42.201.10_4.5.8)
                                   # ... corresponding to OPT_IF2 on webem - fill by tester
${SWITCH_LINK_BREAK_TIME}  90000   # Time of link break in ms
${SELECTED_CELLS}  None
${SISO_L3_CALL}  False             # default value for L3 call is False, set test variable as True to perform test with L3 call
${CELLS_YAML_PATH}                 # mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
${LOGS_DIR}                        # path to store logs from L3 call
${node}  default

*** Keywords ***
TC__SiSo_REC_RU_Hot_remove_hot_insert_for_eCPRI
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to verify functionalities and recovery actions of BTS during breaking link
    ...  between Radio Module and System Module (BBMOD).
    ...  RM and BBU are connected with optical fibers by optical switch - Calient.
    ...  Test supports optical switch Calient S320 (using TL1, TL2 commands) and supports multi-link configuration
    ...  with two optical fibers: Primary Link, Secondary Link.
    ...  Test case checks correctness of eCPRI link interruption on Classical BTS, on RU 6.2 - AKNB (5G).
    ...  The test scenario includes checking and restoring connections separately for the Sync,Condig,Data Link,
    ...  Data Link and both simultaneously.
    ...  Time of link break in set on 90000 ms.
    ...
    ...  Mandatory variable to perform test: IP of optical switch, number of ports, e.g.
    ...  ${SWITCH_IP_PORT_A}  10.42.201.18_211
    ...  ${SWITCH_IP_PORT_B}  10.42.201.10_4.5.8  (IP of switch can be different, than first one)
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}
    ...  ${CELLS_YAML_PATH}
    ...  ${LOGS_DIR}
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/FPB-1013128 - Initial creation


    Set Tags    CA-BS-SM    OWNER-malgorzata.piecyk-celuch@nokia.com    AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...    MAINTAINER-malgorzata.piecyk-celuch@nokia.com    PHASE-CRT    SW-SBTS24
    ...    FEATURE-CB008969    CNI-102820

    Step 1: Test Case Preconditions
    Step 2: Hot remove all links
    Step 3: Hot insert all links
    Step 4: Hot remove Data Link
    Step 5: Hot insert Data Link
    Step 6: Hot remove Configuration, Data and Synchronization Link
    Step 7: Hot insert Configuration, Data and Synchronization Link


Step 1: Test Case Preconditions
    Log  Step 1: Test Case Preconditions  console=True
    Log  -------------------------------${\n}  console=True

    Log  Getting BTS info  console=True
    ${bts}  admin.Get BTS Info

    FOR  ${rmod}  IN  @{bts['radioModules']['rmod']}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        ${rmod_distname_id}  Set Variable  ${rmod['id']['internal']}
    END
    Set Test Variable  ${RMOD_DISTNAME_ID}

    ${all_cells}  Create List
    ${rmod_cells}  Get All Cells Mapping By RMOD Id  ${RMOD_DISTNAME_ID}
    ${all_cells}  Combine Lists  ${all_cells}  ${rmod_cells}
    Set Test Variable  ${CELLS}  ${all_cells}

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=60  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log To Console  All cells are onAir${\n}
    ...  ELSE
    ...  Fail  Cells are not onAir${\n}

    Set Test Variable  ${SELECTED_CELLS}  ${CELLS}
    Log  ${SELECTED_CELLS}
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
    Run Keyword If  ${SISO_L3_CALL}  SiSo L3 Call
    ...  ELSE  Log  Call skipped  console=True


Step 2: Hot remove all links
    Log  ${\n}Step 2: Perform hot remove all links  console=True
    Log       ------------------------------------    console=True

    Log  ${\n}Breaking all optical links between SMOD and RMOD${\n}  console=True
    Run Keywords  Set Optical Switch And Perform Break Link  ${SWITCH_IP_PORT_A}  ${SWITCH_LINK_BREAK_TIME}
    ...  AND  Set Optical Switch And Perform Break Link  ${SWITCH_IP_PORT_B}  ${SWITCH_LINK_BREAK_TIME}

    Log  Checking RMOD states and alarms  console=True
    ${rmod_availability}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert  RMOD  ${RMOD_DISTNAME_ID}  availabilityStatus=regex"(?i)not installed"  alias=${node}
    ${rmod_operability}  Run Keyword And Return Status
       ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert  RMOD  ${RMOD_DISTNAME_ID}  operationalState=regex"(?i)Disabled"  alias=${node}
    ${rmod_alarm}  Run Keyword And Return Status
       ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert Alarm Active  faultId=10, alarmId=7116, severity=Critical  timeout=30

    Run Keyword If  '${rmod_operability}'=='True' and '${rmod_alarm}'=='True' and '${rmod_availability}'=='True'
    ...  Log  RMOD has correct states and FID 10 appeared !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD has wrong states or FID 10 did not appeared, check logs !${\n}  console=True
    ...  AND  Fail  RMOD has wrong states or FID 10 did not appeared, check logs !

    Log  Checking if all cells are failed or degraded after breaking link  console=True
    Check If Cells Are Failed Or Degraded


Step 3: Hot insert all links
    Log  ${\n}Step 3: Checking BTS status after insert all links  console=True
    Log  --------------------------------------------------${\n}  console=True

    Log  Waiting for restoring RMOD(s)${\n}  console=True

    Log  Checking if cells and RMODs are onAir  console=True
    ${bts_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  6 min  30 s  Check If All Cells And Modules Are OnAir  timeout=60  alias=${node}

    Run Keyword If  '${bts_status}'=='True'
    ...  Log  All cells and modules are onAir !  console=True
    ...  ELSE  Run Keywords
    ...  Log  ALL cells and modules are not onAir !  console=True
    ...  AND  Fail  ALL cells and modules are not onAir !

    Log  ${\n}Checking if faultId 10 is cleared  console=True
    ${rmod_alarm}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert Alarm Inactive  faultId=10,  alarmId=7116, severity=Critical  timeout=300

    Run Keyword If  '${rmod_alarm}'=='True'
    ...  Log  FID 10 is cleared !  console=True
    ...  ELSE  Run Keywords
    ...  Log  For FID 10 is still visible, check logs !  console=True
    ...  AND  Fail  For FID 10 is still visible, check logs !

    Run Keyword If  ${SISO_L3_CALL}  SiSo L3 Call
    ...  ELSE  Log  ${\n}Call skipped  console=True


Step 4: Hot remove Data Link
    Log  ${\n}Step 4: Perform hot remove Data Link  console=True
    Log  -----------------------------------------${\n}  console=True

    Log  Checking which port will be used for breaking Data (Secondary) Link  console=True
    ${primary_on_first_port}  Get Links Location By RMOD Distname  ${RMOD_DISTNAME_ID}

    ${bts}  admin.Get BTS Info
    FOR  ${cable}  IN  @{bts['cables']}
        Continue For Loop If  '${rmod_distname_id}' not in '${cable['secondEndPointId']['internal']}'
        Run Keyword If
        ...  '${cable['linkMode']['synchronization']}'=='True'
        ...  Set Test Variable  ${PRIMARY_DISTNAME}  ${cable['id']['internal']}
        ...  ELSE  Set Test Variable  ${SECONDARY_DISTNAME}  ${cable['id']['internal']}
    END

    Log  ${\n}Checking which cells are deployed on secondary link  console=True
    ${cablings_with_affected_cells}  Create Cablinks Dictionary With Affected Cells Lists  connection=default
    @{listOfCellsOnDataLink}  Create List
    FOR  ${cabling}  ${cells}  IN ZIP  ${cablings_with_affected_cells.keys()}  ${cablings_with_affected_cells.values()}
        Continue For Loop If  '${SECONDARY_DISTNAME}'!='${cabling}'
        ${listOfCellsOnDataLink}  Set Variable  ${cells}
    END
    Log  Cell(s) ${listOfCellsOnDataLink} is/are deployed on Data Link  console=True

    Log  ${\n}Performing hot remove secondary link  console=True
    Run Keyword If  '${primary_on_first_port}'=='True'  Run Keywords
    ...  Log  Breaking link will be proceeded from port OPT_IF2${\n}  console=True
    ...  AND  Set Optical Switch And Perform Break Link  ${SWITCH_IP_PORT_B}  ${SWITCH_LINK_BREAK_TIME}
    ...  ELSE  Run Keywords  Log  Breaking link will be proceeded from port OPT_IF1${\n}  console=True
    ...  AND  Set Optical Switch And Perform Break Link  ${SWITCH_IP_PORT_A}  ${SWITCH_LINK_BREAK_TIME}

    Log  Checking RMOD states and alarms  console=True
    ${rmod_availability}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  30s  admin.Assert No  RMOD  availabilityStatus=regex"(.*)"  serialNumber=${RMOD_SN}  alias=${node}
    ${rmod_operability}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  30s  admin.Assert  RMOD  ${RMOD_DISTNAME_ID}  operationalState=regex"(?i)Enabled"  alias=${node}

    Run Keyword If  '${rmod_operability}'=='True' and '${rmod_availability}'=='True'
    ...  Log  RMOD has correct states !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD has wrong states, check logs !  console=True
    ...  AND  Fail  RMOD has wrong states, check logs !

    Log  Checking if tested cells have correct states:${\n}  console=True
    FOR    ${cell}  IN  @{listOfCellsOnDataLink}
       ${cell_LN_status}  Run Keyword And Return Status  Run Keyword If  'LNCEL' in '${cell}'  Run Keywords
       ...  Wait Until Keyword Succeeds  1 min  30 s  admin.Assert  LNCEL  ${cell}  operationalState=regex"(?i)Disabled"  alias=${node}
       ...  AND  Log  Cell LTE ${cell} will be verified  console=True
       ...  ELSE  Log  There is no Lte cells to verify  console=True
       ${cell_NR_status}  Run Keyword And Return Status  Run Keyword If  'NRCEL' in '${cell}'  Run Keywords
       ...  Wait Until Keyword Succeeds  1 min  30 s  admin.Assert  NRCEL  ${cell}  operationalState=regex"(?i)Disabled"  alias=${node}
       ...  AND  Log  Cell NR ${cell} will be verified  console=True
       ...  ELSE  Log  There is no NR cells to verify  console=True
       ${cell_WC_status}  Run Keyword And Return Status  Run Keyword If  'WNCEL' in '${cell}'  Run Keywords
       ...  Wait Until Keyword Succeeds  1 min  30 s  admin.Assert  WNCEL  ${cell}  operationalState=regex"(?i)Disabled"  alias=${node}
       ...  AND  Log  Cell WCDMA ${cell} will be verified  console=True
       ...  ELSE  Log  There is no WCDMA cells to verify  console=True
       ${cell_GS_status}  Run Keyword And Return Status  Run Keyword If  'GNCEL' in '${cell}'  Run Keywords
       ...  Wait Until Keyword Succeeds  1 min  30 s  admin.Assert  GNCEL  ${cell}  operationalState=regex"(?i)Disabled"  alias=${node}
       ...  AND  Log  Cell GSM ${cell} will be verified  console=True
       ...  ELSE  Log  There is no GSM cells to verify  console=True
    END

    Run Keyword If  '${cell_LN_status}'=='True' and '${cell_NR_status}'=='True' and '${cell_WC_status}'=='True' and '${cell_GS_status}'=='True'
    ...  Log  ${\n}All tested cells have correct states !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Some cells have wrong states, check logs !  console=True
    ...  AND  Fail  Some cells have wrong states, check logs !


Step 5: Hot insert Data Link
    Log  Step 5: Checking BTS status after insert Data Link  console=True
    Log  --------------------------------------------------${\n}  console=True

    Log  Waiting for restoring RMOD(s)${\n}  console=True

    Log  Checking if cells and RMODs are onAir  console=True
    ${bts_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  6 min  30 s  Check If All Cells And Modules Are OnAir  timeout=60  alias=${node}
    Run Keyword If  '${bts_status}'=='True'
    ...  Log  All cells and modules are onAir !  console=True
    ...  ELSE  Run Keywords
    ...  Log  ALL cells and modules are not onAir !  console=True
    ...  AND  Fail  ALL cells and modules are not onAir !

    Run Keyword If  ${SISO_L3_CALL}  SiSo L3 Call
    ...  ELSE  Log  ${\n}Call skipped  console=True


Step 6: Hot remove Configuration, Data and Synchronization Link
    Log  ${\n}Step 6: Perform hot remove Configuration, Data and Synchronization Link  console=True
    Log  ----------------------------------------------------------------------------${\n}  console=True

    Log  Checking which port will be used for breaking Primary Link  console=True
    ${primary_on_first_port}  Get Links Location By RMOD Distname  ${RMOD_DISTNAME_ID}

    Run Keyword If  '${primary_on_first_port}'=='True'  Run Keywords
    ...  Log  Breaking link will be proceeded from port OPT_IF1${\n}  console=True
    ...  AND  Set Optical Switch And Perform Break Link  ${SWITCH_IP_PORT_A}  ${SWITCH_LINK_BREAK_TIME}
    ...  ELSE  Run Keywords  Log  Breaking link will be proceeded from port OPT_IF2${\n}  console=True
    ...  AND  Set Optical Switch And Perform Break Link  ${SWITCH_IP_PORT_B}  ${SWITCH_LINK_BREAK_TIME}

    Log  Checking RMOD states and alarms  console=True
    ${rmod_availability}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert  RMOD  ${RMOD_DISTNAME_ID}  availabilityStatus=regex"(?i)not installed"  alias=${node}
    ${rmod_operability}  Run Keyword And Return Status
       ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert  RMOD  ${RMOD_DISTNAME_ID}  operationalState=regex"(?i)Disabled"  alias=${node}
    ${rmod_alarm}  Run Keyword And Return Status
       ...  Wait Until Keyword Succeeds  3 min  30 s  admin.Assert Alarm Active  faultId=10, alarmId=7116, severity=Critical  timeout=30

    Run Keyword If  '${rmod_operability}'=='True' and '${rmod_alarm}'=='True' and '${rmod_availability}'=='True'
    ...  Log  RMOD has correct states and FID 10 appeared !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD has wrong states or FID 10 did not appeared, check logs !  console=True
    ...  AND  Fail  RMOD has wrong states or FID 10 did not appeared, check logs !

    Log  Checking if all cells are failed or degraded after breaking link  console=True
    Check If Cells Are Failed Or Degraded


Step 7: Hot insert Configuration, Data and Synchronization Link
    Log  ${\n}Step 7: Checking BTS status after insert Configuration, Data and Synchronization Link  console=True
    Log  -------------------------------------------------------------------------------------${\n}  console=True

    Log  Checking if cells and RMODs are onAir  console=True
    ${bts_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  6 min  30 s  Check If All Cells And Modules Are OnAir  timeout=60  alias=${node}

    Run Keyword If  '${bts_status}'=='True'
    ...  Log  All cells and modules are onAir !  console=True
    ...  ELSE  Run Keywords
    ...  Log  ALL cells and modules are not onAir !  console=True
    ...  AND  Fail  ALL cells and modules are not onAir !

    Log  ${\n}Checking if faultId 10 is cleared  console=True
    ${rmod_alarm}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  30 s  admin.Assert Alarm Inactive  faultId=10,  alarmId=7116, severity=Critical  timeout=300

    Run Keyword If  '${rmod_alarm}'=='True'
    ...  Log  FID 10 is cleared !${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  For FID 10 is still visible, check logs !${\n}  console=True
    ...  AND  Fail  For FID 10 is still visible, check logs !

    Run Keyword If  ${SISO_L3_CALL}  SiSo L3 Call
    ...  ELSE  Log  Call skipped${\n}  console=True


Check If Cells Are Failed Or Degraded
    FOR  ${cell}  IN  @{CELLS}
        ${cell_on_few_rmods}  Check If Cell Is Deployed On More Than One RMOD  ${cell}
        Run Keyword If  ${cell_on_few_rmods}  Cells Deployed On More Than One RMOD  ${cell}
        ...  ELSE  Cells Deployed On One RMOD  ${cell}
    END

Cells Deployed On More Than One RMOD
    [Arguments]    ${cell}
    ${cell_state}  Run Keyword And Return Status  Check If Cell Is Degraded Or Failed  ${cell}  Degraded
    Run Keyword If  '${cell_state}'=='True'
    ...  Log  Cell-${cell} is degraded as expected !  console=True
    ...  ELSE  Run Keywords
    ...  Log  Cell-${cell} is not degraded !  console=True
    ...  AND  Fail  Cell-${cell} is not degraded !

Cells Deployed On One RMOD
    [Arguments]    ${cell}
    @{cell_failed_list}  Create List
    ${cell_state}  Run Keyword And Return Status  Check If Cell Is Degraded Or Failed  ${cell}  Failed
    Run Keyword If  '${cell_state}'=='True'
    ...  Log  Cell-${cell} is failed as expected !  console=True
    ...  ELSE  Run Keywords
    ...  Log  Cell-${cell} is not failed !  console=True
    ...  AND  Fail  Cell-${cell} is not failed !

Get Links Location By RMOD Distname
    [Arguments]  ${rmod_distname_id}
    ${bts}  admin.Get BTS Info
    &{primary_dict}  Create Dictionary
    &{secondary_dict}  Create Dictionary
    FOR  ${cable}  IN  @{bts['cables']}
        Continue For Loop If  '${rmod_distname_id}' not in '${cable['secondEndPointId']['internal']}'
        Run Keyword If
        ...  '${cable['linkMode']['synchronization']}'=='True'
        ...  Set To Dictionary  ${primary_dict}  ${cable['secondEndPointId']['internal']}  primary
        ...  ELSE  Set To Dictionary  ${secondary_dict}  ${cable['secondEndPointId']['internal']}  secondary
    END

    ${primary_cablink_from_dict}  Get Dictionary Keys  ${primary_dict}
    ${primary_cablink}  Get From List  ${primary_cablink_from_dict}  0
    ${primary_on_first_port}  Run Keyword And Return Status  Should Be True  'OPT_IF1' in '${primary_cablink}'
    Run Keyword If  '${primary_on_first_port}'=='True'
    ...  Log  Primary link is set on OPT_IF1  console=True
    ...  ELSE
    ...  Log  Primary link is set on OPT_IF2  console=True

    [Return]  ${primary_on_first_port}

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
