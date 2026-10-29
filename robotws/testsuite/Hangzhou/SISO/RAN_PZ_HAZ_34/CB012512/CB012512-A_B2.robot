*** Settings ***
Documentation     author: Jerry Wu
...               contact: jerry.wu@nokia-sbell.com
...               squad group: VRF HAZ3 2
...               feature: CB012512-A
Suite Setup       SISO Coam Suite Setup With Specify SCF    scf_suffix=_CB012512_A_B2
#Suite Setup       SISO Coam Suite Setup
Suite Teardown    Run Keyword And Ignore Error     SISO Coam Suite Teardown
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012512/Resource/CB012512_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Loop_Collect_Snapshot.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /home/ute
${if_commissioning}    True


*** Test Cases ***
General_SiSo_Commissioning_BTS_Template_Commissioning_A_B2
    [Documentation]    Modify bbmodBoardConfigType parameter and restore
    [Tags]    AQHC    PARAM_MODIFY    bbmodBoardConfigType
    [Setup]    SISO Coam Test Setup
    AlarmWatchdog.add_allow_alarms    fault_id=1868
    Selenium Login And Disable Screen Lock
    ${ori_value}    Get Parameter Via Webem
	...    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-6
	...    filter_param=Baseband board configuration type
    ${modify_params}=    Create List
    ${param_dict}=    Create Dictionary
	...    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-6
	...    filter_param=Baseband board configuration type
	...    p_name=bbmodBoardConfigType
	...    value=LTEFDD_NRTDD
    Append To List    ${modify_params}    ${param_dict}
    Modify Parameters On Webem    ${modify_params}    ${True}    ${True}    360
    Check Parameters Modified Successfully    ${modify_params}
    Alarm 1868 in Given Alarm list Present
    ${restore_params}=    Create List
    Set To Dictionary    ${param_dict}    value=${ori_value}
    Append To List    ${restore_params}    ${param_dict}
    Modify Parameters On Webem    ${restore_params}    ${True}    ${True}    360
    Check Parameters Modified Successfully    ${modify_params}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    Selenium Logout And Close Browser
	AlarmWatchdog.remove_allow_alarms    fault_id=1868
    [Teardown]    SISO Coam Test Teardown

Manual_SiSo_SM_BTS_Site_Reset_A_B2
    [Setup]    SISO Coam Test Setup
    General_SiSo_Auto_BTS_site_reset
    [Teardown]    SISO Coam Test Teardown

General_SiSo_Online_Cell_Addition_Deletion_A_B2
    [Setup]    SISO Coam Test Setup
    Online Cell addition deletion    addition_deletion_cell=6
    [Teardown]    SISO Coam Test Teardown

Manual_SiSo_SM_Cell_Lock_Unlock_A_B2
    [Setup]    SISO Coam Test Setup
    ${list_of_cell_ids}    Create List	  2146304
    peak_throughput    cells=${list_of_cell_ids}    Case_SCF_Path=${SCF_Path}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Block and unblock single cell
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    peak_throughput    cells=${list_of_cell_ids}    Case_SCF_Path=${SCF_Path}
    [Teardown]    SISO Coam Test Teardown