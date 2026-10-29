*** Settings ***
Documentation
...   Keywords used for 5GC000955-B feature
...
...   author: kasper.biegun@nokia.com
...   maintainer: kasper.biegun@nokia.com

Resource    resources_5GC000955-A-a.robot
Resource    override_keywords.robot
Resource    robot_utilities.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Library     taf.gnb.oam.coam.admin
Library     ${CURDIR}/keywords.py
Library     ${CURDIR}/create_lane.py   WITH NAME   create_lane
Library     ${CURDIR}/modify_json_files.py   WITH NAME   modify_json_files

*** Variables ***
${lterel_link}   https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build
${artifactory_link}=    https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/

*** Keywords ***
Prepare environment
    Setup keywords override for 5GC000955-B
    modify_json_files.modify_json_files    mrbts_value=${mrbts_value}
    ...                                    sfp_connector=${sfp_connector}
    ...                                    qsfp_connector=${qsfp_connector}
    ...                                    sfp2_connector=${sfp2_connector}
    Update Selenium Library
    taf.gnb.oam.coam.admin.Setup Admin
    Download and uznip Admin CLI
    Transfer ADMIN_CLI scripts
    Check Branch or Trunk

Prepare lane
    [Arguments]   ${lane_type}
    create_lane.create_lane     lane_type=${lane_type}
    ...                         sfp_create_keyword=Create SFP-LANE Objects
    ...                         qsfp_create_keyword=Create QSFP-LANE Objects
    ...                         sfp2_create_keyword=Create SFP2-LANE Objects

Teardown environment
    taf.gnb.oam.coam.admin.Teardown Admin

Check Branch or Trunk
    ${sw_version}=  gnbbbu.get_bts_sw_version
    @{sw_version}=  Split String  ${sw_version}  separator=\_
    ${branch}=  Set Variable  @{sw_version}[0]
    Set Global Variable  ${branch}

Get SW version for admin cli
    ${sw_ver}=    gnbbbu.get_bts_sw_version   bts_id=${0}   du_id=${0}
    ${sw_ver}=    format_sw_version_for_admin_cli    ${sw_ver}
    Log to console   Current sw version: ${sw_ver}
    [Return]   ${sw_ver}

Download and uznip Admin CLI
    [Documentation]    Kw download AdminCLI zip file
    ${SW_Version}         taf.gnb.oam.coam.admin.get_sw_version
    ${is_CommonBuild}=    Run keyword and return status    Should Contain      ${SW_Version}       SBTS
    ${is_TrunkBuild}=     Run keyword and return status    Should Contain      ${SW_Version}      _9999_
    Set Global Variable    ${is_CommonBuild}
    Set Global Variable    ${is_TrunkBuild}
    ${Downloaded_file}=   Run keyword if
    ...           ${is_CommonBuild}==True        Get And Unpack SBTS Build Admin CLI   ${is_Trunk_Build}
    ...  ELSE IF
    ...           ${is_CommonBuild}==False and ${is_Trunk_Build}==False    Get And Unpack 5G Build Admin CLI
    ...  ELSE
    ...           Fail    Keyword not support BTS SW version
    Run    unzip -o /tmp/${Downloaded_file} -d ~/ADMIN_CLI

Get And Unpack SBTS Build Admin CLI
    [Arguments]    ${is_Trunk_Build}
    ${SW_Version}      taf.gnb.oam.coam.admin.get_sw_version
    ${build_ver}=     Run keyword if
    ...           ${is_Trunk_Build}==True        Replace String Using Regexp    ${SW_Version}    ^SBTS[A-Za-z0-9]+_    SBTS00_
    ...  ELSE     Set variable   ${SW_Version}
    ${release}        Fetch from left   ${build_ver}  _ENB_
    ${fileExists}      check_if_file_exists   /tmp/${build_ver}_ADMIN_CLI.zip
    Run Keyword If     ${fileExists} is False   Run  wget ${lterel_link}/${release}/${build_ver}_ADMIN_CLI.zip -nv -P /tmp
    ${fileExists}      check_if_file_exists   /tmp/${build_ver}_ADMIN_CLI.zip
    Should Be Equal As Strings  ${fileExists}  True
    [Return]           ${build_ver}_ADMIN_CLI.zip

Get And Unpack 5G Build Admin CLI
    ${SW_Version}=     Get SW version for admin cli
    Run    rm /tmp/index.html*
    Run    wget ${artifactory_link}${SW_Version}/ -P /tmp/
    ${file}    Run	grep -oP '".*ADMIN_CLI.zip"' /tmp/index.html | tr -d '"'
    ${fileExists}      check_if_file_exists   /tmp/${file}
    Run Keyword If     ${fileExists} is False   Run  wget ${artifactory_link}${SW_Version}/${file} -nv -P /tmp
    ${fileExists}      check_if_file_exists   /tmp/${file}
    Should Be Equal As Strings  ${fileExists}  True
    [Return]           ${file}

Reset Abil
    reset_unit    dist_name=MRBTS-${mrbts_value}/EQM-1/APEQM-1/CABINET-1/BBMOD-1    reset_type=Warm    force_radio_reset=True
    ...    timeout=300
