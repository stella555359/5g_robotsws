*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../../cloud_common_resources/mantaray/mantaray.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot

Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout
...  AUTHORS:       marek.starzyk@gmail.com
...  MAINTAINER:    VRF_WRO3_T03
...  *****************
...  Basic information
...  *****************
...  This test validates the software blue-green upgrade process with a non-default upueShutdownPeriodSeconds parameter,
...  defined by the user, including the scale-in of the redundant vCU using the LCM operator.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  13.01.2026 - TC Creation

Resource        ../../../resources/LCM_operator/LCM_operator.robot
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/logs/logs.robot

*** Keywords ***
UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout
    UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout:0 Test Preparation
    UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout:1 Perform Blue Green Upgrade

UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout:0 Test Preparation
    Decorate Print                           Step: 0 Test Preparation
    Prepare Green Namespace
    Set Test Variable                        ${BLUE_GREEN_UPGRADE_COMMAND}    kubectl apply -f rancnf_${hw}.yaml
    Add Temporary Alowed Alarms To Watchdog  hw_type=${non_upgraded_cnf}
    Add Temporary Alowed Alarms To Watchdog  hw_type=${hw}

UUF_CLOUD.24_CB013390-LCM–Blue_Green_Upgrade_with_Graceful_Scale_in_User_Defined_Non_Zero_Timeout:1 Perform Blue Green Upgrade
    Decorate Print                               Step: 1 Perform Blue Green Upgrade
    Execute Blue Green Upgrade
    ...    ssh_connection=${ssh_conn}            blue_green_command=${BLUE_GREEN_UPGRADE_COMMAND}
    ...    hw=${hw}                              blue_namespace=${BLUE_NAMESPACE}
    ...    green_namespace=${GREEN_NAMESPACE}    sw_version=${VCU_SW_VERSION}
    ${UPUE_PODS_LIST}    ${UPUE_SHUTDOWN_COMPLETED_ON_TIME}    ${SHUTDOWN_TIMEOUT}    verify_upue_shutdown_procedure
    ...    ssh_conn=${ssh_conn}
    ...    upue_shutdown_period_seconds=${UPUE_SHUTDOWN_TIME}
    Log To Console    waiting for blue-green upgrade to end
    Wait Until Keyword Succeeds    900s    30s    is_bg_upgrade_completed    ${ssh_conn}    ${GREEN_NAMESPACE}
    Run Keyword If    not ${UPUE_SHUTDOWN_COMPLETED_ON_TIME}
    ...  Fail
    ...  UPUE shutdown did not occur within the expected time.
    ...  upueShutdownPeriodSeconds set to ${UPUE_SHUTDOWN_TIME}, shutdown duration: ${SHUTDOWN_TIMEOUT}
    Check vCU State After Blue Green Upgrade

