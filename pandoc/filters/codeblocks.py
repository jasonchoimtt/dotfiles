_globals = dict(globals())

import ast
from collections import OrderedDict
import hashlib
from importlib import import_module
import os.path
from pprint import pformat
import subprocess
import sys
import traceback
import textwrap

import panflute as pf

from codeblocks_common import parse_codeblock_args


CACHE_DIR = os.path.expanduser('~/.pandoc/cache')


def sha1(x):
    return hashlib.sha1(x.encode(sys.getfilesystemencoding())).hexdigest()


def setup_globals():
    ret = dict(_globals)
    ret.update({
        'np': import_module('numpy'),
        'plt': import_module('matplotlib.pyplot')
        })

    return ret


def exec_code(code):
    preamble, _, code = code.rpartition('###')
    code = code.lstrip()
    tree = ast.parse(code, '<string>', mode='exec')

    has_ret = False
    if tree.body and type(tree.body[-1]) == ast.Expr:
        expr = tree.body[-1]
        lineno = expr.lineno
        col_offset = expr.col_offset
        tree.body[-1] = ast.Assign(
            targets=[
                ast.Name(id='_', ctx=ast.Store(), lineno=lineno, col_offset=col_offset)
                ],
            value=expr.value,
            lineno=lineno, col_offset=col_offset)
        has_ret = True

    bc = compile(tree, '<string>', mode='exec')

    locals_ = {}
    try:
        sys.path.insert(0, os.getcwd())
        globals_ = setup_globals()
        if preamble:
            exec(preamble, globals_, locals_)
        exec(bc, globals_, locals_)
    finally:
        sys.path.pop(0)

    return locals_.get('_') if has_ret else None


def render(code, filename, filetype, error_ok=False):
    os.makedirs(CACHE_DIR, exist_ok=True)

    import matplotlib
    matplotlib.use({'png': 'AGG', 'eps': 'PS'}[filetype])
    from matplotlib import pyplot as plt
    from PIL import Image

    has_pil = False
    def show(image):
        image.save(filename)
        nonlocal has_pil; has_pil = True
    Image.Image.show = show

    try:
        ret = exec_code(code)
    except BaseException:
        if not error_ok:
            raise
        exc_type, exc_value, exc_traceback = sys.exc_info()
        for _ in range(2):
            if exc_traceback:
                exc_traceback = exc_traceback.tb_next
        output = ''.join(traceback.format_exception(exc_type, exc_value, exc_traceback))
        output = output.replace(os.getcwd() + '/', '')
    else:
        output = pformat(ret) if ret is not None else ''

    fignums = plt.get_fignums()
    if len(fignums):
        # Only plot the first one =(
        fig = plt.figure(fignums[0])
        fig.savefig(filename)
        plt.close(fig)

        return output, filename
    elif has_pil:
        return output, filename
    else:
        return output, None


def python_exec(elem: pf.Element, doc: pf.Doc, args):
    """
    Syntax: ```{.python exec=(exec args) [format=png|eps]}
            [preamble ###]
            code
            ```

    Generate content form Python code.

    exec args: Comma-separated list of the following:
        plot: Show image plotted with matplotlib
        output: Show the output of the final expression in the code
        echo: Print the code beforehand
        inline: Generate an inline image instead of a figure
    format: png|eps. Sets the output format. Defaults to eps in latex and png
        otherwise.
    """
    attrs = OrderedDict(elem.attributes)

    exec_args = args['exec'].split(',')
    del attrs['exec']

    code = elem.text
    sha = sha1(code)

    if 'format' in args:
        filetype = args['format']
        del attrs['format']
    else:
        filetype = 'eps' if doc.format == 'latex' else 'png'
    figure_file = os.path.join(CACHE_DIR, sha + '.python.' + filetype)
    output_file = os.path.join(CACHE_DIR, sha + '.python.txt')

    if not os.path.exists(figure_file) or not os.path.exists(output_file):
        output, figure_file = render(code, figure_file, filetype, 'error' in exec_args)
        with open(output_file, 'w') as f:
            f.write(output)
    else:
        with open(output_file) as f:
            output = f.read()
        pf.debug('Using cache for {}'.format(figure_file))

    ret = []

    _, _, stripped_code = code.rpartition('###')
    stripped_code = stripped_code.lstrip()

    if 'echo' in exec_args and 'output' in exec_args:
        indented = textwrap.indent(stripped_code, '    ')
        codeblock = '>>> ' + indented[4:] + '\n' + output
        ret.append(pf.CodeBlock(codeblock, classes=elem.classes, attributes=attrs))

    elif 'echo' in exec_args or 'output' in exec_args:
        codeblock = stripped_code if 'echo' in exec_args else output
        ret.append(pf.CodeBlock(codeblock, classes=elem.classes, attributes=attrs))

    if 'plot' in exec_args and figure_file:
        spaces = [pf.Space] if 'inline' in exec_args else []
        ret.append(pf.Para(pf.Image(pf.Str('caption'), url=figure_file), *spaces))

        if 'saveplot' in args:
            saveplot_file = args['saveplot']
            del attrs['saveplot']
            with open(figure_file, 'rb') as f:
                with open(saveplot_file, 'wb') as g:
                    g.write(f.read())  # Whatever

    return ret


DOT_ARGS = [
    '-Gfontname="Helvetica"', '-Nfontname="Helvetica"', '-Efontname="Helvetica"',
    '-Gfontsize=12', '-Nfontsize=12', '-Efontsize=12',
    '-Gmargin=0'
    ]

def graphviz_exec(elem: pf.Element, doc: pf.Doc, args):
    """
    Syntax: ```{.graphviz | .dot}
            code
            ```

    Draw graph with graphviz.
    """
    attrs = OrderedDict(elem.attributes)

    exec_args = args['exec'].split(',')
    del attrs['exec']

    code = elem.text
    sha = sha1(code)

    if 'format' in args:
        filetype = args['format']
        del attrs['format']
    else:
        filetype = 'pdf' if doc.format == 'latex' else 'png'
    figure_file = os.path.join(CACHE_DIR, sha + '.graphviz.' + filetype)

    if not os.path.exists(figure_file):
        result = subprocess.run(
            ['dot', '-T{}'.format(filetype), '-o{}'.format(figure_file), *DOT_ARGS],
            input=code.encode('utf-8'), stderr=subprocess.PIPE)
        if result.returncode != 0:
            raise Exception(result.stderr.decode())
    else:
        pf.debug('Using cache for {}'.format(figure_file))

    ret = []

    if 'echo' in exec_args:
        ret.append(pf.CodeBlock(code, classes=elem.classes, attributes=attrs))

    if 'plot' in exec_args and figure_file:
        if 'inline' in exec_args:
            ret.append(pf.Para(pf.Image(pf.Str('caption'), url=figure_file), pf.Space))
        else:
            ret.append(pf.Para(pf.Image(pf.Str('caption'), url=figure_file)))

    return ret


def codeblocks(elem: pf.Element, doc: pf.Doc):
    if type(elem) == pf.CodeBlock:
        syntax, args = parse_codeblock_args(elem)

        # if syntax == 'python' and 'exec' in args:
        #     return python_exec(elem, doc, args)

        if syntax in ['graphviz', 'dot'] and 'exec' in args:
            return graphviz_exec(elem, doc, args)
