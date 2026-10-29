*** Settings ***

Documentation     Keywords related to testline installation
...    must have Ulm Storagenode mounted on TestPC
...    PACKAGE_PATH can be specified to another
...    YAFT_PATH can be specified to another

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin           WITH NAME   admin
Library    taf.transport.ssh                 WITH NAME   ssh
Library    python_libs/installation.py       WITH NAME   installation_internal
Resource   ../../resources/Common/connect.robot
Resource   ../../resources/Common/testline.robot
Resource   ../../resources/Common/gnb.robot
Resource   ../../resources/Common/util.robot
Resource   syve_testline.robot
Resource   enb.robot


*** Variables ***
${PACKAGE_PATH}           /mnt/etfiles/images/sbts
${YAFT_PATH}              /mnt/etfiles/users/yaft
${ARTI_URL_1}             https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local
${P_console}              ${False}  # output to console can be enabled via "Set Console Output" from testline.robot


*** Keywords ***
Teardown For Install Package Via WEBEM
    [Documentation]    Conditional Teardown for KW `Install Package via WEBEM`
    [Arguments]    ${download_status_gNB}   ${status_truck_roll}   ${gnb_id}
    IF    ${download_status_gNB}==False and ${status_truck_roll}!=True
        admin.teardown_all_aliases_for_admin
        gnb.Perform GNB Reboot    gnb_id=${gnb_id}
    ELSE IF    ${status_truck_roll}==True
        admin.teardown_all_aliases_for_admin
    END


Install Package Via WEBEM
    [Documentation]    :Author: Jing Liang/ Modified by:  Anuk Bhattacharyya/ Monika Kolleshi
    ...    use for Classical GNB with only one Common Unit, update SW, Verify update, wait until gNB is onAir
    ...
    ...    :param version:        wanted GNB SW version
    ...    :param gnb_id:         Id of gnb                       [0.. ]           default 0
    ...    :param package_regex:  regular expression for package name              default ${version}_release_BTSSM_downloadable_A54.zip
    ...
    [Arguments]    ${version}    ${gnb_id}=0    ${package_regex}=${version}_release_BTSSM_downloadable_A54.zip    ${yaft}=False
    ${status_gNBOnAir}       Set Variable    ${False}
    ${status_truck_roll}     Set Variable    ${False}
    ${download_status_gNB}   Set Variable    ${False}

    ${status}    Run Keyword and Return Status    gnb.Verify On Board SW Version
    ...    exp_version=${version}    gnb_id=${gnb_id}
    #incase of yaft we need to do the update with the same sw installed
    IF    not ${yaft} and ${status}   RETURN

    Verify Package Path
    ${package_path}    Get SW Package Path    version=${version}    package_regex=${package_regex}

    ${oam_alias}    connect.Setup OAM HTTP Session  node_id=${gnb_id}
    Log To Console    package path : ${package_path}
    ${download_status_gNB}    Run Keyword And Return Status
    ...    admin.update_software    sw_package=${package_path}    timeout=6000    connection=${oam_alias}

    Wait Until Keyword Succeeds    15 min    20 sec    gnb.Verify On Board SW Version
    ...    exp_version=${version}    gnb_id=${gnb_id}

    gnb.Wait Until All DUs Up    gnb_id=${gnb_id}     accept_sleep_state=${True}
    Wait For Minimum Required State For Cell Setup   timeout=25min
    ${status_gNBOnAir}    Run Keyword And Return Status   gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}    timeout=25 min
    IF    ${status_gNBOnAir}!=True
        ${status_truck_roll}=   syve_testline.Check Truck Roll Fault IDs    node_id=${gnb_id}    node_type=gnb
    END

    [Teardown]    Teardown For Install Package Via WEBEM
                  ...    download_status_gNB=${download_status_gNB}
                  ...    status_truck_roll=${status_truck_roll}
                  ...    gnb_id=${gnb_id}


Teardown For Install eNB Package Via WEBEM
    [Documentation]    Conditional Teardown for KW `Install eNB Package via WEBEM`
    [Arguments]    ${download_status_eNB}   ${status_truck_roll}   ${enb_id}
    IF    ${download_status_eNB}==False and ${status_truck_roll}!=True
        admin.teardown_all_aliases_for_admin
        enb.Perform eNB reboot    enb_id=${enb_id}
    ELSE IF    ${status_truck_roll}==True
        admin.teardown_all_aliases_for_admin
    END


Install ENB Package Via WEBEM
    [Documentation]    :Author: Amr Aboushehata/  Modified by:  Anuk Bhattacharyya/ Monika Kolleshi
    ...    use for Classical eNB with only one Common Unit, update SW, Verify update, wait until eNB is onAir
    ...
    ...    :param version:        wanted eNB SW version
    ...    :param enb_id:         Id of enb                       [0.. ]           default 0
    ...    :param package_regex:  regular expression for package name              default ${version}_release_BTSSM_downloadable_A54.zip
    ...
    [Arguments]    ${version}    ${enb_id}=0    ${package_regex}=${version}_release_BTSSM_downloadable_A54.zip    ${yaft}=False
    ${status_eNBOnAir}=     Set Variable    ${False}
    ${status_truck_roll}=    Set Variable    ${False}
    ${download_status_eNB}   Set Variable    ${False}

    ${status}=    Run Keyword and Return Status    Wait Until Keyword Succeeds     3x    10 sec    enb.Verify on board SW Version
    ...    exp_version=${version}    enb_id=${enb_id}
    #incase of yaft we need to do the update with the same sw installed
    IF    not ${yaft} and ${status}   RETURN
    Verify Package Path
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    Log to console      ${\n}The package path is ${package_path}
    ${oam_alias}=    connect.Setup OAM http session  node_id=${enb_id}  node_type=enb

    # retry in case attempting when BTS is in BUSY state
    ${download_status_eNB}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    3x   10 min
    ...    admin.update_software    sw_package=${package_path}    timeout=6000    connection=${oam_alias}

    Run Keyword and Ignore Error    admin.teardown    connection=${oam_alias}
    Wait Until Keyword Succeeds    15 min    20 sec    enb.Verify on board SW Version
    ...    exp_version=${version}    enb_id=${enb_id}
    Wait For Minimum Required State For Cell Setup  node_type=enb  timeout=25min
    ${status_eNBOnAir}=    Run Keyword and Return Status   gnb.Wait Until Node To Be Onair State   node_id=${enb_id}  node_type=enb   timeout=25 min
    IF    ${status_eNBOnAir}==False
        ${status_truck_roll}=   syve_testline.Check Truck Roll Fault IDs    node_id=${enb_id}    node_type=enb
    END
    [Teardown]    Teardown For Install ENB Package Via WEBEM
                  ...    download_status_eNB=${download_status_eNB}
                  ...    status_truck_roll=${status_truck_roll}
                  ...    enb_id=${enb_id}


Install Package Via Yaft
    [Documentation]    :Author: Jing Liang  Editor: Amr Aboushehata
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
    Verify Package Path
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    Log to console      ${\n}Package path ${package_path}
    Remove gNB user json file    gnb_id=${gnb_id}
    ${command}=    Prepare Yaft Command    gnb_id=${gnb_id}
    Log to console      ${\n}The command ${command} -z ${package_path} ${yaft_arg}
    ${gnb_testpc}=    connect.Connect to test pc proxy for node    node_id=${gnb_id}
    ${output}=    ssh.execute    sudo ${command} -z ${package_path} ${yaft_arg}    connection=${gnb_testpc}    timeout=3600
    ${yaft_failed}=    Run Keyword And Return Status    Should Not Contain    ${output}    Flashing done
    ssh.execute     rm -rf /tmp/YAFT_IMAGE/GNB    connection=${gnb_testpc}
    Copy Swconfig To Passive Side    gnb_id=${gnb_id}
    IF    ${yaft_failed}    Fail    msg=Yaft Failed! with msg ${output}
    Run Keyword and Ignore Error    gnb.Perform gNB reboot    gnb_id=${gnb_id}
    Run Keyword and Ignore Error    gnb.Wait Until Node To Be Onair State   node_id=${gnb_id}    timeout=15 min


Install ENB Package Via Yaft
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
    Verify Package Path
    ${package_path}=    Get SW Package Path    version=${version}    package_regex=${package_regex}
    Log to console      ${\n}Package path ${package_path}
    Remove eNB user json file    enb_id=${enb_id}
    ${command}=    Prepare eNB Yaft Command    enb_id=${enb_id}
    Log to console      ${\n}The command ${command} -z ${package_path} ${yaft_arg}
    ${enb_testpc}=    connect.Connect to test pc proxy for node    node_id=${enb_id}  node_type=enb
    ${output}=    ssh.execute    sudo ${command} -z ${package_path} ${yaft_arg}    connection=${enb_testpc}    timeout=3600
    ${yaft_failed}=    Run Keyword And Return Status    Should Not Contain    ${output}    Flashing done
    ssh.execute    rm -rf /tmp/YAFT_IMAGE/ENB    connection=${enb_testpc}
    Copy Swconfig To eNB Passive Side    enb_id=${enb_id}
    IF    ${yaft_failed}    Fail    msg=Yaft Failed! with msg ${output}
    ...    ELSE   Log To Console    Downgrade of eNB SW release via YAFT done! Triggering eNB reboot now to complete ...
    Run Keyword And Warn On Failure    enb.Perform eNB reboot    enb_id=${enb_id}
    Run Keyword and Ignore Error    Check Board Status And Reboot ENB If Failed    enb_id=${enb_id}    timeout=15 min


Check Board Status And Reboot GNB If Failed
    [Documentation]    :Author: Jing Liang
    ...    [Assumption] only one classical GNB with one common unit
    ...
    ...    :param gnb_id:         Id of gnb                       [0.. ]  default=0
    ...    :param timeout:        wait du status timeout          default=6 min
    [Arguments]    ${gnb_id}=0    ${timeout}=6 min
    ${status}=    Run Keyword And Return Status    gnb.Wait until all DUs up    gnb_id=${gnb_id}    timeout=${timeout}
    IF    ${status}   RETURN
    Reboot gNB System Module via Console    gnb_id=${gnb_id}
    Fail    Board status was not ready, reboot triggered


Check Board Status And Reboot ENB If Failed
    [Documentation]    :Author: Amr Aboushehata
    ...    [Assumption] only one classical eNB with one common unit
    ...
    ...    :param enb_id:         Id of enb                       [0.. ]  default=0
    ...    :param timeout:        wait du status timeout          default=6 min
    [Arguments]    ${enb_id}=0    ${timeout}=6 min    ${status}=commissioned
    ${status}=    Run Keyword And Return Status    gnb.Wait for Node state    node_type=enb    node_id=${enb_id}
    ...     target_proceduralState=${status}    timeout=${timeout}
    IF    ${status}   RETURN
    Perform eNB reboot    enb_id=${enb_id}
    Fail    Board status was not ready, reboot triggered


#------------------------------------------------------------------------------------------------------------------------------------[150 characters]
# Private keywords --> must not used outside of this file!
#------------------------------------------------------------------------------------------------------------------------------------[150 characters]

Verify Package Path
    [Documentation]    :Author: Jing Liang
    ...    [PRIVAT]
    [Arguments]
    Set Suite Variable    ${PACKAGE_PATH}    ${PACKAGE_PATH}
    Directory Should Exist    ${PACKAGE_PATH}    ${PACKAGE_PATH} doesn't exist.


Get SW Package Path
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...    If SW Package doesn't exist, will download it from artifactory
    ...    :param version:       wanted GNB SW Version
    ...    :param package_regex: file pattern, e.g. AirScale*.zip
    ...    :returns package_path:  file location on storagenode
    ...
    [Arguments]    ${version}    ${package_regex}
    ${no_package}=    Run Keyword And Return Status    Directory Should Not Exist    ${PACKAGE_PATH}/${version}    msg=Download SW first!
    IF    ${no_package}    Download SW Package From Artifactory    version=${version}    package=${package_regex}
    @{package_path}=    List Files In Directory    ${PACKAGE_PATH}/${version}    pattern=${package_regex}    absolute=True
    RETURN    ${package_path[0]}


Download SW Package from Artifactory
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    ...
    ...    :param package: file name, e.g. AirScale-0.836.423.zip
    ...
    [Arguments]    ${version}    ${package}
    ${stream}   Set Variable If   ${{'FSM3' in '${version}'}}
    ...   ${version.split('_')[0]}_${version.split('_')[1]}   ${version.split('_')[0]}

    ${package_url}    Set Variable     ${ARTI_URL_1}/build/${stream}/${version}/${package}

    ${output}    OperatingSystem.Run    wget ${package_url} -nv -P ${PACKAGE_PATH}/${version}
    Should Contain    ${output}    ${PACKAGE_PATH}/${version}/${package}    SW Package Download failed!


Prepare Yaft Command
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${ip_address}=     Set Variable    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ${sm_pw}=     Set Variable    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.password}
    ${ignore_FSPs_flag}=     Set Variable If    "${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].hardware_type}" in ["ASOG"]
    ...     --ignore_FSPs    ${EMPTY}
    ${L_flag}=     Set Variable If    "${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].hardware_type}" in ["FSMF", "FSIH"]
    ...     --NO_dsp_linking    ${EMPTY}
    ${is_tty}=    installation_internal.has_a_tty
    ${command}=    Set Variable If
    ...    '${is_tty}'=='True'
    ...  sshpass -p ${sm_pw} python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /tmp/YAFT_IMAGE/GNB -R --ask_for_password ${ignore_FSPs_flag} ${L_flag}
    ...    '${is_tty}'=='False'
    ...  echo ${sm_pw} | python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /tmp/YAFT_IMAGE/GNB -R --ask_for_password ${ignore_FSPs_flag} ${L_flag}
    RETURN    ${command}


Prepare eNB Yaft Command
    [Documentation]    :Author: Amr Aboushehata
    ...    [PRIVATE]
    [Arguments]    ${enb_id}=0
    ${ip_address}=    Set Variable    ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.addr}
    ${sm_pw}=     Set Variable    ${tl.enbs[${enb_id}].system_module.common_units[${0}].lmp_connection.password}
    ${is_tty}=    installation_internal.has_a_tty
    ${command}=    Set Variable If
    ...    '${is_tty}'=='True'   sshpass -p ${sm_pw} python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /tmp/YAFT_IMAGE/ENB -R --ask_for_password
    ...    '${is_tty}'=='False'    echo ${sm_pw} | python ${YAFT_PATH}/yaft.py -i ${ip_address} -d /tmp/YAFT_IMAGE/ENB -R --ask_for_password
    RETURN    ${command}


Copy Swconfig To Passive Side
    [Documentation]    :Author: Jing Liang
    ...    [PRIVATE]
    [Arguments]    ${gnb_id}=0
    ${ssh_alias}=    connect.Connect to Node Common Unit    node_id=${gnb_id}
    ssh.execute    cp /ffs/run/swconfig.txt /ffs/stb/swconfig.txt    connection=${ssh_alias}
    ssh.disconnect    ${ssh_alias}


Copy Swconfig To eNB Passive Side
    [Documentation]    :Author: Amr Aboushehata
    ...    [PRIVATE]
    [Arguments]    ${enb_id}=0
    ${ssh_alias}=    connect.Connect to Node Common Unit   node_type=enb   node_id=${enb_id}
    ssh.execute    cp /ffs/run/swconfig.txt /ffs/stb/swconfig.txt    connection=${ssh_alias}
    ssh.disconnect    ${ssh_alias}


Evaluate Band Identifier
    [Arguments]     ${bandId}
    ${bandIndicator}=    Set Variable If     ${bandId} > 256    mmWv  cmWv
    RETURN    ${bandIndicator}


Remove eNB user json file
    [Documentation]    :Author: Amr Aboushehata
    [Arguments]    ${enb_id}=0
    ${ssh_alias}=    connect.Connect to Node Common Unit   node_type=enb    node_id=${enb_id}
    Mount and remove user json file    connection=${ssh_alias}
    ssh.disconnect    ${ssh_alias}

Remove gNB user json file
    [Documentation]    :Author: Amr Aboushehata
    [Arguments]    ${gnb_id}=0
    ${ssh_alias}=    connect.Connect to Node Common Unit    node_id=${gnb_id}
    Mount and remove user json file    connection=${ssh_alias}
    ssh.disconnect    ${ssh_alias}

Mount and remove user json file
    [Documentation]    :Author: Amr Aboushehata
    [Arguments]    ${connection}
    ssh.execute    mount -o remount,rw,async /ffs/fs1    connection=${connection}
    ssh.execute    rm /ffs/fs1/config/users.json    connection=${connection}
    ssh.execute    mount -o remount,rw,async /ffs/fs2    connection=${connection}
    ssh.execute    rm /ffs/fs2/config/users.json    connection=${connection}
