*** Settings ***
Documentation
...   Keywords for testing TC30 of a CB007043 feature
...   author: Aleksander Gospodarczyk
...   contact: aleksander.gospodarczyk@nokia.com



Library      OperatingSystem
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Library      testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CB007043/resources/keywords.py
Library      on_air_tl_preparation.testline_preparation              WITH NAME     tl_prep
Resource     taf/rfrl/bts/robot/gnb.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CB007043/resources/parameters.py



*** Variables ***
${target_dir}           /home/ute/Downloads
${22R4_dir}             /home/ute/Downloads
${sw_build}             SBTS22R4_ENB_0000_001442_000000
${pubs_user}            pubs
${pubs_password}        pubs123
${scf}                  CB007043_main_gnb
${ftp}                  ftp://10.83.200.250/LOADS/SBTS22R4_ENB_0000_001442_000000_release_BTSSM_downloadable_A54.zip
@{CUSTOM_ALLOWED_ALARMS}    GPS receiver alarm: firmware upgrade ongoing
...                         No X2 link available
...                         No X2 link available for a specific LTEENB
...                         ToP reference missing



*** Keywords ***
Test Suite Setup
    Set Suite Variable      ${sw_version}    ${ENB_BUILD}
    tl_prep.Power On All Pdu Ports
    Log to console   \n--- Downloading source build and waiting for onAir ---\n
    Download source build
    Log to console   \n--- Preparing TestLine for testing ---\n
    Upgrade and Commission Gnb   builds_dir=${target_dir}  sw_build=${sw_build}  prefix_tag=${scf}
    Wait until keyword succeeds      1200 sec    30 sec     gnbcell.Verify All Cells Are Onair
    Log to console   \n--- TestLine has been successfully prepared ---\n
    Common Suite Setup


Perform SW Upgrade
    Log to console      \n--- Downloading a target software... ---\n
    ${sw_package_dir}  Download SW package     ${sw_version}   ${target_dir}
    Log to console          \n--- Updating software on BTS... ---\n
    Update gNB software     ${sw_package_dir}    timeout=1800
    Log to console     \n--- Waiting For onAir... --- \n
    Sleep     400s
    gnbbbu.connect    bts_id=${0}  du_id=${0}  force=${True}
    Wait Until Keyword Succeeds     1200 sec     30 sec   Verify gNB is onAir
    Wait Until Keyword Succeeds     1200 sec     30 sec   gnbcell.Verify All Cells Are Onair


Download source build
    Log to console      \nDownloading SBTS22R4...\n
    Run     wget -P ${22R4_dir} --ftp-user=${pubs_user} --ftp-password=${pubs_password} ${ftp}


Test Suite Teardown
    Sleep     400s
    Perform Delta Commissioning On gNB    delta=${missing_parameters}
    Wait Until Keyword Succeeds     1200 sec     30 sec   gnbcell.Verify All Cells Are Onair
    Common Suite Teardown

