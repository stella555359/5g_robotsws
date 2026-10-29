*** Settings ***
Resource    CB013206_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s

*** Keywords ***
CB013206-C_Abnorm_Sgnb_Insession_Release_Non_Pmqap
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start Dl And Ul Data Traffic And Display Bearer Stats
    Perform Abnormal Releases Initiated By Sgnb
    Check In Session Status    status=True
    Check Pm Counters For Abnormal Releases Initiated By Sgnb
    Detach Ue    ue_id=11
