pipeline {
    agent none
   stages {     
    stage('Maven Install') {
      agent any     
  steps {
       sh './mvnw package -Dmaven.test.skip'
       }
     }
     stage('Docker Build') {
       agent any
       steps {
         sh 'docker build -t vannt/sprint-boot:latest .'
       }
     }
   }
 }