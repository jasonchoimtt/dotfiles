#!/usr/bin/env python3
import os
import os.path
import panflute as pf

from codeblocks import codeblocks
from file_codeblocks import file_codeblocks
from listings import listings


DEFAULT_PACKAGES = ['unicode-math', (os.path.dirname(__file__) + '/mylistings')]

def default_packages(elem: pf.Element, doc: pf.Doc):
    """
    Auto-includes some packages when output is latex.
    """
    if type(elem) == pf.MetaMap and elem == doc.get_metadata(builtin=False) and \
            doc.format == 'latex':
        # Import packages automatically in latex
        dct = dict(elem.content)

        if 'header-includes' not in dct:
            dct['header-includes'] = pf.MetaList()
        header = '\n'.join('\\usepackage{' + p + '}' for p in DEFAULT_PACKAGES)
        dct['header-includes'].append(pf.MetaInlines(
            pf.RawInline(header, format='latex')))

        return pf.MetaMap(**dct)


def display_math_align(elem: pf.Element, doc: pf.Doc):
    """
    Syntax: $$& (align* environment content) $$

    Latex align* environment. Also supported by HTML Math renderers like
    MathJax.
    """
    if type(elem) == pf.Math and elem.format == 'DisplayMath':
        if elem.text[0] == '&':
            text = '\\begin{align*}' + elem.text[1:] + '\\end{align*}'
            if doc.format == 'latex':
                return pf.RawInline(text, format='latex')
            else:
                elem.text = text
                return elem


def include_files(elem: pf.Element, doc: pf.Doc):
    """
    Syntax: ![#include](path/to/file.txt)
            ![#include](path/to/file.txt) [codeblock attributes]

    Includes the file as a codeblock, which can be processed by other filters.
    """
    if type(elem) == pf.Para and len(elem.content) == 1:
        child = elem.content[0]
        if type(child) == pf.Image and len(child.content) == 1 and \
                type(child.content[0] == pf.Str) and child.content[0].text == '#include':

            cwd = os.getcwd()
            path = os.path.abspath(child.url)
            if path.startswith(cwd):
                with open(path) as f:
                    code = f.read()
            else:
                code = '[Permission Denied]'
            return pf.CodeBlock(code, child.identifier, child.classes, child.attributes)


section_first = True
def break_before_section(elem: pf.Element, doc: pf.Doc):
    if type(elem) == pf.Header and elem.level == 1 and \
            doc.format == 'latex' and doc.get_metadata('break-before-section', False):
        # Except the first one, I guess
        global section_first
        if section_first:
            section_first = False
            return
        return [pf.RawBlock('\\pagebreak', format='latex'), elem]


def rewrite_collapse(elem: pf.Element, doc: pf.Doc):
    if type(elem) == pf.Div and 'collapse' in elem.classes:
        label = elem.attributes.get('data-label')
        prefix = [pf.Emph(pf.Str(label)), pf.Str(':'), pf.Space] if label else []
        if doc.format == 'html':
            heading = pf.Div(pf.Para(*prefix, pf.Str('[+]')), classes=['label'])
            main = pf.Div(*elem.content, classes=['main'])
            while elem.content:
                elem.content.pop()
            elem.content.extend([heading, main])
            return elem
        else:
            return [pf.Para(*prefix), *elem.content]


def convert_latex(elem: pf.Element, doc: pf.Doc):
    if type(elem) == pf.RawBlock and elem.format in ('latex', 'tex') and doc.format == 'html':
        if elem.text == '\\qed':
            return pf.Para(pf.Str('\u25a1'))
    if type(elem) == pf.RawInline and elem.format in ('latex', 'tex') and doc.format == 'html':
        if elem.text == '\\qed':
            return pf.Span(pf.Str('\u25a1'), attributes={'style': 'display: block; text-align: right'})


def add_pandown_javascript(elem: pf.Element, doc: pf.Doc):
    if (type(elem) == pf.Doc and doc.get_metadata('pandown-preview', False) and
            doc.format == 'html'):
        with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'pandown.js')) as f:
            pandown_javascript = f.read()
        raw = '<script>\n{}\n</script>'.format(pandown_javascript)
        doc.content.append(pf.RawBlock(raw, format='html'))


EXTRACT_FILE_CODEBLOCKS_FILTERS = [
    display_math_align,
    include_files,
    file_codeblocks
    ]

DEFAULT_FILTERS = [
    default_packages,
    display_math_align,
    include_files,
    codeblocks,
    file_codeblocks,
    listings,
    break_before_section,
    rewrite_collapse,
    convert_latex,
    add_pandown_javascript,
    ]


if __name__ == '__main__':
    pf.run_filters(DEFAULT_FILTERS)
