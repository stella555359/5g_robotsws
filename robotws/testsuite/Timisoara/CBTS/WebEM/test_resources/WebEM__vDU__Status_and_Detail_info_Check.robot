*** Settings ***
Documentation
    ...  This TC checks VDU information on several WebEM pages.
    ...  First, M2M command for getting nms state is sent. downlinkFromNMS and uplinkFromNMS should be as expected.
    ...  Number of rmods, cells, pods, rets, raes, mhas and snssais from gui should be equal with the corresponding numbers
    ...  returned by taf vdu library.
    ...  NRBTS ID and NRDU ID should be visible in Site properties.
    ...  Ip addresses available for pods should have the expected format: <interface_name>:<ip_address>.
    ...  Layout Settings should be changed to Settings. Keyboard shortcuts must work when WebEM shortcuts are turned on. After turning
    ...  off WebEM shortcuts, they should not work.
    ...  NMS state from Site view page should be as expected.
    ...  caBlockingLoadLevel and localIpAddrAllocated parameters details should be visible:
    ...    * for caBlockingLoadLevel: The first one should contain: range, description, special value and description of relationship,
    ...    * for localIpAddrAllocated: The first one should contain: lenght range and description.
    ...  VDU cell is blocked for having at least one active alarm. Alarm filters from Active Alarms page are checked. Then Meaning and Instruction
    ...  sections are checked to be visible for the first alarm from all active alarms and historical alarms tables. In the end of this step,
    ...  VDU cell is unblocked.
    ...  One PM counter is chosen. Description and Updated sections must be visible for it.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/M2M_Interface.robot
Resource  ../resources/vdu_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__Status_and_Detail_info_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25074
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  28.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25074 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  FEATURE-CB009444  FEATURE-CB006420  PHASE-CRT

    Step1: Check NMS Through M2M Command
    Step2: Check The Number Of Units And Cells
    Step3: Check Site Properties View
    Step4: Check VNFC Status
    Step5: Check WebEM Navigation Panel And Keyboard Shortcuts
    Step6: Check NMS From Site View
    Step7: Check One Random Parameter Details
    Step8: Trigger Fault And Check Alarm Filters
    Step9: Check PM Counter Details


Step1: Check NMS Through M2M Command
    Log  \nStep1: Check NMS through M2M command  console=true
    Login Using M2M Interface  ${VDU_OAM_IP}
    ${nms_status}  Run M2M Command  GET  https://${VDU_OAM_IP}/api/licensed/v1/nms  Bearer  ${TOKEN}
    ${nms_downlink}  Get Regexp Matches  ${nms_status}  "downlinkFromNMS":"[A-Za-z]*"
    ${nms_uplink}  Get Regexp Matches  ${nms_status}  "uplinkToNMS":"[A-Za-z]*"
    Should Match Regexp  ${nms_downlink}[0]  "downlinkFromNMS":"(Ongoing|Succeeded|NA)"  NMS downlink status is not as expected.
    Should Match Regexp  ${nms_uplink}[0]  "uplinkToNMS":"(Ongoing|Succeeded|NA)"  NMS uplink status is not as expected.

    [Teardown]  Logout Using M2M Interface  ${VDU_OAM_IP}


Step2: Check The Number Of Units And Cells
    Log  \nStep2: Check the number of units and cells  console=true
    ${rmods}  Get Rmods Status
    ${total_rmods_taf}  Get Length  ${rmods}
    ${total_rmods_interface}  Get Text  //*[@title="Total Radios"]/div[1]
    Should Be Equal As Strings  ${total_rmods_interface}  ${total_rmods_taf}  RMODs number is incorrect.

    ${cells}  Get Vdu Cells Status
    ${total_cells_taf}  Get Length  ${cells}
    ${total_cells_interface}  Get Text  //*[@title="Total Cells"]/div[1]
    Should Be Equal As Strings  ${total_cells_interface}  ${total_cells_taf}  Cells number is incorrect.

    Click Element  ${VDU_SITE_VIEW}
    Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'VNFC Status')]
    ${pods}  Get Pods Info
    ${total_pods_taf}  Get Length  ${pods}
    ${total_pods_interface}  Get Text  //span[contains(text(), 'VNFC Total:')]
    ${total_pods_interface}  Fetch From Right  ${total_pods_interface}  ${SPACE}
    Should Be Equal As Strings  ${total_pods_interface}  ${total_pods_taf}  Pods number is incorrect.

    ${rets}  Get Rets Information
    ${total_ret_taf}  Get Length  ${rets}
    Click Element  //span[contains(text(), 'ALD Status')]
    Sleep  2s  TC will wait for correct number of RETs to be loaded.
    ${total_ret_interface}  Get Text  //span[contains(text(), 'RET Total:')]
    ${total_ret_interface}  Fetch From Right  ${total_ret_interface}  ${SPACE}
    Should Be Equal As Strings  ${total_ret_interface}  ${total_ret_taf}  RETs number is incorrect.

    ${raes}  Get Raes Information
    ${total_rae_taf}  Get Length  ${raes}
    Click Element  //span[contains(text(), 'RAE Status View')]
    Sleep  2s  TC will wait for correct number of RAEs to be loaded.
    ${total_rae_interface}  Get Text  //span[contains(text(), 'RAE Total:')]
    ${total_rae_interface}  Fetch From Right  ${total_rae_interface}  ${SPACE}
    Should Be Equal As Strings  ${total_rae_interface}  ${total_rae_taf}  RAEs number is incorrect.

    Click Element  //span[contains(text(), 'MHA Status View')]
    ${mhas}  Get Mhas Information
    ${total_mha_taf}  Get Length  ${mhas}
    Sleep  2s  TC will wait for correct number of MHAs to be loaded.
    ${total_mha_interface}  Get Text  //span[contains(text(), 'MHA Total:')]
    ${total_mha_interface}  Fetch From Right  ${total_mha_interface}  ${SPACE}
    Should Be Equal As Strings  ${total_mha_interface}  ${total_mha_taf}  MHAs number is incorrect.

    ${snssais}  Get Network Slicing
    ${total_snssai_taf}  Get Length  ${snssais}
    Click Element  //span[contains(text(), 'Network Slicing Status')]
    Sleep  2s  TC will wait for correct number of SNSSAISs to be loaded.
    ${total_snssai_interface}  Get Text  //span[contains(text(), 'Network Slicing Total:')]
    ${total_snssai_interface}  Fetch From Right  ${total_snssai_interface}  ${SPACE}
    Should Be Equal As Strings  ${total_snssai_interface}  ${total_snssai_taf}  SNSSAIs number is incorrect.


Step3: Check Site Properties View
    Log  \nStep3: Check Site properties view  console=true
    Click Element  //span[contains(text(), 'Site Properties')]
    Wait Until Element Is Visible  //*[contains(text(), 'NRBTS ID')]  3s  NRBTS ID is not visible.
    Element Should Be Visible  //*[contains(text(), 'NRDU ID')]  NRDU ID is not visible.


Step4: Check VNFC Status
    Log  \nStep4: Check VNFC status  console=true
    Click Element  //span[contains(text(), 'Infrastructure Status')]
    ${pods}  Get Pods Info
    Click Element  //button[@title="Open details panel"]
    FOR  ${pod}  IN  @{pods}
        ${ip_interfaces_is_empty}  Run Keyword And Return Status
        ...  Should Be Empty  ${pod}[ip_interfaces]
        Continue For Loop If  ${ip_interfaces_is_empty}
        Click Element  //div[contains(text(), '${pod}[name]')]
        ${ip_adresses_count}  Get Element Count  //*[@id="pod-ip-addresses-table"]/ui-webem-detail-data-row
        Check Ip Addresses Format  ${ip_adresses_count}
    END


Step5: Check WebEM Navigation Panel And Keyboard Shortcuts
    Log  \nStep5: Check WebEM Navigation panel and keyboard shortcuts  console=true
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}
    Element Should Not Be Visible  //span[text()="Layout Settings"]
    Element Should Be Visible  //span[text()="Settings"]
    Click Element  //div[contains(@class, 'side-bar-expanded')]//p-button[@title="Collapse"]
    Turn On Keyboard Shortcuts
    ${keybord_shortcuts}  Create Dictionary  db=vdu-dashboard  sv=vdu-site-view  aa=alarm-active-home  pf=pm-v2-main-view  pe=parameter-editor
    ...  sn=diagnostic-snapshot-home
    FOR  ${shortcut}  IN  @{keybord_shortcuts}
        Press Keys  None  ${shortcut}
        Wait Until Element Is Visible  //${keybord_shortcuts}[${shortcut}]  5s
    END

    Turn Off Keyboard Shortcuts
    FOR  ${shortcut}  IN  @{keybord_shortcuts}
        Press Keys  None  ${shortcut}
        Sleep  2s  TC will wait for 2 second for page to be loaded.
        Element Should Not Be Visible  //${keybord_shortcuts}[${shortcut}]  ${shortcut} shortcut is still working after turning off WebEM shortcuts.
    END
    Turn On Keyboard Shortcuts


Step6: Check NMS From Site View
    Log  \nStep6: Check NMS from Site view  console=true
    Click Element  ${VDU_SITE_VIEW}
    Sleep  2s  TC will wait for NMS div to be loaded.

    ${nms_downlink}  Get Text  //div[@id="NMS_CONNECTOR"]/div/div[2]/span
    ${nms_uplink}  Get Text  //div[@id="NMS_CONNECTOR"]/div/div[4]/span
    Run Keyword If  '${nms_downlink}' not in ['Ongoing', 'Succeeded', 'NA']
    ...  Fail  NMS downlink status is not as expected.
    Run Keyword If  '${nms_uplink}' not in ['Ongoing', 'Succeeded', 'NA']
    ...  Fail  NMS uplink status is not as expected.
    ${color}  Set Variable If  '${nms_downlink}'=='Succeeded' and '${nms_uplink}'=='Succeeded'  green
    ...  '${nms_downlink}'=='Ongoing' or '${nms_uplink}'=='Ongoing'  white  '${nms_downlink}'=='NA' and '${nms_uplink}'=='NA'  grey  red

    Element Should Be Visible  //div[@id="NMS_CONNECTOR" and @class="tile-frame status-${color}"]


Step7: Check One Random Parameter Details
    Log  \nStep7: Check one random parameter details  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}
    Sleep  10s  TC will wait for PE page to be loaded.
    Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  caBlockingLoadLevel
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td[1]  5  1
    Click Element  //button[@title="Open details panel"]
    Wait Until Keyword Succeeds  5s  1s
    ...  Page Should Contain  Range
    Wait Until Keyword Succeeds  5s  1s  Element Should Be Visible
    ...  //div[contains(@class, 'p-element p-accordion-title ng-star-inserted') and contains(text(), ' Description ')]
    Wait Until Keyword Succeeds  5s  1s  Element Should Be Visible
    ...  //div[contains(@class, 'p-element p-accordion-title ng-star-inserted') and contains(text(), ' Description of special value ')]
    Wait Until Keyword Succeeds  5s  1s  Element Should Be Visible
    ...  //div[contains(@class, 'p-element p-accordion-title ng-star-inserted') and contains(text(), ' Description of relationship ')]
    Click Element  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/div[2]/button/i

    Input Text  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  localIpAddrAllocated
    Press Keys  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[2]/div/ot-search/div/div/input  ENTER
    Sleep  5s  Time for page to be loaded.
    Wait Until Element Is Clicked  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]  5  1
    Wait Until Keyword Succeeds  5s  1s
    ...  Page Should Contain  Length range
    Wait Until Keyword Succeeds  5s  1s
    ...  Element Should Be Visible  //div[contains(@class, 'p-element p-accordion-title ng-star-inserted') and contains(text(), ' Description ')]


Step8: Trigger Fault And Check Alarm Filters
    Log  \nStep8: Trigger fault and check alarm filters  console=true
    ${vdu_cell}  vdu.Get Vdu Cell Id
    ${cell_id}  Get Dictionary Keys  ${vdu_cell}[0]
    ${cell_id}  Fetch From Right  ${cell_id}[0]  -
    Set Test Variable  ${CELL_ID}
    vdu.Block Cell  ${CELL_ID}
    Wait Until Keyword Succeeds  300s  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${DISABLED}  blocking_state=${BLOCKED}

    Click Element  ${VDU_ALARMS_FROM_SITE_VIEW}
    Click Element  //*[contains(text(), 'Show All Active Alarms')]
    Check Severity Filters Are Disabled
    ${severity_filters}  Get WebElements  //ui-webem-toggle-button//button/ui-webem-alarm-severity-icon/i
    FOR  ${severity_web_element}  IN  @{severity_filters}
        Click Element  ${severity_web_element}
        ${severity}  Get Element Attribute  ${severity_web_element}  title
        Check Alarms Table  severity=${severity}
        Click Element  ${severity_web_element}
    END

    ${severity_list}  Create List  Critical  Major
    FOR  ${severity}  IN  @{severity_list}
        Click Element  //ui-webem-toggle-button//button/ui-webem-alarm-severity-icon/i[@title="${severity}"]
        Check Alarms Table  ${severity}
    END
    Click Element  //*[contains(text(), 'Show All Active Alarms')]
    Check Severity Filters Are Disabled

    ${severity_list}  Create List  Minor  Warning
    FOR  ${severity}  IN  @{severity_list}
        Click Element  //ui-webem-toggle-button//button/ui-webem-alarm-severity-icon/i[@title="${severity}"]
        Check Alarms Table  ${severity}
    END
    Click Element  //*[contains(text(), 'Show All Active Alarms')]
    Check Severity Filters Are Disabled

    Check First Alarm Details
    Click Element  //span[contains(text(), 'Historical Alarms')]
    Check First Alarm Details

    vdu.Unblock Cell  ${CELL_ID}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}


Step9: Check PM Counter Details
    Log  \nStep9: Check PM counter details  console=true
    Click Element  ${VDU_DASHBOARD}
    Wait Until Element Is Visible  //dashboard-counters  5s

    ${pm_counters_options_first_element}  Get WebElement  //p-button[@title="Select counters"]
    Click Element  ${pm_counters_options_first_element}
    Wait Until Element Is Visible  //*[contains(text(), 'VLANIF')]  5s
    Click Element  //*[contains(text(), 'VLANIF')]
    Click Element  //*[contains(text(), 'VLAN statistics (VLAN_stats)')]
    Click Element  //*[contains(text(), 'M51302C1 (VlanEthIfInFrames)')]
    ${first_vlanif_element}  Get WebElement  //*[contains(@title, 'VLANIF-1')]
    Click Element  ${first_vlanif_element}
    Click Element  //span[contains(text(), 'OK')]
    ${pm_counters_redirect_first_element}  Get WebElement  //dashboard-counters//p-button[@title="Redirect to view"]
    Click Element  ${pm_counters_redirect_first_element}

    Click Element  //button[@title="Open details panel"]
    Click Element  //div[@class="details-panel-body-section"]//*[contains(@id, 'p-accordiontab-')]

    Wait Until Element Is Visible  //div[@role="tablist"]//ui-webem-details-section-text//*[contains(text(), 'Description')]  5s
    ...  PM counter description is not visible.
    Wait Until Element Is Visible  //div[@role="tablist"]//ui-webem-details-section-text//*[contains(text(), 'Updated')]  5s
    ...  Updated detail for PM counter is not visible.


Check Ip Addresses Format
    [Arguments]  ${ip_adresses_count}

    FOR  ${index}  IN RANGE  1  ${ip_adresses_count}+1
        ${pod_name}  Get Text  //*[@id="pod-ip-addresses-table"]/ui-webem-detail-data-row[${index}]/div/div[1]/span
        Should Match Regexp  ${pod_name}  [a-zA-z0-9]*:  Pod name doesn't have the expected format.
        ${ip_address}  Get Text  //*[@id="pod-ip-addresses-table"]/ui-webem-detail-data-row[${index}]/div/div[2]/span
        Should Match Regexp  ${ip_address}  [0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}\.[0-9]{1,4}  Pod ip address doesn't have the expected format.
    END


Turn ${operation} Keyboard Shortcuts
    ${aria-checked_new}  Set Variable If  '${operation}'=='on'  true  false
    Wait Until Element Is Clicked  ${VDU_OPTIONS_MENU}
    Click Element  //span[text()="Settings"]
    Sleep  2s  TC will wait for Settings page to be loaded.
    ${aria-checked}  Get Element Attribute  //ui-webem-panel/div/div[2]/div/div/div[8]/p-inputswitch/div/div/input  aria-checked
    Run Keyword If  '${aria-checked}'!='${aria-checked_new}'
    ...  Click Element  //ui-webem-panel/div/div[2]/div/div/div[8]/p-inputswitch/div/span


Check First Alarm Details
    Wait Until Element Is Clicked  //ui-webem-alarms-table//tbody/tr[1]  5  1
    Click Element  //button[@title="Open details panel"]
    Wait Until Element Is Visible  //div[@title="Meaning"]  5s  Meaning information is not visible.
    Wait Until Element Is Visible  //div[@title="Instruction"]  5s  Meaning information is not visible.


Check Severity Filters Are Disabled
    ${filters}  Get WebElements  //ui-webem-toggle-button//button
    FOR  ${filter_button}  IN  @{filters}
        ${class}  Get Element Attribute  ${filter_button}  class
        Should Not Contain  ${class}  checked  Show All Active Alarms doesn't work.
    END


Check Alarms Table
    [Arguments]  ${severity}

    ${alarms}  Get WebElements  //ui-webem-alarms-table//tbody/tr[contains(text(), 'ALARM_')]//i
    FOR  ${alarm}  IN  @{alarms}
        ${alarm_severity}  Get Element Attribute  ${alarm}  title
        Element Text Should Be  ${alarm_severity}  ${severity}  ${severity} filter doesn't work.
    END


Perform Recovery Action
    vdu.Unblock Cell  ${CELL_ID}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  operational_state=${ENABLED}  blocking_state=${UNBLOCKED}


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Status_and_Detail_info_Check


TC Teardown
    Run Keyword If Test Failed
    ...  Perform Recovery Action
    VDU WebEM Teardown
    Common VDU Teardown
