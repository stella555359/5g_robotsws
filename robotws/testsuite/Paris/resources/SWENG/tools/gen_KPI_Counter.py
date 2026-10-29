import subprocess
import sys
import argparse
import os
import importlib
import os
import logging
import datetime


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('args', nargs='+', help='List of arguments')
    return parser.parse_args()


def request_package(packId):
    url = "https://esnidd055.emea.nsn-net.net/nidd/Trans/Counter/CounterExportexcel"
    # Parameters to be sent in the GET request
    params = {
        'packageId': packId
    }
    req = importlib.import_module('requests')

    # TRACE: Log environment and authentication info
    print("TRACE: Connecting to NIDD...")
    print("TRACE: URL: {}".format(url))
    print("TRACE: Package ID: {}".format(packId))
    print("TRACE: HTTP_PROXY env: {}".format(os.environ.get('HTTP_PROXY', 'Not set')))
    print("TRACE: HTTPS_PROXY env: {}".format(os.environ.get('HTTPS_PROXY', 'Not set')))
    print("TRACE: USER env: {}".format(os.environ.get('USER', 'Not set')))

    response = req.get(url, params=params)

    # TRACE: Log request and response details
    print("TRACE: Request headers: {}".format(dict(response.request.headers)))
    print("TRACE: Response status: {}".format(response.status_code))
    print("TRACE: Response headers: {}".format(dict(response.headers)))
    print("TRACE: Response URL: {}".format(response.url))
    print("TRACE: Response history: {}".format(response.history))
    if hasattr(response, 'cookies'):
        print("TRACE: Response cookies: {}".format(dict(response.cookies)))

    if response.status_code == 200:
        # Save the response content to a file
        export_file = 'exported_file_' + packId + '.xlsx'
        with open(export_file, 'wb') as file:
            file.write(response.content)
        print("TRACE: File saved successfully: {}".format(export_file))
        logging.info("EXT_PARSE_INF----: File downloaded successfully.")
    else:
        print("TRACE: FAILED - Response text: {}".format(response.text[:500]))
        logging.error('EXT_PARSE_ERR----: Failed to download file - NIDD site. Code: {} '.format(response.status_code))
        exit(1)


def install(package):
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        logging.info("EXT_PARSE_INF----: Successfully installed {}", package)
    except subprocess.CalledProcessError as e:
        logging.error('EXT_PARSE_ERR----: Failed to install {} Error: {}'.format(package, e))


def import_with_auto_install(packages):
    results = []
    for package in packages:
        try:
            results.append(importlib.import_module(package))
        except ImportError:
            install(package)
            results.append(importlib.import_module(package))
            print("\n\ninstalling: {}\nfinal result = {}".format(package, results))
    return results


def write_to_file(el1, el2, file_path):
    try:
        with open(file_path, 'a') as f:
            # print('W_F el1={} el2={}'.format(str(el1), str(el2)))
            f.write(str(el1) + ';' + str(el2) + '\n')
    except Exception as e:
        logging.error('EXT_PARSE_ERR----: Error writing to file: {} Error: {}'.format(file_path, e))


def parse_xlsx(file_path, output_file):
    pd = importlib.import_module('pandas')
    df = pd.read_excel(file_path)
    data_as_list = df.values.tolist()

    if os.path.exists(output_file):
        # print('remove {} existing file'.format(output_file))
        os.remove(output_file)

    for idx, row in enumerate(data_as_list):
        if idx == 0 or idx == 1 or idx == 2 or idx == 3 or idx == 4 or idx == 5 or idx == 6:
            continue
        else:
            # 7 index
            el1 = None
            el2 = None
            for col, element in enumerate(row):
                if col == 0:
                    continue
                elif col == 1:
                    el1 = element
                elif col == 2:
                    el2 = element
                else:
                    # print('col_other={} el={}'.format(col, element))
                    if col > 2:
                        write_to_file(el1, el2, output_file)
                        break


def final_clean(file):
    if os.path.exists(file):
        os.remove(file)


def remove_empty(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()
    non_empty_lines = [line for line in lines if line.strip()]
    with open(output_file, 'w') as f:
        f.writelines(non_empty_lines)


def add_timestamp(p_file):
    now = datetime.datetime.now()
    formatted_date = now.strftime("# Version generated at %Y %m %d - %Hh%M")
    with open(p_file, 'r+') as file:
        content = file.read()
        file.seek(0)
        file.write(formatted_date + '\n' + content)


if __name__ == "__main__":
    args = get_args()

    results = import_with_auto_install(["pandas", "requests"])
    for packId in args.args:
        print('STEP: Requesting Data...')
        request_package(packId)
        export_file = 'exported_file_' + packId + '.xlsx'
        file_to_parse = 'exported_file_' + packId + '.xlsx'
        output_file = 'Counter_step1_' + packId + '.csv'
        no_empty_file = 'Counter_' + packId + '.csv'
        print('STEP: Generating final file(s). Please wait...')
        parse_xlsx(file_to_parse, output_file)
        remove_empty(output_file, no_empty_file)
        print('STEP: Result File : {}'.format(no_empty_file))
        add_timestamp(no_empty_file)
        final_clean(output_file)
        final_clean(export_file)
