FROM perl:5.28

WORKDIR /opt/game
COPY . .

RUN cpanm --notest Carton
RUN carton install

