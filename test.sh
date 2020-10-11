#! /bin/bash

get_folders() {
    folders=$(ls ./root)
}

# This will be a cURL request to the ${ECS_CONTAINER_METADATA_URI_V4} endpoint
get_container_id() {
    container_id=$(cat ./metadata.json | jq .DockerId -r)
}

get_free_folder() {
    # Iterate folders
    for folder in "${folders[@]}"
    do
        found=true

        # Iterate running containers
        # This will be a cURL request to the ${ECS_CONTAINER_METADATA_URI_V4}/task endpoint
        for id in $(jq .Containers[].DockerId -r ./task-metadata.json )
        do
            # If there's a container that matches the folder, exit loop and check next folder
            if [ "$id" = "$folder" ] ; then
                found=false
                break
            fi
        done

        # If we've compared all the containers to the folder then we've found a match
        if [ "$found" = true ] ; then
            free_folder="$folder"
            break
        fi
    done
}

initialise_folder() {
    if [ -n "$free_folder" ] ; then
        mv ./root/"${free_folder}" ./root/"${container_id}" 
    else
        mkdir ./root/"${container_id}"
    fi
}

get_container_id
get_folders
get_free_folder
initialise_folder