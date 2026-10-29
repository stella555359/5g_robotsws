from testsuite.Ulm.ET.L2.libraries.parse_out_log import get_pm_file_scenario_dict
from testsuite.Ulm.resources.Common.python.ltepat.ltepat_run import create_configuration_file, run_ltepat


def calculate_kpi_for_all_scenarios(ts_log_dir, scenario_list, logs_and_traces_flags):
    for scenario_name, values in get_pm_file_scenario_dict(ts_log_dir, scenario_list).items():
        logs_and_traces_flags['KPI']['runtime_options'].update(
            {'@OutputDirectory': f'{ts_log_dir}/PMC/kpi/{scenario_name}'})
        print(f'calculating kpis for {scenario_name}')
        config_path = create_configuration_file(pm_files=values['pm_file'],
                                                conversion_options=logs_and_traces_flags['KPI']['pm_options'],
                                                runtime_options=logs_and_traces_flags['KPI']['runtime_options'],
                                                suite_log_dir=ts_log_dir)
        print(run_ltepat(config_path, f'{ts_log_dir}/ltepat_output_{scenario_name}.txt'))


if __name__ == '__main__':
    calculate_kpi_for_all_scenarios('',
                                    ['scenario_1', 'scenario_2', 'scenario_3'],
                                    {'KPI': {'pm_options': {}, 'runtime_options': {}}})
