*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot


*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_path}      /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SyVe_SEC_ECDSA_CMP_Config.xml
${add_cert_source_path}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/cert.txt
${add_cert_target_name}    cert5999addtional.pem
# Absolute path to commissioning file
${COMMISSIONING_PATH}    /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/commissioning/SCF_01_SBTS18.xml
${COMMISSIONING_TIMEOUT}    600    # Timeout for commissioning procedure (scf upload, reset indication, wait for reconnection after reset)
${SKIP_PARAM_RELATION_ERRORS}    True    # Should relation errors be skipped (True, False)

*** Keywords ***
SyVe_SEC_CB005999_Add_Delete_ECDSA_AdditionalCA_with_RSA_TLS
    [Documentation]    Test for performing CB005999 ECDSA certificate config, init, add and remove under TLS mode.
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    TLS should be configured as precondtion
    ...    The main steps performed for the test are:
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Import the plan SyVe
    ...    - Provision Plan To Config CMP
    ...    - Check modified parameter in Netact after provision plan
    ...    - Initial CMP for ECDSA
    ...    - Install Addtional Certificate
    ...    - Remove Addtional Certificate
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: ECDSA certificate config, init, add and remove success under RSA TLS mode.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.08.2022 - New added for CB005999
    Set Tags    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-lixkang@nokia-sbell.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Import the plan SyVe
    Step 6: Provision Plan To Config CMP
    Step 7: Check modified parameter in Netact after provision plan
    Step 8: Initial CMP for ECDSA
    Step 9: Install Addtional Certificate
    Step 10: Remove Addtional Certificate
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Check final BTS state
    Step 14: Check final number and state of Cells and RMs

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Import the plan SyVe
    Log    Step ${index}: Import the plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${mrbts_id}
    ${file_name}    Fetch From Right    ${plan_path}    /
    ${file_path}    Remove String    ${plan_path}    /${file_name}
    NetAct Import Plan    local_dir=${file_path}    file_name=${file_name}    plan_name=${name}

Step ${index}: Provision Plan To Config CMP
    Log    Step ${index}: Provision Plan To Config CMP    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    ${plan_info}    Get TestData From XML
    ${dist_names}    Get Dictionary Keys    ${plan_info}
    FOR    ${dist_name}    IN    @{dist_names}
         NetAct Check Actual Configuration Parameters    dist_name=${dist_name}    ui_values=false    &{plan_info['${dist_name}']}
    END

Step ${index}: Initial CMP for ECDSA
    Log    Step ${index}: Initial CMP    console=True
    ${expected_msg}    Create List    Status: Success   Starting operation cmpInit on the NE
    ...    CMP Initialize operation was successful    The given request is successfully completed
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Manage CMP via NECertMgmt Command Line    cmpInit    ${MRBTS_DN}    ECDSA     @{expected_msg}
    SSHLibrary.Close Connection

Step ${index}: Install Addtional Certificate
    Log To Console    Step ${index}: Install Addtional Certificate
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Upload Certificate File to NetAct    ${add_cert_source_path}    /home/omc/    ${add_cert_target_name}
    ${fingerprint}    Install Addtional Certificates from File via NECertMgmt Command Line    ${MRBTS_DN}
    ...    /home/omc/${add_cert_target_name}
    Set Test Variable    ${fingerprint}
    SSHLibrary.Close Connection

Step ${index}: Remove Addtional Certificate
    Log To Console    Step ${index}: Remove Addtional Certificate
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Remove Addtional Certificates via NECertMgmt Command Line    ${MRBTS_DN}    ${fingerprint}
    SSHLibrary.Close Connection

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Config Certification via NECertMgmt Command Line
    [Arguments]     ${fqdn}    ${serverType}    ${preSharedKey}    ${refNum}
    ${expected_msg}    Create List    Status: Success    Starting operation cmpConfig on the NE
    ...    Provision of the plan was successful    The given request is successfully completed
    ${necertmgmt_cmd}    Set Variable   /opt/nokia/oss/bin/NECertMgmt.sh --operation cmpConfig --fqdnType NE
    SSHLibrary.Start Command    ${necertmgmt_cmd} --fqdn ${fqdn} --serverType ${serverType} --preSharedKey '${preSharedKey}' --refNum "${refNum}"
    ${output}    SSHLibrary.Read Command Output
    FOR    ${msg}    IN    @{expected_msg}
        Should Contain    ${output}    ${msg}
    END

Manage CMP via NECertMgmt Command Line
    [Arguments]     ${operationType}    ${fqdn}    ${serverType}    @{expected_msg}
    SSHLibrary.Start Command    /opt/nokia/oss/bin/NECertMgmt.sh --operation ${operationType} --fqdnType NE --fqdn ${fqdn} --serverType ${serverType}
    ${output}    SSHLibrary.Read Command Output
    FOR    ${msg}    IN    @{expected_msg}
        Should Contain    ${output}    ${msg}
    END

Recovery SBTS Certificates Via Configuration Reset
    Log To Console    Starting Configuration Reset
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    SBTS Admin Reset Configuration AirScale    remove_operator_certificates=${True}    reset_type=Configuration
    Log To Console    Starting full commisssioning
    coam.Perform Commissioning    ${mrbts_id}    ${COMMISSIONING_PATH}    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}
    ...    timeout=${COMMISSIONING_TIMEOUT}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Upload Certificate File to NetAct
    [Arguments]     ${source_path}    ${target_path}    ${filename}
    SSHLibrary.Start Command    rm -rf *.pem
    SSHLibrary.Put File    ${source_path}    ${target_path}/${filename}
    SSHLibrary.Start Command     ls | grep cert
    ${output}    SSHLibrary.Read Command Output
    Should Contain    ${output}    ${filename}

Install Addtional Certificates from File via NECertMgmt Command Line
    [Arguments]     ${fqdn}    ${certificateFilePath}=/home/omc/cert5999.pem
    ${expected_msg}    Create List    Status: Success    Starting operation addCACert on the NE
    ...    Provision of the plan was successful    There were 1 successful and 0 failed object
    ...    The given request is successfully completed
    ${necertmgmt_cmd}    Set Variable   /opt/nokia/oss/bin/NECertMgmt.sh
    SSHLibrary.Start Command    ${necertmgmt_cmd} --operation addCACert --fqdnType NE --fqdn ${fqdn} --certificateFile ${certificateFilePath}
    ${output}    SSHLibrary.Read Command Output
    FOR    ${msg}    IN    @{expected_msg}
        Should Contain    ${output}    ${msg}
    END
    ${match}    ${key}    ${fingerprint}    Should Match Regexp    ${output}    (fingerPrint): (\\w+)
    [Return]     ${fingerprint}

Remove Addtional Certificates via NECertMgmt Command Line
    [Arguments]     ${fqdn}    ${fingerprint}
    ${expected_msg}    Create List    Status: Success    Starting operation removeCACert on the NE
    ...    Provision of the plan was successful    There were 1 successful and 0 failed object
    ...    The given request is successfully completed
    SSHLibrary.Start Command    /opt/nokia/oss/bin/NECertMgmt.sh --operation removeCACert --fqdnType NE --fqdn ${fqdn} --fingerPrint ${fingerprint}
    ${output}    SSHLibrary.Read Command Output
    FOR    ${msg}    IN    @{expected_msg}
        Should Contain    ${output}    ${msg}
    END

Get TestData From XML
    ${plan_xml}    XML.Parse Xml    ${plan_path}
    ${objects}    XML.Get Elements    ${plan_xml}    .//managedObject
    ${testdata}    Create Dictionary
    FOR    ${obj}    IN    @{objects}
        ${dn}    XML.Get Element Attribute    ${obj}    distName
        ${p_objs}    XML.Get Elements    ${plan_xml}    .//managedObject[@distName="${dn}"]/p
        ${param_value_dict}    Generate Parameter Value Dic    ${p_objs}
        Set To Dictionary    ${testdata}    ${dn}=${param_value_dict}
    END
    [Return]    ${testdata}

Generate Parameter Value Dic
    [Arguments]     ${objs}
    ${param_value_dict}    Create Dictionary
    FOR    ${element}    IN    @{objs}
        ${key}    XML.Get Element Attribute    ${element}    name
        ${value}    XML.Get Element Text    ${element}
        Set To Dictionary    ${param_value_dict}    ${key}=${value}
    END
    [Return]    ${param_value_dict}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Recovery SBTS Certificates Via Configuration Reset
    SSHLibrary.Close All Connections
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown