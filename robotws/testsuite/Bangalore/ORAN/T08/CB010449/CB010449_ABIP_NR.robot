*** Settings ***

Documentation    Script for CB010449 bb cell set feature
...   author: sreekumar.narimuri_kumaran@nokia.com


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
Resource    	 ${CURDIR}/resources/CB010449_Keywords.robot
Resource    	 testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot
Resource    	 testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot

Suite Setup         Run keywords       Admin_Connection
...					AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Configure Netconf Credentials Simulator
...                 AND     Sleep    30s
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     load iphyfile
...                 AND     Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=SCF_ABIP_NR_16_cells.xml
...		    AND     Sleep    60s
...                 AND     Load CFG Config And Verify cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...		    AND     Sleep    60s
...                 AND     Check gNB Bulid
...                 AND     Wait Until Keyword Succeeds    4min    5s	  Check_BTS_State    nom
...			AND		Suite Setup Local




Test Setup	        CB010449_Keywords.Test Setup
Test Teardown       CB010449_Keywords.Test Teardown
Suite Teardown      CB010449_Keywords.Suite Teardown Local
Force Tags      	QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${INSTALL_OFGESA}       ${CURDIR}/config/Install_OFGESA_ABIP.sh
${ncsnap_path}          ${CURDIR}/config/fjt_4T4R_FDD_n1_n3_n75_v7.xml
${wts_cfg_file}         ${CURDIR}/config/Mix_ABIP_16cell_n1n3.cfg
${IPHY_FILE}            ${CURDIR}/config/Mix_ABIP_16cell_n1n3.xml
&{WTS}                  Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}              /opt/iphy/latest

*** Test Cases ***
CB010449_ABIP_cell_set_NR_FDD_cells
	Wait Until Keyword Succeeds    10min    10s    Check BTS is OnAir   nom
	Check Active Fault
    Wait Until Keyword Succeeds    10min    10s	  Check MIB_SIB status of GNB cell     1
	UE Register should be Successful     1    1    1    1
	Trigger DL Traffic for SA    1    Traffic_rate=kbps     dl_rate=15      pdu_id=1    trf_id=1       qfi_id=1
    Trigger UL Traffic for SA    1    Traffic_rate=kbps     ul_rate=15      pdu_id=1    trf_id=1       qfi_id=1
    Sleep      10s
    Stop Data Traffic for SA     1
    UE Deregister should be Successful    1
	O-RU reset
