import logging
import os
from pathlib import Path

logger = logging.getLogger()


class Autohtml:
    def __init__(self):
        self.html = Html()
        self.document = "<!DOCTYPE html>\n"

    def generate(self):
        html_doc = f"""{self.document}
{self.html.generate()}
"""
        return html_doc

    def write_to_file(self, filename):
        with open(filename, "w+", encoding='utf-8') as fstream:
            logger.debug(f"html location: {filename}")
            html = self.generate()
            fstream.write(html)


class HtmlElement:
    def __init__(self, self_closing=False, attribute="", _style=None, _class=None, _id=None):
        self.inner_elements = []
        self.element_name = self.__class__.__name__.lower()
        self.attribute = attribute
        if _class is not None:
            self.attribute = f'{self.attribute} class="{_class}" '
        if _id is not None:
            self.attribute = f'{self.attribute} id="{_id}" '
        if _style is not None:
            self.attribute = f'{self.attribute} style="{_style}" '
        self.self_closing = self_closing

    def insert(self, new_elements):
        self.inner_elements.extend(new_elements)
        return self

    def append(self, new_element):
        self.inner_elements.append(new_element)
        return self

    def _insert_hard_element(self):
        pass

    def generate(self, indention=0):
        fill = '{fill:>{w}}'.format(fill='', w=indention)
        if self.self_closing:
            return self._generate_self_closing(indention)
        else:
            self._insert_hard_element()
            str_element = ""
            for element in self.inner_elements:
                if isinstance(element, HtmlElement):
                    str_element = f"{fill}{str_element}\n{element.generate(indention+4)}"
                else:
                    str_element = f"{str_element}\n{fill}    {element}"
            return f"""{fill}<{self.element_name} {self.attribute}>{fill}{str_element}
{fill}</{self.element_name}>"""

    def _generate_self_closing(self, indention=0):
        fill = '{fill:>{w}}'.format(fill='', w=indention)
        return f"{fill}<{self.element_name} {self.attribute}/>"


class Html(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)
        self.body = Body()
        self.head = Head()

    def _insert_hard_element(self):
        self.inner_elements.append(self.head)
        self.inner_elements.append(self.body)


class A(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class B(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Br(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)
        self.self_closing = True


class Body(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Center(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Div(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Font(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Head(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)
        self.title = Title()
        self.style = Style()

    def _insert_hard_element(self):
        self.inner_elements.append(self.title)
        self.inner_elements.append(self.style)


class Li(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class P(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Span(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Style(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Table(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Td(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Title(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Th(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Tr(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class U(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


class Ul(HtmlElement):
    def __init__(self, *args, **kwargs):
        HtmlElement.__init__(self, *args, **kwargs)


def main():
    ahtml = Autohtml()
    ahtml.html.head.title.inner_elements.append("test_title")
    ahtml.html.head.style.inner_elements.append("""
#my-table {
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}
#my-table td, #my-table th {
  border: 1px solid #ddd;
  padding: 8px;
}
#my-table tr:nth-child(even){background-color: #f2f2f2;}
#my-table tr:hover {background-color: #ddd;}
#my-table th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #4CAF50;
  color: white;
}
    """)
    ahtml.html.body.insert(["<h1>test h1</h1>"])

    mTable = Table(_id='my-table', _style='color:red;').insert([
        Tr().insert(
            [
                Th().insert(["test header 1"]),
                Th().insert(["test header 2"]),
                Th().insert(["test header 3"]),
            ]
        ),
        Tr().insert(
            [
                Th().insert(["test column 1"]),
                Th().insert(["test column 2"]),
                Th().insert(["test column 3"]),
            ]
        ),
        Tr().insert(
            [Td().insert(["test column 1"]), Td().insert(["test column 2"]), Td().insert(["test column 3"]),
             ]
        )
    ])

    ahtml.html.body.inner_elements.append(mTable)
    ahtml.html.body.inner_elements.append(Br())
    ahtml.html.body.inner_elements.append(Br())

    logger.info(f"html generated: autohtml.html")
    ahtml.write_to_file('autohtml.html')


if __name__ == '__main__':
    logging.basicConfig(
        format='[%(levelname)7s %(lineno)4s %(filename)-20s] %(message)s',
        datefmt='%H:%M:%S',
        level=getattr(logging, 'DEBUG')
    )

    try:
        logger.info(f"Start of {os.path.basename(__file__)}")
        main()
    except Exception as e:
        logger.exception(e)
        logger.error(f"{os.path.basename(__file__)}")
    finally:
        logger.info(f"End of {os.path.basename(__file__)}")
