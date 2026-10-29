*** Settings ***
Resource    ./../common_setup_teardown.robot
Documentation
...    usage 1:mybot -v airphone_v:4.0 -v username:yuema update_airphone.robot
...    usage 2:mybot -v airphone_v:4.0.28042 -v username:yuema update_airphone.robot
*** Variables ***
${AP_url}    https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/
${package_dir}    /home/ute/output/builds/
${airphone_v}    4.0.28120
#${airphone_v}    4.0
${username}     ute
${log_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CB009855/myconfigs_IWF/
${test_repo_python}    /home/ute/.pyenv/versions/3.9.14/envs/test_repo/bin/python
*** Test Cases ***
Test Case Update Airphone
    ${log_path}=    Get Current Testline Config Files For AP    ${OUTPUT_DIR}/myconfigs/
    Update YAFT
    ${airphone_build}=    Get Latest Package    ${airphone_v}
    Update_WTS    ${airphone_build}
    Update Airphone    ${airphone_build}
    Check AP SSH Connect OK
    Modify IPHY File And Send to Airphone    ${log_path}/iphy.xml
    Send Swconfig File To Airphone    ${log_path}/swconfig.txt


*** Keywords ***
Get Latest Package
    [Arguments]    ${airphone_v}=4.0
    log to console    test:input password1
#    ${cmd}=    Set Variable    curl -u ${username} ${AP_url}|grep 'Enter host password for user'
#    ${airphone_v}=    Run    ${cmd}
    #there are "Enter host password for user '*':" if cmd followed 'with |grep'
    ${cmd}=    catenate    curl -u ${username} ${AP_url}|grep
    ...    '>${airphone_v}'|sort -r|sed -n '1p'|grep -Eo '4.[[:digit:]]{1}.[[:digit:]]{5}'|awk 'NR==1'
    ${airphone_v}=    Run    ${cmd}
    Log To Console    \ndownloaded airphone_bulid is:${airphone_v}
    should not be empty    ${airphone_v}
    [Return]    ${airphone_v}

Update_WTS
    [Arguments]    ${airphone_v}
    #${airphone_version}=    Get Airphone Software Version
    #${v}=    split string    ${airphone_version}    _
    #${airphone_v}=    set variable    ${v[2][-1]}.${v[3][-1]}.${v[4][1:]}    #4.0.20393
    ${airphone_url}=    set variable    ${AP_url}${airphone_v}/
    Run    sudo rm -rf /opt/wts/*; sudo rm -rf /opt/iphy/
    Run    sudo mkdir -p /opt/wts/${airphone_v}/; sudo mkdir /opt/iphy/
    Run    cd ${package_dir};sudo rm -rf esimmode_*;sudo rm -rf esimmode_*;rm -rf AirScale-*;
    #wait for "Password for user ‘yuema’"
    ${cmd}=    Catenate    sudo wget --user=${username} --ask-password -P ${package_dir} -r -np -nd --accept=*_sandybridge.tar.bz2
    ...    --accept=AirScale-*.zip ${airphone_url}|grep 'Password for user'
    Log To Console    ${cmd}
    Run    ${cmd}
    Log To Console    download wts and airphone completed.
#    ${cmd}=    Catenate    sudo wget --user=${username} --ask-password -P ${package_dir} -r -np -nd --accept=AirScale-${airphone_v}.zip
#    ...    ${airphone_url}
#    Log To Console    ${cmd}
#    Run    ${cmd}
    Run    cd /opt/wts/${airphone_v}/; sudo cp ${package_dir}*_sandybridge.tar.bz2 ./;
    Run    cd /opt/wts/${airphone_v}/; sudo tar -jxvf *_sandybridge.tar.bz2;
    Run    cd /opt/wts/; sudo ln -s ${airphone_v} latest; cd /opt/iphy/; sudo ln -s /opt/wts/${airphone_v} /opt/iphy/latest
    Run    sudo chown ute /opt/iphy/; sudo chown ute /opt/wts/; sudo chown ute /opt/wts/${airphone_v};

Update YAFT
    Run    svn co https://svne1.access.nsn.com/isource/svnroot/BTS_T_YAFT/trunk /home/ute/BTS_T_YAFT --username ca_ute_test --password utetest

Update Airphone
    [Arguments]    ${airphone_version}
    log to console    start to yaft airphone...
    Run    cd /home/ute/BTS_T_YAFT; cp ${package_dir}AirScale-*.zip ./;
    Run    cd /home/ute/BTS_T_YAFT; ${test_repo_python} yaft.py -i 192.168.200.1 -z AirScale-${airphone_version}.zip

