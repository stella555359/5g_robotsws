*** Settings ***
Documentation
...  author : lei.nie@nokia-sbell.com
...  contact: lei.nie@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***


*** Keyword ***
# ===============================================================================================================================================
# ===============================================================================================================================================
# ===============================================================================================================================================
002_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
    Log To Console   CB008329 002_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Active_Partition
    Delete Active FileDirectory
    Trigger SC via Admin
    Check Active Missing Files Detection Alarm

Case Setup: 002
    Log To Console   Case setup

Case Teardown: 002
    Log To Console   Case teardown
    Sleep   60s
    Restore Active FileDirectory
    Trigger SC via Admin
    Check Active No Missing Files Detection Alarm
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown


Delete Active FileDirectory
    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    Run Keyword If   ${DUAL_CORE}
    ...   csn.Connect To   hostname=${DUALCORE_HOST}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=DUAL   proxy=LOCAL
    ${True_Connection}   Set Variable If   ${DUAL_CORE}   DUAL   LOCAL

    csn.Execute   command=mkdir -p /user/toor4nsn/test   connection=${True_Connection}
    csn.Execute   command=mv -f /rom/swpool/OAM/radioMappingFiles/beamforming* /user/toor4nsn/test/   connection=${True_Connection}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${DUAL_CORE}   csn.Disconnect   connection=DUAL   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL


Restore Active FileDirectory
    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    Run Keyword If   ${DUAL_CORE}
    ...   csn.Connect To   hostname=${DUALCORE_HOST}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=DUAL   proxy=LOCAL
    ${True_Connection}   Set Variable If   ${DUAL_CORE}   DUAL   LOCAL

    csn.Execute   command=mv -f /user/toor4nsn/test/beamforming* /rom/swpool/OAM/radioMappingFiles/   connection=${True_Connection}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${DUAL_CORE}   csn.Disconnect   connection=DUAL   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL

Check Active Missing Files Detection Alarm
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Contain Any   ${supplAlarmInfo}   5a   5
    Should Contain Any   ${severity}   Warning   Minor

Check Active No Missing Files Detection Alarm
    Return From Keyword If   ${UTE_FLAG}
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Not Contain Any   ${supplAlarmInfo}   5a   5
    Sleep   10s


# ===============================================================================================================================================
# ===============================================================================================================================================
# ===============================================================================================================================================
003_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Passive_Partition
    Log To Console   CB008329 003_SC_Detects_Missing_Files_Referred_In_FileDirectoryXML_On_Passive_Partition
    Delete Passive FileDirectory
    Trigger SC via Admin
    Check Passive Missing Files Detection Alarm


Case Setup: 003
    Log To Console   Case setup

Case Teardown: 003
    Log To Console   Case teardown
    Sleep   60s
    Restore Passive FileDirectory
    Trigger SC via Admin
    Check Passive No Missing Files Detection Alarm
    Run Keyword And Ignore Error   CI_interface.Common Case Teardown


Delete Passive FileDirectory
    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    Run Keyword If   ${DUAL_CORE}
    ...   csn.Connect To   hostname=${DUALCORE_HOST}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=DUAL   proxy=LOCAL
    ${True_Connection}   Set Variable If   ${DUAL_CORE}   DUAL   LOCAL

    csn.Execute   command=mount -o rw,remount /ffs/stb   connection=${True_Connection}
    csn.Execute   command=mv -f /ffs/stb/FileDirectory.xml /ffs/stb/backup_FileDirectory.xml   connection=${True_Connection}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${DUAL_CORE}   csn.Disconnect   connection=DUAL   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL

Restore Passive FileDirectory
    csn.Connect To   hostname=${LOCAL_SSH_ADDR}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=LOCAL
    Run Keyword If   ${DUAL_CORE}
    ...   csn.Connect To   hostname=${DUALCORE_HOST}   username=${LOCAL_SSH_USER}   password=${LOCAL_SSH_PWD}   alias=DUAL   proxy=LOCAL
    ${True_Connection}   Set Variable If   ${DUAL_CORE}   DUAL   LOCAL

    csn.Execute   command=mount -o rw,remount /ffs/stb   connection=${True_Connection}
    csn.Execute   command=mv -f /ffs/stb/backup_FileDirectory.xml /ffs/stb/FileDirectory.xml   connection=${True_Connection}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Run Keyword If   ${DUAL_CORE}   csn.Disconnect   connection=DUAL   AND
    ...   Run Keyword And Ignore Error   csn.Disconnect   connection=LOCAL

Check Passive Missing Files Detection Alarm
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Contain Any   ${supplAlarmInfo}   5b   6
    Should Contain Any   ${severity}   Warning   Minor

Check Passive No Missing Files Detection Alarm
    Return From Keyword If   ${UTE_FLAG}
    ${supplAlarmInfo}   ${alarm_id}   ${fault_id}   ${severity}   Get SC Active Alarm
    Should Not Contain Any   ${supplAlarmInfo}   5b   6
    Sleep   10s
