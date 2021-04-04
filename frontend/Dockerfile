from python:3.9

WORKDIR /var/www

RUN apt-get update && apt-get install -y vim curl

RUN groupadd -g 1000 frontend
RUN useradd -u 1000 -m -s /bin/bash -g frontend frontend

COPY --chmod=frontend:frontend ./ /var/www

USER frontend
RUN pip install -r requirements.txt

EXPOSE 8080
CMD python3 -m src.app
