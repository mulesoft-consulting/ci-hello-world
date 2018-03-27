pipeline {
    agent any

    parameters {
        booleanParam(name: 'IS_RELEASE',
            defaultValue: false,
            description: 'Enable if you would like to build Release Candidate.'
        )
    }

    environment {
        MVNREPO_USER     = credentials('nexus_user')
        MVNREPO_PASSWORD = credentials('nexus_psswd')
        MULEREPO_USER     = credentials('mulerepo_usr')
        MULEREPO_PASSWORD = credentials('mulerepo_psswd')
        MULEANYPOINT_USER = credentials('anypoint_username')
        MULEANYPOINT_PASSWORD = credentials('anypoint_password')
        SCM_USER = credentials('scm_user')
        SCM_PASSWORD = credentials('scm_psswd')      
        MVNREPO_URL = credentials('mvn_repo_url') //e.g. http://172.17.0.7:8081
        MVNREPO_CENTRAL = 'maven-central/'
        MVNREPO_MULE_EE = 'maven-mule-ee/'
        MVNREPO_MULE_PUBLIC = 'maven-mule-public/'
    } 
    
    triggers {
        pollSCM('* * * * *')
    }

    tools {
        maven 'maven' 
    }

    stages {
    
        stage('FEATURE Build and Test') {
            when {
                allOf {
                    branch 'feature-*' 
                }
            } 
            steps { 
                sh 'mvn -s settings.xml clean test' 
            }
        }
        
        stage('DEV and TEST Build, Test, and Deploy') {
            when {
                expression {
                    return params.IS_RELEASE == false
                }
                branch 'dev-*'
            } 
            steps { 
                sh 'mvn -s settings.xml clean deploy'
            }
        }
        
        stage('Prepare Release') {
            when {
                expression {
                    return params.IS_RELEASE
                }
                branch 'dev-*'
            } 
            steps {
                script {
                    def lastCommit = sh returnStdout: true, script: 'git log -1 --pretty=%B'
                    if (lastCommit.contains("[maven-release-plugin]")){
                        sh "echo  Commit done by Maven Release Plugin - build is being skipped"

                    } else {
                    //checkout needs to be done, because Jenkins uses shallow clones, which causes 
                    //“Git fatal: ref HEAD is not a symbolic ref” exception while using Maven Release Plugin
                        sh "git checkout ${env.BRANCH_NAME}"
                        sh 'mvn -s settings.xml clean release:prepare'
                        sh 'mvn -s settings.xml release:perform' 
                    }
                } 
            }
        }
        
        stage('PROD Build and Test') {
            when {
                allOf {
                    branch 'master' 
                }
            } 
            steps { 
                sh 'mvn -s settings.xml clean test' 
            }
        }
        
    }

    post {
        always {
            archive 'target/**/*.zip'
            archive 'target/munit-reports/coverage-json/**/*.json'
            junit 'target/surefire-reports/**/*.xml'
            cleanWs()
        }
    }
}