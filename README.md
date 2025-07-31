Considerations:
I explained to Gary (Fox) that I have not previously worked with Kubernetes or EKS, but I was happy to turn my hand to it, researching and learning the basics, in order to complete this assignment. To that end, I have excluded any optional extras, and I fully acknowledge the files are likely at their most basic. However, I enjoyed working my way through it and gaining an understanding.



Changes/Fixes:
- Dockerfile typo - FROM node:18-alpnie
- Dockerfile port fix - EXPOSE 8000 (instead of 3000)



-- Local Setup --

Terminals:
choco install nodejs      (also installs npm)
choco install docker
choco install docker-desktop    (configure, enable K8s & start docker daemon)
wsl --update

*** Test App runs:
npm install               (installs modules & deps \node_modules for local .json)
npm run start             (runs package.json start script - executes server.js)
Browse to http://localhost:8000/  - confirm App runs correctly

*** Test docker container runs:
docker build . -t "nodejs-app"
docker run -d -p 8000:8000 nodejs-app
Browse to http://localhost:8000/  - confirm App running in container correctly

*** Test K8s container runs:
Create basic k8s deployment & service files:
kubectl apply -f .\deployment.yaml
kubectl apply -f .\service.yaml
kubectl port-forward service/nodejs-app-service 8000:80
Browse to http://localhost:8000/  - confirm App running in K8s container correctly

*** Setup Jenkins server
Use C:\BronA\Setups\JenkinsServer\Dockerfile - to create image
docker build -t jenkins-server .
docker run -d -p 8080:8080 -v jenkins_home:/var/jenkins_home jenkins-server
docker exec -it <container-id> cat /var/jenkins_home/secrets/initialAdminPassword
