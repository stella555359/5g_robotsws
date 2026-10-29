*** Settings ***
Library   taf.sbts.oam.coam.admin
Library   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/testline_preparation/testline_preparation.py
Resource  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_2098/swconfig_operations.robot
Resource  testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/outsides/resources_570/preconditions.robot

Documentation  Author: tomasz.sobania@nokia.com
...            The keyword below is used for post-agent testline preparation:
...            - it uploads additional swconfig flags and cp_runtime for debug syslogs;
...            - uploads scf for the branch BTS is on;
...            - if it detects incompatible sw alarms on RMODs - it downloads the SW (if needed)
...              and performs sw update for the RMODs and checks if everything's on Air after it

*** Keywords ***
Prepare Testline
    [Documentation]  Parameter tl_type should be a string value of 'sa', 'nsa' or 'concurrent'.
    ...              This keyword will work if you have your TL SCF's named according to the standard
    ...              we just made up! Check custom-config/Wroclaw/7_16_UTE5GCLOUDT196 to see how SCF's
    ...              should be stored and named for their respective branches.
    [Arguments]  ${tl_type}=concurrent  ${enb_scf}=${False}   ${gnb_scf}=${False}  @{additional_swconfig_flags}
    Check Tl Type  ${tl_type}
    Close Webui Sessions If Any Exists
    Set Variables
    run keyword if  not '${tl_type}'=='sa'  Prepare Lte  ${BRANCH_SCF}  ${enb_scf}
    Prepare logging on SMOD
    Prepare TL with swconfig without BTS restart  @{additional_swconfig_flags}
    Load Scf  ${gnb_scf}
    Update Sw On Rmods If Needed
    Wait for cell to be in given state  online
    Run Keyword If  '${tl_type}'=='concurrent'  Wait For NSA To Get Up
    [Teardown]  Close Webui Sessions If Any Exists

########################################################################

Update Sw On Rmods If Needed
    ${admin_alias}=  WebUI.create_session
    ${alarms}=  Get active alarms
    WebUI.teardown_session
    ${incompatible_sw_detected}=  check alarms  ${alarms}
    Run Keyword If  ${incompatible_sw_detected}  Upload SW to RMODs


Set Variables
    ${test_line_config_dir}=  get config dir
    Set Global Variable           ${TEST_LINE_CONFIG_DIR}  ${test_line_config_dir}
    ${sw_release_name}=           get software release name
    ${branch_scf}=  get scf path  ${EXECDIR}               ${sw_release_name}       ${TEST_LINE_CONFIG_DIR}
    Set Global Variable           ${BRANCH_SCF}            ${branch_scf}


Close Webui Sessions If Any Exists
    WebUI.teardown_session


Load Scf
    [Arguments]  ${gnb_scf}
    ${admin_alias}=  WebUI.create_session
    Run Keyword If      ${gnb_scf}  Upload Scf  ${gnb_scf}     ${admin_alias}
    run keyword if  not ${gnb_scf}  Upload Scf  ${BRANCH_SCF}  ${admin_alias}
    Sleep  300s  reason=wait for BTS commissioning
    WebUI.teardown_session
    Sleep  180s  reason=wait for possible alarms on radio


Prepare logging on SMOD
    [Documentation]    This keyword is to set CP debug log on GNB_ASIK with the cmd
    ...     echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    ${smod}=  Connect to SMOD
    ${cmd_open_cp_debug}    Set Variable    echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
    SSH.Execute  command=${cmd_open_cp_debug}   connection=${smod}


Upload SW to RMODs
    ${admin_alias}=  WebUI.create_session
    ${sw}=  taf.sbts.oam.coam.admin.get_sw_version  connection=${admin_alias}
    ${status}=  Run Keyword And Return Status  Update Software For Rmods  software=${sw}  connection=${admin_alias}
    run keyword if  not ${status}              Update Software For Rmods  software=${sw}  connection=${admin_alias}
    Wait until keyword succeeds   900   10   Check FRM availability
    ${alarms}=  Get active alarms
    ${incompatible_sw_detected}=  check alarms  ${alarms}
    Should Be Equal  ${incompatible_sw_detected}   ${False}
    [Teardown]  WebUI.teardown_session


Wait For NSA To Get Up
    Sleep  90s  reason=wait for NSA alarms to appear
    Wait Until Keyword Succeeds  600  20  Check If X2 Link Is Up


Check If X2 Link Is Up
    ${admin_alias}=  WebUI.create_session
    ${alarms}=  Get Active Alarms
    WebUI.teardown_session
    ${result}=  Check If X2 Alarm Is Gone  ${alarms}
    run keyword if  not ${result}  Fail
