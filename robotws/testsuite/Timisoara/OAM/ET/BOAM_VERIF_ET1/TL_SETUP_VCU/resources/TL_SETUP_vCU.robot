*** Settings ***

Library        String
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME    taf_ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium
#Library        taf.sw.ping      WITH NAME   taf_ping
Library        DateTime

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/get_build_wft.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/faults.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ./keyword.robot
Resource   ../../vduResourcesAIC/aic_vdu_deployment.robot



*** Variables ***
${G_VCU_NAME}         ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${CLUSTER_NAME}       ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
${VCU_OAMCM_PODS_NAME}    po-${CLUSTER_NAME}-oamcm-0
${VDU_OAMFH_PODS_NAME}    po-${CLUSTER_NAME}-oamfh-0
${G_USER}             core

${NEW_KUAFU_FILE}     kuafu_vcu_config.ini
${MRBTS_ID}           ${tl.gnbs[0].instance_id}

${SCF_FILE}           master_CU_CNF.xml
${SCF_FILE_22R3}      vCUCNF22R3.xml


*** Keywords ***

TL_SETUP_Deployment_vCU

    Log to Console  vCU Deployement started
    Deployment for vCU
#    Step1 Uninstall old version
#    Step2 Install new version
#    Step3 Check Upgrade Status

TL_SETUP_Deployment_VCU_Uncommissioned

    Log to Console  VCU Deployement started
    Uncommissioned Deployment for VCU






