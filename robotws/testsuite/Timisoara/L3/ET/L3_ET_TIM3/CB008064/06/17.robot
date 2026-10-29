*** Settings ***
Force Tags    CLOUD_5G_I_LOO_AP_LOOO    CONFIGURED    RAN_5G_TDD    RAN_5G    PY39
...           CRT    SBTS00    NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :contact: cristinel.sava@nokia.com

Resource    ../CB008064_Keywords.robot
Resource    ../CaseResource/CB008064_17.robot
Resource    Resource/PCMD.robot
Resource    Resource/ERR_WRN_Check.robot
Library     DateTime
Library     taf.sbts.oam.coam.admin    WITH NAME    admin_cli
#Resource    testsuite/Timisoara/L3/ET/L3_ET_TIM3/CB008064/06/Resource/pm_logs_frame_17.robot
Resource    Resource/pm_logs_frame_17.robot
Resource    ../../resources/admin.robot
Resource    ../06/Resource/admin6064.robot

Suite Setup    Run Keywords    sleep    1s
#...            AND             Setup WTS Esim Environment
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...            AND             Log to console    1 Get Scfc File
...            AND             Get VM Password
...            AND             Log to console    2 Get VM Password
...            AND             Get VM IP
...            AND             Log to console    3 Get VM IP
...            AND             Start Vm Ethernet Interfaces
...            AND             Log to console    4 Start Vm Ethernet Interfaces
...            AND             Log to console    5 Start UTF
...            AND             Run  utf_lab-controller start
#...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=delta_json_delete_TCE.json
...            AND             Run Keyword And Ignore Error    Wait Until Keyword Succeeds    120s    30s
                               ...    Find Scfc And Send Delta Commissioning    scfc_filename=delta_json_delete_TCE.json
...            AND             Log to console    8 Delta Commissioning Removed pcmd objects
...  AND  Wait until keyword succeeds  300  30  Find Scfc And Send Delta Commissioning  scfc_filename=add_2xTCE.json
...            AND             Log to console    7 Delta Commissioning ADD TCE objects
...            AND             Get Scfc File    output_filepath=${OUTPUT_DIR}/scfc_after_delta.xml
...            AND             Log to console    8 Get Scfc File scfc_after_delta.xml
...            AND             Reach Onair without confirmation   lua_cfg=${CURDIR}/config/basic.cfg
...            AND             sleep    20s
...            AND             Execute Egate Command    cmd=enb_x2_link_up enb=1 target=2
...            AND             Log to console    9 Site UP
...            AND             ERR_WRN_Check.Start BTSlogs Collection In Log Server
...            AND             Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server


Suite Teardown    Run Keywords    Stop Vm Ethernet Interfaces
...               AND             Send Full Commissioning    input_filepath=${OUTPUT_DIR}/initial_commissioning.xml
...               AND             log to console    Wait until AirPhone is ready to gather logs
...               AND             Sleep    200s
...               AND             Stop Default Processes And Gather Logs And Compress Logs



Test Teardown    Run  docker stop $(docker ps -a -q)


*** Test Cases ***
CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed
    [Documentation]   Author: cristinel.sava@nokia.com
    [Timeout]  1h
#    [Setup]   Case Setup: D_14
    CB008064_17_ASIL_check_Alarm_when_TCE_Connect_failed

    [Teardown]   Common Test Teardown L3

    sleep    1s
