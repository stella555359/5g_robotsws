*** Settings ***

Force Tags    CLOUD_F    FL00    CRT


#variables	 ta_e2e_bts_trs_fw
Resource  	taf/rfrl/trs_e2e_fw/setup/framework.robot



*** Test Cases ***
Test FW KWs
	Run Keyword And Ignore Error    Setup Oamops
	Sleep  5
	Run Keyword And Ignore Error    Teardown Oamops
