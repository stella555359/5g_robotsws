*** Settings ***

Documentation    Script for CB012647 SISO feature NR FDD
...   author: radhika.putchakayala@nokia.com
...   Description:

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
Resource		 testsuite/Bangalore/resources/robot/Airphone.robot
Resource		 testsuite/Bangalore/resources/robot/WTS_Runner_Keywords.robot
Resource     	 taf/rfrl/common_resources/common_step/interface.robot
Resource    	 ${CURDIR}/resources/CB012647_Keywords.robot

Suite Setup			Run keywords       Admin_Connection
...					AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Configure Netconf Credentials
...                 AND     Sleep    30s
...                 AND     load iphyfile
...		    AND     Sleep    60s
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...		    AND     Sleep    60s
...			AND		Suite Setup Local


Test Setup	        CB012647_Keywords.Test Setup
Suite Teardown		Suite_Teardown
Test Teardown       CB012647_Keywords.Test Teardown
Force Tags      	QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${INSTALL_OFEGSA}       ./config/Install_OFGESA.sh
${ncsnap_path}          ./config/fjt_4T4R_FDD_n1_n3_n75_v7.xml
${wts_cfg_file}         ./config/LTENR.cfg
${IPHY_FILE}            ./config/LTENR.xml
&{WTS}                  Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}              /opt/iphy/latest

*** Test Cases ***
 CB012647_NR_FDD_10cells
	 Wait Until Keyword Succeeds    10min    60s    CB012647_Keywords.Check_BTS_is_OnAir
	 Check Active Fault
	 UE attach and L3 Call on each cell
