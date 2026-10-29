*** Settings ***
Documentation     Author: yonna.yao@nokia-sbell.com
Force Tags    QCD_MN_RAN    QCP_RAN_ET
Resource          ../resources/KISS/robot/common_resource.robot   
Suite Setup    Common Suite Setup       
Suite Teardown    Common Suite Teardown    
Test Setup       Common Test Setup    
Test Teardown    Common Test Teardown


*** Variables ***
${SCF_PATH}         /home/ute/testline_init_results/configs/scfc.xml
${DELTA_PATH}       ./Delta_Conf.json  
${UE_ID}         1

*** Test Cases ***
Test_Full_Commissioning_And_Delta_Commission_And_Onair_Example
	${wts_cfg}     Get Colden Wts Config     ${SCF_PATH}     
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Delta Commission And Reach Onair    delta_json=${DELTA_PATH}      scfc=${SCF_PATH}      wts_config=${wts_cfg}     
	...    wait_onair_timeout=900

Test_Full_Commissioning_And_Onair_Example
	${wts_cfg}     Get Colden Wts Config     ${SCF_PATH}     
    Modify TL VM And AP SCTP Configuration
    Perform Full Commission And Reach Onair    scfc=${SCF_PATH}      wts_config=${wts_cfg}       
	...    wait_onair_timeout=900     reset_after_commission=True
    

*** Keywords ***
Get Colden Wts Config
    [Arguments]    ${scfc}   
    Download All Common Config Files From Golden Server	
    Find Match WTS CFG Files And Copy To WorkSpace    ${scfc}
	[Return]    ${WTS_CFG_FULL_PATH}
