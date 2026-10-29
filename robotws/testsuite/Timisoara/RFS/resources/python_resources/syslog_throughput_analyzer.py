import shutil
import logging
import datetime
import re
import statistics
from taf.transport.ssh import ssh

logging.basicConfig(filename='mylog.log', level=0)
LOGLEVEL = 0                 # 0 = NO DEBUG; 1 = DEBUG


def debug_logging(msg):
    if LOGLEVEL == 1:
        logging.debug(msg)


class syslog_throughput_analyzer(object):
    def __init__(self):
        self.ssh_client = ssh()
        self.syslog_file_local = None

    def setup_syslog_throughput_analyzer(self,
                                         hostname='local',
                                         port='22',
                                         username='ute',
                                         password='uteUTE!',
                                         syslog_file=None,
                                         duration=0,
                                         direction=None,
                                         start_time=None,
                                         techno=None,
                                         cell_id=None,
                                         ue_group=0,
                                         work_dir=None,
                                         ):

        """
        Function to set up syslog throughput parser

        :param hostname:  hostname of the VM where Syslog to be parsed is present. Use IP in case of
                          remote VM and 'local' in case of local VM.
                          For remote VM, the Syslog will be transferred on local VM
        :param port:  SSH connection port in case of remote VM syslog
        :param username:  SSH connection username in case of remote VM syslog
        :param password:  SSH connection password in case of remote VM syslog
        :param syslog_file:  Full path to syslog file
        :param duration:  Duration in seconds for the traffic to be analyzed
        :param direction:  Direction for the traffic to be analyzed. Accepted values: DL, UL
        :param start_time:  Start time for the Syslog analysis. Format 'YYYY-MM-DD hh:mm:ss'
        :param techno:  Cellular network technology on which traffic is analyzed, E.g: NR, LTE
        :param cell_id:  Cell ID to be filtered by in syslog - only mandatory for NR
        :param ue_group:  Ue Group to be filtered by in syslog - only mandatory for LTE UL
        :param work_dir:  Name of the local directory where parsing files will be stored

        """
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password
        self.syslog_file = syslog_file
        self.duration = int(duration) if duration is not None else duration
        self.direction = direction
        self.start_time = start_time
        self.techno = techno
        self.cell_id = int(cell_id) if cell_id is not None else cell_id
        self.ue_group = int(ue_group) if ue_group is not None else ue_group
        self.work_dir = work_dir

    def _get_syslog_file(self):
        time_now = datetime.datetime.today().strftime('%Y%m%d_%H_%M_%S')
        syslog_name = self.syslog_file.split("/")[-1]
        self.syslog_file_local = '{}/{}_{}_{}_{}'.format(self.work_dir,
                                                         syslog_name,
                                                         self.techno,
                                                         self.direction,
                                                         time_now)
        self.syslog_file_local = self.syslog_file_local.replace('//', '/')
        if self.hostname.lower() == 'local':
            try:
                shutil.copy(self.syslog_file, self.syslog_file_local)
            except IOError:
                raise Exception("Error at copying local file {}".format(self.syslog_file))
        else:
            ssh_conn = ssh()
            try:
                ssh_conn.connect_to(self.hostname, self.username)
            except Exception as e:
                raise Exception("Cannot open ssh connection in order to transfer Syslog File! Error: {}".format(e))
            if not ssh_conn.file_exists(self.syslog_file):
                raise Exception("Searched remote file {} does not exist!".format(self.syslog_file))
            try:
                ssh_conn.download_file(self.syslog_file, self.syslog_file_local)
            except Exception as e:
                raise Exception("Could not transfer Syslog File! Error: {}".format(e))
            ssh_conn.disconnect()

    def analyze_syslog_throughput(self):
        self._get_syslog_file()
        if self.techno.upper() == 'NR':

            parser = SyslogThroughputParserNR(syslog_file=self.syslog_file_local,
                                              duration=self.duration,
                                              direction=self.direction,
                                              start_time=self.start_time,
                                              cell_id=self.cell_id,
                                              )
        elif self.techno.upper() == 'LTE':
            parser = SyslogThroughputParserLTE(syslog_file=self.syslog_file_local,
                                               duration=self.duration,
                                               direction=self.direction,
                                               start_time=self.start_time,
                                               ue_group=self.ue_group
                                               )

        parser._generate_filtered_file()
        parser._generate_throughput_info_filtered_file()
        parser._get_syslog_thput_values_list()
        avg_thput = parser._get_average_thput_value()
        return avg_thput

    @staticmethod
    def get_syslog_throughput_analysis_start_time(hostname='local',
                                                  port='22',
                                                  username='toor4nsn',
                                                  password='oZPS0POrRieRtu'):
        if hostname.lower() == 'local':
            start_time = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
        else:
            bts_time_now = BTSTime(hostname,
                                   port,
                                   username,
                                   password)
            start_time = bts_time_now.get_bts_time()
        return start_time


class SyslogThroughputParser(object):
    def __init__(self,
                 syslog_file=None,
                 duration=0,
                 direction=0,
                 start_time=None,
                 cell_id=None,
                 ue_group=0,
                 work_dir=None):
        self.syslog_file = syslog_file
        self.duration = duration
        self.direction = direction
        self.start_time = start_time
        self.cell_id = cell_id
        self.ue_group = ue_group
        self.work_dir = work_dir
        self.filtered_file = None
        self.thput_filtered_file = None
        self.thput_info_reg = None
        self.thput_values_list = []
        self.timeout = 30

    def _generate_filtered_file(self):
        date_regex = r".*<(\d+-\d+-\d+T\d+:\d+:\d+).*"
        datetime_start = datetime.datetime.strptime(self.start_time, '%Y-%m-%d %H:%M:%S')
        self.filtered_file = '{}__filtered'.format(self.syslog_file)
        try:
            with open(self.filtered_file, 'w', encoding='UTF-8') as file_w:
                try:
                    with open(self.syslog_file, 'r', encoding='UTF-8') as file_r:
                        while line := file_r.readline():
                            line = line.rstrip()
                            debug_logging("Line read from syslog: {}".format(line))
                            timestamp = re.findall(date_regex, line)
                            if len(timestamp) == 0:
                                debug_logging("Line \n {} \n will be skipped. Timestamp not found!".format(line))
                                continue
                            timestamp = timestamp[0]
                            timestamp = timestamp.replace('T', ' ')
                            debug_logging("Timestamp of line: {}".format(timestamp))
                            datetime_line = datetime.datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
                            sec_diff_to_start_time = int((datetime_line - datetime_start).total_seconds())
                            if datetime_line < datetime_start:
                                debug_logging("Line \n {} \n will be skipped - before start point".format(line))
                                continue
                            if sec_diff_to_start_time > self.duration:
                                debug_logging("exiting file reading - reached end point".format(line))
                                break
                            debug_logging("Line written to filtered file: {}".format(line))
                            file_w.write(line + '\n')
                except FileNotFoundError:
                    raise Exception("File {} not found".format(self.syslog_file))
                except OSError:
                    raise Exception("OS error occurred trying to open {}".format(self.syslog_file))
                except Exception:
                    raise Exception("Unexpected error opening {}".format(self.syslog_file))
        except FileNotFoundError:
            raise Exception("File {} not found".format(self.filtered_file))
        except OSError:
            raise Exception("OS error occurred trying to open {}".format(self.filtered_file))
        except Exception:
            raise Exception("Unexpected error opening {}".format(self.filtered_file))

    def _generate_throughput_info_filtered_file(self):
        self.thput_filtered_file = '{}__thput_info'.format(self.syslog_file)
        try:
            with open(self.thput_filtered_file, 'w', encoding='UTF-8') as file_w:
                try:
                    with open(self.filtered_file, 'r', encoding='UTF-8') as file_r:
                        while line := file_r.readline():
                            line = line.rstrip()
                            debug_logging("Line read from filtered syslog: {}".format(line))
                            if self._apply_throughput_info_filter(line):
                                file_w.write(line + '\n')
                            else:
                                debug_logging("Line \n {} \n not matching for the desired parsing".format(line))
                except FileNotFoundError:
                    raise Exception("File {} not found".format(self.filtered_file))
                except OSError:
                    raise Exception("OS error occurred trying to open {}".format(self.filtered_file))
                except Exception:
                    raise Exception("Unexpected error opening {}".format(self.filtered_file))
        except FileNotFoundError:
            raise Exception("File {} not found".format(self.thput_filtered_file))
        except OSError:
            raise Exception("OS error occurred trying to open {}".format(self.thput_filtered_file))
        except Exception:
            raise Exception("Unexpected error opening {}".format(self.thput_filtered_file))

    def _apply_throughput_info_filter(self, line):
        result = re.match(self.thput_info_reg, line)
        return result

    def _get_syslog_thput_values_list(self):
        pass

    def _get_average_thput_value(self):
        if len(self.thput_values_list) == 0:
            return 0
        else:
            avg_thput = statistics.mean(self.thput_values_list)
            debug_logging("Average throughput value computed: {} bits/sec".format(avg_thput))
            return avg_thput

    def _get_thput_info_from_line_DL(self, **kwargs):
        pass

    def _get_thput_info_from_line_UL(self, **kwargs):
        pass


class SyslogThroughputParserNR(SyslogThroughputParser):
    def __init__(self,
                 syslog_file=None,
                 duration=0,
                 direction=0,
                 start_time=None,
                 cell_id=None):

        super().__init__(syslog_file=syslog_file,
                         duration=duration,
                         direction=direction,
                         start_time=start_time,
                         cell_id=cell_id)
        if not self.cell_id:
            raise Exception("SyslogThroughputParserNR: cell_id is mandatory!")
        if direction == 'DL':
            self.thput_info_reg = r".*nrCellId\s(\d+).*\[(.*DataPdu.*?)]"
        elif direction == 'UL':
            self.thput_info_reg = r".*UlCounterUpdate\.cpp:\d+/UL.*"

    def _get_syslog_thput_values_list(self):
        self.thput_values_list = []
        try:
            with open(self.thput_filtered_file, 'r', encoding='UTF-8') as file_r:
                while line := file_r.readline():
                    line = line.rstrip()
                    debug_logging("Line read from filtered throughput file: {}".format(line))
                    if self.direction == "DL":
                        thput = self._get_DL_thput_info_from_line(line)
                    elif self.direction == "UL":
                        thput = self._get_UL_thput_info_from_line(line)
                    if thput:
                        self.thput_values_list.append(int(thput))
        except FileNotFoundError:
            raise Exception("File {} not found".format(self.thput_filtered_file))
        except OSError:
            raise Exception("OS error occurred trying to open {}".format(self.thput_filtered_file))
        except Exception as err:
            raise Exception("Unexpected error opening {}".format(self.thput_filtered_file))
        debug_logging("Lines throughput list obtained: {}".format(self.thput_values_list))

    def _get_DL_thput_info_from_line(self, line):
        cell_id_found = line.split("nrCellId")[1].split(' ')[1]
        if int(cell_id_found) == self.cell_id:
            thput_from_line = line.split("DataPdu:")[1].split(' ')[1].split('|')[0]
            thput_from_line = int(thput_from_line) * 8   # bytes/sec to bits/sec
            return thput_from_line
        else:
            debug_logging("Cell id {} not found in line".format(self.cell_id))
            return False

    def _get_UL_thput_info_from_line(self, line):
        cell_id_found = line.split("nrCellIdentity")[1].split(' ')[1]
        if int(cell_id_found) == self.cell_id:
            thput_from_line = int(line.split("Bytes received. (")[-1].split(" rlcPduBytes")[0])
            thput_from_line = int(thput_from_line) * 8   # bytes/sec to bits/sec
            return thput_from_line
        else:
            debug_logging("Cell id {} not found in line".format(self.cell_id))
            return False


class SyslogThroughputParserLTE(SyslogThroughputParser):
    def __init__(self,
                 syslog_file=None,
                 duration=0,
                 direction=0,
                 start_time=None,
                 ue_group=0):
        super().__init__(syslog_file=syslog_file,
                         duration=duration,
                         direction=direction,
                         start_time=start_time,
                         ue_group=ue_group)
        if direction == 'DL':
            self.thput_info_reg = r".*INF/RLC/STATS/DL: RCVD:.*"
        elif direction == 'UL':
            self.thput_info_reg = r".*INF/LTE L2/ULUE STATS.*"
        self.dl_cpus_counted = []
        self.dl_cumulative_thput = 0
        self.start_point_cumul_thput = self.start_time
        self.ue_group = ue_group

    def _get_syslog_thput_values_list(self):
        self.thput_values_list = []
        try:
            with open(self.thput_filtered_file, 'r', encoding='UTF-8') as file_r:
                while line := file_r.readline():
                    line = line.rstrip()
                    debug_logging("Line read from filtered throughput file: {}".format(line))
                    if self.direction == "DL":
                        thput = self._get_DL_thput_info_from_line(line)
                    elif self.direction == "UL":
                        thput = self._get_UL_thput_info_from_line(line)
                    if thput:
                        self.thput_values_list.append(int(thput))
        except FileNotFoundError:
            raise Exception("File {} not found".format(self.thput_filtered_file))
        except OSError:
            raise Exception("OS error occurred trying to open {}".format(self.thput_filtered_file))
        except Exception as err:
            raise Exception("Unexpected error opening {}".format(self.thput_filtered_file))
        debug_logging("Lines throughput list obtained: {}".format(self.thput_values_list))

    def _get_DL_thput_info_from_line(self, line):
        to_return = False
        date_regex = r".*<(\d+-\d+-\d+T\d+:\d+:\d+).*"
        line = line.rstrip()
        debug_logging("Line read from syslog thput info filtered file: {}".format(line))
        timestamp = re.findall(date_regex, line)
        if len(timestamp) == 0:
            debug_logging("Line \n {} \n will be skipped. Timestamp not found!".format(line))
            return to_return
        timestamp = timestamp[0]
        timestamp = timestamp.replace('T', ' ')
        debug_logging("Timestamp of line: {}".format(timestamp))
        datetime_line = datetime.datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')
        datetime_start = datetime.datetime.strptime(self.start_point_cumul_thput, '%Y-%m-%d %H:%M:%S')
        try:
            thput_from_line = line.split("ACKD: ")[-1].split(' ACKP: ')[0].split(' ')
            thput_from_line = list(map(int, thput_from_line))
            thput_from_line = sum(thput_from_line)
            thput_from_line = thput_from_line * 8  # in bits
            current_dl_cpu = line.split('L2LMLowPQ_Cpu')[-1].split(' ')[0]
        except Exception as e:
            raise Exception("Error at computing throughput from line! {}".format(e))

        sec_diff_to_start_time = int((datetime_line - datetime_start).total_seconds())
        if sec_diff_to_start_time < 6:
            self.dl_cumulative_thput += thput_from_line
        else:
            to_return = self.dl_cumulative_thput / 6  # trace comes in 6 sec bursts
            self.dl_cumulative_thput = thput_from_line
            self.start_point_cumul_thput = timestamp
        return to_return

    def _get_UL_thput_info_from_line(self, line):
        if not 'ueGroup={}'.format(self.ue_group) in line:
            debug_logging('Line {} not referring to the ueGroup of interest'.format(line))
            return False
        try:
            thput_from_line = line.split("8:")[-1].split(' 9:')[0]
            thput_from_line = int(thput_from_line)/2    # in bytes
            thput_from_line = thput_from_line * 8       # in bits
            if thput_from_line == 0:
                debug_logging('Thput found zero. Line will be skipped')
                return False
        except Exception as e:
            raise Exception("Error at computing throughput from line! {}".format(e))
        return thput_from_line


class SyslogThroughputParserWCDMA(object):
    def __init__(self):
        debug_logging("Not implemented!")


class SyslogThroughputParserGSM(object):
    def __init__(self):
        debug_logging("Not implemented!")


class BTSTime(object):
    def __init__(self,
                 hostname='192.168.255.1',
                 port='22',
                 username='toor4nsn',
                 password='oZPS0POrRieRtu'):
        self.hostname = hostname
        self.port = port
        self.username = username
        self.password = password

    def get_bts_time(self):
        self.ssh_client.connect_to(self.hostname, self.username)
        resp = self.ssh_client.execute('date \'+%Y-%m-%d %H:%M:%S\'')
        resp = resp.decode("utf-8")
        resp = resp.strip()
        self.ssh_client.disconnect()
        return resp
