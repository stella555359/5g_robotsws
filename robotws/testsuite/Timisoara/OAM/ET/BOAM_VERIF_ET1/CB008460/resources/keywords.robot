*** Settings ***
Library        String
Library        OperatingSystem
Library        BuiltIn
Library        DateTime
Library        OperatingSystem
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh
Library        taf.gnb.oam.coam.admin
Library        taf.sbts.oam.coam.admin    WITH NAME    coam

Library        XML    use_lxml=True
Library        Process
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin

Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot

*** Variables ***

#${lterel_disc}=   http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build
#
#${wft_url}         http://files.ute.nsn-rdnet.net/builds/enb/base/
#${CLI_INTERFACE}                          Get Library Instance    taf.gnb.oam.coam.admin
#${ADMIN_CLI_scripts_location}=  ${CURDIR}/../scripts
*** Keywords ***

Prepare BTS with T1 SW

    ### Reason: UTE orginal SW is flashed with yaft ... we need real SWR at the begining of the test
    ${sw_version}    taf.gnb.oam.coam.admin.Get SW Version
    log to console   ${sw_version}
    Set Suite Variable    ${download_build}  ${sw_version}

    log to console   Download T1 SW packages
    Set Suite Variable    ${T1_package}      ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip

    Log to console  ${wft_url}${download_build}/${T1_package} -P ${SW_DESTINATION}
    ${output}   Run    wget ${wft_url}${download_build}/${T1_package} -P ${SW_DESTINATION}
    should not contain  ${output}   404 Not Found
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}

    log to console   Start Software update to T1 package
    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}/${T1_package}
    ...    timeout=3600
    Sleep  100
    log to console  check BTS Is OnAir
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

Update Software To T1

    log to console  Get initial SW
    Get Software Release before fallback

    log to console  Update Software To T1
    Update Software With Activation Trunk T1

Download SW

    log to console  Start download ${CIT_software_Promoted}
    ${software_split}=    Split String
    ...                          string=${CIT_software_Promoted}
    ...                          separator=_
    ...                          max_split=4

    ${BRANCH}=   Get from list         ${software_split}    0
    Set Global Variable  ${BRANCH}

    Download SW from WFT

Download SW from WFT

    ${download_build}=        Set Variable   ${CIT_software_Promoted}

    Set Suite Variable    ${main_package}    ${download_build}_release_BTSSM_downloadable.zip
    Set Suite Variable    ${T1_package}      ${download_build}_release_BTSSM_downloadable_testpackage_T1.zip
    Log    \nDownload SW packages    console=yes
    Log to console  ${wft_url}${download_build}/${main_package} -P ${SW_DESTINATION}
    ${output}   Run    wget ${wft_url}${download_build}/${main_package} -P ${SW_DESTINATION}
    should not contain  ${output}   404 Not Found
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${main_package}

    Log    \nDownload T1 SW packages    console=yes
    Log to console  ${wft_url}${download_build}/${T1_package} -P ${SW_DESTINATION}
    ${output}   Run    wget ${wft_url}${download_build}/${T1_package} -P ${SW_DESTINATION}
    should not contain  ${output}   404 Not Found
    OperatingSystem.File Should Exist    path=${SW_DESTINATION}/${T1_package}
    Set Global Variable  ${WEBDAVSW}  ${download_build}

    Log    Download completed    console=yes

Update Software With Activation
    log to console  SWR on going

    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}/${CIT_software_Promoted}_release_BTSSM_downloadable.zip
    ...    timeout=3600
    Sleep  100
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period

    log to console  check BTS Is OnAir
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
    ${active_build}=    Replace SW Version

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${active_build}.xml

Update Software With Activation Trunk T1  ## SWR to trunk T1
    log to console  SWR on going
    ADMIN Update Software With Activation
    ...    sw_package=${SW_DESTINATION}/${CIT_software_Promoted}_release_BTSSM_downloadable_testpackage_T1.zip
    ...    timeout=3600

    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period

    log to console  check BTS Is OnAir
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
    ${active_build}=    Replace SW Version
    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	TargetBD_${active_build}T1.xml

Replace SW Version
    ${split_build}=    Split string       ${CIT_software_Promoted}    separator=\_
    ${version_flag}=   Get from list       ${split_build}     0

    ${active_build}=    Replace String    ${CIT_software_Promoted}    ${version_flag}    SBTS22R4
    [return]  ${active_build}


Check initial SW version

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	${OUT_ACTIVE_SW}T1

ADMIN Connect To
    [Arguments]    ${admin_alias}=default
    Log To Console                       ADMIN Connect To \${admin_alias}=${admin_alias}
    taf.gnb.oam.coam.admin.Connect To    name=${admin_alias}


SYSTEM Open SSH Connection on gnb

#    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${SYSTEM_ENB_LOCAL_IP}    port=${port}    timeout=20    alias=${ssh_alias}
    SSHLibrary.Login    username=${SYSTEM_ENB_SSH_USERNAME}    password=${SYSTEM_ENB_SSH_PASSWORD}    delay=1s

Fallback 4082

     SYSTEM Open SSH Connection on gnb

     log to console      Start fallback commands


     ${output1}  SSHLibrary.Write            ddal -s ddal_boot_set_reset_loop_count 3
     SSHLibrary.Read Until       root@
     log to console   ${output1}
     SSHLibrary.Write            ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
     ${output}  SSHLibrary.Read Until       root@
     log to console   ${output}

Get Software Release before fallback

    ${initial_sw_release}   taf.gnb.oam.coam.admin.Get SW Version
    @{split_sw_version}  Split String  ${initial_sw_release}  separator=_
    Run Keyword If  '@{split_sw_version}[0]' == 'SBTS22R4'
    ...     Set Test Variable   ${initial_sw_release}  SBTS00
    ...     ELSE  Set Test Variable  ${initial_sw_release}  ${split_sw_version}[0]

Check initial SW version after Fallback

    ${output}=  SYSTEM Execute Command On gNB
    ...    command=ls /ffs/run/
    should contain  ${output}  	${initial_sw_release}

Prepare ADMIN_CLI
    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
    ${SW_Version}     ADMIN Get Sw Version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${build_ver}=  fetch from left  ${build_ver}  T1
    ${release}        Fetch from left   ${build_ver}  _ENB_
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Run Keyword If     ${fileExists} is False   Run  wget ${lterel_disc}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Log to Console     ADMIN_CLI Download completed
    Run  cp ${ADMIN_CLI_scripts_location}/* ${SW_DESTINATION}/ADMIN_CLI/  ##this line copies the RemoteSWR script for cli
    Run  chmod 777 ${SW_DESTINATION}/ADMIN_CLI/*
    [Return]           ${build_ver}_ADMIN_CLI.zip

Activate CLI feature
   ADMIN Perform Parameter Recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
   ...                                        parameter=actCli
   ...                                        operation=update
   ...                                        value=true

Remote SWR
    Activate CLI feature
    log to console  Start Remote SWR via Webdav using ADMIN_CLI
    ${result}=  Run  /home/ute/ADMIN_CLI/RemoteSWR.sh
    Log to console  ${result}
    Sleep  100
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir
    ##Check for successful SWR
    ${remotesw_version}=    taf.gnb.oam.coam.admin.Get Sw Version
    @{split_sw_version}  Split String  ${remotesw_version}  separator=_
    Run Keyword If  '@{split_sw_version}[0]' == 'SBTS22R4'
    ...     Set Test Variable   ${remotesw_version}  SBTS00
    Should contain  ${remotesw_version}  ${WEBDAVSW}

Add targetBD in script file
    ## Edit RemoteSWR.sh script with the current build
    Run  cd ${ADMIN_CLI_scripts_location}; sed -i 's/general/${WEBDAVSW}/' RemoteSWR.sh
    Run  cd ${ADMIN_CLI_scripts_location}; sed -i 's/SBTS00/SBTS22R4/' RemoteSWR.sh
    Log to console  RemoteSWR.sh is edited

Transfer SW to webdav
    Run  sshpass -p "ute" ssh ute@10.5.25.105 'sudo rm -rf /var/www/webdav/Remotepackage/*'
    Log to console  Transfering ${WEBDAVSW} SW Pack to Remote Server
    Set test variable  ${wsw}  ${WEBDAVSW}_release_BTSSM_downloadable.zip   ##this variable is set only to be under 150 chars per line
    Run  cd ${SW_DESTINATION}; sshpass -p "ute" scp ${wsw} ute@10.5.25.105:/var/www/webdav/Remotepackage
    Log to console  Unzipping ${WEBDAVSW} to .../webdav/Remotepackage
    Run  sshpass -p "ute" ssh ute@10.5.25.105 'unzip -o /var/www/webdav/Remotepackage/${wsw} -d /var/www/webdav/Remotepackage'

Transfer Remote Certificate
    ${output}  Run And Return Rc And Output
    ...  sshpass -p 'Aikonbtsoam2@' scp userbtsoam@10.5.25.200:/${location_remote_swr_cert}/cacert105.pem ${local_remote_swr_cert}
#    Should contain    ${output}  0
    log to console    ${output}


ADD Remote SWR Certificate
    Log To Console      ADD Remote SWR Certificate for 105
#    Login To Web Element Manager
#    SELENIUM Go to Configuration Reset
#    ADD Certificate
    SYSTEM Open SSH Connection ENB   ${SYSTEM_ENB_LOCAL_IP}  ${port}  ${SYSTEM_ENB_SSH_USERNAME}  ${SYSTEM_ENB_SSH_PASSWORD}  ${ssh_alias}
    Install CBRS Certificate    cert_file=${Cacert_FILE}    cert_type=BtsTrustChain    cert_format=PEM  connection=SSHLibrary

#Install certificate not working !!!
Install CBRS Certificate
    [Arguments]    ${cert_file}    ${cert_type}    ${cert_format}    ${connection}
    coam.install_certificate    cert_file=${cert_file}    cert_type=${cert_type}
    ...    cert_format=${cert_format}    connection=${connection}

SYSTEM Open SSH Connection ENB
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=20    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s
