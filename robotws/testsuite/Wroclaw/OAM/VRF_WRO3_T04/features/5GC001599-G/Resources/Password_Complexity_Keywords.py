from robot.api import logger
from taf.sbts.oam.coam.admin import admin


class Password_Complexity_Keywords:

    def __init__(self, bts_ip, bts_username, bts_password):
        self.bts_ip = bts_ip
        self.bts_username = bts_username
        self.bts_password = bts_password

    def change_webem_user_password(self, old_username, old_password, new_password):
        status = None
        api = admin()
        connection = api.connect_to(self.bts_ip)
        try:
            logger.info("Changing password for {0}".format(old_username), also_console=True)
            connection.set_user_account(old_username=old_username,
                                        old_password=old_password,
                                        new_password=new_password)
            status = True
        except Exception as e:
            status = False
        finally:
            connection.disconnect()
            return status

    def change_ssh_user_password(self, username, new_password, old_password):
        status = None
        api = admin()
        connection = api.connect_to(bts_host=self.bts_ip)
        try:
            logger.info("Changing password for {0}".format(username), also_console=True)
            connection.change_ssh_password(username=username,
                                           new_password=new_password,
                                           old_password=old_password)
            status = True
        except Exception as e:
            status = False
        finally:
            connection.disconnect()
            return status
