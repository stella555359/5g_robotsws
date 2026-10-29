"""
Owners: Cosmina(Diana) Rebenciuc, Anna Beke, Bogdan Boldurean
"""

"""
Family: Chile
Fronthaul: CPRI + eCPRI
"""
CHB0 = dict(
    sw_line_name='CHB0',
    rmod_types=('AEHC'),
    user='serviceuser',
    password='7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=',
    hw_generation='4.5'
)

"""
Family: Rel5.1
Fronthaul: CPRI + eCPRI
"""
FRM5 = dict(
    sw_line_name='FRM5',
    rmod_types=('AHCA',
                'AHBCC',
                'AHDB',
                'AHEB',
                'AHEGA',
                'AHFIB',
                'AHFIG',
                'AHHB',
                'AHLOA',
                'AHPB',
                'AHPJ',
                'AHPMDA',
                'AHPMDD',
                'ANEGA',
                'AZNA'
                ),
    user='',
    password='',
    hw_generation='5.1'
)

"""
Family: Scorpio
Fronthaul: CPRI + eCPRI
"""
ERM6 = dict(
    sw_line_name='ERM6',
    rmod_types=('AZHL', 'AZQP', 'AZQS', 'AZQU', 'AZQJ'),
    user='serviceuser',
    password='wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=',
    hw_generation='6.1'
)

"""
Family: Zodiac
Fronthaul: CPRI
"""
FRM6 = dict(
    sw_line_name='FRM6',
    rmod_types=('AHFII', 'AHLOB', 'AHEGHA'),
    user='serviceuser',
    password='WAH26M0DHuXSxpqpUSLmklXrKUfF4iPrXQ+8YULFNuM=',
    hw_generation='6.2'
)

"""
Family: Maverick
Fronthaul: eCPRI
"""
FRU6 = dict(
    sw_line_name='FRU6',
    rmod_types=('AHFII', 'AHLOB'),
    user='serviceuser',
    password='oBrd1RgbOasUtYAeVfxrW9yGHb6ONl0w+MJUoKrBMGE=',
    hw_generation='6.2'
)

"""
Family: Cybertron
Fronthaul: eCPRI
"""
CTA6 = dict(
    sw_line_name='CTA6',
    rmod_types=('AQQJ'),
    user='serviceuser',
    password='v160rWp/6qpX/RQjmnaupqP+FBV2/f7bgiwMI8+cpEY=',
    hw_generation='6.2'
)

"""
Family: Master / Amber
Fronthaul: CPRI + eCPRI
"""
SRM6 = dict(
    sw_line_name='SRM6',
    rmod_types=('AEQE', 'AEQP', 'AEQQ', 'AENB'),
    user='serviceuser',
    password='bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
    hw_generation='6.1'
)

"""
Family: RF7.1: AVQL / Yoda / Mars / Thor
        RF8: Rautu
Fronthaul: CPRI + eCPRI
"""
SRM7 = dict(
    sw_line_name='SRM7',
    rmod_types=('AVHA', 'AVQC', 'AVQE', 'AVQL'),
    user='serviceuser',
    password='kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=',
    hw_generation='7.1'
)


sw_lines = (CHB0, FRM5, ERM6, FRM6, SRM6, CTA6, SRM7)


def get_user_and_password_for_rmod(rmod_sw_line, rmod_type):
    """
        This KW is created to return user and password for the given RMOD type.
    """
    for sw_line in sw_lines:
        if rmod_sw_line in sw_line['sw_line_name'] and rmod_type in sw_line['rmod_types']:
            user = sw_line['user']
            password = sw_line['password']
            return user, password
    else:
        raise Exception(f"Unknown RMOD type: '{rmod_type}' not present in radio modules list.")


def get_hw_generation_for_rmod(rmod_type):
    """
        This KW is created to return hardware generation for the given RMOD type.
    """
    for sw_line in sw_lines:
        if rmod_type in sw_line['rmod_types']:
            hw_generation = sw_line['hw_generation']
            return hw_generation
    else:
        raise Exception(f"Unknown RMOD type: '{rmod_type}' not present in radio modules list.")
