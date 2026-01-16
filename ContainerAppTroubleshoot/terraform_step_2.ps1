$ACR_NAME = "acatroubleshootacr"
$REPO     = "samples/web"
$TAG      = "latest"

az acr login -n $ACR_NAME
$ACR_LOGIN_SERVER = az acr show -n $ACR_NAME --query loginServer -o tsv

$IMAGE = "$($ACR_LOGIN_SERVER)/$($REPO):$TAG"   # bezpieczna interpolacja
docker build -t $IMAGE .
docker push $IMAGE

