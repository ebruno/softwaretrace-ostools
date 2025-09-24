FROM docker.io/fedora:42

LABEL title="Fedora 42 with rpmbuild support"
LABEL description="Contains cmake and rpm build utils."
# Tools for static analysis and unit testing shell scripts.
# Tools for C/CPP static analysis.
WORKDIR /
COPY packages /packages/
RUN dnf -y update &&  \
    dnf -y install cmake clang cmake-fedora cmake-rpm-macros cppcheck gcc make rpm-build rpmdevtools shellcheck && \
    dnf clean all && \
    dnf repolist && \
    ls -la /packages && \
    tar -C /usr/lib -xzf /packages/shellspec-dist.tar.gz && \
    install /packages/shellspec /usr/bin/shellspec && \
    rm -rf /packages;


ENTRYPOINT ["/usr/bin/bash"]
