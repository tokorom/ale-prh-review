" Author: tokorom https://github.com/tokorom
" Description: Handle errors for review with prh.

function! s:replaceStringIndexToCol(index, lnum) abort
  let line = getline(a:lnum)
  let back = join(split(line, '\zs')[a:index : ], '')
  return stridx(line, back)
endfunction

function! s:ignoreLines(buffer) abort
    let ignores = [10]

    let ignore_line_patterns = get(g:, 'ale_prhreview_ignore_line_patterns', ['^#@# '])
    let ignore_block_patterns = get(g:, 'ale_prhreview_ignore_block_patterns', [['^//.\+{\s*$', '^//}\s*$']])

    let lines = getbufline(a:buffer, 1, '$')

    let row = 0
    let inIgnoreBlock = 0
    while row < len(lines)
        let line = lines[row]

        if !inIgnoreBlock
            for blockPattern in ignore_block_patterns
                let blockOpen = blockPattern[0]
                if line =~ blockOpen
                    let inIgnoreBlock = 1
                    break
                endif
            endfor
        endif

        if inIgnoreBlock
            call add(ignores, row)

            for blockPattern in ignore_block_patterns
                let blockClose = blockPattern[1]
                if line =~ blockClose
                    let inIgnoreBlock = 0
                    break
                endif
            endfor

            if inIgnoreBlock
                let row += 1
                continue
            endif
        endif

        for pattern in ignore_line_patterns
            if line =~ pattern
                call add(ignores, row)
            endif
        endfor

        let row += 1
    endwhile

    return ignores
endfunction

function! ale#handlers#prhreview#HandleOutput(buffer, lines) abort
    let output = []

    let ignore_rows = s:ignoreLines(a:buffer)

    " Sample: foo/bar.re(30,2): baz baz error
    let pattern = '\v^.+\((\d+),(\d+)\): (.+)$'
    let dict = {}

    for line in a:lines
        let match = matchlist(line, pattern)
        if len(match) == 0
            if has_key(dict, 'text')
              let dict.text = dict.text . "\n" . line
            endif
        else
            if has_key(dict, 'text')
              call add(output, dict)
            endif

            let dict = {}

            let lnum = match[1] + 0
            let col = match[2] + 0
            let text = match[3]

            if index(ignore_rows, lnum - 1) == -1
              let dict.lnum = lnum
              let dict.col = s:replaceStringIndexToCol(col, lnum)
              let dict.text = text . ' ' . lnum
              let dict.type = 'W'
            endif
        endif
    endfor

    if has_key(dict, 'text')
      call add(output, dict)
    endif

    return output
endfunction
