*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           #SISO Coam Test Setup
Test Teardown        #SISO Coam Test Teardown
Test Timeout         1h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_enable_and_disable_eCPRI_M-Plane_resilience.robot
#Resource    ${BASIC_PATH_5G}/General_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_with_one_bbmod.robot
#Resource    ${BASIC_PATH_5G}/General_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress.robot
#Resource    ${BASIC_PATH_5G}/General_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session.robot

Documentation
...    Author: liu yue
...    contact: yue.2.liu@nokis-sbell.com
...    squad group:SG_05
...    Feature 'CB005833-SR-D-SyVe eCPRI M plane Resilience - P2P Configuration (Master + Amber)' in 22R4 program

Force Tags    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_SA_ASIBL_ABIOB1_AEQE
...   PY310

*** Test Cases ***
[1]CB005833_09_enable_disable_eCPRI_M-Plane_resilience
    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_CB005833    CRT_TRUNK    CRT_22R4
    [Setup]    SISO Coam Test Setup
###    General_enable_and_disable_eCPRI_M-Plane_resilience

#    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#    ${ru_index_list}  Get All RU Index    connection=${connection}
    ${ru_index_list}  Get All RU Index
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Check and Modify Single Parameter on WebUI    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    ...    filter_param=Activate eCPRI M-Plane Resilience    abbr=actEcpriMPlaneResilience    new_value=true
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_ip_addr2}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
        Should Contain Any    ${ru_ip_addr2}    15.1.1    35.1.1
    END
    [Teardown]    Run keywords    Run Keyword And Ignore Error   Commissioning SCF And Check On Air   scf_path=${Golden_SCF_Path}
    ...    AND   SISO Coam Test Teardown

#[1]CB005833_04_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_where_resiliency_is_only_on_one_CC_card
#    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_CB005833
#    General_resiliency_of_M-Plane_communication_between_RU_and_DU_in_P2P_deployment_with_one_bbmod
#
#[1]CB005833_06_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress
#    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_CB005833
#    General_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress
#
#[1]CB005833_13_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session
#    [Tags]    3S-2CC-8D-4U_100-100M_C4_Split_CB005833
#    General_Link_Supervision_with_BFD_checking_while_enabling_and_disabling_BFD_session
