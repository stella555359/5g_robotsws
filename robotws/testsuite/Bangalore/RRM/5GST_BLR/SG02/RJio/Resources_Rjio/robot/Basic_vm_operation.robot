*** Settings ***

Documentation    Author: arunkumar.a@nokia.com 
...    Only contain basic linux machine operation. like kill the proceess. etc..

Library    taf.transport.ssh    WITH NAME    csn
Resource    ../variables/Rjio_variables.robot

*** Keywords ***
clear vm pid before run case
    BuiltIn.Log To Console  clear vm pid before run case
    csn.Connect To   hostname=${vm_addr}  username=${vm_username}    password=${vm_password}     alias=test_pc
    Sleep    2s
    csn.Send Command  command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $2}' |sh    connection=test_pc
    Sleep    2s
    csn.Send Command  command=sudo ps -ef|grep firefox|grep -v grep|awk '{print "kill -9 " $3}' |sh   connection=test_pc
    Sleep    2s
    csn.Send Command  command=sudo ps -ef|grep btslog|grep -v grep|awk '{print "kill -9 " $2}' |sh  connection=test_pc
    Sleep    2s
    csn.Disconnect  connection=test_pc