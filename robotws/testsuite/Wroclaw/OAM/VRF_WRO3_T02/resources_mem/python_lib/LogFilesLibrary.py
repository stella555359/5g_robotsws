import paramiko
from datetime import datetime
from robot.api import logger

"""
Documentation
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_1
...  *****************
...  Basic information
...  *****************
...  New scenario introduced based on https://jiradc.ext.net.nokia.com/browse/MNRCA-67334
...  Pronto related with EDA action: 03275309
...  Check second BTS EDA action: 04509660
...  ******************
...  History of changes
...  ******************
...  05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-574 - resource creation
...  01.07.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22686 - Test adaptation for checking second BTS
"""


class LogFilesLibrary:

    def __init__(self):
        self.log_files = LogFiles()

    def get_log_file_list_slave(self):
        return self.log_files.get_log_file_list_slave()

    def get_log_file_list_master(self):
        return self.log_files.get_log_file_list_master()

    def compare_file_sizes(self, firstlist, secondlist):
        return self.log_files.compare_file_sizes(firstlist, secondlist)


class LogFiles(object):

    def __init__(self):
        self.master_host = "192.168.255.129"
        self.slave_host = "fct-4a"
        self.slave_host2 = "192.168.253.32"
        self.port = 22
        self.username = "toor4nsn"
        self.password = "oZPS0POrRieRtu"
        self.command = (
            '''find / -type f -name "*.log" ! -path "/tmp/*" 2>/dev/null | '''
            '''while read -r file; do '''
            '''file_date=$(date -r "$file" "+%Y.%m.%d %H:%M:%S" 2>/dev/null); '''
            '''if [ ! -z "$file_date" ]; then '''
            '''echo "$file_date $(ls -lh "$file" | awk '{print $5}') $file"; '''
            '''fi; done | sort -r'''
        )

    def get_log_file_list_slave(self):
        ssh_master = None
        try:
            # Attempt to connect to the first slave host
            dest_addr = (self.slave_host, self.port)
            src_addr = ("127.0.0.1", 0)

            ssh_master = paramiko.SSHClient()
            ssh_master.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_master.connect(self.master_host, self.port, self.username, self.password)

            transport = ssh_master.get_transport()
            channel = transport.open_channel(kind="direct-tcpip", dest_addr=dest_addr, src_addr=src_addr)

            ssh_slave = paramiko.SSHClient()
            ssh_slave.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_slave.connect(self.slave_host, self.port, self.username, self.password, sock=channel)

            (stdin, stdout, stderr) = ssh_slave.exec_command(self.command)
            output = stdout.readlines()

            return output
        except Exception as e:
            logger.warn(f"(1st try) Problem during SSH connection to Slave system module via Master, "
                        f"proceeding with second try: {str(e)}")
            try:
                # Attempt to connect to the second slave host if the first fails
                dest_addr = (self.slave_host2, self.port)
                src_addr = ("127.0.0.1", 0)

                transport = ssh_master.get_transport()
                channel = transport.open_channel(kind="direct-tcpip", dest_addr=dest_addr, src_addr=src_addr)

                ssh_slave = paramiko.SSHClient()
                ssh_slave.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                ssh_slave.connect(self.slave_host2, self.port, self.username, self.password, sock=channel)

                (stdin, stdout, stderr) = ssh_slave.exec_command(self.command)
                output = stdout.readlines()

                return output
            except Exception as e:
                logger.warn(f"(2nd try) Error during SSH connection to Slave system module via Master, "
                            f"if tests are done on Single Core this message is expected: {str(e)}")
                return None
        finally:
            if ssh_master is not None:
                ssh_master.close()

    def get_log_file_list_master(self):
        ssh_master = None
        try:
            ssh_master = paramiko.SSHClient()
            ssh_master.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_master.connect(self.master_host, self.port, self.username, self.password)

            (stdin, stdout, stderr) = ssh_master.exec_command(self.command)
            output = stdout.readlines()

            return output

        except Exception as e:
            return f"Error during SSH connection: {str(e)}"
        finally:
            if ssh_master is not None:
                ssh_master.close()

    @staticmethod
    def convert_to_mb(size, unit):
        """Convert size from various units to megabytes."""
        units = {"": 1 / (1024 * 1024), "K": 1 / 1024, "M": 1, "G": 1024}
        return size * units[unit]

    @staticmethod
    def parse_line(line):
        """Parse a line of data and return file path and its size in MB."""
        try:
            parts = line.strip().split()
            timestamp = datetime.strptime(' '.join(parts[:2]), '%Y.%m.%d %H:%M:%S')
            size_part = parts[2]
            if size_part[-1].isdigit():
                size = float(size_part)
                unit = ""
            else:
                size = float(size_part[:-1])
                unit = size_part[-1]
            file_path = ' '.join(parts[3:])
            return file_path, LogFiles.convert_to_mb(size, unit), timestamp
        except ValueError as e:
            logger.warn(f'Error while parsing a line: {line}. Error: {str(e)}')
            return None

    def compare_file_sizes(self, first_list, second_list):
        st_files = {file_path: (size, timestamp) for file_path, size, timestamp in map(self.parse_line, first_list)}
        nd_files = {file_path: (size, timestamp) for file_path, size, timestamp in map(self.parse_line, second_list)}
        all_files_sorted = sorted(set(st_files) | set(nd_files))
        test_failed = False
        for file_path in all_files_sorted:
            if file_path in st_files and file_path in nd_files:
                size_diff = nd_files[file_path][0] - st_files[file_path][0]
                time_diff = nd_files[file_path][1] - st_files[file_path][1]
                msg = f'File {file_path} detected with a size of {nd_files[file_path][0]:.3f}MB.' \
                      f' Size increase: {size_diff:.3f}MB, within: {time_diff}.'
                logger.trace(msg)
                logger.console(msg)
                if nd_files[file_path][0] >= 1 or st_files[file_path][0] >= 1:
                    test_failed = True
            elif file_path in nd_files:
                msg = f'File {file_path} detected with a size of {nd_files[file_path][0]:.3f}MB.' \
                      f' Size increase: unknown, within: unknown (the file was created after the first checkpoint).'
                logger.trace(msg)
                logger.console(msg)
                if nd_files[file_path][0] >= 1:
                    test_failed = True
            elif file_path in st_files:
                msg = f'File {file_path} detected with a size of {st_files[file_path][0]:.3f}MB,' \
                      f' but it was deleted during the test suite execution.'
                logger.trace(msg)
                logger.console(msg)
                if st_files[file_path][0] >= 1:
                    test_failed = True
        if test_failed:
            return test_failed
