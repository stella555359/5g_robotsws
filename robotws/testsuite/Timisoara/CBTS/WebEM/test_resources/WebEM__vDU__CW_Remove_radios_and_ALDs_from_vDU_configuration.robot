*** Settings ***
Documentation
    ...  This TC is created to remove radios from DU configuration.
    ...  Commissioning wizard is opened and new delta plan is created.
    ...  One RMOD is chosen and deleted in two ways.
    ...  First, RMOD is deleted without selecting any checkbox. In this case, cells and ALDs
    ...  mapped on this RMOD should disappear from WebEM.
    ...  RMOD is deleted with all the checkbox selected. In this case, NRCELL-GROUP should also disappear from WebEM.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Remove_radios_and_ALDs_from_vDU_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26635
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  21.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26635 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-C

    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Delete RMOD Without Checkbox Selected And Verify Nrcells, Alds And Nrcell-group
    Step4: Delete RMOD With Checkbox Selected And Verify Nrcells, Alds And Nrcell-group


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Set Nr Cell Id And Nrcell Group Id Depends On First RMOD
    ${alds_dns}  ${subunits_dns}  Find ALDs And Subunits Mapped On Given RMOD  ${RMOD_ID}
    Set Test Variable  ${ALDS_DNS}
    Open Commissioning Wizard


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Delete RMOD Without Checkbox Selected And Verify Nrcells, Alds And Nrcell-group
    Log  \nStep3: Delete RMOD without checkbox selected and verify nrcells, alds and nrcell-group.  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]
    Log  Radio Module was deleted!  console=true
    Log  Verify if cell is not still visible!  console=true
    ${cell_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELL-${CELL_ID}
    Run Keyword If  ${cell_status}
    ...  Log  NRCELL-${CELL_ID} on RMOD-1 is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELL-${CELL_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if nr group cell is still visible!  console=true
    ${group_status}  Run Keyword And Return Status
    ...  Page Should Contain  NRCELLGRP-${CELL_GROUP_ID}
    Run Keyword If  ${group_status}
    ...  Log  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is still visible![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is not visible anymore![NOK]
    Log  Verify if ALDs are not still visible!  console=true
    ${alds_status}  Run Keyword And Return Status
    ...  Verify If Every ALD From List Is Visible In WebEM
    Run Keyword If  ${alds_status}
    ...  Fail  ALDs on RMOD-1 are still visible in WebEM. [NOK]
    ...  ELSE
    ...  Log  All ALDs on RMOD-1 are not visible anymore! [OK]  console=true
    Log  Verify Radio module!  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button/button/span[1]
    ...  120
    Log  Key button is visible and pushed!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Log  Delete buton is visible again!  console=true

    Delete Actual Plan Via WebEM
    Create Duplicate Plan For CBTS


Step4: Delete RMOD With Checkbox Selected And Verify Nrcells, Alds And Nrcell-group
    Log  \nStep4: Delete RMOD with checkbox selected and verify nrcells, alds and nrcell-group.  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Click Element  //*[@id="laf-component"]/div/div/div[2]/blocks-delete-check-dialog/div[2]/div/p-checkbox/div/div[2]
    Log  Checkbox was selected!  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]
    Log  Radio Module was deleted!  console=true
    Log  Verify if cell is not still visible!  console=true
    ${cell_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELL-${CELL_ID}
    Run Keyword If  ${cell_status}
    ...  Log  NRCELL-${CELL_ID} on RMOD-1 is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELL-${CELL_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if nr group cell is not still visible!  console=true
    ${group_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELLGRP-${CELL_GROUP_ID}
    Run Keyword If  ${group_status}
    ...  Log  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is not visible anymore[OK]  console=true
    ...  ELSE
    ...  Fail  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if ALDs are not still visible!  console=true
    ${alds_status}  Run Keyword And Return Status
    ...  Verify If Every ALD From List Is Visible In WebEM
    Run Keyword If  ${alds_status}
    ...  Fail  ALDs on RMOD-1 are still visible in WebEM. [NOK]
    ...  ELSE
    ...  Log  All ALDs on RMOD-1 are not visible anymore! [OK]  console=true
    Log  Verify Radio module!  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM_R-1/APEQM_R-1/RMOD_R-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button/button/span[1]
    Log  Key button is visible and pushed!  console=true
    Wait Until Keyword Succeeds  30  5
    ...  Element Should Be Visible
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Log  Delete buton is visible again!  console=true


Verify If Every ALD From List Is Visible In WebEM
    FOR  ${ald_dn}  IN  @{ALDS_DNS}
        Element Should Not Be Visible  //*[@id="${ald_dn}"]  ALD with dist name: ${ald_dn} is still visibile in WebEM after RMOD deletion. [NOK]
    END


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Remove_radios_and_ALDs_from_vDU_configuration


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
