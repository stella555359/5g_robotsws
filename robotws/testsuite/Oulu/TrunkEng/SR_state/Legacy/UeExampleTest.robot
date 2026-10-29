*** Settings ***
Documentation
...   author: Ilkka Pinola
...   contact: ilkka.pinola@nokia.com
...   The purpose of this test is to verify that UEs work on 5G TLs

Force Tags      CLOUD_FR4K_R_L_[2]_[AEQN]_[UE]   SkipRun

Library         ute_ue

Suite Setup     Uc Suite Setup
Test Setup      Uc Test Case Setup
Test Teardown   Uc Test Case Teardown
*** Variables ***
${CELL_ID}=   5447171  # Example
&{DOMAIN_CAPABILITIES}=   device_name=ue  model=k55v1_64_om_nokia_mp3md  # Example

*** Test Cases ***
DL Data Transfer With Duration
    Start Data Transfer  TRANSFER_DL  EXAMPLE_UE  duration=20s  direction=dl
    Await Data Transfer Finish  TRANSFER_DL
    Verify Average Throughput  TRANSFER_DL  1 Mbits/sec

DL Data Transfer
    Start Data Transfer  TRANSFER_DL  EXAMPLE_UE  direction=dl
    Sleep  20s  sleeping 20s ...
    Stop Data Transfer  TRANSFER_DL
    Verify Average Throughput  TRANSFER_DL  1 Mbits/sec

UL Data Transfer
    Start Data Transfer  TRANSFER_UL  EXAMPLE_UE  direction=ul
    Sleep  20s  sleeping 20s ...
    Stop Data Transfer  TRANSFER_UL
    Verify Average Throughput  TRANSFER_UL  1 Mbits/sec


*** Keywords ***
Uc Suite Setup
    Require Ue  EXAMPLE_UE  REALUE  # Ute ue capabilities is required so we give just any string which is later ignored
    # Require Ue  EXAMPLE_UE  ${DOMAIN_CAPABILITIES}  # Capabilities in dictionary format (dict format example above)
    # Require Ue  EXAMPLE_UE  starting_cell=${CELL_ID}  # Specify cell id in which UE must be
    # Require Ue  EXAMPLE_UE  ${DOMAIN_CAPABILITIES}  starting_cell=${CELL_ID}  # Both capabilities and starting cell

Uc Test Case Setup
    Attach Ue  EXAMPLE_UE

Uc Test Case Teardown
    Detach Ue  EXAMPLE_UE
