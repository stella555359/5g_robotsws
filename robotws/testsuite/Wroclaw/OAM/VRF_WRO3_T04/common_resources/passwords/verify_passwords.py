from testsuite.Wroclaw.OAM.VRF_WRO3_T04.common_resources.logs.log_downloader import LogDownloader
from taf.transport.ssh import ssh
from robot.api import logger


class verify_passwords:
    def __init__(self):
        self.list_of_suspicious_files = ""
        self.suspicious_word = ""
        self.download_log = LogDownloader()
        self.ssh = ssh()

    def find_illegal_files_with_stored_password(self, password, file_extension="", directory="/"):
        if password == '$developer#':
            password = '\\$developer#'
        self.list_of_suspicious_files = self.ssh.execute(command="find " + directory + " -name \"*" + file_extension +
                                                                 "\" -type f | xargs grep -i -l -F '" + password + "'",
                                                         connection="cOAM_toor4nsn")
        try:
            self.list_of_suspicious_files = self.list_of_suspicious_files.replace('/var/log/messages\r', '')
        finally:
            print("/var/log/messages removed from the list or was not there")

    def find_illegal_password_strings_in_binary_files(self, password, binary_path):
        if password == '$developer#':
            password = '\\$developer#'
        self.suspicious_word = self.ssh.execute(command="strings " + binary_path + " | grep -F " + "\"" +
                                                        password + "\"", connection="cOAM_toor4nsn")

    def verify_illegal_files(self):
        output = self.list_of_suspicious_files
        logger.console(output)
        if output:
            suspicious_files = output.split("\n")
            logger.console(suspicious_files)
            illegal_files = [single_file for single_file in suspicious_files
                             if ".bash_history" not in single_file and "proc" not in single_file and
                             "ruemlog" not in single_file]
            logger.console(illegal_files)
            for illegal_file in illegal_files:
                logger.console(illegal_file)
                assert illegal_file == '' or 'No such file or directory\r' in illegal_file, \
                    "Password has been found in files: {}".format(illegal_file)

    def verify_illegal_words(self):
        output = self.suspicious_word
        if output != "":
            assert output == [u''], "Password \"{}\" has been found".format(output)
