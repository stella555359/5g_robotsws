*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Description: Test Suite CB010792: Introduction of O-RAN fronthaul specification baseline v12

Library     	SSHLibrary
Library     	BuiltIn
Library     	Process
Library     	String
Library     	DateTime
Library     	Collections
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          ute_wtssim
Library          ta5g_commissioning
Library          ta5g_syslog
Variables        ta5g_global_var
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource		 testsuite/Bangalore/resources/robot/Setup_Env.robot
Resource		 testsuite/Bangalore/resources/robot/Airphone.robot
Resource		 testsuite/Bangalore/resources/robot/WTS_Runner_Keywords.robot
Resource		 ${CURDIR}/resources/CB010792_keywords.robot
Resource    	 testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Resource    	 testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot

Suite Setup         Run keywords       Admin_Connection
...					AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Configure Netconf Credentials1
...                 AND     Sleep    30s
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     load iphyfile
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=FJT_v12_ORAN_SCF.xml
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
...					AND     X2AP Link Should be UP
...                 AND     Check gNB Bulid
...                 AND     Wait Until Keyword Succeeds    4min    5s	  Check_BTS_State    nom
...					AND		Suite Setup Local

Test Setup	        CB010792_keywords.Test Setup
Test Teardown       CB010792_keywords.Test Teardown
Suite Teardown      CB010792_keywords.Suite Teardown Local
Force Tags      	QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${INSTALL_OFGESA}       ${CURDIR}/config/5G_install_OFGESA_v12.sh
${ncsnap_path}          ${CURDIR}/config/FJT_NC_Snapshot_v12.xml
${wts_cfg_file}         ${CURDIR}/config/Config_Basic_v12.cfg
${IPHY_FILE}            ${CURDIR}/config/Iphy_v12_125.xml
&{WTS}                  Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}              /opt/iphy/latest
${TEST_NAME}            CB010792_oru_upgrade_dhcp_125_fault_34_35

*** Test Cases ***
CB010792_oru_upgrade_dhcp_125_fault_34_35
    [Documentation]    New ORAN Faults introduced by CB010792, O-RU SW upgrade and dhcp option-125 Verification.
	...	   Covered requirements ID’s:
	...		TT_GEN_COMMON_USCR_845
	...		OM_GEN_SFS_SWMGMNT.3346
	...		OM_GEN_SFS_SWMGMNT.3345
	...		OM_GEN_SFS_FM.3300
    Log To Console        ---Step1.ORU sw upgrade and netconf validation---
    Upgrade ORU SW
	Wait Until Keyword Succeeds     10m    10s    Check_BTS_State		nom
	Netconf file extract
	os.Copy File    ${output}
    ...    ${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SWUpgrade/${NetconfFileName}
	Log To Console        netconf log is copied from BTS for validation of rpc.
	Verify_Mplane_version_is_12		${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SWUpgrade/${NetconfFileName}
	Verify Netconf Rpc for ORU SW Upgrade	  	${BTS_path}/${SUITE NAME}/${Date}/${TEST_NAME}/SWUpgrade/${NetconfFileName}
	Log To Console        ---Step2.dhcp option 125 verification in fronthaul---
	Netconf call home and dhcp option 125 validation
	Log To Console        ---Step3.ORAN fault 34 and 35 verification.---
	Verify ORAN Faults 34 and 35