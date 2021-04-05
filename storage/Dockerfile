from python:3.9

WORKDIR /var/www

RUN apt-get update && apt-get install -y sqlite3 curl vim

RUN groupadd -g 1000 storage
RUN useradd -u 1000 -m -s /bin/bash -g storage storage 

COPY ./ /var/www
RUN chown -R storage:storage /var/www
RUN mkdir /var/storage
RUN chown storage:storage /var/storage

USER storage
RUN pip install -r requirements.txt

EXPOSE 8080
CMD python3 -m src.app
