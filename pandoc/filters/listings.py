import panflute as pf
import textwrap

from codeblocks_common import parse_codeblock_args


# A rough list from Wikibooks, far from non-exhaustive
SUPPORTED_ARGS = [
        'backgroundcolor',
        'basicstyle',
        'breakatwhitespace',
        'breaklines',
        'caption',
        'captionpos',
        'commentstyle',
        'deletekeywords',
        'escapeinside',
        'extendedchars',
        'firstnumber',
        'firstline',
        'frame',
        'identifierstyle',
        'keepspaces',
        'keywordstyle',
        'lastline',
        'morekeywords',
        'numbers',
        'numbersep',
        'numberstyle',
        'rulecolor',
        'showspaces',
        'showstringspaces',
        'showtabs',
        'stepnumber',
        'stringstyle',
        'tabsize',
        'title'
]

def listings(elem: pf.Element, doc: pf.Doc):
    """
    Syntax: ```{... listing=yes [title=...] [firstnumber=...]}
            code
            ```

    Outputs a codeblock as a listing in latex.
    """
    if type(elem) == pf.CodeBlock:
        syntax, args = parse_codeblock_args(elem)

        if args.get('listing'):
            if doc.format == 'latex':
                extra_args = ''
                for key in SUPPORTED_ARGS:
                    if args.get(key):
                        extra_args += ',%s={%s}' % (key, args[key])

                text = textwrap.dedent('''\
                    \\begin{lstlisting}[language=%s%s]
                    %s
                    \\end{lstlisting}
                ''') % (syntax, extra_args, elem.text)
                return pf.RawBlock(text, format='latex')
