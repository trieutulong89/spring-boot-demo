import groovy.json.JsonOutput
def label = "linux-worker"


node(label) {
    stage('Checkout SCM') {
        def myRepo = checkout scm
        env.GIT_URL = myRepo.GIT_URL
    }
    echo sh(script: 'env|sort', returnStdout: true)
    def jenkinsVar = readProperties  file: './Jenkins.properties'
    jenkinsVar.HELM_CHART_NAME = jenkinsVar.SERVICE_NAME
    env.GITHASH  = sh(script: "printf \$(git log -1 --oneline | cut -c 1-8 )", returnStdout: true)
    //env.AUTHOR = sh(script: "git log -1 --format='%ae' ${GITHASH}", returnStdout: true)
    env.AUTHOR = env.GITLAB_OA_LAST_COMMIT_AUTHOR_EMAIL ? env.GITLAB_OA_LAST_COMMIT_AUTHOR_EMAIL : env.GITLAB_COMMIT_AUTHOR_EMAIL_01
    env.GITLAB_URL = env.GITLAB_OA_LAST_COMMIT_URL ? env.GITLAB_OA_LAST_COMMIT_URL : env.GITLAB_COMMIT_URL_01
    def namespaceVar = readJSON text: "{${jenkinsVar.OCP_NAMESPACES}}" , returnPojo: true
    pipeline(env.BRANCH_NAME, env.TAG_NAME, env.GITHASH, jenkinsVar, namespaceVar)
}


// Function for pipeline
def pipeline(branchName, tagName, gitHash, jenkinsVar, namespaceVar) {
    def props = { }
    if (branchName != null && tagName == null && branchName != 'master') {
        def branchArr = branchName.split('/')
        // For branch Release
        if (branchName.startsWith('release') && branchArr.size() == 2 ) {
            print 'Building a version for SIT'
            def version = branchArr[1]
            props.tag_version = "${version}-sit-${gitHash}"
            props.environment = 'sit'
            // Build Image
            buildImage(props, jenkinsVar)
            // Scan image
            scanImage(props, jenkinsVar)
            // Build Helm
            def helmChartVersion = buildHelm(props, jenkinsVar)
            println "Version Chart : ${helmChartVersion}"
            println "Version Image : ${props.tag_version}"
            // Deploy service by Helm
            deployHelm(props, jenkinsVar, helmChartVersion, namespaceVar[props.environment])
        }
        // For branch Hotfix
        if (branchName.startsWith('hotfix') && branchArr.size() == 2 ) {
            print 'Building a version for HOTFIX'
            def version = branchArr[1]
            props.tag_version = "${version}-uat-${gitHash}"
            props.environment = 'hotfix'
            // Build Image
            buildImage(props, jenkinsVar)
            // Build Helm
            def helmChartVersion = buildHelm(props, jenkinsVar)
            println "Version Chart : ${helmChartVersion}"
            println "Version Image : ${props.tag_version}"
            // Deploy service by Helm
            // deployHelm(props, jenkinsVar, helmChartVersion, namespaceVar[props.environment])
        }
        // For branch Develop
        if (branchName.startsWith('develop')) {
            print 'Building a version for DEV'
            props.tag_version = "${gitHash}"
            props.environment = branchName
            // Scan Code
            scanSonar(props, jenkinsVar, branchName)
            // Build Image
            buildImage(props, jenkinsVar)
            if (namespaceVar.containsKey(props.environment) == true) {
                // Build Helm
                def helmChartVersion = buildHelm(props, jenkinsVar)
                println "Version Chart : ${helmChartVersion}"
                println "Version Image : ${props.tag_version}"
                // Deploy service by Helm
                deployHelm(props, jenkinsVar, helmChartVersion, namespaceVar[props.environment])
            }
        }
        // For Merge Request to Develop, Release, Hotfix
        if (branchName.startsWith('MR') && (env.CHANGE_TARGET.startsWith('develop') || env.CHANGE_TARGET.startsWith('release') || env.CHANGE_TARGET.startsWith('hotfix'))) {
            print 'Scan Merge Request'
            props.tag_version = "${gitHash}-pre"
            props.environment = 'dev'
            // Scan Code
            scanSonar(props, jenkinsVar, env.AUTHOR)
            // Build Image
            // buildImage(props, jenkinsVar)
            // Scan Image
            // scanImage(props, jenkinsVar)
        }
    }
    if (tagName != null) {
        // For tag x.y.z-uat-date
        if (tagName.split('-').size() == 3 && tagName.contains('-uat-')) {
            print 'Building a version for UAT'
            def version = tagName.split('-')[0]
            props.pre_version = "${version}-sit-${gitHash}"
            props.tag_version = "${version}-uat-${gitHash}"
            props.environment = 'uat'
            // Retag Image
            reTagImage(props, jenkinsVar)
            // Build Helm
            def helmChartVersion = buildHelm(props, jenkinsVar)
            println "Version Chart : ${helmChartVersion}"
            println "Version Image : ${props.tag_version}"
            // Deploy service by Helm
            deployHelm(props, jenkinsVar, helmChartVersion, namespaceVar[props.environment])
        }
        // For tag x.y.z
        if (tagName ==~ /(\d.){2}\d/)  {
            props.pre_version = "${tagName}-uat-${gitHash}"
            props.tag_version = "${tagName}"
            props.environment = 'stg'
            // Retag Image
            reTagImage(props, jenkinsVar)
            // Build Helm
            def helmChartVersion = buildHelm(props, jenkinsVar)
            println "Version Chart : ${helmChartVersion}"
            println "Version Image : ${props.tag_version}"
            // Deploy service by Helm
            // deployHelm(props, jenkinsVar, helmChartVersion, namespaceVar[props.environment])
        }
    }
}

def buildImage (props, jenkinsVar) {
    print 'Doing build image!'
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: jenkinsVar.CREDENTIALSID, usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASSWD']]) {       
        node(label) {
            stage('Build service') {
                sh "mvn -s /maven/setting.xml package"
            }
            stage('Build image') {
                sh "buildah login -u ${NEXUS_USER} -p ${NEXUS_PASSWD} ${jenkinsVar.IMAGE_REGISTRY}"
                sh "buildah bud --no-cache --pull --format=docker -f Dockerfile -t ${jenkinsVar.IMAGE_REGISTRY}/${jenkinsVar.IMAGE_FOLDER}/${jenkinsVar.SERVICE_NAME}:${props.tag_version} ."
                sh "buildah push ${jenkinsVar.IMAGE_REGISTRY}/${jenkinsVar.IMAGE_FOLDER}/${jenkinsVar.SERVICE_NAME}:${props.tag_version}"
            }
        }
    print 'build image completed'
    }
}
