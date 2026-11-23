---
title: "git worktreeで作業中のブランチを離れずに別の作業をする"
---

作業の途中で「ちょっとこっちのブランチも見たい」となったとき、これまでは `git stash` して `git switch` して、終わったら戻って `git stash pop`、という往復をしていた。stash が何個も積み上がって、どれが何だったか分からなくなるのもいつものこと。

最近はこのサイトの記事追加も含めて、別ブランチの作業は `git worktree` で切り出すようにしている。本体の作業ツリーには一切触らないので、戻ってきたときに状態が崩れていない。

## やっていること

新しいブランチを origin/main から切って、別ディレクトリにチェックアウトする。

```sh
git fetch origin main
git worktree add -b new-post/git-worktree-for-side-work \
  .claude/worktrees/new-post-git-worktree-for-side-work origin/main
cd .claude/worktrees/new-post-git-worktree-for-side-work
```

あとはそのディレクトリで普通に編集・コミット・push するだけ。本体のディレクトリは main のまま、何も変わらない。

今どれだけ生えているかは `git worktree list` で見られる。

```sh
$ git worktree list
.../website                                                       b422e61 [main]
.../website/.claude/worktrees/new-post-git-worktree-for-side-work b422e61 [new-post/git-worktree-for-side-work]
```

用が済んだら消す。ブランチは PR のために残しておく。

```sh
git worktree remove .claude/worktrees/new-post-git-worktree-for-side-work
```

置き場所をリポジトリの中（`.claude/worktrees/`）にしているので、グローバルの gitignore（`~/.config/git/ignore`）に `.claude/worktrees/` を入れてある。これを忘れると `git status` に worktree のディレクトリが丸ごと出てきて鬱陶しい。

## 同じブランチは2か所で開けない

この記事を書きながら、worktree の中で何も考えずに main に切り替えようとしたら怒られた。

```sh
$ git switch main
fatal: 'main' is already used by worktree at '.../website'
```

本体が main をチェックアウトしているので、他の worktree では main を開けない。仕様としては知っていたのに、手が勝手に打っていた。投了です。

まあ、これは「同じブランチを2か所で別々にいじって壊す」のを防いでくれているので、むしろありがたい制約だと思う。main の中身を見たいだけなら `git show origin/main:path/to/file` で足りる。

ちなみに worktree ごとに `bundle install` や `npm install` が要るので、依存が重いプロジェクトだと切るたびに少し待たされる。このサイトくらいの規模なら気にならない。

## 使ってみて

stash の山に悩まされなくなったのが一番大きい。ブランチとディレクトリが1対1になるので、「いまどこで何をしているか」がディレクトリ名を見れば分かる。それだけで、作業の切り替えがだいぶ気楽になった。
