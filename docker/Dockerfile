FROM ghcr.io/alalazo/manylinux2014-base:master AS build_base
COPY build_scripts/install-build-packages.sh /build_scripts/
RUN manylinux-entrypoint /build_scripts/install-build-packages.sh


FROM build_base AS build_git
COPY build_scripts/build-git.sh /build_scripts/
RUN export GIT_ROOT=git-2.31.1 && \
    export GIT_HASH=46d37c229e9d786510e0c53b60065704ce92d5aedc16f2c5111e3ed35093bfa7 && \
    export GIT_DOWNLOAD_URL=https://www.kernel.org/pub/software/scm/git && \
    manylinux-entrypoint /build_scripts/build-git.sh


FROM build_base AS build_cmake
COPY build_scripts/build-cmake.sh /build_scripts/
RUN export CMAKE_VERSION=3.20.0 && \
    export CMAKE_HASH=9c06b2ddf7c337e31d8201f6ebcd3bba86a9a033976a9aee207fe0c6971f4755 && \
    export CMAKE_DOWNLOAD_URL=https://github.com/Kitware/CMake/releases/download && \
    manylinux-entrypoint /build_scripts/build-cmake.sh


#FROM build_base AS build_swig
#COPY build_scripts/build-swig.sh /build_scripts/
#RUN export SWIG_ROOT=swig-4.0.2 && \
#    export SWIG_HASH=d53be9730d8d58a16bf0cbd1f8ac0c0c3e1090573168bfa151b01eb47fa906fc && \
#    export SWIG_DOWNLOAD_URL=https://sourceforge.net/projects/swig/files/swig/${SWIG_ROOT} && \
#    export PCRE_ROOT=pcre-8.44 && \
#    export PCRE_HASH=aecafd4af3bd0f3935721af77b889d9024b2e01d96b58471bd91a3063fb47728 && \
#    export PCRE_DOWNLOAD_URL=https://ftp.pcre.org/pub/pcre && \
#    manylinux-entrypoint /build_scripts/build-swig.sh


FROM build_base AS build_cpython
COPY build_scripts/build-sqlite3.sh /build_scripts/
RUN export SQLITE_AUTOCONF_ROOT=sqlite-autoconf-3350400 && \
    export SQLITE_AUTOCONF_HASH=7771525dff0185bfe9638ccce23faa0e1451757ddbda5a6c853bb80b923a512d && \
    export SQLITE_AUTOCONF_DOWNLOAD_URL=https://www.sqlite.org/2021 && \
    manylinux-entrypoint /build_scripts/build-sqlite3.sh

COPY build_scripts/build-openssl.sh /build_scripts/
RUN export OPENSSL_ROOT=openssl-1.1.1k && \
    export OPENSSL_HASH=892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5 && \
    export OPENSSL_DOWNLOAD_URL=https://www.openssl.org/source && \
    manylinux-entrypoint /build_scripts/build-openssl.sh

COPY build_scripts/build-cpython.sh /build_scripts/


FROM build_cpython AS build_cpython35
COPY build_scripts/cpython-pubkeys.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint gpg --import /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.5.10


FROM build_cpython AS build_cpython36
COPY build_scripts/cpython-pubkeys.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint gpg --import /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.6.13


FROM build_cpython AS build_cpython37
COPY build_scripts/cpython-pubkeys.txt /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint gpg --import /build_scripts/cpython-pubkeys.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.7.10


FROM build_cpython AS build_cpython38
COPY build_scripts/ambv-pubkey.txt /build_scripts/ambv-pubkey.txt
RUN manylinux-entrypoint gpg --import /build_scripts/ambv-pubkey.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.8.9


FROM build_cpython AS build_cpython39
COPY build_scripts/ambv-pubkey.txt /build_scripts/ambv-pubkey.txt
RUN manylinux-entrypoint gpg --import /build_scripts/ambv-pubkey.txt
RUN manylinux-entrypoint /build_scripts/build-cpython.sh 3.9.4


FROM build_cpython AS all_cpython
COPY --from=build_cpython35 /opt/_internal /opt/_internal/
COPY --from=build_cpython36 /opt/_internal /opt/_internal/
COPY --from=build_cpython37 /opt/_internal /opt/_internal/
COPY --from=build_cpython38 /opt/_internal /opt/_internal/
COPY --from=build_cpython39 /opt/_internal /opt/_internal/
RUN hardlink -cv /opt/_internal


FROM ghcr.io/alalazo/manylinux2014-base:master
COPY --from=build_git /manylinux-rootfs /
COPY --from=build_cmake /manylinux-rootfs /
# COPY --from=build_swig /manylinux-rootfs /
COPY --from=build_cpython /manylinux-rootfs /
COPY --from=all_cpython /opt/_internal /opt/_internal/
COPY build_scripts/finalize.sh build_scripts/update-system-packages.sh build_scripts/python-tag-abi-tag.py build_scripts/requirements.txt build_scripts/requirements-tools.txt /build_scripts/
RUN manylinux-entrypoint /build_scripts/finalize.sh && rm -rf /build_scripts

ENV SSL_CERT_FILE=/opt/_internal/certs.pem

CMD ["/bin/bash"]
