import os
import pysftp


def sftp_download(host, port, usr, pwd, remote, local=None):
    """sftp download file or dir recursively
    :param host: such as '192.168.255.1'
    :param port: such as 22
    :param usr: username such as 'toor4nsn'
    :param pwd: password such as 'oZPS0POrRieRtu'
    :param remote: file in host such as '/tmp/rat_psconfig.xml' or folder '/tmp/'(NOT '/tmp')
    :param local: file path to save in local such as 'example/config1/rat1.xml','example/config1/', 'rat1.xml', None
    """
    if local is not None and os.path.split(local)[0] != '':
        if os.path.exists(os.path.split(local)[0]) is False:
            os.makedirs(os.path.split(local)[0])
        if os.path.split(local)[1] == '':
            local = local + '/' + os.path.split(remote)[1]
    elif local is not None and os.path.split(local)[0] == '':
        local = os.getcwd() + '/' + local
    else:
        local = os.getcwd() + '/' + os.path.split(remote)[1]
    local = os.path.normpath(local)
    isExisted = os.popen('sshpass -p {} ssh {}@{}'.format(pwd, usr, host))
    with pysftp.Connection(host, username=usr, password=pwd, port=int(port)) as sftp:
        if os.path.split(remote)[1] != '':
            sftp.get(remote, local)
        else:
            localpath = os.path.join(local, remote.split('/')[-2])
            if os.path.isdir(localpath) is True:
                shutil.rmtree(localpath)
            sftp.get_r(remote, local)
        sftp.close()


def sftp_upload(host, port, usr, pwd, local, remote=None):
    """sftp upload file
    :param host: such as '192.168.255.1'
    :param port: such as 22
    :param usr: username such as 'toor4nsn'
    :param pwd: password such as 'oZPS0POrRieRtu'
    :param local: file in local such as '/tmp/rat_psconfig.xml'
    """

    with pysftp.Connection(host, username=usr, password=pwd, port=int(port)) as sftp:
        current_path = ['', sftp.getcwd()][sftp.getcwd() is not None]
        if remote is not None and os.path.split(remote)[0] != '':
            if sftp.exists(os.path.split(remote)[0]) is not True:
                sftp.makedirs(os.path.split(remote)[0])
#               print("make dir: %s " % os.path.split(remote)[0])
        elif remote is not None and os.path.split(remote)[0] == '':
            remote = current_path + '/' + remote
        else:
            remote = current_path + '/' + os.path.split(local)[1]
        if remote is not None and os.path.split(remote)[1] == '':
            remote = remote + '/' + os.path.split(local)[1]
        local = os.path.normpath(local)
        remote = os.path.normpath(remote)
        sftp.put(local, remote)
        sftp.close()
