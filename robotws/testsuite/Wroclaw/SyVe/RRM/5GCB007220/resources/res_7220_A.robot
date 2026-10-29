*** Settings ***
Documentation
...  UL and DL for feature 722
...
...  author/contact: krzysztof.1.wrobel@nokia.com


Library         OperatingSystem
Library         ute_ue
Library         testsuite.Wroclaw.SyVe.RRM.features.Res7220And7134    5GCB007220


*** Keywords ***
Create connection to gNB and eNB SA
    Start Syslog Collection

Disconnect from gNB and eNB SA
    Stop Syslog Collection
    Collect Bts Gnb Snapshot
    Ue Detach

Prepare gNB
    [Arguments]  ${modulation_qam}  ${sansa}
    Find Scf And Commission Gnb  100MHzTDD  ${modulation_qam}  ${sansa}
    Wait Until Gnb Reach Onair State
    Reboot Ue Askey
    Check If Acsi Are Enabled In Cells

