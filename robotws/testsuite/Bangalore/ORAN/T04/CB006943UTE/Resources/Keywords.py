from taf.selenium.gnb.oam.coam.classical import classical
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import interface
from robot.api import logger

ssh = interface.ssh()


def check_if_file_exist(output):
    return False if 'No such file or directory' in output else True


def prepare_list_from_console(console_output, split_param="\r\n"):
    list_from_console_output = console_output.split(split_param)
    try:
        list_from_console_output.remove("/etc/swanctl/rsa/enbKey.pem")
    except Exception:
        print("/etc/ipsec.d/private/enbKey.pem is not on list")
    return list_from_console_output


def change_ssh_password(username, old_password, new_password):
    status = None
    api = admin()
    connection = api.connect_to()
    try:
        connection.change_ssh_password(username=username,
                                       new_password=new_password,
                                       old_password=old_password)
        status = True
    except Exception:
        status = False
    finally:
        connection.disconnect()
        return status


def get_file_permissions_from_folder_path(path, connection):
    select_column = "'{print $1}'"
    command = "ls -la {} | awk {}".format(path, select_column)
    output = ssh.execute(command, connection=connection)
    if output is not None:
        return str(output).strip()


def find_auditlogserver_file(connection):
    command = "find / -name auditlogserver.db"
    output = ssh.execute(command, connection=connection)
    output_list = output.split("\r\n")
    file_path = [s for s in output_list if "/ffs/" in s]
    return file_path[0]


def try_to_get_snapshot(ip, user, password):
    interface = classical()
    interface.enable_virtual_display()
    interface.login(ip, user, password)
    logger.console('BTSRead user has logged in correctly')
    try:
        interface.close_start_up_view_window()
    except Exception:
        logger.console('Close start up view is not necessary')
    finally:
        interface.collect_snapshot()
        interface.logout()
        interface.disable_virtual_display()


def check_content(permission):
    return True if "Permission denied" in permission else False


def ifequal(perm, perm1, perm2):
    if perm == perm1 or perm == perm2:
        return True
    else:
        return False


def restore_default_passwords(
        connection,
        default_password_toor4nsn,
        default_password_serviceuser):
    output = ssh.execute(
        command='echo -e "{}\n{}" | passwd toor4nsn'.format(
            default_password_toor4nsn,
            default_password_toor4nsn),
        connection=connection)
    logger.console('Restore default password for toor4nsn:' + output)
    output = ssh.execute(
        command='echo -e "{}\n{}" | passwd serviceuser'.format(
            default_password_serviceuser,
            default_password_serviceuser),
        connection=connection)
    logger.console('Restore default password for serviceuser:' + output)
