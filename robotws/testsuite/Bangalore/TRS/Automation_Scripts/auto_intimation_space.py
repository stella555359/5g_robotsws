####################################################################################
#   VERSION          DATE                AUTHOR                     	    COMMENTS
#   1.0              27-Oct-2022         nupur.rupram_kohadkar@nokia.com     Initial
#
####################################################################################

import argparse
import logging
import datetime
import os
import paramiko
import sys
import subprocess
import requests
import time
import json
import pandas as pd
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email import Encoders

###########################################################################################
filename = "/home/ute/LAB_Machines.csv"


###########################################################################################
def nice_print(message, sign='*'):
    print(''.join([' ', sign * len(message)]))
    print(''.join([' ', message]))
    print(''.join([' ', sign * len(message)]))
    logging.info(message)


def log(filename='machine_space_debug.log'):
    logging.basicConfig(filename=filename, level=logging.DEBUG, format='%(asctime)-6s: %(name)s - %(levelname)s - %('
                                                                       'message)s')
    console = logging.StreamHandler(stream=sys.stdout)
    console.setLevel(logging.WARNING)
    console.setFormatter(logging.Formatter('%(message)s'))
    logger = logging.getLogger()
    logger.addHandler(console)


def check_ping_status(ip):
    logging.debug("Checking Ping Status for {0}".format(ip))
    response = subprocess.check_output(["ping", "-c", "4", ip])
    if "4 received" in response:
        logging.debug("Ping Successful for {0}".format(ip))
        return "Ping Successful"
    else:
        logging.debug("Ping Unsuccessful for {0}".format(ip))
        return "Ping Unsuccessfull"


def ssh_to_vm(ip, vm_username, vm_password):
    try:
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(ip, username=vm_username, password=vm_password)
        return ssh_client

    except Exception as e:
        logging.error(e)
        return None


def read_machine_file():
    logging.info("Reading CSV File")
    df = pd.read_csv(filename)
    logging.info(df)
    df_new = df
    return df_new


def check_vm_space(df):
    logging.info("Checking VM Space")
    df["Ping Status"] = None
    df["SSH Status"] = None
    df["Current Space"] = None
    for i in range(len(df)):
        status = check_ping_status(df["Machine IP"][i])
        df["Ping Status"][i] = status
        ssh_client = ssh_to_vm(df["Machine IP"][i], df["Username"][i], df["Password"][i])
        if ssh_client is not None:
            df["SSH Status"][i] = "OK"
            stdin, stdout, stderr = ssh_client.exec_command("df -kh /root/")
            error = stderr.read().strip()
            if error == "":
                output = stdout.read().splitlines()
                space = output[1].strip().split()[-2]
                df["Current Space"][i] = space
            else:
                df["Current Space"][i] = error
        else:
            df["SSH Status"][i] = "NOK"
    logging.info(df)
    return df


def send_mail(df):
    logging.info("Consolidating Data and Sending Mail")
    df = df.drop("Username", axis='columns')
    df = df.drop("Password", axis='columns')
    print(df)
    to_list = []
    for i in range(len(df)):
        if "%" in df["Current Space"][i]:
            element = df["Current Space"][i]
            element = element.replace("%", "")
            if int(element) >= 80:
                to_list.append(df["POC"][i])
    df.to_csv("/home/ute/Machine_Space.csv")
    try:
        me = "Machine_Space@nokia.com"
        files = ["Machine_Space.csv"]
        sub_str = "Machine Space Report"
        msg = MIMEMultipart()
        msg['Subject'] = sub_str
        msg['From'] = me
        mail_body = "Hello, \n\nPlease find Virtual Machine Space Report"

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
        msg['To'] = ", ".join(to_list)

        server.sendmail(me, to_list, msg.as_string())

        logging.info("Mail Sent Successfully")

    except Exception as e:
        logging.info("Mail not sent due to {0}".format(e))


def main_block():
    log(filename=''.join(["machine_space_debug_", datetime.datetime.now().strftime("%y-%m-%d_%H-%M-%S"), ".log"]))
    df = read_machine_file()
    df = check_vm_space(df)
    send_mail(df)


if __name__ == "__main__":
    try:
        main_block()
    except KeyboardInterrupt as err:
        logging.debug(err)
        nice_print('Killed from keyboard!', '!')
