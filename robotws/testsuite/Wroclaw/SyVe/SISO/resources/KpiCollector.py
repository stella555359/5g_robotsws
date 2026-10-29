from taf.ul.oam_kpi_calculations import oam_kpi_calculations
from taf.sbts.oam.coam.admin import admin
from testsuite.Wroclaw.SyVe.RRM.resources.TimeStamp import TimeStamp
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from taf.rfrl.common_resources.oam_kpi.report_oam_kpi import ReportOamKpi
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger


class KpiCollector:

    def __init__(self):
        self.kpi_calc = oam_kpi_calculations()
        self._ims_dir = VmOs.join_path_elements(Env().test_log_dir, "ims_files")
        self.admin = admin()
        self.connection = None
        self.kpi_results = None

    def prepare_kpi_report(self, kpi_name):
        return self._calculate_proper_oam_kpi(kpi_name)

    def _setup_admin_connection_for_kpi_ims(self):
        try:
            self.connection = self.admin.setup_admin(update_interval=500, alias="KPI_IMS")
        except AliasInUse:
            self.admin.teardown(connection=self.connection)
            self.connection = self.admin.setup_admin(update_interval=500, alias="KPI_IMS")

    def _collect_infomodel_logs_for_oam_kpi(self):
        ims_file_name = "OAM_KPI{}.ims2".format(TimeStamp().file_timestamp)
        ims_file_path = "/".join([self._ims_dir, ims_file_name])
        self.admin.collect_infomodel_log_from_current_session(target_file_name=ims_file_path, timeout=500,
                                                              connection="KPI_IMS")
        self.admin.teardown(connection=self.connection)
        return ims_file_path

    def _calculate_proper_oam_kpi(self, kpi_name):
        ims_file_path = self._collect_infomodel_logs_for_oam_kpi()
        self.kpi_calc.calculate_kpis(kpi_names=kpi_name, ims_file_path=ims_file_path)
        calculated_kpis = self.kpi_calc.get_results()
        Logger.info(f"Result of calculated {kpi_name}:"
                    f"{ReportOamKpi().prepare_kpi_results(calculated_kpis)}")
        return ReportOamKpi().prepare_kpi_results(calculated_kpis)
