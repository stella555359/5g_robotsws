*** Settings ***
Documentation
...     author: Jingang Sun/Wang Cuicui
...     contact: jingang.sun@nokia-sbell.com/cuicui.wang@nokia-sbell.com
...     SC gNB PnP related keywords

Library    ../python/DevNJ_download_build_from_LS.py
Library    taf.transport.ssh    WITH NAME    csn
Library    OperatingSystem
Library    ../python/DevNJ_gNB_PnP_keywords.py
Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    taf.fdsw.rc    WITH NAME    rc
Library    taf.ul.sc.gnb.oam.rest.CommonOAM    oam_ip=${tl.gnbs[0].cu.oam_http_connection_details.addr}     WITH NAME    RestAPI

*** Variables ***
${gnb_id}=    0
${IP_ADDRESS}=    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USER}=    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PW}=    ${tl.gnbs[${gnb_id}].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_IP}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${RC_LOGIN}     false
${FDSW_LOGIN}   false

*** Keywords ***
Prepare Yaft Command
    [Documentation]    Cuicui Wang: This Keyword is To Prepare Command For Yaft
    ...    _filename_     Build Name For Example LN_MN_xxxxx.zip
    ...    _ip_address_   Host IP Address For Example 192.168.255.129
    ...    _asik_pw_      Password of Host IP Address
    ...    _gnb_id_       gNB Index in __init__.py
    ...    Return value:  command: yaft cmd
    ...    Private Function
    [Arguments]    ${filename}=LN_WN_FDSW21A_0000_000130_000000_release_BTSSM_downloadable.zip
    ...            ${ip_address}=${IP_ADDRESS}
    ...            ${asik_pw}=${ASIK_PW}

    ${yaft_path}    Checkout Yaft From Svn
    OperatingSystem.Should Exist  ${yaft_path}
    ${buildpath}    Download Factory File From Load Server  ${filename}
    ${command}    Set Variable
    ...  echo ${asik_pw} | python ${yaft_path} --ip ${ip_address} --NO_lockfile --ignore_slaves --ask_for_password --clean_to_default -z ${buildpath}
    [Return]    ${command}

Install Package Via Yaft
    [Documentation]    Cuicui Wang: This Keyword is To Install Package Via Yaft
    ...    _loadname_     Build Name For Example LN_MN_xxxxx.zip
    ...    _ip_address_   Host IP Address For Example 192.168.255.129
    ...    _asik_pw_      Password of Host IP Address
    ...    _gnb_id_       gNB Index In __init__.py
    ...    Example:
    ...    | Install Package Via Yaft | loadname |
    ...    Return value: None
    ...    Public Function
    [Arguments]    ${loadname}=LN_WN_FDSW21A_0000_000130_000000_release_BTSSM_downloadable.zip
    ...            ${ip_address}=${IP_ADDRESS}
    ...            ${asik_pw}=${ASIK_PW}
    ...            ${gnb_id}=0

    ${command}  Prepare Yaft Command  ${loadname}  ${ip_address}  ${asik_pw}  ${gnb_id}
    ${output}    OperatingSystem.Run     ${command}
    ${flash_flag}    Run Keyword And Return Status    Should Contain    ${output}    Flashing done
    ${reboot_flag}    Run Keyword And Return Status    Should Contain    ${output}    Waiting for FC* after reboot
    Run Keyword If    ${flash_flag} or ${reboot_flag}    Log To Console    msg=Yaft Success! With Msg ${output}
    ...    ELSE    Fail    msg=Yaft Failed! With Msg ${output}

FDSW Clear
    [Documentation]    Cuicui Wang: This Keyword is To Clear Info In gNB To Improve ASIR PnP Success Rate
    ...    _filename_     File Name Which Inculde Cmd Want To Run On gNB For Example FDSW_clear
    ...    _ip_address_   Host IP Address For Example 192.168.255.129
    ...    _asik_pw_      Password of Host IP Address
    ...    _gnb_id_       gNB Index In __init__.py
    ...    Example:
    ...    | FDSW Clear | filename |
    ...    Return value: None
    ...    Public Function
    [Arguments]    ${filename}=FDSW_clear
    ...            ${ip_address}=${IP_ADDRESS}
    ...            ${asik_user}=${ASIK_USER}
    ...            ${asik_pw}=${ASIK_PW}

    ${file_path}    Download Factory File From Load Server  ${filename}
    Csn.Connect To  ${ip_address}    ${asik_user}    ${asik_pw}    alias=${filename}
    Csn.Upload File    ${file_path}    /tmp/${filename}    connection=${filename}
    ${output}    Csn.Execute    chmod 777 /tmp/${filename} && /tmp/${filename}    connection=${filename}
    Csn.Disconnect    connection=${filename}

Prepare GNB Commission File
    [Documentation]  This keyword used to *save gNB commission* and *rename it*, return updated full path commission file
    ...    _local_scf_path_: local directory to save commission file
    ...    _gnb_scf_: name of the downloaded commissioning file
    ...    Example :
    ...    | Prepare GNB Commission File | /tmp | saved_scf.xml |
    ...    Return value: Updated_SCF
    [Arguments]  ${local_scf_path}      ${gnb_scf}
    RestAPI.Get Current Commissioning   log_dir=${local_scf_path}   scf_name=${gnb_scf}
    ${Current_SCF}    Set Variable    ${local_scf_path}/${gnb_scf}
    OperatingSystem.File Should Exist    ${Current_SCF}
    ${Updated_SCF}     Rename gNB Commissioning File   path_to_scf=${Current_SCF}
    [Return]  ${Updated_SCF}

Set gNB PnP Parameters Via RescueConsole
    [Documentation]  This keyword used to set Auto Connection parameters via *Rescue Console* (tls=off by feature team)
    ...    _ac_file_path_:  autoconnect parameter file
    ...    _fdsw_version_: FDSW version
    ...    Example :
    ...    | Set gNB PnP Parameters Via RescueConsole | /##/##/test_file.xml | fdsw19a |
    ...    Return value: None
    [Arguments]    ${ac_file_path}
    #the #content is for FDSW19A
    #${Conn}     Rescue Console Connect     ${fdsw_version}
    ${PnP_protocol}    Get Auto Connection Protocol    path_to_file=${ac_file_path}
    ${ac_parameters}   Parse Auto Connection Parameters    path_to_file=${ac_file_path}
    Log To Console      \n Begin to Set Auto Connection Parameters
    #${Result}  Set Auto Conn Parameters
    #...     parameters=${ac_parameters}     protocol=${PnP_protocol}    connection=${Conn}
    #Set Autoconnection Parameters
    #log to console      End of Set Auto Connection Parameters
    #Should Be Equal     ${Result}  Success
    #below content is for FDSW21A
    ${con}=    FDSW.Connect
    Set Suite Variable    ${FDSWCONN}    ${con}
    Run Keyword And Ignore Error    FDSW.SetParameters    con=${con}    parameters=${ac_parameters}
    log to console      End of Set Auto Connection Parameters

Rescue Console Connect
    [Documentation]  This keyword used to connect to gNB rescue console
    ...    _fdsw_version_: FDSW version
    ...    Example:
    ...    | Rescue Console Connect | fdsw19a |
    ...    Return value: conn
    [Arguments]  ${fdsw_version}
    Run Keyword If   '${RC_LOGIN}'=='true'    rc.teardown
    ${conn}   Wait until keyword succeeds     10min    30s   rc.connect_to
    ...    fdsw_version=${fdsw_version}     ip_address=${ASIK_IP}    port=443    username=Nemuadmin    password=nemuuser
    set suite variable    ${RC_LOGIN}    true
    [Return]    ${conn}

Get AC File Path For PnP
    [Documentation]    Min Dai: This Keyword is To Get the AC File Path Used For Macro Site PnP
    ...    _filename_     File Name of AC File, including IPV4 and IPV6
    ...    Example:
    ...    | Get AC File Path For PnP | filename |
    ...    Return value: /home/ute/pkgload/filename
    ...    Public Function
    [Arguments]    ${filename}=Autoconnection_Parameters.xml
    ${file_path}    Download Factory File From Load Server  ${filename}
    [Return]    ${file_path}

FDSW.Connect
    Run Keyword If   '${FDSW_LOGIN}'=='true'    rc.teardown
    ${con}   Wait until keyword succeeds     10min    30s   rc.connect_to
    ...    ip_address=${ASIK_IP}    port=443    username=Nemuadmin    password=nemuuser
    set suite variable    ${FDSW_LOGIN}    true
    [Return]       ${con}

FDSW.DisConnect
    Return From Keyword if    '${FDSW_LOGIN}'=='false'
    Run Keyword And Ignore error    rc.teardown
    set suite variable    ${FDSW_LOGIN}    false

FDSW.SetParameters
    [Arguments]    ${con}    ${parameters}    ${protocol}=NE3S    ${scenario}=private network manual
    rc.set_autoconnection_parameters_to_default
    ...    primary_ip_address=${parameters['ipAddress']}
    ...    primary_prefix_length=${parameters['prefixLength']}
    ...    primary_gateway=${parameters['gateway']}
    ...    identification_entity_ip_address=${parameters['omsIpAddress']}
    ...    primary_vlan_id=${parameters['vlanId']}
    ...    ip_address=${None}
    ...    server_port=${None}
    ...    subject_name=${None}
    ...    directory=${None}
    ...    vpn_gateway_ip_address=${None}
    ...    timeout=10
    ...    protocol=${protocol}
    ...    scenario=${scenario}
    ...    connection=${con}
    [Teardown]    rc.teardown     connection=${con}
