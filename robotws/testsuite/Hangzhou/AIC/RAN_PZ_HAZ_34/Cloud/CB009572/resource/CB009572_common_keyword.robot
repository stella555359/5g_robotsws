*** Settings ***
Documentation
...    author: zhao nana
...    contact: nana.zhao@nokia-sbell.com
...    squad group: RAN_PZ_3_SG02
...    Feature :  CB009572


Library    taf.nms.netact    WITH NAME    netact
Library    DateTime
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot


*** Variables ***
${NETACT_NAME}=    srnclab1507
${HOSTNAME}=    ${tl.nms.https_main_info.addr}
${USERNAME}=    ${tl.nms.https_main_info.username}
${PASSWORD}=    ${tl.nms.https_main_info.password}
${file_name}    tl173-vdu-plan.xml
#${local_dir}    /home/nazhao/tmp/
${plan_name}    tl173-vdu-plan-auto
${plan_name_23R3}    tl173-vdu-plan-auto-23R3
${plan_name_23R4}    tl173-vdu-plan-auto-23R4
${SCF_Template_path_DU}     ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
${ui_version}    S21UI4.0
${ue_type}    ${tl.ues[${0}].capabilities[0]}
${vran_version}    vran4.0
${attach_mode}    5G_NSA
${upgrade_plan_name}    tl173-vdu-upgrade
${upgrade_plan_name_23R3}    tl173-vdu-upgrade-23R3
${upgrade_plan_name_23R4}    tl173-vdu-upgrade-23R4
${dist_names}    PLMN-PLMN/CNF-11164
${rollback_plan_name}    tl173-vdu-rollback
${rollback_plan_name_23R3}    tl173-vdu-rollback-23R3
${rollback_plan_name_23R4}    tl173-vdu-rollback-23R4


*** Keywords ***

step1: Prepare UE
    [Documentation]    Author: zhao nana
    ...                This keyword is prepare UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20    ${ui_version}=S21UI3.1
    log to console      step1: Prepare UE
    
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=${ui_version}

Step2: UE Attach
    [Documentation]    Author: zhao nana
    ...                This keyword is attach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20    ${attach_mode}=5G_NSA
    log to console      Step2: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog    attach_mode=${attach_mode}

Step6: UE Detach
    [Documentation]    Author: zhao nana
    ...                This keyword is UE Detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    
    log to console    Step6: UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

