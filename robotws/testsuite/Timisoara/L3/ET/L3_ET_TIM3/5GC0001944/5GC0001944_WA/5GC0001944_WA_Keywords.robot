*** Settings ***

Resource     ../../resources/5G_SW_WRO_Keywords.robot
Library      ta5g_enb
Library      ta5g_egate

*** Keywords ***
Bring Up Sctp On Ng Interface
    Run Keyword And Ignore Error    Execute Enb Command    cmd=ifconfig fp0 up
    Run Keyword And Ignore Error    Execute Enb Command    cmd=ifconfig br1 up
