*** Settings ***

Documentation    O-RAN LTE FDD eCPRI support
...              This is testsuite testing O-RAN with CUS2.0 simulator and eNB

Library    OperatingSystem    WITH NAME     os
Library    taf.ul.sc.perf.testline.TestLineLoader
Library    taf.ul.sc.uesim.cus.Executor
Library    taf.sbts.oam.coam.admin
Library    taf.selenium.sbts    WITH NAME    sbts
Library    DateTime
Library    ta_uexgate
Library    taf.file.pack
Library    taf.ul.ue.sim.env_setup
Resource   ./testsuite/Bangalore/ORAN/T08/CB013328/CB013328_keyword.robot
Library    ./testsuite/Bangalore/ORAN/resources/python/netconf_validation.py
Library    ./testsuite/Bangalore/ORAN/T08/CB013328/resources/test_cus.py
Library    ./testsuite/Bangalore/ORAN/T08/CB013328/resources/cus_executor_commands.py
Resource    ./testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot

Suite Setup       Suite setup
Suite Teardown    Suite Teardown
Force Tags    CLOUD_MOPQ_CUS_LOOO    CUS_ORAN     SBTS00

*** Variables ***
${config_catalog}                  ${CURDIR}/resources
${coco1_yaml}                       ${CURDIR}/Config/KDDI_v12_ORAN_coco.yaml
${scf1_xml}                         ${CURDIR}/Config/Configuration_scf_KDDI_ASIM_ABIP.xml
${WEBUI_URL}                       https://192.168.255.129
${WEBUI_NAME}                      Nemuadmin
${WEBUI_PWD}                       nemuuser
${REDUCE_S1_RECONNECTION_TIME}=    0x0015001B=15
@{swconfig_flags}=                 0x340000 = 5
${local_cell_id_1}=                DN:NE-LNBTS-1/LNCEL-1/MCC-244/MNC-08
@{sudo_list}=                      &{authentication}
${snapshotfilename}=               Snapshot.zip
${snapshottimeout}=                400s
${snapshotfilename_unzip}          Snapshot_unzipped
&{authentication}   id=1    defaultNetconfAccount=&{default_user}
&{default_user}=    defaultNetconfAccountName=xranuser
...                 defaultNetconfAccountPwd=xran-password
${BTS_path}=                       /home/ute/logs/CB013328
@{swconfig_flags2}=                 ${REDUCE_S1_RECONNECTION_TIME}


*** Test Cases ***
CB013328_A_Verify PRACH config via section type 3 FCP when O-RU lacks PRACH-STATIC-CONFIG-SUPPORTED cap.
    Testline reconfiguration for ORAN     ${scf1_xml}     ${coco1_yaml}    @{swconfig_flags}
	Get ActiveAlarms
    Sleep     10s
    Verify Call
    Log collection and validation
	Login to CUS
	Search Phrase In File    ${output}    ${phrase}
    Robustness scenario
    [Tags]   QCD_MN_RAN    QCP_RAN_VRF

