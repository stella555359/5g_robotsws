*** Settings ***
Documentation      author: Chen Xiaodong
...                contact: xiaodong.d.chen@nokia-sbell.com
...                Group: HGZ_SG2
Force Tags         5G_RRM    PY36
Suite Setup        SBTS Suite Setup
Suite Teardown     SBTS Suite Teardown
Library            OperatingSystem
Library            BuiltIn
Library            String
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/SBTS_Setup_And_Teardown.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Common/Auto_BTS_site_reset.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

*** Variables ***
${sbts_addr}        ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${http_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${http_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${MRBTS_ID}         ${tl.gnbs[0].instance_id}
${NRBTS_ID}         ${tl.gnbs[0].global_bts_id}
@{cell_list}        1
${cell_type}        lte
${if_commissioning}    0
${scf_relative_dir}    commissionings/HGZ
${if_pdl_check}      True
@{btslog_dirs}       /tmp/btslog2/
${scf_path}          /home/ute/Downloads/SCF

*** Test Cases ***
[1]CB008502_01_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_25_eCPRI
    [Tags]     samsung_S20    4G    5G
    [Setup]    Case Setup 8502
    Run Keyword And Ignore Error    Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/${version}/8502_eCpri25_scf.xml
    Run Keyword And Ignore Error    Simple UE L3 Call And Throughput    dl_tp=100    ul_tp=5
    [Teardown]    Run Keyword And Ignore Error    case Teardown 8502

[1]CB008502_02_BTS_Deployment_via_Commissioning_wizard_or_SCF_load_10_eCPRI
    [Tags]     samsung_S20    4G    5G
    [Setup]    Case Setup 8502
    Run Keyword And Ignore Error    Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/${version}/8502_eCpri10_scf.xml
    Run Keyword And Ignore Error    Simple UE L3 Call And Throughput    dl_tp=100    ul_tp=5
    [Teardown]    Run Keyword And Ignore Error    case Teardown 8502

[1]CB008502_05_Ethernet_mode_reconfiguration_during_BTS_runtime
    [Tags]     samsung_S20    4G    5G
    [Setup]    Case Setup 8502
    Run Keyword And Ignore Error    Commissioning SCF And Check On Air for Common    scf_path=${scf_path}/${version}/8502_eCpri25_scf.xml
    ${output_alarms_normal}     COAM Get active alarms
    Set test variable    ${output_alarms_normal}
    FOR    ${i}    IN RANGE    15
        modify linkspeed test one time
    END
    [Teardown]    Run Keyword And Ignore Error    case Teardown 8502

*** Keywords ***
Case Setup 8502
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    SBTS Test Setup
    robot_common_operations.Common Case Setup    allowed_faults_ids=4420

modify linkspeed test one time
    [Documentation]   Modify linkspeed from eCpri10 to eCpri25
    Modify parameter linkspeed to new value online    value=eCpri10
    sleep    5min
    ${output_alarms_eCpri10}    COAM Get active alarms
    Set test variable    ${output_alarms_eCpri10}
    Run Keyword And Ignore Error    Simple UE L3 Call And Throughput    dl_tp=100    ul_tp=5
    Modify parameter linkspeed to new value online    value=eCpri25
    sleep    5min
    ${output_alarms_eCpri25}    COAM Get active alarms
    Set test variable    ${output_alarms_eCpri25}
    Run Keyword And Ignore Error    Simple UE L3 Call And Throughput    dl_tp=100    ul_tp=5
    Check no unexpect alarm exist

Modify parameter online
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    &{param}    Create Dictionary    dist_name=${dist_name}    parameter=${parameter}    value=${value}
    @{modify_param}    Create List    ${param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=600

Modify parameter linkspeed to new value online
    [Arguments]    ${value}
    [Documentation]   Modify parameter online
    ...          :value     new value which to change
    Modify parameter online    dist_name=MRBTS-10756/EQM-1/HWTOP-1/CABLINK-2    parameter=linkSpeed    value=${value}
    sleep    5min
    Modify parameter online    dist_name=MRBTS-10756/EQM-1/HWTOP-1/CABLINK-3    parameter=linkSpeed    value=${value}
    sleep    5min
    Modify parameter online    dist_name=MRBTS-10756/EQM-1/HWTOP-1/CABLINK-4    parameter=linkSpeed    value=${value}

Check no unexpect alarm exist
    ${length}=       get length     ${output_alarms_normal}
    Should be true    ${length}==4
    ${length10}=     get length     ${output_alarms_eCpri10}
    Should be true    ${length10}==4
    ${length25}=     get length     ${output_alarms_eCpri25}
    Should be true    ${length25}==4

case Teardown 8502
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Save Coam Snapshot
    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    SBTS Test Teardown
