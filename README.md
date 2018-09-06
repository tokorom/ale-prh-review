# ale-prh-review

Lint Tool for Re:VIEW text

- For Vim
- [ale](https://github.com/w0rp/ale) plugin
- Use [prh](https://github.com/prh/prh)

## Installation

### with Vim package management

```sh
mkdir -p ~/.vim/pack/git-plugins/start
git clone https://github.com/w0rp/ale.git ~/.vim/pack/git-plugins/start/ale
git clone https://github.com/tokorom/ale-prh-review.git ~/.vim/pack/git-plugins/start/ale-prh-review
```

### with Volt

```sh
volt get w0rp/ale
volt get tokorom/ale-prh-review
```

## Required Configuration

```vim
let g:ale_fixers = {
\   'review': ['prhreview'],
\}

# with redpen
# let g:ale_fixers = {
# \   'review': ['redpen', 'prhreview'],
# \}
```

## Optional Configuration

```vim
" default
let g:ale_prhreview_ignore_line_patterns = [
\ '^#@# ',
\ ]

" default
let g:ale_prhreview_ignore_block_patterns = [
\ ['^//list\([ [].\+{\|{\)\s*$', '^//}\s*$'],
\ ['^//listnum\([ [].\+{\|{\)\s*$', '^//}\s*$'],
\ ['^//emlist\([ [].\+{\|{\)\s*$', '^//}\s*$'],
\ ['^//emlistnum\([ [].\+{\|{\)\s*$', '^//}\s*$'],
\ ['^//image\([ [].\+{\|{\)\s*$', '^//}\s*$'],
\ ['^//cmd\([ [].\+{\|{\)\s*$', '^//}\s*$'],
\ ]

" default
let g:ale_prhreview_ignore_inline_patterns = [
\ '@<code>{.*}',
\ '@<fn>{.*}',
\ '@<img>{.*}',
\ '@<list>{.*}',
\ ]
```
