*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Andreea Zaharia (andreea-oana.zaharia@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002056-AZ_5GC000666
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC000666/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        DateTime
#Library        Selenium2Library


Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../resources/keywords.robot



*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True



*** Keywords ***
5GC000666_ABION_Check_that_BTS_log_filenames_can_be_generated_and_are_uniquely_identified
    log to console  Check_that_BTS_log_filenames_can_be_generated_and_are_uniquely_identified
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Collect Snapshot    /home/ute/snapshot/Snapshot_MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${OUT_ACTIVE_SW}_${time}.zip    Full
    OperatingSystem.File Should Exist    /home/ute/snapshot/Snapshot_MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${OUT_ACTIVE_SW}_${time}.zip
    Check If File Is Not Empty    /home/ute/snapshot/Snapshot_MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${OUT_ACTIVE_SW}_${time}.zip

5GC000666_ABION_Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content
    log to console  Check_that_the_WebEM_generate_a_list_file_with_the_snapshot_content
    ${time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Collect Snapshot    /home/ute/snapshot/Snapshot_MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${OUT_ACTIVE_SW}_${time}.zip    Full
    Extract Snapshot    /home/ute/snapshot/Snapshot_MRBTS-${OUT_MRBTS_ID}_${OUT_ADMIN_BTS_NAME}_${OUT_ACTIVE_SW}_${time}.zip
    ...      /home/ute/snapshot/snapshot_summary
    Check For Summary File    /home/ute/snapshot/snapshot_summary
    OperatingSystem.File Should Exist  /home/ute/snapshot/snapshot_summary/snapshot_file_list.txt
    Check If File Is Not Empty    /home/ute/snapshot/snapshot_summary/snapshot_file_list.txt

5GC000666_ABION_Check_the_InfoModel_snapshot_is_saved_on_Operator_PC
    log to console  Check_the_InfoModel_snapshot_is_saved_on_Operator_PC
    taf.sbts.oam.coam.admin.Collect Infomodel Log From Current Session    target_file_name=${OUTPUT_DIR}/${TEST_NAME}/IM_snapshot.ims2
    ...                                                                  connection=default
    OperatingSystem.File Should Exist  ${OUTPUT_DIR}/${TEST_NAME}/IM_snapshot.ims2
