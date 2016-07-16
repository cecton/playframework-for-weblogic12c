# playframework-for-weblogic12c
Docker image with Play Framework working on WebLogic 12c

## Troubleshooting

### war/WEB-INF/weblogic.xml

Create `war/WEB-INF/weblogic.xml` at the root of your play project. In it, put the following:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<wls:weblogic-web-app
        xmlns:wls="http://xmlns.oracle.com/weblogic/weblogic-web-app"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/ejb-jar_3_0.xsd http://xmlns.oracle.com/weblogic/weblogic-web-app http://xmlns.oracle.com/weblogic/weblogic-web-app/1.4/weblogic-web-app.xsd">
    <wls:container-descriptor>
        <wls:prefer-application-packages>
            <wls:package-name>org.slf4j</wls:package-name>
        </wls:prefer-application-packages>
    </wls:container-descriptor>
</wls:weblogic-web-app>
```

This will make sure to use play's slf4j package over Weblogic's.

See also [these notes](https://github.com/tomzx/play-framework-notes/tree/12.1).
