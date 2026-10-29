*** Settings ***
Documentation
...   This is a test suite to temporarily check the taf.ul.sbts.pmi_ticket_collector

Library    OperatingSystem
Resource   ../wts_ue.robot
Resource   ../testline.robot
Resource   ../ute_workarounds.robot
Library    taf.ul.sbts.pmi_ticket_collector
Library    ../python/ArgvKeywords.py

Suite Setup     Prepare Precondition


*** Test Cases ***
Check The PMI Ticket Collector
    [TAGS]   PMI


    taf.ul.sbts.pmi_ticket_collector.Prepare PMI Tickets Config

    taf.ul.sbts.pmi_ticket_collector.Start Collecting PMI Tickets

    wts_ue.UE Register   ue_id=1
    Sleep   5s
    wts_ue.UE Deregister  ue_id=1

    taf.ul.sbts.pmi_ticket_collector.Stop Collecting PMI Tickets

    ${pmi_tickets}    taf.ul.sbts.pmi_ticket_collector.Get All PMI Tickets

    Run Keyword And Ignore Error   Should Not Be Empty   ${pmi_tickets}


*** Keywords ***
Prepare Precondition
    Log   Provide a WA for taf.ul.sbts.pmi_ticket_collector expecting hard coded path to TL __init__.py  console=${True}
    ${varfile}   ArgvKeywords.Get Absolute Variable File Path From CLI
    IF   $varfile is None   FAIL   Cannot find robot command line argument -V or --variablefile!
    ${tl_name}   testline.Get Testline Name
    OperatingSystem.Run   mkdir -p /home/ute/testline_configuration/${tl_name}
    OperatingSystem.Run   ln -s ${varfile}/__init__.py /home/ute/testline_configuration/${tl_name}/__init__.py
    ute_workarounds.UTE Cloud Workaround
    Bring Airphone To On Air Status

    # Remove old host key to avoid SSH issues
    OperatingSystem.Run     ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.129"

Bring Airphone To On Air Status
    TRY
        ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    EXCEPT
        ute_workarounds.Bring Airphone TL To On Air Status
    END
