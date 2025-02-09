# kdig同梱のRockLinux9

[Fedora copr](https://copr.fedorainfracloud.org/coprs/g/cznic/knot-dns-latest/) のKnot DNSのrpmをinstallしたRockyLinux9のimage

## usage
```
docker run --rm smbd/rockylinux-kdig +json +dnssec -t AAAA www.google.com
```
