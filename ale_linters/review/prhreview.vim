" Author: tokorom https://github.com/tokorom
" Description: review (https://github.com/kmuto/review) with prh (https://github.com/prh/prh)

call ale#linter#Define('review', {
\   'name': 'prhreview',
\   'executable': 'prh',
\   'command': 'prh %s',
\   'callback': 'ale#handlers#prhreview#HandleOutput',
\})
