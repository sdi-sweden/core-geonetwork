The web module contains the static resources and configuration file for building the final web application WAR.
# Web Application Configuration

# Run in embedded Jetty for development

To run the application with the embedded Jetty for development execute this command:

```
$ mvn jetty:run-exploded -Penv-dev
```

**TODO:** Investigate to get working the UI module (`se-web-ui`) using `jetty:run`

