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
...  TEST NAME:     UUF_CLOUD.01_ST_vCU_SW_intra_release_upgrade_pre-check_via_Helm_CLI
...  AUTHORS:       roscislaw.szuminski@nokia.com
...  MAINTAINER:    VRF_WRO3_T01
...  *****************
...  Basic information
...  *****************
...  This test verifies vCU inter release pre-check from Release N drop(P7) to Release N+1 drop(PT.x) using helm cli.
...  *****************
...  RAN PZ3 WRO1 TEMPLATE
...  ******************
...  History of changes
...  ******************
...  05.12.2024 - TC Creation


*** Keywords ***
UUF_CLOUD.01_ST_vCU_SW_intra_release_upgrade_pre-check_via_Helm_CLI

    UUF_CLOUD.01_ST_vCU_SW_intra_release_upgrade_pre-check_via_Helm_CLI:1 Verify Pods/Rannic/Charts/Noki-Synch Status
    UUF_CLOUD.01_ST_vCU_SW_intra_release_upgrade_pre-check_via_Helm_CLI:2 Save Status


UUF_CLOUD.01_ST_vCU_SW_intra_release_upgrade_pre-check_via_Helm_CLI:1 Verify Pods/Rannic/Charts/Noki-Synch Status
    Decorate Print  Step: 2 Verify Pods/Rannic/Charts/Noki-Synch Status
    Log  Charts Status:  console=${true}
    ${deployed_charts}=  Get Names And Status From Helm List  ${ssh_conn}
    Check If Charts Deployed  ${deployed_charts}
    ${all_pods}=  ssh.Execute  kubectl -n ${CRAN_VCU} get pods  connection=${ssh_conn}
    Log  ========================================  console=${true}
    Log  Pods Status: ${all_pods}  console=${true}
    VCU Pod Status Should Be Normal

UUF_CLOUD.01_ST_vCU_SW_intra_release_upgrade_pre-check_via_Helm_CLI:2 Save Status
    Decorate Print  Step: 3 Save Status
    ssh.Execute  mkdir Logs  connection=${ssh_conn}
    Set Save Status Command As Test Variable    ${ssh_conn}    ${CRAN_VCU}
    Check Pre Post Status  save_status_cm=${save_status_command}  bts_id=${MRBTS_CU}  hw_type=vCU  pre_post=precheck  conn=${ssh_conn}
    Disconnect from ADMIN via SSH  hw_type=vCU
