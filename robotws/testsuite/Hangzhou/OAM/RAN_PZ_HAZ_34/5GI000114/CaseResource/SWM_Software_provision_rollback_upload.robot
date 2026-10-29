*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot
# Resource   ../../UUF/Resource/upgrade_rollback.robot

*** Variables ***
${upgrade_version}
${swm_temp}   /d/oss/global/swmanager/swm_temp
${disk_space_new}    //span[@id='j_id__v_277:archive_diskUsage_diskUsageLabel']

*** Keyword ***
SWM Software Provision Rollback Upload Test Case
    Step1: COAM Get Latest Release Version
    Step2: COAM Select Package And Download To NetAct
    Step3: COAM SWM Import Operation
    Step4: COAM SWM Upload Operation
    Step5: COAM SWM Provision Operation
    Step6: COAM SWM Rollback Operation
    # # Step2: COAM NetAct Upgrade Combine
    # # Step3: COAM NetAct Rollback Combine

Step1: COAM Get Latest Release Version
    @{package_str}   Split String   ${SOFTWARE_VERSION}   .
    Set Test Variable   ${PACKAGE_HEADER}   SBTS00_ENB_${package_str[0]}
    @{packages_states}   Create List   RELEASED   RELEASED_WITH_RESTRICTIONS
    ${status}   ${packages}   Run Keyword And Ignore Error   Wait Until Keyword Succeeds   6m   1m
    ...   Get_Package_Version   package_header=${PACKAGE_HEADER}   states=${packages_states}
    Run Keyword If   '${upgrade_version}'==''   Set Test Variable   ${upgrade_version}   ${packages[0]['version']}
    Set Test Variable   ${second_version}   ${packages[1]['version']}
    Log To Console   SWM Plan to Upgrade GNB To: ${upgrade_version}

Step2: COAM Select Package And Download To NetAct
    Log To Console   Start To Download Package IN NetAct...
    @{split_list}   Split String   ${upgrade_version}   _
    Set Test Variable   ${package_version}   ${split_list[0]}
    ${url_header}   Set Variable   http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/${package_version}
    ${package_name}   Set Variable   ${upgrade_version}_release_BTSSM_downloadable_A54.zip
    ${url_status}   Run Keyword And Return Status   Test WFT Connection   wft_service=${url_header}/${package_name}

    ${package_name}   Set Variable If
    ...   not ${url_status}   ${upgrade_version}_release_BTSSM_downloadable_A54.zip
    ...   ${url_status}   ${upgrade_version}_release_BTSSM_downloadable_A54.zip

    ${download_url}   Set Variable   ${url_header}/${package_name}
    Log To Console   Download URL: ${download_url}
    csn.Connect To  hostname=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}  username=${SERVICE_USER}  password=${SERVICE_PASSWORD}  alias=DMGR
    csn.Execute   command=rm -f wget-log*   connection=DMGR   timeout=60
    csn.Send Command   command=wget -b ${download_url} -P ${swm_temp}/   connection=DMGR   timeout=60
    Wait Until Keyword Succeeds   40m   1m   Check Package Download Finished IN NetAct   package_name=${package_name}
    ${file_exists}   csn.File Exists   remote_path=${swm_temp}/${package_name}   connection=DMGR
    Should Be True   ${file_exists}
    csn.Execute   command=chmod 777 ${swm_temp}/${package_name}   connection=DMGR   timeout=60
    Log To Console   Download Package IN NetAct Finished!
    [Teardown]   csn.Reset Cache

Check Package Download Finished IN NetAct
    [Arguments]   ${package_name}
    ${output}   csn.Execute   command=cat wget-log | grep -i "saved"   connection=DMGR   timeout=60
    Should Contain   ${output}   ${package_name}

Test WFT Connection
    [Arguments]   ${wft_service}
    ${http_code}   OperatingSystem.Run   echo $(curl -sIL -w "%\{http_code\}" -o /dev/null ${wft_service})
    Should Not Be Equal As Strings   ${http_code.find('200')}   -1

Step3: COAM SWM Import Operation
    Log To Console   Start To Import Package To NetAct...
    Set Test Variable   ${software_name}   ${upgrade_version}_release_BTSSM_downloadable_A54
    csn.Connect To  hostname=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}  username=${START_PAGE_USER}  password=${START_PAGE_PASSWORD}  alias=DMGR
    ${output}   csn.Execute  command=swmCLI.sh import --file ${software_name}.zip --mo-type MRBTS
    ...   connection=DMGR  timeout=600
    ${output}   Strip String   ${output}
    #Should Contain   ${output}   9999
    Log To Console   Software Name: ${upgrade_version}
    Set Test Variable   ${upgrade_version}   ${output}
    csn.Execute  command=rm -rf ${software_name}.zip   connection=DMGR  timeout=60
    Log To Console   Import Package To NetAct Finished!
    [Teardown]   csn.Reset Cache

Step4: COAM SWM Upload Operation
    Log To Console   Start To SWM Upload Operation...
    csn.Connect To  hostname=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}  username=${START_PAGE_USER}  password=${START_PAGE_PASSWORD}  alias=DMGR
    ${op_id}   csn.Execute  command=swmCLI.sh -op start --type upload -dn ${DN}   connection=DMGR  timeout=600
    ${op_id}   Strip String   ${op_id}
    Log To Console   Upload Operation ID: ${op_id}
    Log To Console   You Can Check The Operation Status In DMGR HOST: ${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    Log To Console   Command: swmCLI.sh -op operation-status -id ${op_id}
    Wait Until Keyword Succeeds   10m   1m   Wait For Operation Succeeds   op_id=${op_id}
    Log To Console   SWM Upload Operation Finished!
    [Teardown]   csn.Reset Cache

Wait For Operation Succeeds
    [Arguments]   ${op_id}
    ${output}   csn.Execute   command=swmCLI.sh -op operation-status -id ${op_id}   connection=DMGR  timeout=60
    Should Contain   ${output}   ${DN}
    Should Contain   ${output}   SUCCESS

Step5: COAM SWM Provision Operation
    Log To Console   Start To SWM Provision Operation...
    csn.Connect To  hostname=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}  username=${START_PAGE_USER}  password=${START_PAGE_PASSWORD}  alias=DMGR
    ${op_id}   csn.Execute  command=swmCLI.sh -op start -t provision -s ${upgrade_version} -dn ${DN}   connection=DMGR   timeout=60
    ${op_id}   Strip String   ${op_id}
    Log To Console   Provision Operation ID: ${op_id}
    Log To Console   You Can Check The Operation Status In DMGR HOST: ${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    Log To Console   Command: swmCLI.sh -op operation-status -id ${op_id}
    Wait Until Keyword Succeeds   180m   5m   Wait For Operation Succeeds   op_id=${op_id}
    Run Keyword And Ignore Error   All Wait GNB Startup
    Log To Console   SWM Provision Operation Finished!
    [Teardown]   csn.Reset Cache

Step6: COAM SWM Rollback Operation
    Log To Console   Start To SWM Rollback Operation...
    csn.Connect To  hostname=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}  username=${START_PAGE_USER}  password=${START_PAGE_PASSWORD}  alias=DMGR
    ${op_id}   csn.Execute  command=swmCLI.sh -op start --type rollback -dn ${DN}   connection=DMGR  timeout=600
    ${op_id}   Strip String   ${op_id}
    Log To Console   Rollback Operation ID: ${op_id}
    Log To Console   You Can Check The Operation Status In DMGR HOST: ${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    Log To Console   Command: swmCLI.sh -op operation-status -id ${op_id}
    Wait Until Keyword Succeeds   30m   1m   Wait For Operation Succeeds   op_id=${op_id}
    Run Keyword And Ignore Error   All Wait GNB Startup
    Log To Console   SWM Rollback Operation Finished!
    [Teardown]   csn.Reset Cache

Case Setup: Software Operation
    Log To Console   \nStart To SWM Operation Case Setup!
    Log To Console   SWM Operation Initialization: Start To Check Available Disk Space IN Software Archive...
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_page   page_name=Software Manager
    selenium_netact.wait_for_enable   elem_xpath=//span[text()='Software Archive']
    selenium_netact.Click Button   button_xpath=//span[text()='Software Archive']
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="j_id__v_277:archive_diskUsage_diskUsageLabel"]
    Run Keyword If   '${NETACT}'!='CLAB737'   selenium_netact.wait_for_visibility   //*[@id="j_id__v_277:archive_diskUsage_diskUsageLabel"]
    ...    ELSE    selenium_netact.wait_for_visibility   //span[@id='j_id273:archive_diskUsage_diskUsageLabel']
    ${disk_space}   Run Keyword If   '${NETACT}'!='CLAB737'
    ...    selenium_netact.get_elem_text   //span[@id='j_id__v_277:archive_diskUsage_diskUsageLabel']
    ...    ELSE    selenium_netact.get_elem_text   //span[@id='j_id273:archive_diskUsage_diskUsageLabel']
    @{disk_space_list}   Split String   ${disk_space}   /
    ${available_space}   Set Variable   ${disk_space_list[-1]}
    Log To Console   SWM Available Archive Disk Space: ${available_space}
    selenium_netact.logout

Case Teardown: Software Operation
    Log To Console   Start To SWM Operation Case Teardown!
    Log To Console   Wait GNB OnAir...
    Run Keyword And Ignore Error   All Wait GNB Startup
    Run Keyword And Ignore Error   csn.Reset Cache
