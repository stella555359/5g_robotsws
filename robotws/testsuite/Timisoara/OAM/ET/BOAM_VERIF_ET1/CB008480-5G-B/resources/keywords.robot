*** Settings ***
Library        String
Library        OperatingSystem
Library        BuiltIn
Library        DateTime
Library        OperatingSystem
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh
Library        taf.gnb.oam.coam.admin     WITH NAME    admin_api
Library     XML    use_lxml=True
Library        Process
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin

Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot


*** Variables ***

*** Keywords ***

Check Parameter Value
    [Arguments]    ${expected_value}    ${parameter_name}    ${dist_name}
    ${value}    Admin Get Parameter
    ...    dist_name=${dist_name}
    ...    parameter=${parameter_name}
    ${value}   convert to string  ${value}
    Should Contain    ${value}    ${expected_value}

ADMIN_CLI Suite Setup
    Download ADMIN_CLI Package
    Transfer ADMIN_CLI scripts


Download ADMIN_CLI Package
    [Documentation]    Kw download Common Trunk AdminCLI from disc e.g.:
    ...    https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_210505_000001_ADMIN_CLI.zip
    ${SW_Version}     ADMIN Get Sw Version
    ${is_TrunkBuild}=     Run Keyword and Return Status    Should Contain      ${SW_Version}      _9999_
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${release}        Fetch from left   ${build_ver}  _ENB_
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Run Keyword If     ${fileExists} is False   Run  wget ${lterel_disc}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P ${SW_DESTINATION}
    ${fileExists}      Run Keyword and Return Status  OperatingSystem.File Should Exist   ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    Run  unzip -o ${SW_DESTINATION}/${build_ver}_ADMIN_CLI.zip -d ${SW_DESTINATION}/ADMIN_CLI
    Log to Console     Download completed
    [Return]           ${build_ver}_ADMIN_CLI.zip

Transfer ADMIN_CLI scripts
    Run  cp ${ADMIN_CLI_scripts_location}/* ${SW_DESTINATION}/ADMIN_CLI/
    ${output1}  Run And Return Rc And Output
    ...  sshpass -p 'Aikonbtsoam2@' scp userbtsoam@10.5.25.200:/${location_o-ru_package}/* ${SW_DESTINATION}/ADMIN_CLI/
    Log to Console     ${output1}
    ${output2}  Run And Return Rc And Output
    ...  sshpass -p 'Aikonbtsoam2@' scp userbtsoam@10.5.25.200:/${location_o-ru_package2}/* ${SW_DESTINATION}/ADMIN_CLI/
    Log to Console     ${output2}
    Run  chmod 777 ${SW_DESTINATION}/ADMIN_CLI/*

Activate CLI feature
   ADMIN Perform Parameter Recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
   ...                                        parameter=actCli
   ...                                        operation=update
   ...                                        value=true


Deactivate CLI feature
   ADMIN Perform Parameter Recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
   ...                                        parameter=actCli
   ...                                        operation=update
   ...                                        value=false


ORU SWR1
    Activate CLI feature
    log  Start ORU SWR to version 1.1
    ${result}=  Run  cd /home/ute/ADMIN_CLI; ./ORUswr1.sh
    Log to console  ${result}
    Sleep  30

    Log to console   Check operationalstate online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_oru_sw}
    ...      value=enabled

    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir


    ${oruRunningSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=runningSwVersion
    Should Contain  ${oruRunningSw}  oru-sw-r1_1.1
    ${oruActiveSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=activeSwVersion
    Should Contain  ${oruActiveSw}  oru-sw-r1_1.1
    log to console   ORU active and running SW version is 1.1
    Deactivate CLI feature

ORU SWR2
    Activate CLI feature
    log  Start ORU SWR to version 1.2
    ${result}=  Run  cd /home/ute/ADMIN_CLI; ./ORUswr2.sh
    Log to console  ${result}
    Sleep  30

    Log to console   Check operationalstate online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_oru_sw}
    ...      value=enabled

    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

    ${oruRunningSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=runningSwVersion
    Should Contain  ${oruRunningSw}  oru-sw-r1_1.2
    ${oruActiveSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=activeSwVersion
    Should Contain  ${oruActiveSw}  oru-sw-r1_1.2
    log to console   ORU active and running SW version is 1.2
    Deactivate CLI feature

ORU SWR2 autorr disabled
    Activate CLI feature
    log  Start ORU SWR to version 1.2 with auto-Radio Reset disabled
    ${result}=  Run  cd /home/ute/ADMIN_CLI; ./ORUswr2_autorr_disabled.sh
    Log to console  ${result}
    Sleep  30

    Log to console   Check operationalstate online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_oru_sw}
    ...      value=enabled

    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

    ${oruRunningSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=runningSwVersion
    Should Contain  ${oruRunningSw}  oru-sw-r1_1.1
    ${oruActiveSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=activeSwVersion
    Should Contain  ${oruActiveSw}  oru-sw-r1_1.2
    log to console   ORU active SW version is 1.2
    Deactivate CLI feature

ORU SWR2blocked
    Activate CLI feature
    log  Start ORU SWR to version 1.2
    ${result}=  Run  cd /home/ute/ADMIN_CLI; ./ORUswr2.sh
    Log to console  ${result}
    Sleep  30

    Log to console   Check operationalstate online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_oru_sw}
    ...      value=enabled

    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir

    ${oruRunningSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=runningSwVersion
    Should Contain  ${oruRunningSw}  oru-sw-r1_1.1
    ${oruActiveSw}    ADMIN INFOMODEL Get Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=activeSwVersion
    Should Contain  ${oruActiveSw}  oru-sw-r1_1.1
    log to console   ORU active and running SW version is 1.1
    Deactivate CLI feature

Reset RMOD
    [Arguments]  ${rmod_dist_name}    ${connection}=GNB_OAM
    admin_api.connect_to    bts_host=192.168.255.129    username=Nemuadmin    password=nemuuser    name=${connection}
    admin_api.reset_unit    dist_name=${rmod_dist_name}    connection=${connection}    timeout=300    force_radio_reset=${TRUE}
    admin_api.teardown_admin  connection=${connection}

Update Software ORU1 pack
    Log to console   SWR to ORU original pack
    ADMIN Update Software With Activation
    ...    sw_package=/home/ute/ADMIN_CLI/ORU_package_1_1.zip
    ...    timeout=3600
    sleep  10
    Reset RMOD  rmod_dist_name=MRBTS-${OUT_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
    sleep  10
    Log to console   Check operationalstate online for RMOD_R-1
    Wait Until Keyword Succeeds    300    20    ADMIN INFOMODEL Check OperationalState Value
    ...      dist_name=${dist_name_oru_sw}
    ...      value=enabled
    Log to console   Check runningSwVersion for RMOD_R-1

     Wait Until Keyword Succeeds    400    20    ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=${dist_name_oru_sw}
    ...    dict_param=runningSwVersion
    ...    value=oru-sw-r1_1.1
