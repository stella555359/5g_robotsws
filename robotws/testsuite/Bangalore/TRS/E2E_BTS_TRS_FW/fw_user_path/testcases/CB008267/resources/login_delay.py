import pexpect
import time


def delay_verify(timer: int) -> int:
    d = pexpect.spawn("ssh toor4nsn@192.168.255.129")
    d.expect('Password:')
    d.sendline("oPS0POrRieRtu\r")
    time.sleep(timer)
    d.expect('Password:')
    d.sendline("oZPS0POrRieRtu\r")
    d.expect('root@fct-0a:~ >')
    d.sendline('pwd\r')
    d.expect('/user/toor4nsn')
    d.sendline('exit')
    d.close()
