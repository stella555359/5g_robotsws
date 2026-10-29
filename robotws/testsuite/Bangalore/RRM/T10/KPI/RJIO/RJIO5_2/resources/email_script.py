import smtplib
from email.message import EmailMessage
from pathlib import Path
import mimetypes

# from datetime import datetime
from typing import Any, Dict, List

SMTP_SERVER = "mailrelay.int.nokia.com"
SMTP_PORT = 25
SENDER_EMAIL = "no-reply@nokia.com"

DEFAULT_RECIPIENTS = ["hari.somu@nokia.com"]
DEFAULT_SUBJECT = "KPI Report Generated"

EMAIL_TEMPLATE_HTML = """\
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333;
        max-width: 800px; margin: 0 auto; padding: 20px; }}
        .header {{ color: #2c5aa0; font-size: 16px; margin-bottom: 20px; }}
        .field {{ margin: 8px 0; padding: 4px 0; }}
        .label {{ font-weight: bold; color: #555; }}

        /* Two-column layout */
        .content-grid {{
            display: table;
            width: 100%;
            table-layout: fixed;
            margin: 20px 0;
        }}
        .left-panel, .right-panel {{
            display: table-cell;
            vertical-align: top;
        }}
        .left-panel {{ width: 45%; padding-right: 20px; }}
        .right-panel {{ width: 55%; }}

        /* Compact table for right panel */
        .kpi-table {{
            width: 75%;
            border-collapse: collapse;
            background: #f8f9fa;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            font-size: 11px;
        }}
        .kpi-table th {{
            background: #2c5aa0;
            color: white;
            padding: 4px 4px;
            text-align: left;
            height: 20px;
            font-size: 11px;
            vertical-align: middle;
        }}
        .kpi-table td {{
            padding: 2px 4px;
            height: 18px;
            border-bottom: 1px solid #e9ecef;
            font-size: 11px;
            vertical-align: middle;
        }}
        .kpi-table tr:hover {{ background: #e3f2fd; }}

        .notes {{
            background: #f8f9fa;
            padding: 12px;
            border-left: 4px solid #2c5aa0;
            margin: 15px 0;
        }}
        .footer {{ margin-top: 25px; font-style: italic; color: #666; }}
        .kpi-title {{ color: #2c5aa0; margin: 0 0 10px 0; font-size: 17px; }}
    </style>
</head>
<body>
    <p>Hi,</p>

    <div class="header">
        A new KPI report has been generated.
    </div>

    <div class="content-grid">
        <div class="left-panel">
            <div class="field">
                <span class="label">Source build:</span> {source_build}
            </div>

            <div class="field">
                <span class="label">Target build:</span> {target_build}
            </div>

            <div class="field">
                <span class="label">Hostname:</span> {hostname}
            </div>

            <div class="field">
                <span class="label">Scout Template:</span>
                <a href="https://scout.nsn-rdnet.net/kpis-templates/{template_id}"
                target="_blank">SCOUT TEMPLATE {template_id}</a>
            </div>

            <div class="field">
                <span class="label">Log path:</span> /home/ute/logs
            </div>
        </div>

        <div style="margin-top: 25px;">
            <h4 style="color: #555; margin: 0 0 12px 0; font-size: 14px;">Run Reports</h4>
            <table style="width: 60%; border-collapse: collapse; font-size: 13px;
                border: 1px solid #ddd; cellpadding: 6; cellspacing: 0;">
                <thead>
                    <tr style="background: #f5f5f5;">
                        <th style="padding: 8px 10px; border: 1px solid #ddd;
                        font-weight: bold; font-size: 13px;">RUN</th>
                        <th style="padding: 8px 10px; border: 1px solid #ddd; font-size: 13px;">{source_build}</th>
                        <th style="padding: 8px 10px; border: 1px solid #ddd; font-size: 13px;">{target_build}</th>
                    </tr>
                </thead>
                <tbody>
                    {run_table_rows}
                </tbody>
            </table>
        </div>
        <br>

        <div class="right-panel">
            <h3 class="kpi-title">Top 10 KPI Variations</h3>
            <table class="kpi-table">
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>KPI</th>
                        <th>Δ(%)</th>
                        <th>Trend</th>
                    </tr>
                </thead>
                <tbody>
                    {kpi_table_rows}
                </tbody>
            </table>
        </div>
    </div>

    <div class="footer">
        Regards,<br>
        {sender_name}
    </div>
</body>
</html>
"""


def render_body(config: Dict[str, Any]) -> str:
    merged = {
        "source_build": config.get("source_build", "N/A"),
        "target_build": config.get("target_build", "N/A"),
        "hostname": config.get("hostname"),
        # "notes": config.get("notes", "No additional notes."),
        "sender_name": config.get("sender_name", "KPI Automation Bot by hsomu"),
        "template_id": config.get("template_id", "None"),
        "report1_id": config.get("report1_id", "None"),
        "report2_id": config.get("report2_id", "None"),
    }

    # Generate KPI table HTML - FIXED Trend logic
    kpis = config.get("top_kpis", [])
    kpi_table_rows = ""
    run_table_rows = ""
    for kpi in kpis[:10]:  # Ensure max 5
        delta = kpi.get("Delta (%)", 0)

        # Calculate trend based on delta value
        if delta > 0:
            # trend = "Increased"
            trend_icon = "📈"
            delta_color = "#27ae60"  # Green
        elif delta < 0:
            # trend = "Decreased"
            trend_icon = "📉"
            delta_color = "#e74c3c"  # Red
        else:
            # trend = "Same"
            trend_icon = "➡️"
            delta_color = "#f39c12"  # Orange

        kpi_table_rows += f"""
        <tr>
            <td>{kpi.get("KPI Code", "N/A")}</td>
            <td>{kpi.get("KPI Name", "N/A")}</td>
            <td style="color: {delta_color}; font-weight: bold;">{delta:+.2f}%</td>
            <td style="font-size: 16px;">{trend_icon}</td>
        </tr>
        """
    run_table_rows += f"""
        <tr>
            <td style="text-align: center;">{config.get("RUN", "1")}</td>
            <td style="text-align: center; padding: 8px 10px;border: 1px solid #ddd; font-weight: bold;
            font-size: 13px;">
            <a href="https://scout.nsn-rdnet.net/kpis-reports/{config.get("report1_id", "#")}">
            KPI REPORT SCOUT |{config.get("template_id", "#")}</a></td>
            <td style="text-align: center; padding: 8px 10px; border: 1px solid #ddd; font-weight: bold;
            font-size: 13px;"><a href="https://scout.nsn-rdnet.net/kpis-reports/{config.get("report2_id", "#")}">
            KPI REPORT SCOUT |{config.get("template_id", "#")}</a></td>
        </tr>
        """

    return EMAIL_TEMPLATE_HTML.format(
        **merged, kpi_table_rows=kpi_table_rows, run_table_rows=run_table_rows
    )


def resolve_recipients(config: Dict[str, Any]) -> List[str]:
    recipients = config.get("recipients")
    if isinstance(recipients, list) and recipients:
        return recipients
    if isinstance(recipients, str) and recipients.strip():
        return [recipients.strip()]
    return DEFAULT_RECIPIENTS


def resolve_subject(config: Dict[str, Any]) -> str:
    subject = config.get("subject")
    if isinstance(subject, str) and subject.strip():
        return subject.strip()
    return DEFAULT_SUBJECT


def attach_file(msg: EmailMessage, file_path: str) -> None:
    path = Path(file_path)
    if not path.is_file():
        raise FileNotFoundError(f"Attachment not found: {path}")

    ctype, encoding = mimetypes.guess_type(str(path))
    if ctype is None or encoding is not None:
        ctype = "application/octet-stream"

    maintype, subtype = ctype.split("/", 1)

    with open(path, "rb") as f:
        msg.add_attachment(
            f.read(),
            maintype=maintype,
            subtype=subtype,
            filename=path.name,
        )


def send_email_with_attachments(
    files: List[str],
    mail_config: Dict[str, Any],
) -> None:
    msg = EmailMessage()
    msg["From"] = SENDER_EMAIL

    recipients = resolve_recipients(mail_config)
    msg["To"] = ", ".join(recipients)

    msg["Subject"] = resolve_subject(mail_config)

    html_body = render_body(mail_config)
    msg.add_alternative(html_body, subtype="html")

    for fp in files:
        attach_file(msg, fp)

    try:
        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.send_message(msg)
        print("Success: Email sent!")
    except Exception as e:
        print(f"Error: {e}")
