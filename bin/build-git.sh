#!/usr/bin/env bash
set -e
[[ -z $DOTFILES_LOCAL ]] && { echo "\$DOTFILES_LOCAL is empty" >&2; exit 1; }
sudo yum install -y perl-ExtUtils-MakeMaker expat-devel gettext autoconf zlib-devel
sudo yum install -y libcurl-devel || sudo yum install -y curl-devel

tmp=$(mktemp -d "${TMPDIR:-/tmp}/${1:-tmpspace}.XXXXXXXXXX")
[[ -z $tmp ]] && exit 1
trap "rm -rf $(printf %q "$tmp")" EXIT

cd $tmp || exit 1
git clone --depth=1 git://github.com/gitster/git.git
cd git
make configure
./configure --prefix="$DOTFILES_LOCAL"
make
make install
