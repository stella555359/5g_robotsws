*** Settings ***
Documentation
    ...  This TC is checking M55331C00001 (NRPAG_PAGING_SUCC_SENT) counter to be generated according to NIDD
    ...  in Performance Management tab.
    ...  First, miNrPaging parameter is set to 5min. Then, TC is waiting for two entire 5 minutes time intervals to
    ...  generate new values for NR Paging counter.
    ...  The last and next to last timestamps are checked to be at 5 minutes time intervals.
    ...  Table headers must contain counter name with "M<x>C<y>" format, where <x> is the measurement ID
    ...  and <y> is the counter ID of the corresponding measurement.
    ...  Next, miNrPaging parameter is disabled and after 5 minutes time interval, last timestamp must be
    ...  the same as in the previous step (there are no new values generated for M55331C00001 counter).
    ...  In the end, miNrPaging parameter is set to its initial value.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../WebEM/resources/vdu_WebEM_general.robot
Resource  ../resources/PM_general.robot


*** Keywords ***
TC__PM__vDU__Check_Performance_Management_Counters_GUI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26698
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26698 - Initial TAT creation
    ...  ******************

    Set Tags  CA-PM  OWNER-adrian.rosa@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  FEATURE-CB009746  PHASE-CRT

    Step0: Set miNrPaging To 5min If Needed
    Step1: Check NR Paging To Be Visible In PM Counters Dialog
    Step2: Check NR Paging Counters Timestamps From PM Table
    Step3: Check Counters Name From PM Table Header
    Step4: Disable miNrPaging Parameter And Check NR Paging Counter To Be Not Generated


Step0: Set miNrPaging To 5min If Needed
    ${nr_paging_value}  VDU Get Parameter Value  miNrPaging  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1
    Set Test Variable  ${NR_PAGING_INITIAL_VALUE}  ${nr_paging_value}
    Run Keyword If  '${nr_paging_value}'!='5min'
    ...  Change Specific Parameter For Vdu  miNrPaging  5min  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1
    ${time_interval}  Set Variable If  '${NR_PAGING_INITIAL_VALUE}'=='disabled'  5min  ${NR_PAGING_INITIAL_VALUE}
    Sleep Until New Cycle  ${time_interval}


Step1: Check NR Paging To Be Visible In PM Counters Dialog
    Log  \nStep1: Check NR Paging To Be Visible In PM Counters Dialog  console=true
    Sleep Until New Cycle  5min
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until new PM counters values are loaded.
    Wait Until Keyword Succeeds  5s  1s  Click Element  //p-button[@title='Expand']
    Click Element  //*[contains(text(),' Performance ')]
    Sleep  2s  TC waits for web elements to be visible.
    ${select_counters_elements}  Get WebElements  //*[contains(text(),'Select Counters')]
    Click Element  ${select_counters_elements}[0]
    Wait Until Keyword Succeeds  5s  1s  Click Element  //oam-network-profile-column//*[contains(text(), 'Select all')]
    Wait Until Keyword Succeeds  5s  1s  Element Should Be Visible  //*[contains(text(), 'NR Paging (NRPAG)')]
    ...  NR Paging (NRPAG) meas is not visible.
    Click Element  //*[contains(text(), 'NR Paging (NRPAG)')]
    Wait Until Keyword Succeeds  5s  1s  Click Element  //*[contains(text(), 'M55331C00001 (NRPAG_PAGING_SUCC_SENT)')]
    Wait Until Keyword Succeeds  5s  1s  Click Element  //oam-pm-counters-modal-objects-column//*[contains(text(), 'Select all')]
    Wait Until Keyword Succeeds  5s  1s  Click Element  //span[contains(text(), 'OK')]


Step2: Check NR Paging Counters Timestamps From PM Table
    Log  \nStep2: Check NR Paging Counters Timestamps From PM Table  console=true
    ${web_elements}  SeleniumLibrary.Get WebElements  //td[contains(@class, 'p-element pm-frozen-tBody-selector frozen-col-cell')]
    ${last_timestamp}  SeleniumLibrary.Get Text  ${web_elements}[0]
    ${last_timestamp}  Split String  ${last_timestamp}  ${SPACE}
    ${next_to_last_timestamp}  SeleniumLibrary.Get Text  ${web_elements}[1]
    ${next_to_last_timestamp}  Split String  ${next_to_last_timestamp}  ${SPACE}
    ${last_min_sec_expected}  ${next_to_last_min_sec_expected}  Get last two expected times based on 5min time interval
    Should Contain  ${last_timestamp}[1]  ${last_min_sec_expected}  Last timestamp from PM table is wrong.
    Should Contain  ${next_to_last_timestamp}[1]  ${next_to_last_min_sec_expected}  Next to last timestamp from PM table is wrong.
    Set Test Variable  ${LAST_TIMESTAMP_EXPECTED}  ${last_min_sec_expected}


Step3: Check Counters Name From PM Table Header
    Log  \nStep3: Check Counters Name From PM Table Header  console=true
    ${table_headers}  Get WebElements  //thead[@class='p-datatable-thead']/tr/th
    FOR  ${web_element}  IN  @{table_headers}
        ${title}  Get Element Attribute  ${web_element}  title
        Continue For Loop If  '${title}'=='Counter'
        ${counter_splitted}  Split String  ${title}  ${SPACE}
        Should Match Regexp  ${counter_splitted}[0]  M[0-9]+C[0-9]+  Counter name is not in accordance with NIDD.
    END

    [Teardown]  Run Keywords  Run Keyword And Ignore Error  vdu.Disconnect  AND  Connect To VDU  host=${VDU_OAM_IP}


Step4: Disable miNrPaging Parameter And Check NR Paging Counter To Be Not Generated
    Log  \nStep4: Disable miNrPaging Parameter And Check NR Paging Counter To Be Not Generated  console=true
    Change Specific Parameter For Vdu  miNrPaging  disabled  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1
    Sleep Until New Cycle  5min
    Sleep  1min  TC will wait until new PM counters values are loaded.
    ${web_elements}  SeleniumLibrary.Get WebElements  //td[contains(@class, 'p-element pm-frozen-tBody-selector frozen-col-cell')]
    ${last_timestamp}  SeleniumLibrary.Get Text  ${web_elements}[0]
    ${last_timestamp}  Split String  ${last_timestamp}  ${SPACE}
    Should Contain  ${last_timestamp}[1]  ${LAST_TIMESTAMP_EXPECTED}  New value for PM counter is generated.


Get last two expected times based on 5min time interval
    @{time}  Get Time  hour min sec
    ${minutes}  Set Variable  ${time}[0]:05:00
    FOR  ${index}  IN RANGE  0  12
        Exit for loop if  '${minutes}'>'${time}[0]:${time}[1]:${time}[2]'
        ${minutes}  Add Time To Time  ${minutes}  00:05:00  timer  exclude_millis=yes
    END
    ${hour_min_sec}  Subtract Time From Time  ${minutes}  00:10:00  timer  exclude_millis=yes
    ${time_splitted}  Split string  ${hour_min_sec}  :
    ${last_min_sec_expected}  Catenate  ${time_splitted}[1]:${time_splitted}[2]

    ${hour_min_sec}  Subtract Time From Time  ${minutes}  00:15:00  timer  exclude_millis=yes
    ${time_splitted}  Split String  ${hour_min_sec}  :
    ${next_to_last_min_sec_expected}  Catenate  ${time_splitted}[1]:${time_splitted}[2]

    [Return]  ${last_min_sec_expected}  ${next_to_last_min_sec_expected}


Restore Parameter To Its Initial Value
    [Arguments]  ${parameter}  ${dist_name}  ${initial_value}

    ${nr_paging_value}  VDU Get Parameter Value  ${parameter}  ${dist_name}
    Run Keyword If  '${nr_paging_value}'!='${initial_value}'
    ...  Change Specific Parameter For Vdu  ${parameter}  ${NR_PAGING_INITIAL_VALUE}  ${dist_name}


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  PM__vDU__Check_Performance_Management_Counters_GUI


TC Teardown
    Restore Parameter To Its Initial Value  miNrPaging  MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRPMRNL-1  ${NR_PAGING_INITIAL_VALUE}
    VDU WebEM Teardown
    Set Test Variable  ${COLLECT_SNAPSHOT}  always
    Common VDU Teardown
