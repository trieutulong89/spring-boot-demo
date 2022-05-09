pipeline {
    agent none
   stages {     
    stage('Maven Install') {
      agent any     
  steps {
       sh 'mvn clean install'
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