*** Settings ***
Documentation
...     [Author]                    "Shreya Choudhary"
...	    [Maintenance]		        "TRS I&V Tools Bangalore Team"
...     [Date]                      "25-07-2023"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...	    [Feature_ID] 	    	    "CB008737"
...     [Validated_TestLine]        "IAV-BLR-TL004"
...	    [Procedure]   		        "CB008737_B_01_Feature_activation_and_deactivation_the_serviceability_of_all_RAN_NIC_devices_connected_to_vDU"
...     [Precondition]              "Service user password should be set for the first time & VDU should be up and running with all the pods"
...     [Config_Comments]           "Verification of service user functionality in VDU"
...     [Domain]                    "Cloud TL"
...     [Function_Hash_Tags]        "VDU"

Resource        ${CURDIR}/../../resources/common_keywords.robot
Resource        ${CURDIR}/../../resources/Admin_Common_Library.robot


*** Keywords ***
Enable the feature flag with moc modification and verification
    [Documentation]        This test case keyword is to perform delta commissioning with verification of changes
    Perform Recommissioning    type=delta      delta_file=${CB008737_enable_feature}     skip_parameter_relation_errors=${True}
    ...     timeout=300     dut=cbts    alias=vdu
    Sleep     30
    ${result1}=     Get Parameter     param_path=${secadm_query1}      dut=cbts     alias=vdu
    Should Be Equal    ${result1}    ${sshSessionIdleTimer}
    ${result2}=     Get Parameter     param_path=${secadm_query3}      dut=cbts     alias=vdu
    Should Be Equal    ${result2}    ${platLoginBannerText}


Enable the feature flag
    [Documentation]        This test case keyword is to perform delta commissioning
    Perform Recommissioning    type=delta      delta_file=${CB008737_enable_feature}     skip_parameter_relation_errors=${True}
    ...     timeout=300     dut=cbts    alias=vdu
    Sleep    30


Disable the feature flag
    [Documentation]        This test case keyword is to perform delta commissioning
    Perform Recommissioning    type=delta      delta_file=${CB008737_disable_feature}     skip_parameter_relation_errors=${True}
    ...     timeout=300     dut=cbts    alias=vdu
    Sleep     30


Change the service account password
   [Documentation]        This test case keyword is to change service account password
   [Arguments]			${VDU_USERNAME}		${VDU_PASSWORD}			${VDU_NEW_PASSWORD}
   Update Service Account Password      username=${VDU_USERNAME}       password=${VDU_PASSWORD}       new_password=${VDU_NEW_PASSWORD}
   ...         dut=cbts       alias=vdu
   ${VDU_PASSWORD}    Set Variable    ${VDU_NEW_PASSWORD}
   Set Suite Variable      ${VDU_PASSWORD}
   Sleep     100


Enable ssh tunnel
    [Documentation]        This test case keyword is to activate the ssh tunnel
    Trigger Serviceuser Sync      sync_type=L1      timeout=30     dut=cbts    alias=vdu
    Sleep     30
    Config Ssh Tunnel      dist_name=${tunnel_dist}     operation=enable     timeout=100    dut=cbts    alias=vdu
    Sleep     30


Check the tunnel state
   [Documentation]        This test case keyword is to verify the ssh tunnel state
   ${state}=   Get Ssh Tunnel Config     ssh_mode_type=RNICMOD     timeout=30      dut=cbts     alias=vdu
   ${tunnel_details}=     Get From Dictionary      ${state}      details
   Should Be Empty     ${tunnel_details}


Check the session created
    [Documentation]        This test case keyword is to check the session
    ${session}=    Get Sessions List      dut=cbts     alias=vdu     timeout=100
    ${latest}     Get From List    ${session}    0
    ${session_id}     Get From Dictionary     ${latest}     session_id
    Log     ${session_id}


Perform vdu reset
    [Documentation]        This test case keyword is to reset the vdu
    Reset     operation=reset_bts     dut=cbts     alias=vdu      verify_bts=False     should_be_onair=False     timeout=600
    Sleep     30


Login into the device
    [Documentation]       This test case keyword is to login in the device
    Setup Oamops    dut=cbts    alias=vdu
    Sleep     30


SSH login to service user
    [Documentation]        This test case keyword is to login into service user account via ssh
    Setup Remote Access     remote_device=user    timeout=30     alias=default
    ${value}=    Remote Command Execute       command=cat /log_lock.pid
    Set Suite Variable     ${value}
    Teardown Remote Access     alias=default
    Log    ${value}


Verify the feature parameter
    [Documentation]        This test case keyword is to verify parameter change via ssh login
    Setup Remote Access      remote_device=user      alias=session
    ${stdout1}=    Remote Command Execute       command=cat /etc/ssh/sshd_config | grep -i "ClientAliveInterval"    alias=session
    ${stdout2}=    Remote Command Execute       command=cat /etc/ssh/sshd_config | grep -i "ClientAliveCountMax"    alias=session
    ${stdout3}=    Remote Command Execute       command=cat /etc/pam.d/common-auth | grep -i "delay"    alias=session
    ${value1}=    Extract value from text    ${stdout1}
    ${value2}=    Extract value from text    ${stdout2}
    ${value3}=    Extract value from text    ${stdout3}
    ${result}=    Evaluate    int(${value1}) * int(${value2})
    Set Suite Variable		${result}
    Set Suite Variable		${value3}
    Teardown Remote Access      alias=session
    ${param1}=     Get Parameter     param_path=${secadm_query4}      dut=cbts     alias=vdu
    ${web_param1}=     Evaluate    int(${param1}) * int(60)
    Should Be Equal    ${result}    ${web_param1}
    ${param2}=     Get Parameter     param_path=${secadm_query2}      dut=cbts     alias=vdu
    ${web_param2}=     Evaluate    int(${param2}) * int(1000000)
    Should Be Equal    ${value3}    ${web_param2}


Extract value from text
    [Documentation]        This test case keyword is to extract the value from a string
    [Arguments]      ${text}
    ${split_text}    Split String    ${text}    ${SPACE}
    ${value}    Get From List    ${split_text}    -1
    RETURN    ${value}


Enable ssh tunnel with true state
    [Documentation]        This test case keyword is to enable the ssh tunnel with true flag
    Trigger Serviceuser Sync      sync_type=L1      timeout=30     dut=cbts    alias=vdu
    Sleep     30
    Config Ssh Tunnel      dist_name=${tunnel_dist}     operation=enable     timeout=100    dut=cbts    alias=vdu
    Sleep     30
    Get Ssh Tunnel Config     ssh_mode_type=RNICMOD     timeout=30     dut=cbts    alias=vdu


Enable ssh tunnel with false state
    [Documentation]        This test case keyword is to enable the ssh tunnel with false flag
    Run Keyword And Expect Error     *the feature flag is disabled*       Trigger Serviceuser Sync      sync_type=L1
    ...      timeout=30     dut=cbts    alias=vdu
    Sleep     30
    Run Keyword And Expect Error     *SSH feature flag is configured as FALSE*     Config Ssh Tunnel
    ...      dist_name=${tunnel_dist}     operation=enable     timeout=100    dut=cbts    alias=vdu
    Sleep     30


Get serviceuser session list and operation history
    [Documentation]        This test case keyword is to verify serviceuser and operation details
    Get Serviceuser Info       dut=cbts     alias=vdu     timeout=30
    Get Sessions List      dut=cbts     alias=vdu     timeout=100
    ${operation}=   Get Cu Operation History        dut=cbts       alias=vdu      timeout=100
    ${latest}     Get From List    ${operation}    0
    ${ssh_tunnel_config}     Get From Dictionary     ${latest}     targets
    Should Contain       ${ssh_tunnel_config}       ${operation_status}

