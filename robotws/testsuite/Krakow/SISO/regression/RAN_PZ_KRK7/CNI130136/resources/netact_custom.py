from taf.nms.netact import netact as netact
import logging
import re
from pprint import pformat


logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())


class netact_custom(netact):
    '''
    Main documentation in parent class taf.nms.netact.netact
    racclimx.sh -h
        Reports_Compare
        Reports_Delete
        Reports_Export
        Reports_List
        Reports_Save_Snapshot
    '''

    def __init__(self):
        super().__init__()

    def show_object(self):
        print(self)

    def reports_compare(self, report1_name, report2_name, compare_report_name, description=None,
                        verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):
        '''
        racclimx.sh -op Reports_Compare -h
        -op Reports_Compare
            Compares two snapshot reports created before and after the change and saves the
            resulting compare report.
            options:
            -snapshot1      Specifies the name of the snapshot report saved before the change.
            -snapshot2      Specifies the name of the snapshot report saved after the change.
            -compareReportName      Specifies the compare report name. The name must be unique.
            Maximum report name length is 176 characters. The following
            special characters are not supported: ´/`!;:?*~'\".
            -description    Specifies the compare report description. Argument is optional.
        '''

        parameters = {
            '-op': 'Reports_Compare',
            '-snapshot1': report1_name,
            '-snapshot2': report2_name,
            '-compareReportName': compare_report_name,
            '-description': description,
            '-schedule': schedule
        }
        return self.store.get(alias).cm_operations._execute_operation(parameters, verbose, ignore_errors, timeout)

    def reports_delete(self, report_name,
                       verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):
        '''
        racclimx.sh -op Reports_Delete -h
        -op Reports_Delete
            Delete reports.
            options:
            -reportName     Comma separated list of report names identifying reports to be deleted.
        '''

        parameters = {
            '-op': 'Reports_Delete',
            '-reportName': report_name,
            '-schedule': schedule
        }
        return self.store.get(alias).cm_operations._execute_operation(parameters, verbose, ignore_errors, timeout)

    def reports_export(self, report_name, file_name=None, file_format='JSON',
                       verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):
        '''
        racclimx.sh -op Reports_Export -h
        -op Reports_Export
                Exports report to directory /var/opt/oss/global/racops/export/.
                options:
                -fileFormat     Specifies the file format (JSON/XLSX).
                Default value is JSON. Argument is optional.
                -reportName     Specifies the report to be exported.
                -fileName       Specifies the file name. If not defined the report name is used. The file is
                stored in directory /var/opt/oss/global/racops/export/. Argument is optional.
        '''

        parameters = {
            '-op': 'Reports_Export',
            '-fileFormat': file_format,
            '-reportName': report_name,
            '-fileName': file_name,
            '-schedule': schedule
        }
        return self.store.get(alias).cm_operations._execute_operation(parameters, verbose, ignore_errors, timeout)

    @staticmethod
    def _get_path_from_cmd_output(command_output):

        logger.debug(command_output)
        pattern = r"Report exported to: (/.+)"
        match = re.search(pattern, command_output)
        if match:
            file_path = match.group(1)
            logger.info(f"Extracted file path: {file_path}")
        else:
            logger.info(f"File path not found in the output.\n{command_output=}")
            file_path = None
        return file_path

    def reports_export_and_return_path(self, report_name, file_name=None, file_format='JSON',
                                       verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):

        stdout = self.reports_export(report_name, file_name, file_format,
                                     verbose, schedule, ignore_errors, timeout, alias)
        # logger.debug(stdout)
        return self._get_path_from_cmd_output(stdout)

    @staticmethod
    def _get_dir_and_filename_from_path(path):
        return path.rsplit('/', 1)

    def reports_export_and_get_file(self, report_name, local_dir=None, file_name=None, file_format='JSON', cleanup=True,
                                    verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):

        export_path = self.reports_export_and_return_path(report_name, file_name, file_format,
                                                          verbose, schedule, ignore_errors, timeout, alias)
        remote_dir, file_name = self._get_dir_and_filename_from_path(export_path)
        self.store.get(alias).cm_operations._get_file(file_name, remote_dir, local_dir, timeout)
        if cleanup:
            self.store.get(alias).cm_operations._remove_remote_file(file_name, remote_dir, timeout)
        return local_dir, file_name

    def reports_list(self, verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):
        '''
        racclimx.sh -op Reports_List -h
        -op Reports_List
            Prints out a list of the existing reports with details.
        '''

        parameters = {
            '-op': 'Reports_List',
            '-schedule': schedule
        }
        return self.store.get(alias).cm_operations._execute_operation(parameters, verbose, ignore_errors, timeout)

    def reports_save_snapshot(self, working_set, report_name, description=None,
                              verbose=True, schedule=None, ignore_errors=False, timeout=120, alias=None):
        '''
        racclimx.sh -op Reports_Save_Snapshot -h
        -op Reports_Save_Snapshot
            Saves a snapshot report.
            options:
            -DN     Specifies the scope of the operation (comma-separated
            Distinguished Names without spaces). Either argument workingSet
            or DN is used to define the scope. Argument is optional.
            -workingSet     Specifies the scope of the operation as defined in the working
            set (only single working set is supported). Either argument
            workingSet or DN is used to define the scope. Argument is optional.
            -reportName     Specifies the snapshot report name. The name must be
            unique. Maximum report name length is 176 characters. The
            following special characters are not supported: ´/`!;:?*~'\".
            -description    Specifies the snapshot report description. Argument is optional.
            -neType Supported values sranLte and cloudRAN. Default
            value is sranLte. Argument is optional.
       '''
        parameters = {
            '-op': 'Reports_Save_Snapshot',
            '-workingSet': working_set,
            '-reportName': report_name,
            '-description': description,
            '-schedule': schedule
        }
        return self.store.get(alias).cm_operations._execute_operation(parameters, verbose, ignore_errors, timeout)

    def get_alarm_list(self, dist_name, alias=None, only_active=True):
        alarm_list = [dict(el) for el in self.get_alarms(dist_name, alias, only_active)]
        logger.info(f"alarm_list:\n{pformat(alarm_list)}")
        return alarm_list

    def try_upload_alarms(self, dist_name, alias=None):
        try:
            return self.upload_alarms(dist_name, alias)
        except Exception as ex:
            logger.warning(f"netact upload_alarms failed: {ex}")
