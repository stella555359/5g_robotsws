import sys
import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText
from email.MIMEBase import MIMEBase
from email import Encoders
import os


def sendstatusmail(build, mplane_ip):
    maillist = ["mahish_sivan.s@nokia.com"]
    me = "NetSparker_excution@nokia.com"
    files = ["report.html", "report.pdf"]
    mail_str = "Please check and analyze the reults"
    sub_str = "Netsparker Scan Execution "
    msg = MIMEMultipart()
    msg['Subject'] = sub_str
    msg['From'] = me
    mail_body = "Hello, \n\nPlease find NetSparker Scan Execution Report for: \nBuild : {0} \nMplane_IP : {1}} \n".\
        format(build, mplane_ip)

    for a_file in files:
        attachment = open(a_file, 'rb')
        file_name = os.path.basename(a_file)
        part = MIMEBase('application', 'octet-stream')
        part.set_payload(attachment.read())
        part.add_header('Content-Disposition',
                        'attachment',
                        filename=file_name)
        Encoders.encode_base64(part)
        msg.attach(part)

    msg.attach(MIMEText(mail_body))
    server = smtplib.SMTP('10.130.128.21')
    msg['To'] = ", ".join(maillist)

    server.sendmail(me, maillist, msg.as_string())
    print("Done")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Uasge: python sendmail.py Config_Type")
    sendstatusmail(sys.argv[1], sys.argv[2])
