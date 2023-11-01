# kdig同梱のRockLinux9

[Fedora copr](https://copr.fedorainfracloud.org/coprs/g/cznic/knot-dns-latest/) のKnot DNSのrpmをbuildして
installしたRockyLinux9のimage

## usage
```
docker run --rm smbd/kdig +json +dnssec -t AAAA www.google.com
```

## build
./build.sh

### Knot DNSの更新方法
`copr_repo/` がcoprのrepoをgit submoduleしてあり、`copr_repo/knot.spec` からversionを拾っているので、cdしてgit pull(してgit commit)すれば最新のものになる

copr側が更新されていなかったら `copr_repo/knot.spec` と `copr_repo/sources` を手で更新すればよい (後者はmd5sumの出力)
