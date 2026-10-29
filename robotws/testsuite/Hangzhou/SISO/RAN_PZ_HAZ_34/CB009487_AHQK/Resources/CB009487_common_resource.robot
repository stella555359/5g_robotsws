*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Huawei_sigspark_L3_call.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
#Library           ../../../../../resources/python_libs/check_csv_log.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot

*** Variables ***
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Setup enviornment with relevant configuration
    [Arguments]   ${scf_path}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009487_AHQK/Resources
    robot_common_operations.Common Suite Setup
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}

Get Current RU Number
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=GNB_OAM
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    [return]    ${ru_list}

Power reset RU and Check Status
    [Arguments]    ${ru_list}    ${all_cell}=${true}    ${gnb_index}=0    ${du_index}=0
    FOR    ${r_list}    IN    @{ru_list}
         Perform RU Power Off    ru_index=${r_list}
         ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
         ${cg_list}    Evaluate    ${r_list}-1
         sleep    5 sec
         Wait until keyword succeeds    3 min    20 sec    RU Should Be Power Off    ru_index=${r_list}
    END
    ${length}=    Get Length    ${ru_list}
    Run keyword If    ${all_cell}    Wait Until Keyword Succeeds    3 min    20 sec
    ...    Check Present Fault Number    faultId=${10}    source=RMOD_R    number=${length}
    FOR    ${r_list}    IN    @{ru_list}
         Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
         Wait until keyword succeeds    15 min    20 sec    RU Should Be Online    ru_index=${r_list}
    END
    Wait Until Keyword Succeeds    9 min    20 sec
    ...    Check Present Fault Number    faultId=${10}    source=RMOD_R    number=0
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    COAM Wait for gnb ready and cell setup