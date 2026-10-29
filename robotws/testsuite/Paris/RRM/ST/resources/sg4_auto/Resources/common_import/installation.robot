*** Settings ***

Documentation     Keywords related to testline installation
...    must have Ulm Storagenode mounted on TestPC
...    PACKAGE_PATH can be specified to another
...    YAFT_PATH can be specified to another
...    TODO:  Airphone update
...    TODO:  Cloud GNB update

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin           WITH NAME   admin
Library    taf.transport.ssh                WITH NAME   ssh
Library    ./python/installation.py         WITH NAME   installation_internal
Resource   ./connect.robot
Resource   ./testline.robot
Resource   ./gnb.robot
Resource   ./enb.robot
Resource   ./util.robot
Resource   ./ute_workarounds.robot
Resource   ./wts_ue.robot


*** Variables ***
${PACKAGE_PATH}    /mnt/etfiles/images/nodeb
${SBTS_PACKAGE_PATH}    /mnt/etfiles/images/sbts
${YAFT_PATH}       /mnt/5g/tools/yaft
${ARTI_URL}        https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${SBTS_ARTI_URL}   http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/
${P_console}       ${False}           # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***

Install Package via WEBEM
    [Documentation]    :Author: Jing Liang
    ...    use for Classical GNB with only one Common Unit SW update, update SW, Verify update, wait until ASIK ABIL up
    ...
    ...    :param version:        wanted GNB SW version
    ...    :param gnb_id:         Id of gnb                       [0.. ]           default 0
    ...    :param package_regex:  regular expression for package name              default ${version}_release_BTSSM_downloadable_A54.zip
    ...                                                                    for 21A branch  AirScale-${version}.zip
    ...
    [Arguments]    ${version}    ${gnb_id}=0    ${package_regex}=${version}_release_BTSSM_downloadable_A54.zip
    ${status}=    Run Keyword and Return Status    Wait Until Keyword Succeeds     3x    10 sec    gnb.Verify on board SW Version
    ...    exp_version=${version}    gnb_id=${gnb_id}
    Return from Keyword If    ${status}
    Verify Package Path    version=${version}
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    ${oam_alias}=    wait until keyword succeeds    3 min    20 sec    connect.Setup OAM session    gnb_id=${gnb_id}
    Log to console    package path : ${package_path}
    admin.update_software    sw_package=${package_path}    timeout=5000    connection=${oam_alias}
    Wait Until Keyword Succeeds    10 min    20 sec    gnb.Verify on board SW Version
    ...    exp_version=${version}    gnb_id=${gnb_id}
    gnb.Wait until all DUs up    gnb_id=${gnb_id}
    gnb.Wait until gNB to be onair state    gnb_id=${gnb_id}
    [Teardown]  Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias}


Install eNB Package via WEBEM
    [Documentation]    :Author: Amr Aboushehata
    ...    use for Classical eNB with only one Common Unit SW update, update SW, Verify update, wait until ASIK ABIL up
    ...
    ...    :param version:        wanted eNB SW version
    ...    :param enb_id:         Id of enb                       [0.. ]           default 0
    ...    :param package_regex:  regular expression for package name              default ${version}_release_BTSSM_downloadable_A54.zip
    ...                                                                    for 21A branch  AirScale-${version}.zip
    ...
    [Arguments]    ${version}    ${enb_id}=0    ${package_regex}=${version}_release_BTSSM_downloadable_A54.zip
    ${status}=    Run Keyword and Return Status    Wait Until Keyword Succeeds     3x    10 sec    enb.Verify on board SW Version
    ...    exp_version=${version}    enb_id=${enb_id}
    Return from Keyword If    ${status}
    Verify Package Path    version=${version}
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    Log to console      ${\n}The package path is ${package_path}
    ${oam_alias}=    wait until keyword succeeds    3 min    20 sec    connect.Setup eNB OAM session    enb_id=${enb_id}
    admin.update_software    sw_package=${package_path}    timeout=5000    connection=${oam_alias}
    Wait Until Keyword Succeeds    10 min    20 sec    enb.Verify on board SW Version
    ...    exp_version=${version}    enb_id=${enb_id}
    enb.Wait for eNB state    enb_id=${enb_id}    target_proceduralState=OnAir
    [Teardown]  Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias}


Install Package via Yaft
    [Documentation]    :Author: Jing Liang
    ...    use yaft for SW installation, copy used swconfig.txt to new SW
    ...    yaft w/o reboot, after copy swconfig.txt, trigger GNB reboot via OAM
    ...
    ...    :param version:        wanted GNB SW version
    ...    :param gnb_id:         Id of gnb                       [0.. ]           default 0
    ...    :param package_regex:  regular expression for package name              default AirScale-${version}.zip
    ...    :param yaft_arg:       additional yaft argument                         default=${EMPTY}
    ...
    [Arguments]    ${version}    ${gnb_id}=0    ${package_regex}=AirScale-${version}.zip
    ...    ${yaft_arg}=${EMPTY}
    Verify Package Path    version=${version}
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    ${command}=    Prepare Yaft Command    gnb_id=${gnb_id}
    ${output}=    OperatingSystem.Run     ${command} -z ${package_path} ${yaft_arg}
    ${yaft_failed}=    Run Keyword And Return Status    Should Not Contain    ${output}    Flashing done
    OperatingSystem.Remove Directory    /home/ute/YAFT_IMAGE    recursive=True
    Copy Swconfig To Passive Side    gnb_id=${gnb_id}
    Run Keyword If    ${yaft_failed}    Fail    msg=Yaft Failed! with msg ${output}
    gnb.Perform gNB reboot    gnb_id=${gnb_id}
    Run Keyword and Ignore Error    Check board status and reboot GNB if failed    gnb_id=${gnb_id}    timeout=25 min
    # If first try fails, will try twice with 10 min timeout
    Wait Until Keyword Succeeds    2x    30 sec
    ...    Check board status and reboot GNB if failed    gnb_id=${gnb_id}    timeout=10 min
    gnb.Wait until gNB to be onair state    gnb_id=${gnb_id}


Install eNB Package via Yaft
    [Documentation]    :Author: Amr Aboushehata
    ...    use yaft for SW installation, copy used swconfig.txt to new SW
    ...    yaft w/o reboot, after copy swconfig.txt, trigger eNB reboot via OAM
    ...
    ...    :param version:        wanted eNB SW version
    ...    :param enb_id:         Id of enb                       [0.. ]           default 0
    ...    :param package_regex:  regular expression for package name              default AirScale-${version}.zip
    ...    :param yaft_arg:       additional yaft argument                         default=${EMPTY}
    ...
    [Arguments]    ${version}    ${enb_id}=0    ${package_regex}=AirScale-${version}.zip
    ...    ${yaft_arg}=${EMPTY}
    Verify Package Path    version=${version}
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    Log to console      ${\n}Package path ${package_path}
    ${command}=    Prepare eNB Yaft Command    enb_id=${enb_id}
    Log to console      ${\n}The command ${command} -z ${package_path} ${yaft_arg}
    ${output}=    OperatingSystem.Run     ${command} -z ${package_path} ${yaft_arg}
    ${yaft_failed}=    Run Keyword And Return Status    Should Not Contain    ${output}    Flashing done
    OperatingSystem.Remove Directory    /home/ute/YAFT_IMAGE    recursive=True
    Copy Swconfig To eNB Passive Side    enb_id=${enb_id}
    Run Keyword If    ${yaft_failed}    Fail    msg=Yaft Failed! with msg ${output}
    enb.Perform eNB reboot    enb_id=${enb_id}
    Run Keyword and Ignore Error    Check board status and reboot eNB if failed    enb_id=${enb_id}    timeout=10 min
    # If first try fails, will try twice with 10 min timeout
    Wait Until Keyword Succeeds    2x    30 sec
    ...    Check board status and reboot eNB if failed    enb_id=${enb_id}    timeout=10 min


Configure L1bypass for COAM
    [Documentation]    :Author: Jing Liang
    ...    enable l1bypass in psconfig package, install DCI addon, reboot gnb to apply change
    ...
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...
    [Arguments]    ${gnb_id}=0
    BuiltIn.Log    gNB${gnb_id}: Configure L1bypass for COAM    console=${P_console}
    Enable L1bypass on COAM    gnb_id=${gnb_id}
    Install DCI Addon    gnb_id=${gnb_id}
    Reboot gNB System Module via Console    gnb_id=${gnb_id}
    Wait Until Keyword Succeeds    3x    30 sec
    ...    Check board status and reboot GNB if failed    gnb_id=${gnb_id}    timeout=6 min


Check board status and reboot GNB if failed
    [Documentation]    :Author: Jing Liang
    ...    [Assumption] only one classical GNB with one common unit
    ...
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param timeout:        wait du status timeout          default=6 min
    [Arguments]    ${gnb_id}=0    ${timeout}=6 min
    ${status}=    Run Keyword And Return Status    gnb.Wait until all DUs up    gnb_id=${gnb_id}    timeout=${timeout}
    Return From Keyword If    ${status}
    Reboot gNB System Module via Console    gnb_id=${gnb_id}
    Fail    Board status was not ready, reboot triggered


Check board status and reboot eNB if failed
    [Documentation]    :Author: Amr Aboushehata
    ...    [Assumption] only one classical eNB with one common unit
    ...
    ...    :param enb_id:         Id of enb                       [0.. ]  default=0
    ...    :param timeout:        wait du status timeout          default=6 min
    [Arguments]    ${enb_id}=0    ${timeout}=6 min    ${status}=commissioned
    ${status}=    Run Keyword And Return Status    enb.Wait for eNB state    target_proceduralState=${status}    timeout=${timeout}
    Return From Keyword If    ${status}
    Perform eNB reboot    enb_id=${enb_id}
    Fail    Board status was not ready, reboot triggered


Align iphy config on Airphone
    [Documentation]    :Author: Jing Liang
    ...    To align IRFHead SW version with GNB,
    ...    afterwards will perform reboot AP to apply change.
    ...    [WARNING] have seen iphy.xml broken after this, but dont know what happened
    ...
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param ue_id:          Id of ue                        [0.. ]  default=0
    ...    :param ue_comu_id:     Id of UE Common Unit            [0..1]  default=0
    ...
    [Arguments]    ${gnb_id}=0    ${ue_id}=0    ${ue_comu_id}=0
    BuiltIn.Log    Update iphy config on Airphone    console=${P_console}
    ${ap_alias}=    connect.Connect to Airphone Common Unit    ue_id=${ue_id}    ue_comu_id=${ue_comu_id}
    ${ru_type}=    Get Recommended RU type for Airphone
    ${ru_version}  ${frm_fpga}  ${frm_sw}=    testline.Get RU SW Version from TargetBD
    ...    gnb_id=${gnb_id}    ru_type=${ru_type}
    ssh.execute    cp /rom/simmode/${ru_type}_iphy.xml /rom/simmode/${ru_type}_iphy.xml_org    connection=${ap_alias}
    ${l2ps_matches}=  ssh.execute    grep -c l2PSNodeId /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ${l2ps_matches}=  Convert To Integer      ${l2ps_matches}
    Run Keyword If  ${l2ps_matches} > 0
    ...  ssh.execute    sed -i -e '/l2PSNodeId/d' /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ${5gl_matches}=  ssh.execute    grep -c 5GL.* /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ${5gh_matches}=  ssh.execute    grep -c 5GH.* /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ${frm_matches}=  ssh.execute    grep -c FRM[0-9].* /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ${5gl_matches}=  Convert To Integer      ${5gl_matches}
    ${5gh_matches}=  Convert To Integer      ${5gh_matches}
    ${frm_matches}=  Convert To Integer      ${frm_matches}
    Run Keyword If  ${5gl_matches} > 0
    ...  ssh.execute    sed -i -e 's/5GL.*</${ru_version}</' /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ...  ELSE IF    ${5gh_matches} > 0
    ...  ssh.execute    sed -i -e 's/5GH.*</${ru_version}</' /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ...  ELSE IF    ${frm_matches} > 0
    ...  ssh.execute    sed -i -e 's/FRM[0-9].*</${ru_version}</' /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ...  ELSE   FAIL    Cannot align Iphy SW versions!
    ssh.execute    sed -i -e 's/FRM-FPGA.*</${frm_fpga}</' /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ssh.execute    sed -i -e 's/FRM-SW.*</${frm_sw}</' /rom/simmode/${ru_type}_iphy.xml    connection=${ap_alias}
    ssh.execute    cd /ffs/run/simmode/ && rm iphy.xml && ln -s ${ru_type}_iphy.xml iphy.xml    connection=${ap_alias}
    Bring Airphone TL to F1 up status



#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Verify Package Path
    [Documentation]    :Author: Jing Liang
    ...    [PRIVAT]
    [Arguments]    ${version}
    Run Keyword If    'SBTS' in '${version}'    Set Suite Variable    ${PACKAGE_PATH}    ${SBTS_PACKAGE_PATH}
    ${existed_path}=    Run Keyword And Return Status    Directory Should Exist    ${PACKAGE_PATH}
    return from keyword if    ${existed_path}
    Fail    PACKAGE_PATH doesn't exist. Please configure suite variable PACKAGE_PATH


Get SW Package Path
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    If SW Package doesn't exist, will download it from artifactory
    ...
    ...    :param version:       wanted GNB SW Version
    ...    :param package_regex: file pattern, e.g. AirScale*.zip
    ...
    ...    :returns package_path:  file location on storagenode
    ...
    [Arguments]    ${version}    ${package_regex}
    ${no_package}=    Run Keyword And Return Status    Directory Should Not Exist    ${PACKAGE_PATH}/${version}    msg=Download SW first!
    Run Keyword If    ${no_package}    Download SW Package from Artifactory    version=${version}    package=${package_regex}
    @{package_path}=    List Files In Directory    ${PACKAGE_PATH}/${version}    pattern=${package_regex}    absolute=True
    [Return]    ${package_path[0]}


Download SW Package from Artifactory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...
    ...    :param package: file name, e.g. AirScale-0.836.423.zip
    ...
    [Arguments]    ${version}    ${package}
    ${package_url}=    Set Variable If    'SBTS' in '${version}'    ${SBTS_ARTI_URL}/${package}
    ...                                                             ${ARTI_URL}/${version}/${package}
    ${output}=    Run    wget ${package_url} -nv -P ${PACKAGE_PATH}/
    Should Contain    ${output}    ${PACKAGE_PATH}/${package}    SW Package Download failed!
    Create Directory    ${PACKAGE_PATH}/${version}
    Run    mv ${PACKAGE_PATH}/${package} ${PACKAGE_PATH}/${version}


Prepare Yaft Command
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${sm_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}
    ${gnb_testline_type}=    Get gNB type
    ${ip_address}=     Run Keyword If    '${gnb_testline_type}'=='cloud'
    ...    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ELSE            Set Variable    ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.addr}
    ${asik_pw}=     Run Keyword If    '${gnb_testline_type}'=='cloud'
    ...    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    ELSE            Set Variable    ${tl.gnbs[${gnb_id}].cu.oam_ssh_connection_details.password}
    ${is_tty}=    installation_internal.has_a_tty
    ${command}=    Set Variable If
    ...    '${is_tty}'=='True'    sshpass -p ${asik_pw} python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /home/ute/YAFT_IMAGE -R --ask_for_password
    ...    '${is_tty}'=='False'    echo ${asik_pw} | python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /home/ute/YAFT_IMAGE -R --ask_for_password
    [Return]    ${command}


Prepare eNB Yaft Command
    [Documentation]    :Author: Amr Aboushehata
    ...    [PRIVATE]
    [Arguments]    ${enb_id}=0
    ${sm_alias}=    connect.Connect to eNB Common Unit    enb_id=${enb_id}
    ${ip_address}=    Set Variable    ${tl.enbs[${enb_id}].airscale.common_units[${0}].lmp_connection.addr}
    ${asik_pw}=     Set Variable    ${tl.enbs[${enb_id}].airscale.common_units[${0}].lmp_connection.password}
    ${is_tty}=    installation_internal.has_a_tty
    ${command}=    Set Variable If
    ...    '${is_tty}'=='True'    sshpass -p ${asik_pw} python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /home/ute/YAFT_IMAGE -R --ask_for_password
    ...    '${is_tty}'=='False'    echo ${asik_pw} | python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /home/ute/YAFT_IMAGE -R --ask_for_password
    [Return]    ${command}


Copy Swconfig To Passive Side
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${asik_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}
    ssh.execute    cp /ffs/run/swconfig.txt /ffs/stb/swconfig.txt    connection=${asik_alias}
    ssh.disconnect    ${asik_alias}


Copy Swconfig To eNB Passive Side
    [Documentation]    :Author: Amr Aboushehata
    ...    [PRIVATE]
    [Arguments]    ${enb_id}=0
    ${asik_alias}=    connect.Connect to eNB Common Unit    enb_id=${enb_id}
    ssh.execute    cp /ffs/run/swconfig.txt /ffs/stb/swconfig.txt    connection=${asik_alias}
    ssh.disconnect    ${asik_alias}


# Airphone related

Install DCI Addon
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    Get addon from package location
    [Arguments]    ${gnb_id}=0    ${deploy_arg}=${EMPTY}
    ${asik_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}
    ${file_path}=    Get DCI package path
    ssh.upload_file    local_path=${file_path}   remote_path=/tmp/DCI.tar.gz    connection=${asik_alias}
    ssh.execute    mkdir -p /tmp/dci && tar xvf /tmp/DCI.tar.gz -C /tmp/dci    connection=${asik_alias}
    ssh.execute    chmod 777 /tmp/dci/*    connection=${asik_alias}
    ${output}=    ssh.execute    ls -la /tmp/dci/*    connection=${asik_alias}
    Log To Console    ${output}
    Configure DCI Addon for TL type    gnb_id=${gnb_id}
    ${output}=    ssh.execute    cd /tmp/dci && ./deploy.sh -y ${deploy_arg}    connection=${asik_alias}
    Log To Console    ${output}
    should contain    ${output}    Deployment successful

Configure DCI Addon for TL type
    [Documentation]    :Author: Torsten Dieckmann
    ...    [PRIVATE]    configure deploy.cfg dependent on TL type and system module type
    [Arguments]    ${gnb_id}=0
    ${sm_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}
    ${gnb_testline_type}=    Get gNB type
    ${common_unit_type}=     Identify Common Unit Type
    Run Keyword If    '${gnb_testline_type}'=='cloud'
    ...    ssh.execute    sed -i 's/BTS_CONFIG\="class"/BTS_CONFIG\="cloud"/g' /tmp/dci/deploy.cfg    connection=${sm_alias}
    ...    ELSE IF    '${common_unit_type}'=='ASIB'
    ...    ssh.execute    sed -i 's/DCI_SYSCOM_PORT\="eif02"/DCI_SYSCOM_PORT\="ncpeth49"/g' /tmp/dci/deploy.cfg    connection=${sm_alias}
    ${output}=    ssh.execute    cat /tmp/dci/deploy.cfg    connection=${sm_alias}
    log to console      DCI config file after adaptation:\n ${output}\n

Get DCI package path
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    Get DCI package from package location
    ${ap_version}=    Get Airphone SW version
    @{package_path}=    List Files In Directory    ${PACKAGE_PATH}/${ap_version}    pattern=DCI_link_network*    absolute=True
    [Return]    ${package_path[0]}


Get RU type from Airphone
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]    To get simulated RU type from Airphone
    ...    :param connection: alias to Airphone ASIK
    ...
    ...    :return:  RU type, AEUA or AEQA
    [Arguments]    ${connection}
    ${output}=    ssh.execute    readlink /rom/simmode/iphy.xml    connection=${connection}
    @{file_name}=    Split String From Right    ${output}    /    1
    @{file_name}=    Split String    ${file_name[0]}    _iphy.xml
    [Return]    ${file_name[0]}

Get Recommended RU type for Airphone
    [Documentation]    :Author: Torsten Dieckmann
    ...    [PRIVATE]    Propose RU type for Airphone dependend on band/duplex/l1bypass
    ...
    ...    :return:  RU type, AEUA or AEQA
    ${the value}=    Get Variable Value    ${L1bypass_flag}
    ${L1bypass_flag}=      Set Variable If    '${the value}' != 'None'    ${L1bypass_flag}    ${False}
    Fetch gNB Info from SCF
    ${band}=    Evaluate Band Identifier   ${P_freqBandIndicatorNR}
    ${duplex}=      Set Variable    ${P_cellTechnology}
    ${RU}=   Run Keyword If
    ...     '${duplex}'=='FDD' and '${L1bypass_flag}'=='False'                                  Set Variable    AHLOA
    ...     ELSE IF  '${duplex}'=='FDD' and '${L1bypass_flag}'=='True'                          Set Variable    AHLOA_l1bp
    ...     ELSE IF  '${duplex}'=='TDD' and '${band}'=='mmWv' and '${L1bypass_flag}'=='False'   Set Variable    AEUA
    ...     ELSE IF  '${duplex}'=='TDD' and '${band}'=='mmWv' and '${L1bypass_flag}'=='True'    Set Variable    AEUA_l1bp
    ...     ELSE IF  '${duplex}'=='TDD' and '${band}'=='cmWv' and '${L1bypass_flag}'=='False'   Set Variable    AEQA
    ...     ELSE IF  '${duplex}'=='TDD' and '${band}'=='cmWv' and '${L1bypass_flag}'=='True'    Set Variable    AEQA_l1bp
    ...     ELSE     Fail    Unsupported IRFHEAD simulation
    [Return]    ${RU}

Evaluate Band Identifier
    [Arguments]     ${bandId}
    ${bandIndicator}=    Set Variable If     ${bandId} > 256    mmWv  cmWv
    [RETURN]    ${bandIndicator}


Enable L1bypass on COAM
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${asik_alias}=    connect.Connect to gNB Common Unit    gnb_id=${gnb_id}
    FOR    ${var}     IN    A   B
        log to console    Handle psconfig_${var}
        ${file_path}=    util.Extract tar file to tmp    file_pattern=/ffs/run/swpool/OAM/psconfig_${var}*.txz    connection=${asik_alias}
        ${command}=    Catenate
        ...    sed -i -e 's/<\\/config>/${SPACE * 4}<tag name="app.btsom.nts.L1BypassMap"
        ...    type="string">0x125D:0x524A<\\/tag>\\n<\\/config>/'
        ssh.execute    ${command} ${file_path}/tmp/rat_psconfig.xml    connection=${asik_alias}
        util.Compress files into package and install    files=tmp/    connection=${asik_alias}
    END
    ssh.disconnect    ${asik_alias}


Check board status and reboot Airphone if failed
    [Documentation]    :Author: Jing Liang
    ...    TODO: move to airphone.robot
    [Arguments]    ${ue_id}=0    ${ue_comu_id}=0    ${timeout}=6 min
    ${status}=    Run Keyword And Return Status    Wait until Airphone board ready
    ...    ue_id=${ue_id}    ue_comu_id=${ue_comu_id}    timeout=${timeout}
    Return From Keyword If    ${status}
    Reboot Airphone via Console     ue_id=${ue_id}
    Fail    Board status was not ready, reboot triggered


Wait until Airphone board ready
    [Documentation]    :Author: Jing Liang
    ...     TODO: move to airphone.robot
    ...     :param ue_id:            Id of UE                       [0.. ]  default=0
    ...     :param ue_comu_id:       Id of DU                       [0.. ]  default=0
    ...     :param timeout:     Time until Common+CapacityUnit have to be up  default=10 minutes
    [Arguments]    ${ue_id}=0    ${ue_comu_id}=0    ${timeout}=10 min
    BuiltIn.Log    Wait until Airphone is ready    console=${P_console}
    ${comu_ssh_alias}=  Wait until keyword succeeds     ${timeout}  10 sec
    ...     connect.Connect to Airphone Common Unit  ue_id=${ue_id}  ue_comu_id=${ue_comu_id}
    ${CCS_Daemon_node_id}=    gnb_internal.get_CCS_Daemon_node_id    connection=${comu_ssh_alias}
    @{boards_ids}=    Run keyword if    '${CCS_Daemon_node_id}'=='0x5011'
    ...    Create List    0x50    0x52    0x53    0x54
    ...    ELSE    Fail    Wrong node id ${CCS_Daemon_node_id}!
    @{existing_boards_ids}=    Get slice from list    ${boards_ids}    start=${0}    end=2
    FOR    ${board_id}    IN    @{existing_boards_ids}
        Wait until keyword succeeds     ${timeout}    20 sec    gnb.Check Airscale Board Status
        ...     alias=${comu_ssh_alias}   board_id=${board_id}   CCS_Daemon_node_id=${CCS_Daemon_node_id}
    END
