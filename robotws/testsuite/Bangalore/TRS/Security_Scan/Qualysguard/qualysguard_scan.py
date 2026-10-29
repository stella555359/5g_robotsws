#######################################################################################################################
#   VERSION          DATE                AUTHOR                     	               COMMENTS
#   1.0              01-Aug-2022         nupur.rupram_kohadkar@nokia.com                Initial
#######################################################################################################################
import argparse
import datetime
import json
import logging
import os
import smtplib
import subprocess
import sys
import time
from email import Encoders
import xmltodict
from email.MIMEBase import MIMEBase
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

#######################################################################################################################
response_filename = "response.xml"


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
    parser = argparse.ArgumentParser(description='Script is use to Trigger QualysGaurd Scan.\r\n')
    parser.add_argument('--profile', action='store', dest='profile', help='Mention Profile Name')
    parser.add_argument('--name', action='store', dest='scan_name', help='Mention Scan Name')
    args = parser.parse_args()
    return (args)


def session_login(qualys_url):
    logging.info("session login for {0}".format(qualys_url))
    if qualys_url == "https://qualysapi.qg2.apps.qualys.eu/":
        qualys_username = "nkank5ns"
        qualys_password = "Nokia@123"
    elif qualys_url == "https://qualysapi.qg1.apps.qualys.in/":
        qualys_username = "nkasu8mt"
        qualys_password = "Trsiv123$"
    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -c cookies.txt -d 'action=login&username={0}&" \
               "password={1}' '{2}api/2.0/fo/session/' > {3}".format(qualys_username, qualys_password, qualys_url,
                                                                     response_filename)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = response_dict["SIMPLE_RETURN"]["RESPONSE"]["TEXT"]
    if response_text != "Logged in":
        logging.error(response_text)
        sys.exit(1)
    logging.debug(response_text)


def xml_to_dict(filename):
    logging.info("Converting xml to dict")
    with open(filename) as xml_file:
        data_dict = xmltodict.parse(xml_file.read())
    return data_dict


def check_scanner_status(qualys_url, scanner_name):
    logging.info("Checking Scanner Appliance Status for {0}".format(scanner_name))
    curl_cmd = "curl -b cookies.txt -H 'X-Requested-With: Curl' -d 'action=list&name={0}&" \
               "include_license_info=1' '{1}api/2.0/fo/appliance/' > {2}".format(scanner_name, qualys_url,
                                                                                 response_filename)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = response_dict["APPLIANCE_LIST_OUTPUT"]["RESPONSE"]["APPLIANCE_LIST"]["APPLIANCE"]["STATUS"]
    if response_text != "Online":
        logging.error("Scanner Status is {0}".format(response_text))
        session_logout(qualys_url)
        sys.exit(1)
    logging.debug("Scanner Status is {0}".format(response_text))


def launch_scan(qualys_url, option_title, scanner_name, ip, scan_name):
    logging.info("Launching Scan for {0} with {1} {2} {3}".format(qualys_url, option_title, scanner_name, ip))
    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -b 'cookies.txt' -X 'POST' -d 'action=launch&scan_title={0}&" \
               "ip={1}&option_title={2}&iscanner_name={3}&priority=1' '{4}api/2.0/fo/scan/' > {5}".format(
                scan_name,
                ip,
                option_title,
                scanner_name,
                qualys_url,
                response_filename)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = response_dict["SIMPLE_RETURN"]["RESPONSE"]["TEXT"]
    if response_text != "New vm scan launched":
        logging.error(response_text)
        session_logout(qualys_url)
        sys.exit(1)
    logging.debug(response_text)
    key_value = response_dict['SIMPLE_RETURN']['RESPONSE']["ITEM_LIST"]["ITEM"][1]["VALUE"]
    return key_value


def session_logout(qualys_url):
    logging.info("session logout for {0}".format(qualys_url))
    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -d 'action=logout' -b 'cookies.txt' '{0}api/2.0/fo/session/' " \
               "> {1}".format(qualys_url, response_filename)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = response_dict["SIMPLE_RETURN"]["RESPONSE"]["TEXT"]
    if response_text != "Logged out":
        logging.error(response_text)
        sys.exit(1)
    logging.debug(response_text)


def get_scan_status(qualys_url, key_value):
    logging.info("Checking current scan status for {0}".format(key_value))
    curl_cmd = "curl -b 'cookies.txt' -H 'X-Requested-With: Curl' '{0}api/2.0/fo/scan/vm/summary/?action=list&" \
               "output_format=xml&scan_reference={1}' > {2}".format(qualys_url, key_value, response_filename)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = \
        response_dict["SCAN_SUMMARY_OUTPUT"]["RESPONSE"]["SCAN_SUMMARY_LIST"]["SCAN_SUMMARY"]["SCAN_DETAILS"]["STATUS"]
    logging.debug("Scan status :{0}".format(response_text))
    return response_text


def check_scan_status(qualys_url, key_value):
    logging.info("Checking scan status for {0}".format(key_value))
    for i in range(300):
        status = get_scan_status(qualys_url, key_value)
        if status == "FINISHED":
            return status
        elif status == "ERROR":
            return status
        elif status == "NOHOSTALIVE":
            return status
        elif status == "CANCELED":
            return status
        else:
            time.sleep(60)
    return None


def generate_scan_report(qualys_url, key_value, template_id):
    logging.info("Generating Report for {0}".format(key_value))
    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -b cookies.txt -d 'action=launch&" \
               "template_id={3}&output_format=pdf&report_type=Scan&" \
               "report_refs={0}' '{1}api/2.0/fo/report/' > {2}".format(key_value, qualys_url, response_filename,
                                                                       template_id)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = response_dict["SIMPLE_RETURN"]["RESPONSE"]["TEXT"].lower()
    if response_text != "new report launched":
        logging.error(response_text)
        session_logout(qualys_url)
        sys.exit(1)
    pdf_report_id = response_dict["SIMPLE_RETURN"]["RESPONSE"]["ITEM_LIST"]["ITEM"]["VALUE"]
    logging.info("PDF Report ID : {0}".format(pdf_report_id))

    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -b cookies.txt -d 'action=launch&" \
               "template_id={3}&output_format=xml&" \
               "report_type=Scan&report_refs={0}' '{1}api/2.0/fo/report/' > {2}".format(key_value, qualys_url,
                                                                                        response_filename, template_id)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    response_dict = xml_to_dict(response_filename)
    response_text = response_dict["SIMPLE_RETURN"]["RESPONSE"]["TEXT"].lower()
    if response_text != "new report launched":
        logging.error(response_text)
        session_logout(qualys_url)
        sys.exit(1)
    xml_report_id = response_dict["SIMPLE_RETURN"]["RESPONSE"]["ITEM_LIST"]["ITEM"]["VALUE"]
    logging.info("PDF Report ID : {0}".format(xml_report_id))
    return pdf_report_id, xml_report_id


def download_report(pdf_report_id, xml_report_id, qualys_url):
    logging.info("Downloading PDF Report for {0}".format(pdf_report_id))
    logging.info("Downloading XML Report for {0}".format(xml_report_id))
    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -b cookies.txt '{0}api/2.0/fo/report/?action=fetch&" \
               "id={1}' > scan_report.pdf".format(qualys_url, pdf_report_id)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    curl_cmd = "curl -H 'X-Requested-With: Curl Sample' -b cookies.txt '{0}api/2.0/fo/report/?action=fetch&" \
               "id={1}' > scan_report.xml".format(qualys_url, xml_report_id)
    logging.debug(curl_cmd)
    os.system(curl_cmd)
    logging.info("Report Downloaded Successfully")


def SendMail(scan_name):
    try:
        maillist = ["prabakar.sanikommu@nokia.com", "nupur.rupram_kohadkar@nokia.com"]
        me = "Qualysgaurd_Excution@nokia.com"
        files = ["scan_report.xml", "scan_report.pdf", "output.json"]
        sub_str = "QualysGaurd Scan Report for {0}".format(scan_name)
        msg = MIMEMultipart()
        msg['Subject'] = sub_str
        msg['From'] = me
        mail_body = "Hello, \n\nPlease find QualysGaurd Scan Execution Report"

        for a_file in files:
            attachment = open(a_file, 'rb')
            file_name = os.path.basename(a_file)
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(attachment.read())
            part.add_header('Content-Disposition', 'attachment', filename=file_name)
            Encoders.encode_base64(part)
            msg.attach(part)

        msg.attach(MIMEText(mail_body))
        server = smtplib.SMTP('10.130.128.21')
        msg['To'] = ", ".join(maillist)

        server.sendmail(me, maillist, msg.as_string())

        logging.info("Mail Sent Successfully")

    except Exception as e:
        logging.info("Mail not sent due to {0}".format(e))


def main_block():
    args = args_parser()
    log(filename=''.join(["QualysGuard_Scan", datetime.datetime.now().strftime("%y-%m-%d_%H-%M-%S"), ".log"]))
    logging.debug(args)
    profile = args.profile
    scan_name = args.scan_name
    pwd = subprocess.check_output('pwd')
    pwd = pwd.strip("\n")
    file = open("{0}/qualys_info.json".format(pwd))
    data = json.load(file)
    qualys_url = data["profile"][profile]["url"]
    option_title = data["profile"][profile]["option_title"]
    scanner_name = data["profile"][profile]["scanner_name"]
    ip = data["profile"][profile]["ip"]
    template_id = data["profile"][profile]["template_id"]

    session_login(qualys_url)
    check_scanner_status(qualys_url, scanner_name)
    key_value = launch_scan(qualys_url, option_title, scanner_name, ip, scan_name)
    scan_status = check_scan_status(qualys_url, key_value)
    if scan_status is not None:
        if scan_status == "FINISHED":
            logging.info("Scan Finished Successfully.")
            pdf_report_id, xml_report_id = generate_scan_report(qualys_url, key_value, template_id)
            time.sleep(120)
            download_report(pdf_report_id, xml_report_id, qualys_url)
            # upload_vams()
            # SendMail(scan_name)
            print("Scan Completed Successfully !!")
        else:
            logging.error("Scan is Failed due to Status {0}".format(scan_status))
    else:
        logging.error("Scan is not completed in 1800 Sec")
    session_logout(qualys_url)

    SendMail(scan_name)


if __name__ == "__main__":
    try:
        main_block()
    except KeyboardInterrupt as err:
        logging.debug(err)
        nice_print('Killed from keyboard!', '!')
