// node {
//     stage('Checkout SCM') {
//         def myRepo = checkout scm
//         env.GIT_URL = myRepo.GIT_URL
//     }
//     echo sh(script: 'env|sort', returnStdout: true)
//     // def jenkinsVar = readProperties  file: './Jenkins.properties'
//     // jenkinsVar.HELM_CHART_NAME = jenkinsVar.SERVICE_NAME
//     env.GITHASH  = sh(script: "printf \$(git log -1 --oneline | cut -c 1-8 )", returnStdout: true)
//     //env.AUTHOR = sh(script: "git log -1 --format='%ae' ${GITHASH}", returnStdout: true)
//     env.AUTHOR = env.GITLAB_OA_LAST_COMMIT_AUTHOR_EMAIL ? env.GITLAB_OA_LAST_COMMIT_AUTHOR_EMAIL : env.GITLAB_COMMIT_AUTHOR_EMAIL_01
//     env.GITLAB_URL = env.GITLAB_OA_LAST_COMMIT_URL ? env.GITLAB_OA_LAST_COMMIT_URL : env.GITLAB_COMMIT_URL_01
//     // def namespaceVar = readJSON text: "{${jenkinsVar.OCP_NAMESPACES}}" , returnPojo: true
//     // pipeline(env.BRANCH_NAME, env.TAG_NAME, env.GITHASH, jenkinsVar, namespaceVar)
//     buildImage()

// }

// def buildImage () {
//     print 'Doing build image!'
//     stage('Build image') {
//        sh './mvnw package -Dmaven.test.skip'
//     }
// }

@Library('jenkins_lib@main') _

timestamps {
    node() {
        tool name: 'maven'
        stage('Checkout SCM'){
            def myRepo = checkout scm
        }
        try {
            ansiColor('xterm') {
                java_maven()
            }
        } catch (err) {
            print err
        }                   
    }
}
