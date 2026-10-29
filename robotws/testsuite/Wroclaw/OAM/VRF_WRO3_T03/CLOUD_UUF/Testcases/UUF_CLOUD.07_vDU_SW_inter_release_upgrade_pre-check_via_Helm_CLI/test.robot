*** Settings ***
Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        taf/rfrl/cbts/utilities/init_variables.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource        ../../../resources/common.robot


Library         taf.ul.vdu.helm.interface.helm   WITH NAME    helm
Library         taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library         Collections

Documentation
...  TEST NAME:     UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies vDU inter release pre-check from Release N drop(P7) to Release N+1 drop(PT.x) using helm cli.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  10.02.2025 - TC Creation

*** Keywords ***
UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI

    UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI:0 Test Preparation
    UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI:1 Verify Pods/Rannic/Charts/Noki-Synch Status
    UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI:2 Save Status

UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI:0 Test Preparation
    Decorate Print  Step: 0 Test Preparation
    Set Save Status Command As Test Variable    ${ssh_conn}    ${CRAN_VDU}
    Set Test Variable  ${save_status_command}  helm test vdu --filter "name=upgrade-pre-check" -n ${CRAN_VDU}


UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI:1 Verify Pods/Rannic/Charts/Noki-Synch Status
    Decorate Print  Step: 1 Verify Pods/Rannic/Charts/Noki-Synch Status
    Log  Charts Status:  console=${true}
    ${deployed_charts}=  Get Names And Status From Helm List  ${ssh_conn}
    Check If Charts Deployed  ${deployed_charts}
    ${all_pods}=  ssh.Execute  kubectl -n ${CRAN_VDU} get pods  connection=${ssh_conn}
    Log  ========================================  console=${true}
    Log  Pods Status: ${all_pods}  console=${true}
    VDU Pod Status Should Be Normal

UUF_CLOUD.07_vDU_SW_inter_release_upgrade_pre-check_via_Helm_CLI:2 Save Status
    Decorate Print  Step: 2 Save Status
    ssh.Execute  mkdir Logs  connection=${ssh_conn}
    Set Save Status Command As Test Variable    ${ssh_conn}    ${CRAN_VDU}
    Check Pre Post Status  save_status_cm=${save_status_command}  bts_id=${MRBTS}  hw_type=vDU  pre_post=precheck  conn=${ssh_conn}
