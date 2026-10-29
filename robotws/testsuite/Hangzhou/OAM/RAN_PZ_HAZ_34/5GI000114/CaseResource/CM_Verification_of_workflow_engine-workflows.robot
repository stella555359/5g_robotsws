*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

Library    DateTime
*** Variables ***


*** Keywords ***
CM_Verification_of_workflow_engine-workflows
    NetAct CM Operation remove gNB Module
    Run Keyword And Ignore Error   selenium_netact.Logout
    Integrating NE to NetAct

Case Setup: CM_Verification_of_workflow_engine-workflows
    Open Netact Start Page   url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${false}
    Remove File    path=${WEB_DOWNLOAD_DIR}/*.jnlp

Case Teardown: CM_Verification_of_workflow_engine-workflows
    #Run Keyword And Ignore Error   Close Java Application by Remote Port   remote_port=${remote_port}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
