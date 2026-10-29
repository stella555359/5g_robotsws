*** Settings ***
Documentation
...    usage1(newest trunk build): mybot -v gnb_v:SBTS00_ENB update_gnb.robot
...    usage2(newest branch build): mybot -v gnb_v:SBTS22R4_ENB update_gnb.robot
...    usage3(official build): mybot -v gnb_v:SBTS00_ENB_9999_220412_000005 update_gnb.robot
...    usage4(official build): mybot -v gnb_v:SBTS23R2_ENB_0000_001195_000000 update_gnb.robot
...    usage5(knife build): mybot -v gnb_v:SBTS00_ENB_9999_220412_793542 update_gnb.robot
...    usage6(knife build): mybot -v gnb_v:SBTS00_ENB_9990_230718_000007 update_gnb.robot
...    knife url:
...    https://knife-results.es-si-s3-z2.eecloud.nsn-net.net/793542/SBTS00_ENB_9999_220412_793542_release_BTSSM_downloadable_A54.zip
...    https://es-si-s3-z2.eecloud.nsn-net.net/knife-results/979879/SBTS00_ENB_9999_230420_979879_release_BTSSM_downloadable_A54.zip
...    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/SBTSCD00/SBTS00_ENB_9990_230718_000007/
...    SBTS00_ENB_9990_230718_000007_release_BTSSM_downloadable_A54.zip

...    official build url:
...    https://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/SBTS00/SBTS00_ENB_9999_220412_000005_release_BTSSM_downloadable_A54.zip
Resource         ./../common_setup_teardown.robot
*** Variables ***
${gnb_v}    SBTS00_ENB
#${gnb_v}    SBTS00_ENB_9999_220412_000005    #official
#${gnb_v}    SBTS23R2_ENB_0000_001195_000000    #official
#${gnb_v}    SBTS00_ENB_9999_220412_793542    #knife
#${gnb_v}    SBTS00_ENB_9999_230722_1027723    #knife
#${gnb_v}    SBTS00_ENB_9990_230718_000007    #knife
${package_dir}    /home/ute/output/builds/
${cmd}
*** Test Cases ***
Test Case Update Gnb
    Remove Package
    ${package_type}    ${gnb_build}=    Is Package Offical Or Knife    ${gnb_v}
#    Run Keyword If    "${package_type}"=="offical"    Download Gnb Offical Package    ${gnb_build}
#    ...    ELSE IF    "${package_type}"=="CDRT_knife"    Download Gnb CDRT Knife Package    ${gnb_build}
#    ...    ELSE    Download Gnb Knife    ${gnb_build}
#    Update Software With Admin
    Run Keyword If    "${package_type}"=="offical"    Download And Update Ttitrace Package    ${gnb_build}

*** Keywords ***
Remove Package
    Run    rm -rf ${package_dir}*

Get Latest Package
    [Arguments]    ${gnb_build}
    ${cmd}=    Catenate    SEPARATOR=    curl http://files.ute.nsn-rdnet.net/builds/enb/base/|grep ${gnb_build}
    ...    |sort -r|sed -n '1p'|grep -Eo 'SBTS00_ENB_[[:digit:]]{4}_[[:digit:]]{6}_[[:digit:]]{6}'|awk 'NR==1'
    ${gnb_v}=    Run    ${cmd}
    [Return]    ${gnb_v}

Is Package Offical Or Knife
     [Arguments]    ${gnb_build}
     [Documentation]
     ...    ${gnb_v}    SBTS00_ENB_9999_220412_000005    #official
     ...    ${gnb_v}    SBTS23R2_ENB_0000_001195_000000    #official
     ...    ${gnb_v}    SBTS00_ENB_9999_220412_793542    #knife
     ...    ${gnb_v}    SBTS00_ENB_9990_230718_000007    #knife
    ${str_length}=    Get Length    ${gnb_build}
    ${gnb_build}=    Run Keyword If    ${str_length}<20    Get Latest Package    ${gnb_build}
    ...    ELSE    Set Variable    ${gnb_build}
    Get Latest Package    ${gnb_build}
    Log To Console    \ndownloaded gnb_bulid is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${postfix0}=    Set Variable    ${v1[0]}
    ${postfix1}=    Set Variable    ${v1[2]}
    ${postfix2}=    Get Substring    ${v1[-1]}    0    4
    ${knife_flag1}=    Evaluate    "${postfix0}"=="SBTS00" and "${postfix1}"=="9990"
    ${knife_flag2}=    Evaluate    "${postfix0}"=="SBTS00" and "${postfix1}"=="9999" and "${postfix2}"!="0000"
    ${offical_flag}=    Evaluate    "${postfix0}"=="SBTS00" and "${postfix1}"=="9999" and "${postfix2}"=="0000"
    ${package_type}=    set variable if    "${knife_flag1}"=="${True}"    CDRT_knife
    ...    "${knife_flag2}"=="${True}"    knife
    ...    "${offical_flag}"=="${True}"    offical
    Log To Console    \ndownloaded package type is:${package_type}
    [Return]    ${package_type}    ${gnb_build}

Download Gnb Knife
    [Arguments]    ${gnb_build}
    Log To Console    installing gnb build version is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${postfix}=    set variable    ${v1[-1]}
    ${cmd}=    catenate    aria2c -j 16 -x 16 -s 16
    ...    https://es-si-s3-z2.eecloud.nsn-net.net/knife-results/${postfix}/${gnb_build}_release_BTSSM_downloadable_A54.zip
    ...    -d ${package_dir}
    Log To Console    ${cmd}
    ${rc}    ${output}=    Run And Return Rc And Output    ${cmd}
    Log To Console    ${output}

Download Gnb Offical Package
    [Arguments]    ${gnb_build}
    Log To Console    installing gnb build version is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${branch}=    set variable    ${v1[0]}
    ${WFT_link}=    set variable    ${PACKAGE_FTP_URL_WFT_SBTS}
    ${package_link}=    set variable    ${WFT_link}/${branch}/${gnb_build}/
    #package
    ${cmd}=    catenate    aria2c -j 16 -x 16 -s 16 ${package_link}/${gnb_build}_release_BTSSM_downloadable_A54.zip
    ...    -d ${package_dir}
    Log To Console    ${cmd}
    ${rc}    ${output}=    Run And Return Rc And Output    ${cmd}
    Log To Console    ${output}

Download And Update Ttitrace Package
    [Arguments]    ${gnb_build}
    Log To Console    installing gnb build version is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${branch}=    set variable    ${v1[0]}
    ${WFT_link}=    set variable    ${PACKAGE_FTP_URL_WFT_SBTS}
    ${package_link}=    set variable    ${WFT_link}/${branch}/${gnb_build}/
    #ttitrace
    Run    mkdir -p ${package_dir}
    ${dec_file}=    set variable    ${gnb_build}_tti-dec.deb
    ${dissectors_file}=    set variable    ${gnb_build}_tti-dissectors.zip
    ${cmd}=    Catenate    wget ${package_link}/${dec_file} ${package_link}/${dissectors_file}
    ...    -P ${package_dir}
    Log To Console    ${cmd}
    ${rc}    ${output}=    Run And Return Rc And Output    ${cmd}
    Log To Console    ${output}
    Run    sudo dpkg -i /home/ute/output/builds/${dec_file}
    Run    sudo rm -rf /opt/tti_dissectors && sudo mkdir -p /opt/tti_dissectors && sudo chown ute /opt/tti_dissectors
    Run    unzip -q -o -d /opt/tti_dissectors /home/ute/output/builds/${dissectors_file}
    Run    chmod +x /opt/tti-dec/tti-dec-bin/bin/eventDecoder

Download Gnb CDRT Knife Package
    [Arguments]    ${gnb_build}
    Log To Console    installing gnb build version is:${gnb_build}
    @{v1}=    split string    ${gnb_build}    _
    ${branch}=    set variable    ${v1[0]}
    ${prefix1}=    Get Substring    ${branch}    0    4
    ${postfix1}=    Get Substring    ${branch}    4
    ${WFT_link}=    set variable    ${PACKAGE_FTP_URL_WFT_SBTS}
    ${cmd}=    catenate    aria2c -j 16 -x 16 -s 16
    ...    ${WFT_link}/${prefix1}CD${postfix1}/${gnb_build}/${gnb_build}_release_BTSSM_downloadable_A54.zip
    ...    -d ${package_dir}
    Log To Console    ${cmd}
    ${rc}    ${output}=    Run And Return Rc And Output    ${cmd}
    Log To Console    ${output}

Update Software With Admin
    ${ret}=    Run    ls -rt ${package_dir}/SBTS*release_BTSSM_downloadable_A54.zip
    Log To Console    downloaded file: ${ret}
    Log To Console    start to update gnb...
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.update_software    ${ret}    timeout=1800
    COAM.Teardown Admin

Gnb Admin Reset
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.Reset
    COAM.Teardown Admin

