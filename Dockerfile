FROM alpine:3.5

RUN apk add --no-cache --virtual .build-deps ca-certificates curl unzip
RUN apk add --no-cache --virtual .build-deps libsodium-dev python git ca-certificates iptables
 
 
COPY liblkl.so configure.sh /root/
RUN chmod a+x /root/liblkl-hijack.so /root/configure.sh
ENTRYPOINT ["/root/configure.sh"]
CMD /root/configure.sh
