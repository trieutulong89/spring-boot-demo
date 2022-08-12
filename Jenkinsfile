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
