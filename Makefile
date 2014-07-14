# Makefile used to test and package SlackBuild scripts

# Copyright Talos Thoren <talosthoren@gmail.com>
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SHELL := /bin/bash
ARCH := `uname -m`
APP_NAME := steam
TAR_NAME := ${APP_NAME}.tar
ARCHIVE_NAME := ${TAR_NAME}.gz
TMP_DIR := ${CURDIR}/_tmp/${APP_NAME}
CHECK_DIR := ${CURDIR}/_dist
SOURCE_URL_32 := `awk -F'"' '/DOWNLOAD=/ {print $$2}' ${APP_NAME}.info`
SOURCE_URL_64 := `awk -F'"' '/DOWNLOAD_x86_64/ {print $$2}' ${APP_NAME}.info`
VERSION := 1.0.0.48
SOURCE_ARCHIVE := ${APP_NAME}\_${VERSION}.tar.gz

default: dist

check: getsource
	sh ./${APP_NAME}.SlackBuild

distcheck: dist getsource
	-mkdir ${CHECK_DIR}
	-cp ${ARCHIVE_NAME} ${CHECK_DIR}
	cd ${CHECK_DIR} && tar xvzf ${ARCHIVE_NAME}
	-cp ${SOURCE_ARCHIVE} ${CHECK_DIR}/${APP_NAME}
	cd ${CHECK_DIR}/${APP_NAME} && sh ./${APP_NAME}.SlackBuild
	${MAKE} clean

getsource:
	if [ ! -e ${SOURCE_ARCHIVE} ]; then\
		if [[ ("${ARCH}" = "x86_64") && (-n "${SOURCE_URL_64}") ]]; then\
			wget "${SOURCE_URL_64}";\
		else\
			wget "${SOURCE_URL_32}";\
		fi;\
	fi

dist: ${ARCHIVE_NAME} cleantmp

clean: cleantmp
	-rm -f ./*~
	-rm -f ./*.swp
	-rm -f ${ARCHIVE_NAME}
	-rm -rf ./${APP_NAME}
	-rm -rf ./_dist

cleantmp:
	-rm -rvf _tmp

${ARCHIVE_NAME}: ${TAR_NAME}
	cd _tmp && gzip ${TAR_NAME}
	mv _tmp/${ARCHIVE_NAME} .

${TAR_NAME}: ${TMP_DIR}
	cp ${CURDIR}/doinst.sh ${TMP_DIR}
	cp ${CURDIR}/slack-desc ${TMP_DIR}
	cp ${CURDIR}/README ${TMP_DIR}
	cp ${CURDIR}/${APP_NAME}.info ${TMP_DIR}
	cp ${CURDIR}/${APP_NAME}.SlackBuild ${TMP_DIR}
	cd _tmp && tar cvf ${TAR_NAME} ${APP_NAME}

${TMP_DIR}:
	-mkdir -p ${TMP_DIR}

.PHONY: default dist distcheck getsource cleantmp clean
