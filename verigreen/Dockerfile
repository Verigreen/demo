FROM verigreen/vg-collector:2.0.1
MAINTAINER Ricardo Quintana http://github.com/rqc

RUN apt-get update && apt-get install -y \
										--fix-missing  \
										curl \
										unzip \
										bash \
										host \
										dnsutils \
										net-tools \
                                        sendmail \
										&& \
										apt-get clean

WORKDIR $VG_ROOT

ADD pre-entrypoint.sh pre-entrypoint.sh
ADD update_hosts.sh update_hosts.sh
RUN chmod +x pre-entrypoint.sh
RUN chmod +x update_hosts.sh

CMD ["./pre-entrypoint.sh"]