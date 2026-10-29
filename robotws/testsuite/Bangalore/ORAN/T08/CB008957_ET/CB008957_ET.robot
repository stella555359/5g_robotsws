*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com
...   Description: Test Suite CB008957_ET

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
Resource		 ${CURDIR}/resources/CB008957_ET_keywords.robot
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

Test Setup	        CB008957_ET_keywords.Test Setup
Test Teardown       CB008957_ET_keywords.Test Teardown
Suite Teardown      CB008957_ET_keywords.Suite Teardown Local
Force Tags      	QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${INSTALL_OFGESA}       ${CURDIR}/config/5G_install_OFGESA_v12.sh
${ncsnap_path}          ${CURDIR}/config/fjt_4T4R_FDD_n1_n3_n75_v7_1.xml
${wts_cfg_file}         ${CURDIR}/config/Config_Basic_v12.cfg
${IPHY_FILE}            ${CURDIR}/config/Iphy_CB008957.xml
&{WTS}                  Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}              /opt/iphy/latest
${TEST_NAME}            CB008957_faults_handling_during_supervision_watchdog

*** Test Cases ***
CB008957_faults_handling_during_supervision_watchdog
    [Documentation]    New ORAN Faults introduced by CB010792, O-RU SW upgrade and dhcp option-125 Verification.
	...	   Covered requirements ID’s:
	...		TT_GEN_COMMON_USCR_845
	...		OM_GEN_SFS_SWMGMNT.3346
	...		OM_GEN_SFS_SWMGMNT.3345
	...		OM_GEN_SFS_FM.3300
    Log To Console        ---Triggering ORAN supervision watchdog reset request---
	Create SSH Session To ORU and trigger fault locally     ${cmd_oran-supervision}
	sleep    100s
	BuiltIn.log to console		ORAN supervision watchdog reset request triggered
	Verify ORAN Fault 10
