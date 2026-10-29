
import pexpect
import os
import taf.transport.ssh as ssh
from datetime import datetime


def upgrade_gnb_logs(cd_command, ex_command, pc_ip, pc_name, pc_pwd):
    expect_pc_login = pc_name + '@' + pc_ip
    expect_pc_login = expect_pc_login.strip()
    print(expect_pc_login)
    child = pexpect.spawn('ssh {}@{}'.format(pc_name, pc_ip))
    child.expect('password:')
    child.sendline('{}'.format(pc_pwd))
    child.expect('ute@')
    child.sendline(cd_command)
    child.expect('ute@gnb_logs')
    child.sendline(ex_command)
    ret = child.expect([pexpect.TIMEOUT, "Press 'y' in 5 seconds"])

    if ret == 0:
        print('[-] Error Connecting')

    elif ret == 1:
        child.sendline('y')
        child.expect([pexpect.TIMEOUT, 'Enter>'])
        child.sendline('\n')
        child.expect([pexpect.TIMEOUT, 'ute@'])
        print('upgrade logs finished')
