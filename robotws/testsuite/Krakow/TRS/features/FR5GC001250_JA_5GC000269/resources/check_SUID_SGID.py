from taf.transport.ssh import interface
ssh = interface.ssh()

exeptions_exe_proc_cu = ["/usr/bin/passwd", "/usr/bin/sudo", "/usr/libexec/ssh-keysign",
                         "/usr/libexec/lxc/lxc-user-nic", "/opt/nokia/bin/fileoperations_peer",
                         "/opt/nokia/sbin/fsuidsetter", "/opt/nokia/user_sync/chsh", "/opt/nokia/user_sync/chage",
                         "/opt/nokia/user_sync/chfn", "/opt/nokia/user_sync/gpasswd",
                         "/opt/nokia/SS_SCLI/sbin/sftp-wrapper", "/opt/nokia/SS_SCLI/script/ssh_for_scli",
                         "/opt/nokia/SS_SCLI/bin/wrapper", "/usr/bin/pwauth", "/opt/nokia/bin/fpHTTPauthenticator",
                         "/opt/nokia/bin/fpGUIauthenticator", "/opt/nokia/SS_LimBash/bin/bash",
                         "/usr/sbin/netreport", "/usr/sbin/unix_chkpwd", "/usr/bin/crontab", "/usr/bin/su",
                         "CCSMCUDaemonExe", "dbus-daemon-launch-helper", "/opt/nokia/SS_RCPCCSRT/CCSRTDaemonExe",
                         "/opt/nokia/SS_RCPCCSRT/CCSEmDispatcherExe", "rcpmsgdispatcher", "/usr/bin/gpasswd",
                         "/usr/bin/chsh", "/usr/bin/chage", "usr/bin/chfn", "/usr/bin/fusermount-glusterfs",
                         "/opt/nokia/msgdispatcher/msgdispatcher", "/usr/bin/fileoperations_peer", "/usr/bin/mount",
                         "/usr/bin/umount", "/usr/sbin/grub2-set-bootflag"]

exeptions_exe_proc_du = ["/usr/bin/chage", "/usr/bin/chfn", "/usr/bin/chsh", "/usr/bin/expiry",
                         "/usr/bin/fusermount", "/usr/bin/gpasswd", "/usr/bin/mount", "/usr/bin/newgidmap",
                         "/usr/bin/newgrp", "/usr/bin/newuidmap", "/usr/bin/passwd", "/usr/bin/rcp",
                         "/usr/bin/rlogin", "/usr/bin/rsh", "/usr/bin/su", "/usr/bin/traceroute", "/usr/bin/umount",
                         "/usr/lib/lxc/lxc-user-nic", "/usr/lib/ssh/ssh-keysign", "/usr/sbin/mount.nfs",
                         "ssl_fct_handshake_result", "/usr/bin/chshe", "/usr/bin/clockdiff",
                         "/usr/libexec/dbus-daemon-launch-helper", "/usr/sbin/unix_chkpwd", "/usr/bin/ping",
                         "/usr/libexec/lxc/lxc-user-nic", "/usr/libexec/ssh/ssh-keysign", "/usr/bin/netperf",
                         "/usr/sbin/netserver"]


def check_busybox(suspect_files):
    for suspect_file in suspect_files:
        if "/usr/bin/busybox" in suspect_file:
            if not str(ssh.execute(command="cat /etc/busybox.conf", connection="BB1")):
                suspect_files.remove(suspect_file)
                break
    return suspect_files


def remove_exeptions(suspect_files, exeptions):
    for index, suspect_file in enumerate(suspect_files):
        for exeption in exeptions:
            if exeption in suspect_files[index]:
                suspect_files[index] = ""
                break
    return suspect_files


def check_system_executables_suid_sgid(VM):
    if VM == "BB1":
        suspect_files = ssh.execute(
            command=r"ls -la $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -print)",
            connection=VM).split("\n")
        suspect_files = check_busybox(remove_exeptions(suspect_files, exeptions_exe_proc_du))
    else:
        suspect_files = ssh.execute(
            command=r"sudo su -c 'ls -la $(find / -xdev \( -perm -4000 -o -perm -2000 \) -type f -print)'",
            connection=VM).split("\n")
        suspect_files = remove_exeptions(suspect_files, exeptions_exe_proc_cu)
    truly_bad_files = "".join(suspect_files)
    assert not truly_bad_files, truly_bad_files
