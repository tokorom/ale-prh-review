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
\   'review': 'prhreview'],
\}

# with redpen
# let g:ale_fixers = {
# \   'review': ['redpen', 'prhreview'],
# \}
```

## Optional Configuration

```vim
" default
let ignore_line_patterns = ['^#@# ']
" default
let ignore_block_patterns = [['^//.\+{\s*$', '^//}\s*$']]
```
