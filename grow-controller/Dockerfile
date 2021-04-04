from python:3.9

WORKDIR /var/www

RUN apt-get update && apt-get install -y vim curl

RUN groupadd -g 1000 grow
RUN useradd -u 1000 -m -s /bin/bash -g grow grow

COPY --chmod=grow:grow ./ /var/www

USER grow
RUN pip install -r requirements.txt

CMD python3 -m src.main
