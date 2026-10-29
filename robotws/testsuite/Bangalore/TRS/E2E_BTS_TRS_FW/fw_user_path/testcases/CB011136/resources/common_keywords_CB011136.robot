*** Settings ***
Documentation
...     [Author]                    "Abeer Banu"
...     [Maintenance]               "TRS I&V Tools Bangalore Team"
...     [Date]                      "09:05:2024"
...     [QC_Path]                   "QC_Path in Test Plan"
...     [QC_ID]                     "QC_ID in Test Lab for reporting"
...     [Feature_ID]                "CB011136"
...     [Validated_TestLine]        "KVM_ST_LMP_TL1004"
...     [Procedure]                 "CB011136"
...     [Precondition]              "vDU"
...     [Config]                    "fronthaul firewall"
...     [Function_Hash_Tags]        "Firewall"


Resource        ${CURDIR}/../../resources/common_keywords.robot


***Keywords***
Login to RANNIC
    Setup Remote Access    remote_device=remote_device_1     alias=default
    Execute Interactive Remote Command          command=${root_login}            alias=default
    Execute Interactive Remote Command          command=${RANNIC_PASSWORD}       alias=default


Login to Switched RANNIC
    Setup Remote Access    remote_device=remote_device_2     alias=default
    Execute Interactive Remote Command          command=${root_login_splane}            alias=default
    Execute Interactive Remote Command          command=${RANNIC_PASSWORD}       alias=default



Find Duplicates
    [Arguments]    ${list_of_rules}
    ${seen}=    Create List
    ${duplicates}=    Create List
    FOR    ${rule}    IN    @{list_of_rules}
        ${rule}=    Strip String    ${rule}
        Run Keyword If    '${rule}' in ${seen}    Append To List    ${duplicates}    ${rule}
        Append To List    ${seen}    ${rule}
    END
    [Return]    ${duplicates}


Fetch Rules from RANNIC
        Login to RANNIC
        Execute Interactive Remote Command          command=${rules_command}         alias=default
        Execute Interactive Remote Command     command=chmod 777 /tmp/file2.txt      alias=default
        Setup Remote Access        remote_device=remote_device_1       alias=co1
        Execute Interactive Remote Command          command=sshpass -p Nokia@123 scp -P 51217 serviceuser@10.58.66.33:/tmp/file2.txt .
...     alias=co1
        ${rules}=   Remote Command Execute     command=cat /home/ute/file2.txt| cut -c 3-101| tail -20     alias=co1
        Log     ${rules}
        ${lines}=    Split String    ${rules}    \n
        [Return]        ${lines}


Fetch Splane Rules from RANNIC
        Login to Switched RANNIC
        Execute Interactive Remote Command          command=${rules_command}         alias=default
        Execute Interactive Remote Command     command=chmod 777 /tmp/file3.txt      alias=default
        Setup Remote Access        remote_device=remote_device_2       alias=co1
        Execute Interactive Remote Command          command=sshpass -p Nokia@123 scp -P 51217 serviceuser@10.63.83.211:/tmp/file3.txt .
...     alias=co1
        ${rules}=   Remote Command Execute     command=cat /home/ute/file3.txt| cut -c 3-101| tail -20     alias=co1
        Log     ${rules}
        ${lines}=    Split String    ${rules}    \n
        [Return]        ${lines}




Verify Rules
        Fetch Rules from RANNIC
        ${act_op}=   Remote Command Execute     command=sort /home/ute/file2.txt     alias=co1
        ${exp_op}=   Remote Command Execute     command=sort /home/ute/file1.txt     alias=co1
        Log        ${exp_op}
        Should Match        ${act_op}            ${exp_op}


Verify Splane Rules
        Fetch Splane Rules from RANNIC
        ${act_op}=   Remote Command Execute     command=sort /home/ute/file3.txt     alias=co1
        ${exp_op}=   Remote Command Execute     command=sort /home/ute/file4.txt     alias=co1
        Log        ${exp_op}
        Should Match        ${act_op}            ${exp_op}



Verify Duplicate Rules

        ${rules}=     Fetch Rules from RANNIC
        ${duplicates}=    Find Duplicates    ${rules}
        Should Be Empty    ${duplicates}

Verify Duplicate Splane Rules

        ${rules}=     Fetch Splane Rules from RANNIC
        ${duplicates}=    Find Duplicates    ${rules}
        Should Be Empty    ${duplicates}



Login_vDU
    Setup Oamops    dut=vdu_1        timeout=100      alias=default

Logout vDU
    Teardown Oamops    dut=vdu_1      timeout=100      alias=default

Reset Switched_vDU
    Login_Switched_vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_9857    alias=default    should_be_onair=${False}     verify_bts=${False}

Login_Switched_vDU
    Setup Oamops    dut=vdu_9857        timeout=100      alias=default

Logout Switched_vDU
    Teardown Oamops    dut=vdu_9857      timeout=100      alias=default


Reset vDU
    Login_vDU
    Reset    operation=reset_bts    rat=5g    dut=vdu_1    alias=default    should_be_onair=${False}     verify_bts=${False}


Load the basic scf
     Login_vDU
     Perform Commissioning    dut=vdu_1    scf_file=${basic_scf}     skip_parameter_relation_errors=${True}    timeout=300     alias=default

     Sleep   100
     Logout vDU


Change the service account password
    Login_vDU
    [Documentation]        This test case keyword is to change service account password
    Update Service Account Password      username=${RANNIC_USERNAME}       password=${RANNIC_PASSWORD}       new_password=${RANNIC_NEW_PASSWORD}
    ...         dut=vdu_1       alias=default
    ${RANNIC_PASSWORD}    Set Variable    ${RANNIC_NEW_PASSWORD}
    Set Suite Variable      ${RANNIC_PASSWORD}



Enable ssh access from rannic
    Login_vDU
    [Documentation]        This test case keyword is to activate the ssh tunnel
#    Config Ssh Tunnel      dist_name=${rannic_runtime_path}     operation=enable     timeout=500    dut=vdu_1    alias=default
#    Sleep     30
#    Logout vDU


Reset fhnftmgmt pod
       Setup Remote Access    remote_device=vdu_1.ocp     alias=default
       ${healing_pod}=           Execute Interactive Remote Command     command=${healing_controller}      alias=default
       ${get_healing_controller}=     Get Line    ${healing_pod}   -2
       Log     ${get_healing_controller}
       ${fhnftmgmt_pod}=         Execute Interactive Remote Command     command=${fhnftmgmt}      alias=default
       ${get_fhnftmgmt_pod}=     Get Line    ${fhnftmgmt_pod}   -2
       Log     ${get_fhnftmgmt_pod}
       Remote Command Execute     command=${reset_pod}     continue_on_failure=${False}     alias=default


Reset RANNIC
        Setup Oamops    dut=vdu_1        timeout=100      alias=default
        Reset    operation=reset_rannic     rannic_dn=${RANNIC_MOC}    dut=vdu_1    timeout=100    alias=default

Reset RANNIC and Verify Rules
        Reset RANNIC
#        Enable ssh access from rannic
        Change the service account password
        Enable ssh access from rannic
        Verify Rules
        Verify Duplicate Rules

Reset vDU and Verify Rules
        Reset vDU
#        Enable ssh access from rannic
        Change the service account password
        Enable ssh access from rannic
#       Login to RANNIC
        Verify Rules
        Verify Duplicate Rules

Reset fhnftmgmt pod and Verify Rules
        Reset fhnftmgmt pod
        Verify Rules
        Verify Duplicate Rules

Enable flag from NMS
    Setup Ems    config_device=netact1042    alias=lab42
    Cm Upload    config_device=netact1042    alias=lab42
    Configuration Manage    config_device=netact1042    config=enable_params.json    plan_name=enable_flag
    ...     delete_plan="True"   timeout=300   alias=lab42
    Teardown Ems    config_device=netact1042    alias=lab42
