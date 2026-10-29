*** Settings ***
Resource          ../resources/KISS/robot/common_resource.robot
suite setup      common_suite_setup


*** Variables ***


*** Test Cases ***
test

     Find Match GNB swconfig Golden Files
     Find Match AP swconfig Golden Files
     Download Common Config Files From Private Server
     Download All Common Config Files From Golden Server
     Download Topology Config Files From gerrit