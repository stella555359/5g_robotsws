*** Settings ***
Documentation
...     This is a test suite used for testing the resoruces in the
...     SyVe resource folder, checking the hanging_resources.robot

Resource    ../../../SyVe/resources/hanging_resources.robot
Resource   ../testline.robot
Resource   ../connect.robot
Resource   ../wts_ue.robot
Resource   ../ute_workarounds.robot

Suite Setup   Prepare Testline For Test Case

*** Test Cases ***
Check The Hanging Resouces
    Get Resources Before Test For All Nodes

    wts_ue.Ue Register
    Sleep   30s
    wts_ue.Ue Deregister


    Get Resources After Test For All Nodes

    Verify Resource Usage For All Nodes


*** Keywords ***
Prepare Testline For Test Case
    UTE Cloud Workaround
    Bring Airphone To On Air Status


Bring Airphone To On Air Status
    TRY
        ute_workarounds.Bring Airphone TL To On Air Status Without Reboot
    EXCEPT
        ute_workarounds.Bring Airphone TL To On Air Status
    END
