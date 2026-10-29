*** Settings ***
Resource    CB013554_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
CB013554-B-B1_ENDC_Specific_Counters_To_Calculate_The_DL_And_UL_ENDC_Split_Ratio
    Attach Ue With Sgnb
    Start Data Traffic In Dl And Ul
    Display Bearer Stats
    Detach Ue    ue_id=11
    Check Tput X2 Counters For Dl And Ul
    Enable Data Split Mode Over F1
    Attach Ue With Sgnb
    Start Data Traffic In Dl And Ul
    Display Bearer Stats
    Detach Ue    ue_id=11
    Check Tput F1 Counters For Dl And Ul

Start Data Traffic In Dl And Ul
    Start Data Traffic  ues=11   bearer_id=2    direction=dl    throughput=60mbps
    Start Data Traffic  ues=11    bearer_id=2    direction=ul    throughput=30mbps
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}

Display Bearer Stats
    Execute Egate Command And Wait For Data   cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=all
    Execute Egate Command And Wait For Data   cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=all

