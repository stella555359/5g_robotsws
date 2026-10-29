*** Settings ***
Documentation
...   Keywords used for 5GC000955-B feature
...
...   author: kasper.biegun@nokia.com
...   maintainer: kasper.biegun@nokia.com

Resource    ../../../../OAM/ET/BTS_OAM_FMRECOV/5GC000955-A/resources/5GC000955-A-a.robot
Resource    override_keywords.robot
Resource    keywords.robot
Resource    robot_utilities.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Library     ${CURDIR}/modify_json_files.py   WITH NAME   modify_json_files
