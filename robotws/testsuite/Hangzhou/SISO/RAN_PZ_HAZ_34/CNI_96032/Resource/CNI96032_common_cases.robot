*** Settings ***
Documentation    This is CNI96032 common keywords for siso RU factory upgrade cases
...              Please do not modify the file without notification to author
...              Contact: kaihui.fan@nokia-sbell.com
...              Squard: HZ SG4

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_log.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/snapshot_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_env.robot
Variables   ../TestData/CNI96032_variables.py

# *** Variables ***
*** Keywords ***
General_SiSo_RF_Factory_FDSW_SW_Upgrade
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to test RRU factory upgrade, and after fid 23 raised ,then upgrade to target package
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 3.20.2023 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${gnb_index}=0   ${connection}=GNB_OAM  ${asik_alias}=ASIK Master
    csn.Connect to    hostname=${test_pc_ip}     username=${test_pc_username}
    ...   password=${test_pc_password}    alias=VM
    ${file_exist}  Run Keyword And Return Status   OperatingSystem.File Should Exist   /home/ute/${RF_FACTORY_SW_INFO['factory_img_file']}
    ${download_link}   Set Variable   ${RF_SW_DOWNLOAD_INFO['svn_path']}${RF_SW_DOWNLOAD_INFO['path_to_file']}
    run keyword if  not ${file_exist}  Download Factory SW package to TAF VM  ${download_link}  ${RF_FACTORY_SW_INFO['factory_img_file']}
    ...   connection=VM
    Upload Factory Package to Target   ${gnb_ip}   ${gnb_username}  ${gnb_password}
    ...   /home/ute/   ${RF_FACTORY_SW_INFO['factory_img_file']}   /user/toor4nsn/   connection=VM
    log to console   General_SiSo_RF_FDSW_SW_Upgrade
    connect to gnb coam via ssl    connection=${connection}
    Connect to Common Unit Master  gnb_index=${gnb_index}  alias=${asik_alias}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    ${ru_index_list}  Get All RU Index
    FOR   ${ru_index}   IN   @{ru_index_list}
        &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
        ${ru_type}   Set Variable   ${ru_info['productName']}
        Continue For Loop If    "${ru_type}" != "AQQY"
        RRU_FDSW_SW_Upgrade  ${ru_index}
    END
    Download SW package to VM   ${Active_SW_version}
    Sleep   120s
    Perform Software Upgrade   ${Active_SW_version}
    Wait until keyword succeeds    20min    20 sec    gnb should be onair with cell up    connection=${connection}
    COAM Commission with scf file  scf_file_path=${SCF_Path}    timeout=600    is_pdl_checking_needed=${True}
    ...    connection=${connection}
    Wait until keyword succeeds    20min    20 sec    gnb should be onair with cell up    connection=${connection}
    Make Call with all ue attached RU  with_peak=${False}
    Run Keyword And Ignore Error  csn.Disconnect    connection=VM
    Run Keyword And Ignore Error   coam.teardown    connection=${connection}

RRU_FDSW_SW_Upgrade
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify site status chould be OK while every time check
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.15.2021 - - Created
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]    ${ru_index}   ${active_alarm}=${23}
    log to console   RRU_FDSW_SW_Upgrade
    Send Factory Package to RU   ru_index=${ru_index}
    Upgrade RF Image To FR   ru_index=${ru_index}
    Perform RU Power Off   ru_index=${ru_index}
    sleep  30s
    Perform RU Power On   ru_index=${ru_index}
    Wait Until Keyword Succeeds    10 min    20 sec  Check RRU Alarm And Version
    ...   ru_index=${ru_index}  RRU_version=${RF_FACTORY_SW_INFO['build_version']}
    ...   active_alarm=${active_alarm}

Make Call with all ue attached RU
    [Arguments]  ${connection}=GNB_OAM   ${duration}=${100}    ${with_peak}=${True}
    log to console   Make Call with all ue attached RU
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${cell_list}    Get All Cell Id    ru_index=${ru_index}    connection=${connection}
        Get UE From Init File and Make call    cell_list=${cell_list}    with_peak=${with_peak}    duration=${duration}
        ...    connection=${connection}
    END

Upgrade RF Image To FR
    [Arguments]   ${file_imge}=${RF_FACTORY_SW_INFO['factory_img_file']}
    ...   ${file_number}=${RF_FACTORY_SW_INFO['file_number']}
    ...   ${build_name}=${RF_FACTORY_SW_INFO['build_name']}
    ...   ${build_version}=${RF_FACTORY_SW_INFO['build_version']}
    ...  ${connection}=GNB_OAM  ${gnb_index}=0  ${ru_index}=${2}   ${asik_alias}=ASIK Master
    log to console   Upgrade RF Image To FR
    Connect to Common Unit Master  gnb_index=${gnb_index}  alias=${asik_alias}
    ${ru_connect_status}    Run Keyword And Return Status   Connect to RU With Allocated IP  ru_index=${ru_index}
        ...       ru_alias=RU_${ru_index}    connection=${connection}   asik_alias=${asik_alias}
        ...       ru_username=${RF_FACTORY_SW_INFO['AQQY_username']}
        ...       ru_password=${RF_FACTORY_SW_INFO['AQQY_password']}
    log to console   upgrade rf cocommand:   SWmanShellCommand -s /run/${file_imge} ${file_number} ${build_name} ""
    ${out}    csn.execute
    ...    sudo chmod 777 /run/${file_imge}   connection=RU_${ru_index}
    ${out}    csn.execute
    ...    sudo SWmanShellCommand -s /run/${file_imge} ${file_number} ${build_name} ""   connection=RU_${ru_index}
    log to console   upgrade rf cocommand:  SWmanShellCommand -a ${build_name} ${build_version} ${file_imge} ${build_version}
    should contain   ${out}   OK
    ${out}    csn.execute
    ...    sudo SWmanShellCommand -a ${build_name} ${build_version} ${file_imge} ${build_version}   connection=RU_${ru_index}
    should contain   ${out}   OK
    csn.execute    /sbin/shutdown -r now    connection=RU_${ru_index}
    sleep    2s
    run keyword and ignore error  csn.execute   rm -rf /run/${file_imge}*   connection=RU_${ru_index}
    [Teardown]    Run Keywords    Run keyword and ignore error
    ...   csn.Disconnect    connection=RU_${ru_index}   AND    Run keyword and ignore error
    ...   csn.Disconnect    connection=ASIK Master

Upload Factory Package to Target
    [Arguments]    ${target_ip}  ${ssh_username}    ${ssh_password}  ${package_path}    ${package_name}
    ...   ${package_target_path}  ${connection}=VM
    log to console   Upload Factory Package to Target
    csn.Send Command
    ...   scp -o StrictHostKeyChecking\=no ${package_path}${package_name} ${ssh_username}@${target_ip}:${package_target_path}${package_name}
    ...   get_pty=True   connection=${connection}
    Sleep    1s
    ${scp_output} =    Run Keyword And Ignore Error
    ...                csn.read output until    match=Password    timeout=10    connection=${connection}
    ${ret1}    Run Keyword And Ignore Error    Should Match Regexp    ${scp_output}}    Password
    Run Keyword If      '${scp_output[0]}'=='PASS'    Run Keywords    csn.write input
    ...   data=${ssh_password}\n    connection=${connection}
    ...     AND     Wait Until Keyword Succeeds    200s    1s    csn.read output until    100%   connection=${connection}
#    ${factory_exist_return}=   csn.execute   command=${exec_cmd}   connection=${connection}
#    log to console   ${factory_exist_return}
    log to console   Upload Factory Package to Target [Done]

Send Factory Package to RU
    [Arguments]   ${asik_alias}=ASIK Master  ${package_name}=${RF_FACTORY_SW_INFO['factory_img_file']}
    ...   ${package_path}=/user/toor4nsn/   ${ssh_username}=${RF_FACTORY_SW_INFO['AQQY_username']}
    ...   ${ssh_passwd}=${RF_FACTORY_SW_INFO['AQQY_password']}
    ...   ${ru_index}=${2}  ${gnb_connection}=GNB_OAM
    log to console   Send Factory Package to RU
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${gnb_connection}
    Wait Until Keyword Succeeds   2m   5s   Check if remote file size   file_path=${package_path}${package_name}   connection=${asik_alias}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${gnb_connection}
#    ${factory_exist_return}=   csn.execute   command=ls -l ${package_path}${package_name}  connection=${asik_alias}
#    log to console   ${factory_exist_return}
#    Run keyword and ignore error   csn.Disconnect    connection=${gnb_connection}
    ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
#    csn.Send Command  command=ssh-keygen -f "${package_path}/.ssh/known_hosts"    connection=${asik_alias}
    Call Method    ${channel}    send    rm -f "${package_path}/.ssh/known_hosts"\n
    ${scp_output}    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}
    ...  send   scp -o StrictHostKeyChecking\=no ${package_path}${package_name} ${ssh_username}@${ru_ip_addr}:/run/${package_name}\n
    Sleep    20s
    ${scp_output}    Call Method    ${channel}    recv    ${65535}
    ${scp_output}    Convert To String    ${scp_output}
    ${status}    Run Keyword And Return Status    Should Contain    ${scp_output}    password
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${ssh_passwd}\n   AND
    ...   Sleep    120 sec
    ${scp_output}    Run Keyword If    ${status}    Call Method    ${channel}    recv    ${65535}
    log to console   send to package to ru  ${scp_output}
    Call Method    ${channel}    close
    ${ru_connect_status}    Run Keyword And Return Status   Connect to RU With Allocated IP  ru_index=${ru_index}
        ...       ru_alias=RU_${ru_index}    connection=${gnb_connection}   asik_alias=${asik_alias}   container_id=${container_id}
        ...       ru_username=${ssh_username}
        ...       ru_password=${ssh_passwd}
    Wait Until Keyword Succeeds   2m   5s   Check if remote file size   file_path=/run/${package_name}   connection=RU_${ru_index}
    log to console   Send Factory Package to RU done
    [Teardown]    Run keyword and ignore error   csn.Disconnect    connection=RU_${ru_index}

Download Factory SW package to TAF VM
    [Arguments]    ${package_download_dir}   ${file_imge}  ${connection}=VM
    log to console   Download Factory SW package to TAF VM
#    run keyword and ignore error  Run   rm -rf /home/ute/${file_imge}*
    ${file_exist}   Run Keyword And Return Status   OperatingSystem.File Should Exist   /home/ute/${file_imge}
    run keyword if  not ${file_exist}   Log    \nStart to Download Factory Package From WFT!
    ${package_download_path}  Set Variable   ${package_download_dir}/${file_imge}
    log to console   \ndownload link is ${package_download_path}
    ${res_output}   run keyword if  not ${file_exist}
    ...    ssh.execute    svn export --force --username ${SVN_USERNAME} --password ${SVN_PASSWORD} ${package_download_path} /home/ute/${file_imge}
    ...    connection=${connection}
    run keyword if  not ${file_exist}   ssh.await execution end   timeout=120s   connection=${connection}
    OperatingSystem.File Should Exist   /home/ute/${file_imge}

Check RRU Alarm And Version
    [Arguments]     ${ru_index}=${2}   ${RRU_version}=${RF_FACTORY_SW_INFO['build_version']}  ${active_alarm}=${23}   ${connection}=GNB_OAM
    log to console   Check RRU Alarm And Version
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${out_rfmode_info}    Get RRU Sw Info
    log   ${out_rfmode_info}
#    log to console  ${RU_info}
    ${rmod_source}   Set Variable   ${out_rfmode_info["distName"].split('/')}[-1]
    Should Be Equal   ${out_rfmode_info["parameters"]["activeSwVersion"]}   ${RRU_version}
    ...   msg=upgraded RF factory fail,RRUversion not ${RRU_version}
    Expect Fault Should Present
    ...                                                     faultId=${active_alarm}
    ...                                                     source=${rmod_source}
    ...                                                     connection=${connection}

Get RRU Sw Info
    [Arguments]   ${connection}=GNB_OAM
#    ${connection_id}    Set Variable   ${CASE_NAME}_${MASTER_BTS_ID}
    log to console   Get RRU Sw Info
    ${rmode_infos}    coam.get_managed_objects    RMOD_R    connection=${connection}
    FOR    ${rmode_info}    IN    @{rmode_infos}
#        Continue For Loop If    "${rmode_info["parameters"]["serialNumber"]}" != "${serial_number}"
        ${status}    Run Keyword And Return Status    Should Not Be Empty    ${rmode_info["distName"]}
       Run Keyword If    '${status}'=='True'    Set Test Variable    ${out_rfmode_info}    ${rmode_info}
    END
    [Return]    ${out_rfmode_info}
#    Should Be Equal As Strings    ${out_rfmode_info["parameters"]["stateInfo"]["availabilityStatus"]}     Online

Download SW package to VM
    [Arguments]   ${package_version}
#    run keyword and ignore error  Run   rm -rf /home/ute/${package_version}*
    log to console   Download SW package to VM
    ${package_release}   ${package_version}   Get Build Release And Version   package_version=${package_version}
    ${package_path}  Set Variable   /home/ute/${package_version}_release_BTSSM_downloadable_A54.zip
    ${file_exist}   run keyword and return status   OperatingSystem.File Should Exist   ${package_path}
    Run Keyword If  ${file_exist}  log to console   \nfile exist
    ${common_hz_site}   Set Variable   ${GNB_SW_DOWNLOAD_INFO['common_web_service_hz']}
    ${package_download_dir_hz}   Set Variable
    ...  ${common_hz_site}/${package_release}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
    Log    \nPackage Do Not Exist, Start to Download Package From WFT!    WARN
    ${wget_log_dir}=    Run   pwd
    Run   rm -rf ${wget_log_dir}/wget-log*
    ${wget_log}=    Run   ls -l ${wget_log_dir}/wget-log*
    log to console   ${wget_log}
    ${wget_command}    set variable
    ...    wget --http-user=y2fang --http-password=AP4c7QuQwZ77WUGzmo5wPns528u -b ${package_download_dir_hz} -P /home/ute
    run keyword if  not ${file_exist}   Run Keywords   Run   ${wget_command}  AND  Sleep  5s
    ${check_wget}   Check Package Not Download
    ${check_wget}   Run Keyword If   not ${file_exist} and ${check_wget}    Download Package From More Site   ${package_version}   ${package_release}
    log to console   \nstart to check
    run keyword if  not ${check_wget} or ${file_exist}    Wait Until Keyword Succeeds   8m   1m   Wait Until wget process done
    ...   ${package_version}
    log to console   \ncheck done
    ${file_download}   run keyword and return status  OperatingSystem.File Should Exist   ${package_path}
    Run Keyword If  ${file_download}  Log To Console    Download Package Finished!
    [Return]   ${package_path}

Check Package Not Download
    log to console   Check Package Not Download
    ${output}   Run   cat wget-log
    ${status1}   Run Keyword And Return Status  Should Contain   ${output}   404 Not Found
    ${status2}   Run Keyword And Return Status  Should Contain   ${output}   failed
    ${status3}   Run Keyword And Return Status  Should Not Contain   ${output}   200 OK
    ${status}   Set Variable If  ${status1} or ${status2} or ${status3}  ${True}  ${False}
    [Return]   ${status}

Download Package From More Site
    [Arguments]   ${package_version}   ${common_release}
    log to console   Download Package From More Site
    ${wget_log_dir}=    Run   pwd
    ${messages}=    Run   rm -rf ${wget_log_dir}/wget-log*
    ${wget_log}=    Run   ls -l ${wget_log_dir}/wget-log*
    log to console   ${wget_log}
    FOR   ${item}   IN   @{GNB_SW_DOWNLOAD_INFO['common_web_service']}
        ${package_download_link}   Set Variable
        ...   ${item}/${common_release}/${package_version}/${package_version}_release_BTSSM_downloadable_A54.zip
        Log    \nPackage Do Not Exist, Start to Download Package From WFT!    WARN
        ${messages}=    Run   rm -rf ${wget_log_dir}/wget-log*
        ${wget_log}=    Run   ls -l ${wget_log_dir}/wget-log*
        log to console   ${wget_log}
        Sleep  2s
        ${wget_command}    set variable
        ...    wget -b ${package_download_link} -P /home/ute --no-check-certificate
        Run   ${wget_command}
        Sleep  5s
        ${check_wget}   Check Package Not Download
        exit for loop if   not ${check_wget}
    END
    [Return]   ${check_wget}

Perform Software Upgrade
    [Arguments]   ${package_version}   ${activate}=yes   ${connection}=GNB_OAM
    log to console   Perform Software Upgrade
    ${package_release}   ${package_version}   Get Build Release And Version   package_version=${package_version}
    Log To Console   Start Software Updating...
    ${should_activate}   Set Variable If   '${activate}'=='yes'   ${True}
    ...   '${activate}'=='no'   ${False}
    connect to gnb coam via ssl    connection=${connection}
    run keyword and continue on failure   coam.update_software   sw_package=/home/ute/${package_version}_release_BTSSM_downloadable_A54.zip
    ...   should_activate=${True}   timeout=${5400}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
#    COAM Logout   connection=${connection}
    coam.teardown    connection=${connection}
    Sleep   5m
    Wait Until Keyword Succeeds   10m   1m   Connect to gnb coam via ssl
    Log To Console   Reset finished!
    Log To Console   COAM SWM Update Done!

Check if remote file size
    [Arguments]   ${file_path}   ${connection}
    ${file_exist}   csn.File Exists
    ...   remote_path=${file_path}   connection=${connection}
    run keyword if  not ${file_exist}    Fail
    ${prev_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Sleep   1s
    ${final_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Should Be Equal   ${prev_size}    ${final_size}

Get Build Release And Version
    [Arguments]   ${package_version}
    ${if_common}   Run Keyword And Return Status   Should Contain   ${package_version}   _ENB_9999_
    @{common_verision_separator}  Split String   ${package_version}   _   1
    ${package_release}   Set Variable if  ${if_common}   SBTS00   ${common_verision_separator}[0]
    ${package_version}   Set Variable If  ${if_common}  SBTS00_${common_verision_separator}[1]   ${package_version}
    [Return]  ${package_release}   ${package_version}
