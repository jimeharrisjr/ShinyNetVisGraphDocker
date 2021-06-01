FROM jimeharrisjr/raspi-r-base:latest

LABEL org.label-schema.license="GPL-2.0" \
      maintainer="Jim Harris <jimeharrisjr@gmail.com>"

ARG R_VERSION
ARG BUILD_DATE
ARG CRAN
ENV BUILD_DATE ${BUILD_DATE:-2021-02-09}
ENV R_VERSION=${R_VERSION:-3.6.3} \
    CRAN=${CRAN:-https://cran.rstudio.com} \ 
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TERM=xterm
  

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libssl-dev \
    libcurl4-openssl-dev \
    libsasl2-dev \
    net-tools \
    libhiredis-dev \
    libz-dev \
    libpcap-dev\
    cmake \
    git

RUN git clone https://github.com/mfontanini/libtins.git \
    && mkdir libtins/build \
    && cd libtins/build \
    && cmake .. -DCMAKE_INSTALL_PREFIX=/usr \
    && make \
    && make install


RUN apt-get -y install libcurl4-gnutls-dev
RUN Rscript -e "install.packages(c('remotes','shiny','shinydashboard','visNetwork','data.table','igraph'), repo = '$CRAN')" 

RUN Rscript -e "remotes::install_github('https://github.com/jimeharrisjr/rtins')"

ADD ShinyNetVisGraph /home/ShinyNetVisGraph
RUN cd /home/ShinyNetVisGraph
EXPOSE 8080
CMD ["R","-e","shiny::runApp('/home/ShinyNetVisGraph',host='0.0.0.0',port=8080)"]
