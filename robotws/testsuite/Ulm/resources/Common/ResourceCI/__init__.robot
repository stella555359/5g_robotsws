*** Settings ***

Documentation
...   This robot resource file holds a generic Suite Setup for ResourceCI.
...   It will be automatically executed by robot if robot is lauched with path to ResourceCI/!

Resource    ../ute_workarounds.robot
Resource    ../bsr_package_installation.robot
Resource    ../gnb.robot
Resource    ../wts_ue.robot

Suite Setup   Prepare Test Build Over ResourceCI Folder


*** Keywords ***
Prepare Test Build Over ResourceCI Folder
    ute_workarounds.UTE Cloud Workaround
    bsr_package_installation.Install All BSR Packages Found In SCF
    ...   force_zip=BSR_AQQJ_6_H6_ALN45_ARP45_P00_COVERAGE_00423_00001_CB010471

    TRY
        ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
        LOG   ResourceCI initialization: 'Bring Airphone TL To On Air Status Without Reboot' passed!   INFO
    EXCEPT
        Log   ResourceCI initialization: 'Bring Airphone TL To On Air Status Without Reboot' failed!   ERROR
        ute_workarounds.Bring Airphone TL To On Air Status
    END

    gnb.Get SCF from gNB
    wts_ue.Store Current WTS Config
