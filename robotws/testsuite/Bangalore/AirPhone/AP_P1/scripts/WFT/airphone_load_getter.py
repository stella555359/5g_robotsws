import os
import json
try:
    import click
except ImportError:
    os.system('pip install click')
    import click
try:
    import requests
except ImportError:
    os.system('pip install requests')
    import requests


class WFTToolInterface():
    def __init__(self):
        self.base_url = 'https://wft.int.net.nokia.com:8091/'
        self.build_url = self.base_url + 'TOOLS/api/v1/build.json'
        self.headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        self.access_key = 'S3roP5dXbVm4tlZnIhigteyuUHNlgt8mxe2566VD'

    def get_latest_ap_load(self, project, state):
        payload = self.get_ap_payload(project, state)
        response_data = self.get_json_response(self.build_url, payload)
        return response_data['items'][-0]['version'].replace('airphone_', '')

    def get_ap_latest_load_with_test_result(self, project, state, test_result, l3call_status):
        payload = self.get_ap_payload(project, state)
        response_data = self.get_json_response(self.build_url, payload)
        airphone_builds = response_data['items']
        for build in airphone_builds:
            if self.is_result_present_in_test_results(build['test_results'], test_result, l3call_status.lower()):
                return build['version'].replace('airphone_', '')
        return ''

    def is_result_present_in_test_results(self, build_results, result, l3call_status):
        for build_result in build_results:
            if build_result['test_type'] == result and build_result['result'] == l3call_status:
                return True
        return False

    def get_ap_payload(self, project, state):
        payload = {'sorting_field': 'planned_delivery_date', 'sorting_direction': 'DESC', 'group_by': '',
                   'group_by_processor': '', 'access_key': self.access_key,
                   'columns': {'0': {'id': 'state'}, '1': {'id': 'version'}, '2': {'id': 'test_results'}},
                   'view_filters_attributes': {'0': {'column': 'branch',
                                                     'operation': 'cont', 'value': project},
                                               '1': {'column': 'state', 'operation': 'eq_any',
                                                     'value': [state]},
                                               '2': {'column': 'version', 'operation': 'not_cont_any',
                                                     'value': ['airph_mzoam_l1r51_tdd_1.']},
                                               '3': {'column': 'version', 'operation': 'not_cont_any',
                                                     'value': ['airphone_1.']},
                                               '4': {'column': 'version', 'operation': 'not_cont_any',
                                                     'value': ['WTS']},
                                               '5': {'column': 'component', 'operation': 'eq',
                                                     'value': 'airphone'}}}
        return payload

    def get_load_info(self, project, load_id, state=''):
        payload = self.get_ap_payload(project, state)
        payload.update({
            "view_filters_attributes": {
                "0": {"column": "version", "operation": "cont", "value": "{}".format(load_id)}
            }
        })
        return self.get_json_response(self.build_url, payload)

    def get_json_response(self, url, payload=None):
        data = json.dumps(payload)
        response = requests.get(url,
                                headers=self.headers,
                                data=data, verify=False)
        response_data = json.loads(response.text)
        return response_data

    def get_ap_cit_candidate(self, project, cit_type):
        latest_released_build = self.get_latest_ap_load(project, 'RELEASED')
        build_test_results = self.get_ap_load_test_results(latest_released_build)
        for build_test_result in build_test_results:
            if self.is_result_released(build_test_result, cit_type):
                return ''
        return latest_released_build

    def get_ap_load_test_results(self, build):
        url = '{}api/v1/TOOLS/airphone/builds/airphone_{}/test_results.json?access_key={}'.format(self.base_url,
                                                                                                  build,
                                                                                                  self.access_key)
        return self.get_json_response(url)

    def is_result_released(self, build_test_result, cit_type):
        return build_test_result['test_type']['identifier'] == cit_type and build_test_result['result'] == 'released'

    def get_ap_latest_load_released_or_released_with_restrictions(self, project):
        latest_released_build = self.get_latest_ap_load(project, 'RELEASED')
        latest_released_with_restrictions_build = self.get_latest_ap_load(project, 'RELEASED_WITH_RESTRICTIONS')
        if latest_released_build > latest_released_with_restrictions_build:
            return latest_released_build
        return latest_released_with_restrictions_build

    def check_p1_global_func_status(self, build, identifier='global_p1-func_status'):
        build_test_results = self.get_ap_load_test_results(build)
        for build_test_result in build_test_results:
            if self.is_result_released(build_test_result, identifier):
                return True
        return False

    def get_ap_latest_load_with_test_name(self, project, state, test_result):
        payload = self.get_ap_payload(project, state)
        response_data = self.get_json_response(self.build_url, payload)
        airphone_builds = response_data['items']
        for build in airphone_builds:
            if self.is_test_in_test_results(build['test_results'], test_result):
                return build['version'].replace('airphone_', '')
        return ''

    def is_test_in_test_results(self, build_results, test_result):
        for build_result in build_results:
            if build_result['test_type'] == test_result:
                return True
        return False

    def get_ap_latest_load_for_p2_regression(self, project):
        selected_build = []
        selected_build.append(self.get_latest_ap_load(project, 'RELEASED'))
        selected_build.append(self.get_latest_ap_load(project, 'RELEASED_WITH_RESTRICTIONS'))
        selected_build.append(self.get_latest_ap_load(project, 'NOT_RELEASED'))
        selected_build.append(
            self.get_ap_latest_load_with_test_name(
                project, 'RELEASED_FOR_QUICKTEST', 'Global_QT_status'
            )
        )
        selected_build = [ap_build for ap_build in selected_build if ap_build]
        selected_build.sort(key=lambda s: list(map(int, s.split('.'))), reverse=True)
        return selected_build[0]


@click.group()
@click.pass_context
def main(ctx):
    ctx.obj = WFTToolInterface()
    return


@main.command()
@click.argument('project')
@click.option('--state', help='State of the build to Query')
@click.pass_obj
def ap_latest_load(ctx, project, state):
    wft_interface_tool = ctx
    print(wft_interface_tool.get_latest_ap_load(project, state))
    return


@main.command()
@click.argument('project')
@click.argument('load_id')
@click.pass_obj
def ap_load_info(ctx, project, load_id):
    wft_interface_tool = ctx
    print(wft_interface_tool.get_load_info(project, load_id))
    return


@main.command()
@click.argument('project')
@click.argument('cit_type')
@click.pass_obj
def ap_cit_candidate(ctx, project, cit_type):
    wft_interface_tool = ctx
    print(wft_interface_tool.get_ap_cit_candidate(project, cit_type))
    return


@main.command()
@click.option('--state')
@click.option('--testresult')
@click.pass_obj
def ap_latest_load_with_test_result_and_state(ctx, state, testresult):
    wft_interface_tool = ctx
    print(wft_interface_tool.get_ap_latest_load_with_test_result('master_airphone', state, testresult))
    return


@main.command()
@click.pass_obj
def ap_p1_candidate_build(ctx):
    wft_interface_tool = ctx
    ap_latest_load = wft_interface_tool.get_ap_latest_load_released_or_released_with_restrictions('master_airphone')
    ap_p1_candidate_build = wft_interface_tool.get_ap_latest_load_with_test_result(project='master_airphone',
                                                                                   state='RELEASED_FOR_QUICKTEST',
                                                                                   test_result='Global_QT_status',
                                                                                   l3call_status='RELEASED')
    if ap_p1_candidate_build and wft_interface_tool.check_p1_global_func_status(ap_p1_candidate_build):
        print('')
        return
    if ap_p1_candidate_build and ap_p1_candidate_build > ap_latest_load:
        print(ap_p1_candidate_build)
        return
    print('')
    return


@main.command()
@click.pass_obj
def get_latest_ap_build(ctx):
    wft_interface_tool = ctx
    ap_latest_load = wft_interface_tool.get_latest_ap_load('master_airphone', '')
    print(ap_latest_load)
    return ap_latest_load


@main.command()
@click.pass_obj
def ap_p1_released_build(ctx):
    wft_interface_tool = ctx
    ap_latest_load = wft_interface_tool.get_ap_latest_load_released_or_released_with_restrictions('master_airphone')
    print(ap_latest_load)
    return


@main.command()
@click.pass_obj
def ap_p1_feature_candidate_build(ctx):
    wft_interface_tool = ctx
    ap_latest_load = wft_interface_tool.get_ap_latest_load_released_or_released_with_restrictions('master_airphone')
    release_with_restriction_candidate_build = \
        wft_interface_tool.get_ap_latest_load_with_test_result(project='master_airphone',
                                                               state=['RELEASED_WITH_RESTRICTIONS', 'RELEASED'],
                                                               test_result='Overall_P1-L3call',
                                                               l3call_status='RELEASED_WITH_RESTRICTIONS')
    release_candidate_build = \
        wft_interface_tool.get_ap_latest_load_with_test_result(project='master_airphone',
                                                               state=['RELEASED_WITH_RESTRICTIONS', 'RELEASED'],
                                                               test_result='Overall_P1-L3call',
                                                               l3call_status='RELEASED')
    ap_p1_feature_candidate_build = max(release_with_restriction_candidate_build, release_candidate_build)
    if ap_p1_feature_candidate_build\
            and wft_interface_tool.check_p1_global_func_status(ap_p1_feature_candidate_build,
                                                               identifier='overall_p1-feature'):
        print('')
        return
    if ap_p1_feature_candidate_build and (ap_p1_feature_candidate_build >= ap_latest_load):
        print(ap_p1_feature_candidate_build)
        return
    print('')
    return


@main.command()
@click.pass_obj
def select_p2_regression_ap_build(ctx):
    wft_interface_tool = ctx
    ap_latest_load = wft_interface_tool.get_ap_latest_load_for_p2_regression('master_airphone')
    print(ap_latest_load)
    return


if __name__ == '__main__':
    main()
