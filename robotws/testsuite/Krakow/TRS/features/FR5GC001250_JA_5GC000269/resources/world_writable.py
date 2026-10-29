from taf.transport.ssh import interface
ssh = interface.ssh()

exceptions_exe_proc_cu = []
exceptions_exe_proc_du = ["/tftpboot/slot01/devB/bootdt.uim", "/tftpboot/slot01/devA/bootdt.uim"]


def remove_exceptions(suspect_files, exceptions):
    for index, suspect_file in enumerate(suspect_files):
        for exception in exceptions:
            if exception in suspect_files[index]:
                suspect_files[index] = ""
                break
    return suspect_files


def check_unauthorized_on(VM):
    if VM == "BB1":
        suspect_files = ssh.execute(
            command=r"find / -xdev -type f -perm 777 -exec ls -al {} \;",
            connection=VM).split("\n")
        suspect_files = remove_exceptions(suspect_files, exceptions_exe_proc_du)
    else:
        suspect_files = ssh.execute(
            command=r"sudo su -c 'find / -xdev -type f -perm 777 -exec ls -al {} \;'",
            connection=VM).split("\n")
        suspect_files = remove_exceptions(suspect_files, exceptions_exe_proc_cu)
    truly_bad_files = "".join(suspect_files)
    assert not truly_bad_files, truly_bad_files
