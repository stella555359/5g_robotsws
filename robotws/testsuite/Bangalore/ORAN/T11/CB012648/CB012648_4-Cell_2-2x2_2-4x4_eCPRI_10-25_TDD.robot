*** Settings ***
Force Tags    CLOUD_5G_O_H_AP_LOO_TOOLS_PRFOILE_TTI_LEGACY
    ...           RAN_5G    CONFIGURED

Documentation   :Copyright: Nokia
    ...             :Author   : Brijend Tiwari
    ...             :Contact  : brijend.tiwari@nokia.com
    ...             The aim of the feature is to verify half capacity of ASOH in TDD by verifying 4 cell with different TDD
    ...             Channel Bandwidth and max throughput.
    ...             Cells Detail
    ...             Cell-1 = 70 MHZ - eCPRI-10 - 2x2
    ...             Cell-2 = 100MHZ - eCPRI-25 - 2x2
    ...             Cell-3 = 100 MHZ - eCPRI-25 - 4x4
    ...             Cell-4 = 90MHZ - eCPRI-10 - 4x4
    ...             Requirement : SRAN_SFS_SISO.5469  and SRAN_SFS_SISO.5470


#Library          ute_wtssim
Library          Process
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta5g_commissioning
Library          ta5g_syslog
Variables        ta5g_global_var
Library          String
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../ORAN/T11/resources/ORAN_Keywords.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/configuration_id.robot
Resource         ../../../resources/ECEcommon/common_deal_config_file.robot
Resource         ../../../resources/ECEcommon/common_file_operation.robot

Suite Setup         Run keywords   Get and Update RFMplugin   ${RFplugin_file}     ${artifactory_link}
    ...                 AND     Configure Netconf Credentials
    ...                 AND     Sleep    30s
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     load iphyfile     ${INSTALL_OFGESA}
    ...                 AND     Update GNB R&D Parameter   ${LOG_PATH}   ${rad_params}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                           scfc_filename=Final_SCF_ASOH_2x2-eCPRI-10_4x4-eCPRI-25.xml
    ...                 AND     start Log   btslog
    ...                 AND     Load CFG Config      ${wts_cfg_file}
    ...                 AND     Sleep    300s
    ...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Log   snapshot  sosreport  btslog

*** Variables ***

${INSTALL_OFGESA}     ${CURDIR}/config/5G_install_radio.sh
${RFplugin_file}      RFMPlugin_O-RU_NK_475701A-102_0010.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/25R2_NCSnapshot-AWHQN.xml
${wts_cfg_file}       ${CURDIR}/config/Basic_4Cell.cfg
${AP_XML}             ${CURDIR}/config/ASOH_Iphy.xml
${SCFC}               ${CURDIR}/config/SBTS25R2/Final_SCF_ASOH_2x2-eCPRI-10_4x4-eCPRI-25.xml
&{WTS}                Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}            /opt/iphy/latest
${sa_ue_id1}          ${1}
${TEST_NAME}          CB010358_100Mhz_25ecpri
${rad_params}         0x420088=1

*** Test Cases ***

[1]CB012648-A_Half_ASOH_4x4_100MHZ_4-Cell_2x25G_ECPRI_2x10G_ECPRI
    [Documentation]   The purpose of this test case is to verify Half ASOH BB Cell Capacity with smodBoardConfigType = NRTDD
	Check Peak Throughput for UE 1 (70MHZ CHBW 2x2)
	Check Peak Throughput for UE 2 (100MHZ CHBW 2x2)
	Check Peak Throughput for UE 3 (100MHZ CHBW 4x4)
	Check Peak Throughput for UE 4 (90MHZ CHBW 4x4)
    sleep   5s
    Check overall gNB Throughput with all UEs
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***

Check Peak Throughput for UE 1 (70MHZ CHBW 2x2)
	${crnti_list}=      MultiUE Register should be Successful    1  1
    sleep   2s
    Trigger MAX DL throughput    1    1    5
    Trigger MAX UL throughput    1    1    2
    sleep   10s
	Validate MAX DL throughput   1    1    500
	Validate MAX UL throughput   1    1    120
	Stop MultiUE Data Traffic for SA     1    1
	MultiUE Deregister should be Successful   1   1

Check Peak Throughput for UE 2 (100MHZ CHBW 2x2)
    ${crnti_list}=      MultiUE Register should be Successful    2  2
    sleep   2s
    Trigger MAX DL throughput    2    2    9
    Trigger MAX UL throughput    2    2    2
    sleep   10s
	Validate MAX DL throughput   2    2    740
	Validate MAX UL throughput   2    2    180
	Stop MultiUE Data Traffic for SA     2    2
	MultiUE Deregister should be Successful   2   2

Check Peak Throughput for UE 3 (100MHZ CHBW 4x4)
    ${crnti_list}=      MultiUE Register should be Successful    3  3
    sleep   2s
    Trigger MAX DL throughput    3    3    9
    Trigger MAX UL throughput    3    3    2
    sleep   10s
	Validate MAX DL throughput   3    3    1300
	Validate MAX UL throughput   3    3    180
	Stop MultiUE Data Traffic for SA     3   3
	MultiUE Deregister should be Successful   3   3

Check Peak Throughput for UE 4 (90MHZ CHBW 4x4)
    ${crnti_list}=      MultiUE Register should be Successful    4  4
    sleep   2s
    Trigger MAX DL throughput    4    4    9
    Trigger MAX UL throughput    4    4    2
    sleep   10s
	Validate MAX DL throughput   4    4    1050
	Validate MAX UL throughput   4    4    160
	Stop MultiUE Data Traffic for SA     4   4
	MultiUE Deregister should be Successful   4   4

Check overall gNB Throughput with all UEs
     ${crnti_list}=      MultiUE Register should be Successful    1  4
     sleep   2s
     Trigger MAX DL throughput    1    4    2
     Trigger MAX UL throughput    1    4    2
     sleep   10s
	 Validate MAX DL throughput   1    1    250
	 Validate MAX UL throughput   1    1    120
	 Validate MAX DL throughput   2    3    250
	 Validate MAX UL throughput   2    3    170
	 Validate MAX DL throughput   4    4    300
	 Validate MAX UL throughput   4    4    160
     Stop MultiUE Data Traffic for SA     1    4
     MultiUE Deregister should be Successful   1   4
