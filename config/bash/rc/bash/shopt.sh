# タブ補完でパス中の変数をその場で展開させる（本当は変数は変数のままでいて欲しいだがどっかのbashバージョンで$FOODIRを保管すると\$FOODIRにするバグが酷いのでその一次対応）
if ver-ge 4.2.29; then
  shopt -s direxpand
fi
