*** Settings ***
Documentation
...  Test case should make GSM voice call via every TRX in GSM cell.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_GSM_voice_call_L3.robot


*** Variables ***

@{SELECTED_CELLS}             # define list of gsmSectorId ex. <gsmSectorID_1>  <gsmSectorID_2>
${CELLS_YAML_PATH}            # define cells yaml file path


*** Keywords ***
TC__Automated_SiSo_CALL_GSM_Voice_Call
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35835
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case should make GSM voice call via every TRX in GSM cell. Only Voice call is allowed.
    ...  User needs to prepare cells yaml file and set path to it as test variable. Template:
    ...  https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob/master/testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/cells_template.yaml
    ...  User needs to make changes in __init__.py and prepare UEPC according to:
    ...  https://confluence.ext.net.nokia.com/display/mnsranprodsisopz/L3+Call+for+testauto+-+PROXY+solution
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.08.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-35835 - Initial creation


    Set Tags    CA-2G_RRM    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    GROUP_IN_CHARGE-WRO_8_Vrf    PHASE-CRT

    ca_GSM_voice_call_L3.step1: Open BSC session
    ca_GSM_voice_call_L3.step2: TC precondition
    ca_GSM_voice_call_L3.step3: Voice call via every TRX

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
