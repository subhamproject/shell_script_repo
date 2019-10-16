export BEFORE_DATETIME=$(date --date='10 weeks ago' +"%Y-%m-%dT%H:%M:%S.%NZ")
docker images -q | while read IMAGE_ID; do
    export IMAGE_CTIME=$(docker inspect --format='{{.Created}}' --type=image ${IMAGE_ID})
    if [[ "${BEFORE_DATETIME}" > "${IMAGE_CTIME}" ]]; then
        echo "Removing ${IMAGE_ID}, ${BEFORE_DATETIME} is earlier then ${IMAGE_CTIME}"
        docker rmi -f ${IMAGE_ID};
    fi;
done




=====================================================================================
#!/bin/bash

# remove not running containers
docker rm $(docker ps -f "status=exited" -q)

declare -A used_images

# collect images which has running container
for image in $(docker ps | awk 'NR>1 {print $2;}'); do
    id=$(docker inspect --format="{{.Id}}" $image);
    used_images[$id]=$image;
done

# loop over images, delete those without a container
for id in $(docker images --no-trunc -q); do
    if [ -z ${used_images[$id]} ]; then
        echo "images is NOT in use: $id"
        docker rmi $id
    else
        echo "images is in use:     ${used_images[$id]}"
    fi
done


======================================================================

#!/bin/bash

imgs=$(docker images | awk '/<none>/ { print $3 }')
if [ "${imgs}" != "" ]; then
   echo docker rmi ${imgs}
   docker rmi ${imgs}
else
   echo "No images to remove"
fi

procs=$(docker ps -a -q --no-trunc)
if [ "${procs}" != "" ]; then
   echo docker rm ${procs}
   docker rm ${procs}
else
   echo "No processes to purge"
fi
