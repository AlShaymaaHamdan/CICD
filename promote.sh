#!/bin/bash

# Save latest test tag
LATEST_TAG=$(aws ecr describe-images \
    --repository-name cicd-aseel \
    --region "$AWS_REGION" \
    --output json \
    | jq -r '
    .imageDetails[]
    | select(.imageTags != null)
    | select([.imageTags[] | contains("test")] | any)
    | {pushedAt: .imagePushedAt, tag: (.imageTags[] | select(contains("test")))}
    ' | jq -s 'sort_by(.pushedAt) | last.tag')

# Remove quotations from latest test tag
           
LATEST_TAG=$(echo "$LATEST_TAG" | tr -d '"')
echo "$LATEST_TAG"

# Pull Latest test tag
docker pull $AWS_ECR_URI/cicd-shaymaa:$LATEST_TAG

# Save Base Tag
BASE_TAG=$(echo "$LATEST_TAG" | cut -d'-' -f1 | tr -d '"')
echo "$BASE_TAG"

# retag the latest test tag
docker tag $AWS_ECR_URI/cicd-shaymaa:$LATEST_TAG $AWS_ECR_URI/cicd-shaymaa:$BASE_TAG
         
# Push Base tag
docker push $AWS_ECR_URI/cicd-shaymaa:$BASE_TAG