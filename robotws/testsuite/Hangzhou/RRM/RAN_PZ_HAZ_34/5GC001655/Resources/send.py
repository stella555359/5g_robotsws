import datetime
import requests


def send_fading_test_results(data):
    api = 'http://compass.eecloud.dynamic.nsn-net.net/others/api/hst_result/'
    per_page_count = 2000
    total_count = len(data)
    today = datetime.date.today().strftime('%Y-%m-%d')
    for page, index in enumerate(xrange(0, total_count, per_page_count)):
        if index + per_page_count < total_count:
            info = data[index:index + per_page_count]
        else:
            info = data[index:total_count]
        params = {'date': today,
                  'start': index,
                  'page': page + 1,
                  'results': info,
                  }
        response = requests.post(api, json=params)
        if response.status_code != 200:
            print('request params: %s' % params)
            raise Exception('failed to send data to dashboard via API. response:%s' % response.content)
    print('send fading test results to dashboard successfully.')


if __name__ == '__main__':
    data = [{"time": "0.0012", "lt": 12.4343},
            {"time": "0.0012", "lt": 12.4343},
            {"time": "0.0035", "st": -10.444},
            {"time": "0.0012", "lt": 12.4343}]

    send_fading_test_results(data)
