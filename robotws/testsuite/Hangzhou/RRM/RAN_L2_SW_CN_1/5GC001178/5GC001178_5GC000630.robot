*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Prepare QT LOLO Enviroment    TYPE=FDD
#...               AND    Suite Setup Update GNB
#...               AND    Set Suite Variable    ${WTS_CFG}    FDD_basic_setup.cfg
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        #Common Test Setup
#Test Teardown     #Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD    RAN_5G_FDD    FR1
#...               Owner_YuXin    CN1_SQ    5GC001178    RAN_5G    SBTS00    SBTS23R1    SBTS22R4    CRT
#Resource          ../CUDU_L2/common_setup_teardown.robot
#
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             2
#${BEARER_ID}           2
#@{OLD_CFG_PARAMS}      plmn=[0-9]+:[0-9]+
#@{NEW_CFG_PARAMS}      plmn=302:610
#@{LOG_NAME_LIST}       btslog    snapshot
#${COUNT}               0
#@{COUNTER_LIST}    M55323C04001    M55323C04002    M55323C04003    M55323C04004    M55323C04005    M55323C04006    M55323C04007
#...    M55323C04008    M55323C04009    M55323C04010    M55323C04011    M55323C04012    M55323C04013    M55323C04014    M55323C04015
#...    M55323C04016    M55323C04017    M55323C04018    M55323C04019    M55323C04020
#
#*** Test Cases ***
#5GC001178_630_B_03_Verify_Intermittent_Data_Transfer_over_NOKIA_Flow_Control
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    Delete PM BTS counter file
#    SA Start DL Traffic    5    20
#    SA Stop DL Traffic
#    SA Check Average Traffic Bigger Than Target    dl    5
#    SA Start DL Traffic    10    20
#    SA Stop DL Traffic
#    SA Check Average Traffic Bigger Than Target    dl    10
#    SA Start DL Traffic    15    20
#    SA Stop DL Traffic
#    SA Check Average Traffic Bigger Than Target    dl    15
#    SA Start DL Traffic    20    20
#    SA Stop DL Traffic
#    SA Check Average Traffic Bigger Than Target    dl    20
#    BuiltIn.Log    \n DL Traffic is OK \n    console=yes
#    SA 5G Detach    ${UE_ID}
#    Check BTS Counters
#
#*** Keywords ***
#Delete PM BTS counter file
#    Log To Console    Delete PM BTS counter file on SA
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    rm /tmp/PM.BTS*
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Check BTS Counters
#    Log to Console    Check BTS Counters
#    : FOR    ${counter}    IN    @{COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${counter} as 0
#    \    sleep    5
#
#Get the bts counter ${counter_id} as 0
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    gunzip /tmp/PM.BTS*.gz
#    SSH.Execute    rm /tmp/PM.BTS*.xml
#    ${counter_info}    SSH.Execute    cat /tmp/PM.BTS* | grep ${counter_id}
#    ${regexp_matche_list}    get regexp matches    ${counter_info}    <${counter_id}>(\\d+)</${counter_id}>    1
#    BuiltIn.Log    ${regexp_matche_list}
#    ${value}    get from list    ${regexp_matche_list}    0
#    should be true    ${value}==0
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
