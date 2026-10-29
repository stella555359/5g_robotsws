*** Settings ***
Resource    ./../common_setup_teardown.robot
*** Variables ***
${url}    https://hzisoj70.china.nsn-net.net/artifactory/mnp5g-airphone-ci-gen-local/Airphone/
${username}     ute
*** Test Cases ***
Update_WTS
    ${airphone_version}=    Get Airphone Software Version
    ${v}=    split string    ${airphone_version}    _
    ${airphone_v}=    set variable    ${v[2][-1]}.${v[3][-1]}.${v[4][1:]}    #4.0.20393
    ${airphone_url}=    set variable    ${url}${airphone_v}/
    Run    sudo rm -rf /opt/wts/${airphone_v}/; sudo rm -rf /opt/iphy/
    Run    sudo mkdir -p /opt/wts/${airphone_v}/; sudo mkdir /opt/iphy/
    ${cmd}=    Catenate    sudo wget --user=${username} --ask-password -P /opt/wts/${airphone_v}/ -r -np -nd
    ...    --accept=_sandybridge.tar.bz2 ${airphone_url}|grep 'Password for user'
    Log To Console    ${cmd}
    Run    ${cmd}
    Run    cd /opt/wts/${airphone_v}/; sudo tar -jxvf *_sandybridge.tar.bz2;
    Run    cd /opt/wts/; sudo ln -s ${airphone_v} latest; cd /opt/iphy/; sudo ln -s /opt/wts/${airphone_v} /opt/iphy/latest
    Run    sudo chown ute /opt/iphy/; sudo chown ute /opt/wts/; sudo chown ute /opt/wts/${airphone_v};

