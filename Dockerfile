FROM r-base

RUN apt-get update
RUN apt-get -y install -y -qq \ 
			curl \
			libxml2-dev \ 
			libgit2-dev \
			unixodbc-dev
			
RUN apt-get -y install -y -qq \
			r-cran-devtools \
			r-cran-plumber \
			r-cran-jsonlite \ 
			r-cran-stringr \
			r-cran-dplyr \
			r-cran-data.table \
			r-cran-rodbc \
	    	r-cran-openxlsx \
			r-cran-future 

RUN R -e "install.packages(c('openxlsx2', 'odbc'), repos = 'http://cran.r-project.org')"			

# Environment variables
WORKDIR /home/exporter

# Copies the app sources 
COPY ./app .
copy ./update_libs.R .

# External argument(s)
ARG GITLAB_AUTH_TOKEN

# Environment variables
#ENV _R_SHLIB_STRIP_=true
ENV GITLAB_AUTH_TOKEN=$GITLAB_AUTH_TOKEN

ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache

RUN Rscript ./update_libs.R

EXPOSE 3838

ENTRYPOINT ["Rscript", "./run_plumber.R"]