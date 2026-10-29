*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define TMO rat reset test cases

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/L3_Call.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown

*** Variables ***
${times}    10
${x2_enb_mrbtsId}    8581
${gnbmode}    NSA

*** Test Cases ***
siso_common_rat_reset_actRATResetEnhancement_True
   [Timeout]  8h
   [Setup]    Case Setup:siso_common_rat_reset_actRATResetEnhancement_True
   FOR   ${index}    IN RANGE    ${times}
       log to console     //this is index：${index} time do All Soft RAT Reset with actRATResetEnhancement=True...
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['rat_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
       run keyword if   '${release}'>='SBTS24R3'    All Soft RAT Reset with actRATResetEnhancement True
    END
    wait until keyword succeeds    15min    1min   Check onair and x2 meantime
    ...    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}
    Start Capture Wireshark at gNB    nglogname=axis_0
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    wait until keyword succeeds   3x  1mins  Call Setup and check tput   method=PEAK
    ...   tput=110   tput_expect=110
    ...   peak_ul=9   ul_expect=9
    ...   duration=60
    [Teardown]   Case Teardown:siso_common_rat_reset_actRATResetEnhancement_True




*** Keywords ***
Case Setup:siso_common_rat_reset_actRATResetEnhancement_True
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    AlarmWatchdog.add_allow_alarms    fault_id=4741
    Wait Until Keyword Succeeds    2m   30s   COAM Login
    Upload Swconfig File    swconfig_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/swconfig.txt
    CI_interface.Common Suite Setup
    wait until keyword succeeds    15min    1min   Check onair and x2 meantime
    ...    x2_enb_mrbtsId=${x2_enb_mrbtsId}   gnbmode=${gnbmode}
    Recovery At Case Setup if Fault Occurs
    ${btsinfo}     COAM Get BTS Info
#    ${cells_info}     Get Dictionary Values    ${btsinfo['cells']}
    ${rat_list}     Create List
    FOR    ${rat}    IN    @{btsinfo['cells']}
        ${isempty}     run keyword and return status     should be empty    ${btsinfo['cells']['${rat}']}
        continue for loop if     ${isempty}
        Append to list     ${rat_list}     ${rat}
     END
     ${nr_cell_list}     ${lte_cell_list}    COAM Get 4G 5G Cell List
     Set test variable     ${rat_list}
     Set test variable     ${nr_cell_list}
     Set test variable     ${lte_cell_list}
    ${release}   COAM Get SW Release   connection=COAM
    set test variable    ${release}
    run keyword if   'SBTS24R2'<'${release}'<'SBTS25R3'
    ...    Active or Disable Rat Hard Reset by Param    option=true
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair


Case Teardown:siso_common_rat_reset_actRATResetEnhancement_True
    run keyword and ignore error    Stop and download Wireshark at gNB    nglogname=axis_0
    run keyword if   'SBTS24R2'<'${release}'<'SBTS25R3'
    ...    Active or Disable Rat Hard Reset by Param    option=true
    Siso Common Save Logs
    Wait Until Keyword Succeeds   15m   30s   COAM Check all cells should be onair
     [Teardown]    run keywords    COAM Logout
     ...   AND   robot_common_operations.Common Case Teardown

