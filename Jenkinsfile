properties([
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '7'))
])

def publishable_branches = ["development", "master"]

node('docker') {
  withEnv(["npm_config_cache=$WORKSPACE/.npm"]){
    stage('Build devicehive-admin-panel') {
      def node = docker.image('node:9')
      node.pull()
      node.inside {
        sh('curl -L "https://github.com/devicehive/devicehive-admin-panel/archive/1.0.0.tar.gz" | tar -zxf - --strip-components=1')
        writeFile file: 'src/environments/environment.prod.ts', text: """export const environment = {
        production: true,
        autoUpdateSession: true,
        mainServiceURL: '/api/rest',
        authServiceURL: '/auth/rest',
        pluginServiceURL: '/plugin/rest'
        };
        """

        sh '''
          npm install
          npm run build -- --base-href=/admin/
          rm -rf admin
          mv -T dist admin
        '''
        def artifacts = 'admin/**'
        stash includes: artifacts, name: 'dist'
       }
    }
  }
  stage('Build and publish Docker images in CI repository') {
    checkout scm
    unstash 'dist'
    echo 'Building image ...'
    def DevicehiveProxy = docker.build('devicehiveci/devicehive-proxy:${BRANCH_NAME}', '--pull -f Dockerfile .')

    echo 'Pushing image to CI repository ...'
    docker.withRegistry('https://registry.hub.docker.com', 'devicehiveci_dockerhub'){
      DevicehiveProxy.push()
    }
  }
}

if (publishable_branches.contains(env.BRANCH_NAME)) {
  node('docker') {
    stage('Publish image in main repository') {
      // Builds from 'master' branch will have 'latest' tag
      def IMAGE_TAG = (env.BRANCH_NAME == 'master') ? 'latest' : env.BRANCH_NAME

      docker.withRegistry('https://registry.hub.docker.com', 'devicehiveci_dockerhub'){
        sh """
          docker tag devicehiveci/devicehive-proxy:${BRANCH_NAME} registry.hub.docker.com/devicehive/devicehive-proxy:${IMAGE_TAG}
          docker push registry.hub.docker.com/devicehive/devicehive-proxy:${IMAGE_TAG}
        """
      }
    }
  }
}
