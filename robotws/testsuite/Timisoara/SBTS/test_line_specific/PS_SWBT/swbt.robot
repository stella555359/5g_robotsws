*** Settings ***
Documentation  SWBT suite to be used daily by PS team.

Resource    ../../PS/resources/common.robot
Resource    ../../PS/resources/alarms.robot
Resource    ../../PS/resources/ald.robot
Resource    ../../PS/resources/power_saving.robot
Resource    ../../PS/resources/L3_call.robot


Suite Setup  Download target software


*** Variables ***
${SW_UPDATE_TIMEOUT}    2000
${TARGET_SW_PATH}       /home/ute/swbt
${software_version}       ${ENB_BUILD}
${download_location}      ${TARGET_SW_PATH}\


*** Test Cases ***
SWBT Upgrade
    [Setup]  common.Common Test Setup
    [Teardown]  common.Common Test Teardown
    Upgrade Test


SWBT Site Reset
    [Setup]  common.Common Test Setup
    [Teardown]  common.Common Test Teardown
    Site Reset Test


*** Keywords ***
Download target software
    Download And Check Software Package  ${ENB_BUILD}  ${TARGET_SW_PATH}

Download And Check Software Package
    [Documentation]  This keyword is used to download and check software package.
    [Arguments]  ${software_version}  ${download_location}  ${type}=A54

    ${sw_package}  ${page}  Create Artifactory Links  ${software_version}  ${type}
    ${sw_package_path_on_server}  Catenate  SEPARATOR=  https://artifactory-espoo2.int.net.nokia.com/artifactory/
    ...  mn-cosi-sran-central-public-local/build/${page}/
    ...  ${software_version}/${sw_package}
    ${wget_rc}  Run And Return Rc  wget ${sw_package_path_on_server} -P ${download_location}
    IF  '${wget_rc}' == '0'  RETURN
    ${release_name}  Fetch From Left  ${software_version}  _
    ${sw_package_path_on_server}  Catenate  SEPARATOR=  https://es-si-s3-z2.eecloud.nsn-net.net/lterel/build/  ${release_name}/${sw_package}
    ${wget_rc}  Run And Return Rc  wget ${sw_package_path_on_server} -P ${download_location}
    IF  '${wget_rc}' != '0'
      Fatal Error  ${software_version} was not downloaded in ${download_location}.
    END

Create Artifactory Links
    [Arguments]  ${software_version}  ${type}=A54
    IF  'FDSW' in '${software_version}'
      ${type}  Set Variable  ${EMPTY}
      ${page}  Get Regexp Matches  ${software_version}  FDSW\\d{2}.*_[A-Z]{4}
      ${page}  Set Variable  ${page}[0]
    ELSE
      ${type}  Set Variable  _${type}
      ${release_name}  Fetch From Left  ${software_version}  _
      ${is_fsm3}  Set Variable If  'FSM3' in '${software_version}'  _FSM3  ${EMPTY}
      ${page}  Set Variable  ${release_name}${is_fsm3}
    END
    ${sw_package}  Set Variable  ${software_version}_release_BTSSM_downloadable${type}.zip
    RETURN  ${sw_package}  ${page}


Upgrade Test
    Perform Upgrade


Site Reset Test
    SBTS Site Reset


Perform Upgrade
    Log  Starting SWR.  console=true
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Update Software  ${TARGET_SW_PATH}/${ENB_BUILD}_release_BTSSM_downloadable_A54.zip  True  ${SW_UPDATE_TIMEOUT}
    Log  Checking cells after SWR.  console=true
    Sleep  240s
    Setup Admin
    Check If NLWG Cells Are OnAir
    Sleep  120s
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  SWR Completed.  console=true


SBTS Site Reset
    Log  Starting Site Reset.  console=true
    Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Reset Site  timeout=600
    Log  Checking cells after site reset.  console=true
    Check If NLWG Cells Are OnAir
    Sleep  120s
    Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
    Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
    Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    Log  Site Reset Completed.  console=true