import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


class Email:
    def __init__(self):
        self.email_server = smtplib.SMTP("mail.emea.nsn-intra.net")

    def send(self, email, subject, body, text_file=None):
        msg = MIMEMultipart()
        msg["Subject"] = subject
        msg["From"] = email
        msg["To"] = email
        msg.attach(MIMEText(body.replace("\n", "<br/>\n"), "html"))
        if text_file:
            with open(text_file, newline="") as f_h:
                attachment = MIMEText(f_h.read())
                attachment.add_header("Content-Disposition", "attachment", filename=f_h.name)
            msg.attach(attachment)
        self.email_server.send_message(msg)

    def __del__(self):
        self.email_server.quit()
