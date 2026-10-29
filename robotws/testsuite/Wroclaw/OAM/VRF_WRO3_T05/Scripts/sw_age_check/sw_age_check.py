#!/usr/bin/env python3

import subprocess
import requests
from datetime import datetime
from zoneinfo import ZoneInfo
from urllib.parse import quote
from dataclasses import dataclass
import html


OCP_USER, OCP_PASS = "core", "system123"
FHGW_USER, FHGW_PASS = "toor4nsn", "Fhgw@nokia12435"
SSH_OPTIONS = (
    "-o StrictHostKeyChecking=no "
    "-o UserKnownHostsFile=/dev/null "
    "-o LogLevel=ERROR "
    "-o ConnectTimeout=5"
)
WFT_API_BASE = "https://wft.int.net.nokia.com:8091"
# Align RANDOM with sw_age_check.py
RANDOM = "77OCG96OrO7VlVmb2SVKe0tgItE5z2uFO0G16jh7"
LOCAL_TZ = ZoneInfo("Europe/Warsaw")
SCRIPT_TS = datetime.now(LOCAL_TZ)
OUTFILE = f"OCP_FHGW_check_{SCRIPT_TS.strftime('%Y%m%d_%H%M%S')}.txt"
HTMLFILE = f"OCP_FHGW_check_latest.html"

# Merge SERVERS inventory from sw_age_check.py and preserve CRAN_NoName/multi-IP from JK
SERVERS = {
    "8516": {"vCU": "10.42.38.37", "vDU": "10.42.38.37", "group": "T04"},
    "8517": {"vCU": "10.42.38.36", "vDU": "10.42.38.36", "group": "T04"},
    "8521": {"vCU": "10.45.186.3", "vDU": "10.45.186.3", "group": "T04"},
    "8523": {"vCU": "10.42.91.162", "vDU": "10.45.186.4", "group": "T04"},
    "8524": {"vCU": "10.45.186.5", "vDU": "10.45.186.5", "group": "T04"},
    "8525": {"vCU": "10.45.186.6", "vDU": "10.45.186.6", "group": "T04"},
    "8526": {"vCU": "10.45.186.7", "vDU": "10.45.186.7", "group": "T04"},
    "8685": {"vCU": "10.42.91.147", "vDU": "10.42.38.54", "group": "T04"},
    "8686": {"vCU": "10.42.91.147", "vDU": "10.42.38.53", "group": "T04"},
    "8690": {"vCU": "10.45.186.17", "vDU": "10.45.186.8", "group": "T04"},
    "8850": {"vCU": "10.42.38.42", "vDU": "10.42.38.42", "group": "T04"},
    "8867": {"vCU": "10.42.139.36", "vDU": "10.42.139.36", "group": "T04"},
    "8694": {"vCU": "10.45.186.65", "vDU": "10.45.186.65", "group": "T04"},
    "Dedal": {"vCU": "10.42.139.49", "vDU": "10.42.139.49", "group": "T05"},
    "Ikar": {"vCU": "10.42.139.10", "vDU": "10.42.139.10", "group": "T05"},
    "Ozzy": {"vCU": "10.42.91.162", "vDU": "10.42.139.35", "group": "T05"},
    "Diuna": {"vCU": "10.42.139.11", "vDU": "10.42.139.11", "group": "T05"},
    "NaVi": {"vCU": "10.42.91.162", "vDU": "10.42.139.12", "group": "T05"},
    "Jolka": {"vCU": "10.42.69.153", "vDU": "10.42.139.14", "group": "T05"},
    "Aurora": {"vCU": "10.42.139.40", "vDU": "10.42.139.40", "group": "T05"},
    "Zaraza1": {"vCU": "10.42.69.131", "vDU": "10.42.139.8", "group": "T05"},
    "Zaraza2": {"vCU": "10.42.69.164", "vDU": "10.42.139.15", "group": "T05"},
    "Joker": {"vCU": "10.42.139.9", "vDU": "10.42.139.9", "group": "T05"},
    "Cerber1": {"vCU": "10.42.69.155", "vDU": "10.42.139.7", "group": "T05"},
    "Cerber2": {"vCU": "10.42.69.155", "vDU": "10.42.139.6", "group": "T05"},
    "Skarpeta1": {"vCU": "10.42.102.137", "vDU": "10.42.139.23", "group": "T05"},
    "Skarpeta2": {"vCU": "10.42.102.171", "vDU": "10.42.38.40", "group": "T05"},
    "Licek": {"vCU": "10.42.38.31", "vDU": "10.42.38.31", "group": "T05"},
    "CRAN_NoName": {"vCU": "10.42.91.162", "vDU": ["10.42.139.44", "10.42.139.45", "10.42.139.46"], "group": "T05"},
}

# Merge FHGW inventory from sw_age_check.py
FHGW = {
    "8521": {"IP": "10.44.249.196", "group": "T04"},
    "8523": {"IP": "10.44.249.198", "group": "T04"},
    "8524": {"IP": "10.44.249.200", "group": "T04"},
    "8525": {"IP": "10.44.249.202", "group": "T04"},
    "8526": {"IP": "10.44.249.204", "group": "T04"},
    "8686": {"IP": "10.44.44.166", "group": "T04"},
    "8690": {"IP": "10.44.44.166", "group": "T04"},
    "8867": {"IP": "10.42.138.153", "group": "T04"},
    "8694": {"IP": "10.44.44.118", "group": "T04"},
    "Dedal": {"IP": "10.42.103.184", "group": "T05"},
    "Ikar": {"IP": "10.42.103.186", "group": "T05"},
    "Ozzy": {"IP": "10.42.103.168", "group": "T05"},
    "NaVi": {"IP": "10.42.103.180", "group": "T05"},
    "Jolka": {"IP": "10.42.103.166", "group": "T05"},
    "Aurora": {"IP": "10.42.103.182", "group": "T05"},
    "Joker": {"IP": "10.42.138.41", "group": "T05"},
    "Cerber1": {"IP": "10.42.103.172", "group": "T05"},
    "Cerber2": {"IP": "10.42.103.170", "group": "T05"},
    "Licek": {"IP": "10.44.44.116", "group": "T05"}
}


OCP_CMD = "oc get nokiaclusters.nokia.com -o yaml | grep nokiaRelease:"
FHGW_CMD = "cat /etc/fhgw-release"


@dataclass
class Result:
    node: str
    role: str
    ip: str
    sw: str
    delivery_date: str
    age: str
    group: str = "N/A"
    error: str = ""


def run_ssh(ip, user, pwd, cmd, login_shell=False):
    shell = f'bash -l -c \'{cmd}\'' if login_shell else cmd
    full_cmd = f'sshpass -p "{pwd}" ssh {SSH_OPTIONS} {user}@{ip} "{shell}"'
    try:
        return subprocess.check_output(full_cmd, shell=True, text=True).strip()
    except subprocess.CalledProcessError as e:
        return f"SSH error: {e.output}"


def fetch_wft(sw_type, baseline):
    url = f"{WFT_API_BASE}/api/v1/{sw_type}/builds/{quote(baseline)}.json?strict_search=true&access_key={RANDOM}"
    try:
        resp = requests.get(url, verify=True, timeout=15)
        return resp.json() if resp.status_code == 200 else None
    except Exception:
        return None


def parse_datetime(s):
    try:
        return datetime.fromisoformat(s.replace("Z", "+00:00")).astimezone(LOCAL_TZ) if s else None
    except Exception:
        return None


def calc_age(delivery_dt):
    return f"{(SCRIPT_TS - delivery_dt).days}days old" if delivery_dt else "N/A"


def process_ocp(nick, role, ip):
    out = run_ssh(ip, OCP_USER, OCP_PASS, OCP_CMD)
    baseline = next(
        (
            line.split(":", 1)[1].strip()
            for line in out.splitlines()
            if "nokiaRelease:" in line
        ),
        None
    )
    if not baseline:
        return Result(nick, role, ip, "N/A", "N/A", "N/A", "N/A", "No OCP version found")
    wft = fetch_wft("ECP%3ACloudInfra/ocp", baseline)
    delivery = parse_datetime(wft.get("delivery_date")) if wft else None
    return Result(
        nick,
        role,
        ip,
        baseline,
        delivery.isoformat() if delivery else "N/A",
        calc_age(delivery),
        "N/A",
        "" if wft else "WFT API error",
    )


def process_fhgw(nick, ip, group):
    out = run_ssh(
        ip, FHGW_USER, FHGW_PASS, FHGW_CMD, login_shell=True
    )
    fhgw_sw = next(
        (
            line.split("=", 1)[1].strip().replace("_base", "")
            for line in out.splitlines()
            if line.startswith("DELIVERY=")
        ),
        None,
    )
    if not fhgw_sw:
        return Result(nick, "FHGW", ip, "N/A", "N/A", "N/A", group, "DELIVERY not found")
    wft = fetch_wft("Common/FHGW", fhgw_sw)
    delivery = parse_datetime(wft.get("delivery_date")) if wft else None
    return Result(
        nick,
        "FHGW",
        ip,
        fhgw_sw,
        delivery.isoformat() if delivery else "N/A",
        calc_age(delivery),
        group,
        "" if wft else "WFT API error",
    )


def txt_to_html(txt_path, html_path):
    def get_color(role, age_str):
        try:
            days = int(age_str.split('days')[0])
        except Exception:
            return "badge-gray"
        if role == "FHGW":
            if days > 7:
                return "badge-red"
            elif 5 < days <= 7:
                return "badge-yellow"
            else:
                return "badge-green"
        else:  # OCP
            if days > 25:
                return "badge-red"
            elif 20 < days <= 25:
                return "badge-yellow"
            else:
                return "badge-green"
        return "badge-gray"

    with open(txt_path) as f, open(html_path, "w", encoding="utf-8") as h:
        h.write("<html><head>\n")
        h.write("""<link rel=\"stylesheet\" href=\"static/style.css\">\n""")
        h.write("""<script src=\"static/filter.js\"></script>\n""")
        h.write("</head><body>\n")
        h.write("""<div id=\"filter-bar\"></div>\n""")
        h.write("<table>\n")
        for i, line in enumerate(f):
            cells = [html.escape(cell) for cell in line.strip().split('\t')]
            if i == 0:
                # Header row - skip Group column (idx 6)
                h.write("<tr>")
                for idx, cell in enumerate(cells):
                    if idx == 6:
                        # Skip Group column - it's in data-group attribute, not displayed
                        pass
                    elif idx == 0:
                        h.write('<th id="node-th"></th>')
                    elif idx == 1:
                        h.write('<th id="role-th"></th>')
                    else:
                        h.write(f"<th>{cell}</th>")
                h.write("</tr>\n")
            else:
                # Data rows - extract group for filtering, skip from display
                group_value = cells[6] if len(cells) > 6 else "N/A"
                h.write(f'<tr data-group="{group_value}">')
                for idx, cell in enumerate(cells):
                    if idx == 6:
                        # Skip Group column - it's stored in data-group attribute
                        pass
                    elif idx == 5:  # Age column - add color
                        color_class = get_color(cells[1], cell)
                        cell = f"<span class='{color_class}'>{cell}</span>"
                        h.write(f"<td>{cell}</td>")
                    else:
                        h.write(f"<td>{cell}</td>")
                h.write("</tr>\n")
        h.write("</table>\n")
        h.write("</body></html>")


def main():
    print(f"Script timestamp: {SCRIPT_TS.isoformat()}")
    ocp_cache = {}  # ip -> (baseline, error)
    wft_cache = {}  # baseline -> wft_result
    with open(OUTFILE, "w") as f:
        f.write("Node\tRole\tIP\tSW\tDeliveryDate\tAge\tError\n")
        # OCP section
        for nick, addrs in SERVERS.items():
            group = addrs.get("group", "N/A")
            ip_roles = {}
            for role in ("vCU", "vDU"):
                ips = addrs.get(role)
                # Accept both str and list for IPs
                if ips:
                    if isinstance(ips, str):
                        ips = [ips]
                    for ip in ips:
                        ip_roles.setdefault(ip, []).append(role)
            for ip, roles in ip_roles.items():
                # Only run SSH once per IP
                if ip not in ocp_cache:
                    out = run_ssh(ip, OCP_USER, OCP_PASS, OCP_CMD)
                    baseline = next(
                        (
                            line.split(":", 1)[1].strip()
                            for line in out.splitlines()
                            if "nokiaRelease:" in line
                        ),
                        None
                    )
                    ocp_cache[ip] = (baseline, out if baseline else "No OCP version found")
                baseline, error = ocp_cache[ip]
                # Cache WFT API results per baseline
                if baseline and baseline not in wft_cache:
                    wft_cache[baseline] = fetch_wft("ECP%3ACloudInfra/ocp", baseline)
                wft = wft_cache.get(baseline) if baseline else None
                delivery = parse_datetime(wft.get("delivery_date")) if wft else None
                for role in roles:
                    res = Result(
                        nick,
                        role,
                        ip,
                        baseline if baseline else "N/A",
                        delivery.isoformat() if delivery else "N/A",
                        calc_age(delivery),
                        group,
                        "" if wft else error if not baseline else "WFT API error"
                    )
                    line = (f"{res.node}\t{res.role}\t{res.ip}\t{res.sw}\t{res.delivery_date}"
                            f"\t{res.age}\t{res.group}\t{res.error}")
                    print(line)
                    f.write(line + "\n")
        # FHGW section
        for nick, data in FHGW.items():
            group = data.get("group", "N/A")
            res = process_fhgw(nick, data["IP"], group)
            line = (f"{res.node}\t{res.role}\t{res.ip}\t{res.sw}"
                    f"\t{res.delivery_date}\t{res.age}\t{res.group}\t{res.error}")
            print(line)
            f.write(line + "\n")
    print(f"\nSaved results to: {OUTFILE}")
    txt_to_html(OUTFILE, HTMLFILE)
    # Keep duplicate call to match sw_age_check.py behavior
    txt_to_html(OUTFILE, HTMLFILE)


if __name__ == "__main__":
    main()
