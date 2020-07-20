FROM alpine:3.5
USER root
RUN apk add --no-cache --virtual .build-deps ca-certificates curl unzip
RUN apk add --no-cache --virtual .build-deps libsodium-dev python git ca-certificates iptables
 
 
#COPY liblkl.so configure.sh /root/
#RUN chmod a+x /root/liblkl.so /root/configure.sh
COPY config-port.conf rinetd configure.sh /root/
RUN chmod a+x /root/config-port.conf /root/configure.sh /root/rinetd
ENTRYPOINT ["/root/configure.sh"]
CMD /root/configure.sh
