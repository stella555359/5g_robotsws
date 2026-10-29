*** Settings ***
Documentation
...          Just an exemple about how to use Sherpa library

Resource             ../Setup.robot
Resource             ../Oam.robot
Resource             ../CallSetup.robot
Resource             ../Sherpa.robot

Suite Setup          Suite Setup
Suite Teardown       Suite Teardown

*** Test Cases ***

BasicSherpaTest
    [Documentation]        This example shows how to use the Sherpa.robot library to use sherpa in a
    ...                    test based on taf libraries last evolutions.
    ...                    This usage is implemented for UTE test lines only.
    ...                    Stand alone ones are supposed to continue using sherpa running in a docker container

    ###   A simple cell setup is performed in this example to have a minimum of traces   ###
    ###   More can be done of course, 4G and 5G connection, traffic, and so on           ###

    ############################################################################
    #########   IMPORTANT:  common traces must be activated on GNB!!   #########

    CallSetup.WTS Setup                          nbUe=1
    Sleep                                        4
    Sherpa.Activate Sherpa
    Sleep                                        4
    Sherpa.Deactivate Sherpa and Stop Collect
    Upload and decode sherpa pcap files          ${trace_dir}
