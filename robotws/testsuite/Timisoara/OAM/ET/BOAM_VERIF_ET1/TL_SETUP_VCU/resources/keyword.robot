*** Settings ***
Documentation
...   author:
...   contact:
...   squad group:
Resource          ../../vduResourcesAIC/aic_common_vcu_resources.robot
Resource          ../../vduResourcesAIC/aic_vdu_oam.robot
Resource          ../../vduResourcesAIC/aic_vdu_deployment.robot
Resource          ../../vduResourcesAIC/aic_vdu_ru_status.robot
Library           Collections
Resource          ../../vduResourcesAIC/vdu_oam_cm.robot
Resource          ../../vduResourcesAIC/common_setup_teardown.robot
Library           taf.ul.vdu.helm                       WITH NAME    helm
Library           OperatingSystem
Library           Process
Library           SeleniumLibrary
Library           String
Library           taf.transport.ssh                     WITH NAME    tafssh


#Suite Setup       AiC Common Suite Setup
#Suite Teardown    AiC Common Suite Teardown

*** Variables ***


*** Keywords ***
SCF FILE
    ${SCF_FILE}    Set Variable If   '${BRANCH_from_JENKINS}' == 'master_CU_CNF'    master_CU_CNF.xml
        ...                            '${BRANCH_from_JENKINS}' == 'vCUCNF22R3'    vCUCNF22R3.xml
        ...                         ${BRANCH_from_JENKINS}' == 'vCUCNF22R4'    vCUCNF22R4.xml
    Set Global Variable  ${SCF_FILE}

Branch or Trunk Jenkins
    ${BRANCH_from_JENKINS}=     Run  command=cat ~/jenkins/branch.txt

    Set Global Variable  ${BRANCH_from_JENKINS}

Get last vCU build from Jenkins
#     ${VCU_BUILD}     Run  command=cat ~/jenkins/last22R3.txt
    Run Keyword If  '${BRANCH_from_JENKINS}' == 'master_CU_CNF'
        ...            Get last vCU Trunk build from Jenkins
        ...   ELSE IF  '${BRANCH_from_JENKINS}' == 'vCUCNF22R4'
        ...            Get last vCU branch build from Jenkins
        ...   ELSE     Fail

VCU build
    ${VCU_BUILD}=                Split String
        ...                          string=${VCU_BUILD}
        ...                          separator=_
        ...                          max_split=2

    ${VCU_VERSION}=   Get from list         ${VCU_BUILD}    1

    Log To Console  ${VCU_VERSION}
    Set Global Variable  ${VCU_VERSION}

Get last vCU Trunk build from Jenkins
    ${VCU_BUILD}     Run  command=cat ~/jenkins/lastTrunk.txt
    Log to console      ${VCU_BUILD}
    Set Global Variable   ${VCU_BUILD}
    VCU build

Get last vCU branch build from Jenkins
    ${VCU_BUILD}     Run  command=cat ~/jenkins/last22R4.txt
    Log to console      ${VCU_BUILD}
    Set Global Variable   ${VCU_BUILD}
    VCU build

Get Deployment Type for vCU from Jenkins
    ${DEPLOYMENT_from_Jenkins}   Run  command=cat ~/jenkins/deployment_vCU.txt
    Log to console   vCU will be deployed in ${DEPLOYMENT_from_Jenkins} mode
    Set Global Variable   ${DEPLOYMENT_from_Jenkins}
    ${CNF_LAYOUT}    Set Variable If   '${DEPLOYMENT_from_Jenkins}' == '2N'      redundant
        ...                            '${DEPLOYMENT_from_Jenkins}' == '2N+3'    redundant
        ...                            '${DEPLOYMENT_from_Jenkins}' == '1N'      basic
        ...                            '${DEPLOYMENT_from_Jenkins}' == 'N+'      basic
    Set Global Variable  ${CNF_LAYOUT}
    ${CPUE_COUNT}    Set Variable If   '${DEPLOYMENT_from_Jenkins}' == '2N'      2
        ...                            '${DEPLOYMENT_from_Jenkins}' == '2N+3'    3
        ...                            '${DEPLOYMENT_from_Jenkins}' == '1N'      1
        ...                            '${DEPLOYMENT_from_Jenkins}' == 'N+'      2
    Set Global Variable  ${CPUE_COUNT}
    ${UPUE_COUNT}    Set Variable If   '${DEPLOYMENT_from_Jenkins}' == '2N'      2
        ...                            '${DEPLOYMENT_from_Jenkins}' == '2N+3'    3
        ...                            '${DEPLOYMENT_from_Jenkins}' == '1N'      1
        ...                            '${DEPLOYMENT_from_Jenkins}' == 'N+'      2
    Set Global Variable  ${UPUE_COUNT}
    ${MIN_CPUE}    Set Variable If     '${DEPLOYMENT_from_Jenkins}' == '2N'      1
        ...                            '${DEPLOYMENT_from_Jenkins}' == '2N+3'    2
        ...                            '${DEPLOYMENT_from_Jenkins}' == '1N'      1
        ...                            '${DEPLOYMENT_from_Jenkins}' == 'N+'      1
    Set Global Variable  ${MIN_CPUE}
    ${MIN_UPUE}    Set Variable If     '${DEPLOYMENT_from_Jenkins}' == '2N'      1
        ...                            '${DEPLOYMENT_from_Jenkins}' == '2N+3'    2
        ...                            '${DEPLOYMENT_from_Jenkins}' == '1N'      1
        ...                            '${DEPLOYMENT_from_Jenkins}' == 'N+'      1
    Set Global Variable  ${MIN_UPUE}

Deployment for vCU
    log to console  \n Case Precondition deploy vCU and onair
    vCU Cluster Login With Admin
    ${workspace}    Create Workspace
    set test variable   ${workspace}
    ${kuafu_dir}    vCU Get Kuafu   workspace_dir=${workspace}  kuafu_version=master   config_file=${NEW_KUAFU_FILE}
    set test variable   ${kuafu_dir}
    run keywords     VCU Undeployment By Kuafu   ${kuafu_dir}
        ...   AND   VCU Onboard By Kuafu    ${kuafu_dir}    build_version=${VCU_VERSION}
        ...   AND   VCU deployment By Kuafu     ${kuafu_dir}    chart_name=${G_VCU_NAME}
        ...   AND   VCU Load And Active SCF By Kuafu    ${kuafu_dir}    ${SCF_FILE}
    [Teardown]    helm.helm_master_close

Uncommissioned Deployment for VCU
    log to console  \n Case Precondition deploy vCU
    vCU Cluster Login With Admin
    ${workspace}    Create Workspace
    set test variable   ${workspace}
    ${kuafu_dir}    vCU Get Kuafu   workspace_dir=${workspace}  kuafu_version=master   config_file=${NEW_KUAFU_FILE}
    set test variable   ${kuafu_dir}
    run keywords     VCU Undeployment By Kuafu   ${kuafu_dir}
        ...   AND   VCU Onboard By Kuafu    ${kuafu_dir}    build_version=${VCU_VERSION}
        ...   AND   VCU deployment By Kuafu     ${kuafu_dir}    chart_name=${G_VCU_NAME}
    [Teardown]    helm.helm_master_close

Delete KUAFU
    log to console  Remove KUAFU
    vCU Cluster Login With Admin
    tafssh.Execute    command=cd /home/${G_USER}/; rm -rf TA_Workspace-${CLUSTER_NAME}
    [Teardown]    helm.helm_master_close

Step1 Uninstall old version
    log to console  Step1:Uninstall old version
    vCU Cluster Login With Admin
    ${vcu_release_name}=     tafssh.Execute
    ...     command=helm list -n ${CLUSTER_NAME} |grep 'aic-vcu-cnf-0.250'|awk '{print $1}'|tr -d '\r\n'
    tafssh.Execute    command=helm uninstall ${vcu_release_name} -n ${CLUSTER_NAME}
    Wait Until Keyword Succeeds     10x  15s     Check vCU pod empty   ${CLUSTER_NAME}
    [Teardown]    helm.helm_master_close

Step2 Install new version
    log to console  Step2:Install new version
    vCU Cluster Login With Admin
    ${install_dir}    set variable    ${new_kuafu_dir}/charts/vcu/aic-vcu-${VCU_NEW_VERSION}/aic-vcu-cnf/
    tafssh.Execute    command=cd ${install_dir};helm install ${G_VCU_NAME} ./ -f values-override.yaml -n ${CLUSTER_NAME} --timeout 10m
    Wait Until Keyword Succeeds    15min  30s    check healing controller status
    [Teardown]    helm.helm_master_close

Step3 Check Upgrade Status
    log to console  Step3: Check Upgrade Status
    Check sw version    ${VCU_NEW_VERSION}
#    Check migration status
#    Check cell status
#    Check alarm

Step4 Rollback to old version
    log to console  Step4: Rollback to old version
    vCU Cluster Login With Admin
    ${vcu_release_name}=     tafssh.Execute    command=helm list -n ${CLUSTER_NAME} |grep 'cnf-0.250'|awk '{print $1}'|tr -d '\r\n'
    tafssh.Execute    command=helm uninstall ${vcu_release_name} -n ${CLUSTER_NAME}
    Wait Until Keyword Succeeds     10x  15s     Check vCU pod empty   ${CLUSTER_NAME}
    ${install_dir}    set variable    ${old_kuafu_dir}/charts/vcu/aic-vcu-${vCU_OLD_VERSION}/aic-vcu-cnf/
    tafssh.Execute    command=cd ${install_dir};helm install ${G_VCU_NAME} ./ -f values-override.yaml -n ${CLUSTER_NAME} --timeout 10m
    vDU SSH Login
    wait until keyword succeeds   10min   1min  Check RF Power By Kuafu   ${vdu_kuafu_dir}
    [Teardown]    helm.helm_master_close

Step5 Check Rollback Status
    log to console  Step5: Check Rollback Status
    Check sw version    ${VCU_OLD_VERSION}
    Check migration status
    Check cell status
    Check alarm

Check sw version
    [Arguments]    ${except_version}
    log to console  Check sw version
    vCU Rest Login
    ${sw_version}   Get VDU Parameter Value Online      MRBTS-${MRBTS_ID}/MNL-1/MNL_R-1      activeSWReleaseVersion
    should contain   ${sw_version}  ${except_version}
    log to console  sw version is correct
    [Teardown]  vCU Rest Logout

Check migration status
    log to console  Check migration status
    vCU Cluster Login With Admin
    Collect vCU Container Logs   ${VCU_OAMCM_PODS_NAME}    ctr-${CLUSTER_NAME}-oamcm    log_path=/home/${G_USER}/TA_Workspace
    ${status} =   tafssh.execute
    ...     cat /home/${G_USER}/TA_Workspace/${G_VCU_NAME}.ctr-${CLUSTER_NAME}-oamcm.log | grep 'migration'
    should contain    ${status}   Migration success after restart
    [Teardown]    helm.helm_master_close

Check cell status
    log to console  Check cell status
    vDU SSH Login
    wait until keyword succeeds   10min   1min  Check RF Power By Kuafu   ${vdu_kuafu_dir}
    log to console   cell onair
    [Teardown]    helm.helm_master_close

Check alarm
    log to console  Check alarm
    Login vCU Webem
    ${output_alarms}=  Get Vcu Active Alarm Fault
    log to console    alarm=@{output_alarms}
    should not contain   ${output_alarms}    fault_id
    log to console    no active alarm
    [Teardown]      coam_cu.disconnect

Prepare New Version
    log to console  \n ***Prepare New Version***
    VCU Onboard By Kuafu        ${new_kuafu_dir}    ${VCU_NEW_VERSION}
    VCU deployment By Kuafu     ${new_kuafu_dir}    ${G_VCU_NAME}
    VCU Undeployment By Kuafu   ${new_kuafu_dir}

Install Old Version
    log to console  \n ***Install Old Version***
    ${old_kuafu_dir}    vCU Get Kuafu   workspace_dir=${workspace}  kuafu_version=${OLD_KUAFU_VERSION}   config_file=${OLD_KUAFU_FILE}
    set test variable   ${old_kuafu_dir}
    VCU Onboard By Kuafu        ${old_kuafu_dir}    ${vCU_OLD_VERSION}
    VCU deployment By Kuafu     ${old_kuafu_dir}    ${G_VCU_NAME}
    VCU Load And Active SCF By Kuafu    ${old_kuafu_dir}    ${SCF_FILE}
