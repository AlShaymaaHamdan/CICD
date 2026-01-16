# retag the latest test tag
docker tag $AWS_ECR_URI/cicd-shaymaa:$LATEST_TAG $AWS_ECR_URI/cicd-shaymaa:$BASE_TAG
         
# Push Base tag
docker push $AWS_ECR_URI/cicd-shaymaa:$BASE_TAG


# Output for GitHub Actions
echo "BASE_TAG=$BASE_TAG" >> "$GITHUB_OUTPUT"