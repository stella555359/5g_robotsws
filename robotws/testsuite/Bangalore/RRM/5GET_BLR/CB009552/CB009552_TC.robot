*** Settings ***
Force Tags      CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G		SBTS00	    CONFIGURED

Documentation
...
...             author:B,Padmashree <padmashree.b@nokia.com>
...             maintainer:B,Padmashree <padmashree.b@nokia.com>        
...
...             TEST SET NAME:    CB009552
...             TESTING SPLIT:   cni-51355
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB009552 CFAM
...             Requirement ID:   

Resource            ./CB009552_resource.robot

*** Variables ***
${wts_cfg_file}     /opt/iphy/latest/basic_setup.cfg
${WTS_DIR}          /opt/iphy/latest/
${connection}       COAM
${ssh_passwd}       ute

*** Test Cases ***
[1][1.0] CB009552_E_CNI_51355_01_L2PS Triggred L1 IQ Snapshot for RLF Scenario
	[Setup]	Clear snapshot in home directory	
    Add Lss account
    Update Snapshot Configuration of LSS
    Update RAD Debug Parameter		scenario=rlf
    Sleep   60s
    Add Trigger Fault       faultnum=8101
    Update parameter for rlf
    Load CFG and verify cell status   ${wts_cfg_file}   1   1
    Activate_L1_IQ_capture
    wts_sim_keywords.UE Register should be Successful     ue_id=1     pdu_id=1     nw_id=1     gw_id=1
    Trigger RLF Command
    Wait Until Keyword succeeds      2min   10sec   Verify snapshot file is generated
    Verify Iq snapshot is collected	