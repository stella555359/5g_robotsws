from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
import paramiko


_tl = get_builtin_value(param_name="tl")


def chan_expect(chan, cmd, expect=':~ >', expect2=None, timeout=10):
    """
    Send a command on the channel and expect a specific output ending

    Parameters
    ----------
    chan : Paramiko.channel.Channel
        channel used to communicate
    cmd : string
        command to send
    expect : string
        string by which we expect the output to end
    expect2 : string
        optional string by which we expect the output to end as well
    display : boolean
        display the output on screen?
    timeout : int
        timeout value for all operations performed by the channel

    Returns
    -------
    string
        output of the command
    """
    chan.send(cmd + '\r\n')
    return chan_display(chan, expect, expect2, timeout)


def chan_display(chan, expect=':~ >', expect2=None, timeout=10):
    """
    Read the channel output and expect a specific output ending

    Parameters
    ----------
    chan : Paramiko.channel.Channel
        channel used to communicate
    cmd : string
        command to send
    expect : string
        string by which we expect the output to end
    expect2 : string
        optional string by which we expect the output to end as well
    timeout : int
        timeout value for all operations performed by the channel

    Returns
    -------
    string
        output of the command
    boolean
        True if the 2nd expect was found
    """
    buff = ''
    chan.timeout = timeout
    if expect2 is None:
        expect2 = expect
    while not buff.endswith(expect) and not buff.endswith(expect2):
        resp = chan.recv(9999)
        buff += resp.decode('utf-8')
    return buff, buff.endswith(expect2)


def set_ovlthreshold_to_specific_value(ovl_threshold):
    """
    Set overload threshold value on container to specific value expected during the test

    Parameters
    ----------
    ovl_threshold : int
        value of expected overload threshold we want to set during the test
    """
    cpln_ovl_cmd = "LD_LIBRARY_PATH=./opt/nokia/lib64/ ./opt/nokia/SS_CPLANE/bin/set_overload_high_threshold " \
                   "--overload_high_threshold {} --port 30671".format(ovl_threshold)
    gNB = paramiko.SSHClient()
    ssh_username = _tl.gnbs[0].cu.oam_ssh_connection_details.username
    ssh_password = _tl.gnbs[0].cu.oam_ssh_connection_details.password
    ssh_ip = _tl.gnbs[0].cu.oam_ssh_connection_details.addr
    gNB.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    gNB.connect(ssh_ip, username=ssh_username, password=ssh_password)
    gNB_tunnel_ABIL = gNB.get_transport()
    dest_addr = ('asp-5a', 22)
    local_addr = (ssh_ip, 22)
    ABIL_redirect = gNB_tunnel_ABIL.open_channel("direct-tcpip", dest_addr, local_addr)
    ABIL = paramiko.SSHClient()
    ABIL.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ABIL.connect('fsp-1-1a', username=ssh_username, password=ssh_password, sock=ABIL_redirect)

    ABIL_lxc_container = ABIL.invoke_shell()
    cmd_out1 = chan_expect(chan=ABIL_lxc_container, cmd="lxc-attach --name 0x2731", expect='CPUE20:~ >')
    BuiltIn().log(cmd_out1)
    cmd_out1 = chan_expect(chan=ABIL_lxc_container, cmd="cd /", expect='CPUE20:/ >')
    BuiltIn().log(cmd_out1)
    cpln_ovl_cmd_output = chan_expect(chan=ABIL_lxc_container, cmd=cpln_ovl_cmd, expect='CPUE20:/ >', timeout=30)
    BuiltIn().log(cpln_ovl_cmd_output)

    assert "No such file or directory" not in str(cpln_ovl_cmd_output), "Script is not avaliable on ABIL !"
    assert "Sent request to change overload high threshold" in str(cpln_ovl_cmd_output), "Change request not send !"
    assert "Overload high threshold changed" in str(cpln_ovl_cmd_output), "Script execution failed !"
    ABIL.close()
    gNB.close()
