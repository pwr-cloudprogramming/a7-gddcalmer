FROM busybox:1.35


RUN adduser -D stud
USER stud
WORKDIR /home/stud

COPY src/ .



ENTRYPOINT ["busybox"]
EXPOSE 3000
CMD ["httpd", "-f", "-v", "-p", "3000"]