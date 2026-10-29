*** Settings ***
Documentation
...    usage1(newest trunk build): mybot -v gnb_v:SBTS00 update_gnb.robot
...    usage2(newest branch build): mybot -v gnb_v:SBTS22R2 update_gnb.robot
...    usage3(official build): mybot -v gnb_v:SBTS00_ENB_9999_220412_000005 update_gnb.robot
...    usage4(knife build): mybot -v gnb_v:SBTS00_ENB_9999_220412_793542 update_gnb.robot
...    knife url:
...    https://knife-results.es-si-s3-z2.eecloud.nsn-net.net/793542/SBTS00_ENB_9999_220412_793542_release_BTSSM_downloadable_A54.zip
...    official build url:
...    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_220412_000005_release_BTSSM_downloadable_A54.zip
Resource          ${EXECDIR}/testsuite/Beijing/ET/airphone/resources/common_setup_teardown_bj.robot
*** Variables ***
${gnb_v}    SBTS00
#${gnb_v}    SBTS00_ENB_9999_220412_000005    #official
#${gnb_v}    SBTS00_ENB_9999_220412_793542    #knife
${package_dir}    /home/ute/output/builds/
${gnb_load}          /home/ute/gnb_load/SBTS00_ENB_9999_220906_000002_release_BTSSM_downloadable.zip

*** Test Cases ***
Update Gnb On Jenkins
    [Tags]    update_on_jenkins
    ${rest}  ${name}=     Split String From Right    ${gnb_load}    /    1
    ${gnb_load_file}   ${file_type}           Split String     ${name}    .    1
    ${gnb_load_ver}   ${file_type}           Split String     ${name}    _release    1
    set suite variable      ${gnb_load_file}
    set suite variable      ${gnb_load_ver}
    Update Software With Admin On Jenkins     ${gnb_load}
    sleep                   600
    Check Gnb Version       ${gnb_load_ver}
    sleep                   5
    Check Gnb Status

Test Case Update Gnb
    Remove Package
    ${package_type}    ${gnb_build}=    Is Package Offical Or Knife    ${gnb_v}
    run keyword if    "${package_type}"=="offical"
    ...    Download Gnb Offical Package    ${gnb_build}
    ...    ELSE    Download Gnb Knife    ${gnb_build}
    Update Software With Admin

*** Keywords ***
Remove Package
    Run    rm -rf ${package_dir}*

Get Latest Package
    [Arguments]    ${gnb_build}
    ${cmd}=    Catenate    SEPARATOR=    curl http://files.ute.nsn-rdnet.net/builds/enb/base/|grep ${gnb_build}
    ...    |sort -r|sed -n '1p'|grep -Eo 'SBTS[[:alnum:]]{2,4}_ENB_[[:digit:]]{4}_[[:digit:]]{6}_[[:digit:]]{6}'|awk 'NR==1'
    ${gnb_v}=    Run    ${cmd}
    [Return]    ${gnb_v}

Is Package Offical Or Knife
     [Arguments]    ${gnb_build}
    ${ret}=    Run Keyword And Return Status    Should Contain    ${gnb_build}    ENB
    ${gnb_build}=    Run Keyword If    "${ret}"=="False"    Get Latest Package    ${gnb_build}
    ...    ELSE    Set Variable    ${gnb_build}
    Log To Console    \ndownloaded gnb_bulid is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${postfix}=    Get Substring    ${v1[-1]}    0    4
    ${package_type}=    set variable if    "${postfix}"=="0000"    offical    knife
    [Return]    ${package_type}    ${gnb_build}

Download Gnb Knife
    [Arguments]    ${gnb_build}
    Log To Console    installing gnb build version is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${postfix}=    set variable    ${v1[-1]}
    ${cmd}=    catenate    aria2c -j 16 -x 16 -s 16
    ...    https://knife-results.es-si-s3-z2.eecloud.nsn-net.net/${postfix}/${gnb_build}_release_BTSSM_downloadable_A54.zip
    ...    -d ${package_dir}
    Log To Console    ${cmd}
    Run    ${cmd}

Download Gnb Offical Package
    [Arguments]    ${gnb_build}
    Log To Console    installing gnb build version is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${branch}=    set variable    ${v1[0]}
    ${cmd}=    catenate    aria2c -j 16 -x 16 -s 16
    ...    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/${branch}/${gnb_build}_release_BTSSM_downloadable_A54.zip
    ...    -d ${package_dir}
    Log To Console    ${cmd}
    Run    ${cmd}

Update Software With Admin
    ${ret}=    Run    ls -rt ${package_dir}/SBTS*release_BTSSM_downloadable_A54.zip
    Log To Console    download file: ${ret}
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.update_software    ${ret}    timeout=1800
    sleep                             30
    [Teardown]    COAM.Teardown Admin

Gnb Admin Reset
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.Reset
    COAM.Teardown Admin

Update Software With Admin On Jenkins
    [Arguments]    ${gnb_load}
    Log To Console    Target load file: ${gnb_load}
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.update_software    ${gnb_load}    timeout=3600
    sleep                   60
    [Teardown]    COAM.Teardown Admin

Check Gnb Status
    ${bts_status}=    Get GNB Status From COAM
    Log To Console    bts_status:${bts_status}
    run keyword if    '${bts_status}' != 'Configured'  fail
    ...                gnb upgraded failed, gnb status not Configured ,pls check!!!

Check Gnb Version
    [Arguments]    ${gnb_load_ver}
    Log To Console     Target load file: ${gnb_load_ver}
    Get Software Version
    Log To Console        SOFTWARE_INFO:${SOFTWARE_INFO}
    Log To Console        SW_VERSION_TOTAL:${SW_VERSION_TOTAL}
    Log To Console        ENB_BUILD:${ENB_BUILD}
    run keyword if    '${gnb_load_ver}' != '${SW_VERSION_TOTAL}'  fail
    ...                gnb upgraded failed, gnb version not match target version, Fail ,pls check!!!
