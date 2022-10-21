FROM debian:bullseye

LABEL MAINTAINER Certus Software S.R.L. <security _AT_ certussoftware _DOT_ ro>
LABEL VERSION ="1.0"
LABEL DESCRIPTION ="Docker image to build shim-15.6 for Certus Software S.R.L."

RUN apt-get update -y
RUN echo "deb-src http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian-security bullseye-security main" >> /etc/apt/sources.list
RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends build-essential git-buildpackage dos2unix

RUN git clone --recursive -b 15.6 https://github.com/rhboot/shim.git shim

COPY shimx64.efi /
COPY certus.cer /shim/pub.cer
COPY sbat.certus.csv /shim/data/

WORKDIR /shim
RUN make VENDOR_CERT_FILE=pub.cer

RUN hexdump -Cv /shim/shimx64.efi > build
RUN hexdump -Cv /shimx64.efi > orig
RUN diff -u orig build

RUN sha256sum /shimx64.efi /shim/shimx64.efi
RUN objdump -s -j .sbat /shim/shimx64.efi
