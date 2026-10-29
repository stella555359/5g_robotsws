*** Settings ***
Documentation    Keywords to perform varius operations with Mantaray NMS labs.
...              Author:    Klaudyna Piechocka
...              Contact:   klaudyna.piechocka@nokia.com

Resource      ../certificates/certificates.robot
Library     taf.nms.netact             WITH NAME    nms
Library     taf.sbts.oam.coam.admin    WITH NAME    admin
Library     Collections
Library     SSHLibrary
Library      ./mantaray.py
Library     taf.sw.graylog    WITH NAME    graylog
Library       ../admin/admin_utils.py

*** Variables ***
${MAX_LAB_RETRIES}     3
${NMS_USERNAME}        omc
${NMS_PASSWORD}        Medsql!_1893
${NMS_ROOT_USER}       root
${NMS_ROOT_PASS}       arthur
${PLAN_NAME}           single_plan
${PLAN_NAME_MULTI}     multi_plan
${SRNLAB_CA}           CN=srnblrna1
${SRNLAB_CA_IP}        10.96.129.254
${SRNLAB_CA_REFNUM}    56215
${SRNLAB_CA_PSK}       X2gd-4PJa-QLo2-rk9k
${CA_SERVER_PATH}      pkix
${CA_DEFAULT_PORT}     8080
${GRAYLOG_USER}=       admin
${GRAYLOG_PASS}=       adminpassword
&{TLS1_3_PARAMS_MANTARAY}      actEnableTLSv13=${TRUE}
...                            tls12Enabled=${FALSE}

&{TLS1_2_PARAMS_MANTARAY}      actEnableTLSv13=${FALSE}
...                            tls12Enabled=${TRUE}

&{TLS_VERSIONS_MANTARAY}       1_3=${TLS1_3_PARAMS_MANTARAY}
...                            1_2=${TLS1_2_PARAMS_MANTARAY}

&{siem_node}    srnclab1015=10.41.146.82
...             srnclab1025=10.41.148.33
...             srnclab1045=10.43.48.120
...             srnclab1046=10.43.48.169
...             srnclab2002=10.82.47.21
...             srnclab2010=10.82.47.131
...             srnclab2001=10.99.102.49

*** Keywords ***
########################################### Main keywords #############################################################
Integrate BTS to MantaRay without TLS
    [Documentation]    Description:    KW to integrate BTS to MantaRay lab
    ...                Input:          NMS_HOST = ip address of MantaRay lab
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                                SW_REL = software release installed on BTS, for example SBTS00
    ...                                BTS_IP = mplane BTS ip address
    ...                                MRBTS_ID = number of MRBTS
    ...                                MR = maintenence region of BTS
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${NMS_HOST}=${NONE}
    ...                ${LAB_NAME}=${NONE}
    ...                ${BTS_IP}=${MPLANE_IPV4}
    ...                ${MRBTS_ID}=${BTS_ID}
    ...                ${MR}=MRC-COMMON/MR-COMMON
    ...                ${SW_RELEASE}=${NONE}
    ...                ${PREFERRED_LAB}=${NONE}
    ...                ${NIDD_CHECK}=False
    Deintegrate BTS from Mantaray Labs
    RUN    sudo pkill -f "emssim"
    @{excluded_labs}    Create List
    ${RELEASE}        Run Keyword If    "${SW_RELEASE}"=="${NONE}"    _Get SW release
    ...               ELSE    Set Variable    ${SW_RELEASE}
    ${VERSION_FOR_SW_CHECK}    Run Keyword If    "${SW_RELEASE}"=="${NONE}"    _Get SW Version
    ...              ELSE    Set Variable    ${SW_RELEASE}
    FOR    ${i}    IN RANGE    ${MAX_LAB_RETRIES}
        ${LAB_DETAILS}     Run Keyword If    '${NIDD_CHECK}'=='True'
        ...                Get Valid Netact Lab With NIDD    preferred_lab=${PREFERRED_LAB}    excluded_labs=${excluded_labs}
        ...                sw_version=${VERSION_FOR_SW_CHECK}
        ...                ELSE    Get Valid Netact Lab Without NIDD    preferred_lab=${PREFERRED_LAB}
        ...                sw_version=${VERSION_FOR_SW_CHECK}
        ...                excluded_labs=${excluded_labs}
        ${NMS_LAB}         Set Variable If    "${LAB_NAME}"=="${NONE}"     ${LAB_DETAILS}[0]    ${LAB_NAME}
        ${NMS_IP}          Set Variable If    "${LAB_NAME}"=="${NONE}"     ${LAB_DETAILS}[1]    ${NMS_HOST}
        nms.Add Web URL      ${NMS_LAB}lbwas.srnblr.nsn-rdnet.net    ${NMS_USERNAME}  ${NMS_PASSWORD}  alias=${NMS_LAB}
        Run Keyword And Ignore Error    nms.Delete Node    cmwas    alias=${NMS_LAB}
        nms.Add Node  cmwas  ${NMS_IP}  ${NMS_USERNAME}  ${NMS_PASSWORD}    alias=${NMS_LAB}
        Run Keyword And Ignore Error    nms.Deintegrate MRBTS from NetAct    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
        ${conn}=  Run Keyword If    "${SW_RELEASE}"=="${NONE}"   admin.Connect To Admin
        Run Keyword If    "${SW_RELEASE}"=="${NONE}"
        ...               Change Multiple Parameters On BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
        ...               connection=${conn}
        ...               oamTls=off
        ${status}         Run Keyword And Return Status    nms.Integrate MRBTS with NetAct
        ...               release=${RELEASE}
        ...               mr=${MR}
        ...               mrbts_address=${BTS_IP}
        ...               dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
        ...               security_mode=no TLS
        ...               alias=${NMS_LAB}
        Run Keyword If    not ${status}
        ...               Run Keywords    Log    Integration with NMS with ${NMS_LAB} lab failed    console=true
        ...               AND    Append To List    ${excluded_labs}    ${LAB_DETAILS}[0]
        ...               AND    Log to console    ${excluded_labs}
        ...               AND    Continue For Loop
        Exit For Loop If  ${status}
    END
    [Return]          ${NMS_LAB}

Integrate BTS to MantaRay with TLS
    [Documentation]    Description:    KW to integrate BTS to MantaRay lab
    ...                Input:          NMS_HOST = ip address of MantaRay lab
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                                SW_REL = software release installed on BTS, for example SBTS00
    ...                                BTS_IP = mplane BTS ip address
    ...                                MRBTS_ID = number of MRBTS
    ...                                MR = maintenence region of BTS
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${NMS_HOST}=${NONE}
    ...                ${LAB_NAME}=${NONE}
    ...                ${BTS_IP}=${MPLANE_IPV4}
    ...                ${MRBTS_ID}=${BTS_ID}
    ...                ${cert_type}=RSA
    ...                ${tls_version}=1_2
    ...                ${MR}=MRC-COMMON/MR-COMMON
    ...                ${SW_RELEASE}=${NONE}
    ...                ${PREFERRED_LAB}=${NONE}
    ...                ${NIDD_CHECK}=False
#    RUN    sudo pkill -f "emssim"
    Deintegrate BTS from Mantaray Labs
    @{excluded_labs}    Create List
    _Setup certificates for MantaRay    ${cert_type}    ${tls_version}
    ${RELEASE}       Run Keyword If    "${SW_RELEASE}"=="${NONE}"    _Get SW release
    ...              ELSE    Set Variable    ${SW_RELEASE}
    ${VERSION_FOR_SW_CHECK}    Run Keyword If    "${SW_RELEASE}"=="${NONE}"    _Get SW Version
    ...              ELSE    Set Variable    ${SW_RELEASE}
    FOR    ${i}    IN RANGE    1
        ${LAB_DETAILS}     Run Keyword If    '${NIDD_CHECK}'=='True'
        ...                Get Valid Netact Lab With NIDD    preferred_lab=${PREFERRED_LAB}    excluded_labs=${excluded_labs}
        ...                sw_version=${VERSION_FOR_SW_CHECK}
        ...                ELSE    Get Valid Netact Lab Without NIDD    preferred_lab=${PREFERRED_LAB}
        ...                sw_version=${VERSION_FOR_SW_CHECK}
        ...                excluded_labs=${excluded_labs}
        ${NMS_LAB}         Set Variable If    "${LAB_NAME}"=="${NONE}"     ${LAB_DETAILS}[0]    ${LAB_NAME}
        ${NMS_IP}          Set Variable If    "${LAB_NAME}"=="${NONE}"     ${LAB_DETAILS}[1]    ${NMS_HOST}
        nms.Add Web URL      ${NMS_LAB}lbwas.srnblr.nsn-rdnet.net    ${NMS_USERNAME}  ${NMS_PASSWORD}  alias=${NMS_LAB}
        Run Keyword And Ignore Error    nms.Delete Node    cmwas    alias=${NMS_LAB}
        nms.Add Node  cmwas  ${NMS_IP}  ${NMS_USERNAME}  ${NMS_PASSWORD}    alias=${NMS_LAB}
        Run Keyword And Ignore Error    nms.Deintegrate MRBTS from NetAct    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
        ${status}         Run Keyword And Return Status    nms.Integrate MRBTS with NetAct
        ...               release=${RELEASE}
        ...               mr=${MR}
        ...               mrbts_address=${BTS_IP}
        ...               dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
        ...               security_mode=TLS
        ...               certificate_type=Already installed
        ...               alias=${NMS_LAB}
        Run Keyword If    not ${status}
        ...               Run Keywords    Log    Integration with NMS with ${NMS_LAB} lab failed    console=true
        ...               AND    Append To List    ${excluded_labs}    ${LAB_DETAILS}[0]
        ...               AND    Log to console    ${excluded_labs}
        ...               AND    Continue For Loop
        Exit For Loop If  ${status}
    END
    [Return]         ${NMS_LAB}

Get IP From MantaRay
    [Arguments]    ${NMS_LAB}    ${VALUE}
    ${NMS}    OperatingSystem.Get File    ${CURDIR}/config/netact/${NMS_LAB}.py
    ${correct_address}    Set Variable    ${None}
    FOR    ${line}    IN    @{NMS.splitlines()}
        ${status}    Run Keyword And Return Status    Should Contain    ${line}    ${VALUE}
        IF    '${status}'=='True'
            ${address}    Evaluate    ${line.split('=')}[1]
            IF    '${address}' != '${None}'
                ${correct_address}    Set Variable    ${address}
                BREAK
            END
        END
    END
    [Return]    ${correct_address}

Deintegrate BTS from MantaRay
    [Documentation]    Description:    This KW opens cmwas node to given Mantaray NMS Lab and deintegrates vCU/vDU
    ...                                from this lab. After deintegration node is deleted.
    ...                Input:          nms_lab_ip = cmwas node ip of selected NMS Lab
    ...                                username = username for NMS Lab
    ...                                password = password for NMS Lab
    ...                                hw_type = vDU / vCU
    ...                Author:         damian.kotula@nokia.com
    [Arguments]         ${LAB_NAME}
    nms.Detect Nodes    alias=${LAB_NAME}
    nms.Deintegrate Mrbts From Netact    dist_name=PLMN-PLMN/MRBTS-${BTS_ID}   alias=${LAB_NAME}
    nms.Delete Node  fmwas    alias=${LAB_NAME}
    nms.Delete Node  cmwas    alias=${LAB_NAME}
    nms.Clean All        alias=${LAB_NAME}
    [Teardown]    nms.Delete Node    cmwas    alias=${LAB_NAME}

Deintegrate BTS from Mantaray Labs
    [Documentation]    Description:    This KW deintegrate all labs as prerequisite.
    ...                Author:         jagoda.kubacka@nokia.com
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=srnclab*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    FOR  ${lab_file}  IN  @{randomized_list}
        Run Keyword And Ignore Error    Import Variables  ${CURDIR}/config/netact/${lab_file}
        Run Keyword And Ignore Error    nms.Add Node         cmwas  ${NA_HOST}  ${NA_USER}  ${NA_PASS}    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Deintegrate Mrbts From Netact    dist_name=PLMN-PLMN/MRBTS-${BTS_ID}
        ...                             alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Delete Node      fmwas    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Delete Node      cmwas    alias=deintegrate_${lab_file}
        Run Keyword And Ignore Error    nms.Clean All        alias=deintegrate_${lab_file}
    END

Change Multiple Parameters with NMS
    [Documentation]    Description:    KW to change multiple parameters usung MantaRay lab
    ...                Input:          MOC_DN = destinguished name of managed object
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                                kwargs = parameters and values in format name=value
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${MOC_DN}    ${LAB_NAME}    &{kwargs}
    Run Keyword and Ignore Error    nms.Add Node  cmwas  ${NMS_HOST}  ${NMS_USERNAME}  ${NMS_PASSWORD}    alias=${LAB_NAME}
    Run Keyword and Ignore Error    nms.Delete plan     ${PLAN_NAME_multi}     alias=${LAB_NAME}
    ${plan_conf}=     nms.Create Plan Configuration    ${PLAN_NAME_multi}   new plan    alias=${LAB_NAME}
    ${meta_class}     ${meta_version}    ${parameters}=    _Get Actual Configuration MO Data   ${MOC_DN}    ${LAB_NAME}
    ${managed_object}=    nms.Create Managed Object
    ...                 ${plan_conf}
    ...                 ${meta_class}
    ...                 ${meta_version}
    ...                 PLMN-PLMN/${MOC_DN}
    ...                 UPDATE
    ...                 alias=${LAB_NAME}
    ...                 &{kwargs}
    Wait Until Keyword Succeeds   5x   30s   nms.Provision Plan
    ...                 plan_name=${PLAN_NAME_MULTI}
    ...                 backup_plan_name=None
    ...                 create_backup_plan=False
    ...                 provisioning_operation=activate
    ...                 ignore_errors=False
    ...                 timeout=1200
    ...                 alias=${LAB_NAME}
    [Teardown]    nms.Delete Plan Configuration    ${plan_conf}


Change Parameter with NMS
    [Documentation]    Description:    KW to change single parameter usung MantaRay lab
    ...                Input:          MOC_DN = destinguished name of managed object
    ...                                param_name = abbreviated name of the parameter
    ...                                param_value = planned value of the parameter
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${MOC_DN}
    ...                 ${param_name}
    ...                 ${param_value}
    ...                 ${LAB_NAME}
    Run Keyword and Ignore Error    nms.Delete plan     ${PLAN_NAME}     alias=${LAB_NAME}
    Run Keyword and Ignore Error    nms.Add Node  cmwas  ${NMS_HOST}  ${NMS_USERNAME}  ${NMS_PASSWORD}    alias=${LAB_NAME}
    ${plan_conf}=       nms.Create Plan Configuration    ${PLAN_NAME}   new plan    alias=${LAB_NAME}
    ${meta_class}    ${meta_version}    ${parameters}=    _Get Actual Configuration MO Data   ${MOC_DN}    ${LAB_NAME}
    ${managed_object}=  nms.Create Managed Object
    ...                 ${plan_conf}
    ...                 ${meta_class}
    ...                 ${meta_version}
    ...                 PLMN-PLMN/${MOC_DN}
    ...                 UPDATE
    ...                 alias=${LAB_NAME}
    ...                 ${param_name}=${param_value}
    Wait Until Keyword Succeeds   5x   30s   nms.Provision Plan
    ...                 plan_name=${PLAN_NAME}
    ...                 backup_plan_name=None
    ...                 create_backup_plan=False
    ...                 provisioning_operation=activate
    ...                 ignore_errors=False
    ...                 timeout=1200
    ...                 alias=${LAB_NAME}
    [Teardown]    nms.Delete Plan Configuration    ${plan_conf}

Activate CNUM user
    [Arguments]    ${LAB_NAME}
    ...            ${MRBTS_ID}=${BTS_ID}
    nms.Activate CNUM
    ...    ne_id_value=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...    ip_type=IPv4
    ...    alias=${LAB_NAME}

Get Active Alarms From BTS via MantaRay
    [Arguments]    ${LAB_NAME}
    ...            ${MRBTS_ID}=${BTS_ID}
    ${netact_alarms}    nms.get_alarms
    ...    dist_name=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ...    alias=${LAB_NAME}
    Log    ${netact_alarms}    console=true
    ${x}=    extract_alarms    ${netact_alarms}
    [Return]    ${x}

Setup Mantaray
    [Documentation]    Description:    KW to setup certificates for MantaRay
    ...                Input:          cert_type = ip address of MantaRay lab
    ...                                tls_version = name of NetAct lab,  for example srnclab1015
    ...                Output:         None
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${cert_type}=RSA
    ...                ${tls_version}=1_2
    _Setup certificates for MantaRay    ${cert_type}    ${tls_version}

Check If Local ATL Is Configured
    [Documentation]    Description:    This KW checks if ATL are redirected to local directory
    ...                Input:          LAB_NAME = name of NetAct lab, for example srnclab1015
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${LAB_NAME}
    Log                Login to graylog node and check if ATL is redirected    console=true
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${LAB_NAME}
    SSHLibrary.Open Connection   host=${atl_node_ip}
    SSHLibrary.Login             username=${NMS_USERNAME}       password=${NMS_PASSWORD}
    SSHLibrary.Write             su ${NMS_ROOT_USER}
    Sleep    5s                  reason=Waiting until password can be written
    SSHLibrary.Write             ${NMS_ROOT_PASS}
    Sleep    2s                  reason=Waiting for user change
    SSHLibrary.Write             ls /var/log
    Sleep                        2s    reason=Wait until terminal execute the command
    ${output}=                   SSHLibrary.Read
    ${status}=                   Run Keyword And Return Status    Should Contain    ${output}    slc_syslog.log
    IF    '${status}'=='False'
           ${command}=              Catenate    /opt/oss/NSN-slc/bin/siem.sh add --local localOutput
           ...                                  file=/var/log/slc_syslog.log size=1000 rotate=5
           SSHLibrary.Write         ${command}
           SSHLibrary.Read Until    *Configuring SIEM*    timeout=60s
    END
    [Teardown]    SSHLibrary.Close Connection

Clear ATL
    [Documentation]    Description:    This KW clears ATL file
    ...                Input:          LAB_NAME = name of NetAct lab, for example srnclab1015
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${LAB_NAME}
    Log                Clear current ATL log file    console=true
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${LAB_NAME}
    SSHLibrary.Open Connection    host=${atl_node_ip}
    SSHLibrary.Login              username=${NMS_USERNAME}       password=${NMS_PASSWORD}
    SSHLibrary.Write              su ${NMS_ROOT_USER}
    Sleep    5s                   reason=Waiting until password can be written
    SSHLibrary.Write              ${NMS_ROOT_PASS}
    Sleep    2s                   reason=Waiting for user change
    SSHLibrary.Write              cat /dev/null > /var/log/slc_syslog.log
    [Teardown]                    SSHLibrary.Close Connection

Gather ATL for BTS to Variable
    [Documentation]    Description:    This KW gathers ATL logs into ${atl} variable
    ...                Input:          LAB_NAME = name of NetAct lab, for example srnclab1015
    ...                                grep = optional, only if you want to grep logs instead of getting all of them
    ...                Output:         ATL logs in form of a string variable
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${LAB_NAME}    ${grep}=${NONE}
    Log                Collecting ATL logs    console=true
    ${atl_node_ip}=    Get from Dictionary    ${siem_node}    ${LAB_NAME}
    SSHLibrary.Open Connection    host=${atl_node_ip}
    SSHLibrary.Login              username=${NMS_USERNAME}       password=${NMS_PASSWORD}
    SSHLibrary.Write              su ${NMS_ROOT_USER}
    Sleep    5s                   reason=Waiting until password can be written
    SSHLibrary.Write              ${NMS_ROOT_PASS}
    Sleep    2s                   reason=Waiting for user change
    Run Keyword If    "${grep}"=="${NONE}"    SSHLibrary.Write    cat /var/log/slc_syslog.log
    ...       ELSE                            SSHLibrary.Write    cat /var/log/slc_syslog.log | grep ${grep}
    Sleep         5s    reason=Wait until logs are captured
    ${atl}=       SSHLibrary.read
    [Return]      ${atl}
    [Teardown]    SSHLibrary.Close Connection

Get Valid Netact Lab With NIDD
    [Arguments]  ${smod_type}=AIRSCALE    ${sw_version}=None    ${preferred_lab}=None    ${excluded_labs}=None
    Log To Console  \nChecking for valid NetAct lab...
    ${valid_lab}      Set Variable  None
    ${nidd_baseline}  _Get NIDD From AIRSCALE
    ${nidd_baseline}  Run Keyword If  '${smod_type}'!='AIRSCALE'
    ...                                Remove String  ${nidd_baseline}  _NIDD
    ...                         ELSE   Set Variable   ${nidd_baseline}
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=srnclab*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    ${index}  Get Index From List  ${randomized_list}  ${preferred_lab}.py    # returns -1 if value is not found
    Run Keyword If  ${index}>=0  Run Keywords  Set List Value  ${randomized_list}  ${index}  ${randomized_list[0]}
    ...                                   AND  Set List Value  ${randomized_list}  0         ${preferred_lab}.py
    FOR  ${lab_file}  IN  @{randomized_list}
        Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${lab_file}
        ${current_lab_name}  Set Variable  ${lab_file[0:-3]}
        Run Keyword If  '${current_lab_name}' in ${excluded_labs}
        ...             Run Keywords    Log    Lab ${current_lab_name} is in the excluded list. Skipping.
        ...             AND    Continue For Loop

        Log    Checking ${lab_file[0:-3]} lab    console=True
        ${lab_pingable}    Run Keyword And Return Status  Wait Until Keyword Succeeds  10s  5s
        ...                _Check If Host Is Reachable  IP=${NA_HOST}
        Run Keyword If     not ${lab_pingable}
        ...                Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} is not pingable. Skipping.
        ...                AND    Continue For Loop

        ${sw_on_lab}      Run Keyword And Return Status    _Check SW supported on NMS Lab    host=${SW_INFO}
        ...               user=${NA_USER}    password=${NA_PASS}    sw_version=${sw_version}
        Log               Proper SW on NMS Lab: ${sw_on_lab}    console=true
        Run Keyword If    not ${sw_on_lab}
        ...               Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} has no proper SW version. Skipping.
        ...               AND    Continue For Loop

        ${login_possible}    _Check If SSH Login Is Possible  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        Run Keyword If       not ${login_possible}
        ...                  Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} has no possiblity to login. Skipping.
        ...                  AND    Continue For Loop

        ${nidd_on_lab}       _Check For NIDD Baseline On Netact Lab  ${nidd_baseline}  ${NA_HOST}
        ...                  ${NA_USER}  ${NA_PASS}
        Log                  Proper NIDD on NMS Lab: ${nidd_on_lab}    console=true
        Run Keyword If       not ${nidd_on_lab}
        ...                  Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} has no proper NIDD. Skipping.
        ...                  AND    Continue For Loop

        ${valid_lab}     Set Variable  ${lab_file[0:-3]}
        Exit For Loop If  '${valid_lab}'!='None'
    END
    Run Keyword If  '${valid_lab}'!='None'
    ...              Log To Console  Lab ${valid_lab} is valid
    ...              ELSE  FAIL    msg=No lab that supports actions
    [Return]  ${valid_lab}    ${NA_HOST}

Get Valid Netact Lab Without NIDD
    [Arguments]    ${preferred_lab}=None    ${sw_version}=None    ${excluded_labs}=None
    Log To Console  \nChecking for valid NetAct lab...
    ${valid_lab}      Set Variable  None
    @{labs_files_list}  OperatingSystem.List Files In Directory  path=${CURDIR}/config/netact  pattern=srnclab*.py
    @{randomized_list}  Evaluate  random.sample(${labs_files_list}, len(${labs_files_list}))  modules=random
    ${index}  Get Index From List  ${randomized_list}  ${preferred_lab}.py
    Run Keyword If  ${index}>=0  Run Keywords  Set List Value  ${randomized_list}  ${index}  ${randomized_list[0]}
    ...                                   AND  Set List Value  ${randomized_list}  0         ${preferred_lab}.py
    FOR  ${lab_file}  IN  @{randomized_list}
        Log    Importing variables from python files
        Run Keyword And Ignore Error  Import Variables  ${CURDIR}/config/netact/${lab_file}
        ${current_lab_name}  Set Variable  ${lab_file[0:-3]}
        Run Keyword If  '${current_lab_name}' in ${excluded_labs}
        ...             Run Keywords    Log    Lab ${current_lab_name} is in the excluded list. Skipping.
        ...             AND    Continue For Loop

        Log    Checking ${lab_file[0:-3]} lab    console=True
        ${lab_pingable}    Run Keyword And Return Status  Wait Until Keyword Succeeds  10s  5s
        ...                _Check If Host Is Reachable  IP=${NA_HOST}
        Run Keyword If     not ${lab_pingable}
        ...                Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} is not pingable. Skipping.
        ...                AND    Continue For Loop

        ${sw_on_lab}     Run Keyword And Return Status    _Check SW supported on NMS Lab    host=${SW_INFO}
        ...              user=${NA_USER}    password=${NA_PASS}    sw_version=${sw_version}
        Log    Proper SW on NMS Lab: ${sw_on_lab}    console=true
        Run Keyword If     not ${sw_on_lab}
        ...                Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} has no proper SW version. Skipping.
        ...                AND    Continue For Loop

        ${login_possible}     _Check If SSH Login Is Possible  ${NA_HOST}  ${NA_USER}  ${NA_PASS}
        Run Keyword If  not ${login_possible}
        ...                Run Keywords    Log    Lab ${lab_file[0:-3]}: ${NA_HOST} has no possiblity to login. Skipping.
        ...                AND    Continue For Loop

        ${valid_lab}     Set Variable  ${lab_file[0:-3]}
        Exit For Loop If  '${valid_lab}'!='None'
    END
    Run Keyword If  '${valid_lab}'!='None'
    ...              Log To Console  Lab ${valid_lab} is valid
    ...              ELSE  FAIL    msg=No lab that supports actions
    [Return]  ${valid_lab}    ${NA_HOST}

Get PM Counters from Mantaray
    [Arguments]    ${mrbts_id}
    ...            ${technology}=SBTS-Nokia Multi Radio Transceiver Station
    ...            ${measurement}=IP filtering Statistics
    ...            ${counters}=ALL
    ...            ${filter_by}=MRBTS
    ...            ${object_aggregation}=PLMN/MRBTS/TNLSVC/TNL/IPNO
    ...            ${time_aggregation}=RAW
    ...            ${time_filter}=today
    ...            ${alias}=${None}
    ${result}      nms.get_pm_counters    technology=${technology}
    ...            measurement=${measurement}
    ...            counters=${counters}
    ...            filter_by=${filter_by}
    ...            mo_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...            object_aggregation=${object_aggregation}
    ...            time_aggregation=${time_aggregation}
    ...            time_filter=${time_filter}
    ...            alias=${alias}
    [Return]       ${result}


########################################### Suplementary keywords #####################################################
_Get NIDD From AIRSCALE
    ${connection}=    Connect to ADMIN
    ${MNL_R_info}  admin.Get Managed Objects  class_name=MNL_R    connection=${connection}
    FOR  ${item}  IN  @{MNL_R_info}
        ${nidd_baseline}  Set Variable  ${item['parameters']['infoModelVersion']}
    END
    [Teardown]    Disconnect from ADMIN    ${connection}
    [Return]  ${nidd_baseline}

_Check If Host Is Reachable
    [Arguments]  ${IP}
    ${result}  Run  ping -c 5 -w 10 ${IP}
    ${status}=  Run Keyword And Return Status  Should Contain  ${result}  5 packets transmitted, 5 received
    Run Keyword If  ${status} == False  Fail  msg=Host is not pingable

_Check If SSH Login Is Possible
    [Arguments]  ${host}  ${user}  ${password}
    ${connection_attempt}  ${connection_result}  Run Keyword And Ignore Error  ssh.Connect To  ${host}  ${user}  ${password}
    Run Keyword If  '${connection_attempt}'=='PASS'  ssh.Disconnect  ${connection_result}
    ...                                       ELSE   Log To Console  ${connection_result}
    ${return_result}  Set Variable If  '${connection_attempt}'=='PASS'  ${TRUE}  ${FALSE}
    [Return]  ${return_result}

_Check For NIDD Baseline On Netact Lab
    [Arguments]  ${baseline}  ${host}  ${user}  ${password}
    ${command}  Set Variable  grep -R ${baseline} /d/oss/global/var/fastpass/BOM/FastPass
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Contain  ${output}  ${baseline}
    [Return]  ${match}

_Check If Services Are Running On Lab
    [Documentation]  Keyword returns False if any of the requested services is stopped.
    [Arguments]  ${services}  ${host}  ${user}  ${password}
    ${services_list}  Split String  ${services}  separator=,
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    FOR  ${service}  IN  @{services_list}
        ${output}  ssh.Execute  command=/opt/cpf/sbin/netact_status.sh status service ${service}  connection=${connection}
        ssh.Await Execution End  connection=${connection}  timeout=60s
        Return From Keyword If  'stopped' in $output or 'starting' in $output or 'frozen' in $output  ${FALSE}
    END
    Return From Keyword  ${TRUE}
    [Teardown]  ssh.Disconnect  ${connection}

_Check If Actions Are Supported On Lab
    [Arguments]  ${host}  ${user}  ${password}
    ${command}  Set Variable  grep -e 'Trunk' -e '[2-9][4-9]R[2-9]' -e 'PP1314' /etc/netact-release
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match}  Run Keyword And Return Status  Should Not Be Empty  ${output}
    [Return]  ${match}

_Set NetAct Related Variables To None
    Set Suite Variable  ${LBWAS_NODE}  None
    Set Suite Variable  ${NA_HOST}     None
    Set Suite Variable  ${NA_USER}     None
    Set Suite Variable  ${NA_PASS}     None

_Get SW Version
    [Documentation]
    ${conn}=          Connect to ADMIN
    ${sw_version}=    admin.get_sw_version    connection=${conn}
    ${if_trunk}       Run Keyword And Return Status    Should Contain    ${sw_version}    9999
    ${shorter_sw}     Split String    ${sw_version}    _
    ${sw_release}     Set Variable If    ${if_trunk}    SBTS00    ${shorter_sw}[0]
    [Teardown]        Disconnect from ADMIN    connection=${conn}
    [Return]          ${sw_release}

_Get SW release
    ${conn}=          Connect to ADMIN
    ${sw_release}=    admin.get_sw_release_name    connection=${conn}
    [Teardown]        Disconnect from ADMIN    connection=${conn}
    [Return]          ${sw_release}

_Get Actual Configuration MO Data
    [Documentation]    Description:    KW to get the actual configuration of given managed object from BTS using MantaRay
    ...                Input:          mo_id = destinguished name of managed object
    ...                                LAB_NAME = name of NetAct lab,  for example srnclab1015
    ...                Output:         meta_class, meta_version and parameters of managed object
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]             ${mo_id}
    ...                     ${LAB_NAME}
    ${actual_conf}=         nms.Get Actual Configuration     alias=${LAB_NAME}
    ${managed_object}=      nms.Get Managed Object           ${actual_conf}    PLMN-PLMN/${mo_id}    alias=${LAB_NAME}
    [Return]    ${managed_object.meta_class}     ${managed_object.meta_version}    ${managed_object.parameters}

_Setup certificates for MantaRay
    [Documentation]           Keyword configuring RSA certs for MantaRay
    [Arguments]               ${cert_type}
    ...                       ${tls_version}
    ${conn}=                  Connect To Admin
    Configure CMP
    ...                       ca_subject_name=${SRNLAB_CA}
    ...                       bts_id=${BTS_ID}
    ...                       server_type=${cert_type}
    ...                       ca_server_host=${SRNLAB_CA_IP}
    ...                       server_path=${CA_SERVER_PATH}
    ...                       ca_server_port=${CA_DEFAULT_PORT}
    ...                       connection=${conn}
    admin.Set Certificate Automatic Management
    ...                       key_pool_type=${cert_type}
    ...                       reference_number=${SRNLAB_CA_REFNUM}
    ...                       preshared_key=${SRNLAB_CA_PSK}
    ...                       detailed_output=${TRUE}
    ...                       connection=${conn}
    Initialize Certificates   key_pool_type=${cert_type}    connection=${conn}
    Run Keyword And Ignore Error   Disconnect from ADMIN    ${conn}
    &{params_mantaray}=        Get From Dictionary    ${TLS_VERSIONS_MANTARAY}     ${tls_version}
    ${conn}                    Connect To Admin
    Change Multiple Parameters On BTS   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                 connection=${conn}
    ...                                 oamTls=forced
    ...                                 &{params_mantaray}
    [Teardown]    Disconnect from ADMIN    ${conn}


Execute SSH Command On BTS
    [Arguments]  ${command}
    ssh.connect_to  hostname=192.168.255.129  username=toor4nsn  password=oZPS0POrRieRtu
    ${msg}  Run Keyword And Return  ssh.execute  command=${command}
    ssh.Disconnect
    [Return]  ${msg}

Remove All ne3sadapt File
    Log To Console  Removing ne3sadaptdata.db file...
    Execute SSH Command On BTS  command=rm /ffs/run/config/ne3sadapt/configs/ne3sadaptdata.db
    Log To Console  BTS needs to be rebooted.

Change Web Service User Credentials
    [Arguments]  ${username}=wsuser  ${new_password}=A0zY~rP#8Mx@  ${old_password}=A0zY~rP8Mx@
    Log To Console  Trying to change '${username}' password...
    ${change_result}  ${change_output}  Run Keyword And Ignore Error  admin.Modify Web Service User  username=${username}
    ...                                                                                              password=${new_password}
    ...                                                                                              old_username=${username}
    ...                                                                                              old_password=${old_password}
    Run Keyword If  'PASS' in $change_result  Log  Password for '${username}' changed from '${old_password}' to '${new_password}'  WARN
    ...       ELSE  Log To Console  Password for '${username}' was not changed -- it may already be set as desired or it failed due to other reason.

_Check SW supported on NMS Lab
    [Arguments]  ${host}  ${user}  ${password}    ${sw_version}
    ${command}  Set Variable  /opt/oss/Nokia-fit/bin/query_fastpass_info.sh --all | grep ${sw_version}
    ${connection}  ssh.Connect To  ${host}  ${user}  ${password}
    ${output}  ssh.Execute  command=${command}  connection=${connection}
    ssh.Await Execution End  connection=${connection}  timeout=60s
    ssh.Disconnect  ${connection}
    ${match_lines}    Split String    ${output}    \n
    @{sw}    Create List
    FOR    ${i}    IN    @{match_lines}
        ${sw_installed}    Run Keyword And Return Status    Should Contain    ${i}    ${sw_version}
        Run Keyword If     ${sw_installed}    Append To List    ${sw}    ${i}
    END
    Should Not Be Empty    ${sw}

Check NMS Statuses on BTS
    [Arguments]       ${TLS}=False    ${conn}=${NONE}
    ${expected_state}    Set Variable If    '${TLS}'=='True'    Secured    notSecured
    ${connection}=     Run Keyword If    "${conn}"=="${NONE}"    Connect to ADMIN
    ...               ELSE    Set Variable      ${conn}
    ${nms_list}=      coam_admin.get_nms_state
    ...               connection=${connection}
    ${nms_statuses}    Set Variable    ${nms_list[0]}
    Should Be Equal    ${nms_statuses}[downlinkFromNMS]    ${expected_state}
    Should Be Equal    ${nms_statuses}[uplinkToNMS]        ${expected_state}
#    [Teardown]    Disconnect from ADMIN    ${connection}

Setup Graylog
    [Documentation]    Description:    Setup Graylog API. To be executed before operations that will generate ATL logs.
    ...                Input:          lab_name = lab BTS is integrated with
    ...                                graylog_addr = address of graylog paired with given lab_name,
    ...                                               by default graylog from srnclab2010
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${lab_name}    ${graylog_addr}=10.99.102.48
    ...                ${graylog_username}=${GRAYLOG_USER}    ${graylog_password}=${GRAYLOG_PASS}
    graylog.setup_graylog_api    url=http://${graylog_addr}:9000/
    ...                          username=${graylog_username}    password=${graylog_password}
    ...                          api_token=${EMPTY}    version=3.3    alias=${lab_name}_graylog

Gather Logs from Graylog
    [Documentation]     Description:    Gather ATL logs directly from graylog.
    ...                 Input:          lab_name = lab BTS is integrated with
    ...                                 range_sec = how many seconds of logs should be gathered
    ...                                 range_from = offset of the start of logs gathering
    ...                                 filter = way of filter ATL logs, by default using MRBTS ID
    ...                                 fields = list of required fields, if empty all fields are gathered
    ...                 Output:         ATL logs from graylog
    ...                 Author:         patryk.tatarek@nokia.com
    [Arguments]         ${lab_name}    ${range_sec}    ${range_from}=0
    ...                 ${filter}=source:"PLMN-PLMN/MRBTS-${BTS_ID}"    ${fields}=${EMPTY}
    ${offset}=          Evaluate    ${range_sec} + 3600    #Due to 1h time zone difference
    ${graylog_logs}=    graylog.query_messages    query=${filter}    range_from=${range_from}    timeout=60
    ...                 range_seconds=${offset}    graylog_api=${lab_name}_graylog    fields=${fields}
    [Return]            ${graylog_logs}
