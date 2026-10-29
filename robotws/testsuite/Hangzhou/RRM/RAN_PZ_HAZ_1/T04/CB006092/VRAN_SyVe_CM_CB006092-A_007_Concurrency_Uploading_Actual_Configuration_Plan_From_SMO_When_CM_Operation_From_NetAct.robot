*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for NFTA
...   RAN_ST_CB006092-A_007_CM_Concurrency uploading actual configuration plan from SMO when CM operation from NetAct
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-A_007_Concurrency_Uploading_Actual_Configuration_Plan_From_SMO_When_CM_Operation_From_NetAct
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.06.2025, yuyan.xu@nokia-sbell.com
    Step 1: Create Plan SyVe For Cell Reset
    Step 2: Concurrency Upload Configuration From SMO When Provision Delta Plan From NetAct

Step ${index}: Create Plan SyVe For Cell Reset
    Log To Console    Step ${index}: Create Plan SyVe For Cell Reset
    ${plan_info_reset}    Create Dictionary    scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-0
    ...    parameter_name=actCceSplit    value1=true    value2=false
    vDU Login By Rest
    ${origin_value}    Get Parameter Value From vDU    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set}    Set Variable If    "${origin_value}"=="${plan_info_reset['value2']}"
    ...    ${plan_info_reset['value1']}    ${plan_info_reset['value2']}
    Set Test Variable    ${value_to_set}
    Set To Dictionary    ${plan_info_reset}    value=${value_to_set}

    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_reset['parameter_name']}=${plan_info_reset['value']}
    ${mo_params}    Create Dictionary    ${plan_info_reset['scf_distName']}=${params}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Concurrency Upload Configuration From SMO When Provision Delta Plan From NetAct
    Log To Console    Step ${index}: Concurrency Upload Configuration From SMO When Provision Delta Plan From NetAct
    ${time}    Get Time    epoch
    ${onap_get_file}    Set Variable    ${TEST_LOG_DIRECTORY}/onap_get_config_${time}.xml
    ${cmd}    Set Variable    get-config --source running --out /tmp/onap_get_config_${time}.xml

    SSHLibrary.Open Connection    ${NETACT['was_host']}    alias=provision
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${cmdstr1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vDU_id} -createBackupPlan true -backupPlanName
    ${cmdstr2}    Set Variable    ${plan_name}_backup -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command     ${cmdstr1} ${cmdstr2}

    ${ret}    Execute NetConf Command On ONAP Simulator    MRBTS-${vDU_id}    ${host_ip}    ${user}    ${pwd}    ${cmd}
    SSHLibrary.Switch Connection    provision
    ${result_Activate}    SSHLibrary.Read Command Output
    Log    ${result_Activate}    #Provision of the plan was successful
    Get File From Simulator To Local    ${host_ip}    ${user}    ${pwd}    onap_get_config_${time}.xml    ${onap_get_file}
    Log   ${onap_get_file}


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    #need develop kw
    #Run Keyword If    ${Integrate_Need}    Integrate SBTS To ONAP Simulator    ${MRBTS_ID}    ${ONAP['host_ip']}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Teardown NetAct