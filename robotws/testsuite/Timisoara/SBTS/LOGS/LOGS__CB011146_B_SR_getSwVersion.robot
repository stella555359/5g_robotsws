*** Settings ***
Documentation    getSwVersion for CB011146
Library     ../../resources/python_resources/admin_cli.py  WITH NAME  hran_admin_cli
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam

*** Variables ***
${cmd_token}    curl https://192.168.255.129/ext/api/auth/v1/login -k -X POST -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Basic TmVtdWFkbWluOm5lbXV1c2Vy" -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"
${cmd_start}    curl https://192.168.255.129/ext/api/swm/v1/software -k -X GET -H "Accept: application/json" -H "Content-Type: application/json"
...    -H "Authorization: Bearer
${cmd_end}     " -d '{ "readOnlyMode": false }' -i -w "\nHTTP Status: '%'{http_code}\n"

${flag1}                     0x450040    # enable ERadOamUri_HasAPIGateWayEnabled (target removed release is 25R3 done)
${flag_with_desired_value1}  0x450040 = 1

${flag2}                     0xA80000    # enable ERadOamApigw_EnableEnvoy (target removed release is 25R3 done)
${flag_with_desired_value2}  0xA80000 = 1

${flag3}                     0x450027    # enable ERadOamUri_EnableDeveloperAccount (will not removed since webem should use this for local debug)
${flag_with_desired_value3}  0x450027 = 1

${flag4}                     0xA80002    # enable ERadOamApigw_EnableDeveloperAccount
${flag_with_desired_value4}  0xA80002 = 1
${alias}     default
*** Keywords ***
TC__LOGS__CB011146_B_SR_getSwVersion

    Step 0: Preconditions
    Step 1: Get SW with token and compare


Step 0: Preconditions
    [Documentation]
    ...   In this step necessary test variables are set.

    Log    \nStep 0: Preconditions    console=${True}
    sleep    4

    # setup flags in swconfig file
    Prepare SWconfig    ${flag1}    ${flag_with_desired_value1}
    log  \nFlag 0x450040 = 1 was successfully added in the SW config  console=${True}
    Prepare SWconfig    ${flag2}    ${flag_with_desired_value2}
    log  \nFlag 0xA80000 = 1 was successfully added in the SW config  console=${True}
    Prepare SWconfig    ${flag3}    ${flag_with_desired_value3}
    log  \nFlag 0x450027 = 1 was successfully added in the SW config  console=${True}
    Prepare SWconfig    ${flag4}    ${flag_with_desired_value4}
    log  \nFlag 0xA80002 = 1 was successfully added in the SW config  console=${True}

    log  \nReset ongoing in order to apply changes made in SWconfig  console=${True}
    Run Keyword And Ignore Error   coam.Reset Site  720

    Wait Until Keyword Succeeds  15m  1m  Check All Modules And All Cells Working States

    coam.connect_to    bts_host=192.168.255.129
    ...    update_interval=1000    name=coam_admin
    ${output_sw}      coam.get_sw_version    timeout=30    connection=coam_admin
    ${sw_info}      coam.get_software_info    timeout=10    connection=coam_admin

    log to console    sw-info:${sw_info}

    Set Test Variable   ${active_gsm_rat_version}     ${sw_info['Active GSM RAT version']}
    Set Test Variable   ${active_lte_rat_version}     ${sw_info['Active LTE RAT version']}
    Set Test Variable   ${active_wcdma_rat_version}   ${sw_info['Active WCDMA RAT version']}
    Set Test Variable   ${active_sw_version}          ${sw_info['Active SW version']}


Step 1: Get SW with token and compare
    [Documentation]
    ...   In this step necessary test variables are set.
    Log    \nStep 1: Get SW with token and compare    console=${True}

    ${output_token}    Run    ${cmd_token}
    ${out}    Fetch From Right    ${output_token}    token":"
    ${token}    Fetch From Left    ${out}    ","type

    ### Concatenate commnad with token
    ${cmd_getSW}    Set Variable    ${cmd_start} ${token}${cmd_end}
    ${output_getSW}    Run    ${cmd_getSW}

    #### Check content
    ${out1}    Fetch From Right    ${output_getSW}  activeGsmSwVersion"
    ${output1}    Fetch From Left    ${out1}    activeLteSwVersion"

    log to console    activeGsmSwVersion:${output1}
    Should contain    ${output1}    ${active_gsm_rat_version}

    ${out2}    Fetch From Right    ${output_getSW}  activeLteSwVersion"
    ${output2}    Fetch From Left    ${out2}    activeNrSwVersion"

    log to console    activeLTESwVersion:${output2}
    Should contain    ${output2}    ${active_lte_rat_version}

    #${out3}    Fetch From Right    ${output_getSW}  activeSwVersion"
    #${output3}    Fetch From Left    ${out3}    activeWcdmaSwVersion"

    #log to console    activeLTESwVersion:${output3}
    #Should contain    ${output3}    ${active_sw_version}

    #${out4}    Fetch From Right    ${output_getSW}  activeWcdmaSwVersion"
    #${output4}    Fetch From Left    ${out4}    HTTP Status:

    #log to console    activeWcdmaSwVersion:${output4}
    #Should contain    ${output4}    ${active_wcdma_rat_version}



Prepare SWconfig
    [Arguments]  ${flag}    ${flag_with_desired_value}
    [Documentation]
    ...  This KW is checking if ${flag} exist in SWconfig on  MSM . If yes, it is changed to ${flag_with_desired_value} value.
    ...  If ${flag} doesn't exist in SWconfig, it is being added.


    SSH Connection
    ###Prepare SWconfig file for MSM
    ${swconfig_MSM}=  ssh.Execute  grep ${flag} /ffs/run/swconfig.txt  connection=${alias}
    ${swconfig_MSM}=  Strip String  ${swconfig_MSM}
    ${flag_exist}=  Evaluate  "${flag}" in """${swconfig_MSM}"""
    Run Keyword If  ${flag_exist}  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}
    ...  AND  Change Flag  ${alias}    ${flag}    ${flag_with_desired_value}
    ...  ELSE  Run Keywords
    ...  Set Test Variable  ${swconfig_MSM}  ""
    ...  AND  Add Flag  ${alias}    ${flag_with_desired_value}


Add Flag
    [Documentation]
    ...  This KW is adding ${flag_with_desired_value} to SWconfig file
    [Arguments]  ${SMOD_Connection}    ${flag_with_desired_value}
    ssh.Execute  command=echo ${flag_with_desired_value} >> /ffs/run/swconfig.txt  connection=${SMOD_Connection}


Change Flag
    [Documentation]
    ...  This KW is checking on which line is ${flag} in SWconfig and replaces that line with ${flag_with_desired_value}
    [Arguments]  ${SMOD_Connection}    ${flag}    ${flag_with_desired_value}
    ${flag_line_nr}=  ssh.Execute  grep -n '${flag}' /ffs/run/swconfig.txt | awk -F: '{print $1}'  connection=${SMOD_Connection}
    ${flag_line_nr}=  Strip String  ${flag_line_nr}
    ssh.Execute  command=sed -i '${flag_line_nr}s/.*/${flag_with_desired_value}/' /ffs/run/swconfig.txt  connection=${SMOD_Connection}

Delete flags
    Log    \nDelete flags    console=${True}

    Delete Flag in swconfig If exist    ${flag1}
    Delete Flag in swconfig If exist    ${flag2}
    Delete Flag in swconfig If exist    ${flag3}
    Delete Flag in swconfig If exist    ${flag4}

    Run Keyword And Ignore Error   coam.Reset Site  720

Delete Flag in swconfig If exist
    [Documentation]
    ...  This keyword is used to verify if a certain flag exists in swconfig.txt.
    ...  If the flag is present in swconfig.txt, it is deleted.
    ...  *AUTHOR* dan.moldovan@nokia.com
    [Arguments]  ${flag}

    SSH Connection

    ${swconfig_content}    ssh.Execute  command=cat /ffs/run/swconfig.txt

    ${flag_status}  Run Keyword And Return Status
    ...  Should Contain  ${swconfig_content}  ${flag}

    Run Keyword If  ${flag_status}  ssh.Execute  command=sed -i '/${flag}/d' /ffs/run/swconfig.txt

   ${swconfig_content}    ssh.Execute  command=cat /ffs/run/swconfig.txt
   Should Not Contain  ${swconfig_content}  ${flag}

    Log  Flag: ${flag} deleted successfully from swconfig.txt file. [OK]

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Delete flags
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
