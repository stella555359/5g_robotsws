*** Settings ***
Documentation     author: Zhang Xuewen
...               Group: HGZ_SG5
...               contact: xuewen.zhang@nokia-sbell.com

Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ../../CB008997/resource/CB008997_Common_KW.robot


*** Variables ***
${asik_connection}    ASIK Master
${connection}         GNB_OAM

*** Keywords ***
Reconfigure 16DL cell to 8DL cell with 4Rx IRC receiver
    log to console   \nReconfigure Cell1 from 16DL to 8DL cell with 4Rx IRC receiver
    set test variable    ${faultId}    ${7312}
    add fault to the allowed fault list   faultId=${faultId}
    Change Cell from 16DL to 8DL   cell_index=1
    Sleep   5min
    Wait until keyword succeeds    5 min    30 sec    Connect to gnb coam via ssl
#    Wait until keyword succeeds     20min   20s   COAM Check GNB cell on air
    Wait until keyword succeeds    20 min    20 sec   Check all cells info should be onair
#    Wait For Expect Fault To Disappear  faultId=${faultId}   timeout=180
#    COAM Wait gnb And Cells ready    timeout=30 min    gnb_type='${gNb_CuType}'
    run keyword and ignore error    COAM Teardown gnb connections
    [Teardown]  CleanFirefox

Change Cell from 16DL to 8DL
    [Arguments]    ${cell_index}=1
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    set test variable   ${stream}   ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_index}
    ...    filter_param=NR Cell type
    ...    abbr=nrCellType
    ...    new_value=8DL8UL    node_index=${0}
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-3
    ...   timeout=60
    selenium_coam.remove_object    object_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_index}/CHANNELGROUP-4
    ...   timeout=60
    selenium_coam.validate_plan
    ${status}    Run Keyword And Return Status    selenium_coam.activate_plan
    Run keyword if  '${status}'!='True'  log to console  \nActivate plan rc is '${status}', can be ignored if cells onair in next step
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
