" Author: tokorom https://github.com/tokorom
" Description: Handle errors for review with prh.

function! s:replaceStringIndexToCol(index, line) abort
  let line = getline(a:line)
  let back = join(split(line, '\zs')[a:index : ], '')
  return stridx(line, back)
endfunction

function! ale#handlers#prhreview#HandleOutput(buffer, lines) abort
    let l:output = []

    " Sample: foo/bar.re(30,2): baz baz error
    let l:pattern = '\v^.+\((\d+),(\d+)\): (.+)$'
    let dict = {}

    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)
        if len(l:match) == 0
            if has_key(dict, 'text')
              let dict.text = dict.text . "\n" . l:line
            endif
        else
            if has_key(dict, 'text')
              call add(l:output, dict)
            endif

            let dict = {}
            let dict.lnum = l:match[1] + 0
            let dict.col = s:replaceStringIndexToCol(l:match[2] + 0, l:match[1] + 0)
            let dict.text = l:match[3]
            let dict.type = 'W'
        endif
    endfor

    if has_key(dict, 'text')
      call add(l:output, dict)
    endif

    return l:output
endfunction
