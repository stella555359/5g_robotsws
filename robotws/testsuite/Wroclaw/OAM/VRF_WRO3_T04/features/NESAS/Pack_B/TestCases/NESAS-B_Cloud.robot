*** Settings ***
Documentation
...    Author:            Patryk Tatarek
...    Contact:           patryk.tatarek@nokia.com
...    Test Plan (QC):    /VRF_WRO3_T04/24R3/CB009857/
...    Description:

Library    SSHLibrary
Library    String
Library    OperatingSystem
Library    Collections
Library    DateTime

Resource    ../../../../../cloud_common_resources/resets/resets.robot
Resource    ../Resources/NESAS-B_Cloud_Keywords.robot
Resource    ../../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource    ../../../../../cloud_common_resources/connections/connections.robot
Resource    ../../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../../cloud_common_resources/alarms/alarms.robot
Resource    ../../../../../cloud_common_resources/alarms/watchdog.robot
Resource    ../../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../cloud_common_resources/tls/tls.robot
Resource    ../../../../cloud_common_resources/emssim/emssim_setup.robot

*** Variables ***
${SSH_USERNAME}=           ${SSH_K8S_USERNAME}
${SSH_PASSWORD}=           ${SSH_K8S_PASSWORD}
${no_space_left_error}=    No space left on device
${perm_denied}=            Permission denied
${ipsec_gw}=               10.42.131.99
${ipsec_cert}=             C=PL, O=Common, CN=IPSEC
#${old_default_password}         nemuuser\
${error_password}               The password contains less than 2 non-alphanumeric characters
${error}                        Change password failed
@{passwords}                    Nokia   Nokia:123   Nookia!1234     Nokia 1234
...                             SGLfHoZrhmVQizJdOytcHyCMujwdlFzITVcdmPJEYoOLqrNsxMqWifEtuQIusTwiQTCeqCdmyEquEwfAZsreFfK\n
...                             ZOwitOKSJitCuAEkVWKyabnqBnJPaeYimVY09ayp
${read_username}=               BTSRead
${app_username}=                BTSApplication
${sys_username}=                BTSSystem
${sec_username}=                BTSSecurity
${old_default_password}         nemuuser
${error_minlenght}              Incorrect value of minPasswordLength
${new_password}                 Nokia@123a
${fault 4459}=                  User Account has Default Password
@{parameters}=                  localPasswdExpiryPeriod    localPasswdWarningPeriod    minPasswordLength    minNonAlphaNumInPassword
${dist_name1}                   MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1
${dist_name2}                   MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
${PC_IP}                        10.42.61.152
${PC_username}                  ute
${PC_password}                  UTE.debian12
${hydra_failed}                 1 of 1 target completed, 0 valid password found
${hydra_passed}                 1 of 1 target successfully completed, 1 valid password found
${Login_delay_error}            The account is temporarily locked
${TEST_PC_IP}                   10.42.195.89
${TEST_PC_LOGIN}                ute
${TEST_PC_PASSWD}               UTE.debian12
${TEST_LOGS_DIR}                /home/ute
${MAX_LOGIN_FAILED_ATTEMPTS}    10
${local_password}=          Qwerty!23$
${error_read}=              TTP method not allowed for read-write session
${error_user}                    Update local user account

*** Keywords ***
Handling_of_growing_memory_content_vCU
    Log                   Step 2: Check free space in /tmp folder on oamext pod    console=true
    ${free_space}=        Execute Command on Specific Pod    specific_pod=oamext    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Log                   Step 3: Fill in free space in /tmp folder and expect error message   console=true
    ${output}=            Execute Command on Specific Pod    specific_pod=oamext    raw_output=${True}    hw_type=vCU
    ...                   command=sh -c "cd /tmp && dd if=/dev/zero of=filename bs=1M count=${free_space}"
    Should Contain        ${output}    ${no_space_left_error}
    Log                   Step 4: Check free space in /tmp folder on oamext pod    console=true
    ${new_free_space}=    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    ${new_space_int}=     Convert to Integer    ${new_free_space}
    Should be Equal       ${new_space_int}    ${0}
    Log                   Step 5: Check stability of vCU    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         Check if Unit Status is OnAir        hw_type=vCU
    END
    Log                   Step 6: Delete temporary file in /tmp folder    console=true
    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vCU    command=rm /tmp/filename
    Log                   Step 7: Compare free space before and after test steps    console=true
    ${end_free_space}=    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Should be Equal       ${free_space}    ${end_free_space}
    Log                   Step 8: Repeat steps 2-7 for cpif pod    console=true
    Log                   Step 8-2: Check free space in /tmp folder on cpif pod    console=true
    ${free_space}=        Execute Command on Specific Pod    specific_pod=cpif    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Log                   Step 8-3: Fill in free space in /tmp folder and expect error message   console=true
    ${output}=            Execute Command on Specific Pod    specific_pod=cpif    raw_output=${True}    hw_type=vCU
    ...                   command=sh -c "cd /tmp && dd if=/dev/zero of=filename bs=1M count=${free_space}"
    Should Contain        ${output}    ${no_space_left_error}
    Log                   Step 8-4: Check free space in /tmp folder on oamext pod    console=true
    ${new_free_space}=    Execute Command on Specific Pod    specific_pod=cpif    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    ${new_space_int}=     Convert to Integer    ${new_free_space}
    Should be Equal       ${new_space_int}    ${0}
    Log                   Step 8-5: Check stability of vCU    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         Check if Unit Status is OnAir        hw_type=vCU
    END
    Log                   Step 8-6: Delete temporary file in /tmp folder    console=true
    Execute Command on Specific Pod    specific_pod=cpif    hw_type=vCU    command=rm /tmp/filename
    Log                   Step 8-7: Compare free space before and after test steps    console=true
    ${end_free_space}=    Execute Command on Specific Pod    specific_pod=cpif    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Should be Equal       ${free_space}    ${end_free_space}
    Log                   Step 9: Repeat steps 2-7 for cpnrt pod    console=true
    Log                   Step 9-2: Check free space in /tmp folder on cpnrt pod    console=true
    ${free_space}=        Execute Command on Specific Pod    specific_pod=cpnrt    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Log                   Step 9-3: Fill in free space in /tmp folder and expect error message   console=true
    ${output}=            Execute Command on Specific Pod    specific_pod=cpnrt    raw_output=${True}    hw_type=vCU
    ...                   command=sh -c "cd /tmp && dd if=/dev/zero of=filename bs=1M count=${free_space}"
    Should Contain        ${output}    ${no_space_left_error}
    Log                   Step 9-4: Check free space in /tmp folder on oamext pod    console=true
    ${new_free_space}=    Execute Command on Specific Pod    specific_pod=cpnrt    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    ${new_space_int}=     Convert to Integer    ${new_free_space}
    Should be Equal       ${new_space_int}    ${0}
    Log                   Step 9-5: Check stability of vCU    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         Check if Unit Status is OnAir        hw_type=vCU
    END
    Log                   Step 9-6: Delete temporary file in /tmp folder    console=true
    Execute Command on Specific Pod    specific_pod=cpnrt    hw_type=vCU    command=rm /tmp/filename
    Log                   Step 9-7: Compare free space before and after test steps    console=true
    ${end_free_space}=    Execute Command on Specific Pod    specific_pod=cpnrt    hw_type=vCU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Should be Equal       ${free_space}    ${end_free_space}
    [Teardown]    Run Keywords    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vCU
    ...                                                              command=rm /tmp/filename
    ...    AND                    Execute Command on Specific Pod    specific_pod=cpif      hw_type=vCU
    ...                                                              command=rm /tmp/filename
    ...    AND                    Execute Command on Specific Pod    specific_pod=cpnrt     hw_type=vCU
    ...                                                              command=rm /tmp/filename

Handling_of_growing_memory_content_vDU
    Log                   Step 2: Check free space in /tmp folder on oamext pod    console=true
    ${free_space}=        Execute Command on Specific Pod    specific_pod=oamext    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Log                   Step 3: Fill in free space in /tmp folder and expect error message   console=true
    ${output}=            Execute Command on Specific Pod    specific_pod=oamext    raw_output=${True}    hw_type=vDU
    ...                   command=sh -c "cd /tmp && dd if=/dev/zero of=filename bs=1M count=${free_space}"
    Should Contain        ${output}    ${no_space_left_error}
    Log                   Step 4: Check free space in /tmp folder on oamext pod    console=true
    ${new_free_space}=    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    ${new_space_int}=     Convert to Integer    ${new_free_space}
    Should be Equal       ${new_space_int}    ${0}
    Log                   Step 5: Check stability of vDU    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         Check if Unit Status is OnAir        hw_type=vDU
    END
    Log                   Step 6: Delete temporary file in /tmp folder    console=true
    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vDU    command=rm /tmp/filename
    Log                   Step 7: Compare free space before and after test steps    console=true
    ${end_free_space}=    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Should be Equal       ${free_space}    ${end_free_space}
    Log                   Step 8: Repeat steps 2-7 for cprt pod    console=true
    Log                   Step 8-2: Check free space in /tmp folder on cprt pod    console=true
    ${free_space}=        Execute Command on Specific Pod    specific_pod=cprt    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Log                   Step 8-3: Fill in free space in /tmp folder and expect error message   console=true
    ${output}=            Execute Command on Specific Pod    specific_pod=cprt    raw_output=${True}    hw_type=vDU
    ...                   command=sh -c "cd /tmp && dd if=/dev/zero of=filename bs=1M count=${free_space}"
    Should Contain        ${output}    ${no_space_left_error}
    Log                   Step 8-4: Check free space in /tmp folder on oamext pod    console=true
    ${new_free_space}=    Execute Command on Specific Pod    specific_pod=cprt    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    ${new_space_int}=     Convert to Integer    ${new_free_space}
    Should be Equal       ${new_space_int}    ${0}
    Log                   Step 8-5: Check stability of vDU    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         Check if Unit Status is OnAir        hw_type=vDU
    END
    Log                   Step 8-6: Delete temporary file in /tmp folder    console=true
    Execute Command on Specific Pod    specific_pod=cprt    hw_type=vDU    command=rm /tmp/filename
    Log                   Step 8-7: Compare free space before and after test steps    console=true
    ${end_free_space}=    Execute Command on Specific Pod    specific_pod=cprt    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Should be Equal       ${free_space}    ${end_free_space}
    Log                   Step 9: Repeat steps 2-7 for oamfh pod    console=true
    Log                   Step 9-2: Check free space in /tmp folder on oamfh pod    console=true
    ${free_space}=        Execute Command on Specific Pod    specific_pod=oamfh    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Log                   Step 9-3: Fill in free space in /tmp folder and expect error message   console=true
    ${output}=            Execute Command on Specific Pod    specific_pod=oamfh    raw_output=${True}    hw_type=vDU
    ...                   command=sh -c "cd /tmp && dd if=/dev/zero of=filename bs=1M count=${free_space}"
    Should Contain        ${output}    ${no_space_left_error}
    Log                   Step 9-4: Check free space in /tmp folder on oamext pod    console=true
    ${new_free_space}=    Execute Command on Specific Pod    specific_pod=oamfh    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    ${new_space_int}=     Convert to Integer    ${new_free_space}
    Should be Equal       ${new_space_int}    ${0}
    Log                   Step 9-5: Check stability of vDU    console=true
    FOR    ${i}    IN RANGE    20
         Log    The number of loop is ${i}    console=true
         Check if Unit Status is OnAir        hw_type=vDU
    END
    Log                   Step 9-6: Delete temporary file in /tmp folder    console=true
    Execute Command on Specific Pod    specific_pod=oamfh    hw_type=vDU    command=rm /tmp/filename
    Log                   Step 9-7: Compare free space before and after test steps    console=true
    ${end_free_space}=    Execute Command on Specific Pod    specific_pod=oamfh    hw_type=vDU
    ...                   command=df -BM /tmp | awk 'FNR == 2 {{print $4}}' | sed 's/[A-Za-z]//g'
    Should be Equal       ${free_space}    ${end_free_space}
    [Teardown]    Run Keywords    Execute Command on Specific Pod    specific_pod=oamext    hw_type=vDU
    ...                                                              command=rm /tmp/filename
    ...    AND                    Execute Command on Specific Pod    specific_pod=cprt      hw_type=vDU
    ...                                                              command=rm /tmp/filename
    ...    AND                    Execute Command on Specific Pod    specific_pod=oamfh     hw_type=vDU
    ...                                                              command=rm /tmp/filename

Authorization_Policy
    Log                           Step 1: Login to TLs cluster    console=true
    SSHLibrary.Open Connection    host=${SSH_VCU_IP}
    SSHLibrary.Login              username=${SSH_USERNAME}    password=${SSH_PASSWORD}
    Sleep    3                    reason=Wait until terminal execute the command
    Log                           Step 3: Verify abilities to perform operation without admin rights    console=true
    SSHLibrary.Write              cat .bashrc
    Sleep    2                    reason=Wait until terminal execute the command
    ${output}=                    SSHLibrary.Read
    Should not Contain            ${output}    ${perm_denied}
    Log                           Step 4: Verify lack of abilities to perform operation without admin rights
    ...                           console=true
    SSHLibrary.Write              cat /etc/shadow
    Sleep    2                    reason=Wait until terminal execute the command
    ${output}=                    SSHLibrary.Read
    Should Contain                ${output}    ${perm_denied}
    Log                           Step 5: Verify abilities to perform operation with admin rights    console=true
    SSHLibrary.Write              sudo cat /etc/shadow
    Sleep    2                    reason=Wait until terminal execute the command
    ${output}=                    SSHLibrary.Read
    Should not Contain            ${output}    ${perm_denied}
    [Teardown]                    SSHLibrary.Close Connection

Protecting_data_and_information_in_transfer-IPSEC_vCU
    Log                             Step 2-6: Configure IPSEC    console=true
    Change Parameters on BTS Using XML File    xml=${CURDIR}/../Resources/Delta_files/IPSEC_config.xml    hw_type=vCU
    Log                             Step 7: Add IPSEC to routing table    console=true
    ${values_dict}=                 Create Dictionary    destinationIpPrefixLength=32    destIpAddr=${ipsec_gw}
    ...                                                  gateway=${F1U_VCU_GATEWAY}
    ${values}=                      Create List    ${values_dict}
    Add Parameter on BTS            dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/TNL-3/IPNO-1/IPRT-1
    ...                             param_name=staticRoutes    param_value=${values}    hw_type=vCU
    Log                             Step 8: Install IPSEC certificate    console=true
    Configure CMP                   ca_subject_name=${ipsec_cert}    hw_type=vCU
    Update CMP Server Settings      hw_type=vCU
    Initialize Certificate          hw_type=vCU
    Log                             Step 9: Start collecting pcap    console=true
    Start TCPdump                   capture_type=pod    pod_names=po-upue-0    hw_type=vCU
    Sleep    3s                     reason=TCPdump
    Log                             Step 10: Turn on ipSecEnabled    console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/TNL-3/IPAPP-1/IPSECC-1
    ...                             param_name=ipSecEnabled    param_value=true    hw_type=vCU
    Log                             Step 11: Verify if IPSEC connection is established    console=true
    Wait Until Keyword Succeeds     3min    5s    Verify IP Secuirty Associations
    Log                             Step 12: Download pcap and verify that traffic is protected    console=true
    Sleep    3s                     reason=TCPdump
    ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=po-upue-0     hw_type=vCU
    Convert pcap to XML             filename=${pcap_path}    xml_name=${CURDIR}/pcap_request.txt
    ...                             filters=isakmp && ip.dst==${ipsec_gw}
    Convert pcap to XML             filename=${pcap_path}    xml_name=${CURDIR}/pcap_response.txt
    ...                             filters=isakmp && ip.dst==${NGU_VCU}
    ${pcap_request}=                OperatingSystem.Get File    ${CURDIR}/pcap_request.txt
    ${pcap_response}=               OperatingSystem.Get File    ${CURDIR}/pcap_response.txt
    Should Contain                  ${pcap_request}     IKE_SA_INIT
    Should Contain                  ${pcap_request}     IKE_AUTH
    Should Contain                  ${pcap_response}    IKE_SA_INIT
    Should Contain                  ${pcap_response}    IKE_AUTH
    [Teardown]                      Run Keywords    Change Parameter on BTS
    ...                             dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/TNL-3/IPAPP-1/IPSECC-1
    ...                             param_name=ipSecEnabled    param_value=false    hw_type=vCU
    ...    AND                      Restore Default Certificates on BTS    hw_type=vCU
    ...    AND                      Run Keyword and Ignore Error    Stop TCPdump and Download Pcap
    ...                             pod_name=po-upue-0     hw_type=vCU
    ...    AND                      Run    rm ${CURDIR}/pcap_request.txt
    ...    AND                      Run    rm ${CURDIR}/pcap_response.txt

NESAS-B_Cloud_Password_Structure_Change_Hiding
    Log  Step 1: Connecting to vCU using BTS System Administrator and default password - expect error     console=true
#    Run Keyword and Expect Error    *         Connect to ADMIN      password=${old_default_password}
#    ...                                                             hw_type=vCU
    Sleep       10s
    Log  Step 2: Connecting to vCU using BTS System Administrator   console=true
    ${conn}=    Connect to ADMIN    hw_type=vCU
    Log  Step 3: Check if on vCU is visible warning with expiration time on main webEM page after login   console=true
    ${localPasswdExpiryPeriod}=     Check Parameter Value           param_name=localPasswdExpiryPeriod
    ...                                                             dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1/LUAC_R-1
    ...                                                             hw_type=vCU
    Run Keyword If                  ${localPasswdExpiryPeriod}==0   Change Parameter on BTS    dist_name=${dist_name1}
    ...                                                                                        param_name=localPasswdExpiryPeriod
    ...                                                                                        param_value=90
    ...                                                                                        hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=localPasswdWarningPeriod
    ...                             param_value=89
    ...                             hw_type=vCU
    Log  Step 4: Check if parameters are configured                 console=true
    FOR  ${parameter}   IN    @{parameters}
        ${dist_name}         Run Keyword if   '${parameter}'=='localPasswdExpiryPeriod'    Set Variable    ${dist_name1}
        ...            ELSE IF                '${parameter}'=='localPasswdWarningPeriod'   Set Variable    ${dist_name2}
        ...            ELSE                    Set Variable                             MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
        ${value_of_parmameter}=                Check Parameter Value                    param_name=${parameter}
        ...                                                                             dist_name=${dist_name}
        ...                                                                             hw_type=vCU
        Should Not be true   ${value_of_parmameter}==0
        Log    Parameter: ${parameter} is configured.               console=true
    END
    Log  Step 5: Changing minPasswordLength with value lower than 8 - expect error             console=true
    Run Keyword And Expect Error    *${error_minlenght}*            Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                                                                                        param_name=minPasswordLength
    ...                                                                                        param_value=7
    ...                                                                                        hw_type=vCU
    Log  Step 6: Changing minNonAlphaNumInPassword with value 2 and try to change password to Nokia@123a.    console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=minNonAlphaNumInPassword
    ...                             param_value=2
    ...                             hw_type=vCU
    Run Keyword And Expect Error    *${error_password}*             Change Local User Account Password
    ...                                                             ${WEBEM_USERNAME}
    ...                                                             ${WEBEM_PASSWORD}
    ...                                                             ${new_password}
    ...                                                             hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=minNonAlphaNumInPassword
    ...                             param_value=1
    ...                             hw_type=vCU
    Log  Step 6: Changing passwords for local users                 console=true
    FOR  ${password}   IN    @{passwords}
        Run Keyword And Expect Error           *${error_user}*      Setup Local User Account
        ...                                                         account_type=${sec_username}
        ...                                                         password=${password}
        ...                                                         status=active
        ...                                                         hw_type=vCU
    END
    Setup Local User Account        account_type=${sec_username}
    ...                             password=${WEBEM_PASSWORD}
    ...                             status=active
    ...                             hw_type=vCU
    Log    Password for ${sec_username} is changed                  console=true
    FOR  ${password}   IN    @{passwords}
        Run Keyword And Expect Error           *${error_user}*      Setup Local User Account
        ...                                                         account_type=${app_username}
        ...                                                         password=${password}
        ...                                                         status=active
        ...                                                         hw_type=vCU
    END
    Setup Local User Account        account_type=${app_username}
    ...                             password=${WEBEM_PASSWORD}
    ...                             status=active
    ...                             hw_type=vCU
    Log    Password for ${app_username} is changed                  console=true
    FOR  ${password}   IN    @{passwords}
        Run Keyword And Expect Error           *${error_user}*      Setup Local User Account
        ...                                                         account_type=${read_username}
        ...                                                         password=${password}
        ...                                                         status=active
        ...                                                         hw_type=vCU
    END
    Setup Local User Account        account_type=${read_username}
    ...                             password=${WEBEM_PASSWORD}
    ...                             status=active
    ...                             hw_type=vCU
    Log    Password for ${read_username} is changed                 console=true
    FOR  ${password}   IN    @{passwords}
        Run Keyword And Expect Error          *${error}*            Change Local User Account Password
        ...                                                         ${WEBEM_USERNAME}
        ...                                                         ${WEBEM_PASSWORD}
        ...                                                         ${password}
        ...                                                         hw_type=vCU
    END
    Log  Step 7: Changing parameter passwdHistoryLength as 1        console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=passwdHistoryLength
    ...                             param_value=1
    ...                             hw_type=vCU
    Log  Step 6: Changing passwords for Nemuadmin                    console=true
    Change Local User Account Password        ${WEBEM_USERNAME}
    ...                                       ${WEBEM_PASSWORD}
    ...                                       ${WEBEM_PASSWORD}!
    ...                                       hw_type=vCU
    Log  Step 8: Connecting to Admin with new password               console=true
    ${conn_TEMP}=     Connect to ADMIN        username=${WEBEM_USERNAME}
    ...                                       password=${WEBEM_PASSWORD}!
    ...                                       hw_type=vCU
    Log  Step 9: Changing passwords for Nemuadmin like in step 2     console=true
    Run Keyword And Expect Error              *${error}*             Change Password For Specified Connection
    ...                                                              username=${WEBEM_USERNAME}
    ...                                                              password=${WEBEM_PASSWORD}!
    ...                                                              new_password=${WEBEM_PASSWORD}
    ...                                                              connection=${conn_TEMP}
    ...                                                              hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/SECADM-1
    ...                             param_name=passwdHistoryLength
    ...                             param_value=0
    ...                             hw_type=vCU
    ...                             pre-connection=${conn_TEMP}
    Log  Step 10: Setting enableDefaultPasswdAlarm = true and expect alarm               console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm
    ...                             param_value=true
    ...                             hw_type=vCU
    ...                             pre-connection=${conn_TEMP}
    ${alarms_list}=   Get Active Alarms From BTS                      hw_type=vCU
    ...                                                               pre-connection=${conn_TEMP}
    ${alarms}=        Convert to String      ${alarms_list}
    Log    Checking if "User Account has Default Password" alarm is visible on BTS       console=true
    Should Contain    ${alarms}              ${fault 4459}
    Log  Step 11: Setting enableDefaultPasswdAlarm = false and checking if alarm is not raised         console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm
    ...                             param_value=false
    ...                             hw_type=vCU
    ...                             pre-connection=${conn_TEMP}
    ${alarms_list}=   Get Active Alarms From BTS                       hw_type=vCU
    ...                                                                pre-connection=${conn_TEMP}
    ${alarms}=        Convert to String      ${alarms_list}
    Log    Checking if "User Account has Default Password" alarm is not visible on BTS                 console=true
    Should Not Contain  ${alarms}            ${fault 4459}
    [Teardown]        Change Password For Specified Connection
    ...               username=${WEBEM_USERNAME}
    ...               password=${WEBEM_PASSWORD}!
    ...               new_password=${WEBEM_PASSWORD}
    ...               connection=${conn_TEMP}
    ...               hw_type=vCU

NESAS-CR_Acount_Management_With_Mandatory_Password_Update
    Log  Step 1: Connecting to vDU using System Administrator account     console=true
    Connect to ADMIN      hw_type=vDU
    Log  Step 2: Changing password for System Administrator account       console=true
    Change Local User Account Password    ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${local_password}  hw_type=vDU
    Log  Step 3: Connecting to vDU using System Administrator account with new password                console=true
    ${connection}=                         Connect to ADMIN     username=${WEBEM_USERNAME}
    ...                                    password=${local_password}     hw_type=vDU
    Log  Step 4: Changing parameter enableDefaultPasswdAlarm on vDU       console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=true    hw_type=vDU    pre-connection=${connection}
    Sleep  60s   reason = Waiting until alarms occure
    Log  Step 4: Checking alarms on vDU    console=true
    Alarm Should be Active          alarm=4459    hw_type=vDU       pre-connection=${connection}
    Log  Step 5: Changing password for wsuser account       console=true
    Change Service User Password    username=${WSUSER_LOGIN}    password=${DEFAULT_WSUSER_PWD}    new_password=${NEW_WSUSER_PWD}    hw_type=vDU
    ...                             pre-connection=${connection}
    Log  Step 6: Checking alarms on vDU    console=true
    Wait until keyword succeeds     3x  10s     Alarm Should not be Active    4459    vDU    ${connection}
    Log    Alarm 4459 is cleared due to password change!    console=true
    [Teardown]    Run keywords      Log    Setting up BTS to previous values!    console=true
    ...    AND                      Change Service User Password    username=${WSUSER_LOGIN}
    ...                             password=${NEW_WSUSER_PWD}   new_password=${DEFAULT_WSUSER_PWD}   hw_type=vDU    pre-connection=${connection}
    ...    AND                      Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1
    ...                             param_name=enableDefaultPasswdAlarm    param_value=false    hw_type=vDU         pre-connection=${connection}
    ...    AND                      Change Password For Specified Connection
    ...                             username=${WEBEM_USERNAME}
    ...                              password=${local_password}
    ...                              new_password=${WEBEM_PASSWORD}
    ...                              connection=${connection}
    ...                              hw_type=vDU

NESAS-CR_Session_Login_Delay_vDU
    Log  Preconditions- creating user.txt and pass.txt and send it to Test PC   console=true
    Send Files to Test PC
    Log  Step 1: Login to vDU WebEM with Nemuadmin account                      console=true
    ${conn}=    Connect to ADMIN    hw_type=vDU
    Log  Step 2: Configuring parameters to prevent from bruteforce              console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsMaxFailedLoginAttempts
    ...                             param_value=10
    ...                             hw_type=vDU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsSessionLoginDelay
    ...                             param_value=10
    ...                             hw_type=vDU
    Log  Step 3: Login with SSH to TestPC with hydra tool installed             console=true
    SSHLibrary.Open Connection      ${PC_IP}
    SSHLibrary.Login                ${PC_username}          ${PC_password}
    Log  Step 3: Run commands with hydra tool               console=true
    SSHLibrary.Write      hydra -vv -L user.txt -P pass.txt ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I -t4
    Sleep    2            reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_failed}
    ${error}              Run Keyword and Expect Error   *  Connect to ADMIN    hw_type=vDU
    Should Contain        ${error}   ${Login_delay_error}
    Sleep    5            reason=Wait until login delay is finised
    SSHLibrary.Write      hydra -vv -l Nemuadmin -p Nemuuser ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I
    Sleep    2            reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_failed}
    SSHLibrary.Write      hydra -vv -l Nemuadmin -p Nokia@123 ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I
    Sleep    2            reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_failed}
    SSHLibrary.Write      sleep 10 && hydra -vv -l Nemuadmin -p Nokia@123 ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I
    Sleep    12           reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_passed}
    [Teardown]            Run Keywords                       SSHLibrary.Close Connection
    ...                   AND                                Change Parameter on BTS
    ...                                                      dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                                      param_name=btsMaxFailedLoginAttempts
    ...                                                      param_value=0
    ...                                                      hw_type=vDU

NESAS-CR_Session_Login_Delay_vCU
    Log  Preconditions- creating user.txt and pass.txt and send it to Test PC   console=true
    Send Files to Test PC
    Log  Login to vCU WebEM with Nemuadmin account                              console=true
    ${conn}=    Connect to ADMIN    hw_type=vCU
    Log  Step 2: Configuring parameters to prevent from bruteforce              console=true
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsMaxFailedLoginAttempts
    ...                             param_value=10
    ...                             hw_type=vCU
    Change Parameter on BTS         dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=btsSessionLoginDelay
    ...                             param_value=10
    ...                             hw_type=vCU
    Log  Step 3: Login with SSH to TestPC with hydra tool installed             console=true
    SSHLibrary.Open Connection      ${PC_IP}
    SSHLibrary.Login                ${PC_username}          ${PC_password}
    Log  Step 3: Run commands with hydra tool               console=true
    SSHLibrary.Write      hydra -vv -L user.txt -P pass.txt ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I -t4
    Sleep    2            reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_failed}
    ${error}              Run Keyword and Expect Error   *  Connect to ADMIN    hw_type=vCU
    Should Contain        ${error}   AuthenticationFailed
    Sleep    5            reason=Wait until login delay is finised
    SSHLibrary.Write      hydra -vv -l Nemuadmin -p Nemuuser ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I
    Sleep    2            reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_failed}
    SSHLibrary.Write      hydra -vv -l Nemuadmin -p Nokia@123 ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I
    Sleep    2            reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_failed}
    SSHLibrary.Write      sleep 10 && hydra -vv -l Nemuadmin -p Nokia@123 ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I
    Sleep    12           reason=Wait until terminal execute the command
    ${output}=            SSHLibrary.Read
    Should Contain        ${output}  ${hydra_passed}
    [Teardown]            Run Keywords                       SSHLibrary.Close Connection
    ...                   AND                                Change Parameter on BTS
    ...                                                      dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                                                      param_name=btsMaxFailedLoginAttempts
    ...                                                      param_value=0
    ...                                                      hw_type=vCU


NESAS-CR_Protection_Against_Bruteforce_Attack_vCU

    Log To Console    \nOpen SSH connection to testPC...    no_newline=True
    Enable Ssh Logging    ${TEST_LOGS_DIR}/SSHlog.txt
    ${PC_connection}=    Open Connection    ${TEST_PC_IP}
    Login    ${TEST_PC_LOGIN}    ${TEST_PC_PASSWD}
    Log To Console    ${SPACE}OK!

    Log To Console    Check if hydra is installed...    no_newline=True
    ${output} =    Execute Command    which hydra
    ${status}=    Get Regexp Matches    ${output}   hydra
    IF    ${status}
        Log To Console    ${SPACE}OK!
    ELSE
        Log To Console    ${SPACE}NOT OK!
        Log To Console    Installing hydra...    no_newline=True
        ${installation}=    Execute Command    sudo apt install hydra -y    sudo=True    sudo_password=${TEST_PC_PASSWD}
        Log To Console   install: ${installation}
        ${output} =    Execute Command    which hydra
        ${status}=    Get Regexp Matches    ${output}   hydra
        IF   ${status}
            Log To Console    ${SPACE}OK!
        ELSE
            Log To Console    ${SPACE}FAILED!
            Fail    msg=ERROR!\n${status}\n${installation}
        END
    END

    Log To Console    Start alarm watchdog detection & check onAir status...
    Start Watchdog    hw_type=vCU
    Run Keyword And Continue On Failure    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vCU
    Check if Unit Status is OnAir    hw_type=vCU
    Log To Console    Start alarm watchdog detection & check onAir status... OK!

    Log To Console    BTS parametrs comissionig...
    Change Parameter on BTS    hw_type=vCU    dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsFailedLoginCountingPeriod    param_value=10
    Change Parameter on BTS    hw_type=vCU    dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsMaxFailedLoginAttempts   param_value=${MAX_LOGIN_FAILED_ATTEMPTS}
    Change Parameter on BTS    hw_type=vCU    dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsAccountLockoutDuration   param_value=2
    Change Parameter on BTS    hw_type=vCU    dist_name=MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsSessionLoginDelay    param_value=1
    Log To Console    BTS parametrs comissionig... OK!

    Log To Console    Enabling BTSSecurity user on BTS...
    Setup Local User Account    hw_type=vCU    account_type=BTSSecurity    password=Security@123    status=active
    Log To Console    Enabling BTSSecurity user on BTS... OK!

    Add Alarm to the Allowed List   hw_type=vCU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked

    FOR   ${i}   IN RANGE    ${MAX_LOGIN_FAILED_ATTEMPTS}+1
        ${pass}=    Set Variable    ofc_wrong_pass_${i}
        LOG TO CONSOLE   ${i+1}. Try to bruteforce the WebEm with credentials:\n${SPACE*4}${WEBEM_USERNAME}/${pass}...    no_newline=True
        ${output}=    Run Keyword And Ignore Error    Execute Command
        ...    hydra -vv -l ${WEBEM_USERNAME} -p ${pass} ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I -t4
        Should Contain    ${output[1]}
        ...               1 target completed, 0 valid password    msg=Error during execution, authentication failed during login expected
        Sleep    1s    msg='btsSessionLoginDelay = 1s'
        Log To Console    ${SPACE}OK!
    END

    Log To Console    Wait for fid:61642 - BTS Local OAM user account ${WEBEM_USERNAME} has been locked...    no_newline=True
    Wait Until Alarm Appears    hw_type=vCU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked    timeout=2
    ${alarm_raised_timestamp}=    Get Current Date
    Log To Console    ${SPACE}OK!

    Log To Console    Check if account is locked...    no_newline=True
    ${output}=    Run Keyword And Ignore Error
    ...    Connect to ADMIN    hw_type=vCU    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    alias=after_bruteforce_locked
    Should Contain    ${output[1]}    Authentication failed    Account locked due to 11 failed logins
    Log To Console    ${SPACE}OK!

    Log To Console    Check if hydra break credentials while account is locked...    no_newline=True
    ${output}=    Run Keyword And Ignore Error    Execute Command
    ...    hydra -vv -l ${WEBEM_USERNAME} -p ${WEBEM_PASSWORD} ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I -t4
    Should Contain    ${output[1]}    1 target completed, 0 valid password    msg=Error during execution, account locked during login expected
    Log To Console    ${SPACE}OK!

    Log To Console    Check if login on BTSSecurity account is possible...
    ${connection}=    Connect to ADMIN    hw_type=vCU    username=BTSSecurity    password=Security@123    alias=after_bruteforce_BTSSecurity
    Disconnect from ADMIN    hw_type=vCU    connection=${connection}
    Log To Console    Check if login on BTSSecurity account is possible... OK!

    Log To Console    Wait for fid:61642 - BTS Local OAM user account ${WEBEM_USERNAME} has been cleared...    no_newline=True
    Wait Until Alarm Disappears    hw_type=vCU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked
    ...                            timeout=120
    ${alarm_cleared_timestamp}=    Get Current Date
    ${alarm_rise_time}=    Subtract Date From Date    ${alarm_cleared_timestamp}     ${alarm_raised_timestamp}    result_format=number
    Remove Alarm from Allowed List    hw_type=vCU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked
    IF    ${alarm_rise_time} < 118
        Log To Console    ${SPACE}FAILED!
        Run Keyword And Continue On Failure    Fail    msg=Alarm was raised for ${alarm_rise_time}seconds, expected about 120 seconds
    ELSE
        Log To Console    ${SPACE}OK!
    END

    Log To Console    Check with hydra if account is unlocked...    no_newline=True
    ${output}=    Execute Command    hydra -vv -l ${WEBEM_USERNAME} -p ${WEBEM_PASSWORD} ${LMP_VCU_IP} https-post "/api/sec/v1/login" -I -t4
    Should Contain    ${output}    1 target successfully completed, 1 valid password found
    ...   msg=Error during execution, login should proceed - account should be unlocked
    Log To Console    ${SPACE}OK!

    Log To Console   Check alarms...    no_newline=True
    Check if Disallowed Alarm was Detected during Watchdog   hw_type=vCU
    Log To Console    ${SPACE}OK!

    [Teardown]    Run Keywords
                  ...    Close All Connections    AND
                  ...    Stop Watchdog    hw_type=vCU   AND
                  ...    Setup Local User Account    hw_type=vCU    account_type=BTSSecurity    password=Security@123    status=deactive


NESAS-CR_Protection_Against_Bruteforce_Attack_vDU

    Log To Console    \nOpen SSH connection to testPC...    no_newline=True
    Enable Ssh Logging    ${TEST_LOGS_DIR}/SSHlog.txt
    ${PC_connection}=    Open Connection    ${TEST_PC_IP}
    Login    ${TEST_PC_LOGIN}    ${TEST_PC_PASSWD}
    Log To Console    ${SPACE}OK!

    Log To Console    Check if hydra is installed...    no_newline=True
    ${output} =    Execute Command    which hydra
    ${status}=    Get Regexp Matches    ${output}   hydra
    IF    ${status}
        Log To Console    ${SPACE}OK!
    ELSE
        Log To Console    ${SPACE}NOT OK!
        Log To Console    Installing hydra...    no_newline=True
        ${installation}=    Execute Command    sudo apt install hydra -y    sudo=True    sudo_password=${TEST_PC_PASSWD}
        Log To Console   install: ${installation}
        ${output} =    Execute Command    which hydra
        ${status}=    Get Regexp Matches    ${output}   hydra
        IF   ${status}
            Log To Console    ${SPACE}OK!
        ELSE
            Log To Console    ${SPACE}FAILED!
            Fail    msg=ERROR!\n${status}\n${installation}
        END
    END

    Log To Console    Start alarm watchdog detection & check onAir status...
    Start Watchdog    hw_type=vDU
    Run Keyword And Continue On Failure    Check if Disallowed Alarm was Detected during Watchdog    hw_type=vDU
    Check if Unit Status is OnAir    hw_type=vDU
    Log To Console    Start alarm watchdog detection & check onAir status... OK!

    Log To Console    BTS parametrs comissionig...
    Change Parameter on BTS    hw_type=vDU    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsFailedLoginCountingPeriod    param_value=10
    Change Parameter on BTS    hw_type=vDU    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsMaxFailedLoginAttempts   param_value=${MAX_LOGIN_FAILED_ATTEMPTS}
    Change Parameter on BTS    hw_type=vDU    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsAccountLockoutDuration   param_value=2
    Change Parameter on BTS    hw_type=vDU    dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...    param_name=btsSessionLoginDelay    param_value=1
    Log To Console    BTS parametrs comissionig... OK!

    Log To Console    Enabling BTSSecurity user on BTS...
    Setup Local User Account    hw_type=vDU    account_type=BTSSecurity    password=Security@123    status=active
    Log To Console    Enabling BTSSecurity user on BTS... OK!

    Add Alarm to the Allowed List   hw_type=vDU    fault_id=61642    fault_name=BTS Local OAM user account Nemuadmin has been locked

    FOR   ${i}   IN RANGE    ${MAX_LOGIN_FAILED_ATTEMPTS}+1
        ${pass}=    Set Variable    ofc_wrong_pass_${i}
        LOG TO CONSOLE   ${i+1}. Try to bruteforce the WebEm with credentials:\n${SPACE*4}${WEBEM_USERNAME}/${pass}...    no_newline=True
        ${output}=    Run Keyword And Ignore Error    Execute Command
        ...    hydra -vv -l ${WEBEM_USERNAME} -p ${pass} ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I -t4
        Should Contain    ${output[1]}
        ...               1 target completed, 0 valid password    msg=Error during execution, authentication failed during login expected
        Sleep    1s    msg='btsSessionLoginDelay = 1s'
        Log To Console    ${SPACE}OK!
    END

    Log To Console    Wait for fid:61642 - BTS Local OAM user account ${WEBEM_USERNAME} has been locked...    no_newline=True
    Wait Until Alarm Appears    hw_type=vDU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked    timeout=2
    ${alarm_raised_timestamp}=    Get Current Date
    Log To Console    ${SPACE}OK!

    Log To Console    Check if account is locked...    no_newline=True
    ${output}=    Run Keyword And Ignore Error
    ...    Connect to ADMIN    hw_type=vDU    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    alias=after_bruteforce_locked
    Should Contain    ${output[1]}    Authentication failed    Account locked due to 11 failed logins
    Log To Console    ${SPACE}OK!

    Log To Console    Check if hydra break credentials while account is locked...    no_newline=True
    ${output}=    Run Keyword And Ignore Error    Execute Command
    ...    hydra -vv -l ${WEBEM_USERNAME} -p ${WEBEM_PASSWORD} ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I -t4
    Should Contain    ${output[1]}    1 target completed, 0 valid password    msg=Error during execution, account locked during login expected
    Log To Console    ${SPACE}OK!

    Log To Console    Check if login on BTSSecurity account is possible...
    ${connection}=    Connect to ADMIN    hw_type=vDU    username=BTSSecurity    password=Security@123    alias=after_bruteforce_BTSSecurity
    Disconnect from ADMIN    hw_type=vDU    connection=${connection}
    Log To Console    Check if login on BTSSecurity account is possible... OK!

    Log To Console    Wait for fid:61642 - BTS Local OAM user account ${WEBEM_USERNAME} has been cleared...    no_newline=True
    Wait Until Alarm Disappears    hw_type=vDU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked
    ...                            timeout=120
    ${alarm_cleared_timestamp}=    Get Current Date
    ${alarm_rise_time}=    Subtract Date From Date    ${alarm_cleared_timestamp}     ${alarm_raised_timestamp}    result_format=number
    Remove Alarm from Allowed List    hw_type=vDU    fault_id=61642    fault_name=BTS Local OAM user account ${WEBEM_USERNAME} has been locked
    IF    ${alarm_rise_time} < 118
        Log To Console    ${SPACE}FAILED!
        Run Keyword And Continue On Failure    Fail    msg=Alarm was raised for ${alarm_rise_time}seconds, expected about 120 seconds
    ELSE
        Log To Console    ${SPACE}OK!
    END

    Log To Console    Check with hydra if account is unlocked...    no_newline=True
    ${output}=    Execute Command    hydra -vv -l ${WEBEM_USERNAME} -p ${WEBEM_PASSWORD} ${LMP_VDU_IP} https-post "/api/sec/v1/login" -I -t4
    Should Contain    ${output}    1 target successfully completed, 1 valid password found
    ...   msg=Error during execution, login should proceed - account should be unlocked
    Log To Console    ${SPACE}OK!

    Log To Console   Check alarms...    no_newline=True
    Check if Disallowed Alarm was Detected during Watchdog   hw_type=vDU
    Log To Console    ${SPACE}OK!

    [Teardown]    Run Keywords
                  ...    Close All Connections    AND
                  ...    Stop Watchdog    hw_type=vDU   AND
                  ...    Setup Local User Account    hw_type=vDU    account_type=BTSSecurity    password=Security@123    status=deactive

NESAS-B_Role_based_access_control_vDU_System_Administrator
    Log  Step 1: Connecting to vDU using System Administrator account   console=true
    ${connection}=          Connect to ADMIN      hw_type=vDU
    Log  Step 2: Locking Cell using System Administrator account        console=true
    ${cells_ID}=            Get Cell ID           hw_type=vDU
    Lock Cell               cells_ID=${cells_ID}
    ...                     connection=${connection}
    ...                     hw_type=vDU
    Sleep  1 minutes        reason = Waiting until cells are locked
    Log    Cell with id ${cells_ID} is locked
    Log  Step 3: Unocking Cell using System Administrator account       console=true
    Unlock Cell             cells_ID=${cells_ID}
    ...                     connection=${connection}
    ...                     hw_type=vDU
    Log    Cell with id ${cells_ID} is unlocked
    Log  Step 4: Changing Admin password using System Administrator account         console=true
    Change Local User Account Password    ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${local_password}  hw_type=vDU
    ${conn_TEMP}=                        Connect to ADMIN     username=${WEBEM_USERNAME}
    ...                                  password=${local_password}     hw_type=vDU
    [Teardown]              Change Password For Specified Connection
    ...                     username=${WEBEM_USERNAME}
    ...                     password=${local_password}
    ...                     new_password=${WEBEM_PASSWORD}
    ...                     connection=${conn_TEMP}
    ...                     hw_type=vDU

NESAS-B_Role_based_access_control_vCU_System_Administrator
    Log  Step 1: Connecting to vCU using System Administrator account   console=true
    ${connection}=          Connect to ADMIN      hw_type=vCU
    Log  Step 2: Locking Cell using System Administrator account        console=true
    ${cells_ID}=            Get Cell ID           hw_type=vCU
    ...                                           connection=${connection}
    Lock Cell               cells_ID=${cells_ID}
    ...                     connection=${connection}
    ...                     hw_type=vCU
    Sleep  1 minutes        reason = Waiting until cells are locked
    Log    Cell with id ${cells_ID} is locked
    Log  Step 3: Unocking Cell using System Administrator account       console=true
    Unlock Cell             cells_ID=${cells_ID}
    ...                     connection=${connection}
    ...                     hw_type=vCU
    Log    Cell with id ${cells_ID} is unlocked
    Log  Step 4: Changing Admin password using System Administrator account         console=true
    Change Local User Account Password   ${WEBEM_USERNAME}    ${WEBEM_PASSWORD}    ${local_password}  hw_type=vCU
    ${conn_TEMP}=                        Connect to ADMIN     username=${WEBEM_USERNAME}
    ...                                  password=${local_password}     hw_type=vCU
    [Teardown]            Change Password For Specified Connection
    ...                   username=${WEBEM_USERNAME}
    ...                   password=${local_password}
    ...                   new_password=${WEBEM_PASSWORD}
    ...                   connection=${conn_TEMP}
    ...                   hw_type=vCU

NESAS-B_Role_based_access_control_vDU_Security_Administrator
    Log  Step 1: Creating and connecting to vDU using Security Administrator account   console=true
    Setup Local User Account             account_type=${sec_username}  password=${local_password}
    ...                                  status=active                 hw_type=vDU
    ${conn_sec}=                         Connect to ADMIN              username=${sec_username}
    ...                                  password=${local_password}    alias=sec                        hw_type=vDU
    Log  Step 2: Changing password for the Security Administrator using Security Administrator account  console=true
    Change Password For Specified Connection
    ...               username=${sec_username}
    ...               password=${local_password}
    ...               new_password=${new_password}
    ...               connection=${conn_sec}
    ...               hw_type=vDU
#    ${conn_sec}=                         Connect to ADMIN              username=${sec_username}
#    ...                                  password=${new_password}      alias=sec                        hw_type=vDU
    Log  Step 3: Locking Cell using Security Administrator account and expect error  console=true
    ${cells_ID}=      Get Cell ID         hw_type=vDU
    ...                                   connection=${conn_sec}
    Run Keyword and Expect Error   *      Lock Cell
    ...                                   cells_ID=${cells_ID}
    ...                                   connection=${conn_sec}
    ...                                   hw_type=vDU
    Log  Step 4: Changing password for the System Administrator using Security Administrator account   console=true
    Run Keyword and Expect Error         *                               Change Password For Specified Connection
    ...                                                                  username=${sys_username}
    ...                                                                  password=${local_password}
    ...                                                                  new_password=${new_password}
    ...                                                                  connection=${conn_sec}
    ...                                                                  hw_type=vDU
    [Teardown]        Run Keywords         Disconnect from ADMIN         connection=${conn_sec}          hw_type=vDU
    ...               AND                  Setup Local User Account      account_type=${sec_username}    password=${local_password}
    ...                                                                  status=active                   hw_type=vDU

NESAS-B_Role_based_access_control_vCU_Security_Administrator
    Log  Step 1: Creating and connecting to vCU using Security Administrator account   console=true
    Setup Local User Account             account_type=${sec_username}    password=${local_password}
    ...                                  status=active                   hw_type=vCU
    ${conn_sec}=                         Connect to ADMIN                username=${sec_username}
    ...                                  password=${local_password}      alias=sec                       hw_type=vCU
    Log  Step 2: Changing password for the Security Administrator using Security Administrator account  console=true
    Change Password For Specified Connection
    ...               username=${sec_username}
    ...               password=${local_password}
    ...               new_password=${new_password}
    ...               connection=${conn_sec}
    ...               hw_type=vCU
    Log  Step 3: Locking Cell using Security Administrator account and expect error  console=true
    ${cells_ID}=      Get Cell ID         hw_type=vCU
    ...                                   connection=${conn_sec}
    Run Keyword and Expect Error     *    Lock Cell
    ...                                   cells_ID=${cells_ID}
    ...                                   connection=${conn_sec}
    ...                                   hw_type=vCU
    Log  Step 4: Changing password for the System Administrator using Security Administrator account   console=true
    Run Keyword and Expect Error          *                             Change Password For Specified Connection
    ...                                                                 username=${sys_username}
    ...                                                                 password=${local_password}
    ...                                                                 new_password=${new_password}
    ...                                                                 connection=${conn_sec}
    ...                                                                 hw_type=vCU
    [Teardown]        Run Keywords           Disconnect from ADMIN      connection=${conn_sec}          hw_type=vCU
    ...               AND                    Setup Local User Account   account_type=${sec_username}    password=${local_password}
    ...                                                                 status=active                   hw_type=vCU

NESAS-B_Role_based_access_control_vDU_Application_Administrator
    Log  Step 1: Creating and connecting to vDU using Application Administrator account   console=true
    Setup Local User Account             account_type=${app_username}   password=${local_password}
    ...                                  status=active                  hw_type=vDU
    ${conn_app}=                         Connect to ADMIN               username=${app_username}
    ...                                  password=${local_password}     alias=app                       hw_type=vDU
    Log  Step 2: Locking and Unlocking Cell using Application Administrator account   console=true
    ${cells_ID}=      Get Cell ID        hw_type=vDU
    ...                                  connection=${conn_app}
    Lock Cell
    ...                                  cells_ID=${cells_ID}
    ...                                  connection=${conn_app}
    ...                                  hw_type=vDU
    Sleep  1 minutes  reason = Waiting until cells are locked
    Log    Cell with id ${cells_ID} is locked
    Unlock Cell       cells_ID=${cells_ID}
    ...               connection=${conn_app}
    ...               hw_type=vDU
    Log    Cell with id ${cells_ID} is unlocked
    Log  Step 3: Changing password for the Application Administrator using Application Administrator account  console=true
    Change Password For Specified Connection
    ...               username=${app_username}
    ...               password=${local_password}
    ...               new_password=${new_password}
    ...               connection=${conn_app}
    ...               hw_type=vDU
    Log  Step 4: Changing password for the System Administrator using Application Administrator account   console=true
    Run Keyword and Expect Error          *                             Change Password For Specified Connection
    ...                                                                 username=${sys_username}
    ...                                                                 password=${local_password}
    ...                                                                 new_password=${new_password}
    ...                                                                 connection=${conn_app}
    ...                                                                 hw_type=vDU
    [Teardown]        Run Keywords        Disconnect from ADMIN         connection=${conn_app}          hw_type=vDU
    ...               AND                 Setup Local User Account      account_type=${app_username}    password=${local_password}
    ...                                                                 status=active                   hw_type=vDU

NESAS-B_Role_based_access_control_vCU_Application_Administrator
    Log  Step 1: Creating and connecting to vCU using Application Administrator account   console=true
    Setup Local User Account             account_type=${app_username}    password=${local_password}
    ...                                  status=active                   hw_type=vCU
    ${conn_app}=                         Connect to ADMIN                username=${app_username}
    ...                                  password=${local_password}      alias=app                      hw_type=vCU
    Log  Step 2: Locking and Unlocking Cell using Application Administrator account   console=true
    ${cells_ID}=      Get Cell ID        hw_type=vCU
    ...                                  connection=${conn_app}
    Lock Cell
    ...                                  cells_ID=${cells_ID}
    ...                                  connection=${conn_app}
    ...                                  hw_type=vCU
    Sleep  1 minutes  reason = Waiting until cells are locked
    Log    Cell with id ${cells_ID} is locked
    Unlock Cell       cells_ID=${cells_ID}
    ...               connection=${conn_app}
    ...               hw_type=vCU
    Log    Cell with id ${cells_ID} is unlocked
    Log  Step 3: Changing password for the Application Administrator using Application Administrator account  console=true
    Change Password For Specified Connection
    ...               username=${app_username}
    ...               password=${local_password}
    ...               new_password=${new_password}
    ...               connection=${conn_app}
    ...               hw_type=vCU
    Log  Step 4: Changing password for the System Administrator using Application Administrator account   console=true
    Run Keyword and Expect Error          *                             Change Password For Specified Connection
    ...                                                                 username=${sys_username}
    ...                                                                 password=${local_password}
    ...                                                                 new_password=${new_password}
    ...                                                                 connection=${conn_app}
    ...                                                                 hw_type=vCU
    [Teardown]        Run Keywords        Disconnect from ADMIN         connection=${conn_app}          hw_type=vCU
    ...               AND                 Setup Local User Account      account_type=${app_username}    password=${local_password}
    ...                                                                 status=active                   hw_type=vCU

NESAS-B_Role_based_access_control_vDU_Read_only_user
    Log  Step 1: Creating and connecting to vDU using Read-only User account   console=true
    Setup Local User Account             account_type=${read_username}  password=${local_password}
    ...                                  status=active                  hw_type=vDU
    ${conn_read}=                        Connect to ADMIN               username=${read_username}
    ...                                  password=${local_password}     alias=read                      hw_type=vDU
    Log  Step 2: Changing password for the Read-only User using Read-only User account                  console=true
    Change Password For Specified Connection
    ...               username=${read_username}
    ...               password=${local_password}
    ...               new_password=${new_password}
    ...               connection=${conn_read}
    ...               hw_type=vDU
    Log  Step 3: Locking Cell using Read-only User account    console=true
    ${cells_ID}=      Get Cell ID        hw_type=vDU
    ...                                  connection=${conn_read}
    Run Keyword and Expect Error     *   Lock Cell
    ...                                  cells_ID=${cells_ID}
    ...                                  connection=${conn_read}
    ...                                  hw_type=vDU
    [Teardown]        Run Keywords       Disconnect from ADMIN            connection=${conn_read}         hw_type=vDU
    ...               AND                Setup Local User Account         account_type=${read_username}   password=${local_password}
    ...                                                                   status=active                   hw_type=vDU

NESAS-B_Role_based_access_control_vCU_Read_only_user
    Log  Step 1: Creating and connecting to vCU using Read-only User account   console=true
    Setup Local User Account             account_type=${read_username}    password=${local_password}
    ...                                  status=active                    hw_type=vCU
    ${conn_read}=                        Connect to ADMIN                 username=${read_username}
    ...                                  password=${local_password}       alias=read                      hw_type=vCU
    Log  Step 2: Changing password for the Read-only User using Read-only User account                  console=true
    Change Password For Specified Connection
    ...               username=${read_username}
    ...               password=${local_password}
    ...               new_password=${new_password}
    ...               connection=${conn_read}
    ...               hw_type=vCU
    Log  Step 3: Locking Cell using Read-only User account    console=true
    ${cells_ID}=      Get Cell ID        hw_type=vCU
    ...                                  connection=${conn_read}
    Run Keyword and Expect Error     *   Lock Cell
    ...                                  cells_ID=${cells_ID}
    ...                                  connection=${conn_read}
    ...                                  hw_type=vCU
    [Teardown]        Run Keywords       Disconnect from ADMIN            connection=${conn_read}           hw_type=vCU
    ...               AND                Setup Local User Account         account_type=${read_username}     password=${local_password}
    ...                                                                   status=active                     hw_type=vCU
