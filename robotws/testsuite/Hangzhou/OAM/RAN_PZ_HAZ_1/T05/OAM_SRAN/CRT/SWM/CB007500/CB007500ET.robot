*** Settings ***
Documentation     [PURPOSE]
Library    taf.sbts.oam.coam.admin


*** Variables ***
${OfflinePlanFileName}                newMRBTSplan.xml
${IsUIvalue}                          false
${CLI package_Path}                     /home/ute/Downloads/
${active_Package_dir}                 /home/ute/btsauto/
${BTS_OnAir_Timeout}                  35


*** Keywords ***
CB007500_ET_05_04_Execute shell script to trigger configuration reset
    [Documentation]    Short description.
    Run Keyword If     ${smod2_variable_exists}     Change parameter to connect netact with BTS
    Run Keyword If     ${smod2_variable_exists}        Run Keywords    Precondition: Import Target SW To NA
    ...    AND      taf.sbts.oam.coam.admin.Update Software    ${Target SW path}    True  1800s
    ...    AND      Sleep      ${BTS_OnAir_Timeout}min
    ...    AND      check BTS is onair after update to tested software
    Step1: Check SW Version
    Step2: prepare ADMIN CLI package
    Step3: Admin CLI configuration reset execution
    Step4: Check BTS go back to DNR
    Step5: Recovery BTS

CB007500_ST_05_06_Software management procedures on D&RSW
    [Documentation]    Short description.
    Step1: Check SW Version
    Step2: delete plan on netact
    rollback from active
    rollback from passive
    installation SW from FDSW
    recommission BTS
    recover BTS after rollback  newactive

Step1: Check SW Version
    [Documentation]    Short description.
    ${ACTIVE_SW_BEFORE}    ${PASSIVE_SW_BEFORE}    Admin Get BTS SW Version
    set test variable    ${PASSIVE_SW_BEFORE}
    set test variable    ${ACTIVE_SW_BEFORE}
    Active CLI Function on BTS

Step2: prepare ADMIN CLI package
    [Documentation]    Short description.
    ${CLI_Package_PATH}    Download_Specify_Build_By_Aria    ${ACTIVE_SW_BEFORE}    ADMINCLI    ${CLI package_Path}
    Run     unzip -o ${CLI_Package_PATH} -d /tmp
    #Run     cp ${EXECDIR}${/}CRT${/}SWM${/}CB007500${/}configurationreset.sh /tmp

Step3: Admin CLI configuration reset execution
    [Documentation]    Short description.
    set test variable     ${node_path}    /tmp/node/linux/bin/node
    set test variable     ${bundle_path}    /tmp/bin/main.bundle.js
    ${DATA}=    Catenate
    ...    '{"requestId":100,"parameters":{"name":"configurationReset","parameters":
    ...    {"resetType":"ConfigurationWithDiagnosticAndRecoverySw"}}}'
    Log    ${DATA}
    ${cmd}=    Catenate    SEPARATOR=${SPACE}
    ...    '${node_path} --expose_gc --no-warnings ${bundle_path}
    ...    --bts-username="Nemuadmin" --bts-password="nemuuser"
    ...    --bts-host=${BTS_INFO.IP} --bts-port=${BTS_PORT_SRAN} --data=${DATA} --format="human"'
    Log    ${cmd}
    ${output}=    Run    '${cmd}'
    Log    ${output}

Step4: Check BTS go back to DNR
    [Documentation]    Short description.
   Wait Until Keyword Succeeds  25min  10 sec  Connected to D&RSW BTS by RC
   Check Running FDSW Version
   sleep    100 s

check BTS is onair after update to tested software
    [Documentation]    Short description.
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=900
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=300
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    Log  Waiting for stable ping...  console=${TRUE}
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}   min_uptime=360  max_downtime=0  timeout=361
    Run keyword if  ${ping stable status}==${FALSE}
    ...  Set Test Failed  Ping has not been available for 60 seconds
    ...  ELSE
    ...  Log  Ping is stable after SWM operation  console=${TRUE}
    Wait until keyword succeeds  15 min  30 sec  Check SBTS SOAM cells and modules
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

Common_Find SW name
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SW_PATH}: <description>
    ...
    ...    Returns:
    ...        ${SW_PATH_package}: <description>
    [Arguments]    ${SW_PATH}
    ${package name}  OperatingSystem.List files in directory  ${SW_PATH}
    should not be empty  ${package name}  Required package not present in ${SW_PATH}
    ${SW_PATH_package}=  Join Path 	${SW_PATH}  ${package name[0]}
    OperatingSystem.File should exist  ${SW_PATH_package}
    [Return]    ${SW_PATH_package}

Find release version
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${package name}: <description>
    ...        ${release_1}: <description>
    ...        ${release_2}: <description>
    ...        ${release_3}: <description>
    ...
    ...    Returns:
    ...        ${release}: <description>
    [Arguments]    ${package name}    ${release_1}    ${release_2}    ${release_3}
    ${release}=    set variable if    '${release_1}' in '${package name}'
    ...    ${release_1}    '${release_2}' in '${package name}'    ${release_2}    '${release_3}' in '${package name}'
    ...    ${release_3}
    [Return]    ${release}

Precondition: Import Target SW To NA
     [Documentation]
    ...  choose the target package to upgrade, first import to netact, then upgrade by netact
    Log step header  Precondition: Import Target SW To NA
    Log  Check build in Netact otherwise Import
    ${collect_snapshot}    set variable    never
    ${target_sw_path}=    Common_Find SW name    ${Target SW dir}
    set test variable    ${target_sw_path}
    ${package name}    OperatingSystem.List files in directory    ${Target SW dir}
    ${package name}    set variable    ${package_name[0]}
    ${package_release}=    Find release version    ${package name}    ${release_list_1}    ${release_list_2}    ${release_list_3}
    ${release_NUM}=    RUN KEYWORD IF    '${target_release}'=='SBTS00'     set variable    SBTS26R1
    ...    ELSE    set variable    SBTS25R3
    ${active_sw_before_master}    ${passive_sw_before_master}=    Infomodel Get SW Versions    module=MSM
    ${release_NUM}=    RUN KEYWORD IF    '${target_release}'=='SBTS00'     set variable    SBTS26R1
    ...    ELSE    should match regexp    ${active_sw_before_master}    SBTS\\d+..
    set test variable    ${release_NUM}
    ${package_release_changed}    run keyword if    '${target_release}'=='SBTS00'    Replace String Using Regexp
    ...    ${package_release}    SBTS\\d{2}[A-Z]?[0-9]?    ${release_NUM}
    ...    ELSE    set variable    ${package_release}
    set test variable    ${package_release_changed}
    Log  Check build in Netact otherwise Import
    ${Mid_Server}  ${Mid_Server_usr}  ${Mid_Server_pwd}=  Choose_Mid_Server4Netact  ${NETACT_SERVER_INFO.IP}
    build_download_upload_on_remote_server_and_import_to_Netact  target_sw=${package_release}
                                                            ...  release_NUM=${release_NUM}
                                                            ...  remote_ip=${Mid_Server}
                                                            ...  remote_usr=${Mid_Server_usr}
                                                            ...  remote_pwd=${Mid_Server_pwd}
    ${collect_snapshot}    set variable    failed_verdict

Step5: Recovery BTS
    [Documentation]    Short description.
    fdsw.download_technical_logs    ${Snapshot}
    ${activepartID}=    fdsw.get_active_sw_partition    timeout=10
    fdsw.software_rollback    ${activepartID}
    run keyword and ignore error    taf.fdsw.rc.teardown
    Run Keyword If     ${smod2_variable_exists}    Wait Until Keyword Succeeds
    ...  ${BTS_OnAir_Timeout}min  10 sec  Admin Check BTS Procedural and Blocking states  OnAir

Check Running FDSW Version
    [Documentation]    Short description.
    ${RunFDSWVersion}=    fdsw.get_running_sw_version_name
    log    ${RunFDSWVersion}

Active CLI Function on BTS
    [Documentation]    Short description.
    taf.sbts.oam.coam.admin.Perform Parameter Recommissioning
    ...    dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FMCADM-1    parameter=actCli    operation=update
    ...    dist_name=${BTS_INFO.MRBTS}/MNL-1/MNLENT-1/FEATCADM-1  value=true
    ...    skip_parameter_relation_errors=True      should_activate=True      alias=default

Connected to D&RSW BTS by RC
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ip_address}: <description>
    ...        ${port}: <description>
    ...        ${username}: <description>
    ...        ${password}: <description>
    ...        ${auto_discover}: <description>
    ...        ${secure}: <description>
    ...        ${name}: <description>
    [Arguments]    ${ip_address}=192.168.255.129   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    taf.fdsw.rc.connect to    ip_address=${ip_address}   port=${port}    username=${username}    password=${password}
    ...    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    Log  FDSW RC Connected to BTS successfully with IP ${ip_address}
    CB007500_enable_SSH_Access_On_RC

set dnr counter temp
    [Documentation]    Short description.
    Set Connection Parameters     192.168.255.129
    ${commands}    set variable    uboot_env del boot_dnr_counter
    ca_swm_general.Run Remote Linux Command    ${commands}
    ca_swm_general.Run Remote Linux Command    ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN

Step2: delete plan on netact
    [Documentation]    Short description.
    Precondition Netact with TAF
    Run Keyword And Ignore Error    NetAct Delete Plan    planfilefor${BTS_INFO.ID}    planfilefor${BTS_INFO.ID}
    Postcondition Netact with TAF

rollback from active
    [Documentation]    Short description.
    Log Step Header    rollback from active
    Step3: Configuration Reset for CB007500
    Connected to D&RSW BTS by RC
    ${activeslotID}    fdsw.get_active_sw_partition
    ${rollbackoptionlist}    fdsw.get_available_reset_options    ${activeslotID}
    ${option}    Evaluate    random.choice(${rollbackoptionlist})    random
    fdsw.software_rollback    ${activeslotID}     reset_type=${option}
    set test variable    ${rollbackoption}    ${option}
    recover BTS after rollback    active
    set test variable    ${slotID}    ${activeslotID}

rollback from passive
    [Documentation]    Short description.
    Log Step Header    rollback from passive
    Step3: Configuration Reset for CB007500
    Connected to D&RSW BTS by RC
    ${activeslotID}    fdsw.get_active_sw_partition
    ${passiveslotID}    set variable if    ${activeslotID}==1    ${2}    ${1}
    ${rollbackoptionlist}    fdsw.get_available_reset_options    ${passiveslotID}
    ${option}    Evaluate    random.choice(${rollbackoptionlist})    random
    fdsw.software_rollback    ${passiveslotID}     reset_type=${option}
    set test variable    ${rollbackoption}    ${option}
    recover BTS after rollback    passive
    set test variable    ${slotID}    ${passiveslotID}

recover BTS after rollback
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SWpartition}: <description>
    [Arguments]    ${SWpartition}=active
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=120
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful SW activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful SW activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=600
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
    ${ping_status}  Check If Target Is Stable  192.168.255.129  min_uptime=360  max_downtime=420  timeout=1500
    Run keyword if    not ${ping_status}  Fail  BTS is not stable after fallback.
    Log  BTS is stable after rallback from D&RSW.  console=${TRUE}
    Check BTS version and recovery    ${SWpartition}

installation SW from FDSW
    [Documentation]    Short description.
    Log Step Header    installation SW from FDSW
    Step3: Configuration Reset for CB007500
    Connected to D&RSW BTS by RC
    ${activeslotID}    fdsw.get_active_sw_partition
    ${activationOptionslist}    fdsw.get_all_software_inventory
    ${activationOptions}    set variable    ${activationOptionslist}[activation_options]
    ${randlist}    Create list    ${0}    ${1}
    ${rand}    Evaluate    random.choice(${randlist})    random
    fdsw.software_update    ${SW_path_package}    timeout=1200    activate=False
    Connected to D&RSW BTS by RC
    run keyword if    ${rand}==${0}    fdsw.software_update    ${SW_path_package}    timeout=1200    activate=True
    ...  activation_options=${activationOptions}
    run keyword if    ${rand}==${1}    fdsw.software_update    ${SW_path_package}    timeout=1200    activate=True

Check BTS version and recovery
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${SWpartition}: <description>
    [Arguments]    ${SWpartition}
    wait until keyword succeeds  15min  30s  taf.sbts.oam.coam.admin.Reset Admin    alias=default
    sleep    60s
#    ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}  Infomodel Get SW Versions  module=MSM
    ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}  Admin Get BTS SW Version
    @{sw_temp}    split string    ${ACTIVE_SW_BEFORE_MASTER}    _
    ${current_release}  set variable    ${sw_temp[0]}
    ${release}=    Evaluate    "${current_release}"[4:]
    Import Configuration by release    ${release}
 #   wait until keyword succeeds    15min    30s    _Perform Full Commision By Admin
 #   ...    /home/ute/testline_configuration/${TESTLINE_NAME}/node1/BTS_${tl_configuration}_${SWRelease}.xml    ${BTS_INFO.ID}
    sleep    90s
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=120
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful plan activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful plan activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=600
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}

    ${ACTIVE_SW}    ${PASSIVE_SW}    Admin Get BTS SW Version _
    run keyword if    '${SWpartition}'=='active'    should be true    '${ACTIVE_SW}'=='${ACTIVE_SW_BEFORE}'
    run keyword if    '${SWpartition}'=='passive'   should be true    '${ACTIVE_SW}'=='${PASSIVE_SW_BEFORE}'
    run keyword if    '${SWpartition}'=='passive'  run keywords
    ...    taf.sbts.oam.coam.admin.rollback_software
    ...  AND  sleep    300s
    ${build_exist_local_before}   Run keyword and return status    OperatingSystem.Directory should exist    ${active_Package_dir}Basic
    run keyword if  '${build_exist_local_before}'=='False'
    ...  Download_Specify_Build_By_Aria    ${ACTIVE_SW_BEFORE}    Basic    ${active_Package_dir}Basic${/}
    ${package name}  OperatingSystem.List files in directory  ${active_Package_dir}Basic
    ${basic_PATH_package}=  Join Path 	${active_Package_dir}Basic${/}  ${package name[0]}
    ${SW_PATH_package}  set variable if  '${SWpartition}'=='newactive'  ${SW_path_package}  ${basic_PATH_package}
    Fault23 check and update software to Onair    ${SW_PATH_package}

recommission BTS
    [Documentation]    Short description.
#    ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}  Infomodel Get SW Versions  module=MSM
    sleep    360s
    wait until keyword succeeds  15min  30s  taf.sbts.oam.coam.admin.Reset Admin    alias=default
    ${ACTIVE_SW_BEFORE_MASTER}  ${PASSIVE_SW_BEFORE_MASTER}  Admin Get BTS SW Version
    @{sw_temp}    split string    ${ACTIVE_SW_BEFORE_MASTER}    _
    ${current_release}  set variable    ${sw_temp[0]}
    ${release}=    Evaluate    "${current_release}"[4:]
    wait until keyword succeeds    15min    30s    _Perform Full Commision By Admin
    ...    /home/ute/testline_configuration/${TESTLINE_NAME}/node1/BTS_${tl_configuration}_${SWRelease}.xml    ${BTS_INFO.ID}
    ${ping loss status}  Run keyword and return status  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}    timeout=120
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log  BTS RESET after successful plan activation DID NOT OCCUR  console=${TRUE}
    ...  ELSE
    ...  Log  BTS is resetting after successful plan activation...  console=${TRUE}
    ${ping regain status}  Run keyword and return status  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}   timeout=600
    Run keyword if  ${ping regain status}==${FALSE}
    ...  Set Test Failed  Ping has not been regained within timeout
    ...  ELSE
    ...  Log  BTS ping regained  console=${TRUE}
