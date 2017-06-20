FROM elasticsearch:5.2

# x-pack 
RUN elasticsearch-plugin  install --batch x-pack

# kuromoji
RUN elasticsearch-plugin  install analysis-kuromoji

# TimeZone
RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

