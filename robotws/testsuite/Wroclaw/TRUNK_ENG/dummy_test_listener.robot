*** Settings ***
Documentation    For testing taf.internal.robot.listener.logging_configurator
Library    taf.transport.ssh    WITH NAME    ssh
Library    OperatingSystem

Force Tags   RF50

*** Test Cases ***
Dummy SSH
    ssh.connect_to    hostname=10.16.92.168    username=ute    password=Wp9a)3X97M%R
    ssh.send_command     command=ls
    [Teardown]    List Directory 	/home/ute/testline_init_results/taf_agents_logs/
