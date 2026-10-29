*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    This is a upgrade SW case.
Resource    ../RRM_Common_Resource.robot
Force Tags    upgrade



*** Test Cases ***
Download SW
    ${latest_build_name}    Get SRAN latest build by wft link with promotion_tags    branch=${branch}
	...                                                                              target_dir=${target_dir}
	...                                                                              promotion_tags=${promotion_tags}
	Set test variable    ${latest_build_name}
	COAM_Admin.UpdateSW for SRAN    VM_IP=${VM_IP}
	...                             directory=${target_dir}


