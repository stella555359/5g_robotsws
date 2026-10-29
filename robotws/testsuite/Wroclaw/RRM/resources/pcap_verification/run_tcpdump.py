import subprocess
from taf.transport.ssh import ssh
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture


tcpdump_command = 'tcpdump -G {timeout} -W 1 sctp -i any -l -w - 2>/dev/null'


def start_tcpdump(local_filepath=None, timeout=10):
    filepath = local_filepath if local_filepath else fixture.get_default_pcap_filepath()
    if fixture.is_classical_testline:
        start_tcpdump_on_classical(filepath, timeout)
    else:
        start_tcpdump_on_cloud(filepath, timeout)


def stop_tcpdump():
    stop_tcpdump_on_classical() if fixture.is_classical_testline else stop_tcpdump_on_cloud()


def start_tcpdump_on_classical(local_filepath, timeout=10):
    start_tshark_on_remote_and_save_dump_on_local_machine(
        local_filepath,
        fixture.classical_asik_ip_address,
        fixture.asik_username,
        fixture.asik_password,
        timeout_in_min=timeout)


def stop_tcpdump_on_classical():
    asik = ssh()
    asik.connect_to(
        hostname=fixture.classical_asik_ip_address,
        username=fixture.asik_username,
        password=fixture.asik_password,
        timeout=120.0)
    asik.execute(command="killall tcpdump")
    asik.disconnect()
    subprocess.call("sudo pkill tshark", shell=True)


def start_tcpdump_on_cloud(local_filepath, timeout=10):
    start_trace_on_bridged_connection_and_save_dump_on_local_machine(
        local_filepath=local_filepath,
        bridge_ip_address=fixture.get_oam_ip(),
        bridge_login=fixture.get_oam_user(),
        bridge_password=fixture.get_oam_pass(),
        destination_ip_address='cpif-0.local',
        destination_login=fixture.get_oam_user(),
        timeout_in_min=timeout)


def stop_tcpdump_on_cloud():
    stop_trace_on_bridged_connection(
        bridge_ip_address=fixture.get_oam_ip(),
        bridge_login=fixture.get_oam_user(),
        bridge_password=fixture.get_oam_pass(),
        destination_ip_address='cpif-0.local',
        destination_login=fixture.get_oam_user())


def start_trace_on_bridged_connection_and_save_dump_on_local_machine(local_filepath, bridge_ip_address,
                                                                     bridge_login, bridge_password,
                                                                     destination_ip_address, destination_login,
                                                                     timeout_in_min=10):
    """
    Starts tcpdump on remote machine connected via ssh from other machine, logs are saved on local machine.
    Warning: Remember to stop tcpdump command on that remote machine!
    """
    subprocess.call('sudo rm {filepath}'.format(filepath=local_filepath), shell=True)
    command = 'sudo touch {filepath} && sudo chmod o=rw {filepath}'.format(filepath=local_filepath)
    print(command)
    subprocess.call(command, shell=True)

    __send_tcpdump_command(__bridged_connection_assembler(bridge_ip_address=bridge_ip_address,
                                                          bridge_login=bridge_login,
                                                          bridge_password=bridge_password,
                                                          destination_ip_address=destination_ip_address,
                                                          destination_login=destination_login),
                           local_filepath, timeout_in_min, with_sudo=True)


def start_tshark_on_remote_and_save_dump_on_local_machine(local_filepath,
                                                          ip_address_to_remote_machine,
                                                          login_to_remote_machine,
                                                          password_to_remote_machine,
                                                          timeout_in_min=10):
    """
    Starts tcpdump on remote machine connected via ssh, logs are saved on local machine.
    Warning: Remember to stop tcpdump command on remote machine!
    """
    subprocess.call('rm {filepath}'.format(filepath=local_filepath), shell=True)
    subprocess.call("touch {filepath} && chmod o=rw {filepath}".format(filepath=local_filepath), shell=True)
    ssh_connection_command = "sshpass -p \'{password}\' ssh -T -q {login}@{ip_address}".format(
        ip_address=ip_address_to_remote_machine,
        login=login_to_remote_machine,
        password=password_to_remote_machine)
    __send_tcpdump_command(ssh_connection_command, local_filepath, timeout_in_min)


def stop_trace_on_bridged_connection(bridge_ip_address, bridge_login, bridge_password,
                                     destination_ip_address, destination_login):
    ssh_connection = __bridged_connection_assembler(bridge_ip_address=bridge_ip_address,
                                                    bridge_login=bridge_login,
                                                    bridge_password=bridge_password,
                                                    destination_ip_address=destination_ip_address,
                                                    destination_login=destination_login)
    assembled_command = '{} sudo killall tcpdump | sudo killall tcpdump && sudo pkill tshark'.format(ssh_connection)
    print(assembled_command)
    subprocess.call(assembled_command, shell=True)


def __bridged_connection_assembler(bridge_ip_address, bridge_login, bridge_password,
                                   destination_ip_address, destination_login):
    bridge_ssh = 'sshpass -p \'{bridge_password}\' ssh -T -q ' \
                 '{bridge_login}@{bridge_ip_address}'.format(bridge_ip_address=bridge_ip_address,
                                                             bridge_login=bridge_login,
                                                             bridge_password=bridge_password)

    destination_ssh = 'ssh -T {destination_login}@{dest_ip_addr}'.format(destination_login=destination_login,
                                                                         dest_ip_addr=destination_ip_address)

    return '{bridge_ssh} {destination_ssh}'.format(bridge_ssh=bridge_ssh, destination_ssh=destination_ssh)


def __send_tcpdump_command(ssh_connection_command, local_filepath, timeout, with_sudo=False):
    sudo_s_cmd = 'sudo -S '
    sudo_cmd = 'sudo '
    tshark_command = 'tshark -i - -w {filepath} &>/dev/null &'.format(filepath=local_filepath)
    assembled_command = "{ssh} {sudoS}{tcpdump} | {sudo}{tshark}".format(
        ssh=ssh_connection_command,
        sudoS=sudo_s_cmd if with_sudo else '',
        tcpdump=tcpdump_command.format(timeout=timeout * 60),
        sudo=sudo_cmd if with_sudo else '',
        tshark=tshark_command)
    print(assembled_command)
    subprocess.call(assembled_command, shell=True)
