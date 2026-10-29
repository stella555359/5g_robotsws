*** Settings ***

Documentation   :copyright: Nokia
    ...             :author   : Pradeep Kumar K L
    ...             :contact  : pradeep.kumar_k_l@nokia.com
    ...             The aim of the feature is to verify the functionality of newly introduced HW ABIQ for
    ...             TDD 100Mhz chBW 25ecpri link NR cell L3 call

Library          Process
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ta5g_commissioning
Library          ta5g_syslog
Variables        ta5g_global_var
Library          String
Library          ute_wtssim
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../resources/robot/Setup_Env.robot
Resource         ../../../resources/robot/Airphone.robot
Resource         ../../../ORAN/T11/resources/ORAN_Keywords.robot
Resource         taf/rfrl/common_resources/robot/libraries_instances.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../resources/robot/configuration_id.robot


*** Variables ***

${INSTALL_OFGESA}     ${CURDIR}/config/5G_install_radio.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_TA08029-B311-A1_0003.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/samji_ncs_1.xml
${wts_cfg_file}       ${CURDIR}/config/Basic_Setup_Samji.cfg
${IPHY_FILE}          ${CURDIR}/config/SAMJI_IPY_abiq.xml
${scfc_filename}      ${CURDIR}/config/SBTS/scf_CB10358_ABIQ.xml
&{WTS}                Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}            /opt/iphy/latest
${sa_ue_id1}            ${1}
${TEST_NAME}          CB010358_100Mhz_25ecpri

${INSTALL_OFGESA2}     ${CURDIR}/config/5G_install_radio_FDD.sh
${ncsnap_path2}        ${CURDIR}/../Snapshot/NCS*
${wts_cfg_file2}       ${CURDIR}/config/basic.cfg
${IPHY_FILE2}          ${CURDIR}/config/Iphy_FDD.xml
${scfc_filename2}      ${CURDIR}/config/SBTS25R1/FDD_SCF_MP_20MHZ_25ECPRI.xml


*** Test Cases ***

[1]CB010358_100MHz_ChBW_TDD_Verify_L3Call_ORU
    [Documentation]   The purpose of this test case is to verify successful TDD 100Mhz chBW 25ecpri link NR cell L3 call
    [Setup]      Run keywords    Get and Update RFMplugin   ${RFplugin_file}     ${artifactory_link2}
    ...                 AND     load ncsnapshot     ${ncsnap_path}
    ...                 AND     Configure Netconf Credentials
    ...                 AND    Sleep    30s
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     load iphyfile     ${INSTALL_OFGESA}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                           scfc_filename=scf_CB10358_ABIQ.xml
    ...                 AND     start Log   btslog
    ...                 AND     Load CFG Config      ${wts_cfg_file}
    ...                 AND     Check gNB Bulid
    ${crnti_list}=      MultiUE Register should be Successful    1  1
    sleep   5s
    Trigger MAX DL throughput    1    1    9
    Trigger MAX UL throughput    1    1    3
    sleep   30s
	Validate MAX DL throughput   1    1    1100
	Validate MAX UL throughput   1    1    170
    Stop MultiUE Data Traffic for SA     1    1
    MultiUE Deregister should be Successful   1   1
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Log  snapshot  sosreport  btslog

[1]CB010358_20MHz_ChBW_FDD_Verify_L3Call_ORU
    [Documentation]   The purpose of this test case is to verify successful FDD 20Mhz chBW 25ecpri link NR cell L3 call
    [Setup]     Run keywords     Get and Update RFMplugin   ${RFplugin_file}     ${artifactory_link2}
    ...                 AND     load ncsnapshot     ${ncsnap_path2}
#    ...                 AND     Configure Netconf Credentials
    ...                 AND    Sleep    30s
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     load iphyfile      ${INSTALL_OFGESA2}
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                           scfc_filename=FDD_SCF_MP_20MHZ_25ECPRI.xml
    ...                 AND     start Log   btslog
    ...                 AND     Load CFG Config      ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid
    ${crnti_list}=      MultiUE Register should be Successful    1  2
    sleep   5s
    Trigger MAX DL throughput    1    2    5
    Trigger MAX UL throughput    1    2    3
    sleep   30s
	Validate MAX DL throughput    1    1    350     #uses 4TXRX cell
	Validate MAX DL throughput    2    2    190     #uses 2TXRX cell
	Validate MAX UL throughput    1    2    215
    Stop MultiUE Data Traffic for SA     1    2
    MultiUE Deregister should be Successful   1   2
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
        [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Log  snapshot  sosreport  btslog
