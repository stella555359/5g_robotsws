#######################################################################################################################
#   VERSION          DATE                AUTHOR                     	               COMMENTS
#   1.0              01-Feb-2022         nupur.rupram_kohadkar@nokia.com                Initial
#######################################################################################################################
import argparse
import datetime
import json
import logging
import shlex
import subprocess
import sys
import time
import requests
from exceptions import *


#######################################################################################################################


def nice_print(message, sign='*'):
    print(''.join([' ', sign * len(message)]))
    print(''.join([' ', message]))
    print(''.join([' ', sign * len(message)]))
    logging.info(message)


def log(filename='airphone_update.log'):
    logging.basicConfig(filename=filename, level=logging.DEBUG,
                        format='%(asctime)-6s: %(name)s - %(levelname)s - %(message)s')
    console = logging.StreamHandler(stream=sys.stdout)
    console.setLevel(logging.WARNING)
    console.setFormatter(logging.Formatter('%(message)s'))
    logger = logging.getLogger()
    logger.addHandler(console)


def args_parser():
    parser = argparse.ArgumentParser(description='Script is use to Automate Netsparker.\r\n')
    parser.add_argument('--mplane', action='store', dest='mplane', help='Mention M-Plane')
    args = parser.parse_args()
    return (args)


def register_mplane(mplane_ip):
    logging.info("Register Mplane")
    url = "https://dyndns-api.nesc.nokia.net/dyndns/replace/ivbtsblr000/A?data=" + mplane_ip
    logging.info(url)
    response = requests.get(url=url, verify=False)
    data = response.json()
    logging.info(data)
    if data['status'] == 200:
        return data['request']['record']
    else:
        logging.error(data['status'])
        sys.exit(1)


def start_scan(netsparker_url):
    logging.info(netsparker_url)
    curl_cmd = "curl -X POST --header {0} --header {1} --header {2} -d '{ {3} : {4}, {5} : {6},  {7}': { {8}: [{" \
               " {9} : {10}, {11}: {12}, {13}: {14}, {15}: {16}, {17}: {18}, {19}: {20} }], {21}: {22}," \
               "{23}: {24} } {25}: {26}, {27}: {28}, {29}: {30}, {31}: {32}, {33}: {34}, {35}: {36}, {37}: {38}," \
               "{39}: {40}, {41}: {42}, {43}: {44}, {45}: {46}, {47}: [{ {48}: {49} }], {50}: { {51}: {52}}, " \
               "{53}: {54}, {55}: {56} }' {57}".format('Content-Type: application/json',
                                                       'Accept: application/json',
                                                       'Authorization: Basic ZTEyZDBjMGU0NTczNGMyZjNmMTRhYzc4MDI2MGMzYW'
                                                       'Y6Q2EzK3pndmtaYXJ3NHZHUzZrd1hhRnB0R1RHV01HQjNDTXQxcXRWL2p6MD0=',
                                                       "TargetUri", "https://ivbtsblr000.dyn.nesc.nokia.net/",
                                                       "AgentName", "MN_TRS_PZ_BTS_SRAN", "BasicAuthenticationApiModel",
                                                       "Credentials", "AuthenticationType", "Basic", "Domain",
                                                       "example.com", "Password", "pass", "UriPrefix",
                                                       "http://example.com/", "UserName", "user",
                                                       "IsReplacedCredentials", "false", "IsEnabled", True,
                                                       "NoChallenge", False, "CrawlAndAttack", True,
                                                       "FindAndFollowNewLinks", True, "AuthenticationProfileOption",
                                                       "DontUse", "IsMaxScanDurationEnabled", False,
                                                       "MaxDynamicSignatures", 60, "MaxScanDuration", 48,
                                                       "Scope", "EnteredPathAndBelow", "SubPathMaxDynamicSignatures",
                                                       30, "UrlRewriteAnalyzableExtensions", "htm,html",
                                                       "UrlRewriteBlockSeparators", "/$.,;|:", "UrlRewriteMode",
                                                       "Heuristic", "UrlRewriteRules", "PlaceholderPattern",
                                                       "/blog/{category}/{title}", "PreRequestScriptSetting",
                                                       "IsEnabled", False, "DoNotDifferentiateProtocols", True,
                                                       "EnablePciScanTask", False,
                                                       "http://netsparker.int.net.nokia.com/api/1.0/scans/new")
    arguments = shlex.split(curl_cmd)
    process = subprocess.Popen(arguments, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    logging.info(stdout)
    if stdout is None:
        logging.error(stderr)
        sys.exit(1)
    json_content = stdout.decode('utf8').replace("'", '"')
    data = json.loads(json_content)
    logging.info(data[0]['Id'])
    return data[0]['Id']


def scan_status(scan_id):
    logging.info(scan_id)
    curl_cmd = "curl -X GET --header {0} --header {1} {2}{3}".format(
        'Accept: application/json',
        'Authorization: Basic '
        'ZTEyZDBjMGU0NTczNGMyZjNmMTRhYzc4MDI2MGMzYWY6Q2EzK3pndmtaYXJ3NHZHUzZrd1hhRnB0R1RHV01HQjNDTXQxcXRWL2p6MD0=',
        'http://netsparker.int.net.nokia.com/api/1.0/scans/status/', scan_id)
    logging.debug(curl_cmd)
    arguments = shlex.split(curl_cmd)
    process = subprocess.Popen(arguments, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    if stdout is None:
        logging.error(stderr)
        sys.exit(1)
    json_content = stdout.decode('utf8').replace("'", '"')
    data = json.loads(json_content)
    logging.info(data["State"])
    return data["State"]


def check_scan_status(scan_id):
    for i in range(60):
        status = scan_status(scan_id)
        if status == "Complete":
            return status
        elif status == "Failed":
            return status
        else:
            time.sleep(60)
    logging.error("scan not completed in 60 mins")
    sys.exit(1)


def generate_scan_report(scan_id):
    logging.info(scan_id)
    curl_cmd = "curl -X GET --header {0} --header {1} {2}{3}{4}".format(
        'Accept: application/pdf',
        'Authorization: Basic '
        'ZTEyZDBjMGU0NTczNGMyZjNmMTRhYzc4MDI2MGMzYWY6Q2EzK3pndmtaYXJ3NHZHUzZrd1hhRnB0R1RHV01HQjNDTXQxcXRWL2p6MD0=',
        'http://netsparker.int.net.nokia.com/api/1.0/scans/report/?contentFormat=Html&format=Pdf&id=', scan_id,
        '&type=ScanDetail')
    logging.info(curl_cmd)
    logging.debug(curl_cmd)
    arguments = shlex.split(curl_cmd)
    process = subprocess.Popen(arguments, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    filename = "report.pdf"
    f = open(filename, "w")
    f.write(stdout)
    f.close()

    curl_cmd = "curl -X GET --header {0} --header {1} {2}{3}{4}".format(
        'Accept: text/html',
        'Authorization: Basic '
        'ZTEyZDBjMGU0NTczNGMyZjNmMTRhYzc4MDI2MGMzYWY6Q2EzK3pndmtaYXJ3NHZHUzZrd1hhRnB0R1RHV01HQjNDTXQxcXRWL2p6MD0=',
        'http://netsparker.int.net.nokia.com/api/1.0/scans/report/?contentFormat=Html&format=Html&id=', scan_id,
        '&type=ScanDetail')
    logging.info(curl_cmd)
    logging.debug(curl_cmd)
    arguments = shlex.split(curl_cmd)
    process = subprocess.Popen(arguments, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    filename = "report.html"
    f = open(filename, "w")
    f.write(stdout)
    f.close()


def main_block():
    args = args_parser()
    log(filename=''.join(["Netsparker_Scan", datetime.datetime.now().strftime("%y-%m-%d_%H-%M-%S"), ".log"]))
    logging.debug(args)
    netsparker_url = register_mplane(args.mplane)
    scan_id = start_scan(netsparker_url)
    status = check_scan_status(scan_id)
    if status == "Failed":
        logging.error("Scan Failed")
        sys.exit(1)
    logging.debug(status)
    generate_scan_report(scan_id)


if __name__ == "__main__":
    try:
        main_block()
    except KeyboardInterrupt as err:
        logging.debug(err)
        nice_print('Killed from keyboard!', '!')
