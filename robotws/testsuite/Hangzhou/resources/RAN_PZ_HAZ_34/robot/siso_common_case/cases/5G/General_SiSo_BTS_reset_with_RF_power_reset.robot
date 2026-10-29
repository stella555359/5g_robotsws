*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
*** Variables ***

*** Keywords ***
General_SiSo_BTS_reset_with_RF_power_reset
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify Reset site shouldn't be performed after RU power reset
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.25.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1
    Perform BTS Site Reset    download_dir=${SAVE LOG DIRECTORY}
    Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    10 min    20 sec    RU Should Be Power Off    ru_index=${ru_index}
    sleep    2 sec
    Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
    Wait until keyword succeeds    15 min    20 sec    RU Should Be Online    ru_index=${ru_index}
    Wait Until Keyword Succeeds    10 min    20 sec    Verify all cells should be onair
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ${filter_param}    set variable
    ...  Activate addition of fault signature fields to alarms indicating autonomous reset of a unit/BTS for fault recovery and crashes/failures
	Selenium Login And Disable Screen Lock
	${actFaultSignature}    Get Parameter Via Webem    dist_name=${dist_name}    filter_param=${filter_param}
    Run Keyword If  '${actFaultSignature}'=='true' or '${actFaultSignature}'=='True'    Wait For Expect Fault To Disappear
    ...   faultId=4589   timeout=1200
    [Teardown]    selenium logout and close browser