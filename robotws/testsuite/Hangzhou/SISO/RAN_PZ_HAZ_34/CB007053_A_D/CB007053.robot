*** Settings ***
Suite Setup      robot_common_operations.Common Suite Setup
Suite Teardown    Run keywords    Suite Teardown with SCF    AND    robot_common_operations.Common Suite Teardown

Documentation    author：shushu huang
...              contact: shushu.huang@nokia-sbell.com
...              squad group: mmw_SG_03

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          ./Resources/CB007053_common.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Variables         ./Resources/CB007053_para.py

*** Variables ***
${GNB_PB_ASIK_IP}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PB_ASIK_PORT}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}


*** Test Cases ***
[1]CB007053_01_8 cells configuration with BB cell set type CB007053-A and CB007053-B
   [Tags]    HAZ3_T03
   [Setup]    robot_common_operations.Common Case Setup
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='25R3'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_01_25R3.xml
    ...    ELSE IF    '${RELEASE}'=='26R1'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_01_26R1.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB007053_A_01.xml
    Wait Until Keyword Succeeds   20m   1m    COAM Check All NR Cells Onair
    attach power ue
   start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
   Check power ue Tput    ul_throughput=24    dl_throughput=160
   stop multi power ue traffic ul and dl
   Run Keyword And Ignore error    COAM Logout
   [Teardown]    Run keywords    Run Keyword If Test Failed    Collect snapshot logs    AND
   ...    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
   ...    robot_common_operations.Common Case Teardown    AND
   ...    CI_interface.Common Case Teardown


[1]CB008124_G_05_IWK5_CG_Type_2_setup_for_UE_already_switched_to_Power_Saving_BWP
    [Tags]    HAZ3_T03
    [Setup]    robot_common_operations.Common Case Setup
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='25R3'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_01_25R3.xml
    ...    ELSE IF    '${RELEASE}'=='26R1'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_01_26R1.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB007053_A_01.xml
    Wait Until Keyword Succeeds   20m   1m    COAM Check All NR Cells Onair
     attach power ue
    #Start Btslog Collect for CB008124
    start power ue traffic ul and dl      ul_throughput=100M    dl_throughput=200M
    #Stop btslog and check
    stop multi power ue traffic ul and dl
    Run Keyword And Ignore error    COAM Logout
    [Teardown]    Run keywords    Run Keyword If Test Failed    Collect snapshot logs    AND
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown


[1]CB008953_A_8_NR_TDD_CPRI_configuration_4_radios_with_2_NR_carriers_per_radio_with_ASOE_09
    [Tags]    HAZ3_T03
    [Setup]    robot_common_operations.Common Case Setup
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='25R3'    Scf commission and wait on-air    scf_name=SCF_CB008953_config8_25R3.xml
    ...    ELSE IF    '${RELEASE}'=='26R1'    Scf commission and wait on-air    scf_name=SCF_CB008953_config8_26R1.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB008953_config8.xml
    Wait Until Keyword Succeeds   20m   1m    COAM Check All NR Cells Onair
     attach power ue
    start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
    Check power ue Tput    ul_throughput=24    dl_throughput=160
    stop multi power ue traffic ul and dl
	Run Keyword And Ignore error    COAM Logout
    [Teardown]    Run keywords    Run Keyword If Test Failed    Collect snapshot logs    AND
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown

[1]CB007053_02_8 cells configuration with BB cell set type CB007053-C and CB007053-D
    [Tags]    HAZ3_T03
    [Setup]    robot_common_operations.Common Case Setup
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='25R3'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_10_25R3.xml
    ...    ELSE IF    '${RELEASE}'=='26R1'    Scf commission and wait on-air    scf_name=SCF_CB007053_A_10_26R1.xml
    ...    ELSE    Scf commission and wait on-air    scf_name=SCF_CB007053_A_10.xml
    Wait Until Keyword Succeeds   20m   1m    COAM Check All NR Cells Onair
     attach power ue
    start power ue traffic ul and dl      ul_throughput=30M    dl_throughput=200M
    Check power ue Tput    ul_throughput=24    dl_throughput=160
    stop multi power ue traffic ul and dl
	Run Keyword And Ignore error    COAM Logout
    [Teardown]    Run keywords    Run Keyword If Test Failed    Collect snapshot logs    AND
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    detach multi power ue    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown

[1]CB012190_B_09_2CC_AWHHF_49.5M_4T4R_49.5M_4T4R
    [Setup]    robot_common_operations.Common Case Setup
    Scf commission and wait on-air    scf_name=SCF_CB012190_2CC.xml
    Conect to DU COAM

    Modify the normal cell to slim cell 49.5MHz    key_dl=slimRfFilterDL    key_ul=slimRfFilterUL    value=49.5MHz    cell_ID=3
    Collect snapshot logs for check soap info
    Extract Permanent from snapshot     snapshot_file=${TS_CASE_LOG_PATH}/Snapshot.zip
    Check Soap log    distName=NR11452.RX4_1_6    expected_bandwidth=50000000    soapfile=UnitOAM_SOAP_Log0.xml
    Check Soap log    distName=NR11452.RX3_1_6    expected_bandwidth=49500000    soapfile=UnitOAM_SOAP_Log0.xml

    Modify the normal cell to slim cell 49.5MHz    key_dl=slimRfFilterDL    key_ul=slimRfFilterUL    value=49.5MHz    cell_ID=4
    Collect snapshot logs for check soap info
    Extract Permanent from snapshot     snapshot_file=${TS_CASE_LOG_PATH}/Snapshot.zip
    Check Soap log    distName=NR11452.RX4_1_6    expected_bandwidth=49500000    soapfile=UnitOAM_SOAP_Log1.xml
    Check Soap log    distName=NR11452.RX3_1_6    expected_bandwidth=49500000    soapfile=UnitOAM_SOAP_Log0.xml


    [Teardown]    Run keywords    Run Keyword If Test Failed    Collect snapshot logs    AND
    ...    RUN KEYWORD AND CONTINUE ON FAILURE    COAM Logout    AND
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown


