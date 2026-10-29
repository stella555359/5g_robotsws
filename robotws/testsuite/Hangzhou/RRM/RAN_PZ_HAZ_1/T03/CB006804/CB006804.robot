*** Settings ***
Documentation
...   author: Nicky Lu
...   contact: nicky.lu@nokia-sbell.com
...   this is a robot case about CB006804
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Case Teardown
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_ASIBL_ABIO_ABIN_AHLOA_AHFIB-ASIKR_ABIL2_AZHL
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}          ${93}
${PA_NormalValue}       ${10}
${PA_NormalValue2}      ${30}
${PA_MinValue}          ${0}
${UE_IP}                172.252.116.19
${CA_CheckPoint}        PCell's relations: {[0-9]+,[0-9]+,[0-9]+}   #sCell candidate
${CELL_ID}              636182

*** Test Cases ***
CB006804 #1.a LTE-NR DSS SCell handling during SgNB Addition procedure when CA is not configured, without CA configuration after EN-DC setup
    [Documentation]    Author: Nicky Lu
    [Tags]    10_5_UTESRAN001T2485    SCF_10_5_UTESRAN001T2485_CB006804
    Start Local Sys Log
    Start DL traffic By Iperf    time=200    ue_ip=${UE_IP}
    Attach UE to ENB
    Attach UE By AT
    Check ENB Attach State
    Attach UE to GNB
    Check EN-DC State
    Check DSS SCell Restriction    ${CELL_ID}

CB006804 #2.a LTE-NR DSS SCell handling during SgNB Addition MeNB initiated SgNB Modification procedure when CA is already configured
    [Documentation]    Author: Nicky Lu
    [Tags]    10_5_UTESRAN001T2485    SCF_10_5_UTESRAN001T2485_CB006804
    Start Local Sys Log
    Start DL traffic By Iperf    time=200    traffic=500.00M    ue_ip=${UE_IP}
    Attach UE to ENB
    Attach UE By AT
    Check ENB Attach State
    Attach UE to GNB
    Check EN-DC State
    Check DSS SCell Restriction    ${CELL_ID}

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Connect All VM
    Run Keyword And Ignore Error    Stop BTSLite For Btslog On VM0
    Run Keyword And Ignore Error    MultiBTS BackupSCF after Case Execution
    Run Keyword if Test Failed    Collect Coam Snapshot For All GNB
    Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    interface.Common step trigger
    ${dfst}    ${ret}    Run Keyword And Ignore Error    csn.execute    command=df    connection=BTS0_VM
    Log to console    ${ret}
    Run Keyword if Test Passed    Run Keyword And Ignore Error    _Zip Test Logs
    Run Keyword And Ignore Error    Disconnect All VM
    Teardown All GNB FCT Connect
    Logout All Coam Admin
    Run Keyword And Ignore Error    End Get Resources Usage And Compare
    Run Keyword And Ignore Error    AT Teardown

Start Local Sys Log
    Connect All VM
    Prepare BTSLite On Local
    ${log_start_time}    Get TimeStamp With Date
    Start BTSLite For Btslog On VM    vm_index=0    btslog_name=syslog_${log_start_time}.log

Attach UE To ENB
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue2}

Attach UE To GNB
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue}

Attach UE to ENB and GNB
    Log To Console    Attach UE to ENB and GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${3}    gnb_id=${0}    value=${PA_NormalValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${4}    gnb_id=${0}    value=${PA_NormalValue2}

Check ENB Attach State
    Log To Console    Check ENB Attach State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a UEC_UEM_INITIAL_CONTEXT_SETUP_ATTACH | grep -av grep
    Should Contain    ${ret}    UEC_UEM_INITIAL_CONTEXT_SETUP_ATTACH

Check EN-DC State
    Log To Console    Check EN-DC State
    Sleep    5s
    ${es}    ${ret}    Run Keyword And Ignore Error    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Run Keyword And Ignore Error    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check EN-DC CA Mode
    Log To Console    Check EN-DC CA Mode
    ${ret}    OperatingSystem.Run    cat ${BTS0_LOG_PATH} |grep -E "${CA_CheckPoint}" | grep -av grep
    ${matches}    Get Regexp Matches    ${ret}    ${CA_CheckPoint}
    Should Not Be Empty    ${matches}

Check DSS SCell Restriction
    Log To Console    Check DSS SCell Restriction
    [Arguments]    ${CELL_ID}
    Log To Console    ${CELL_ID}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "CB006804: Clearing dss restriction in all SCell candidates" | grep -av grep
    Should Contain    ${ret}    CB006804: Clearing dss restriction in all SCell candidates
#    ${ret1}    OperatingSystem.Run
#    ...    command=cat ${BTS0_LOG_PATH} |grep -a "CB006804-A-a: restricting scell with id: ${CELL_ID}" | grep -av grep
#    Should Contain    ${ret1}    CB006804-A-a: restricting scell with id: ${CELL_ID}

MultiBTS BackupSCF after Case Execution
    FOR    ${i}    IN RANGE   ${GNB_NUMBER}
        COAM_Admin.BackupSCF    connection=COAM_${i}
        ...    local_dir=${TEST_LOG_DIRECTORY}
        ...    file_name=back_${i}_final_commission.xml
    END