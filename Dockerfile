FROM ruby:2.6-stretch

MAINTAINER Sergey Homa srghma@gmail.com

ENV LANG C.UTF-8

RUN apt-get update -y; \
  apt-get upgrade -y; \
  apt-get update -qq && \
  apt-get install -y build-essential libpq-dev lsb-release

############ NODEJS ############
# stolen from here https://github.com/nodejs/docker-node/blob/master/9/Dockerfile

ENV NODE_VERSION 10.15.3

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    77984A986EBC2AA786BC0F66B01FBB92821C587A \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs

ENV YARN_VERSION 1.13.0

RUN set -ex \
  && for key in \
    6A010C5166006599AA17F08146C2130DFD2497F5 \
  ; do \
    gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" || \
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" || \
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz" \
  && curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc" \
  && gpg --batch --verify yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz \
  && mkdir -p /opt \
  && tar -xzf yarn-v$YARN_VERSION.tar.gz -C /opt/ \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarn /usr/local/bin/yarn \
  && ln -s /opt/yarn-v$YARN_VERSION/bin/yarnpkg /usr/local/bin/yarnpkg \
  && rm yarn-v$YARN_VERSION.tar.gz.asc yarn-v$YARN_VERSION.tar.gz

############ NODEJS ############

# ############ POSTGRES ############
# stolen from https://github.com/docker-library/postgres/blob/master/10/Dockerfile

ENV PG_MAJOR 10
ENV PG_VERSION 10.7-1.pgdg90+1

RUN set -ex; \
  \
# see note below about "*.pyc" files
  export PYTHONDONTWRITEBYTECODE=1; \
  \
  dpkgArch="$(dpkg --print-architecture)"; \
  case "$dpkgArch" in \
    amd64|i386|ppc64el) \
# arches officialy built by upstream
      echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
      apt-get update; \
      ;; \
    *) \
# we're on an architecture upstream doesn't officially build for
# let's build binaries from their published source packages
      echo "deb-src http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main $PG_MAJOR" > /etc/apt/sources.list.d/pgdg.list; \
      \
      case "$PG_MAJOR" in \
        9.* | 10 ) ;; \
        *) \
# https://github.com/docker-library/postgres/issues/484 (clang-6.0 required, only available in stretch-backports)
# TODO remove this once we hit buster+
          echo 'deb http://deb.debian.org/debian stretch-backports main' >> /etc/apt/sources.list.d/pgdg.list; \
          ;; \
      esac; \
      \
      tempDir="$(mktemp -d)"; \
      cd "$tempDir"; \
      \
      savedAptMark="$(apt-mark showmanual)"; \
      \
# build .deb files from upstream's source packages (which are verified by apt-get)
      apt-get update; \
      apt-get build-dep -y --allow-unauthenticated \
        postgresql-common pgdg-keyring \
        "postgresql-$PG_MAJOR=$PG_VERSION" \
      ; \
      DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" \
        apt-get source --compile \
          postgresql-common pgdg-keyring \
          "postgresql-$PG_MAJOR=$PG_VERSION" \
      ; \
# we don't remove APT lists here because they get re-downloaded and removed later
      \
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
# (which is done after we install the built packages so we don't have to redownload any overlapping dependencies)
      apt-mark showmanual | xargs apt-mark auto > /dev/null; \
      apt-mark manual $savedAptMark; \
      \
# create a temporary local APT repo to install from (so that dependency resolution can be handled by APT, as it should be)
      ls -lAFh; \
      dpkg-scanpackages . > Packages; \
      grep '^Package: ' Packages; \
      echo "deb [ trusted=yes ] file://$tempDir ./" > /etc/apt/sources.list.d/temp.list; \
# work around the following APT issue by using "Acquire::GzipIndexes=false" (overriding "/etc/apt/apt.conf.d/docker-gzip-indexes")
#   Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
#   ...
#   E: Failed to fetch store:/var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages  Could not open file /var/lib/apt/lists/partial/_tmp_tmp.ODWljpQfkE_._Packages - open (13: Permission denied)
      apt-get -o Acquire::GzipIndexes=false update; \
      ;; \
  esac; \
  \
  apt-get install -y --allow-unauthenticated postgresql-common; \
  sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf; \
  apt-get install -y --allow-unauthenticated \
    "postgresql-$PG_MAJOR=$PG_VERSION" \
  ; \
  \
  rm -rf /var/lib/apt/lists/*; \
  \
  if [ -n "$tempDir" ]; then \
# if we have leftovers from building, let's purge them (including extra, unnecessary build deps)
    apt-get purge -y --allow-unauthenticated --auto-remove; \
    rm -rf "$tempDir" /etc/apt/sources.list.d/temp.list; \
  fi; \
  \
# some of the steps above generate a lot of "*.pyc" files (and setting "PYTHONDONTWRITEBYTECODE" beforehand doesn't propagate properly for some reason), so we clean them up manually (as long as they aren't owned by a package)
  find /usr -name '*.pyc' -type f -exec bash -c 'for pyc; do dpkg -S "$pyc" &> /dev/null || rm -vf "$pyc"; done' -- '{}' +

# ############ POSTGRES ############
