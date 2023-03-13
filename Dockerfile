FROM public.ecr.aws/u3x5d0k4/maven:3.8.6-openjdk-11-slim@sha256:d12b61d6ea1938fd3f8b194f06276a2b70b4f1f5b2a87304a7c0c585db64b242 AS build
COPY src /home/app/src
COPY pom.xml /home/app
RUN mvn -f /home/app/pom.xml clean package -DskipTests
RUN ls -al /home/app/target

FROM public.ecr.aws/u3x5d0k4/openjdk:11.0.6-jre-slim@sha256:01669f539159a1b5dd69c4782be9cc7da0ac1f4ddc5e2c2d871ef1481efd693e
ENV TZ="Asia/Kolkata" 
RUN apt-get update  && apt-get install --no-install-recommends dumb-init=1.2.2-1.1 -y && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir /app
RUN addgroup --system javauser && useradd javauser -g javauser   
COPY  --from=build /home/app/target/*.war /app/app.war
WORKDIR /app
RUN chown -R javauser:javauser /app
USER javauser
CMD ["dumb-init","java","-jar","app.war"]
