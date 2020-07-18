FROM alpine:3.5

RUN apk add --no-cache --virtual .build-deps ca-certificates curl unzip
RUN apk add --no-cache --virtual .build-deps libsodium-dev python git ca-certificates iptables
 
 
COPY liblkl.so /root/
RUN chmod a+x /root/liblkl-hijack.so 

ADD configure.sh /configure.sh
RUN chmod +x /configure.sh
CMD /configure.sh
