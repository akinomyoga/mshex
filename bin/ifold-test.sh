
./ifold -i -s -w 80 <<EOF
  　またもう一つの解決方法として、連想配列や配列を使用せずにグローバル変数にフラットに変数を記録する事ができる。この時統一的な管理をしようと思ったら eval 等を使って変数を設定するなどすれば良い。また、参照する時には普通の変数として参照すれば良いので速度の問題は一切ない。後、参照の仕方が mwg_term_cf_dr 等、長い名前になって途中で切れていないと幾らか気分が悪い…がこれは仕方がない。また、declare で変数一覧を参照する時に散乱して見にくいという事と、declare -p mwg_term で一括して見る、等と言った事ができないという問題点もある。またキーに用いる文字列は当然ながら変数に用いる事のできる文字列で構成されていなければならないので、使用の際に充分気を付ける必要がある。
EOF