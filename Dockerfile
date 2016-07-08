# NOTE: the Play Framework tests doesn't pass on Java 7
FROM java:6
#FROM williamyeh/java7 # TODO works better?

ENV PLAYFRAMEWORK_VERSION=2.3.10

ADD https://raw.githubusercontent.com/guilhem/apt-get-install/master/apt-get-install /usr/bin/
RUN chmod +x /usr/bin/apt-get-install

RUN apt-get-install git patch unzip

RUN cd / && git clone git://github.com/playframework/playframework.git

RUN cd /playframework && \
	git reset --hard $PLAYFRAMEWORK_VERSION

# NOTE: the patch 422ca97c54a7ab84cb965df1474f2cd0d11e5fc6 is used to make
# Play Framework work on WebLogic 12c. This is already in the branch 2.3.x
# NOTE: the patch 6481551605958e4b08e383681c80cbccf5f6e942 is used to make
# the tests of Play Framework pass. I will propose its backport to 2.3.x.
ENV PATCHES="422ca97c54a7ab84cb965df1474f2cd0d11e5fc6 6481551605958e4b08e383681c80cbccf5f6e942"

# NOTE: fixes indentation changes
RUN cd /playframework && \
	perl -ne 's/ \|/|/ if (/configString = """/ .. /"""\.stripMargin/); print' \
		documentation/manual/detailedTopics/configuration/ws/code/HowsMySSLSpec.scala \
		>/tmp/HowsMySSLSpec.scala && \
	mv -f /tmp/HowsMySSLSpec.scala documentation/manual/detailedTopics/configuration/ws/code/HowsMySSLSpec.scala

RUN cd /playframework && \
	for hash in $PATCHES; do \
		git show -s $hash && \
		git show $hash | patch -p1 -F3 -l || exit 1; \
	done

# NOTE: this should be the default but if you change the base Docker image
# you may encounter an issue because part of the source code is in UTF-8.
# If the base image doesn't use UTF-8 as default encoding, the build will
# fail.
ENV LANG=C.UTF-8

RUN cd /playframework/framework && ./build publish-local

# NOTE: this is an extra layer only to make sure the Play Framework is working
# properly. You could remove this line if you want to get a light version of this image
RUN cd /playframework/framework && ./runtests

ENV ACTIVATOR_VER=1.3.4

RUN wget --progress=dot http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VER/typesafe-activator-${ACTIVATOR_VER}-minimal.zip && \
	unzip typesafe-activator-${ACTIVATOR_VER}-minimal.zip -d / && \
	rm typesafe-activator-${ACTIVATOR_VER}-minimal.zip && \
	chmod a+x /activator-${ACTIVATOR_VER}-minimal/activator

ENV PATH $PATH:/activator-$ACTIVATOR_VER-minimal

# NOTE: install activator dependencies in the image already
RUN activator list-templates || exit 0

EXPOSE 9000 8888

ENTRYPOINT ["activator"]
