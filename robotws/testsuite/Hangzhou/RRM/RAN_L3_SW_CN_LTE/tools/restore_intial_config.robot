*** Settings ***
Library  taf.ul.ue.sim.env_setup

*** Variables ***

*** Test Cases ***
setup BTS
    Add Simulator    cus    /home/ute/config/coco.yaml
    Add Enb Configuration    /home/ute/config/TL1_1.0_SBTS23R2_GOLDEN.xml
    Configure Environment

*** Keywords ***
