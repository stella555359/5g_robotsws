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
TC_CB007402_ST_02_03_upgradeCfgDataValidCheck_failed_on_Webem_remot_toll_when_PDL_err_or_wrn_exists
    [Documentation]    Short description.
    Step 1: Prepare PDL err on BTS
    Step 2: Perform SW download from webem
    Step 3: upgradeCfgDataValidCheckfail
    Step 4: Check if fault30 present after valid err
    Step 5: ParaModifyCorrect and upgradeCfgDataValidCheck
    Step 6: Check if fault30 cleared after valid ok
    Step 7: Prepare PDL wrn on BTS
    Step 8: upgradeCfgDataValidCheckfail for PDL wrn
    Step 9: ParlaModifyCorrect and upgradeCfgDataValidCheck for wrn

Step 1: Prepare PDL err on BTS
    [Documentation]    Short description.
    Log Step Header  Step 1: Prepare PDL err on BTS
    _Get Scf By Admin  ${BTSFiles}/BACK_UP.xml
    ModifyParaOnSBTS  true
    _Get Scf By Admin  /home/ute/wait_validate_NOK_scf.xml
    ${validate_res}  Run keyword
    ...  taf.sbts.oam.coam.admin.validate_scf_online
    ...    /home/ute/wait_validate_NOK_scf.xml  skip_parameter_relation_errors=True
    Run keyword if  '${validate_res['requestMessage']['pdlValidationResult']['status']}'=='FAIL'
    ...  log to console   Validation err on BTS as expected.
    ...  ELSE   FAIL   Validation err not occured on BTS.

Step 2: Perform SW download from webem
    [Documentation]    Short description.
    Log Step Header  Step 2: Perform SW download from webem
    ${check_package}=    Common_Find SW name    ${Target SW dir}
    taf.sbts.oam.coam.admin.Run keyword in background     Update Software
    ...  sw_package=${SW_path_T2_package}  should_activate=False  timeout=${SW_UPDATE_TIMEOUT}
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

Step 3: upgradeCfgDataValidCheckfail
    [Documentation]    Short description.
    Log Step Header  Step 3: upgradeCfgDataValidCheckfail
    taf.sbts.oam.coam.admin.Setup Admin    alias=config_check    update_interval=1000
    ${status}  ${upgrade_validate_res}  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.upgrade_config_data_valid_check  timeout=300  detailed_output=True
    ${upgrade_validate_res}  convert to string   ${upgrade_validate_res}
    Run keyword if  '69' in """${upgrade_validate_res}""" and 'failed' in """${upgrade_validate_res}"""
    #...  Should Contain '${upgrade_validate_res['errorCode']}  '69'
    #...  Should Contain '${upgrade_validate_res['requestStatus']}'failed'
    ...  Log to console  upgradeCfgDataValidCheck successful.
    ...  ELSE  FAIL   unexpected result.
    Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.get_connection_and_configuration_status  timeout=300

Step 4: Check if fault30 present after valid err
    [Documentation]    Short description.
    ${EXPECTED_ALARM1}=     Create Dictionary  faultId=30
    ${EXPECTED}=            Create List  ${EXPECTED_ALARM1}
    ${alarms_status}    ${alarms_msg}=
    ...  Run Keyword And Ignore Error    Admin Check Active Alarms    expected_patterns=${EXPECTED}
    Run keyword if    '${alarms_status}'=='FAIL'
    ...  Log    Critical fail while checking alarms: ${alarms_msg}    console=${TRUE}
    ...    ELSE IF    ${alarms_msg}    Set test restriction    Unexpected alarms are present: ${alarms_msg}

Step 5: ParaModifyCorrect and upgradeCfgDataValidCheck
    [Documentation]    Short description.
    ModifyParaOnSBTS  false
    ${upgrade_validate_res}
    ...   Run keyword and return status
    ...   taf.sbts.oam.coam.admin.upgrade_config_data_valid_check  timeout=120  detailed_output=True
    Run keyword if  '${upgrade_validate_res}'=='True'
    ...  log  upgradeCfgDataValidCheck success as expected  console=${TRUE}

Step 6: Check if fault30 cleared after valid ok
    [Documentation]    Short description.
    @{active_alarms} =  taf.sbts.oam.coam.admin.Get Active Alarms
    Log  ${\n}Active alarms on SBTS:  console=${TRUE}
    FOR  ${alarm}  IN  @{active_alarms}
        Log  FaultId: ${alarm.faultId}, Severity: ${alarm.severity}, Notifier: ${alarm.notifier}  console=yes
#        ${suplement_info}  run keyword and return status  should contain  ${alarm.notifier}  SMOD_R
        Run Keyword If  '${alarm.faultId}'=='30'
#         and ${notifier_is_smod}
        ...  Fail  Alarm with fault 30 on SBTS active
    END
    Log  ${\n}Fault30 cleared  console=yes

Step 7: Prepare PDL wrn on BTS
    [Documentation]    Short description.
    Log Step Header  Step 7: Prepare PDL wrn on BTS
    ${scf_con}    OperatingSystem.Get File
    ...   /home/ute/testline_configuration/${TESTLINE_NAME}/node1/BTS_${tl.tl_cloud_topology}_${sw_release}.xml
    ${scf_con_changed}    Replace String Using Regexp
    ...    ${scf_con}    <p name="tceIpAddress">10.21.41.148</p>    <p name="tceIpAddress">2a00:8a00:8000:10c:1:d:0:402</p>
    Create File    ${BTS Files}/pre_scf.xml    ${scf_con_changed}
    _Perform Full Commision By Admin    ${BTS Files}/pre_scf.xml    ${BTS_INFO.ID}
#    _Get Scf By Admin  ${BTSFiles}/BACK_UP.xml
#    ModifyParaOnSBTS_wrn  16DL8UL
#    _Get Scf By Admin  /home/ute/wait_validate_NOK_scf.xml
    ${validate_res}  Run keyword
    ...  taf.sbts.oam.coam.admin.validate_scf_online
    ...    ${BTS Files}/pre_scf.xml  skip_parameter_relation_errors=True
    Run keyword if
    ...  '${validate_res['requestMessage']['pdlValidationResult']['logs']['relationErrors'][0]['severity']}'=='Warning'
    ...  log to console   Validation wrn on BTS as expected.
    ...  ELSE   FAIL   Validation wrn not occured on BTS.

Step 8: upgradeCfgDataValidCheckfail for PDL wrn
    [Documentation]    Short description.
    Log Step Header  Step 8: upgradeCfgDataValidCheckfail for PDL wrn
    taf.sbts.oam.coam.admin.Setup Admin    alias=config_check_for_wrn    update_interval=1000
    ${status}  ${upgrade_validate_res}  Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.upgrade_config_data_valid_check  timeout=300  detailed_output=True
    ${upgrade_validate_res}  convert to string   ${upgrade_validate_res}
    Run keyword if  'PDL warning' in """${upgrade_validate_res}"""
    #...  Should Contain '${upgrade_validate_res['errorCode']}  '69'
    #...  Should Contain '${upgrade_validate_res['requestStatus']}'failed'
    ...  Log to console  upgradeCfgDataValidCheck successful.
    ...  ELSE  FAIL   unexpected result.
    Run keyword and ignore error
    ...    taf.sbts.oam.coam.admin.get_connection_and_configuration_status  timeout=300

Step 9: ParlaModifyCorrect and upgradeCfgDataValidCheck for wrn
    [Documentation]    Short description.
    _Perform Full Commision By Admin
    ...   /home/ute/testline_configuration/${TESTLINE_NAME}/node1/BTS_${tl.tl_cloud_topology}_${sw_release}.xml
    ...  ${BTS_INFO.ID}
    ${upgrade_validate_res}
    ...   Run keyword and return status
    ...   taf.sbts.oam.coam.admin.upgrade_config_data_valid_check  timeout=120  detailed_output=True
    Run keyword if  '${upgrade_validate_res}'=='True'
    ...  log  upgradeCfgDataValidCheck success as expected  console=${TRUE}

Step ${index}: check final BTS state and alarm status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${index}: <description>
    Log Step Header  Step 4: check final BTS state and alarm status
    Wait until keyword succeeds   10min  10 sec  Verify BTS states
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

ModifyParaOnSBTS
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Paravalue}: <description>
    [Arguments]  ${Paravalue}=false
    create file    ${BTSFiles}/modify_${Paravalue}.json
    file_operation.Update Json File  target_json_file=${BTSFiles}/modify_${Paravalue}.json
    ...  dist_operation=update    dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter_operation=update       rfSharingEnabled=${Paravalue}
    _Perform Delta Commission By Admin    ${BTSFiles}/modify_${Paravalue}.json
