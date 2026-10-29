*** Settings ***
Documentation
...   Tests that
...   The main functionality of this test is to check if the m
...   QC_NAME:
...   Author: amaand.li@nokia-sbell.com
...   maintainer: zhonggen.lu@nokia-sbell.com
Library    taf.sbts.oam.coam.admin
Library    taf.nms.netact
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource          ../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Library		SSHLibrary
Library		Collections
Library		String
Library		OperatingSystem


*** Variables ***
${SW Update Timeout}               3000


*** Keywords ***
TC_CB007402_ST_05_03_execute_upgradeCfgDataValidCheck_successful_from_Webem
    [Documentation]    Short description.
    Step 1: No validation err on BTS before upgradeCfgDataValidCheck
    Step 2: Perform SW download from webem
	Step 3: upgradeCfgDataValidCheck
	Step 4: check final BTS state and alarm status

Step 1: No validation err on BTS before upgradeCfgDataValidCheck
    [Documentation]    Short description.
    Log Step Header  Step 1: No validation err on BTS before upgradeCfgDataValidCheck
    _Get Scf By Admin  /home/ute/wait_validate_scf.xml
    ${validate_res}  taf.sbts.oam.coam.admin.validate_scf_online
    ...    /home/ute/wait_validate_scf.xml  skip_parameter_relation_errors=True
    Run keyword if  '${validate_res['errorCode']}'=='0'  log to console   No validation err on BTS.
    ...  ELSE   FAIL   Validation err occured on BTS.

Step 2: Perform SW download from webem
    [Documentation]    Short description.
    Log Step Header  Step 2: Perform SW download from webeAdd Xml Elementm
    ${Tested_package}=    Common_Find SW name    ${Target SW dir}
    taf.sbts.oam.coam.admin.Run keyword in background     Update Software
    ...  sw_package=${Tested_package}  should_activate=False  timeout=${SW_UPDATE_TIMEOUT}
    ${distName_pattern}  Set variable  /MRBTS-1/RAT-1/URI-*/SESSION-*/SW_UPDATE_IND-*
    ${object}  Query Infomodel  get object ${distName_pattern} is [actionType="Download"]  timeout=5m
    Log  SW download started.  console=${TRUE}
    ${result}  Query Infomodel
    ...  get object ${object['dist_name']}/SW_UPDATE_RESULT-* is [result="Successful"]  timeout=30m
    Log  SW download finished.  console=${TRUE}

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}  OperatingSystem.List files in directory  ${SW_PATH}
    should not be empty  ${package name}  Required package not present in ${SW_PATH}
    ${SW_PATH_package}=  Join Path 	${SW_PATH}  ${package name[0]}
    OperatingSystem.File should exist  ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

Step 3: upgradeCfgDataValidCheck
    [Documentation]    Short description.
    Log Step Header  Step 3: upgradeCfgDataValidCheck
    taf.sbts.oam.coam.admin.Setup Admin    alias=config_check    update_interval=1000
    ${status}  ${upgrade_validate_res}  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.upgrade_config_data_valid_check  timeout=120  detailed_output=True  connection=config_check
    Run keyword if
    ...  '${upgrade_validate_res['errorCode']}'=='0' and '${upgrade_validate_res['requestStatus']}'=='completed'
    ...  Log to console  upgradeCfgDataValidCheck successful.
    [Teardown]  Run keyword and ignore error  taf.sbts.oam.coam.admin.teardown admin  connection=config_check

Step 4: check final BTS state and alarm status
    [Documentation]    Short description.
    Log Step Header  Step 4: check final BTS state and alarm status
    Wait until keyword succeeds   10min  10 sec  Verify BTS states
    Log Important Message  BTS is OnAir, all cells and modules are in expected states
