#!/bin/bash

ROCKY_REL="9.2"

function usage () {
  echo "Usage: ${0} [-l] [-p]"
  echo "    -l: update latest tag"
  echo "    -p: push to dockerhub"
  echo "    -h: show this"
  exit 1
}

while getopts hlp OPT ; do
  case ${OPT} in
    "l") LATEST="true" ;;
    "p") PUSH="true" ;;
    "h") usage ;;
  esac
done

shift $((${OPTIND}-1))

function abort () {
   echo "$1" 1>&2
   exit 1
}

# delete old base image
docker rmi rockylinux/rockylinux:${ROCKY_REL}
docker rmi rockylinux/rockylinux:${ROCKY_REL}-minimal

# download source file
tarball_filename=$(cat copr_repo/sources | awk '{print $2}')
echo $tarball_filename | grep -q ^knot- || abort "cannot get tarball filename"

(
  cd rpmbuild/SOURCES || abort "faild to chdir"
  curl -sOL https://secure.nic.cz/files/knot-dns/${tarball_filename} || abort "faild to download source file"
  md5sum -c ../../copr_repo/sources > /dev/null || abort "md5sum miss match"
) || exit 1

knot_ver=$(awk '/^Version:/{print $2}' copr_repo/knot.spec)

image_name=kdig
image_tag=${knot_ver}

# copy spec file and sources
cp copr_repo/knot.spec rpmbuild/SPECS || abort "failed to copy spec file"
cp copr_repo/* rpmbuild/SOURCES || abort "faild to copy sources"

# build
## PUSH: false
docker build --progress plain --platform linux/amd64,linux/arm64 -t smbd/${image_name}:${image_tag} --build-arg ROCKY_REL=${ROCKY_REL} . || abort "docker build faild. abort."
docker build --load -t smbd/${image_name}:${image_tag} --build-arg ROCKY_REL=${ROCKY_REL} . || abort "docker build faild. abort."

if [ "${LATEST}" == "true" ] ; then
  docker build --platform linux/amd64,linux/arm64 -t smbd/${image_name}:latest --build-arg ROCKY_REL=${ROCKY_REL} . || abort "docker build faild. abort."
  docker build --load -t smbd/${image_name}:latest --build-arg ROCKY_REL=${ROCKY_REL} . || abort "docker build faild. abort."
fi

if [ "${PUSH}" == "true" ] ; then
  docker build --push --platform linux/amd64,linux/arm64 -t smbd/${image_name}:${image_tag} --build-arg ROCKY_REL=${ROCKY_REL} . || abort "docker build faild. abort."
  if [ "${LATEST}" == "true" ] ; then
    docker build --push --platform linux/amd64,linux/arm64 -t smbd/${image_name}:latest --build-arg ROCKY_REL=${ROCKY_REL} . || abort "docker build faild. abort."
  fi
fi

