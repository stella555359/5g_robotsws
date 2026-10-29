*** Settings ***
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../../Resources/SiSo_L3_call.robot


*** Variables ***

@{SELECTED_CELLS}             # define list of wcdma cellId ex. <cellId_1>  <cellId_2>  <cellId_3>
${CELLS_YAML_PATH}            # define cells yaml file path


*** Keywords ***
TC__Automated_SiSo_CALL_WCDMA_Voice_Call
    [Documentation]
    ...  [CASE LINK]:https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35835
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case makes voice call via selected WCDMA cells. Only voice call is allowed.
    ...  User needs to prepare cells yaml file and set path to it as test variable. Template: 
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob/master/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/cells_template.yaml
    ...  User needs to make changes in __init__.py and prepare UEPC according to:
    ...  https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/L3+Call+for+testauto+-+PROXY+solution  
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.08.2023 -  https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35835 - Initial creation


    Set Tags    CA-3G_RRM    OWNER-daniel.bartkowiak@nokia.com    AUTHOR-daniel.bartkowiak@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    GROUP_IN_CHARGE-WRO_8_Vrf    PHASE-CRT

	Automated_SiSo_CALL_WCDMA_Voice_Call.Step1:Make WCDMA Voice Call


Step1:Make WCDMA Voice Call
    Log To Console  ${\n}------------------------------
    Log To Console  Step1.Make WCDMA Voice Call
    Log To Console  ------------------------------
    SiSo Convert Id to Runtime Distname  wcdma
    Set Test Variable  ${DATA}  False
    Set Test Variable  ${LOGS_DIR}  ${BTS Files}
    SiSo L3 Call

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
