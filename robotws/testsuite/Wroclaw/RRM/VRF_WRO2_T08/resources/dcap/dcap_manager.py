import os
from pprint import pformat

from taf.sw.dcap.rd import rd

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration as TLConfig
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger


class DCAPManager:
    """
    Adapter library for taf.sw.dcap.rd library that simplifies basic DCAP log collection on UTE VMs
    Usage example:

    # import and initialize library
    >>> from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import DCAPManager, LogProfile, extract_logs
    >>> dcap = DCAPManager()

    # connect to dcap instance on given host
    >>> dcap.connect_to('10.44.1.1', port='443', user='utfuser', passwd='utfadmin!', alias='my_dcap')

    # create and build custom profile dict (kwargs passed to taf.sw.dcap.rd start_trace kw) using LogProfile helper
    # class:
    >>> profile = LogProfile().with_scf().with_5g_tti().with_lte_tti().with_5g_bip()

    # start new trace - bts will be automatically added to dcap if not present
    >>> trace_id = dcap.start_new_trace(mplane='10.44.224.1', port='443', user='Nemuadmin', passwd='nemuuser',
                                    nr_cells=[1], connection='my_dcap', log_profile=profile)

    # stop trace and download zip
    >>> dcap.stop_trace(trace_id, connection='my_dcap')
    >>> zip_path = dcap.download_logs(trace_id, connection='my_dcap', target_dir='/tmp/dcap_logs')

    # extract relevant log files (merged in one files)
    >>> logs_dict = extract_logs(zip_path)
    """

    _api = rd()

    def __init__(self, verbose=False):
        self._bts_to_be_deleted = []
        self.verbose = verbose

    def connect_to(self, host=None, port='443', user='utfuser', passwd='utfadmin!', alias='dcap_collector'):
        """
        Connects to dcap instance running on given host. Fetches, logs and stores info about all bts added to
        dcap for future reference

        :param: host (str)  -  IP address of host with dcap installed
        :param: port (str)  -  Port on which dcap was configured during installation. Defaults to '443' which is a
                               default for UTE VMs.
        :param: user (str)  -  username for logging into dcap instance
        :param: password (str)  -  password for logging into dcap instance
        :param: alias (str)  -  alias which will reference new connection for usage in rest of the keywords.
        """

        if host is None:
            host = TLConfig().get_nr_test_pc_connection_details()['hostname']
        logger.info(f"Connecting to DCAP instance on {host}:{port}, user = {user}, password = {passwd}")
        self._api.connect_to(host=host, port=port, username=user, password=passwd, rd_version='dcapv3', secure=True,
                             alias=alias)

    def start_new_trace(self, mplane=None, port='443', user=None, passwd=None, nr_cells=None, lte_cells=None,
                        connection='dcap_collector', force=False, skip_pre_check=False, log_profile=None):
        """
        Starts new trace for specified bts

        :param: mplane (str)  -  mplane ip of bts to be traced. If left as None, it will try to fetch this data
                                 from testline __init__.py file
        :param: port (str)  -  port on which bts is accessible via WebEM interface. Defaults to '443'
        :param: user (str)  -  username used to log onto BTS via WebEM interface. If left as None, it will try to
                              fetch this data from testline __init__.py file
        :param: passwd (str)  -  password used to log onto BTS via WebEM interface. If left as None, it will try to
                              fetch this data from testline __init__.py file
        :param: nr_cells (list)  -  list of global_cell_ids of 5g cells to be traced. None means all cells will be
                                    traced
        :param: lte_cells (list)  -  list of global_cell_ids of lte cells to be traced. None means all cells will be
                                     traced
        :param: connection (str)  -  alias given to dcap in 'connect_to' keyword.
        :param: force (bool)  -  Specifies whether new trace should terminate all previous traces that are still
                                 running. Defaults to False
        :param: skip_pre_check (bool) - Specifies whether to run precondition check before actual trace. Defaults to
                                        False, which conducts precondition check
        :param: log_profile (dict)  -  dict containing kwargs that are passed down to taf.sw.dcap.rd start_trace kw.
                                       Those parameters specifies which profile is being used (which logs will be
                                       collected). You can use helper class LogProfile which a dict subclass that
                                       provides interface to quickly build desired dict.
        :returns: (str)  -  id of started trace
        """

        mplane, user, passwd = DCAPManager._get_validated_bts_info(mplane, user, passwd)
        bts = self._get_bts(mplane, port, user, passwd, connection=connection)
        nr_cell_distnames = DCAPManager._validate_cells_for_bts(nr_cells, bts['nr_cells']) \
            if nr_cells is not None else []
        lte_cell_distnames = DCAPManager._validate_cells_for_bts(lte_cells, bts['lte_cells']) \
            if lte_cells is not None else []
        bts_info = {'host': mplane, 'port': port, 'username': user, 'password': passwd, 'nrCells': nr_cell_distnames,
                    'lteCells': lte_cell_distnames}
        if log_profile is None:
            log_profile = {}
        if not skip_pre_check:
            pre_check = self._api.check_precondition(bts=bts_info, connection=connection, **log_profile)
            assert pre_check.ok, f"DCAP trace precondition check failed with msg: {pre_check.msgs}. " \
                                 f"Chosen log profile:\n{pformat(log_profile)}"
        logger.info(f"Starting new DCAP trace on {mplane} (NR cells: {nr_cell_distnames},"
                    f" LTE cells: {lte_cell_distnames}). Chosen log profile:\n{pformat(log_profile)}")
        trace_id = self._api.start_trace(bts_info, connection=connection, force=force, **log_profile)['tracer_id']
        logger.info(f"Trace started successfully. ID = {trace_id}")
        return trace_id

    @staticmethod
    def _get_validated_bts_info(host, user, passwd):
        if host is None or user is None or passwd is None:
            default_host, default_user, default_passwd = TLConfig().get_gnb_oam_connection_details().values()
        host = host if host is not None else default_host
        user = user if user is not None else default_user
        passwd = passwd if passwd is not None else default_passwd
        return host, user, passwd

    def _get_bts(self, mplane, port, user, passwd, connection):
        for bts in self._api.get_all_bts_info(connection=connection):
            if mplane == bts['host']:
                return bts
        logger.info(f"Getting BTS: {mplane}, {port}, {user}, {passwd}")
        bts = self._api.create_bts(host=mplane, port=port, username=user, password=passwd, connection=connection)
        self._bts_to_be_deleted.append((connection, bts.id))
        return bts

    @staticmethod
    def _validate_cells_for_bts(requested_cell_ids, bts_cells):
        bts_cell_ids = [cell['internal_id'] for requested_cell in requested_cell_ids for cell in bts_cells
                        if cell['internal_id'].rsplit('-', maxsplit=1)[-1] == str(requested_cell)]
        assert len(bts_cell_ids) == len(requested_cell_ids), f"Requested cell ids: {requested_cell_ids}\n" \
                                                             f"Matched cells: {bts_cell_ids}\n" \
                                                             f"All cells: {pformat(bts_cells, indent=4)}"
        return bts_cell_ids

    def stop_trace(self, trace, connection='dcap_collector', timeout=600):
        """
        Stop dcap trace using trace_id. Trace_id is obtained from start_new_trace kw for traces started using this lib

        :param: trace (str)  -  id of trace to stop. Returned value fro start_new_trace kw.
        :param: connection (str)  -  alias given to dcap in 'connect_to' keyword.
        :param: timeout (int, float)  -  timeout for waiting for trace stop. Defaults to 600 sec
        """

        logger.info(f"Stoping dcap trace with id = {trace}...")
        self._api.stop_trace(trace_id=trace, connection=connection, timeout=timeout)
        logger.info(f"Trace with id = {trace} stopped!")

    def download_logs(self, trace, connection='dcap_collector', target_dir='/tmp/dcap_logs', timeout=600):
        """
        Download collected zip with results from DCAP

        :param: trace (str)  -  id of trace to download results of. Returned value from start_new_trace kw.
        :param: connection (str)  -  alias given to dcap in 'connect_to' keyword.
        :param: target_dir (str)  -  path to directory to which zip will be collected. If path not exists,
                                     creates such directory. Raises error if path exists but is not a direcotry.
                                     Defaults to '/tmo/dcap_logs'.
        :param: timeout (int, float)  -  timeout for downloading files. (defaults to 600 sec)
        :returns:  (str)  path to collected zip
        """
        if not os.path.isdir(target_dir):
            if os.path.exists(target_dir):
                raise FileExistsError(f"{target_dir} exists and is not a directory!")
            os.makedirs(target_dir)
        return self._api.get_results(trace, target_dir=target_dir, timeout=timeout, connection=connection)

    def teardown(self):
        """
        This method does not teardown connection to DCAP - it will be safely cleaned automatically. Rather than that,
        this method deletes all bts'es from DCAP that were added automatically by this library.
        """

        for connection, bts_id in self._bts_to_be_deleted:
            self._api.delete_bts(bts_id=bts_id, connection=connection)
