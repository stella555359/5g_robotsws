*** Settings ***

Documentation    Script for CB011098 TDD cell set feature
...   author: veena.bhaskaran@nokia.com
...   Description: Configuration of 6 NR FR1 TDD cells with 4T4R and basic OAM operations.

Library     	Process
Library     	DateTime
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Variables        ta5g_global_var
Resource		 ./testsuite/Bangalore/resources/robot/Airphone.robot
Resource		 ./testsuite/Bangalore/resources/robot/WTS_Runner_Keywords.robot
Resource    	 ./resources/CB011098_Keywords.robot
Resource     		taf/rfrl/common_resources/common_step/interface.robot

Suite Setup			Run keywords       Admin_Connection
...					AND     load ncsnapshot     ${ncsnap_path}
...                 AND     Configure Netconf Credentials
...                 AND     Sleep    30s
...                 AND     load iphyfile
...		    AND     Sleep    60s
...                 AND     Start WTS Using WTS_Runner     ${wts_cfg_file}
...		    AND     Sleep    60s
...         AND     X2AP Link Should be UP
...			AND		Suite Setup Local
...         AND     Alarm monitoring


Suite Teardown		Suite_Teardown
Test Teardown       CB011098_Keywords.Test Teardown
Force Tags      	QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${INSTALL_AWHQN}       ${CURDIR}/config/Install_AWHQN.sh
${ncsnap_path}          ${CURDIR}/config/NC1.xml
${wts_cfg_file}         ${CURDIR}/config/AWHQN_6cell.cfg
${IPHY_FILE}            ${CURDIR}/config/6NC.xml
&{WTS}                  Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}              /opt/iphy/latest


*** Test Cases ***
CB011098_ABIP_cell_set_NR_TDD_cells
	Wait Until Keyword Succeeds    5min    60s    Check BTS is OnAir
	Check Active Fault
	UE attach and L3 Call on each cell
	Block_cell operation
    RMOD Reset operation
    BBMOD reset operation
    Site reset operation
