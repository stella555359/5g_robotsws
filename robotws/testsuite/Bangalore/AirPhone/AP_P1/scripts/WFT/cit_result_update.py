import click
import requests
import urllib.parse
import yaml
import os
import sys
import json
import logging

log = logging.getLogger()
console = logging.StreamHandler()
log.addHandler(console)
log.setLevel(logging.INFO)


class CITResultUpdate():
    CIT_RESULT_FILE = os.path.join(sys.path[0], 'cit_results.yaml')

    def __init__(self):
        self.base_url = 'https://wft.int.net.nokia.com:8091/api/v1/TOOLS/airphone/builds'
        self.gnb_base_url = 'https://wft.int.net.nokia.com:8091/api/v1/SBTS/CI_ENB/builds'
        self.gnb_5g_base_url = 'https://wft.int.net.nokia.com:8091/api/v1/5G:WMP/5G_Central/builds'
        self.headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        self.access_key = 'S3roP5dXbVm4tlZnIhigteyuUHNlgt8mxe2566VD'
        self.cit_result = yaml.load(open(self.CIT_RESULT_FILE, 'r'), yaml.SafeLoader)
        self.min_number_of_suites = 5
        self.overall_p1_l3call_status = ''
        self.overall_p1_feature_status = ''
        self.global_p1_function_status = ''

    def update_result(self, build, identifier, status, link=''):
        if 'SBTS' in build:
            test_result_url = '{}/{}/test_results/{}.json?'.format(self.gnb_base_url,
                                                                   build, identifier)
        elif 'vDUCNF22R4' in build:
            test_result_url = '{}/{}/test_results/{}.json?'.format(self.gnb_5g_base_url,
                                                                   build, identifier)
        else:
            test_result_url = '{}/airphone_{}/test_results/{}.json?'.format(self.base_url,
                                                                            build, identifier)
        test_result_params = {'test_result[result]': status,
                              'test_result[link]': urllib.parse.quote_plus(link),
                              'access_key': self.access_key}
        param_string = '&'.join(['{}={}'.format(key, value) for key, value in test_result_params.items()])
        response = requests.post(test_result_url + param_string, headers=self.headers, verify=False)
        if response.status_code == 200:
            return True
        print('Setting Result {} to {} Failed'.format(identifier, build))
        return False

    def update_p1_release(self, build):
        self.is_all_test_result_present(build)
        release_status = self.is_all_p1_result_released(build)
        print('Setting Overall_P1-L3call Result as {} for {} build'.format(release_status, build))
        self.update_result(build, identifier='overall_p1-l3call', status=release_status)
        return

    def update_p1_feature_release(self, build, release_status):
        print('Setting Overall_P1-Feature_status Result as {} for {} build'.format(release_status, build))
        self.update_result(build, identifier='overall_p1-feature', status=release_status)
        return

    def update_p1_regression_release(self, build, release_status):
        print('Setting Overall_P1-Regression_status Result as {} for {} build'.format(release_status, build))
        self.update_result(build, identifier='p1_regression', status=release_status)
        return

    def get_p1_final_release_result(self, priority, build_test_results):
        results = {}
        p1_result = 'released'
        for stream in self.cit_result['P1_Results'][priority]:
            results[stream] = self.is_result_released(build_test_results, stream)
            if not (results[stream]):
                log.info('{} result is not released'.format(stream))

        result_values = results.values()
        if priority == 'Critical' and False in result_values:
            p1_result = 'not_released'

        elif priority == 'Major' and False in result_values:
            number_major_stream = len(results)
            if number_major_stream < self.min_number_of_suites:
                p1_result = 'released_with_restrictions'
            else:
                mandatory_success_runs = round(number_major_stream * (80.0 / 100.0))
                failed_results = list(result_values).count(False)
                if failed_results > mandatory_success_runs:
                    p1_result = 'not_released'

        return p1_result

    def is_all_p1_result_released(self, build):
        build_test_results = self.get_ap_load_test_results(build)
        p1_final_release_result = self.get_p1_final_release_result('Critical', build_test_results)
        if p1_final_release_result == 'released':
            p1_final_release_result = self.get_p1_final_release_result('Major', build_test_results)
        return p1_final_release_result

    def get_json_response(self, url, payload=None):
        data = json.dumps(payload)
        response = requests.get(url,
                                headers=self.headers,
                                data=data, verify=False)
        response_data = json.loads(response.text)
        return response_data

    def get_ap_load_test_results(self, build):
        url = '{}/airphone_{}/test_results.json?access_key={}'.format(self.base_url,
                                                                      build,
                                                                      self.access_key)
        return self.get_json_response(url)

    def is_result_released(self, build_test_results, p1_result):
        for build_test_result in build_test_results:
            if build_test_result['test_type']['identifier'] == p1_result and build_test_result['result'] == 'released':
                return True
        return False

    def is_test_result_present(self, priority, build):
        for stream in self.cit_result['P1_Results'][priority]:
            result_exists = self.is_test_result_present_for_stream(stream, build)
            if not result_exists:
                print('Overall P1 L3 tag will not be updated as all P1 stream tags are not present')
                exit(1)
        return

    def is_test_result_present_for_stream(self, stream, build):
        is_stream_present = False
        build_test_results = self.get_ap_load_test_results(build)
        for build_test_result in build_test_results:
            if stream == build_test_result['test_type']['identifier']:
                is_stream_present = True
                return is_stream_present
        return is_stream_present

    def is_all_test_result_present(self, build):
        self.is_test_result_present('Critical', build)
        self.is_test_result_present('Major', build)
        return

    def update_p1_global_release(self, build):
        self.get_overall_p1l3call_p1feature_status(build)
        if self.overall_p1_l3call_status == 'not_released' or \
                self.overall_p1_feature_status == 'not_released':
            self.global_p1_function_status = 'not_released'
        if self.global_p1_function_status != 'not_released':
            if self.overall_p1_l3call_status == 'released' and self.overall_p1_feature_status == 'released':
                self.global_p1_function_status = 'released'
            if self.overall_p1_l3call_status == 'released_with_restrictions' or \
                    self.overall_p1_feature_status == 'released_with_restrictions':
                self.global_p1_function_status = 'released_with_restrictions'
        print('Setting Global_P1-FUNC_status Result as {} for {} build'
              .format(self.global_p1_function_status, build))
        self.update_result(build, identifier='global_p1-func_status', status=self.global_p1_function_status)
        return

    def get_overall_p1l3call_p1feature_status(self, build):
        build_test_results = self.get_ap_load_test_results(build)
        for build_test_result in build_test_results:
            if build_test_result['test_type']['identifier'] == 'overall_p1-l3call':
                self.overall_p1_l3call_status = build_test_result['result']
            if build_test_result['test_type']['identifier'] == 'overall_p1-feature':
                self.overall_p1_feature_status = build_test_result['result']
        if self.overall_p1_l3call_status == '':
            print('Overall P1 L3 call tag is not present')
            self.overall_p1_l3call_status = 'not_released'
        if self.overall_p1_feature_status == '':
            print('Overall P1 Feature tag is not present')
            self.overall_p1_feature_status = 'not_released'
        return

    def update_gnb_p1_feature_release(self, result_file):
        with open(result_file, 'r') as json_file:
            gnb_p1_results = json.load(json_file)
        for key, p1_results in gnb_p1_results.items():
            for key, value in p1_results.items():
                wft_tag = 'gNB_P1_AP_' + key
                result = 'released' if value['status'] == 'Passed' else 'not_released'
                if (value['gnb_build']).startswith('vDUCNF'):
                    value['gnb_build'] = value['gnb_build'].split(',')[0]
                print('Setting {} Result as {} for {} build'.format(wft_tag, result, value['gnb_build']))
                self.update_result(value['gnb_build'], identifier=wft_tag, status=result)
        return


@click.group()
@click.pass_context
def main(ctx):
    ctx.obj = CITResultUpdate()
    return


@main.command()
@click.argument('build')
@click.argument('result')
@click.argument('status')
@click.argument('link')
@click.pass_obj
def cit_result_update(ctx, build, result, status, link):
    ctx.update_result(build, result, status, link)


@main.command()
@click.argument('build')
@click.pass_obj
def p1_release_update(ctx, build):
    ctx.update_p1_release(build)
    return


@main.command()
@click.argument('build')
@click.argument('result')
@click.pass_obj
def p1_feature_release_update(ctx, build, result):
    ctx.update_p1_feature_release(build, result)
    return


@main.command()
@click.argument('build')
@click.argument('result')
@click.pass_obj
def p1_regression_release_update(ctx, build, result):
    ctx.update_p1_regression_release(build, result)
    return


@main.command()
@click.argument('build')
@click.pass_obj
def p1_global_release_update(ctx, build):
    ctx.update_p1_global_release(build)
    return


@main.command()
@click.argument('json_result_file')
@click.pass_obj
def gnb_p1_release_update(ctx, json_result_file):
    ctx.update_gnb_p1_feature_release(json_result_file)
    return


if __name__ == '__main__':
    main()
