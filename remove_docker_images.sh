images=($(docker images -q -a))
if [[ "${#images[@]}" -gt 0 ]]; then
	# because "docker rmi -f" might remove an image in the list while removing
	# its parent, we use "docker inspect" to check if the image actually still
	# exists before requesting removal (so we can separate out genuine docker
	# errors from issues with the removal order)
	for image in "${images[@]}"; do
		if docker inspect "$image" > /dev/null 2>&1; then
			echo "Removing image: $image"
			if ! docker rmi -f "$image"; then
				ok=false
			fi
		fi
	done
fi

# double check there's no images left
if ! [[ -z "$(docker images -q -a)" ]]; then
	echo "WARNING: there are still some images left behind..."
	ok=false
fi
