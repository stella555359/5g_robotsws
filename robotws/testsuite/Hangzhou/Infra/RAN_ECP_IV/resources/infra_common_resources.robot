*** Settings ***
Documentation    This is common libraries for robot.
...              Author: jacky.zhu@nokia-sbell.com
...              Squard: CP HZ 3

Library           OperatingSystem
Library           String
Library           SSHLibrary    WITH NAME    SSH
Library           python/local_cmd.py
Library           python/neatOps.py
Library           python/ocpOps.py
Resource          infra_common_setup_teardwon.robot
