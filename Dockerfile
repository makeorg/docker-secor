FROM maven:3-jdk-8 as builder
MAINTAINER Samuel Bernard "samuel.bernard@gmail.com"

WORKDIR /root
RUN \
# Build Secor with kafka-2.0.0 profil
  git clone https://github.com/pinterest/secor.git && \
  cd secor && \
  git checkout master && \
  mvn -T 2C -Pkafka-2.0.0 clean package && \
  mv target/secor-*-bin.tar.gz target/secor-bin.tar.gz
Run \
  cd secor && \
  printf 'VERSION=${project.version}\n0\n' | \
  mvn org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate | \
  grep '^VERSION' > version && \
  echo GIT_SHA=$(git rev-parse --verify HEAD) >> version

# Restart from clean image
FROM azul/zulu-openjdk-alpine:8
# Create user
RUN adduser -D secor
COPY --from=builder /root/secor/target/secor-bin.tar.gz /tmp/.

WORKDIR /home/secor
RUN \
  tar xfz /tmp/secor-bin.tar.gz && \
# Remove useless config files, easier to seen what is the current config
  rm -f *.dev.* *.test.* log4j.prod.* *.warn.* secor.prod.backup.* && \
  mv secor-*.jar secor.jar

COPY --from=builder /root/secor/version /home/secor/.
COPY run.sh /home/secor/.
USER secor
CMD ["/home/secor/run.sh"]
