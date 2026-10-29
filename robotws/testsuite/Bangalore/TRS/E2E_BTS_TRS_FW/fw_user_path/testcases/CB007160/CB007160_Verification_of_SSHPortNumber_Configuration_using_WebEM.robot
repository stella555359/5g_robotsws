*** Settings ***

Documentation
... 	[Procedure]				"The test case performs commissioning and verifies config of SSH port number using WebEM. Firewall rules also verified."
...	    [Date]					"26-10-2022"
...	    [Author]				"Punith"
...	    [Feature_ID] 			"CB007160"
... 	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	    [Funtion_Hash_Tags] 	"E2LINK_RIC"
...	    [Validated_TestLine] 	"CLOUD_5G - ASIB, ASIL, ASIK, ASIM, ASOE topologies"
...	    [Precondition] 			"BTS should be operational and configured state"
...	    [QC_Path]               "QC_Path in Test Plan"
...	    [QC_ID]					"QC_ID in Test Lab for reporting"

Force Tags          CA_E2ET_BTSTRSPZ        SBTS00        SBTS23R1      RAN_4G    RAN_4G_FDD      QCD_MN_RAN        QCP_RAN_ET        CRT

Variables       ta_e2e_bts_trs_fw
Resource         ${CURDIR}/../resources/common_keywords.robot
Resource         ${CURDIR}/resources/7160.robot

Suite Setup             Run Keywords    Suite Setup Preconditions
...             AND             Setup Oamops
Suite Teardown     Run Keywords         Suite Teardown Postconditions
...             AND             Teardown Oamops


*** Test Cases ***
[1][1.0] CB007160_Verification_of_SSHPortNumber_Configuration_using_WebEM
    Change Ssh Access       enable=${True}   timeout=120
#Step1: Changing SSH ports &  verifing firewall rules
    ${PORT}   Evaluate    random.randrange(19000,19999)    random
    Verify firewall rules with changing port   ${PORT}
#Step2: Checking SSH Login with SOE behaviour
    Change Ethernet port security       enable=${True}   timeout=120
    Verify firewall rules   ${PORT}
    ${PORT}   Evaluate    random.randrange(19000,19999)    random
    Verify firewall rules with changing port        ${PORT}
    Change Ethernet port security       enable=${False}   timeout=120
    Verify firewall rules   ${PORT}
#Step3: Reboot and checking persistency
    Reset Bts   verify_bts=True     req_rat=all     should_be_onair=False
    Sleep   120
    Verify firewall rules   ${PORT}

#Step4: Upgrade Softwre and checking persistency

    Perform software upgrade   ${PORT}
    Verify firewall rules   ${PORT}
    ${PORT_1}  Evaluate    random.randrange(19000,19999)    random
    Verify firewall rules with changing port  ${PORT_1}
#Step5: Rollback software  and checking persistency
    Rollback Software   timeout=300
    Sleep   200
    ${sync_param}  Get parameter  param_path=FEATCADM-1:actLoginCredPartitionSync
    Run Keyword If  ${sync_param}==${True}       Verify firewall rules   ${PORT_1}       ELSE      Verify firewall rules   ${PORT}
#Step5: SSH login with Default port
    Deleting SSH port number
    SSH Login should Pass
#Step6: Negative Scenerios
    Change Ssh Access       enable=${False}   timeout=120
    #SSH Login should fail
    Change Ssh Access       enable=${True}   timeout=120
    SSH Login should Pass
###### Invalid SSH Port Number#########
    Changing SSH port number fails due to Below range
    Changing SSH port number fails due to out of range
