import os
from file_codeblocks import codeblocks_files
from main import EXTRACT_FILE_CODEBLOCKS_FILTERS

import panflute as pf


if __name__ == '__main__':
    # Extract codeblock files
    with open(os.devnull, 'w') as devnull:
        pf.run_filters(EXTRACT_FILE_CODEBLOCKS_FILTERS, output_stream=devnull)
    for filename, data in codeblocks_files.items():
        with open(filename, 'w') as f:
            for c in data['contents']:
                f.write(c)
        print('Wrote {}'.format(filename))
