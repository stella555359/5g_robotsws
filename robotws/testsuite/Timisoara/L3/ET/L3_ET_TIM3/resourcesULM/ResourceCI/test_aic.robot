*** Settings ***
#
Documentation   testsuite for AiC gNB KWs
#
#Resource        ../aic_cu.robot
#Resource        ../aic_vdu.robot
#Resource        ../testline.robot
#Resource        ../gnb.robot
#Resource        ../aic_cu_commissioning.robot
#Resource        ../aic_vdu_commissioning.robot
#Resource        ../ute_workarounds.robot
#
#
#Suite Setup     Set Skip Tag If Not AiC TL
#
#*** Test Cases ***
#Test Patch testline configuration for UTE Cloud
#    [TAGS]              AIC   UTEWA
#    Patch testline configuration for UTE Cloud
#
#Test Get Node Deployment Type for AiC
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    ${gnb_type}     Get Node Deployment Type
#    Log To Console  \ngnb_type: '${gnb_type}'
#    should be equal as strings  ${gnb_type}  aic
#
#Test Get Pods Info
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Get Pods Info
#
#Test Get DU Cell Summary
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Get DU Cell Summary
#
#Test Get DU SW Version
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Get DU SW Version
#
#Test Get DU current plan file
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    ${result}=  Get DU current plan file
#    file should exist  ${result}
#
#Test Get CU SW Version
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Get CU SW Version
#
#Test Get CU current plan file
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    ${result}=  Get CU current plan file
#    file should exist  ${result}
#
#Test Get gNB SW Version
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    ${result}=  Get gNB SW Version
#    Log To Console  ${result}
#
#Test Get SCF from Gnb DU
#    [TAGS]              AIC
#    ${result}=  gnb.Get SCF from gNB
#    file should exist  ${result}
#
#Test Get SCF from Gnb CU
#    [TAGS]              AIC
#    ${result}=  gnb.Get SCF from gNB  component=CU
#    file should exist  ${result}
#
#Test Get distNames from gNB DU
#    [TAGS]              AIC
#    ${distnames}=   Get distNames from gNB DU   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
#    Should Not Be Empty     ${distnames}
#
#Test Get distNames from AiC CU
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    ${distnames}=   Get distNames from AiC CU   regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+
#    Should Not Be Empty     ${distnames}
#
#Test Get distNames from Local SCF File
#    [TAGS]              AIC
#    ${distnames}=  Get distNames from Local SCF File  regex=MRBTS-[0-9]+/EQM-[0-9]+  scf_path=${DU_SCF}
#    Should Not Be Empty     ${distnames}
#    ${distnames}=  Get distNames from Local SCF File  regex=MRBTS-[0-9]+/NRBTS-[0-9]+/NRDRB_PDCP-[0-9]+  scf_path=${CU_SCF}
#    Should Not Be Empty     ${distnames}
#    Run Keyword And Expect Error  *FileNotFoundError*  Get distNames from Local SCF File
#    ...     regex=MRBTS-[0-9]+  scf_path=dummy
#
#Test Bring Airphone TL to on Air status
#    Bring Airphone TL to on Air status    kw_timeout=30min
#
#Test Commission vDU
#    [TAGS]              AIC   COMM
#    Skip If Not AiC TL
#    ${param_list_DU}=  Create vDU delta commissioning parameter structure
#    Execute Delta Commissioning for Aic vDU    delta_plan_name=MY_PLAN   param_list_DU=${param_list_DU}   gnb_id=0    du_id=0
#    ${scf_file}=    Get DU current plan file                gnb_id=0  du_id=0
#    Check If Commissioning Is Needed                        param_list=${param_list_DU}    scf_file=${scf_file}
#    Run Keyword If  ${P_COMISSIONING_REQUIRED}  Fail
#
#Test Commission CU
#    [TAGS]              AIC   COMM
#    Skip If Not AiC TL
#    ${param_list_CU}=  Create CU delta commissioning parameter structure
#    Execute Delta Commissioning for Aic CU    delta_plan_name=MY_PLAN   param_list_CU=${param_list_CU}   gnb_id=0
#    ${scf_file}=    Get CU current plan file                gnb_id=0
#    Check If Commissioning Is Needed                        param_list=${param_list_CU}    scf_file=${scf_file}
#    Run Keyword If  ${P_COMISSIONING_REQUIRED}  Fail
#
#Test Operational State of VDU should be on Air
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Operational State of VDU should be on Air
#
#Test Wait until All VDU are onAir
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Wait until VDU is onAir     gnb_id=${0}  timeout=20s
#
#Test Wait until VDU is ready
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Wait until VDU is ready
#
#Test Wait until All VDU are ready
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    Wait until All VDU are ready
#
#Test delta Commissioning for Aic vDU with json
#    [TAGS]              AIC   COMM
#    Skip If Not AiC TL
#    Execute Delta Commissioning for Aic vDU with json       delta_plan_name=MY_PLAN  json_delta_file=./delta_scf_vdu.json  gnb_id=0  du_id=0
#    ${scf_file}=    Get DU current plan file                gnb_id=0  du_id=0
#
#Test delta Commissioning for Aic CU with json
#    [TAGS]              AIC   COMM
#    Skip If Not AiC TL
#    Execute Delta Commissioning for Aic CU with json        delta_plan_name=MY_PLAN  json_delta_file=./delta_scf_vcu.json  gnb_id=0
#    ${scf_file}=    Get CU current plan file                gnb_id=0
#
#Test Get gNB Physical Cell ID From AiC
#    [TAGS]              AIC
#    Skip If Not AiC TL
#    ${nr_cells}=    Get gNB Physical Cell ID
#    Should Not Be Empty     ${nr_cells}
#
#Test Commission Managed Object List for Aic CU
#    [TAGS]              AIC   COMM
#    Skip If Not AiC TL
#    ${btsName}=  Create Dictionary  parameterName=btsName  value=vCU_MNGD  operation=update
#    ${btsName_params}=  Create List  ${btsName}
#    ${btsName_1}=  Create Dictionary  distName=MRBTS-1  operation=update  parameters=${btsName_params}
#    ${managed_objects}=  Create List  ${btsName_1}
#    Commission Managed Object List for Aic CU  ${managed_objects}
#
#Test Commission Managed Object List for Aic vDU
#    [TAGS]              AIC   COMM
#    Skip If Not AiC TL
#    ${rlpDetDlHarqThreshold}=  Create Dictionary  parameterName=rlpDetDlHarqThreshold  value=33  operation=update
#    ${rlpRecDlHarqThreshold}=  Create Dictionary  parameterName=rlpRecDlHarqThreshold  value=7  operation=update
#    ${rlpDetCsiBsiThreshold}=  Create Dictionary  parameterName=rlpDetCsiBsiThreshold  value=73  operation=update
#    ${rlpRecCsiBsiThreshold}=  Create Dictionary  parameterName=rlpRecCsiBsiThreshold  value=3  operation=update
#    ${rlpThreshold_params}=  Create List  ${rlpDetDlHarqThreshold}  ${rlpRecDlHarqThreshold}  ${rlpDetCsiBsiThreshold}  ${rlpRecCsiBsiThreshold}
#    ${rlpThreshold_1}=  Create Dictionary  distName=MRBTS-1/NRBTS-1/NRCELL-1  operation=update  parameters=${rlpThreshold_params}
#    ${managed_objects}=  Create List  ${rlpThreshold_1}
#    Commission Managed Object List for Aic vDU  ${managed_objects}
#
#
#*** Keywords ***
#Set Skip Tag If Not AiC TL
#    Run Keyword If   '${tl_info.deployment_type()}'!='aic'  Run Keywords
#    ...         Log To Console  Test suite isn't applicable for '${tl_info.deployment_type()}' !
#    ...   AND   Set TAGS    SKIP
#    ${DU_SCF}=  gnb.Get SCF from gNB
#    Set Suite Variable  ${DU_SCF}
#    ${CU_SCF}=  gnb.Get SCF from gNB  component=CU
#    Set Suite Variable  ${CU_SCF}
#
#Skip If Not AiC TL
#    Pass Execution If   'SKIP' in @{TEST TAGS}  Test is only applicable for AiC!
#
#Create vDU delta commissioning parameter structure
#    ${param1}=    Create Dictionary  value=35        dist_name=MRBTS-1/NRBTS-1/NRCELL-1  p_name=rlpDetDlHarqThreshold
#    ${param2}=    Create Dictionary  value=5         dist_name=MRBTS-1/NRBTS-1/NRCELL-1  p_name=rlpRecDlHarqThreshold
#    ${param3}=    Create Dictionary  value=5         dist_name=MRBTS-1/NRBTS-1/NRCELL-1  p_name=rlpDetCsiBsiThreshold
#    ${param4}=    Create Dictionary  value=2         dist_name=MRBTS-1/NRBTS-1/NRCELL-1  p_name=rlpRecCsiBsiThreshold
#    ${param5}=    Create Dictionary  value=vDU2_BLR  dist_name=MRBTS-1                   p_name=btsName
#    ${param_list_DU}=  Create list  ${param1}  ${param2}  ${param3}  ${param4}  ${param5}
#    [Return]   ${param_list_DU}
#
#Create CU delta commissioning parameter structure
#    ${param1}=  create dictionary  value=vCU2_KRK   dist_name=MRBTS-1                          p_name=btsName
#    ${param2}=  create dictionary  value=15min      dist_name=MRBTS-1/MNL-1/MNLENT-1/PMCADM-1  p_name=reportingIntervalPm
#    ${param3}=  create dictionary  value=15min      dist_name=MRBTS-1/NRBTS-1/NRPMRNL-1        p_name=miNrRacCu
#    ${param_list_CU}=  Create list  ${param1}  ${param2}  ${param3}
#    [Return]   ${param_list_CU}
