*** Settings ***
Documentation     author: shasha liu
...               Group: HGZ_SG5
...               contact: shasha.liu@nokia-sbell.com

*** Keywords ***
### part-1: 5GC000470_N_5GC001541 ###
General_SiSo_Cell_lock_and_unlock_under_creation
    Connect to gnb coam via ssl
    Perform cell lock via rest api
    #Du login page via webUI
    #Perform Cell Lock
    #Wait Until Keyword Succeeds    5min    30s    Cell Should Be Locked
    #Perform Cell Unlock
    #Wait Until Keyword Succeeds    5min    30s    Cell Should Be Unlocked
    #Wait Until Keyword Succeeds    10min    10s     Du Check cell on air via WebUI

General_SiSo_RU_block_unblock
    Du login page via webUI
    Perform RU Lock
    Wait Until Keyword Succeeds    5min    30s    RU Should Be Locked
    Perform RU Unlock
    Wait Until Keyword Succeeds    5min    30s    RU Should Be Unlocked
    Wait Until Keyword Succeeds    10min    10s     Du Check cell on air via WebUI

### part-3: 5GC001178-A-5GC001082-A ###
Step1: Login WebUI
    log to console    Step1:Login WebUI
    Wait Until Keyword Succeeds    10min    10s    WEBUI Login

Step2: Upgrade site without active
    log to console    Step2:Upgrade site without active
    ${package_full_link}    Get link For Download from external value    version_type=Active
    ${upgrade_package_abs_path}    Download SW Build to VM      package_full_link=${package_full_link}
    set suite variable    ${upgrade_package_abs_path}
    Download package to site       if_active=${FALSE}      upgrade_package_path=${upgrade_package_abs_path}

Step3: Cancel during software update progress
    log to console    Step3:Cancel during software update progress
    #wait until keyword succeeds    15min    1min    Check if SW download start
    sleep    2min
    wait until keyword succeeds    5min    10s    selenium_coam.cancel_software_update
    wait until keyword succeeds    3min    10s    Check the planned SW version

Step4: Logout webui
    log to console    Step4:logout webui
    Run Keyword And Ignore Error    WEBUI Logout

Check the planned SW version
    ${version}    selenium_coam.check_current_software_version
    ${result}    should match regexp    ${version}[Planned]     ${empty}
    sleep    5s

Check if SW download start
    ${result}    selenium_coam.check_software_update_progress
    log    ${result}
    should not be equal    ${result}[percentage]    0%

Deactivate NR Supercell
    log to console    Deactivate NR Supercell
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell    abbr=actSuperCell    new_value=false
    sleep    1s
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3    timeout=15
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    abbr=numberOfTransmittedSsBlocks    new_value=1 beam
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of paging frames in a DRX cycle    abbr=numOfPagingFrames    new_value=halfT
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
        ...    filter_param=First PDCCH monitoring occasion of paging occasion     abbr=fPdcchMonOccsnPo
        ...    new_value=${2}
        ...    node_index=${0}
    Activate Parameters
    [Teardown]    Selenium Logout And Close Browser

Activate NR Supercell
    log to console    Activate NR Supercell
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell    abbr=actSuperCell    new_value=true
    sleep    1s
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
        ...    id_value=${2}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    object_class_name=CHANNELGROUP    plan_to_copy_from=CURRENT_BTS_CONF-1
        ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1
        ...    id_value=${3}    timeout=15
    sleep    1s
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
    ...    filter_param=Number of transmitted Synchronization Signal Blocks    abbr=numberOfTransmittedSsBlocks    new_value=3 beams
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Number of paging frames in a DRX cycle    abbr=numOfPagingFrames    new_value=quaterT
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-1
        ...    filter_param=First PDCCH monitoring occasion of paging occasion     abbr=fPdcchMonOccsnPo
        ...    new_value=${0}
        ...    node_index=${0}
    Activate Parameters
    [Teardown]    Selenium Logout And Close Browser
