import pandas as pd
import ast
import operator
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import re

# 支持的运算符
OPS = {ast.Add: operator.add, ast.Sub: operator.sub,
       ast.Mult: operator.mul, ast.Div: operator.truediv}

CMP = {">": operator.gt, "<": operator.lt, ">=": operator.ge,
       "<=": operator.le, "==": operator.eq, "!=": operator.ne}


# 计算表达式值
def eval_expr(expr, kpi_map):
    for k, v in kpi_map.items():
        expr = re.sub(r'\b{}\b'.format(k), str(v), expr)
    try:
        node = ast.parse(expr, mode='eval')
        return eval_ast(node.body)
    except Exception:
        return None


def eval_ast(node):
    if isinstance(node, ast.Num):
        return node.n
    if isinstance(node, ast.Constant):
        return node.value
    if isinstance(node, ast.BinOp):
        return OPS[type(node.op)](eval_ast(node.left), eval_ast(node.right))
    if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub):
        return -eval_ast(node.operand)
    return None


# 分割条件
def split_condition(cond):
    m = re.search(r'(>=|<=|==|!=|>|<)', cond)
    if not m:
        return None, None, None
    op = m.group(1)
    left = cond[:m.start()].strip()
    right = cond[m.end():].strip()
    return left, op, right


# 检查单条规则
def check_rule(expr, kpi_map):
    if pd.isna(expr) or "Negative value pool" in str(expr):
        return True
    conds = str(expr).split("&&")
    for cond in conds:
        left, op, right = split_condition(cond)
        if not op:
            continue
        lval = eval_expr(left, kpi_map)
        rval = eval_expr(right, kpi_map)
        if lval is None or rval is None:
            return False
        if not CMP[op](lval, rval):
            return False
    return True


# Excel 列字母转索引
def excel_col_to_index(col):
    col = col.upper()
    index = 0
    for c in col:
        index = index * 26 + (ord(c) - ord('A') + 1)
    return index - 1


# 发送 HTML 邮件
def send_email(receiver_email, subject, body_html):
    smtp_server = "mailrelay.int.nokia.com"
    port = 25
    sender_email = "auto_kpi_analysis@nokia.com"
    try:
        msg = MIMEMultipart("alternative")
        msg['From'] = sender_email
        msg['To'] = receiver_email
        msg['Subject'] = subject
        msg.attach(MIMEText(body_html, 'html'))

        server = smtplib.SMTP(smtp_server, port)
        server.ehlo()
        server.starttls()  # 启用 TLS
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()
        print("send email successfully")
    except Exception as e:
        print(f"send email failed: {e}")


# 主函数
def run_kpi_check(file, receiver_email,
                  sheet_name="SA final",
                  start_row=4,
                  kpi_col='D',
                  rule_col='G',
                  value_col="L"):
    df = pd.read_excel(file, sheet_name=sheet_name, header=2)
    start_row = start_row - 4
    global_case_id = str(df.iloc[start_row, 0])[:-3]
    print("totalid={}, global_case_id={}".format(df.iloc[start_row, 0], global_case_id))

    # 获取当前 case 的行
    end_row = len(df) - 1
    for index, row in df.iloc[start_row:].iterrows():
        if str(row.iloc[0])[:-3] != global_case_id:
            end_row = index - 1
            break
    sub_df = df.iloc[start_row:end_row + 1]

    # KPI 映射
    kpi_i = excel_col_to_index(kpi_col)
    rule_i = excel_col_to_index(rule_col)
    val_i = excel_col_to_index(value_col)
    kpi_map = {str(k).upper(): v for k, v in zip(sub_df.iloc[:, kpi_i], sub_df.iloc[:, val_i])}

    # 检查 KPI
    results = []
    for _, row in sub_df.iterrows():
        rule = row.iloc[rule_i]
        if not pd.isna(rule):
            if rule.lower() == "negative value pool, only these value can be negative":
                rule = "{}<0".format(row.iloc[kpi_i])
            rule = str(rule).upper()
        ok = check_rule(rule, kpi_map)
        results.append(ok)

    sub_df.insert(loc=val_i, column="check_result", value="")
    sub_df.loc[:, "check_result"] = list(map(str, results))
    sub_df.to_excel("kpi_report.xlsx", index=False)

    # 失败 KPI
    fail_df = sub_df[sub_df.iloc[:, val_i] == "False"]
    cols = fail_df.iloc[:, [0, kpi_i, kpi_i + 1, rule_i, val_i + 1]].astype(str)

    widths = []
    for i, col in enumerate(cols.columns):
        max_data_len = cols[col].map(lambda x: len(x[:100]) if i == 2 else len(x)).max()
        widths.append(max(len(col), max_data_len))

    col_header = "  ".join(f"{name.strip():<{w}}" for name, w in zip(cols.columns, widths))
    fail_all = "\n".join(
        f"{a:<{widths[0]}}  {b:<{widths[1]}}  {c[:100]:<{widths[2]}}  {d:<{widths[3]}}  "
        f"{('empty' if e == 'nan' else e):<{widths[4]}}"
        for a, b, c, d, e in cols.itertuples(index=False)
    )
    fail_all = f"{col_header}\n{fail_all}"
    print(fail_all)

    # Summary
    summary = {
        "total": len(sub_df),
        "fail": len(fail_df),
        "rate": round((len(df) - len(fail_df)) / len(df) * 100, 2)
    }
    print("========== KPI CHECK ==========")
    print(summary)

    # HTML 邮件内容
    summary_html = f"""
    <h2>KPI Check Summary</h2>
    <ul>
        <li>Total KPI: {summary['total']}</li>
        <li>Failed KPI: {summary['fail']}</li>
        <li>Pass Rate: {summary['rate']}%</li>
    </ul>
    """

    fail_all_html = f"<pre>{fail_all}</pre>"

    html_body = f"""
    <html>
    <body>
        <p>Dear all,</p>
        {summary_html}
        <h2>Failed KPI Details</h2>
        {fail_all_html}
        <p>Regards,<br>Yin Zhang</p>
    </body>
    </html>
    """

    send_email(receiver_email,
               subject=f"KPI test case {global_case_id} failed on {df.columns[val_i]}",
               body_html=html_body)


if __name__ == "__main__":
    # run_kpi_check(
    #     r"C:\zhangyin\RAN_VRF\KPI\NR_L1L2L3_Area_SpecSiteCell_25R2_v1_Daily 1 (20251012模板)_Ryan.xlsx",
    #     receiver_email="yin.zhang@nokia.com"
    # )
    # run_kpi_check(
    #     r"C:\zhangyin\RAN_VRF\KPI\E2E_SFE_Qos_TMO_KPI_monitor_summary_2026_0211_TL363_LX.xlsx",
    #     receiver_email="yin.zhang@nokia.com",
    #     sheet_name="SA",
    #     start_row=4,
    #     kpi_col='D',
    #     rule_col='G',
    #     value_col="BC"
    # )
    run_kpi_check(
        r"C:\zhangyin\RAN_VRF\KPI\E2E_SFE_Qos_TMO_KPI_monitor_summary_2026_trunk_TL375_Ryan.xlsx",
        receiver_email="yin.zhang@nokia.com",
        sheet_name="SA final",
        start_row=504,
        kpi_col='D',
        rule_col='G',
        value_col="P"
    )
