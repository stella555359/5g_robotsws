*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB
#...               AND    Prepare QT LOLO Enviroment    TYPE=TDD
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        #Common Test Setup
#Test Teardown     #Common Test Teardown
#Force Tags        RAN_5G_TDD    FR1    Owner_qianwu    PRI-High    SBTS22R3
#...               RAN_5G    SBTS00    SBTS23R1    SBTS22R4    SBTS22R2    CN1_SQ    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
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
#${LOCAL_WTS_DIR}      ${CURDIR}/config
#${WTS_CFG}    wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
#
#@{A001_COUNTER_LIST}    M55319C01001    M55319C01002    M55319C01003    M55319C01004    M55319C01005    M55319C01006    M55319C01007
#...    M55319C01008    M55319C01009    M55319C01010    M55319C01011    M55319C01012    M55319C01013    M55319C01014    M55319C01015
#...    M55319C01016    M55319C01017    M55319C01018    M55319C01019    M55319C01020
#@{A002_COUNTER_LIST}    M55319C02001    M55319C02002    M55319C02003    M55319C02004    M55319C02005    M55319C02006    M55319C02007
#...    M55319C02008    M55319C02009    M55319C02010    M55319C02011    M55319C02012    M55319C02013    M55319C02014    M55319C02015
#...    M55319C02016    M55319C02017    M55319C02018    M55319C02019    M55319C02020
#@{A003_COUNTER_LIST}    M55319C03001    M55319C03002    M55319C03003    M55319C03004    M55319C03005    M55319C03006    M55319C03007
#...    M55319C03008    M55319C03009    M55319C03010    M55319C03011    M55319C03012    M55319C03013    M55319C03014    M55319C03015
#...    M55319C03016    M55319C03017    M55319C03018    M55319C03019    M55319C03020
#@{A004_COUNTER_LIST}    M55319C04001    M55319C04002    M55319C04003    M55319C04004    M55319C04005    M55319C04006    M55319C04007
#...    M55319C04008    M55319C04009    M55319C04010    M55319C04011    M55319C04012    M55319C04013    M55319C04014    M55319C04015
#...    M55319C04016    M55319C04017    M55319C04018    M55319C04019    M55319C04020
#@{A005_COUNTER_LIST}    M55319C05001    M55319C05002    M55319C05003    M55319C05004    M55319C05005    M55319C05006    M55319C05007
#...    M55319C05008    M55319C05009    M55319C05010    M55319C05011    M55319C05012    M55319C05013    M55319C05014    M55319C05015
#...    M55319C05016    M55319C05017    M55319C05018    M55319C05019    M55319C05020
#@{A006_COUNTER_LIST}    M55319C06001    M55319C06002    M55319C06003    M55319C06004    M55319C06005    M55319C06006    M55319C06007
#...    M55319C06008    M55319C06009    M55319C06010    M55319C06011    M55319C06012    M55319C06013    M55319C06014    M55319C06015
#...    M55319C06016    M55319C06017    M55319C06018    M55319C06019    M55319C06020
#@{A007_COUNTER_LIST}    M55319C07001    M55319C07002    M55319C07003    M55319C07004    M55319C07005    M55319C07006    M55319C07007
#...    M55319C07008    M55319C07009    M55319C07010    M55319C07011    M55319C07012    M55319C07013    M55319C07014    M55319C07015
#...    M55319C07016    M55319C07017    M55319C07018    M55319C07019    M55319C07020
#@{A008_COUNTER_LIST}    M55319C08001    M55319C08002    M55319C08003    M55319C08004    M55319C08005    M55319C08006    M55319C08007
#...    M55319C08008    M55319C08009    M55319C08010    M55319C08011    M55319C08012    M55319C08013    M55319C08014    M55319C08015
#...    M55319C08016    M55319C08017    M55319C08018    M55319C08019    M55319C08020
#@{A009_COUNTER_LIST}    M55315C02001    M55315C02002    M55315C02003    M55315C02004    M55315C02005    M55315C02006    M55315C02007
#...    M55315C02008    M55315C02009    M55315C02010    M55315C02011    M55315C02012    M55315C02013    M55315C02014    M55315C02015
#...    M55315C02016    M55315C02017    M55315C02018    M55315C02019    M55315C02020
#@{A010_COUNTER_LIST}    M55315C03001    M55315C03002    M55315C03003    M55315C03004    M55315C03005    M55315C03006    M55315C03007
#...    M55315C03008    M55315C03009    M55315C03010    M55315C03011    M55315C03012    M55315C03013    M55315C03014    M55315C03015
#...    M55315C03016    M55315C03017    M55315C03018    M55315C03019    M55315C03020
#
#*** Test Cases ***
#5GC001178-ET-A001-Verify NSA only UP_PMCounter_M55319C010xx_Traffic_DL_SDU_TX_NSA_QOS_GRP_xx in SA
#    [Tags]    CIT    CDRT
#    Check 1178-ET-A001 bts counters
#
#5GC001178-ET-A002-Verify NSA only UP_PMCounter_M55319C020xx_Traffic_DL_VOL_TX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A002 bts counters
#
#5GC001178-ET-A003-Verify NSA only UP_PMCounter_M55319C030xx_Traffic_MAX_DL_VOL_TX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A003 bts counters
#
#5GC001178-ET-A004-Verify NSA only UP_PMCounter_M55319C040xx_Traffic_MIN_DL_VOL_TX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A004 bts counters
#
#5GC001178-ET-A005-Verify NSA only UP_PMCounter_M55319C050xx_Traffic_UL_SDU_RX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A005 bts counters
#
#5GC001178-ET-A006-Verify NSA only UP_PMCounter_M55319C060xx_Traffic_UL_VOL_RX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A006 bts counters
#
#5GC001178-ET-A007-Verify NSA only UP_PMCounter_M55319C070xx_Traffic_MAX_UL_VOL_RX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A007 bts counters
#
#5GC001178-ET-A008-Verify NSA only UP_PMCounter_M55319C080xx_Traffic_MIN_UL_VOL_RX_NSA_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A008 bts counters
#
#5GC001178-ET-A009-Verify NSA only UP_PMCounter_M55315C020xx_Traffic_UL_PDCP_SDU_SNT_S1U_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A009 bts counters
#
#5GC001178-ET-A010-Verify NSA only UP_PMCounter_M55315C030xx_Traffic_UL_PDCP_VOL_SNT_S1U_QOS_GRP_xx in SA
#    [Tags]    CRT
#    Check 1178-ET-A010 bts counters
#
#*** Keywords ***
#
#Check 1178-ET-A001 bts counters
#    Log to Console    Check 1178-ET-A001 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A001_counter}    IN    @{A001_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A001_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A002 bts counters
#    Log to Console    Check 1178-ET-A002 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A002_counter}    IN    @{A002_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A002_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A003 bts counters
#    Log to Console    Check 1178-ET-A003 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A003_counter}    IN    @{A003_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A003_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A004 bts counters
#    Log to Console    Check 1178-ET-A004 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A004_counter}    IN    @{A004_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A004_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A005 bts counters
#    Log to Console    Check 1178-ET-A005 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A005_counter}    IN    @{A005_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A005_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A006 bts counters
#    Log to Console    Check 1178-ET-A006 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A006_counter}    IN    @{A006_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A006_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A007 bts counters
#    Log to Console    Check 1178-ET-A007 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A007_counter}    IN    @{A007_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A007_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A008 bts counters
#    Log to Console    Check 1178-ET-A008 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A008_counter}    IN    @{A008_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A008_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A009 bts counters
#    Log to Console    Check 1178-ET-A009 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A009_counter}    IN    @{A009_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A009_counter} as 0
#    \    sleep    5
#
#Check 1178-ET-A010 bts counters
#    Log to Console    Check 1178-ET-A010 bts counters
#    Prepare the Enviroment for common case
#
#    : FOR    ${A010_counter}    IN    @{A010_COUNTER_LIST}
#    \    wait until keyword succeeds    30min    1min   Get the bts counter ${A010_counter} as 0
#    \    sleep    5
#
#Delete PM BTS counter file
#    Log To Console    Delete PM BTS counter file on SA
#    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
#    SSH.Execute    rm /tmp/PM.BTS*
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
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
#
#Prepare the Enviroment for common case
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    Delete PM BTS counter file
#    SA Start DL Traffic    10    10
#    SA Stop DL Traffic
#    SA 5G Detach    ${UE_ID}
#    SA Check Average Traffic Bigger Than Target    dl    5
#    BuiltIn.Log    \n DL Traffic is OK \n    console=yes
#
