*** Settings ***
Documentation
...    Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...    Maintainer: sergiu.alecu@nokia.com
...    Test Description: The purpose of the test is to verify support common fault management flow mechanism to report
...    faults from SW and HW component of cOAM BTS
...    Group in charge: I_MN_5GSC_PZ_5G_IV7_WRO_5_GMS
...    Review: piotr.zukrowski@nokia.com, damian.muszynski@nokia.com, sylwia.swiatkiewicz@nokia.com

Resource    ../../../SyVe_Left_Shift/resources/admin.robot
Resource    ../../../SyVe_Left_Shift/resources/pretest_posttest.robot
Resource    ../../../SyVe_Left_Shift/resources/system.robot
Resource    ../../../SyVe_Left_Shift/resources/selenium.robot
#Resource    ../../resources/pdu.robot
Resource    ../../../SyVe_Left_Shift/resources/fault_trigger.robot
Library     String
Library     taf.transport.ssh    WITH NAME    trs_ssh


*** Variables ***
@{ALLOWED_ALARMS}=
...                                61524
...                                61649
...                                61652
...                                61074
...                                4527
...                                6450
...                                9000
${fault_id_NoConnectionToUnit}     10
${fault_id_SwPackage}              28
${fault_id_PpsRefMiss}             1898
${fault_id_FrDangerouslyOverheat}  1937
${fault_id_GPSSystemElement}       4011
${fault_id_Toggling}               4026
${fault_id_FanBroken}              4078
${fault_id_VirtualNodeNotResponding}    4383
@{summer}=
...                                04
...                                05
...                                06
...                                07
...                                08
...                                09
...                                10
${FAULT_NUMBER}                    0028
${NUMBER_OF_RETESTS}               500
${RESET_COM}  export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/MIT_reset_5G.py --i 192.168.255.1 -n 0x1011 -b 0x10 -c 0x11 -s 1 -e 6
...           -p 15004
${ALARMING_OBJECT_BBMOD}           /EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${ALARMING_OBJECT_RMOD}            /EQM_R-1/APEQM_R-1/RMOD_R-1
${ALARMING_OBJECT_SMOD}            /EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
${CONFIG_OBJECT_APEQM}             /EQM-1/APEQM-1
${CONFIG_OBJECT_BBMOD}             /EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${CONFIG_OBJECT_RMOD}              /EQM-1/APEQM-1/RMOD-1
${CONFIG_OBJECT_SMOD}              /EQM-1/APEQM-1/CABINET-1/SMOD-1
${CELL_OBJECT_AFFECTED_CELLS}      affected_cells:   :some
${CELL_OBJECT_DEGRADED_ALL}        Degraded: All
${CELL_OBJECT_FAULTY}              Faulty
${CELL_OBJECT_NONE}                None
${CLOCK_OBJECT_DIST_NAME}          /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/SYNC_CONF_M-1/CLOCK_CONF_M-1/CLOCK_R-1

${asik_addr}                     192.168.255.1
${asik_username}                 toor4nsn
${asik_password}                 oZPS0POrRieRtu

*** Keywords ***
5GC001525_SA_5_Fault_history_storage
    Wait Until Keyword Succeeds
    ...    600
    ...    5
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    FOR    ${index}    IN RANGE    ${NUMBER_OF_RETESTS}
        ADMIN Setup Admin
        Trigger Fault 28
        Cancel Fault 28
        ADMIN Teardown Admin
    END
    ADMIN Setup Admin
    ${numberOfFaults}    SYSTEM Execute Command On gNB
    ...    command=cat /tmp/RawAlarmHistory.txt | grep ${FAULT_NUMBER} | cut -f11
    Should Contain
    ...    container=${numberOfFaults}
    ...    item=${SPACE}${NUMBER_OF_RETESTS}\r

Force Specific Reset On GNB
    [Arguments]
    ...    ${timeout}=60 min
    [Timeout]    ${timeout}
    SYSTEM Execute Command On gNB
    ...    command=${RESET_COM}
    Wait Until Keyword Succeeds
    ...    120
    ...    10
    ...    SYSTEM Check If Host Is Not Pingable
    ...    host_ip_address=${ADMIN_BTS_HOST}
    Wait Until Keyword Succeeds
    ...    120
    ...    10
    ...    SYSTEM Check If Host Is Pingable
    ...    host_ip_address=${ADMIN_BTS_HOST}

Check If Fault Is In Black Box History
    [Arguments]    ${faultId}
#    ${status}    Run    sshpass -p ${ROOT_PASSWORD} ssh ${ROOT_USERNAME}@${LMP_IP} cat ${BLACKBOX_ALARMS_PATH}
    ${status}    SYSTEM Execute Command On gNB   command=cat ${BLACKBOX_ALARMS_PATH}
    Should Contain    item=${faultId}
    ...                   container=${status}

Check If Fault Is Not In Black Box History
    [Arguments]    ${faultId}
#    ${status}    Run    sshpass -p ${ROOT_PASSWORD} ssh ${ROOT_USERNAME}@${LMP_IP} cat ${BLACKBOX_ALARMS_PATH}
    ${status}    SYSTEM Execute Command On gNB   command=cat ${BLACKBOX_ALARMS_PATH}
    Should Not Contain    item=${faultId}
    ...                   container=${status}

Check If Alarm Historical Alarms Is Empty
    #[Arguments]
    #...    ${connection}=${ADMIN_ALIAS}
    ${out_alarms_objects_list}    ADMIN Get Historic Alarms
    ${alarms_objects_len}    Get Length
    ...    item=${out_alarms_objects_list}
    Set Test Variable    ${is_empty}    ${FALSE}
    Run Keyword If    ${alarms_objects_len} == ${0}
    ...    Set Test Variable    ${is_empty}    ${TRUE}
    Should Be True    ${is_empty}

Get Time Of Alarm In WebEM
    [Arguments]
    ...            ${fault_id}
    ${out_alarms_objects_list}    Get WebElements
    ...    locator=//td[@class="ng-binding ng-scope fault-name-cell"][2]
    ${alarms_objects_len}    Get Length
    ...    item=${out_alarms_objects_list}
    Set Test Variable    ${is_searched_fault}    ${0}
    FOR    ${alarm}    IN RANGE    ${alarms_objects_len}
        ${webem_fault_detail}    Get Text
    ...    locator=(//td[@class="ng-binding ng-scope fault-id-cell"][2])[${alarm+1}]
        ${webem_fault_time}    Get Text
    ...    locator=(//td[@class="ng-binding ng-scope time-cell"])[${alarm+1}]
        Run Keyword If    '${webem_fault_detail}' == '${fault_id}'
    ...    Set Test Variable    ${is_searched_fault_time}    ${webem_fault_time}
    END
    [Return]    ${is_searched_fault_time}

Get Alarm ID In WebEM
    [Arguments]
    ...            ${fault_id}
    ${out_alarms_objects_list}    Get WebElements
    ...    locator=//td[@class="ng-binding ng-scope fault-id-cell"][1]
    ${alarms_objects_len}    Get Length
    ...    item=${out_alarms_objects_list}
    Set Test Variable    ${is_searched_fault}    ${0}
    FOR    ${alarm}    IN RANGE    ${alarms_objects_len}
        ${webem_fault_detail}    Get Text
    ...    locator=(//td[@class="ng-binding ng-scope fault-name-cell"][2])[${alarm+1}]
        ${webem_fault_id}    Get Text
    ...    locator=(//td[@class="ng-binding ng-scope fault-id-cell"][1])[${alarm+1}]
        Run Keyword If    '${webem_fault_detail}' == '${fault_id}'
    ...    Set Test Variable    ${is_searched_fault}    ${webem_fault_id}
    END
    [Return]    ${is_searched_fault}

Time Zone Change
    [Arguments]
    ...    ${timezone}
    ${is_left}    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${OUT_ADMIN_SMOD_POSITION}
    ...    left
    ${time_zone_actual}    Run Keyword If    ${is_left}
    ...    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=/MRBTS-1/EQM-1/SMOD-4113/TIME-1
    ...    pattern=timeZone
    ...    ELSE
    ...    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=/MRBTS-1/EQM-1/SMOD-8209/TIME-1
    ...    pattern=timeZone

    ADMIN Perform Parameter Update
    ...    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/TIME-1
    ...    parameter=timeZone
    ...    value=${timezone}
    ...    timeout=600
    Wait Until Keyword Succeeds
    ...    900
    ...    5
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    ${time_zone_name}    Run Keyword If    ${is_left}
    ...    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=/MRBTS-1/EQM-1/SMOD-4113/TIME-1
    ...    pattern=timeZone
    ...    ELSE
    ...    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=/MRBTS-1/EQM-1/SMOD-8209/TIME-1
    ...    pattern=timeZone
    ${time_zone_name}    Get From Dictionary    ${time_zone_name}    timeZone
    ${time_zone_name}    Get From Dictionary    ${time_zone_name}    timeZoneName
    Should Contain
    ...    item=${time_zone_name}
    ...    container=${timezone}

Compare Times Of Alarms
    [Arguments]
    ...    ${first_time}
    ...    ${second_time}
    ${time_offset}    SYSTEM Get Local Timezone Time Offset
    ${first_time_plus_12}    Add Time To Date    date=${first_time}    time=12 hour
    ${first_time_to_compare}    Subtract Time From Date    date=${first_time_plus_12}    time=${time_offset} hour    result_format=%H
    ${second_time_hour}    Convert Date    ${second_time}    result_format=%H
    Should Be Equal   ${first_time_to_compare}    ${second_time_hour}

Ensure That gNB Will Have Time To Perform Reset Before Hour Change
    Wait Until Keyword Succeeds    11 min
    ...                            15 sec
    ...                            Wait for proper 10 Minutes Time

Wait for proper 10 Minutes Time
    SYSTEM Get Time From Various Time Sources
    ${list}    Create Last Ten Minutes List
    ${actualTime}    Get Current Date    result_format=%M
    List Should Not Contain Value    ${list}    ${actualTime}

Create Last Ten Minutes List
    ${listLen}     Set Variable    10
    ${list}        Create List     50
    FOR    ${index}    IN RANGE    0    ${listLen}-1
        ${time}    Add Time To Time    ${list[${index}]} minute    1 minute    result_format=timer    exclude_millis=false
        ${time}    Get Substring    ${time}    3    5
        ${time}    Convert To String    ${time}
        Append To List    ${list}    ${time}
    END
    [Return]    ${list}

Check How Many Times Fault Is In Alarms File
    [Arguments]
    ...    ${faultId}
    ...    ${date_csv}
    ...    ${occurrence}
    ...    ${alarmType}
    ${actual_date}    Run  date +%Y%m%d
    ${actual_date}    Remove String    ${actual_date}    \r\n
    Set New Date If Actual Time Is Not Equal To Admin Api Log Time
    ...    actual_date=${actual_date}
    OperatingSystem.Run
    ...    command=rm '/home/ute/Downloads/${OUT_ADMIN_BTS_NAME}_${alarmType}Alarms_${date_csv}.csv'
    Click Element
    ...    locator=//ui-button[@a-title="Save ${alarmType} alarms"]
    ${output}    Run    ls /home/ute/Downloads
    Wait Until Keyword Succeeds
    ...    30
    ...    1
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${alarmType}Alarms_${date_csv}.csv
    ...    fileDirectory=/home/ute/Downloads
    ${fault_exists}    OperatingSystem.Run
    ...    command=cat '/home/ute/Downloads/MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${alarmType}Alarms_${date_csv}.csv' | grep -c '"${faultId}"'
    ${fault_exists}    Convert To Integer
    ...    item=${fault_exists}
    Should Be Equal
    ...    first=${fault_exists}
    ...    second=${occurrence}

Check If MO Is In Proper Field
    Click Element
    ...    locator=//ui-button[@class='show-panel-button ng-scope ng-isolate-scope ui-tooltip-source']
    Click Element
    ...    locator=//td[@class="ng-binding ng-scope fault-name-cell" and text()='No connection to unit']
    Element Should Be Visible
    ...    locator=//tbody[1]//span[contains(text(),'alarm')]

Check If Object Contain Proper Text
    [Arguments]
    ...    ${locator}
    ...    ${expected_text}
    ${text_in_object}    Get Text
    ...    locator=${locator}
    Should Contain
    ...    item=${expected_text}
    ...    container=${text_in_object}

Check If RMOD State Is Failed
    SELENIUM Close Pop If Visible
    SELENIUM Go To Detailed Site View
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="RMOD-column"]//div[@class="site-widget-status"]/div[@class="site-widget-diode gray-diode"]
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="RMOD-column"]//div[@class="site-widget-status"]//span[@class="alarm-icon-container icon"]

Check If RMOD State Is Valid
    SELENIUM Go To Detailed Site View
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="RMOD-column"]//div[@class="site-widget-status"]/div[@class="site-widget-diode green-diode"]
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Not Be Visible
    ...    locator=//div[@class="RMOD-column"]//span[@class="alarm-icon-container icon" and @title="Critical Alarms"]

Check OnAir State Of Cell
    SELENIUM Go To Detailed Site View
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="site-widget-container cells-group-widget"]//div[contains(@class, "site-cell-status-diode green-diode")]
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[contains(@class, "site-cell-widget online-cell")]
    Click Element
    ...    locator=//div[@class="site-widget-container cells-group-widget"]
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][1]
    ...    expected_text=Enabled
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][2]
    ...    expected_text=Online
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][3]
    ...    expected_text=Unlocked
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][4]
    ...    expected_text=Active  #configured for 5G21A

Check Degraded State Of Cell
    [Documentation]
    ...    Highlighted Cells match degraded cells reported in the category alarms. Highlight is different for degraded and faulty cells.
    ...    HW view - cell is degraded / HW & Service Status view: yellow background + yellow dot
    ...    Operational state is Enabled / Availabiity state is Degraded / Administrative state is Unlocked / Procedural status is configured
    SELENIUM Go To Detailed Site View
    Click Element
    ...    locator=//div[@class="RMOD-column"]      #to click on something else than cell
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="site-widget-container cells-group-widget"]//div[contains(@class, "site-cell-status-diode yellow-diode")]
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="site-cell-widget degraded-cell"]
    Click Element
    ...    locator=//div[@class="site-widget-container cells-group-widget"]
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][1]
    ...    expected_text=Enabled
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][2]
    ...    expected_text=Degraded
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][3]
    ...    expected_text=Unlocked
    Check If Object Contain Proper Text
    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][4]
    ...    expected_text=configured

Check Failed State Of Cell
    SELENIUM Go To Detailed Site View
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="site-widget-container cells-group-widget"]//div[@class="site-cell-status-diode red-diode"]
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Element Should Be Visible
    ...    locator=//div[@class="site-cell-widget failed-cell"]
#    Click Element
#    ...    locator=//div[@class="site-widget-container cells-group-widget"]
#    Check If Object Contain Proper Text
#    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][1]
#    ...    expected_text=Disabled
#    Check If Object Contain Proper Text
#    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][2]
#    ...    expected_text=Failed
#    Check If Object Contain Proper Text
#    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][3]
#    ...    expected_text=Unlocked
#    Check If Object Contain Proper Text
#    ...    locator=//div[@ng-repeat="section in sections | orderBy:'order' track by $index"][4]//tr[@class="ng-scope"][4]
#    ...    expected_text=Idle  #not initialized for 5G21A

Trigger Fault 1898
    PDU Setup GPS Breaker
    PDU Action
    ...    device=gpsbreaker
    ...    action=off
    Wait Until Keyword Succeeds
    ...    1000
    ...    1
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=1898

Cancel Fault 1898
    PDU Setup GPS Breaker
    PDU Action
    ...    device=gpsbreaker
    ...    action=on
    Wait Until Keyword Succeeds
    ...    1000
    ...    10
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=1898

Trigger Fault 4078
    PDU Setup Fan Breaker
    PDU Action
    ...    device=fanbreaker
    ...    action=on
    Wait Until Keyword Succeeds
    ...    1000
    ...    10
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=4078

Cancel Fault 4078
    PDU Setup Fan Breaker
    PDU Action
    ...    device=fanbreaker
    ...    action=off
    Wait Until Keyword Succeeds
    ...    1000
    ...    10
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=4078

##############################################################################################
#############     Keywords for 5GC001525-SA after Left Shift     #############################
##############################################################################################

Trigger Fault 1937 AEQN
    PC Create Batch File - RMOD Fault 1937 Trigger - version 3
    ${RU_IP}=     Get RU IP from ASIK
    Connect Ssh To Asix
    Connect to RU via Asik   ${RU_IP}    root    w@=EIj7P6R0bVy85OjCVa^ho&8
    trs_ssh.upload_file  /tmp/batch_1      /tmp    connection=ru
    trs_ssh.upload_file  /tmp/batch_2p1    /tmp    connection=ru
    trs_ssh.upload_file  /tmp/batch_2p2    /tmp    connection=ru
    ${output}    trs_ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_1    connection=ru
    Log To Console    batch_1 \${output}=${output}
    ${output}    trs_ssh.execute    command=cat /var/tmp/tempest_inst3_default.json|grep tempOffset    connection=ru
        # `inst<number>` differ depending on RMOD
    Log To Console    cat \${output}=${output}
    ${output}    trs_ssh.execute
    ...    command=sed -i 's/"tempOffset": [0-9]*[.0]*,/"tempOffset": 65,/g' /var/tmp/tempest_inst3_default.json
    ...    connection=ru
    Log To Console    sed 0 --> 65 \${output}=${output}
    ${output}    trs_ssh.execute    command=cat /var/tmp/tempest_inst3_default.json|grep tempOffset    connection=ru
    Log To Console    cat \${output}=${output}
    ${output}    trs_ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_2p1    connection=ru
    Log To Console    batch_2p1 \${output}=${output}
    Sleep    1 sec
    ${output}    trs_ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_2p2    connection=ru
    Log To Console    batch_2p2 \${output}=${output}

    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix


Cancel Fault 1937 AEQN
    PC Create Batch File - RMOD Fault 1937 Canceller - version 3
     ${RU_IP}=     Get RU IP from ASIK
    Connect Ssh To Asix
    Connect to RU via Asik   ${RU_IP}    root    w@=EIj7P6R0bVy85OjCVa^ho&8
    trs_ssh.upload_file  /tmp/batch_1      /tmp    connection=ru
    trs_ssh.upload_file  /tmp/batch_3p1    /tmp    connection=ru
    trs_ssh.upload_file  /tmp/batch_3p2    /tmp    connection=ru
    ${output}    trs_ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_1    connection=ru
    Log To Console    batch_1 \${output}=${output}
    ${output}    trs_ssh.execute    command=cat /var/tmp/tempest_inst3_default.json|grep tempOffset    connection=ru
        # `inst<number>` differ depending on RMOD
    Log To Console    cat \${output}=${output}
    ${output}    trs_ssh.execute
    ...    command=sed -i 's/"tempOffset": 65.0,/"tempOffset": 0,/g' /var/tmp/tempest_inst3_default.json
    ...    connection=ru
    Log To Console    sed 65.0 --> 0 \${output}=${output}
    ${output}    trs_ssh.execute    command=cat /var/tmp/tempest_inst3_default.json|grep tempOffset    connection=ru
    Log To Console    cat \${output}=${output}
    ${output}    trs_ssh.execute
    ...    command=sed -i 's/"tempOffset": 65,/"tempOffset": 0,/g' /var/tmp/tempest_inst1_default.json
    ...    connection=ru
    Log To Console    sed 65 --> 0 \${output}=${output}
    ${output}    trs_ssh.execute    command=cat /var/tmp/tempest_inst3_default.json|grep tempOffset    connection=ru
    Log To Console    cat \${output}=${output}
    ${output}    trs_ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_3p1    connection=ru
    Log To Console    batch_3p1 \${output}=${output}
    Sleep    1 sec
    ${output}    trs_ssh.execute    command=frmonShellClient 127.0.0.1 2000 /tmp/batch_3p2    connection=ru
    Log To Console    batch_3p2 \${output}=${output}
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Trigger Fault 10 - Radio reset
    #PREPOST Setup Admin
    ${sw_version}=    ADMIN Get Sw Version
    ${split_build}=    Split string       ${sw_version}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    Connect to RU via Asik   ${RU_IP}
    Run Keyword If  '${version}' == 'SBTS22R1'   run keyword and ignore error  trs_ssh.execute   rfsw-reboot --soft   connection=ru  timeout=3
    ...    ELSE    run keyword and ignore error  trs_ssh.execute    sudo rfsw-reboot --soft    connection=ru  timeout=3
    [Teardown]  run_keywords    Disconnect from RU  AND
    ...                         Disconnect Ssh From Asix

Connect Ssh To Asix
    [Documentation]
    ...  Establish connection with ASIx via SSH
    trs_ssh.Connect To
    ...    hostname=${asik_addr}
    ...    username=${asik_username}
    ...    password=${asik_password}
    ...    alias=asik

Disconnect Ssh From Asix
    [Documentation]
    ...  Break connection with ASIx via SSH
    trs_ssh.Disconnect      connection=asik

Connect to RU via Asik
    [Arguments]   ${RU_IP}
    #PREPOST Setup Admin
    ${sw_version}=    ADMIN Get Sw Version
    ${split_build}=    Split string       ${sw_version}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Run Keyword If  '${version}' == 'SBTS22R4'   Connect to RU via Asik for Branch   ${RU_IP}
    ...   ELSE   Connect to RU via Asik for Trunk   ${RU_IP}

Connect to RU via Asik for Trunk
    [Arguments]   ${RU_IP}    ${username}=rfsw    ${password}=HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=
    ${container_connection}=    Check if connection through lxc is enabled
    ${proxy}=    set variable if   '${container_connection}'=='True'    fhnet_container     asik
    run keyword if     '${container_connection}'=='True'     Connect to FHNET contaier
    trs_ssh.Connect To
    ...                   hostname=${RU_IP}
    ...                   username=${username}
    ...                   password=${password}
    ...                   proxy=${proxy}
    ...                   alias=ru

Connect to RU via Asik for Branch
    [Arguments]   ${RU_IP}    ${username}=rfsw    ${password}=HfBKgqIOogKY3BlGtiniuCI9bs76C8jYsAY6vw8f/Tw=
    ${container_connection}=    Check if connection through lxc is enabled
    ${proxy}=    set variable if   '${container_connection}'=='True'    fhnet_container     asik
    run keyword if     '${container_connection}'=='True'     Connect to FHNET contaier
    trs_ssh.Connect To
    ...                   hostname=${RU_IP}
    ...                   username=${username}
    ...                   password=${password}
    ...                   proxy=${proxy}
    ...                   alias=ru

Disconnect from RU
    trs_ssh.Disconnect      connection=ru

Check if connection through lxc is enabled
    ${containers}=    trs_ssh.execute    lxc-ls     connection=asik
    ${status}=    run keyword and return status    should contain any    ${containers}    0x2018    0x1018
    [Return]    ${status}

Get RU IP from ASIK
    Connect Ssh To Asix
    ${FRIps}=     trs_ssh.execute   cat /rom/config/FRIps.txt    connection=asik
    ${RU_IP}=    Get Regexp Matches     ${FRIps}    ;[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+;
    ${RU_IP}=    get from list    ${RU_IP}    -1
    ${RU_IP}=    Remove String   ${RU_IP}    ;
    should not be empty  ${RU_IP}
    [Return]    ${RU_IP}

Check if RU is pingable
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 ${RU_IP}     connection=asik
    Should contain      ${output}   1 packets transmitted, 1 received
    [Teardown]  Disconnect Ssh From Asix

Check if Radio Unit is not pingable
    Connect Ssh To Asix
    ${RU_IP}=     Get RU IP from ASIK
    ${output}=         trs_ssh.Execute       ping -c 1 -W 10 ${RU_IP}     connection=asik
    Should contain      ${output}   1 packets transmitted, 0 received
    [Teardown]  Disconnect Ssh From Asix


Connect to FHNET contaier
    [Arguments]    ${fhnet_host_ip}=192.168.255.254
    ${containers}=    trs_ssh.execute    lxc-ls     connection=asik
    ${fhnet_container}=    get regexp matches     ${containers}     \0x[12]018
    trs_ssh.send command    rm -rf /tmp/sshd_debug.log    connection=asik
    trs_ssh.send command    lxc-attach -n ${fhnet_container[0]} -- /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    ...                     connection=asik
    trs_ssh.connect to    hostname=${fhnet_host_ip}
    ...                   username=toor4nsn
    ...                   password=oZPS0POrRieRtu
    ...                   alias=fhnet_container
    ...                   proxy=asik

Wait until fault 10 is visible
        wait until keyword succeeds  180  10  SELENIUM Check If Alarm Exists    fault_id=${fault_id_NoConnectionToUnit}

Wait until fault 10 is not visible
        wait until keyword succeeds  180  10  SELENIUM Check If Alarm Not Exists  fault_id=${fault_id_NoConnectionToUnit}

Trigger Fault 10 - PDU Turn Off All Rmods
    PDU Turn Off All Rmods With UTE Command
    ADMIN Assert Alarm Active    parameters=faultId=10
    ...                          timeout=300

Trigger Fault 10 - PDU Turn Off Rmod 1
    PDU Turn Off Rmod 1 With UTE Command
    ADMIN Assert Alarm Active    parameters=faultId=10
    ...                          timeout=300

Cancel Fault 10 - PDU Turn On All Rmods
    PDU Turn On All Rmods With UTE Command
    ADMIN Assert Alarm Inactive    parameters=faultId=10
    ...                            timeout=300

Check Alarm Parent Object
    #[Arguments]
    #...    ${fault_id}
    ${out_alarms_objects_list}    ADMIN Get Active Alarms
    ${alarms_objects_len}    Get Length
    ...    item=${out_alarms_objects_list}
    FOR    ${alarm}    IN RANGE    ${alarms_objects_len}
        ${dist_name}    Get From Dictionary    ${out_alarms_objects_list[${alarm}]}    distName
        ${parent_object}    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=${dist_name}
    ...    pattern=alarmingResourceDN
        Should Match Regexp
    ...    string=${parent_object["alarmingResourceDN"]}
    ...    pattern=/MRBTS-1/
    END

Check Alarms Filtering For No Selected Alarming Object
    [Documentation]    All filters are up, no selected alarming object: All alarms are visible
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652

Check Alarms Filtering For No Selected Configuration Object
    [Documentation]    All filters are up, no selected alarming object: All alarms are visible
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652

Check Alarms Filtering For BBMOD Alarming Object Selected
    [Documentation]    All filters are down, MRBTS-10191/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1 is selected:
    ...    (no alarm is visible)
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${ALARMING_OBJECT_BBMOD}
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652

Check Alarms Filtering For SMOD Alarming Object Selected
    [Documentation]    /EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1 is selected:
    ...   (61652 is visible, 10 is not visible)
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${ALARMING_OBJECT_SMOD}
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10

Check Alarms Filtering For RMOD Alarming Object Selected
    [Documentation]   /EQM_R-1/APEQM_R-1/RMOD_R-1 is selected:
    ...    (10 for RMOD is visible, 61652 is not visible)
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${ALARMING_OBJECT_RMOD}
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652

Check Alarms Filtering For BBMOD Configuration Object Selected
    [Documentation]    all filters are down - MRBTS-10191/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1 is selected:
    ...    ok (no alarm is visible)
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CONFIG_OBJECT_BBMOD}
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652

Check Alarms Filtering For SMOD Configuration Object Selected
    [Documentation]    /EQM-1/APEQM-1/CABINET-1/SMOD-1 is selected: (61652 is visible, 10 for RMOD is not visible)
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CONFIG_OBJECT_SMOD}
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10

Check Alarms Filtering For RMOD Configuration Object Selected
    [Documentation]    /EQM-1/APEQM-1/RMOD-1 is selected: (10 is visible, 61652 is not visible)
    ${current_RMOD}  Get Current RMOD
    log to console   ${current_RMOD}
    ${config_object_RMOD}    Remove String Using Regexp    ${current_RMOD}    MRBTS-[0-9]*
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${config_object_RMOD}
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652

Check Alarms Filtering For APEQM Configuration Object Selected
    [Documentation]    /EQM-1/APEQM-1/ is selected: (61652 and 10 are visible)
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CONFIG_OBJECT_APEQM}
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652

Check Alarms Filtering When All Severities Are Selected
    [Documentation]    all filters are up: (all alarms are visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652

Check Alarms Filtering When All Severities Are Unselected
    [Documentation]    all filters are down: (no alarm is visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Unselect Critical Severity In Active Alarms
    SELENIUM Unselect Major Severity In Active Alarms
    SELENIUM Unselect Minor Severity In Active Alarms
    SELENIUM Unselect Warning Severity In Active Alarms
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652

Check Alarms Filtering When Critical Severity Is Selected
    [Documentation]    (10 for RMOD is visible, 61652 is not visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Critical Severity In Active Alarms
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652
    SELENIUM Unselect Critical Severity In Active Alarms

Check Alarms Filtering When Major Severity Is Selected
    [Documentation]    (10 and 61652 are not visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Major Severity In Active Alarms
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652
    SELENIUM Unselect Major Severity In Active Alarms

Check Alarms Filtering When Minor Severity Is Selected
    [Documentation]    (61652 is visible, 10 is not visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Minor Severity In Active Alarms
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Unselect Minor Severity In Active Alarms

Check Alarms Filtering When Critical And Major Severity Is Selected
    [Documentation]    (10 is visible, 61652 is not visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Critical Severity In Active Alarms
    SELENIUM Select Major Severity In Active Alarms
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=61652
    SELENIUM Unselect Critical Severity In Active Alarms
    SELENIUM Unselect Major Severity In Active Alarms

Check Alarms Filtering When Critical And Minor Severity Is Selected
    [Documentation]    (10 and 61652 are visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Critical Severity In Active Alarms
    SELENIUM Select Minor Severity In Active Alarms
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652
    SELENIUM Unselect Critical Severity In Active Alarms
    SELENIUM Unselect Minor Severity In Active Alarms

Check Alarms Filtering When Major And Minor Severity Is Selected
    [Documentation]    (61652 is visible, 10 is not visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Major Severity In Active Alarms
    SELENIUM Select Minor Severity In Active Alarms
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Unselect Major Severity In Active Alarms
    SELENIUM Unselect Minor Severity In Active Alarms

Check Alarms Filtering When Critical Major And Minor Severity Is Selected
    [Documentation]    (10 and 61652 are visible)
    ...    10 is Critical / 61652 is Minor
    SELENIUM Select Critical Severity In Active Alarms
    SELENIUM Select Major Severity In Active Alarms
    SELENIUM Select Minor Severity In Active Alarms
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=61652
    SELENIUM Unselect Critical Severity In Active Alarms
    SELENIUM Unselect Major Severity In Active Alarms
    SELENIUM Unselect Minor Severity In Active Alarms

Check Alarms Filtering When No Cell Filtering Is Selected
    [Documentation]    all filters are up - no selected cell filter: ok (all alarms are visible)
    ...    10 Faulty / 4298 Degraded: All / 4405 None
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Exists
    ...            fault_id=4298
    SELENIUM Check If Alarm Exists
    ...            fault_id=4405

Check Alarms Filtering When Some Affected Cells Filtering Is Selected
    [Documentation]    all filters are down - `affected_cells:   :some` is selected (no alarm is visible)
    ...    10 Faulty / 4298 Degraded: All / 4405 None
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CELL_OBJECT_AFFECTED_CELLS}
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=4298
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=4405

Check Alarms Filtering When Faulty Filtering Is Selected
    [Documentation]    only `Faulty is selected: ok (10 for RMOD is visible, 4405 and 4298 are not visible)
    ...    10 Faulty / 4298 Degraded: All / 4405 None
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CELL_OBJECT_FAULTY}
    SELENIUM Check If Alarm Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=4298
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=4405

Check Alarms Filtering When Degraded All Filtering Is Selected
    [Documentation]    only `Degraded: All` is selected: ok (4298 is visibe, 10 and 4405 are not visible)
    ...    10 Faulty / 4298 Degraded: All / 4405 None
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CELL_OBJECT_DEGRADED_ALL}
    SELENIUM Check If Alarm Exists
    ...            fault_id=4298
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=4405

Check Alarms Filtering When None Filtering Is Selected
    [Documentation]    only `None` is selected: ok (4405 is visible, 10 and 4298 are not visible)
    ...    10 Faulty / 4298 Degraded: All / 4405 None
    SELENIUM Filter Alarms For Selected Object In Active Alarms
    ...    object_name=${CELL_OBJECT_NONE}
    SELENIUM Check If Alarm Exists
    ...            fault_id=4405
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=10
    SELENIUM Check If Alarm Not Exists
    ...            fault_id=4298

Trigger Fault 4011
   Trigger Fault 1898
   Wait Until Keyword Succeeds
    ...    720
    ...    5
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=4011

Trigger Fault 61652
    ADMIN Perform Parameter Update
    ...    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actServicePortState
    ...    value=true
    ...    timeout=60
    Wait Until Keyword Succeeds
    ...    30
    ...    5
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=61652

Cancel Fault 61652
    ADMIN Perform Parameter Update
    ...    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actServicePortState
    ...    value=false
    ...    timeout=60
    Wait Until Keyword Succeeds
    ...    60
    ...    5
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=61652

Cancel Fault 4011
    Cancel Fault 1898
    Wait Until Keyword Succeeds
    ...    15
    ...    5
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=4011

Trigger Fault 4405
    [Arguments]    ${syncInputType}
    Set Synchronization Source
    ...    syncInputType=${syncInputType}
    Wait Until Keyword Succeeds
    ...    6 min
    ...    5 sec
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=4405

Cancel Fault 4405
    Set Synchronization Source
    ...    syncInputType=1pps/ToD from external GNSS receiver
    Wait Until Keyword Succeeds
    ...    2 min
    ...    5 sec
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=4405

Trigger Fault 4298
    Trigger Fault 4405
    ...    syncInputType=TOPP
    Wait Until Keyword Succeeds
    ...    8 min
    ...    5 sec
    ...    ADMIN Check If Alarm Is Active
    ...    fault_id=4298

Cancel Fault 4298
    Cancel Fault 4405
    Wait Until Keyword Succeeds
    ...    4 min
    ...    5 sec
    ...    ADMIN Check If Alarm Is Not Active
    ...    fault_id=4298

Change BTS Synchronization Mode If Needed
    [Documentation]  For fault 4405 to be triggered in 4,5 min
    ${status}    Check Parameter Value
    ...    expected_value=PhaseSync
    ...    parameter_name=activeSyncMode
    ...    dist_name=${CLOCK_OBJECT_DIST_NAME}
    Run Keyword Unless    ${status}    Change BTS Synchronization Mode To Phase Sync

Check Parameter Value
    [Arguments]    ${expected_value}    ${parameter_name}    ${dist_name}
    ${value}    Admin Get Parameter
    ...    dist_name=${dist_name}
    ...    parameter=${parameter_name}
    ${status}    Run Keyword And Return Status
    ...    Should Be Equal    ${value}    ${expected_value}
    [Return]    ${status}

Change BTS Synchronization Mode To Phase Sync
    ADMIN Perform Parameter Update
    ...    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1
    ...    parameter=btsSyncMode
    ...    value=PhaseSync
    ...    timeout=8 min
    Wait Until Keyword Succeeds
    ...    8 min
    ...    5 sec
    ...    ADMIN INFOMODEL Check If BTS Is OnAir

Set Synchronization Source
    [Arguments]    ${syncInputType}
    ${syncInputdict}    Create Dictionary
    ...    syncInputPrio=1	  syncInputType=${syncInputType}
    @{syncInputList}    Create List    ${syncInputdict}
    ADMIN Perform Parameter Update
    ...    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...    parameter=syncInputList
    ...    value=@{syncInputList}
    ...    timeout=2 min

Set New Date If Actual Time Is Not Equal To Admin Api Log Time
    [Arguments]    ${actual_date}
    ${actual_hour}    Run  date +%H
    ${actual_hour}    Remove String    ${actual_hour}    \r\n
    ${time_adminApi}    Run
    ...    command=tail --lines=4 ${ADMIN_API_LOG_DIR}/admin_api_default.log | awk '{print $1}' | egrep -m 1 '[0-9]+:[0-9]+:[0-9]+'
    ${time_adminApi}    Fetch From Left    ${time_adminApi}    :
    ${new_date}    Convert To Integer    ${actual_date}
    ${new_date}    Evaluate    ${new_date}+1
    ${new_date}    Convert To String    ${new_date}
    Run Keyword If    '${actual_hour}' == '23'
    ...    Run Keyword If    '${time_adminApi}' == '00'    Set Test Variable    ${actual_date}    ${new_date}


Check if fault 4011 exists in toggling history
    ${actual_date}    SYSTEM Execute Command On gNB    command=date +%Y%m%d
    ${actual_date}    Remove String    ${actual_date}    \r\n
    ${print}    OperatingSystem.Run    command=rm /home/ute/Downloads/'${OUT_ADMIN_BTS_NAME}'_FaultTogglingHistory_${actual_date}-????.txt
    Download Toggling History file
    ${count}    OperatingSystem.Run
    ...    command=cat /home/ute/Downloads/'${OUT_ADMIN_BTS_NAME}'_FaultTogglingHistory_${actual_date}-????.txt | grep -c '4011'
    should be true  ${count} > 0

Download Toggling History file
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    SELENIUM Go To Fault Toggling History Tab
    Wait Until Keyword Succeeds    4x    900ms
    ...   Page Should Contain    EFaultId_GPSSystemElementAl
    Wait Until Keyword Succeeds    100   10
    ...    click button    //*[@ng-if="isTabActive(tabs.togglingAlarms)"]//button[@ui-tooltip="Save"]
    Sleep  10
    SELENIUM Teardown Enviroment

Check Current Time
    ${hour_now}=    OperatingSystem.Run  date +%k
    ${minute_now}=  OperatingSystem.Run  date +%M
    ${second_now}=  OperatingSystem.Run  date +%S
    ${minute_now}=    convert to integer  ${minute_now}
    ${sum}=  OperatingSystem.Run  echo $(((${hour_now}*3600+${minute_now}*60)+${second_now}))
    Set Test Variable  ${sum}
	[Return]  ${sum}

Test Preconditions 5GC001525-SA With Selenium
    Log To Console    Test Preconditions 5GC001525-SA With Selenium
    Test Preconditions
    Wait Until Keyword Succeeds
    ...    600
    ...    10
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Return Status
    ...    ADMIN Assert No Unexpected Active Alarms
    ...    alowed_alarms_list=@{ALLOWED_ALARMS}
#    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager

Test Postconditions 5GC001525-SA
    Wait Until Keyword Succeeds
    ...    10 min
    ...    10 sec
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Return Status
    ...    ADMIN Assert No Unexpected Active Alarms
    ...    alowed_alarms_list=@{ALLOWED_ALARMS}
    Test Postconditions

Test Postconditions 5GC001525-SA With Selenium
    Log To Console    Test Postconditions 5GC001525-SA With Selenium
    Wait Until Keyword Succeeds
    ...    10 min
    ...    10 sec
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Return Status
    ...    ADMIN Assert No Unexpected Active Alarms
    ...    alowed_alarms_list=@{ALLOWED_ALARMS}
    Test Postconditions
    SELENIUM Teardown Enviroment

Get Current RMOD
    ${resp}  taf.sbts.oam.coam.admin.get_detected_hw_info
    ${current_RMOD}  set variable  ${resp['radioModules']['rmod'][0]['id']['configuration']}
    [Return]   ${current_RMOD}
