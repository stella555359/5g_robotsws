*** Settings ***

Documentation   :copyright: Nokia
    ...             :author   : Brijend Tiwari
    ...             :contact  : brijend.tiwari@nokia.com
    ...             The aim of the feature is to verify the functionality of newly introduced FR1 FDD 50Mhz chBW NR cell NSA call

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

${INSTALL_OFGESA}     ${CURDIR}/config/50mhz_install_OFGESA_v7.sh
${RFplugin_file}      RFMPlugin_O-RU_FJ_TA08029-B311-A1_0003.zip
${ncsnap_path}        ${CURDIR}/../Snapshot/NCS_692.xml
${wts_cfg_file}       ${CURDIR}/config/50mhz_basic.cfg
${IPHY_FILE}          ${CURDIR}/config/50mhz_iphy.xml
${scfc_filename}      ${CURDIR}/config/SBTS26R3/NSA_SCF_50MHZ.xml
&{WTS}                Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}            /opt/iphy/latest
${nsa_ue_id}          ${11}
${nsa_ue_id1}         ${11}
${nsa_trf_id}         1
${nsa_qfi_id}         1
${TEST_NAME}          CB012255_50Mhz_SA

${RFplugin_file1}       RFMPlugin_O-RU_NK_475701A-102_0034.zip
${INSTALL_OFGESA_35mhz}       ${CURDIR}/config/5G_install_OFGESA_v7.sh
${ncsnap_path2}          ${CURDIR}/../Snapshot/NCS* FJT*
${wts_cfg_file2}         ${CURDIR}/config/35mhz_Basic.cfg
${IPHY_FILE2}            ${CURDIR}/config/iphy_35mhz.xml
${scfc_filename2}        ${CURDIR}/config/scf_CB014100-SR_5G_V17_v12_v7.xml
${sa_ue_id1}            ${1}
*** Test Cases ***

[1][1.0] CB012255_CB011006_50MHz_ChBW_FDD_Verify_L3Call_NSA_ORU
    [Setup]      Run keywords    Get and Update RFMplugin   ${RFplugin_file}     ${artifactory_link2}
    ...                 AND     load ncsnapshot     ${ncsnap_path}
    ...                 AND     Configure Netconf Credentials
    ...                 AND    Sleep    100s
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     load iphyfile     ${INSTALL_OFGESA}
    ...                 AND    Sleep    300s
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                           scfc_filename=NSA_SCF_50MHZ.xml     skip_relation_errors=True
    ...                 AND    Sleep    300s
    ...                 AND     start Log   btslog
    ...                 AND     Load CFG Config      ${wts_cfg_file}
    ...                 AND     Check gNB Bulid
    [Documentation]   The purpose of this test case is to verify successful NSA call on NR cell FR1 FDD 50Mhz chBW cell
    Attach NSA UE
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     dl_rate=170      trf_id=1
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     dl_rate=170      trf_id=2
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     dl_rate=170      trf_id=3
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     dl_rate=170      trf_id=4
    Trigger DL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     dl_rate=170      trf_id=5
    sleep  300s
    Trigger UL Traffic for NSA    ue_id=${nsa_ue_id}    Traffic_rate=mbps     ul_rate=170      trf_id=1
    sleep  100s
    Validate DL Traffic For NSA   ue_id=${nsa_ue_id}     dl_rate=850
    sleep  300s
    Validate UL Traffic For NSA   ue_id=${nsa_ue_id}     ul_rate=160
    Multiple NSA UE Detach   ${nsa_ue_id}  ${nsa_ue_id1}
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...                 AND     Stop Log  snapshot  sosreport  btslog

CB012255_CB014100_35MHz_ChBW_FDD_Verify_L3Call_SA_ORU
    [Setup]     Run keywords    Get and Update RFMplugin   ${RFplugin_file1}     ${artifactory_link1}
    ...                 AND     load ncsnapshot     ${ncsnap_path2}
    ...                 AND     Configure Netconf Credentials
    ...                 AND    Sleep    30s
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     load iphyfile     ${INSTALL_OFGESA_35mhz}
    ...                 AND    Sleep    300s
    ...                 AND     Find Scfc And Fix And Send Full Commissioning
    ...                           scfc_filename=scf_CB014100-SR_5G_V17_v12_v7.xml        skip_relation_errors=True
    ...                 AND    Sleep    300s
    ...                 AND     start Log   btslog
    ...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file2}
    ...                 AND     Check gNB Bulid
    [Documentation]   The purpose of this test case is to verify successful SA call on NR cell FR1 FDD 35Mhz chBW cell.
    ${crnti_list}=      MultiUE Register should be Successful    1  1
    sleep   5s
    Trigger MAX DL throughput    1    1    3
    Trigger MAX UL throughput    1    1    3
    sleep   30s
	Validate MAX DL throughput   1    1    500
	Validate MAX UL throughput   1    1    400
    Stop MultiUE Data Traffic for SA     1    1
    MultiUE Deregister should be Successful   1   1
    run keyword and continue on failure    Link SCOUT SCF to Configuration ID for Reporting
    [Teardown]    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
    ...         AND     Stop Log  snapshot  sosreport  btslog
