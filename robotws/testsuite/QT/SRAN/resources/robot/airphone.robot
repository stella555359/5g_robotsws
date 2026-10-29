*** Settings ***
Documentation    Suite documentation - Airphone for QT as a Service.
...              author: QT
Library     BuiltIn
Library     OperatingSystem
Library     hashlib
Library     Collections
Library     String
Library     XML
Library     ute_admin_infomodel
Library     taf.sbts.oam.coam.admin   WITH NAME    coam

*** Variables ***
${bts_host}    192.168.255.129
${path}        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${vm_logdir}               ${EXECDIR}/logs

*** Keywords ***
Download package
    [Documentation]    Download selected package.
    ...                author: Emilia Sadowska
    [Arguments]    ${url}    ${target_dir}=/tmp
    ${status}    Run Keyword And Return Status
    ...          Download Build    url=${url}
    ...                            target_dir=${target_dir}
    Run Keyword If    '${status}'=='${False}'    Run Keywords
    ...               Log To Console    \n Download build failed, start download build using WGET
    ...        AND    Download Build Using WGET    url=${url}
    ...                                            target_dir=${target_dir}

Download Build
    [Documentation]    Download selected package.
    ...                author: Emilia Sadowska
    [Arguments]    ${url}    ${target_dir}
    OperatingSystem.Run    aria2c -x 16 -s 16 ${url} -d ${target_dir}
    ${build_package}       Fetch From Right    ${url}    /
    OperatingSystem.File Should Exist      ${target_dir}/${build_package}
    Set Test Variable    ${sw_package_location}    ${target_dir}/${build_package}

Download Build Using WGET
    [Documentation]    Different way to download selected package if lterel fail.
    ...                author: Emilia Sadowska
    [Arguments]    ${url}    ${target_dir}
    OperatingSystem.Run    cd ${target_dir} && wget ${url}
    ${build_package}       Fetch From Right    ${url}    /
    OperatingSystem.File Should Exist      ${target_dir}/${build_package}
    Set Test Variable    ${sw_package_location}    ${target_dir}/${build_package}

Check If SW version is not empty
    [Documentation]    Check if any software version is visible.
    ...                author: Emilia Sadowska
    Wait Until Keyword Succeeds    3min  20s    coam.connect to
    ...    bts_host=${bts_host}    update_interval=1000   name=coam_admin
    ${sw_version}    Wait Until Keyword Succeeds    3min  20s
    ...              coam.get_sw_version    timeout=30    connection=coam_admin
    Should not be empty    ${sw_version}
    RETURN      ${sw_version}

Install gNB package
    [Documentation]    Install selected software version.
    ...                author: Emilia Sadowska
    [Arguments]          ${sw_version}       ${component}=${EMPTY}
    ${sw_version}        Fetch From Left     ${sw_version}    _release_
    ${component}         Set Variable If    '${component}'!='${EMPTY}'    _testpackage_${component}    ${EMPTY}
    Set Test Variable    ${build_package}    ${sw_version}_release_BTSSM_downloadable${component}_A54.zip
    ${knife_url}         Get Variable Value    ${knife_url}    ${False}
    Run Keyword If       ('${knife_url}'!='${False}' and '${knife_url}' != 'not_set') and '${component}'!='${EMPTY}'
    ...    Get T1 Knife URL    ${knife_url}    ${component}
    Run Keyword If       '${TESTBUILD_STATUS}' == '${True}'   Find Testbuild    ${component}
    Run Keyword If       '${URL_STATUS}' == '${True}'         Find URL          ${component}
    ${url}    Set Variable If    ('${knife_url}'!='${False}' and '${knife_url}' != 'not_set')          ${knife_url}
    ...                          '${TESTBUILD_STATUS}' == '${True}'    ${testbuild_package}
    ...                          '${URL_STATUS}' == '${True}'          ${url_link}
    ...       ${path}/${stream_nr}/${sw_version}/${build_package}
    Download package    ${url}
    Log to console    \n Install SW Package: ${url}
    Wait Until Keyword Succeeds    4min  20s    coam.connect to
    ...    bts_host=${bts_host}    update_interval=1000   name=coam_admin
    coam.update_software    ${sw_package_location}    timeout=5400    connection=coam_admin
    [Teardown]    Run Keywords    OperatingSystem.Run    rm -f /tmp/${stream_nr}_*
    ...           AND             OperatingSystem.Run    df
    ...           AND             OperatingSystem.Run    rm -rf /home/ute/MN/UTE/robotlte
    ...           AND             coam.teardown    connection=coam_admin

Get T1 Knife URL
    [Arguments]          ${knife_url}       ${component}
    ${part_of_url}       Fetch From Left    ${knife_url}    _A54.zip
    Set Test Variable    ${knife_url}    ${part_of_url}${component}_A54.zip

Check if installed package is on active version
    [Documentation]    Wait until BTS updates its active partition after package installation
    ...                author: Aleksandra Wolczecka
    [Arguments]    ${expected_sw_version}
    ${current_sw_version}    Check If SW version is not empty
    ${active_sw_version}    Fetch From Right    ${current_sw_version}    _ENB_
    Should Be Equal    ${expected_sw_version}    ${active_sw_version}
    Log to console    \n After SW installation we have on the BTS:
    Log to console    \n Active partition SW: ${current_sw_version}

Check SW version
    [Documentation]    Check if installed software version is correct.
    ...                author: Emilia Sadowska
    [Arguments]        ${component}=none
    ${sw_version}        Check If SW version is not empty
    ${sw_version}        Fetch From Right    ${sw_version}    _ENB_
    Log to console       \n SW Version: ${stream_nr}_ENB_${sw_version}
    Run Keyword If       '${component}'!='none'    Should Contain    ${sw_version}    ${component}
    ...                  ELSE    Set Suite Variable    ${sw_version}     ${stream_nr}_ENB_${sw_version}

Perform commissioning
    [Documentation]    Perform commissioning with scf from testconfigs repository.
    ...                author: Emilia Sadowska
    ${scf_repo}    Run Keyword And Return Status    Get SCF from repo
    Get Current SCF
    Log To Console       gNB SCF: ${scf}
    Wait Until Keyword Succeeds    1min  15s    coam.connect_to    bts_host=${bts_host}
    ...                                                            update_interval=1000
    ...                                                            name=coam_admin
    ${scf_validation_result}    coam.validate_scf    ${scf}    connection=coam_admin
    Log to console     \n--> Validation status: ${scf_validation_result['niddValidationResult']['status']}
    Wait until Keyword Succeeds    3x    10s
    ...                            coam.perform_commissioning     scf_file=${scf}    skip_parameter_relation_errors=False
    ...                            timeout=660    connection=coam_admin
    [Teardown]    coam.teardown    connection=coam_admin

Get Current SCF
    Wait Until Keyword Succeeds    1min  15s    coam.connect_to    bts_host=${bts_host}
    ...                                                            update_interval=1000
    ...                                                            name=coam_admin
    coam.get_current_scf_file    local_dir_path=${vm_logdir}
    ...                          file_name=scf_from_webui.xml
    ...                          timeout=60    connection=coam_admin
    Set Test Variable    ${scf}    ${vm_logdir}/scf_from_webui.xml
    [Teardown]    coam.teardown    connection=coam_admin

Get SCF from repo
    [Documentation]     Download testconfigs repository and select scf.
    Set Test Variable   ${AP_configs}      /home/ute/AP_configs_repo
    Run                 git clone "ssh://gerrit.ext.net.nokia.com:29418/MN/5G/TEST/testconfigs" ${AP_configs}
    Run                 cd ${AP_configs} && git pull origin master
    ${ap_cp_hardware}   Get Substring    ${ap_cp_hardware}    1    -1
    ${configuration}    Set Variable
    ...                 Airphone_${ap_sm_hardware}_${ap_cp_hardware}_${duplexing}_${RF_type}_${wavelength}
    ${scf_gnb}          get_config_filename     gNB_DU_scf      ${configuration}
    ...                 ${AP_configs}/${stream_nr}/${deployment}/FS
    Set Test Variable   ${scf}    ${AP_configs}/${scf_gnb}

Get Baseline
    [Documentation]        Get environment variable: TESTBUILD
    ${TESTBUILD_STATUS}    Run Keyword And Return Status        Variable Should Exist    ${TESTBUILD}
    ${URL_STATUS}          Run Keyword And Return Status        Variable Should Exist    ${URL}
    BuiltIn.Set Global Variable     ${TESTBUILD_STATUS}
    BuiltIn.Set Global Variable     ${URL_STATUS}
    Check SW version

Get Baseline For Classical
    [Documentation]        Get environment variable: URL, TESTBUILD
    ${TESTBUILD_STATUS}    Run Keyword And Return Status        Variable Should Exist    ${TESTBUILD}
    ${URL_STATUS}          Run Keyword And Return Status        Variable Should Exist    ${URL}
    ${SW_VER_STATUS}       Run Keyword And Return Status        Variable Should Exist    ${SW_VERSION}
    ${stream_nr}           Get Variable Value    ${ENB_BRANCH}    SBTS00
    BuiltIn.Set Global Variable    ${stream_nr}
    ${STREAM}              BuiltIn.Set Variable If    '${stream_nr}'=='SBTS00'    ENB_9999    ${None}
    Run Keyword If         '${URL_STATUS}'=='True'    Get SW Build From Knife URL
    ...    ELSE IF         '${URL_STATUS}'=='False' and '${TESTBUILD_STATUS}'=='False' and '${SW_VER_STATUS}'=='False'
    ...                    Check SW version
    ${SW_VERSION}    Remove String    ${SW_VERSION}    T1
    ${SW_VERSION}    Remove String    ${SW_VERSION}    T2
    ${AF_PATH}    Set Variable      /media/builds/${SW_VERSION}/${SW_VERSION}_release_BTSSM_downloadable_A54.zip
    BuiltIn.Set Global Variable     ${TESTBUILD_STATUS}
    BuiltIn.Set Global Variable     ${URL_STATUS}
    BuiltIn.Set Global Variable     ${stream_nr}
    BuiltIn.Set Global Variable     ${STREAM}
    BuiltIn.Set Global Variable     ${AF_PATH}
    BuiltIn.Set Global Variable     ${SW_VERSION}

Find Testbuild
    [Arguments]      ${component}
    ${xml_status}    Run Keyword And Return Status    File Should Not Exist    /tmp/Content_${TESTBUILD}.xml
    ${wft}           Set Variable    https://wft.int.net.nokia.com/ext/build_content/${TESTBUILD}
    Run Keyword if   '${xml_status}'=='True'    Run
    ...              curl -o /tmp/Content_${TESTBUILD}.xml --connect-timeout 5 --max-time 25 --retry 3 --retry-delay 0 --retry-max-time 40 -k ${wft}
    Set Test Variable    ${testbuild_package}    ${TESTBUILD}_release_BTSSM_downloadable${component}_A54.zip
    ${status}        ${storage}    Run Keyword And Ignore Error    Get Elements Texts
    ...              /tmp/Content_${TESTBUILD}.xml    xpath=.//storages/storage[@title="ARTIFACTORY"]/file[@title="${testbuild_package}"][@url]
    BuiltIn.Set Global Variable    ${testbuild_package}    ${storage}[0]

Find URL
    [Documentation]    Get url for build.
    [Arguments]      ${component}
    ${url_link}    Fetch From Left    ${URL}    _A54.zip
    Set Test Variable    ${url_link}    ${url_link}${component}_A54.zip

Find Knife Build
    [Documentation]    Check if knife build is set.
    Check SW version
    ${knife_url}    Fetch From Right    %{CM_ARTIFACTS}    btssw_url": "
    ${knife_url}    Fetch From Left     ${knife_url}       ", "knife
    ${knife_url}    Fetch From Left     ${knife_url}       "}, "add_date":
    BuiltIn.Set Global Variable    ${knife_url}

Find Knife Build For On Demand Run
    [Documentation]    Get btssw_url value from CM_ARTIFACTS and assign it to knife_url for On Demand Run
    Check SW version
    ${knife_url}         Fetch From Right    %{CM_ARTIFACTS}    "btssw_url": "
    ${knife_url}         Fetch From Left     ${knife_url}       ", "build_paths"
    ${knife_url}         Fetch From Left     ${knife_url}       "}, "knife"
    Should Start With    ${knife_url}        https://
    Should End With      ${knife_url}        _downloadable_A54.zip
    BuiltIn.Set Global Variable    ${knife_url}
    Log to console    \nKnife URL found: ${knife_url}

Run WTS
    Run      rm -rf /opt/wts/latest/egate_console*
    Stop Edaemon Egate
    Configure UTE ETH3
    Run Keyword If    '${4G5G_Combo}'=='1' and '${variant_name}' == '4G5G_COMBO_MultiUE'    Configure UTE and IPV6 ETH3
    ...    ELSE IF    '${4G5G_Combo}'=='1'    Configure IPV6 ETH3
    Run Keyword If    '${4G5G_CUS}'=='1' and '${variant_name}' == '4G5G_CUS_MultiUE'    Configure UTE and IPV6 ETH3 FOR CUS
    ...    ELSE IF    '${4G5G_CUS}'=='1'    Configure UTE ETH3 and ETH4 FOR CUS
    Run Keyword If    '${BOAM_ET_CONF}'=='1'
    ...    Configure UTE ETH3 FOR BOAM_ET_CONF
    Log to Console                 Starting WTS...
    Add ca_5gair User in ssh config
    Run Keyword If    '${variant_name}' == '4G5G_CUS_MultiUE'    Copy CUS MultiUE lua file
    ${SKIP_WTS_CONFIG_DL}    Get Variable Value    ${WTS_CONFIG}    False
    Run Keyword If    '${SKIP_WTS_CONFIG_DOWNLOAD}' == 'False' and '${SKIP_WTS_CONFIG_DL}' == 'False'    Download of WTS config Files
    Run Keyword If    '${SKIP_WTS_CONFIG_DL}' == 'True'    Run    cp ${WTS_DIR}/basic_setup.cfg ${WTS_DIR}/${SUITE_WTS_CFG}
    Run Keyword If    '${4G5G_CUS}' == '1' or '${variant_name}' == '4G5G_CUS_MultiUE'    Enable Uexgate for CUS
    Update Bearer Configuration For TCP Traffic
    Connect To WTS VM
    wtsrunner.configure_wtsemu_edaemon    edaemon_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=22222
    ...                                   sudo_password=ute
    wtsrunner.configure_wtsemu_egate      egate_ssh_alias=${WTS.Connection}
    ...                                   directory_path=${WTS_DIR}
    ...                                   port=20000
    ...                                   nostats=True
    wtsrunner.start_wtsemu                egate_console_ip=${WTS.Ip}
    ...                                   egate_port=20000
    ${ls}    Run    ls ${WTS_DIR}/*cfg
    Log To Console    ${ls}
    ${cfg_filename}  set variable   ${WTS_DIR}/${SUITE_WTS_CFG}
    wtsrunner.configure                      file=${cfg_filename}
    Run Keyword If    '${apConfiguration}' == 'fs_tdd_sa_eCpri_cmwv_E_AP_E_6G'    Enable Radio for 6G usage
    wtsrunner.read_wtsemu_output_until_re    expected=SimMode is ready now     timeout=240
    Wait Until Keyword Succeeds    2 min    30 sec    Verify if sim state is active
    Run Keyword If    '${MAX_THROUGHPUT}' == 'True'    Testmode enable

Copy logs to test_results
    Run    cp -R ${vm_logdir} /home/ute/test_results/

Get SW Build From Knife URL
    ${SW_VERSION}    Fetch From Left     ${URL}         _release_BTSSM_downloadable_A54.zip
    ${SW_VERSION}    Fetch From Right    ${SW_VERSION}    /
    BuiltIn.Set Global Variable    ${SW_VERSION}

Checkout To Robotws Branch
    ${branch_status}    Run Keyword And Return Status    Variable Should Exist    ${ROBOTWS_BRANCH}
    ${git_command}      Run Keyword If    '${branch_status}'=='True'    Catenate    rm -rf /home/ute/MN/UTE/robotws
    ...                                   && cd /home/ute/MN/UTE && git clone git@wrgitlab.ext.net.nokia.com:RAN/robotws.git
    ...                                   && cd /home/ute/MN/UTE/robotws && git config --global user.email "auqt@nokia.com"
    ...                                   && git config --global user.name "auqt" && git reset --hard
    ...                                   && git checkout ${ROBOTWS_BRANCH} && git pull origin ${ROBOTWS_BRANCH} -q && git log -1
    Run Keyword If    '${branch_status}'=='True'    Run Keywords    Run    ${git_command}
    ...        AND    Log To Console    \n Robotws has been checkout to '${ROBOTWS_BRANCH}' branch.
