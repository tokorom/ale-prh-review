" Author: tokorom https://github.com/tokorom
" Description: Handle errors for review with prh.

function! ale#handlers#prhreview#replaceStringIndexToCol(index, lnum) abort
  let line = getline(a:lnum)
  let back = join(split(line, '\zs')[a:index : ], '')
  return stridx(line, back)
endfunction

function! ale#handlers#prhreview#ignoreLines(buffer) abort
    let ignores = []

    let ignore_line_patterns = get(g:, 'ale_prhreview_ignore_line_patterns', [
    \ '^#@# ',
    \ ])
    let ignore_block_patterns = get(g:, 'ale_prhreview_ignore_block_patterns', [
    \ ['^//list\([ [].\+{\|{\)\s*$', '^//}\s*$'],
    \ ['^//listnum\([ [].\+{\|{\)\s*$', '^//}\s*$'],
    \ ['^//emlist\([ [].\+{\|{\)\s*$', '^//}\s*$'],
    \ ['^//emlistnum\([ [].\+{\|{\)\s*$', '^//}\s*$'],
    \ ['^//image\([ [].\+{\|{\)\s*$', '^//}\s*$'],
    \ ['^//cmd\([ [].\+{\|{\)\s*$', '^//}\s*$'],
    \ ])

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

function! ale#handlers#prhreview#ignoreParts(buffer) abort
    let ignores = []

    let ignore_inline_patterns = get(g:, 'ale_prhreview_ignore_inline_patterns', [
    \ '^//\a\+\[[^]]\+\]',
    \ '@<code>{[^}]*}',
    \ '@<tt>{[^}]*}',
    \ '@<fn>{[^}]*}',
    \ '@<img>{[^}]*}',
    \ '@<list>{[^}]*}',
    \ ])

    let lines = getbufline(a:buffer, 1, '$')

    let row = 0
    let inIgnoreBlock = 0
    while row < len(lines)
        let line = lines[row]

        for pattern in ignore_inline_patterns
            let offset = 0
            let target = line
            while 1
              let match = matchstr(target, pattern)
              if len(match) > 0
                  let dict = {}
                  let dict.row = row
                  let start = stridx(target, match)
                  let dict.start = offset + start
                  let dict.end = offset + start + len(match) - 1
                  call add(ignores, dict)

                  let offset = dict.end
                  let target = strpart(line, dict.end)
              else
                break
              endif
            endwhile
        endfor

        let row += 1
    endwhile

    return ignores
endfunction

function! ale#handlers#prhreview#matchIgnoreParts(ignoreParts, lnum, col) abort
    let parts = a:ignoreParts
    let row = a:lnum - 1
    let col = a:col - 1

    for part in parts
        if (part.row == row) && (part.start <= col) && (col <= part.end)
            return 1
        endif
    endfor

    return 0
endfunction

function! ale#handlers#prhreview#HandleOutput(buffer, lines) abort
    let output = []

    let ignoreRows = ale#handlers#prhreview#ignoreLines(a:buffer)
    let ignoreParts = ale#handlers#prhreview#ignoreParts(a:buffer)

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
            let index = match[2] + 0
            let col = ale#handlers#prhreview#replaceStringIndexToCol(index, lnum)
            let text = match[3]

            if (index(ignoreRows, lnum - 1) == -1) && !(ale#handlers#prhreview#matchIgnoreParts(ignoreParts, lnum, col))
              let dict.lnum = lnum
              let dict.col = col
              let dict.text = text
              let dict.type = 'W'
            endif
        endif
    endfor

    if has_key(dict, 'text')
      call add(output, dict)
    endif

    return output
endfunction
