*** Settings ***
Documentation
    ...  This TC checks active and historical alarms by applying severity and rat filters after performing
    ...  some operations that generate specific alarms.
    ...
    ...  The following alarms are generated:
    ...  - 3 Critical alarms by performing: GSM cell block, WCDMA rat block and NR cell block,
    ...  - 1 Major alarm by sending fault 6117 on locked LTE cell,
    ...  - 1 Warning and General alarm by sending the kill command for l1_application process on 5G SoC.
    ...  The alarms that were active before the TC started are checked when Minor filter and General filter
    ...  are applied.
    ...
    ...  After applying each filter the alarms table is checked for both active alarms and history alarms.
    ...  If unexpected alarms appear, TC will Fail.
    ...
    ...  In the end, Site reset will be performed to clear all counters.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  600  # Time for SBTS to recover.


*** Keywords ***
TC__WebEM__Filtering_active_historical_BTS_alarm_list
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21615
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  20.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21615 - Initial TAT creation
    ...  25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  11.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27528 - Convert values for alarms generated dictionary
    ...  20.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28620 - Add snapshot collection
    ...  27.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28632 - Delete fault 6450 from active/historical alarms list
    ...  03.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30057 - Add fault generation flag in swconfig file
    ...  15.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30286 - LTE NBIOT cells are excluded and only BBMODs ABIO are selected for SOC reset

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step0: Set Alarms That Need To Be Checked
    Step1: Perform Operations And Generate Alarms
    Step2: Filter Active Alarms
    Step3: Clear All Active Alarms Generated
    Step4: Filter Historical Alarms
    Step5: Perform Site Reset To Clear All Counters


Step0: Set Alarms That Need To Be Checked
    Set Window Size  ${1920}  ${1400}
    ${module_rat_dict}  Create Dictionary  MRBTS=General  SMOD=General  BBMOD=General  SECADM=General  NRCELL=NR  LNCEL=LTE  WBTS=WCDMA  GNCEL=GSM
    Set Test Variable  ${MODULE_RAT_DICT}
    ${active_alarms}  Get All Active Alarms From Taf
    Set Test Variable  ${MINOR_ALARMS}  ${active_alarms}
    ${alarms_generated}  Get All Alarms Generated
    ${alarms_to_be_checked}  Create List
    Set Test Variable  ${ALARMS_TO_BE_CHECKED}
    Append To List  ${ALARMS_TO_BE_CHECKED}  @{alarms_generated}  @{active_alarms}
    Add Fault Generation Flag In Swconfig File And Perform Site Reset If Is Not Set


Step1: Perform Operations And Generate Alarms
    Log  \nStep1: Perform operations and generate alarms  console=true
    Block GSM Cell
    Assert Any  GNCEL  blockingState=${BLOCKED}  timeout=150
    RAT Block  WCDMA
    Assert Every  WNCEL  blockingState=${BLOCKED}  timeout=120
    Lock One LNCEL And Trigger Major Fault
    Assert Any  LNCEL  administrativeState=${LOCKED}  timeout=120
    Block NR Cell
    Assert Any  NRCEL  blockingState=${BLOCKED}  timeout=120
    Generate 5G BBMOD Recovery Reset


Step2: Filter Active Alarms
    Log  \nStep2: Filter active alarms  console=true
    Click Element  ${ALARMS_BUTTON_SITE_VIEW}
    Check active Alarms Table
    Apply All rat Filters
    Save current Alarms File


Step3: Clear All Active Alarms Generated
    Log  \nStep3: Clear all active alarms generated  console=true
    Recovery Actions


Step4: Filter Historical Alarms
    Log  \nStep4: Filter historical alarms  console=true
    Click Element  ${ALARMS_BUTTON_SITE_VIEW}
    Sleep  2s
    Click Element  //a[contains(text(), "Alarm History")]
    Remove Values From List  ${ALARMS_TO_BE_CHECKED}  @{MINOR_ALARMS}
    Check historical Alarms Table
    Apply All rat Filters
    Save historical Alarms File
    Check If Unexpected Alarms Appeared


Step5: Perform Site Reset To Clear All Counters
    Log  \nStep5: Perform site reset to clear all counters  console=true
    Log  Collect snapshot before site unblock.  console=true
    Collect Snapshot And Ensure GUI Does Not Lock  snapshot_before_site_reset.zip
    Go To Site View
    Reset SBTS From Admin
    Close Startup View If Visible
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State
    ${lteenb_elements}  SeleniumLibrary.Get WebElements  //div[contains(@title, 'X2 Link Status:')]
    Wait Until Keyword Succeeds  180  10  Check X2 Links Status  ${lteenb_elements}


Get All Active Alarms From Taf
    ${active_alarms}  Create List
    ${alarms}  coam.Get Alarms
    FOR  ${alarm}  IN  @{alarms}
        ${alarm_id}  Convert To String  ${alarm}[alarmId]
        ${fault_id}  Convert To String  ${alarm}[faultId]
        ${matches}  Get Regexp Matches  ${alarm}[alarmingObjectIds][0][configuration]  [A-Z]{2}CEL(L)?|[A-Z]{1,2}BTS|[A-Z]{1,2}MOD
        ${config_obj}  Set Variable  ${matches}[-1]
        ${rat}  Set Variable
        ${alarm_dict}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${alarm}[alarmInformation][faultDescription]
        ...  config_obj=${config_obj}  severity=${alarm}[severity]  rat=${MODULE_RAT_DICT}[${config_obj}]
        Append To List  ${active_alarms}  ${alarm_dict}
    END

    RETURN  ${active_alarms}


Get All Alarms Generated
    ${alarm_id}  Convert To String  ${FAULT_49}[alarm_id]
    ${fault_id}  Convert To String  ${FAULT_49}[fault_id]
    ${gncel_block}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${FAULT_49}[fault_name]  config_obj=GNCEL
    ...  severity=${FAULT_49}[severity]  rat=GSM
    ${alarm_id}  Convert To String  ${FAULT_4614}[alarm_id]
    ${fault_id}  Convert To String  ${FAULT_4614}[fault_id]
    ${wcdma_rat_blocked}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${FAULT_4614}[fault_name]  config_obj=WBTS
    ...  severity=${FAULT_4614}[severity]  rat=WCDMA
    ${alarm_id}  Convert To String  ${FAULT_6117}[alarm_id]
    ${fault_id}  Convert To String  ${FAULT_6117}[fault_id]
    ${lte_cell_lock}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${FAULT_6117}[fault_name]  config_obj=LNCEL
    ...  severity=${FAULT_6117}[severity]  rat=LTE
    ${alarm_id}  Convert To String  ${FAULT_49}[alarm_id]
    ${fault_id}  Convert To String  ${FAULT_49}[fault_id]
    ${nrcel_block}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${FAULT_49}[fault_name]  config_obj=NRCELL
    ...  severity=${FAULT_49}[severity]  rat=NR
    ${alarm_id}  Convert To String  ${FAULT_2087_SOC_AUTO_RST}[alarm_id]
    ${fault_id}  Convert To String  ${FAULT_2087_SOC_AUTO_RST}[fault_id]
    ${severity}  Catenate  SEPARATOR=  ${FAULT_2087_SOC_AUTO_RST}[severity]  s
    ${soc_reset}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${FAULT_2087_SOC_AUTO_RST}[fault_name]  config_obj=BBMOD
    ...  severity=${severity}  rat=General
    ${alarms_generated}  Create List  ${soc_reset}  ${nrcel_block}  ${lte_cell_lock}  ${wcdma_rat_blocked}  ${gncel_block}

    RETURN  ${alarms_generated}


Add Fault Generation Flag In Swconfig File And Perform Site Reset If Is Not Set
    Add Flag To Swconfig File And Perform Site Reset  0x450027=1
    ${status_reset}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  parameters=faultId=4592, faultName="BTS Reset Cause", alarmId=7115, severity=${severity}  timeout=120
    IF  ${status_reset}
        Close Startup View If Visible  timeout=300 sec
        Logout From SBTS
        Login SBTS
        Legal Notice
        Log  Wait until the page is loaded.  console=true
        Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  60s
        ...  WebElement is not fully loaded in 60 seconds.
        Set Test Variable  ${STATUS_SITE_RESET}  1
    ELSE
        Set Test Variable  ${STATUS_SITE_RESET}  0
    END


Block ${rat} Cell
    ${cell_xpath}  Evaluate  random.choice(${${rat}_CELLS_XPATH})  random
    Set Test Variable  ${${rat}_CELL_XPATH_FOR_BLOCK}  ${cell_xpath}
    Block ${rat} Cell By ${${rat}_CELL_XPATH_FOR_BLOCK}


${block_unblock} ${rat} Cell By ${cell_xpath}
    Log  ${block_unblock} one ${rat} cell.  console=true
    Click Element  ${cell_xpath}
    Wait Until Element Is Clicked  //*[contains(text(), '${block_unblock}')][contains(text(), 'Cell')]  60
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


Lock One LNCEL And Trigger Major Fault
    Log  Lock random LTE cell.  console=true
    ${cells_dn}  Get Parameters For All  LNCEL
    ${lte_cells}  Create List
    FOR  ${cell}  IN  @{cells_dn}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell}[cellTechnology]  IoT
        IF  ${status}
            CONTINUE
        ELSE
            Append To List  ${lte_cells}  ${cell}[id]
        END
    END
    ${random_dn}  Evaluate  random.choice(${lte_cells})  random
    ${short_dn}  Get Short DN From Runtime DN  ${random_dn}
    Perform Parameter Recommissioning  ${short_dn}  administrativeState  update  locked  skip_parameter_relation_errors=${TRUE}
    ${lncel_id}  Fetch From Right  ${short_dn}  -
    Set Test Variable  ${LNCEL_ID}
    Send Fault  ${FAULT_6117}[fault_id]  ${LNCEL_ID}
    Set Test Variable  ${LNCEL_SHORT_DN_FOR_LOCK}  ${short_dn}


Get Short DN From Runtime DN
    [Arguments]  ${runtime_dn}

    ${bts_id}  Admin Get BTS Id
    ${short_dn}  Remove String Using Regexp  ${runtime_dn}  .*VIEW-\\d/
    ${short_dn}  Remove String  ${short_dn}  _R
    ${short_dn}  Replace String Using Regexp  ${short_dn}  MRBTS-\\d  MRBTS-${bts_id}

    RETURN  ${short_dn}


Send Fault
    [Arguments]  ${fault_id}  ${cell_id}

    ${bts_side}  Get BTS Side
    IF  '${bts_side}'=='1'
        Send Lom Fault Ind Msg  ${0x10110240}  ${0x10111202}  ${${fault_id}}  ${1}  ${2}  ${1}  ${${cell_id}}
    ELSE
        Send Lom Fault Ind Msg  ${0x20110240}  ${0x20111202}  ${${fault_id}}  ${1}  ${2}  ${1}  ${${cell_id}}
    END


Cancel Fault
    [Arguments]  ${fault_id}  ${cell_id}

    ${bts_side}  Get BTS Side
    IF  '${bts_side}'=='1'
        Send Lom Fault Ind Msg  ${0x10110240}  ${0x10111202}  ${${fault_id}}  ${0}  ${2}  ${1}  ${${cell_id}}
    ELSE
        Send Lom Fault Ind Msg  ${0x20110240}  ${0x20111202}  ${${fault_id}}  ${0}  ${2}  ${1}  ${${cell_id}}
    END


Get BTS Side
    ${smod_dn_list}  Get Ids For All  SMOD
    FOR  ${smod_dn}  IN  @{smod_dn_list}
        ${smod_object}  coam.Get Parameters  ${smod_dn}
        ${bts_l_dn_matches}  Get Regexp Matches  ${smod_object}[configDN]  .*BTS_L-\\d
        ${bts_l_object}  coam.Get Parameters  ${bts_l_dn_matches}[0]
        IF  '${bts_l_object}[storedRole]'=='Single' or '${bts_l_object}[storedRole]'=='Active'  RETURN  ${bts_l_object}[hwapiDomainId]
    END


Generate 5G BBMOD Recovery Reset
    Log  Generate 5G BBMOD recovery reset.  console=true
    ${random_bbmod_dn}  Get Random 5G ABIO BBMOD
    ${smod_stored_role}  ${bbmod_vertical_position}  Get Bbmod Side And Vertical Position  ${random_bbmod_dn}
    Open Ssh Connection To BBMOD And Kill Process  ${smod_stored_role}  ${bbmod_vertical_position}


Get Random 5G ABIO BBMOD
    ${5_g_bbmod_dn_list}  Create List
    ${bbmod_dns}  Get Ids For All  BBMOD
    FOR  ${bbmod_dn}  IN  @{bbmod_dns}
        ${parameters}  coam.Get Parameters  ${bbmod_dn}
        ${status}  Run Keyword And Return Status  Should Contain  ${parameters}[productName]  ABIO
        IF  not ${status}  CONTINUE
        ${cells_on_module_dns}  coam.Get Cell Mapping By Module Id  ${bbmod_dn}
        ${status}  Check If NR Is Deployed On Module  ${cells_on_module_dns}
        IF  ${status}  Append To List  ${5_g_bbmod_dn_list}  ${bbmod_dn}
    END
    ${random_bbmod_dn}  Evaluate  random.choice(${5_g_bbmod_dn_list})  random

    RETURN  ${random_bbmod_dn}


Check If NR Is Deployed On Module
    [Arguments]  ${cells_on_module_dns}

    FOR  ${cell_dn}  IN  @{cells_on_module_dns}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  NRCEL
        IF  ${status}  RETURN  ${TRUE}
    END

    RETURN  ${FALSE}


Get Bbmod Side And Vertical Position
    [Arguments]  ${bbmod_dn}

    ${bbmod_parameters}  coam.Get Parameters  ${bbmod_dn}
    ${bbmod_vertical_position}  Evaluate  ${bbmod_parameters}[verticalPosition]-1
    ${smod_dn_matches}  Get Regexp Matches  ${bbmod_parameters}[configDN]  .*BTS_L-\\d
    ${smod_object}  coam.Get Parameters  ${smod_dn_matches}[0]

    RETURN  ${smod_object}[storedRole]  ${bbmod_vertical_position}


Open Ssh Connection To BBMOD And Kill Process
    [Arguments]  ${smod_stored_role}  ${bbmod_vertical_position}

    Open Connection To Primary Core
    IF  '${smod_stored_role}'=='Secondary'  Open Connection To Secondary Core
    Open Connection To SOC  ${bbmod_vertical_position}  soc_position=1
    ${lines}  Get Lines Containing Process
    IF  ${lines}
        Log  Process is visible!  console=true
    ELSE
        Open Connection To SOC  ${bbmod_vertical_position}  soc_position=2
    END
    Kill Process  ${lines}
    Sleep  10s  Time for fault to appear


Get Lines Containing Process
    SSHLibrary.Write  ps aux | grep l1
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${lines_concatenated}  Get Lines Containing String  ${output_ps}  /usr/bin/l1_application
    ${lines}  Split To Lines  ${lines_concatenated}

    RETURN  ${lines}


Kill Process
    [Arguments]  ${lines}

    IF  ${lines}
        ${lines}  Set Variable  ${lines}
    ELSE
        ${lines}  Get Lines Containing Process
    END
    IF  ${lines}
        Log  l1_application process exist on FSP!  console=true
    ELSE
        Fail  l1_application process does not exist on FSP!
        RETURN
    END
    FOR  ${line}  IN  @{lines}
        ${split}  Split String  ${line}
        IF  '${split}[2]'!='0.0'  Exit For Loop
    END
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -11 ${pid}


Check ${active_historical} Alarms Table
    Remove All severity Filters
    ${severity_list}  Create List  Warnings  Minor  Major  Critical
    FOR  ${severity}  IN  @{severity_list}
        Check If Alarms Are Found Using ${severity} severity Filter In ${active_historical} Alarms
    END
    Apply All severity Filters
    Remove All RAT Filters
    ${rat_list}  Create List  General  GSM  WCDMA  LTE  NR
    FOR  ${rat}  IN  @{rat_list}
        Check If Alarms Are Found Using ${rat} rat Filter In ${active_historical} Alarms
    END


${apply_remove} All ${filter_type} Filters
    IF  '${apply_remove}'=='Apply'
        ${active_var}  Set Variable  ${EMPTY}
    ELSE
        ${active_var}  Set Variable  ${SPACE}active
    END
    IF  '${filter_type}'=='severity'
        ${locator}  Set Variable  //button[@class='btn btn-icon-button alarm-faults ng-scope${active_var}']
    ELSE
        ${locator}  Set Variable
        ...  //button[@class='btn btn-small${active_var}' and (contains(@ui-tooltip, 'technology') or starts-with(@ui-tooltip, 'General'))]
    END
    ${severity_filters}  Get WebElements  ${locator}
    FOR  ${filter_button}  IN  @{severity_filters}
        Click Element  ${filter_button}
    END


Check If Alarms Are Found Using ${filter} ${filter_type} Filter In ${active_historical} Alarms
    IF  '${filter_type}'=='rat'
        ${part_of_locator}  Set Variable  //button
    ELSE
        ${part_of_locator}  Set Variable  //button/alarm-bell-icon/div
    END
    IF  '${active_historical}'=='active'
        ${td_indexes}  Create List  3  5  6  8
    ELSE
        ${td_indexes}  Create List  4  6  7  9
    END
    ${locator}  Catenate  SEPARATOR=  ${part_of_locator}  [starts-with(@ui-tooltip, '${filter}')]
    Click Element  ${locator}
    Log  '${filter}' filter is set:  console=true

    ${alarms_filtered_list}  Get Filtered Alarms By ${filter} ${filter_type}

    FOR  ${alarm_parameters}  IN  @{alarms_filtered_list}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  120  10
        ...  Check If Current Alarm Is Found In Alarms Table  ${alarm_parameters}  ${td_indexes}
        IF  ${status}==${FALSE}
            Set Test Failed
            ...  ${alarm_parameters}[faultId] ${alarm_parameters}[faultName] fault is not visible on ${alarm_parameters}[config_obj]. [NOK]
        END
    END
    Click Element  ${locator}


Get Filtered Alarms By ${filter} ${filter_type}
    ${alarms_filtered_list}  Create List
    FOR  ${alarm_parameters}  IN  @{ALARMS_TO_BE_CHECKED}
        IF  '${alarm_parameters}[${filter_type}]'!='${filter}'  CONTINUE
        Append To List  ${alarms_filtered_list}  ${alarm_parameters}
    END

    RETURN  ${alarms_filtered_list}


Check If Current Alarm Is Found In Alarms Table
    [Arguments]  ${alarm_parameters}  ${td_indexes}

    ${alarms_from_table}  Create List
    ${alarm_count}  SeleniumLibrary.Get Element Count  //table[@class='alarm-faults ng-scope']/tbody/tr
    FOR  ${index}  IN RANGE  1  ${alarm_count}+1
        ${severity}  SeleniumLibrary.Get Element Attribute  //table[@class='alarm-faults ng-scope']/tbody/tr[${index}]/td[1]/alarm-bell-icon/div
        ...  ui-tooltip
        ${severity}  Fetch From Left  ${severity}  ${SPACE}
        ${alarm_id}  Get Text  //table[@class='alarm-faults ng-scope']/tbody/tr[${index}]/td[${td_indexes}[0]]
        ${fault_id}  Get Text  //table[@class='alarm-faults ng-scope']/tbody/tr[${index}]/td[${td_indexes}[1]]
        ${fault_name}  Get Text  //table[@class='alarm-faults ng-scope']/tbody/tr[${index}]/td[${td_indexes}[2]]
        ${config_alarming_obj}  Get Text  //table[@class='alarm-faults ng-scope']/tbody/tr[${index}]/td[${td_indexes}[3]]
        ${matches}  Get Regexp Matches  ${config_alarming_obj}  [A-Z]{2}CEL(L)?|[A-Z]{1,2}BTS|[A-Z]{1,2}MOD
        ${config_obj}  Set Variable  ${matches}[-1]
        ${alarm_dict}  Create Dictionary  alarmId=${alarm_id}  faultId=${fault_id}  faultName=${fault_name}  config_obj=${config_obj}
        ...  severity=${severity}  rat=${MODULE_RAT_DICT}[${config_obj}]
        Append To List  ${alarms_from_table}  ${alarm_dict}
    END
    List Should Contain Value  ${alarms_from_table}  ${alarm_parameters}
    Log  ${alarm_parameters}[faultId] ${alarm_parameters}[faultName] fault is visible on ${alarm_parameters}[config_obj]. [OK]  console=true


Check If Unexpected Alarms Appeared
    ${MINOR_ALARMS}  Check If 6450 Fault Appeared In List And Delete It  ${MINOR_ALARMS}  historical
    ${active_alarms_checked_counter}  Get Length  ${MINOR_ALARMS}
    ${active_alarms}  coam.Get Alarms
    ${active_alarms}  Check If 6450 Fault Appeared In List And Delete It  ${active_alarms}  active
    ${active_alarms_counter}  Get Length  ${active_alarms}
    ${status_active}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${active_alarms_checked_counter}  ${active_alarms_counter}
    ${ALARMS_TO_BE_CHECKED}  Check If 6450 Fault Appeared In List And Delete It  ${ALARMS_TO_BE_CHECKED}  historical
    ${historical_alarms_checked_counter}  Get Length  ${ALARMS_TO_BE_CHECKED}
    ${historical_alarms}  coam.Get Alarm History
    ${historical_alarms}  Set Variable  ${historical_alarms}[requestMessage]
    ${historical_alarms}  Check If 6450 Fault Appeared In List And Delete It  ${historical_alarms}  historical
    IF  ${STATUS_SITE_RESET} == 1
        ${historical_alarms}  Check If Default Faults Appeared In List And Delete Them  ${historical_alarms}
    END
    ${historical_alarms_counter}  Get Length  ${historical_alarms}
    ${status_history}  Run Keyword And Return Status
    ...  Should Be Equal As Integers  ${historical_alarms_checked_counter}  ${historical_alarms_counter}
    IF  ${status_active}==${FALSE} or ${status_history}==${FALSE}  Fail  Unexpected alarms appeared.


Check If 6450 Fault Appeared In List And Delete It
    [Arguments]  ${alarms_list}  ${alarm_type}

    FOR  ${alarm}  IN  @{alarms_list}
        ${faultId_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  6450
        IF  '${alarm_type}'=='active'
            ${faultName_status}  Run Keyword And Return Status
            ...  Should Match Regexp  ${alarm}[alarmInformation][faultDescription]  Diagnostic (F|f)iles collected
        ELSE IF  '${alarm_type}'=='historical'
            ${faultName_status}  Run Keyword And Return Status  Should Match Regexp  ${alarm}[faultName]  Diagnostic (F|f)iles collected
        END
        IF  not(${faultId_status} and ${faultName_status})  CONTINUE
        Remove Values From List  ${alarms_list}  ${alarm}
    END

    RETURN  ${alarms_list}


Check If Default Faults Appeared In List And Delete Them
    [Arguments]  ${alarms_list}

    FOR  ${alarm}  IN  @{alarms_list}
        ${status_61649}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  LMP access via port 443
        ${status_61652}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  R&D Service Port enabled
        ${status_61524}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  SSH enabled
        ${status_4654}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  Ethernet port security is disabled
        ${status_4655}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  Service account root access is enabled
        ${status_4592}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  BTS Reset Cause
        IF  ${status_61649} or ${status_61652} or ${status_61524} or ${status_4654} or ${status_4655} or ${status_4592}
            Remove Values From List  ${alarms_list}  ${alarm}
        END
    END

    RETURN  ${alarms_list}


Check X2 Links Status
    [Arguments]  ${lteenb_elements}

    FOR  ${lteenb_elem}  IN  @{lteenb_elements}
        ${title}  SeleniumLibrary.Get Element Attribute  ${lteenb_elem}  title
        Should Be Equal As Strings  ${title}  X2 Link Status: available
    END


Save ${alarm_type} Alarms File
    Log  Save ${alarm_type} alarms file in BTSFiles/alarms.  console=true
    Click Element  //button[@ui-tooltip='Save ${alarm_type} alarms']
    ${current_time}  DateTime.Get Current Date  result_format=%Y.%m.%d-%H:%M  exclude_millis=true
    Wait Until Created  /home/ute/Downloads/*${alarm_type}Alarms*.csv
    Move File  /home/ute/Downloads/*${alarm_type}*.csv  ${BTS_FILES}/alarms/${alarm_type}Alarms_${current_time}.csv


Recovery Actions
    Go To Site View
    ${status}  Run Keyword And Return Status
    ...  Assert Any  GNCEL  blockingState=${BLOCKED}  timeout=120
    IF  ${status}  Wait Until Keyword Succeeds  60  10  Unblock GSM Cell By ${GSM_CELL_XPATH_FOR_BLOCK}
    ${status}  Run Keyword And Return Status
    ...  Assert Every  WNCEL  blockingState=${BLOCKED}
    IF  ${status}  Wait Until Keyword Succeeds  60  10  RAT Unblock  WCDMA
    ${status}  Run Keyword And Return Status
    ...  Assert Any  LNCEL  administrativeState=${LOCKED}
    IF  ${status}
        Log  Unlock one LTE cell.  console=true
        Perform Parameter Recommissioning  ${LNCEL_SHORT_DN_FOR_LOCK}  administrativeState  update  unlocked  skip_parameter_relation_errors=${TRUE}
        Cancel Fault  ${FAULT_6117}[fault_id]  ${LNCEL_ID}
    END
    ${status}  Run Keyword And Return Status
    ...  Assert Any  NRCEL  blockingState=${BLOCKED}
    IF  ${status}  Wait Until Keyword Succeeds  60  10  Unblock NR Cell By ${NR_CELL_XPATH_FOR_BLOCK}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State


TC Setup
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=WebEM__Filtering_active_historical_BTS_alarm_list
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Recovery Actions
    WebEM Teardown
    Common Test Teardown
