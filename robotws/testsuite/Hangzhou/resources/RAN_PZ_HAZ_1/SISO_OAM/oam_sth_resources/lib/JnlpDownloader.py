import requests
# from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
from logging import info
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
import re

NETACT_URL = ''
LOGIN_URL = ''
TRACE_URL = ''

LOGIN_PAYLOAD = {'login:password': '', 'login:username': '', 'login_SUBMIT': '1', 'login:loginButton': 'Log In',
                 'javax.faces.ViewState': ''}
LEGAL_TEXT_PAYLOAD = {'login:legalPanelCloseButton': 'Accept', 'login_SUBMIT': '1', 'javax.faces.ViewState': ''}


def _update_payload_with_view_state_value(payload, page):
    match = re.search("<[^<]+javax.faces.ViewState[^>]+>", page.text)
    if not match:
        raise Exception("Unable to locate javax.faces.ViewState")
    else:
        info(match.group(0))
        match = re.search("value=\"([^\"]+)\"", match.group(0))
        info(match.group(1))
        view_state_value = match.group(1)
        payload['javax.faces.ViewState'] = view_state_value


def _login_to_netact(session, username, password):
    login_page = session.get(LOGIN_URL, verify=False)
    info(login_page.url)
    LOGIN_PAYLOAD['login:password'] = password
    LOGIN_PAYLOAD['login:username'] = username
    _update_payload_with_view_state_value(LOGIN_PAYLOAD, login_page)
    info(str(LOGIN_PAYLOAD))
    login_page = session.post(LOGIN_URL, data=LOGIN_PAYLOAD, verify=False)
    if "Login failed" in login_page.content.decode("UTF-8"):
        raise Exception("Login Failed!")
    legal_text_page = session.get(login_page.url, verify=False)
    _update_payload_with_view_state_value(LEGAL_TEXT_PAYLOAD, login_page)
    return session.post(legal_text_page.url, data=LEGAL_TEXT_PAYLOAD, verify=False)


def _save_file(jnlp_file, download_file_path):
    with open(download_file_path, 'wb') as f:
        for chunk in jnlp_file.iter_content(chunk_size=1024):
            if chunk:
                f.write(chunk)


def download_jnlp_file(download_file_path, username, password, fqdn):
    global NETACT_URL, LOGIN_URL, TRACE_URL
    NETACT_URL = "https://" + fqdn
    LOGIN_URL = NETACT_URL + "/authentication/authentication/login.jsp"
    TRACE_URL = NETACT_URL + "/trc-war/StartupServlet"
    with requests.Session() as s:
        info("Loging in to netact...")
        _login_to_netact(s, username, password)
        info("Login is sucessful. Downloading jnlp file..")
        jnlp_file = s.get(TRACE_URL, stream=True, verify=False)
        _save_file(jnlp_file, download_file_path)
        info("Download is successful, file is stored to %s" % download_file_path)
