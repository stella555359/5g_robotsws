import re
import time
import SSHLibrary
from taf.transport.ssh import ssh


def change_cell_operationalState_via_rmod(rmod_ip, rmod_type, operationalState='degraded',
                                          password='5rfS2qmWC0AiFYvir7k8JekCN8/NklqDK5E6OWXuUVQ='):
    assert operationalState in ('enabled', 'degraded'), "operationalState should be 'enabled'/'degraded'"
    c = SSHLibrary.SSHLibrary()
    cmd_download_json = "/usr/bin/dapd -duc dpdmade_dlpath1.json"
    cmd_upload_json = "/usr/bin/dapd -ciuc /var/tmp/dpdmade_dlpath1.json"
    degraded_str = '0.0000001'
    enabled_str = '0.1'
    dMonDpdMseLimi_position = '98,98'
    assert_msg_1 = '[ERROR]dMonDpdMseLimi[position:{}] is already {}'.format(dMonDpdMseLimi_position, degraded_str)
    assert_msg_2 = '[ERROR]dMonDpdMseLimi[position:{}] is already {}'.format(dMonDpdMseLimi_position, enabled_str)
    if operationalState.lower() == 'degraded':
        cmd_change_json = "sed -i '{}s/{}/{}/g' /var/tmp/dpdmade_dlpath1.json"\
            .format(dMonDpdMseLimi_position, enabled_str, degraded_str)
    else:
        cmd_change_json = "sed -i '{}s/{}/{}/g' /var/tmp/dpdmade_dlpath1.json"\
            .format(dMonDpdMseLimi_position, degraded_str, enabled_str)
    cmd_check_json = 'grep -A 3 -e dMonDpdMseLimit /var/tmp/dpdmade_dlpath1.json'
    command_sq = "/usr/bin/dapd -sq"
    try:
        c.open_connection('192.168.255.1')
        output = c.login('toor4nsn', 'oZPS0POrRieRtu')
        print('login successfully\n' + output)
        if "password" in output:
            c.write('oZPS0POrRieRtu')
            print('enter password successfully')
        else:
            c.write("rm /user/toor4nsn/.ssh/known_hosts")
            x = c.execute_command("cat /rom/config/FRIps.txt")
            print(x)
            c.write('lxc-attach -n 0x1018')
            output = c.read(delay=2)
            print('lxc attach successfully\n' + output)
        if rmod_type in ['AZQP', 'AZHL']:
            c.write('ssh rfsw@{}'.format(rmod_ip))
            time.sleep(5)
            # output = c.read_until_regexp('fingerprint')
            c.write('yes')
            time.sleep(5)
            output = c.read_until_regexp('password:')
            if "password:" in output:
                print('[1]login rmod[{}][rfsw@{}] ... ...\n'.format(rmod_type, rmod_ip) + output)
                c.write(password)
                time.sleep(5)
            else:
                print('[2]login rmod[{}][root@{}] ... ...\n'.format(rmod_type, rmod_ip) + output)
                c.write("ssh root@{}".format(rmod_ip))
            output = c.read_until_regexp('azqp')
            print('[1]login rmod[{}][{}] successfully'.format(rmod_type, rmod_ip))
            for ip in ['192.168.101.2']:
                c.write("ssh {}".format(ip))
                time.sleep(5)
                print('login made#{} successfully'.format(ip))
                c.set_client_configuration(prompt="#")

                # Download [dpdmade_dlpath1.json] on made#1 of rmod
                c.write(cmd_download_json)
                time.sleep(5)
                download_json = c.read_until_regexp('File decoding finished')
                c.write(cmd_check_json)
                check_json = c.read_until_regexp(']')
                check_tmp = check_json.replace(' ', '').replace('\r', '').split('\n')[-2]
                print('\nBefore change "dMonDpdMseLimi" ... ...\n' + check_json)
                if operationalState.lower() == 'degraded':
                    assert check_tmp != degraded_str, assert_msg_1
                else:
                    assert check_tmp != enabled_str, assert_msg_2
                c.write(cmd_change_json)
                c.write(cmd_check_json)
                check_json = c.read_until_regexp(']')
                print('After change "dMonDpdMseLimi" ... ...\n' + check_json)

                # Upload [dpdmade_dlpath1.json] on made#1 of rmod
                c.write(cmd_upload_json)
                time.sleep(5)
                upload_json = c.read_until_regexp('dpdmade_dlpath1.json')
                print('Uploaded json [dpdmade_dlpath1.json]\n' + upload_json)
                c.write("exit")
                c.write("exit")
                c.write("exit")
    except AssertionError as e:
        return e
    except Exception as e:
        print(e)
        raise e
    finally:
        c.close_connection()
