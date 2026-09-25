# 三七

Sileo / Zebra / Cydia 可用的 APT 软件源。

添加地址（国内加速，推荐）：

```
https://cdn.jsdmirror.com/gh/aichihongluobudetuzi/repo@master/
```

备用：

```
https://cdn.jsdelivr.net/gh/aichihongluobudetuzi/repo@master/
```

把 `.deb` 放到 `debs/` 并推送到 `master` 后，GitHub Actions 会自动重建 `Packages` / `Release`。

本地手动重建：

```
bash scripts/update-repo.sh
```
