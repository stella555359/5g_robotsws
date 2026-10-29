# *** Settings ***
# Suite Setup    Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# ...    AND    Suite Teardown
# 
# Resource    ./Resources/CB007108_common_keywords.robot
# 
# Documentation
# ...    Author:Guo Zhenzhen
# ...    contact:zhenzhen.guo@nokia-sbell.com
# ...    squad group:mmw_SG_03
# ...    Feature CB007108
# 
# *** Variables ***
# ${first_angle}    8
# ${second_angle}    0
# ${third_angle}    2
# ${retu_index}    1
# ${SWCONFIG_DEFAULT_FILE_PATH}    /home/ute/
# 
# *** Test Cases ***
# 	
# [1]CB007108_02_ALD_Configuration_Management_ALD_site_commissioning_and_HW_detection
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
#     ...    AND    Scf commition and wair for on-air    scf_name=${scf_path}/${8T8R_scf_name}
#     Backup SCF and return
#     Add ALD precondition    ald_index=1    port_type=CAL
#     #${ald_info} =    Get ALD Information via WebEM    ald_index=1
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Product code"]}    msg=There is Product code for ALD
# 	should be equal    ${ald_info["Product code"]}    ATM3
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["Serial number"]}    msg=There is Serial number for ALD
# 	should be equal    ${ald_info["Serial number"]}    0000CN10184761297
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["HW version"]}    msg=There is HW version for ALD
# 	should be equal    ${ald_info["HW version"]}    2.0
#     Run keyword and continue on failure    Should Not Be Empty    ${ald_info["SW version"]}    msg=There is SW version for ALD
# 	should be equal    ${ald_info["SW version"]}    2.0.20
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
# 	...    AND    Check If there is new alarm
# 	
# [1]CB007108_03_ALD_Configuration_Management_RET_calibration_via_command
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup    AND    UE preparation
#     Check RETU Status
#     Calibrate RETU via WebEM
#     ${status}    run keyword and return status  RETU status should be normal
#     run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss
#     run keyword if    '${status}' == 'False'    Wait Until Keyword Succeeds   1 min  5 sec    Check RETU Status	
#     UE Prepare and UE attach
#     Start traffic and check UE DL and UL TP seperately
#     ...    expect_dl_tp=1400    expect_ul_tp=70    dl_traffic=1600M    ul_traffic=90M
#     Check RU Calibration Status And Compare
# 	[teardown]    run keywords    robot_common_operations.Common Case Teardown    AND    Detach UE for case finished
# 	...    AND    Check If there is new alarm
# 	
# [1]CB007108_04_Support_ALD_device_connected_via_calibration_port_and_RET_tilt_modification
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup    AND    UE preparation
#     Set angle for RET
#     UE Prepare and UE attach
#     Start traffic and check UE DL and UL TP seperately
#     ...    expect_dl_tp=1400    expect_ul_tp=70    dl_traffic=1600M    ul_traffic=90M	
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown    AND    Detach UE for case finished
# 	...    AND    Check If there is new alarm
# 	
# [1]CB007108_05_Support_ALD_devices_connected_via_calibration_port_and_RET_port
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup
# 	#...    AND    Scf commition and wair for on-air    scf_name=${scf_path}/${nonBF_scf_name}
# 	...    AND    Backup SCF and return
#     ...    AND    Add ALD precondition    ald_index=2    port_type=RET
#     ...    AND    UE preparation
#     Set angle for RET
#     Wait until keyword succeeds    2min    20s    RETU status should be normal    ald_index=1
#     sleep    20s
#     Set angle for RET    ald_index=2
#     UE Prepare and UE attach
#     Start traffic and check UE DL and UL TP seperately
#     ...    expect_dl_tp=1300    expect_ul_tp=60    dl_traffic=1600M    ul_traffic=90M
# 	[teardown]    run keywords    robot_common_operations.Common Case Teardown    
# 	...    AND    Detach UE for case finished
#     ...    AND    Check If there is new alarm
# 
# [1]CB007108_06_ALD_Configuration_Management_RETs_calibration_via_command
#     [Tags]    CRT_TRUNK
#     [Setup]    run keywords    robot_common_operations.Common Case Setup    AND    UE preparation
#     Check RETU Status    ald_index=2
#     Calibrate RETU via WebEM
#     Wait until keyword succeeds    2min    20s    RETU status should be normal    ald_index=2
#     sleep    20s
#     Calibrate RETU via WebEM    ald_index=2
#     RETU status should be normal
#     ${status}    run keyword and return status  RETU status should be normal    ald_index=2
#     run keyword if    '${status}' == 'False'    WA for ALD cases due to dip adjustment lever hw miss    ald_index=2
#     run keyword if    '${status}' == 'False'    Wait Until Keyword Succeeds   1 min  5 sec    Check RETU Status    ald_index=2
#     UE Prepare and UE attach
#     Start traffic and check UE DL and UL TP seperately
#     ...    expect_dl_tp=1300    expect_ul_tp=60    dl_traffic=1600M    ul_traffic=90M
#     Check RU Calibration Status And Compare
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown    AND    Detach UE for case finished
# 	...    AND    Check If there is new alarm	
# 	
# [1]CB007108_04_Fault_4141_4142_verification_when_ALD_connected_to_CAL_port
#     [Tags]    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Set hdlcCommunicationAllowed value for ANTL1    hdlcCommunicationAllowed=false
#     Wait until keyword succeeds    1min    5s    Check RETU Status    availability_status=off line
#     ...    operational_state=disabled    procedural_status=not initialized
#     Set dcVoltage value for ANTL1    dcVoltage=OFF
#     Wait until keyword succeeds    1min    5s    Check RETU Status    availability_status=power off
#     ...    operational_state=disabled    procedural_status=not initialized
#     Wait until keyword succeeds    1min    5s    CB007108_common_keywords.Expect Fault Should Present   faultId=4141    
#     ...    source=MRBTS-${mrbtsId}/EQM_R-1/APEQM_R-1/ALD_R-1/RETU_R-1    connection=GNB_OAM    severity=Major    alarmId=7113
#     CB007108_common_keywords.Expect Fault Should Present   faultId=4142    
#     ...    source=MRBTS-${mrbtsId}/EQM_R-1/APEQM_R-1/ALD_R-1/RETU_R-1    connection=GNB_OAM    severity=Major    alarmId=7113
#     recovery 4141 and 4142 for ANT1
#     Set hdlcCommunicationAllowed value for RSL    hdlcCommunicationAllowed=false
#     Wait until keyword succeeds    1min    5s    Check RETU Status    ald_index=2    availability_status=off line
#     ...    operational_state=disabled    procedural_status=not initialized
#     Set dcVoltageEnabled value for RSL    dcVoltageEnabled=false
#     Wait until keyword succeeds    1min    5s    Check RETU Status    ald_index=2    availability_status=power off
#     ...    operational_state=disabled    procedural_status=not initialized
#     run keyword and ignore error    CB007108_common_keywords.Expect Fault Should Present   faultId=4142
#     ...    source=MRBTS-${mrbtsId}/EQM_R-1/APEQM_R-1/ALD_R-2/RETU_R-1    connection=GNB_OAM    severity=Major    alarmId=7113
#     run keyword and ignore error    CB007108_common_keywords.Expect Fault Should Present   faultId=4141
#     ...    source=MRBTS-${mrbtsId}/EQM_R-1/APEQM_R-1/ALD_R-2/RETU_R-1    connection=GNB_OAM    severity=Major    alarmId=7113
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown    
#     ...    AND    CB007108_common_keywords.recovery 4141 and 4142 for ANT1
#     ...    AND    CB007108_common_keywords.recovery 4141 and 4142 for RSL
#     ...    AND    Check If there is new alarm
# 
# [1]CB007108_08
#     [Tags]    CRT_TRUNK
#     [Setup]    robot_common_operations.Common Case Setup
#     Selenium Login And Disable Screen Lock    download_dir=/tmp    version=${version}	
#     ${ald_info} =    run keyword and ignore error    Get ALD Information via WebEM    ald_index=1
#     [teardown]    run keywords    robot_common_operations.Common Case Teardown 
