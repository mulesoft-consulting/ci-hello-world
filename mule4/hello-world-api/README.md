API utilises [Mule 4 RESTful API Template](https://github.com/mulesoft-labs/mule4-api-template).

Mule Maven Plugin in pom.xml is configured to deploy to CloudHub instead of on-prem, as described in the documentation on the main page.
```xml
<plugin>
  <groupId>org.mule.tools.maven</groupId>
  <artifactId>mule-maven-plugin</artifactId>
  <version>${mule.maven.plugin.version}</version>
  <extensions>true</extensions>
  <configuration>
    <classifier>mule-application</classifier>
    <!-- DEPLOYMENT CONFIG -->
    <cloudHubDeployment>
      <uri>https://anypoint.mulesoft.com</uri>
      <muleVersion>4.1.3</muleVersion>
      <username>${MULEANYPOINT_USER}</username>
      <password>${MULEANYPOINT_PASSWORD}</password>
      <applicationName>${deployment.app.name.prefix}-${project.artifactId}</applicationName>
      <environment>TEST</environment>
      <workerType>MICRO</workerType>
      <workers>1</workers>
      <!-- EU (London) -->
      <region>eu-west-2</region>
      <properties>
        <!-- just to demonstrate how property can be set -->
        <api.http.listener.port>8091</api.http.listener.port>
      </properties>
    </cloudHubDeployment>
  </configuration>
</plugin>
```
