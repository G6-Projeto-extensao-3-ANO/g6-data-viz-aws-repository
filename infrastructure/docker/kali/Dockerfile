FROM kasmweb/kali-rolling-desktop:1.15.0

USER root

COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

ENTRYPOINT ["/setup.sh"]