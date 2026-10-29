*** Settings ***

Documentation
... 	[Procedure]				"The test case performs commissioning and verifies config of ssh Session Idle timer and
...                              login delay timer using WebEM."
...	    [Date]					"20-06-2023"
...	    [Author]				"Punith K"
...	    [Feature_ID] 			"CB008267"
... 	[Maintenance]			"TRS I & V Tools Bangalore Team"
...	    [Funtional_Hash_Tags] 	"SSH"
...	    [Validated_TestLine] 	"CLOUD_R4A_CUS"
...	    [Precondition] 			"BTS should be operational and configured state"
...	    [QC_Path]               "QC_Path in Test Plan"
...	    [QC_ID]					"QC_ID in Test Lab for reporting"



Library         ${CURDIR}/resources/login_delay.py
Resource        ${CURDIR}/resources/CB008267_common_keywords.robot

Suite Setup     Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown  Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops



*** Test Cases ***
CB008267-D_Operator Modifies SSH Session Idle Timer
    Change Ssh Access       enable=${True}   timeout=120
    SSH Login should Pass
    ${timer}   Evaluate   random.randrange(0,400)     random
    Perform Recommissioning     type=param  param_path=SECADM-1:sshSessionIdleTimer       operation=update    value=${timer}    timeout=200
    ${delay}   Evaluate    random.randrange(1,60)    random
    Perform Recommissioning     type=param  param_path=SECADM-1:sshSessionLoginDelayTimer       operation=update    value=${delay}    timeout=200
    Check Autologout with file open and data transfer   ${timer}
    login_delay.delay_verify    ${delay}
    Perform software upgrade
    Check Autologout with file open and data transfer   ${timer}
    login_delay.delay_verify    ${delay}
    ${timer1}   Evaluate    random.randrange(0,400)    random
    Perform Recommissioning     type=param  param_path=SECADM-1:sshSessionIdleTimer       operation=update    value=${timer1}    timeout=200
    ${delay1}   Evaluate    random.randrange(1,60)    random
    Perform Recommissioning     type=param  param_path=SECADM-1:sshSessionLoginDelayTimer       operation=update    value=${delay1}    timeout=200
    Reset Bts   verify_bts=True     req_rat=all     should_be_onair=False
    Sleep   120
    Check Autologout with file open and data transfer   ${timer1}
    login_delay.delay_verify    ${delay1}
    Perform Recommissioning     type=param  param_path=FEATCADM-1:actLoginCredPartitionSync       operation=update    enable=${True}    timeout=200
    Rollback Software   timeout=300
    Sleep   200
    Check Autologout with file open and data transfer   ${timer1}
    login_delay.delay_verify    ${delay1}
    Perform Recommissioning     type=param  param_path=SECADM-1:sshSessionIdleTimer       operation=update    value=0    timeout=200
    Perform Recommissioning     type=param  param_path=SECADM-1:sshSessionLoginDelayTimer       operation=update    value=1    timeout=200
    Changing idle timer fails due to Below range
    Changing idle timer fails due to out of range
    Changing delay timer fails due to Below range
    Changing delay timer fails due to out of range
