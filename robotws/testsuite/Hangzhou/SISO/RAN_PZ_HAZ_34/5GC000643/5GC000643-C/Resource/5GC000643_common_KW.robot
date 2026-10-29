*** Settings ***
Documentation     author: jackie.ji
...               Group: HGZ_SG5
...               contact: jackie.ji@nokia-sbell.com


Resource          ../../../5GC002118/Resource/5GC002118_common_KW.robot
Library           Collections
Library           String
Library           ../../../../../OAM/RAN_PZ_HAZ_34/libraries/snapshot_structure.py
Library           ../../../../../OAM/RAN_PZ_HAZ_34/libraries/verify_snapshot.py
Library           verify_snapshot.VerifySnapshot    WITH NAME    snapshot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.analyzer.pcap


*** Variables ***
${SW_build_path}            /home/ute/Downloads/
${wget_link}                https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release/
${swconfig_path_file}       /ffs/run/swconfig.txt
${ru_addr_filepath}         /ffs/run/config/FRIps.txt


*** Keywords ***
Step1: Login WebEM and check gNB is CPRI onair
    log to console    \n Step1: Login WebEM and check gNB is CPRI onair
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    Acquire active version name
    ${mrbts_id}  ${nrbts_id}    Get Gnb BTS ID
    ${bts_name}    Get BTS Name
    set test variable    ${mrbts_id}
    set test variable    ${nrbts_id}
    set test variable    ${bts_name}
    Check gNB is onair
    Check RU version belong to CPRI type

Step2: Backup scf file by WebUI
    log to console    \n Step2: Backup scf file by WebUI
    Backup commissioning file via WebUI

Step3: Modify radioProtocolSelection to eCPRI
    log to console    \n Step3: Modify radioProtocolSelection to eCPRI
    Modify radioProtocolSelection value to eCPRI

Step4: Login WebEM and check 23 fault raised
    log to console    \n Step4: Login WebEM and check 23 fault raised
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    Check 23 fault raised

Step5: Download active SW build and upgrade
    log to console    \n Step5: Download active SW build and upgrade
    Download new SW build without activate
    Start to activate active build

Step6: Login WebEM and check 4610 fault raised
    log to console    \n Step6: Login WebEM and check 4610 fault raised
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    Check 4610 fault raised

Step7: Modify parameters and delete cablinks with activation
    log to console    \n Step7: Modify parameters and delete cablinks with activation
    Delete cablinks except cablink1 and cablink2
    Modify six parameters and activate

Step8: Login WebEM and check gNB is eCPRI onair
    log to console    \n Step8: Login WebEM and check gNB is eCPRI onair
    Check gNB is onair
    Check RU build belong to eCPRI type

WA: Comment two flags for eCPRI
    log to console    WA: Comment two flags for eCPRI
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.execute    command=sed -i 's/0x590000=9/#&/' ${swconfig_path_file}    connection=gNB
    csn.execute    command=sed -i 's/0x5800BA=12/#&/' ${swconfig_path_file}    connection=gNB
    csn.execute    command=crasign ${swconfig_path_file}    connection=gNB
    csn.disconnect    connection=gNB

WA: Uncomment two flags for CPRI
    log to console    WA: Uncomment two flags for CPRI
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.execute    command= sed -i 's/#0x590000=9/0x590000=9/' ${swconfig_path_file}    connection=gNB
    csn.execute    command= sed -i 's/#0x5800BA=12/0x5800BA=12/' ${swconfig_path_file}    connection=gNB
    csn.execute    command=crasign ${swconfig_path_file}    connection=gNB
    csn.disconnect    connection=gNB

WA: Reset gnb by WebUI
    log to console    WA: Reset gnb by WebUI
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    Wait Until Keyword Succeeds    10min    2min    Check gnb hardware online
    selenium_coam.reset_site
    sleep    2min

Assure two flags should be uncomment
    log to console    Assure two flags should be uncomment
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    ${grep_content1}    csn.execute    command=cat ${swconfig_path_file} | grep '#0x590000=9'    connection=gNB
    ${grep_content2}    csn.execute    command=cat ${swconfig_path_file} | grep '#0x5800BA=12'    connection=gNB
    csn.disconnect    connection=gNB
    @{content_list1}    split string    ${grep_content1}    separator=\r\n
    ${content_first_value1}    set variable    ${content_list1}[0]

    @{content_list2}    split string    ${grep_content2}    separator=\r\n
    ${content_first_value2}    set variable    ${content_list2}[0]
    run keyword if    "${content_first_value1}" == "${empty}" and "${content_first_value2}" == "${empty}"
    ...       log to console    Not need uncomment
    ...       ELSE    WA: Uncomment two flags for CPRI

Delete cablinks except cablink1 and cablink2
    log to console    Delete cablinks except cablink1 and cablink2
    FOR    ${index}    IN RANGE    3    7    1
        run keyword and ignore error    selenium_coam.remove_object    object_name=CABLINK-${index}
    END
    sleep    5s

Modify radioProtocolType value to 25eCPRI for CABLINK-2
    Change new parameter on webUI    expected_val=25eCPRI
    ...                              dist_name=MRBTS-${mrbts_id}/EQM-1/HWTOP-1/CABLINK-2
    ...                              filter_param=Radio protocol type
    ...                              p_name=radioProtocolType
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}

Modify linkSpeed value to eCpri25 for CABLINK-2
    Change new parameter on webUI    expected_val=eCpri25
    ...                              dist_name=MRBTS-${mrbts_id}/EQM-1/HWTOP-1/CABLINK-2
    ...                              filter_param=Link speed
    ...                              p_name=linkSpeed
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}

Modify actEcpriMasterClock value to true
    Change new parameter on webUI    expected_val=true
    ...                              dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-1
    ...                              filter_param=Activate eCPRI Master clock
    ...                              p_name=actEcpriMasterClock
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}

Modify actEcpriPhase2 value to true
    Change new parameter on webUI    expected_val=true
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                              filter_param=Activate eCPRI Phase 2
    ...                              p_name=actEcpriPhase2
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}

Modify actEcpriPhase3 value to true
    Change new parameter on webUI    expected_val=true
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ...                              filter_param=Activate eCPRI Phase 3
    ...                              p_name=actEcpriPhase3
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${False}

Modify miNrEcpriUpFCp value to disabled
    Change new parameter on webUI    expected_val=disabled
    ...                              dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRPMRNL-1
    ...                              filter_param=Measurement interval for NR eCPRI U-Plane &amp; Fast-C-Plane measurements
    ...                              p_name=miNrEcpriUpFCp
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${True}

Modify six parameters and activate
    log to console    Modify the first parameter: radioProtocolType
    Modify radioProtocolType value to 25eCPRI for CABLINK-2

    log to console    Modify the second parameter: linkSpeed
    Modify linkSpeed value to eCpri25 for CABLINK-2

    log to console    Modify the third parameter: actEcpriMasterClock
    Modify actEcpriMasterClock value to true

    log to console    Modify the fourth parameter: actEcpriPhase2
    Modify actEcpriPhase2 value to true

    log to console    Modify the fifth parameter: actEcpriPhase3
    Modify actEcpriPhase3 value to true

    log to console    Modify the sixth parameter: miNrEcpriUpFCp
    Modify miNrEcpriUpFCp value to disabled
    sleep    2min

Modify radioProtocolSelection value to eCPRI
    Change new parameter on webUI    expected_val=ECPRI
    ...                              dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ...                              filter_param=Radio Protocol Selection
    ...                              p_name=radioProtocolSelection
    ...                              is_need_to_check_validation_errors=${False}
    ...                              need_active=${True}
    sleep    3min

Acquire active version name
    log to console    Acquire active version name
    &{current_gNB_version}    selenium_coam.check_current_software_version
    set test variable    ${active_version}    ${current_gNB_version}[Active]

Download active version
    log to console    Download active version
    @{sw_package_name_tmp}    split string     ${active_version}     _
    ${sw_package_name_tmp_1}   convert to integer     ${sw_package_name_tmp}[-1]
    ${sw_package_name_tmp_2}   convert to integer     ${sw_package_name_tmp}[-2]
    ${sw_package_name_tmp_3}   convert to integer     ${sw_package_name_tmp}[-3]
    ${sw_package_version}    set variable  ${sw_package_name_tmp_3}.${sw_package_name_tmp_2}.${sw_package_name_tmp_1}
    set test variable    ${sw_package_name}    AirScale-${sw_package_name_tmp_3}.${sw_package_name_tmp_2}.${sw_package_name_tmp_1}_ASIK_ABIL.zip
    ${wget_link_version}    set variable    ${wget_link}/${sw_package_version}/${sw_package_name}
    csn.Connect to    hostname=${host_addr}     username=${host_username}    password=${host_password}    alias=TESTPC
    csn.send_command    command=ls ${SW_build_path}     connection=TESTPC
    csn.send_command    command=wget --no-proxy -P ${SW_build_path} -q ${wget_link_version}     connection=TESTPC
    ${new_package_path}    join path    ${SW_build_path}    ${sw_package_name}
    set test variable    ${new_package_path}
    wait until keyword succeeds    5min    2min    Check version download completed
    csn.disconnect    connection=TESTPC

Check version download completed
    log to console    Check version download completed
    ${package_download_status}    selenium_coam.load_software_package_from_local_drive    file_path=${new_package_path}
    set test variable    ${package_download_success}    software package load success
    should be equal    ${package_download_status}    ${package_download_success}

Download new SW build without activate
    log to console    Download new SW build without activate
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    Download active version
    log to console    active build download complete
    Start to download active build
    wait until keyword succeeds    10min    2min    check SW download progress finished

Check SW download progress finished
    ${result}    selenium_coam.check_software_update_progress
    should be equal    ${result}[status]    Download completed
    should be equal    ${result}[percentage]    100%

Start to download active build
    log to console    Start to download active build
    selenium_coam.software_update    is_activate=False
    sleep    5s

Start to activate active build
    log to console    Start to activate active build
    selenium_coam.software_update    is_activate=True
    sleep    2min

Check 4610 fault raised
    log to console    Check 4610 fault raised
    wait until keyword succeeds    10min    2min    Check active fault on WebUI
    ...                                             alarm_filter=No connection to radio after protocol change
    ...                                             Severity_expect=critical
    ...                                             AlarmID_expect=7112
    ...                                             AlarmName_expect=BASE STATION CONFIGURATION PROBLEM
    ...                                             FaultID_expect=4610
    ...                                             FaultName_expect=No connection to radio after protocol change
    ...                                             AlarmOB_expect=[${bts_name}] MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1

Check 23 fault raised
    log to console    Check 23 fault raised
    wait until keyword succeeds    10min    2min    Check active fault on WebUI
    ...                                             alarm_filter=Incompatible SW version detected
    ...                                             Severity_expect=critical
    ...                                             AlarmID_expect=7111
    ...                                             AlarmName_expect=BASE STATION SOFTWARE MANAGEMENT PROBLEM
    ...                                             FaultID_expect=23
    ...                                             FaultName_expect=Incompatible SW version detected
    ...                                             AlarmOB_expect=[${bts_name}] MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1

Check RU version belong to CPRI type
    log to console    Check RU version belong to CPRI type
    ${ru_version_cpri}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...                                                    filter_param=RU active SW version
    ...                                                    abbr=activeSwVersion
    set test variable    ${ru_version_cpri}
    should contain    ${ru_version_cpri}    TRM

Check RU build belong to eCPRI type
    log to console    Check RU build belong to eCPRI type
    ${ru_version_ecpri}    selenium_coam.get_parameter_value    dist_name=MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...                                                     filter_param=RU active SW version
    ...                                                     abbr=activeSwVersion
    set test variable    ${ru_version_ecpri}
    should contain    ${ru_version_ecpri}    SRM

SSH to RU and transform RU version to CPRI type
    log to console    SSH to RU and transform RU version to CPRI type
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    ${ru_relevant_info}    csn.execute    command=cat ${ru_addr_filepath}    connection=gNB
    ${match_info}    ${ru_addr}    should match regexp    ${ru_relevant_info}    .*;([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+).*
    #csn.connect to    ${ru_addr}    ${asik_username}    ${asik_password}    alias=RU    proxy=gNB
    ${FHNETcontainer_id}     Get FHNET Container ID    asik_alias=gNB
    Connect to RU With Allocated IP
    ...     ru_alias=RU
    ...     asik_alias=gNB
    ...     container_id=${FHNETcontainer_id}
    ${ru_sw_info}    csn.execute    command=SWmanShellCommand -i    connection=RU
    log to console    Acquire CPRI tar package name
    ${ru_match_tar}    ${ru_tar_name}    should match regexp    ${ru_sw_info}    .*\\s*(trm-.*\\.tar).*

    log to console    Check current eCPRI build name
    ${ru_match_info}    ${ru_cur_build}    should match regexp    ${ru_sw_info}    Current.*(SRM\\w+\\.\\w+\\.\\w+)
    should be equal    ${ru_cur_build}    ${ru_version_ecpri}

    log to console    Obtain version info from tar name
    ${full_matched_tar}    ${tar_version}    should match regexp    ${ru_tar_name}    .*\\_(\\w+)\\.tar

    log to console    Activate RU build from eCPRI to CPRI
    ${active_info}    csn.execute
    ...    command=SWmanShellCommand -a ${ru_version_cpri} ${ru_version_cpri} ${ru_tar_name} ${tar_version}    connection=RU
    should contain    ${active_info}    OK
    sleep    3s
    csn.send_command    command=rfsw-ncfg-reboot    connection=RU
    sleep    1min
    run keyword and ignore error    csn.disconnect    connection=RU
    csn.disconnect    connection=gNB

Get BTS Name
    [Arguments]    ${dist_name}=MRBTS-${mrbts_id}    ${filter_param}=BTS name    ${p_name}=btsName
    ${bts_name}    Run Keyword And Continue On Failure       selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    [Return]    ${bts_name}

Recover env to CPRI type
    log to console    Recover env to CPRI type
    SSH to RU and transform RU version to CPRI type
    Assure two flags should be uncomment
    Recommission backup scf file
    WA: Reset gnb by WebUI
    Login WebEM and check gNB is CPRI onair
    Delete downloaded package

Delete downloaded package
    log to console    Delete downloaded package
    csn.Connect to    hostname=${host_addr}     username=${host_username}    password=${host_password}    alias=TESTPC
    csn.execute    command=ls ${SW_build_path}     connection=TESTPC
    run keyword and ignore error    csn.execute    command=rm ${new_package_path}     connection=TESTPC
    csn.disconnect    connection=TESTPC

Check gnb hardware online
    Check ASIK status normal
    Check ABIL status normal

Check ASIK status normal
    ${output_asik}    selenium_coam.get_asik_info
    ${output_asik_info}    set variable    ${output_asik}[Status]
    should be equal    ${output_asik_info}[Administrative state]    Unlocked
    should be equal    ${output_asik_info}[Availability status]     Online
    should be equal    ${output_asik_info}[Procedural status]       configured

Check ABIL status normal
    ${output_abil}    selenium_coam.get_abil_info
    ${output_abil_info}    set variable    ${output_abil}[Status]
    should be equal    ${output_abil_info}[Administrative state]    Unlocked
    should be equal    ${output_abil_info}[Availability status]     Online
    should be equal    ${output_abil_info}[Procedural status]       configured

Recommission backup scf file
    log to console    Recommission backup scf
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    Reload backup scf file

Login WebEM and check gNB is CPRI onair
    log to console    Check gnb CPRI onair
    Check gNB is onair

Check gNB is onair
    Wait Until Keyword Succeeds    6min    1min    WEBUI Login
    wait until keyword succeeds    15min    2min    check gNB Staus onAir
    ...    dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}    search_text=Operational state

Change new parameter on webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    run keyword if  not '${current_val}'=='${expected_val}'
    ...                  Set new parameter value on webUI    expected_val=${expected_val}
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      p_name=${p_name}
    ...                                                      is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                      need_active=${need_active}
    [Return]    ${current_val}

Set new parameter value on webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                              filter_param=${filter_param}
    ...                              new_value=${expected_val}
    ...                              abbr=${p_name}
    ...                              timeout=${120}
    selenium_coam.validate_plan
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}

Backup commissioning file via WebUI
    [Documentation]   get scf from wbui and stored
    ...    Author: shasha.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    scf file
    ...    Example
    ...    | ${scfFile} | backup commission file via WebUI | ${scfSaved_dir} |
    [Arguments]    ${scfSaved_dir}=${SAVE LOG DIRECTORY}
    ${commission_file}=    selenium_coam.backup_bts_site_configuration    download_timeout=60
    ${Status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${scfSaved_dir}
    Run Keyword If    '${Status}'== 'False'    OperatingSystem.Create Directory    ${scfSaved_dir}
    OperatingSystem.Copy File    ${commission_file}    ${scfSaved_dir}/scf.xml
    OperatingSystem.File Should Exist    ${scfSaved_dir}/scf.xml
    set test variable    ${scfFile}    ${scfSaved_dir}/scf.xml
    [Return]    ${scfFile}

Reload backup scf file
    [Arguments]   ${scfFilePath}=${scfFile}
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scfFilePath}
    sleep   3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    2min
