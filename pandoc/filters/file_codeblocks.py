from collections import defaultdict, OrderedDict

import panflute as pf

from codeblocks_common import parse_codeblock_args


codeblocks_files = defaultdict(lambda: {'lines': 0, 'contents': []})


def file_codeblocks(elem: pf.Element, doc: pf.Doc):
    if type(elem) == pf.CodeBlock:
        syntax, args = parse_codeblock_args(elem)
        attrs = OrderedDict(elem.attributes)

        if 'file' in args:
            code = elem.text + '\n'
            f = args['file']
            del attrs['file']

            attrs['firstnumber'] = str(codeblocks_files[f]['lines']+1)
            codeblocks_files[f]['lines'] += code.count('\n')
            codeblocks_files[f]['contents'] += code

            return pf.CodeBlock(code, elem.identifier, elem.classes, attrs)
