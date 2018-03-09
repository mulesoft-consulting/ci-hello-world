# CICD Hello World

**Automated build ready for self-service**

Project demonstrates DevOps best prectices, tooling and configuration and is mostly focused on CI.

**Key topics are:**

* Maven configuration
	* (Internal) Maven Repository Configuration: `Nexus` has been used for the purposes of this document
	* [Maven scm plugin](https://maven.apache.org/scm/maven-scm-plugin/)
* [MUnit](https://docs.mulesoft.com/munit/v/1.3/)
* Source code branching
* CI pipeline - design and build: `Jenkins` has been used to demostrate implementation of the proposed design
* Prepare a release
	* [Maven release plugin](http://maven.apache.org/maven-release/maven-release-plugin/)

## Maven configuration

### Maven repository `Nexus`

[Repostiory Mirroring](https://maven.apache.org/guides/mini/guide-mirror-settings.html)

<details><summary>Sample Config - settings.xml</summary><p>
	
```xml
<mirrors>
  <mirror>
    <id>nexus</id>
    <mirrorOf>central</mirrorOf>
    <url>${MVNREPO_URL}/repository/${MVNREPO_CENTRAL}</url>
  </mirror>

  <mirror>
    <id>mule-extra-repos</id>
    <mirrorOf>mule-public</mirrorOf>
    <url>${MVNREPO_URL}/repository/${MVNREPO_MULE_PUBLIC}</url>
  </mirror>

  <mirror>
    <id>Mule</id>
    <mirrorOf>MuleRepository</mirrorOf>
    <url>${MVNREPO_URL}/repository/${MVNREPO_MULE_EE}</url>
  </mirror>
</mirrors>
```

</p></details>

### Deployment on DEV environment

<details><summary>Sample Config - on-prem runtime</summary><p>
	
```xml
<plugin>
  <groupId>org.mule.tools.maven</groupId>
  <artifactId>mule-maven-plugin</artifactId>
  <version>2.2.1</version>
  <configuration>
    <deploymentType>arm</deploymentType>
    <username>${MULEANYPOINT_USR}</username>
    <password>${MULEANYPOINT_PASSWORD}</password>
    <target>summer</target>
    <!-- One of: server, serverGroup, cluster -->
    <targetType>server</targetType>
    <environment>TEST</environment>
  </configuration>
  <executions>
    <execution>
      <id>deploy</id>
      <phase>deploy</phase>
      <goals>
        <goal>deploy</goal>
      </goals>
    </execution>
  </executions>
</plugin>
```

</p></details>

### MUnit

<details><summary>Sample Config</summary><p>
	
```xml
<plugin>
  <groupId>com.mulesoft.munit.tools</groupId>
  <artifactId>munit-maven-plugin</artifactId>
  <version>${munit.version}</version>
  <executions>
    <execution>
      <id>test</id>
      <phase>test</phase>
      <goals>
        <goal>test</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
    <coverage>
      <runCoverage>true</runCoverage>
      <failBuild>true</failBuild>
      <requiredApplicationCoverage>80</requiredApplicationCoverage>
      <requiredFlowCoverage>80</requiredFlowCoverage>
      <formats>
        <format>html</format>
        <format>json</format>
      </formats>
    </coverage>
  </configuration>
</plugin>
```

</p></details>

## Source code branching

The diagram below captures the suggested branching strategy, which also impacts the design of CI pipelines.

![Branching strategy](./images/scm-branching.png)

* **Feature branch**: feature development - branch usually maintained by one developer working on the specific feature.
* **Main development branch**: all the finalised features are merged to development branch. The new releases or release candidates are created from this branch.
* **Prod branch**: Once the release is deployed to production, code from development branch is merged to Master that represents production code.
* **Hotfix branch**: Created from Mater / PROD branch if critical issue is identified in production and requires immediate fix.

## CI/CD Pipeline design

The main focus of this document is to provide detailed view on CI pipeline definition. CD pipelines are mentioned mostly to maintain completed DevOps picture.

**Continuous Integration**

![CI pipeline design](./images/ci-pipeline-design.png)

As displayed on the diagram above, package creation and deployment (to Nexus and DEV environment) is triggered only for development branch (name starts with 'dev-').
Feature branch and PROD branch do not create any packages, neither do deployment. The only purpose of these pipelines is to run the MUnit tests to ensure code quality.

**Continuous Deployment**

![CD pipeline design](./images/cd-pipeline-design.png)

Deployment on DEV is the only deployment considered and implemented in this example. Deployment on development environment should be triggered every time there is a commit to development brach (as per the configuration in `Jenkinsfile`, every branch starting with 'dev-' is considered as development branch). [Mule maven plugin](https://docs.mulesoft.com/mule-user-guide/v/3.9/mule-maven-plugin) is used for deployement to development environment.

Deployment on TEST and PROD are included just for illustration purposes. There are different tools and approaches that could help with the application deployment. Some of them are mentioned in [Recommendations section](#recommendations).

### Pipeline as a Code

Pipeline defined in `Jenkinsfile` implements different stages of the build process depending on the source code branch that triggered the build execution as desribed in [parent section](#ci-pipeline-design).

#### Benefits of Pipeline

- Code: Pipelines are implemented in code and typically checked into source control, giving teams the ability to edit, review, and iterate upon their delivery pipeline.
- Durable: Pipelines can survive both planned and unplanned restarts of CI server
- Pausable: Pipelines can optionally stop and wait for human input or approval before continuing the Pipeline run.
- Versatile: Pipelines support complex real-world continuous delivery requirements, including the ability to fork/join, loop, and perform work in parallel.

### Jenkins configuration
* Environment variables
  * MULEANYPOINT_USR
  * MULEANYPOINT_PASSWORD
* `settings.xml` for Jenkins

## How to use `cicd_build_hello_world`
This project implements all patterns discussed above. It gives us the ability to quickly test and prove design decisions and configuration.

## Recommendations
Check the following [project](https://github.com/mulesoft-consulting/automated_api_promotion) for establishing simple CD within the organisation.

