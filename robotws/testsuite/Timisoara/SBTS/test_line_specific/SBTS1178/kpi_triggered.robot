*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  ${ENB_BRANCH}  SRAN  CLOUD_SRAN_LW_1ASIA_3ABIA_7FRGH_7FXCA
Library     XML  use_lxml=True

Suite Setup       Run keywords    Check Netboot variable  AND  Map BuildShareTimi01  AND  Map rotta server
Suite Teardown    Save kpi results

Resource    ../../KPI/test_resources/KPI__KPI_triggered_fault_handling.robot

Variables    targets.py

*** Variables ***
${SCF_ID}    01
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1178
${REF_FILE_PATH}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS1178/json/KPI_ref_file.json
${REFERENCE_CONFIGURATION_ID}    CNF_SRAN_MR10
${TIM_DIRECTORY_PATH_ON_ROTTA}   SBTS1Vrf/OAM_KPI/CRT
${MOVE_LOGS_ON_ROTTA}   ${TRUE}


*** Test Cases ***

[1][1.0]KPI__KPI_triggered_fault_handling
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}    
    ...    [['faultId', '4655', 'alarmId', '7220'], ['faultId', '4654', 'alarmId', '7220']]
    ...    AND    KPI__KPI_triggered_fault_handling.TC Setup
    ...    AND    Modify Resource Search Order    KPI__KPI_triggered_fault_handling
    TC__KPI__KPI_triggered_fault_handling
    [Teardown]    Run Keywords    KPI__KPI_triggered_fault_handling.TC Teardown
    ...    AND    Restore Resource Search Order
    ...    AND    Run keyword if  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE} CIT Recover Test Line By Power Reset
	

*** Keywords ***
Set additional ignored alarms variable
    ${ADDITIONAL_IGNORED_ALARMS}  Catenate  [['faultId', '4657', 'alarmId', '7100'], ['faultId', '4655', 'alarmId', '7220'], 
    ...                                     ['faultId', '61524', 'alarmId', '7220'], ['faultId', '61652', 'alarmId', '7220'], 
    ...                                     ['faultId', '4654', 'alarmId', '7220'], ['faultId', '61649', 'alarmId', '7220']]
    Set test variable  ${ADDITIONAL_IGNORED_ALARMS}
    
Map BuildShareTimi01
    Run  sudo mkdir -p /media/BuildShareTimi01
    Run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    Run  ${sh_command}
    Run  sudo mount -a